unit gsmparser;

{$mode ObjFPC}{$H-}

interface

uses
  gsmtypes{, classes};

type
  TModemState = (
    msNone,
    msWaitCmdEcho, msWaitResponse, msGotResponse,
    msWaitUnsolicited, msGotUnsolicited);

  TMsgCallback = procedure(s: shortstring);
  TSendString = procedure(s: shortstring);
  TReadString = function: shortstring;

  { TGsmParser }
  TGsmParser = {$if defined(FREERTOS) or defined(EMBEDDED)}object{$else}class{$endif}
  type
    TSmsSendState = (sssNone, sssWaitPrompt, sssGotPrompt);
  private
    transactionLog: shortstring;
    // Parser state variables
    modemState: TModemState;
    previousCmd: shortstring;
    tmp: shortstring;
    unsolicitedMsg: shortstring;
    waitLF: boolean;
    waitForSecondPart: boolean;

    // Handlers for sending and reading data over communication channel with modem
    sendString: TSendString;
    readString: TReadString;

    procedure ParseChar(c: char);
    procedure resetParser;
    procedure logUnexpectedState(AWaitLF: boolean; c: char; state: TModemState);
  public
    commandSuccess: boolean;
    commandResponse: shortstring;

    msgCallback: TMsgCallback;

    commandCompleted: boolean;
    SMSstate: TSmsSendState;

    // Serial connection should already be established
    procedure Init(AsendCharFunc: TSendString; AreadStr: TReadString);
    // sendATCommand calls "process" until input has been received.
    // If response is delayed, this should yield/sleep to prevent WDT from timeout.
    procedure process;

    // Block until current parser state clears and
    // this command response received
    procedure sendATCommand(cmd: shortstring; timeoutSeconds: integer = {$ifdef DEBUG}100{$else}10{$endif}; terminateWithCR: boolean = true);

    //procedure Execute; override;

    function getSimStatus: TSimStatus;
    function getNetworkOperator: shortstring;
    function sendSMS(const dest: shortstring; msg: shortstring): boolean;
    // This function discards the bit errror rate, which is also included in response
    // Return value in percentage signal strength, with 100% = -52 dBm
    function getNetworkSignalQuality: integer;
    procedure getBatteryStatus(var chargeStatus: TBatteryChargeMode;
      var pctCapacity, milliVolts: integer);
    function getBaudRate: integer;
    function setBaudRate(const baud: integer): boolean;
  end;

implementation

{$include freertosconfig.inc} // To access configTICK_RATE_HZ

uses
  task, shared, logtouart;

{ TGsmParser }

procedure TGsmParser.Init(AsendCharFunc: TSendString; AreadStr: TReadString);
begin
  sendString := AsendCharFunc;
  readString := AreadStr;
  //inherited Create(true);  // Create suspended
  transactionLog := '';
  SMSstate := sssNone;
end;

procedure TGsmParser.process;
var
  s: shortstring;
  c: char;
