unit handleSMS;

interface

type
  TCylinderEvent = (ceWarningPressure, ceLowPressure, ceCylChangeover);

procedure startSMShandlerThread;

// For warning/low pressure, cylID indicates the cylinder ID
// For changeover, cylID=0 refers to cylinder A, cylID=1 refers to cylinder B
procedure sendNotification(msg: shortstring);

procedure initModem;
procedure processModemEvents;

// Requests a network reconnect of the modem
procedure resetModemNetwork;
function resetModemFlagCleared: boolean;

implementation

uses
  gsmtypes, gsmparser, shared, uart, uart_types, readadc, pressureswitchover,
  storage, logtouart, esp_err;

type
  TModemState = (msDoStart, msCheckAT, msWaitForReady, msCheckSerialSpeed, msWaitSimReady, msWaitOperator, msReady);

const
  UART_FIFO_BUFFER_SIZE = 4*1024;
  UartPort = 2;
  TX_PIN = 17;
  RX_PIN = 16;

var
  gsm: TGsmParser;
  gotModemReady: boolean;
  i: integer;
  // Incoming phone message/call ID
  incomingPhoneNumber: string[16];
  gotRequest: boolean;
  // Reporting/notification flags
  flagNotification: boolean;
  notifyMsg: shortstring;
  modemState: TModemState = msDoStart;
  flagResetNetwork: boolean = false;

procedure initUart;
var
  uart_cfg: Tuart_config;
  err: Tesp_err;
