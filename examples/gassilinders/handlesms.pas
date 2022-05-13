unit handleSMS;

interface

procedure startSMShandlerThread;

procedure doNotifySMS;

procedure initUart;
procedure initModem;
procedure processModemEvents;

implementation

uses
  gsmtypes, gsmparser, shared, uart, uart_types, readadc, pressureswitchover,
  storage, logtouart;

const
  UART_FIFO_BUFFER_SIZE = 1024;
  UartPort = 2;
  TX_PIN = 17;
  RX_PIN = 16;

var
  gsm: TGsmParser;
  s: shortstring;
  waitForReady: boolean;
  i: integer;
  // Incoming phone message/call ID
  incomingPhoneNumber: string[16];
  gotRequest, gotCall: boolean;
  sendNotification: boolean;

procedure initUart;
var
  uart_cfg: Tuart_config;
begin
  uart_cfg.baud_rate  := 9600;
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
  uart_cfg.rx_flow_ctrl_thresh := 0; // unclear why this is required
  uart_cfg.source_clk := UART_SCLK_APB;

  uart_driver_install(UartPort, UART_FIFO_BUFFER_SIZE, UART_FIFO_BUFFER_SIZE, 0, nil, 0);
  uart_param_config(UartPort, @uart_cfg);
  uart_set_pin(UartPort, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
  Sleep(100);
  uart_flush_input(UartPort);
end;

procedure serialTransmitStr(s: shortstring);
begin
  logwrite('>> ');
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
    logwrite('<< ');
    logwriteln(Result);
  end
  else
  begin
    Result := '';
    // Give another task some space
    Sleep(10);
  end;
end;

procedure processCall(msg: shortstring);
var
  j: integer;
begin
  // +CLIP: "+27xxxxxxxxx",145,"",0,"",0
  j := pos('",', msg);
  if j > 9 then
  begin
    incomingPhoneNumber := copy(msg, 9, j - 9);
    // Check if this is kind of a proper phone number
    // Mainly to filter out network messages
    if (incomingPhoneNumber[1] = '+') and (length(incomingPhoneNumber) > 8) then
    begin
      gotRequest := true;
      gotCall := true;
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
    if (incomingPhoneNumber[1] = '+') and (length(incomingPhoneNumber) > 8) then
      gotRequest := true;
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
    waitForReady := true
  // Incoming call identification
  else if pos('+CLIP', s) = 1 then
    processCall(s);
end;

function statusReport: shortstring;
var
  s: string[4];
  i: integer;
begin
  Result := 'Cyl# Pres'#10;
  for i := 0 to high(Pressures) do
  begin
    Str((i+1):4, s);
    Result := Result + s + ' ';
    Str(Pressures[i]:3, s);
    Result := Result + s + #10;
  end;
  Result := Result + 'Valve open: ' + getCurrentOpenValve;
end;

procedure sendStatusReport(constref dest: shortstring);
var
  status: shortstring;
begin
  status := statusReport;
  gsm.sendSMS(dest, status);
end;

procedure sendStatusReportToAll;
var
  status: shortstring;
  s: string[4];
  i: integer;
begin
  status := statusReport;
  for i := 0 to high(PhoneNumbers) do
  begin
    if PhoneNumbers[i] > 0 then
    begin
      Str(PhoneNumbers[i], s);
      s := '+27' + s;
      gsm.sendSMS(s, status);
      Sleep(10);
    end;
  end;
end;

procedure doNotifySMS;
begin
  sendNotification := true;
end;

procedure initModem;
begin
  waitForReady := false;

  gsm.Init(@serialTransmitStr, @serialReadString);
  gsm.msgCallback := @handleUnsolicitedMsg;

  // Check if modem is active
  logwriteln('Checking ready');
  gsm.sendATCommand('AT', 3);
  if not gsm.commandCompleted then
  begin
    writeln('Waiting for READY');
    while not waitForReady do
    begin
      gsm.process;
      Sleep(100);
    end;
  end;

  // Check if in auto baud mode
  i := gsm.getBaudRate;
  if i = 0 then
    gsm.setBaudRate(115200);

  // Check SIM is OK
  repeat
    // Wait for sim to be ready:
    if gsm.getSimStatus <> ssReady then
    begin
      logwriteln('SIM not ready, retry');
      Sleep(2000);
    end
    else
    begin
      logwriteln('SIM ready.');
      break;
    end;
  until false;

  // Check network connection is OK
  repeat
    // Query network operator:
    s := gsm.getNetworkOperator;
    if s <> '' then
    begin
      logwrite('Network operator: ');
      logwriteln(s);
    end
    else
    begin
      logwriteln('Network not ready, retry');
      gsm.process;
      Sleep(2000);
    end;
  until s <> '';

  //logwrite('Signal strength: ');
  //logwrite(gsm.getNetworkSignalQuality)
  //logwriteln('%');

  // Set new SMS delivered straight to terminal
  gsm.sendATCommand('AT+CNMI=2,2');

  // SMS format = text
  gsm.sendATCommand('AT+CMGF=1');

  // Enable CLIP
  logwriteln('Enable CLIP');
  gsm.sendATCommand('AT+CLIP=1');
end;

procedure processModemEvents;
begin
  gsm.process;
  if gotRequest then
  begin
    if gotCall then
    begin
      // Cancel incoming call
      gsm.sendATCommand('ATH');
      gotCall := false;
    end;
    logwrite('Replying to ');
    logwriteln(incomingPhoneNumber);
    sendStatusReport(incomingPhoneNumber);
    gotRequest := false;
    incomingPhoneNumber := '';
  end;

  if sendNotification then
  begin
    sendNotification := false;
    sendStatusReport('+27836282994');
    //sendStatusReportToAll;
  end;
end;

function SMSthread(parameter : pointer): ptrint; noreturn;
begin
  logwriteln('SMS thread starting');
  initUart;
  initModem;

  // Wait for event from modem
  repeat
    processModemEvents;
    Sleep(250);
  until false;
end;

procedure startSMShandlerThread;
var
  threadID: TThreadID;
begin
  BeginThread(@SMSthread,      // thread to launch
             nil,              // pointer parameter to be passed to thread function
             threadID,         // new thread ID, not used further
             5000);            // stacksize
end;

end.