begin
  s := readString();
  if s <> '' then
  begin
    for c in s do
      if (c > #0) and (c < #128) then // Only accept 7 bit chars
        ParseChar(c);
  end
  else
    // Could vary length of sleep duration according to command type
    // e.g. short period for internal modem commands with expected quick response
    // and longer periods for commands that require network access
    Sleep(10);
end;

procedure TGsmParser.logUnexpectedState(AWaitLF: boolean; c: char; state: TModemState);
var
  s: string[24];
begin
  logwrite('Unexpected state: waitLF = ');
  Str(AWaitLF, s);
  logwrite(s);
  logwrite(', c = #' + HexStr(ord(c), 2));
  logwrite(', modemstate = ');
  Str(state, s);
  logwriteln(s);
  logwrite('tmp = ');
  logwriteln(tmp);
end;

procedure TGsmParser.ParseChar(c: char);
begin
  case modemstate of
    msNone:
    begin
      if not (c in [#10, #13]) then
      begin
        modemstate := msWaitCmdEcho;
        if length(tmp) < 250 then
          tmp := tmp + c
        else
        begin
          logwrite('Modem: long string received: ');
          logwriteln(tmp);
        end;
      end
      else
      begin
        modemstate := msWaitUnsolicited;
        if c = #13 then
          waitLF := true;
      end;
    end;

    msWaitCmdEcho:
    begin
      if c = #13 then
      begin
        waitLF := true;
        if tmp = previousCmd then
        begin
          previousCmd := '';
          modemstate := msWaitResponse
        end
        else if tmp = '' then
          modemstate := msWaitUnsolicited
        else
        begin
          logUnexpectedState(waitLF, c, modemState);
          // Unexpected error
          commandSuccess := false;
          waitLF := false;
          tmp := '';
          modemstate := msNone;  // TODO: Problem, must sync again!
          commandCompleted := true;
        end;
        tmp := '';
      end
      else
      begin
        if length(tmp) < 250 then
          tmp := tmp + c
        else
        begin
          logwrite('Modem: long string received: ');
          logwriteln(tmp);
        end;
      end;
    end;

    msWaitResponse:
    begin
      if c in [#10, #13] then
      begin
        if waitLF then
        begin
          if c = #10 then
            waitLF := false
          // #13 is silently swallowed...
          else if not (c = #13) then
            logUnexpectedState(waitLF, c, modemState);
        end
        else if (c = #13) then
        begin
          //SMSstate := sssNone;
          modemstate := msGotResponse;
          waitLF := true;
        end
        else if (SMSstate = sssGotPrompt) then  // #10 in SMS, just add & continue
        begin
          if length(tmp) < 250 then
            tmp := tmp + c
          else
          begin
            logwrite('Modem: long string received: ');
            logwriteln(tmp);
          end;
        end
        else
          logUnexpectedState(waitLF, c, modemState);
      end
      else
      begin
        if length(tmp) < 250 then
          tmp := tmp + c
        else
        begin
          logwrite('Modem: long string received: ');
          logwriteln(tmp);
        end;
        if (SMSstate = sssWaitPrompt) and (tmp = '> ') then  // Send SMS prompt
        begin
          // Proceed with sending message
          tmp := '';
          SMSstate := sssGotPrompt;
          commandCompleted := true;
        end;
      end;
    end;

    msGotResponse:
    begin
      if waitLF and (c = #10) then
      begin
        if tmp = 'OK' then
        begin
          tmp := '';
          previousCmd := '';
          commandSuccess := true;
          modemstate := msNone;
          SMSstate := sssNone;
          commandCompleted := true;
        end
        else if tmp = 'ERROR' then
        begin
          tmp := '';
          previousCmd := '';
          commandSuccess := false;
          modemstate := msNone;
          commandCompleted := true;
        end
        else
        begin
          commandResponse := tmp;
          tmp := '';
          modemState := msWaitResponse;
          // Only one separator between message echo and message response
          if SMSstate = sssGotPrompt then
          begin
            SMSstate := sssNone;
            waitLF := false;
          end;
        end;
      end
      else if c <> #13 then
      begin
        tmp := '';
        previousCmd := '';
        commandSuccess := false;
        modemstate := msNone;
        commandCompleted := true;
      end
      else
        logUnexpectedState(waitLF, c, modemState);
    end;

    msWaitUnsolicited:
    begin
      if c in [#10, #13] then
      begin
        if waitLF then
        begin
          if c = #10 then
            waitLF := false
          else if not (c = #13) then
            logUnexpectedState(waitLF, c, modemState);
        end
        else if c = #13 then
          modemstate := msGotUnsolicited
        else // #10, possible line break in SMS message
          if length(tmp) < 250 then
            tmp := tmp + c
          else
          begin
            logwrite('Modem: long string received: ');
            logwriteln(tmp);
          end;
          //writeln('Unexpected state: waitLF = ', waitLF, ', c = #', HexStr(ord(c), 2), ', modemstate = ', modemState);
      end
      else
      begin
        tmp := tmp + c;
      end;
    end;

    msGotUnsolicited:
    begin
      if (c = #10) then
      begin
        if not waitForSecondPart and (pos('+CMT:', tmp) > 0) then // Check if this is two part reply
        begin
          waitForSecondPart := true;
          tmp := tmp + #13;
          modemstate := msWaitUnsolicited;
        end
        else
        begin
          // Could have slipped through after unsolicited message
          // TODO: Use lock here?
          if tmp <> '' then
          begin
            if not commandCompleted and (previousCmd <> '') and
              (tmp = previousCmd) then
              logwriteln('TODO: Must resync here.')
            else if Assigned(msgCallback) then
              msgCallback(tmp);

            waitForSecondPart := false;
            tmp := '';
            modemState := msNone;
          end
          else  // Possibly extra separator between unsolicited responses?
          begin
            waitLF := false;
            modemState := msWaitUnsolicited;
          end;
        end;
      end
      else if (c <> #13) then
      begin
        if Assigned(msgCallback) then
          msgCallback('Unexpected ERROR')
        else
          logUnexpectedState(waitLF, c, modemState);
        resetParser;
      end;
      //else
      //  logUnexpectedState(waitLF, c, modemState);
    end;
  end; // case
end;

procedure TGsmParser.resetParser;
begin
  tmp := '';
  unsolicitedMsg := '';
  waitLF := false;
  previousCmd := '';
  commandResponse := '';
  waitForSecondPart := false;
  modemState := msNone;
  commandCompleted := false;
end;

procedure TGsmParser.sendATCommand(cmd: shortstring; timeoutSeconds: integer;
  terminateWithCR: boolean);
var
  timeout, startTime, delta: integer;
begin
  // Block until current state clears
  timeout := timeoutSeconds * configTICK_RATE_HZ;
  startTime := xTaskGetTickCount;
  delta := 0;
  while not((modemstate = msNone) or (SMSstate = sssGotPrompt)) and (delta < timeout) do
  begin
    delta := xTaskGetTickCount - startTime;
    process;
  end;

  // Reset parser state if:
  // * SMSstate <> sssGotPrompt
  // * Timeout waiting for previous state to clear (even if waiting for SMS prompt).
  if (SMSstate < sssGotPrompt) or (delta >= timeout) then
    resetParser;
  previousCmd := cmd;

  if terminateWithCR then
    cmd := cmd + #13
  else // Exception is sending SMS message part
    cmd := cmd + #26;

  if Assigned(sendString) then
    sendString(cmd);

  startTime := xTaskGetTickCount;
  delta := 0;
  // Read and parse response
  while not commandCompleted and (delta < timeout) do
  begin
    Sleep(10);
    delta := xTaskGetTickCount - startTime;
    process;
  end;

  // In case of timeout, reset state of parser
  if not commandCompleted then
  begin
    logwriteln('Parser timeout');
    resetParser;
  end;
end;

{
procedure TGsmParser.Execute;
var
  c: char;
  res: integer;
  //dummyResponse: string;
  part1, part2: string;
begin
{  dummyResponse := #13#10'RDY'#13#10#13#10'+CFUN: 1'#13#10'AT+GSN'#13#13#10 +
    '869170034441742'#13#10#13#10'OK'#13#10#13#10'+CPIN: NOT INSERTED'#13#10 +
    'AT+CPIN?'#13#13#10'ERROR'#13#10'AT+CBC'#13#13#10'+CBC: 0,82,4059'#13#10#13#10 +
    'OK'#13#10'AT+COPS?'#13#13#10'+COPS: 0'#13#10#13#10'OK'#13#10'AT+CMGF?' +
    #13#13#10'ERROR'#13#10'AT+CMGF=1'#13#13#10'ERROR'#13#10'AT+CMGF?'#13#13#10 +
    'ERROR'#13#10'AT+CNMI?'#13#13#10'ERROR'#13#10'AT+IPR=?'#13#13#10 +
    '+IPR: (),(0,1200,2400,4800,9600,19200,38400,57600,115200,230400,460800)'+
    #13#10#13#10'OK'#13#10;}
{$ifdef DEBUG}

  repeat
    // Simulate receiving SMS
    part1 := #13#10'+CMT: "+27609741694","","22/03/30,20:50:11+08"'#13#10'Hallo'#13#10;
    //part1 := #13#10'+CMT: "+27609741694","","22/04/10,08:19:59+08"'#13#10'B'#10'J'#10'X2'#13#10;

    for c in part1 do
      ParseChar(c);

    // Force thread switch
    Sleep(250);

    part1 := 'AT+CMGS="+27609741694"'#13#13#13#10'> ';
    //part1 := 'AT+CMGS="+27609741694"'#13#13#10'> ';
    repeat
      Sleep(250);
    until previousCmd <> '';

    for c in part1 do
      ParseChar(c);

    part2 := 'x2'#13#10'+CMGS: 74'#13#10#13#10'OK'#13#10;
    //part2 := 'B'#10'J'#10'X2x2'#13#10'+CMGS: 74'#13#10#13#10'OK'#13#10;
    // Give main thread time to send message portion of SMS
    repeat
      Sleep(250);
    until (SMSstate = sssGotPrompt);// and (pos(#$1A, previousCmd) > 0);

    for c in part2 do
      ParseChar(c);

    repeat
      Sleep(250);
    until commandCompleted;

    part2 := #13#10#13#10'RDY'#13#10#13#10'+CFUN: 1'#13#10;
    for c in part2 do
      ParseChar(c);
    // Force thread switch
    Sleep(100);
  until false;
{$endif DEBUG}
  while not Terminated do
  begin
    //res := serial.Read(c, 1);
    c := readChar();
    if {(res = 1) and} (c > #0) and (c < #255) then
    begin
      ParseChar(c);
      // Allow time to
      if (modemState = msNone) or commandCompleted then
        Sleep(100)
      else
        Sleep(10);
    end
    else
    begin
      if res = -1 then
        writeln('Error: ', ErrNo);
      Sleep(250);
    end;
  end;
end;
}
function TGsmParser.getSimStatus: TSimStatus;
var
  i: integer;
  s: shortstring;
begin
  Result := ssError;
  sendATCommand('AT+CPIN?', 5);
  if commandSuccess and (commandResponse <> '') then
  begin
    s := commandResponse;
    // Response: +CPIN: <code>
    i := pos('+CPIN: ', s);
    if i > 0 then
    begin
      Delete(s, 1, 7);
      if s = 'READY' then
        Result := ssReady
      else if s = 'SIM PIN' then
        Result := ssSimPin
      else if s = 'SIM PUK' then
        Result := ssSimPuk
      else if s = 'PH_SIM PIN' then
        Result := ssPhoneSimPin
      else if s = 'PH_SIM PUK' then
        Result := ssPhoneSimPuk
      else if s = 'SIM PIN2' then
        Result := ssSimPin2
      else if s = 'SIM PUK2' then
        Result := ssSimPuk2;
    end;
  end;
  commandResponse := '';
end;

function TGsmParser.getNetworkOperator: shortstring;
var
  i: integer;
  s: shortstring;
begin
  Result := '';
  sendATCommand('AT+COPS?', 5);
  if commandSuccess and (commandResponse <> '') then
  begin
    s := commandResponse;
    // Response: +COPS: <mode>[,<format>,<oper>]
    i := pos(',', s);
    if i > 0 then
      Delete(s, 1, i);
    i := pos(',', s);
    if i > 0 then
    begin
      Delete(s, 1, i);
      Result := s;
    end;
  end;
  commandResponse := '';
end;

function TGsmParser.sendSMS(const dest: shortstring; msg: shortstring): boolean;
begin
  Result := false;
  SMSstate := sssWaitPrompt;
  // Initiate SMS:
  sendATCommand('AT+CMGS="'+dest+'"', 100);

  // then send message itself
  if SMSstate = sssGotPrompt then
  begin
    // Use #13 to help
    //msg := msg + #26;
    //Sleep(100);
    commandCompleted := false;
    sendATCommand(msg, 100, false);
    Result := commandSuccess;
  end
  else
  begin
    // Cancel SMS transmission, in case modem is waiting for input to be sent.
    if Assigned(sendString) then
      sendString(#27);
  end;
  SMSstate := sssNone;
end;

function TGsmParser.getNetworkSignalQuality: integer;
var
  i, err: integer;
  s: shortstring;
begin
  sendATCommand('AT+CSQ', 5);
  Result := 0; // not known or not detectable
  if commandSuccess and (commandResponse <> '') then
  begin
    s := commandResponse;
    // Response: +CSQ: 17,0
    i := pos('+CSQ: ', s);
    if i > 0 then
      Delete(s, 1, 6);
    i := pos(',', s);
    if i > 0 then
    begin
      Delete(s, i, 10);
      Val(s, Result, err);
      // A value of 99 indicates unknown or not detectable, map to 0
      if (err <> 0) or (Result > 31) then
        Result := 0;
    end;
  end;
  commandResponse := '';
  // Max = 31, x3.2 = 99%
  Result := Result * 3 + (Result * 2) div 10;
end;

procedure TGsmParser.getBatteryStatus(var chargeStatus: TBatteryChargeMode; var pctCapacity,
  milliVolts: integer);
var
  i, err: integer;
  s, tmpStr: shortstring;
begin
  sendATCommand('AT+CBC', 5);
  if commandSuccess and (commandResponse <> '') then
  begin
    s := commandResponse;
    // Response: +CSQ: 17,0
    i := pos('+CBC: ', s);
    if i > 0 then
      Delete(s, 1, 6);
    i := pos(',', s);
    if i > 1 then
    begin
      tmpStr := copy(s, 1, i-1);
      Delete(s, 1, i);
      Val(tmpStr, i, err);
      if (err = 0) and (i > -1) and (i <= ord(bcmChargingFinished)) then
        chargeStatus := TBatteryChargeMode(i)
      else
        chargeStatus := bcmNotCharging;

      i := pos(',', s);
      if i > 1 then
      begin
        tmpStr := copy(s, 1, i-1);
        delete(s, 1, i);
        val(tmpStr, i, err);
        if (err = 0) and (i > 0) and (i < 101) then
          pctCapacity := i
        else
          pctCapacity := 0;

        val(s, i, err);
        if (err = 0) and (i > 0) and (i < 10000) then
          milliVolts := i
        else
          milliVolts := 0;
      end;
    end;
  end;
  commandResponse := '';
end;

function TGsmParser.getBaudRate: integer;
var
  i: integer;
begin
  sendATCommand('AT+IPR?', 5);
  Result := -1;
  // Response = +IPR: 115200
  if commandSuccess and (commandResponse <> '') then
  begin
    i := pos('+IPR: ', commandResponse);
    if i = 1 then
    begin
      Delete(commandResponse, 1, 6);
      Val(commandResponse, Result, i);
      if i <> 0 then
        Result := -1;
    end;
  end;
  commandResponse := '';
end;

function TGsmParser.setBaudRate(const baud: integer): boolean;
var
  s: string[7];
begin
  Str(baud, s);
  sendATCommand('AT+IPR='+s);
  Result := commandSuccess;
end;

end.