begin
  uart_cfg.baud_rate  := 9600;
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
  uart_cfg.rx_flow_ctrl_thresh := 0; // unclear why this is required
  uart_cfg.source_clk := UART_SCLK_APB;

  err := uart_driver_install(UartPort, UART_FIFO_BUFFER_SIZE, UART_FIFO_BUFFER_SIZE, 0, nil, 0);
  if err <> ESP_OK then
  begin
    logwrite('Error calling uart_driver_install #');
    logwriteln(UartPort);
  end;
  uart_param_config(UartPort, @uart_cfg);
  uart_set_pin(UartPort, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
  Sleep(100);
  uart_flush_input(UartPort);
end;

procedure serialTransmitStr(s: shortstring);
begin
  logwrite('modem> ');
  logwriteln(s);
  uart_write_bytes(UartPort, @s[1], length(s));
end;

function serialReadString: shortstring;
var
  len: integer;
begin
  uart_get_buffered_data_len(UartPort, @len);
  if len > 255 then
    len := 255;

  if len > 0 then
  begin
    SetLength(Result, len);
    FillByte(Result[1], 0, len);
    len := uart_read_bytes(UartPort, @Result[1], len, 1);
    logwrite('modem< ');
    logwriteln(Result);
  end
  else
  begin
    Result := '';
    // Give another task some space
    //Sleep(10);
  end;
end;

function numberIsRegistered(const phoneNumber: shortstring): boolean;
var
  i: integer;
  s: string[16];
  num: uint32;
begin
  Result := false;
  Sleep(10);
  if length(phoneNumber) < 18 then
    SetLength(s, length(phoneNumber)-3)
  else
    exit;

  // Assume number starts with +27 prefix, only start reading 4th character to get local number
  for i := 4 to length(phoneNumber) do
    s[i-3] := phoneNumber[i];
  Val(s, num);
  logwrite('Phone number: ');
  logwrite(s);
  logwrite('(');
  logwrite(num);
  logwriteln(')');

  i := 0;
  if num = 0 then
    exit;
  while (i < length(storage.PhoneNumbers)) and not Result do
  begin
    Result := storage.PhoneNumbers[i] = num;
    inc(i);
  end;
end;

procedure processCall(msg: shortstring);
var
  j: integer;
begin
  // Hang up
  gsm.sendATCommand('ATH', 2);
  // In case of error, retry
  if not gsm.commandSuccess then
    gsm.sendATCommand('ATH', 2);

  // +CLIP: "+27xxxxxxxxx",145,"",0,"",0
  j := pos('",', msg);
  if j > 9 then
  begin
    incomingPhoneNumber := copy(msg, 9, j - 9);
    // Check if this is kind of a proper phone number
    // Mainly to filter out network messages
    if (incomingPhoneNumber[1] = '+') and (length(incomingPhoneNumber) > 8) and
      numberIsRegistered(incomingPhoneNumber) then
    begin
      gotRequest := true;
    end
    else
    begin
      logwrite('Rejecting number: ');
      logwriteln(incomingPhoneNumber);
      gotRequest := false;
    end;
  end;
end;

procedure processSMS(msg: shortstring);
var
  j: integer;
begin
  j := pos('","', msg);
  if j > 9 then
  begin
    incomingPhoneNumber := copy(msg, 8, j - 8);
    // Check if this is kind of a proper phone number
    // Mainly to filter out network messages
    if (incomingPhoneNumber[1] = '+') and (length(incomingPhoneNumber) > 8) and
      numberIsRegistered(incomingPhoneNumber) then
      gotRequest := true
    else
    begin
      logwrite('Rejecting number: ');
      logwriteln(incomingPhoneNumber);
      gotRequest := false;
    end;
  end;
end;

// Called from parser thread
// Do not call gsm functionality here
// it will deadlock because the parser is busy in this callback
procedure handleUnsolicitedMsg(s: shortstring);
begin
  // Check for new SMS notification
  // +CMT: "+27XXXXXXXXX","","22/03/30,20:50:11+08"#13#10Hallo#13#10
  if pos('+CMT: "', s) > 0 then
    processSMS(s)
  // Modem message sent after startup
  else if pos('RDY', s) > 0 then
    gotModemReady := true
  // Incoming call identification
  else if pos('+CLIP', s) = 1 then
    processCall(s);
end;

function statusReport: shortstring;
var
  s: string[4];
  i: integer;
begin
  Result := 'Cyl.   Pres'#10;
  for i := 0 to high(Pressures) do
  begin
    Result := Result + CylinderNames[i] + ' ';
    Str(Pressures[i]:3, s);
    Result := Result + s + #10;
  end;
  Result := Result + 'Ar cylinder: ' + getCurrentOpenValve;
  Result := Result + #10#10'Modem'#10;
  Result := Result + 'Network: ' + gsm.getNetworkOperator;

  Result := Result + #10'Signal: ';
  Str(gsm.getNetworkSignalQuality, s);
  Result := Result + s + '%';
end;

procedure sendStatusReport(constref dest: shortstring);
var
  status: shortstring;
begin
  status := statusReport;
  gsm.sendSMS(dest, status);
end;

procedure sendMessagetoAll(const msg: shortstring);
var
  i: integer;
  phoneNumber: string[16];
begin
  for i := 0 to high(PhoneNumbers) do
  begin
    if PhoneNumbers[i] > 0 then
    begin
      Str(PhoneNumbers[i], phoneNumber);
      phoneNumber := '+27' + phoneNumber;
      gsm.sendSMS(phoneNumber, msg);
      Sleep(10);
    end;
  end;
end;

procedure sendNotification(msg: shortstring);
begin
  notifyMsg := msg;
  flagNotification := true;
end;

procedure resetModemNetwork;
begin
  flagResetNetwork := true;
end;

function resetModemFlagCleared: boolean;
begin
  result := not flagResetNetwork;
end;

procedure initModem;
const
  canceledSMS: boolean = false;
var
  s: string[24];
begin
  if modemState = msDoStart then
  begin
    logwriteln('Init modem UART');
    initUart;
    gotModemReady := false;
    gsm.Init(@serialTransmitStr, @serialReadString);
    gsm.msgCallback := @handleUnsolicitedMsg;
    inc(modemState);
  end;

  if modemState = msCheckAT then
  begin
    // Check if modem is active
    logwriteln('Checking AT');
    gsm.sendATCommand('AT', 2);
    if not gsm.commandCompleted then
    begin
      // Could possibly be waiting for SMS message input, if previous SMS process was interrupted
      if not canceledSMS then
      begin
        // transmit cancel command
        serialTransmitStr(#27);
        gsm.process;
        canceledSMS := true;
        logwriteln('Waiting for READY');
      end
      else
        inc(modemState);
      exit;
    end
    else
    begin
      logwriteln('AT response OK');
      modemState := msWaitSimReady;
    end;
  end;

  if (modemState = msWaitForReady) then
  begin
    gsm.process;
    if gotModemReady then
      inc(modemState)
    else
      exit;
  end;

  // Check if in auto baud mode
  if modemState = msCheckSerialSpeed then
  begin
    i := gsm.getBaudRate;
    if i = 0 then
    begin
      logwriteln('Auto baud detected.');
      gsm.setBaudRate(9600);
    end
    else
    begin
      logwrite('Baud detected: ');
      logwriteln(i);
    end;
    inc(modemState);
  end;

  // Check SIM is OK
  if modemState = msWaitSimReady then
  begin
    if gsm.getSimStatus <> ssReady then
    begin
      logwriteln('SIM not ready');
      exit;
    end
    else
    begin
      logwriteln('SIM ready.');
      inc(modemState);
    end;
  end;

  // Check network connection is OK
  if modemState = msWaitOperator then
  begin
    // Query network operator:
    s := gsm.getNetworkOperator;
    if s <> '' then
    begin
      logwrite('Network operator: ');
      logwriteln(s);
      inc(modemState);
    end
    else
    begin
      logwriteln('Network not ready, retry');
      exit;
    end;
  end;

  logwrite('Signal strength: ');
  logwrite(gsm.getNetworkSignalQuality);
  logwriteln('%');

  // Set new SMS delivered straight to terminal
  gsm.sendATCommand('AT+CNMI=2,2');

  // SMS format = text
  gsm.sendATCommand('AT+CMGF=1');

  // Enable CLIP
  logwriteln('Enable CLIP');
  gsm.sendATCommand('AT+CLIP=1');
  logwriteln('Modem init OK');
end;

procedure processModemEvents;
begin
  if not (modemState = msReady) then
  begin
    logwrite('i');
    initModem;
  end
  else
  begin
    logwrite('m');
    gsm.process;
    if gotRequest then
    begin
      logwrite('Replying to ');
      logwriteln(incomingPhoneNumber);
      sendStatusReport(incomingPhoneNumber);
      gotRequest := false;
      incomingPhoneNumber := '';
    end
    else if flagNotification then
    begin
      flagNotification := false;
      sendMessagetoAll(notifyMsg);
    end;
  end;
end;

function SMSthread(parameter : pointer): ptrint; noreturn;
begin
  logwriteln('SMS thread starting');
  // Flag to initialize from scratch, starting with UART
  modemState := msDoStart;
  repeat
    processModemEvents;
    Sleep(500);

    if flagResetNetwork then
    begin
      gsm.sendATCommand('AT+CFUN=0');
      gsm.sendATCommand('AT+CFUN=1,1');
      flagResetNetwork := false;
    end;
  until false;
end;

procedure startSMShandlerThread;
var
  threadID: TThreadID;
begin
  BeginThread(@SMSthread,      // thread to launch
             nil,              // pointer parameter to be passed to thread function
             threadID,         // new thread ID, not used further
             16*1024);            // stacksize
end;

end.

