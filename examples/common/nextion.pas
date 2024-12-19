unit nextion;

interface

{$ifndef freertos}
uses
  sysutils;
{$endif}

const
  NexCommandInvalid            = $00;
  NexCommandSuccess            = $01;
  NexInvalidCID                = $02;
  NexInvalidPID                = $03;
  NexInvalidPictureID          = $04;
  NexInvalidFontID             = $05;
  NexInvalidFileOper           = $06;
  NexInvalidCRC                = $09;
  NexInvalidBaudRate           = $11;
  NexInvalidWaveForm           = $12;
  NexInvalidVarAttrib          = $1A;
  NexInvalidVarOp              = $1B;
  NexAssignmentFailed          = $1C;
  NexEEPROMFailed              = $1D;
  NexParamNumInvalid           = $1E;
  NexIOFailed                  = $1F;
  NexInvalidEscape             = $20;
  NexVarNameTooLong            = $23;
  NexBufferOverflow            = $24;

  // Own event definition
  CustomEventPageExit          = $60;   // 60 xx FF FF FF, xx is ID of page just exited
  NexEventTouch                = $65;   // Return page ID, component ID and event data
  NexCurrentPageNo             = $66;

  // Following two events only valid when sendxy=1
  NexEventTouchCoord           = $67;   // Returns touch coordinate in x, y, event format.
  NexEventTouchCoordSleep      = $68;   // Returns touch coordinate in x, y, event format, and exiting sleep

  NexStringData                = $70;
  NexNumericData               = $71;
  NexEventAutoSleep            = $86;
  NexEventAutoWake             = $87;
  NexEventReady                = $88;
  NexEventUpgrading            = $89;

  NexEventTransparentDataDone  = $FD;
  NexEventTransparentDataReady = $FE;

  NexEventStartup              = $FF;  // Own definition, actually a sequence of three zeros

type
  TNextionComponent = record
    pid,
    cid: integer;
  end;

  // Event handlers
  TNextionGeneralEvent = procedure(event: byte);
  TNextionTouchEvent = procedure(pid, cid: integer; pressed: boolean);
  TNextionTouchCoordEvent = procedure(x, y: integer; pressed: boolean);
  TNextionPageExitEvent = procedure(pageID: integer);

  // Communication handlers
  TWriteStr = procedure(data: shortstring);
  TReadStr  = function: shortstring;

  TNexState = (nsNone,          // Initial state, ready for any input
               nsProcessReply,  // Got a reply header
               nsProcessEvent,  // Got an event header
               nsReplyWaitEnd,  // Wait for message ending, $FF $FF $FF
               nsEventWaitEnd,  // Wait for message ending, $FF $FF $FF. Also dispatches events
               nsWaitEnd);      // After unvalid characters, wait for message ending, $FF $FF $FF

  TNexAttribute = (naTxt, naVal);

  { TNextionHandler }

  TNextionHandler = {$ifdef FREERTOS}object{$else}class{$endif}
  private
    messageState: TNexState;
    messageHeader: byte;
    // Set to false when command is submitted, wait until commandComplete is true
    // But only if command has a response, i.e. if bkcmd > 0, or a data request
    // Assume bkcmd = 0 for command flow, so only set when requesting data
    commandCompleted: boolean;

    // Private storage for various response data
    // Touch events
    fPid, fCid: integer;
    // Touch coordinate events
    fX, fY: word;
    // Touch/Coordinate events: pushed/released
    fPressed: boolean;
    // Text response
    fText: shortstring;
    // Numeric response
    fNumber: int32;
  public
    pageExitHandler: TNextionPageExitEvent;
    touchHandler: TNextionTouchEvent;
    touchCoordHandler: TNextionTouchCoordEvent;
    generalEventHandler: TNextionGeneralEvent;
    readHandler: TReadStr;
    writeHandler: TWriteStr;

    procedure init;
    procedure processInputData;

    function setText(const ID: TNextionComponent; value: shortstring): boolean;
    function getText(const ID: TNextionComponent; out text: shortstring): boolean;

    function setValue(const ID: TNextionComponent; value: integer): boolean;
    function getValue(const ID: TNextionComponent; out val: integer): boolean;

    function setCurrentPage(pageID: integer): boolean;
    function getCurrentPage(out pageID: integer): boolean;

    procedure sendCommand(cmd: shortstring; timeout_ms: integer = 200);
  end;

implementation

uses
  {$ifdef FREERTOS}task, portmacro,{$endif} logtouart;

{$ifdef FREERTOS}
procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;
{$endif}

{ TNextionHandler }

procedure TNextionHandler.init;
begin
  messageState := nsNone;
  commandCompleted := false;
end;

procedure TNextionHandler.processInputData;
const
  endMarkerCount: integer = 0; // Count FF chars which marks end of message
  startupZeroes: integer = 0;  // Count #00 chars which marks display startup
  dataCount: integer = 0;  // Count chars processed while extracting data from message
var
  data: shortstring;
  c: char;
begin
  if Assigned(readHandler) then
    data := readHandler()
  else
    exit;

  for c in data do
  begin
    case messageState of
      nsNone:
      begin
        dataCount := 0;
        endMarkerCount := 0;
        messageHeader := ord(c);
        startupZeroes := 0;
        case ord(c) of
          // Replies without further processing
          NexCommandInvalid..NexBufferOverflow:
          begin
            messageState := nsReplyWaitEnd;
          end;

        // Notification events, no further processing required
          NexEventAutoSleep, NexEventAutoWake, NexEventReady, NexEventUpgrading, NexEventTransparentDataDone,
          NexEventTransparentDataReady:
          begin
            messageState := nsEventWaitEnd;
          end;

          NexCurrentPageNo, NexStringData, NexNumericData:
          begin
            messageState := nsProcessReply;
            fText := '';
            fNumber := 0;
          end;

          // Events with embedded information, require further processing
          CustomEventPageExit, NexEventTouch, NexEventTouchCoord, NexEventTouchCoordSleep:
          begin
            messageState := nsProcessEvent;
          end;

        otherwise
          //logwriteln('processInputData: unexpected start of message');
          messageState := nsWaitEnd;
        end;
      end;

      // Display events, i.e.asynchronous
      // Read response
      nsProcessEvent:
      begin
        case ord(messageHeader) of
          CustomEventPageExit:
          begin
            fPid := ord(c);
            messageState := nsEventWaitEnd;
          end;

          NexEventTouch:
          begin
            case dataCount of
              0: fPid := ord(c);
              1: fCid := ord(c);
              2: begin
                  fPressed := c = #1;
                  dataCount := 0;
                  messageState := nsEventWaitEnd;
                 end;
            otherwise
              logwrite('Invalid dataCount in NexEventTouch: ');
              logwriteln(dataCount);
            end;
            inc(dataCount);
          end;

          NexEventTouchCoord, NexEventTouchCoordSleep:
          begin
            // Coordinates transmitted in big endian format
            case datacount of
              0: fX := ord(c)*256;
              1: fX := fX + ord(c);
              2: fY := ord(c)*256;
              3: fY := fY + ord(c);
              4: begin
                   fPressed := c = #1;
                   dataCount := 0;
                   messageState := nsEventWaitEnd;
                 end;
            otherwise
              logwrite('Invalid dataCount in NexEventTouch: ');
              logwriteln(dataCount);
            end;
              inc(dataCount);
          end;
        otherwise
          logwriteln('Unexpected message in nsProcessEvent');
        end;
      end;

      // Reply to command, i.e. synchronous
      nsProcessReply:
      begin
        case messageHeader of
          NexCurrentPageNo:
          begin
            fPid := ord(c);
            messageState := nsReplyWaitEnd;
          end;

          NexStringData:
          begin
            if (c < #$FF) then
            begin
              if (length(fText) < 255) then
              begin
                fText := fText + c;
                inc(dataCount);
              end
              else
                logwriteln('Text received exceeds 255 bytes');
            end
            else  // $FF means end of text
            begin
              SetLength(fText, dataCount);
              inc(endMarkerCount);
              messageState := nsReplyWaitEnd;
            end;
          end;

          NexNumericData:
          begin
            // Value transmitted in little endian format
            case dataCount of
              0: fNumber := ord(c);
              1: fNumber := fNumber + ord(c) * 256;
              2: fNumber := fNumber + ord(c) * 256 * 256;
              3: begin
                   fNumber := fNumber + ord(c) * 256 * 256 * 256;
                   messageState := nsReplyWaitEnd;
                 end;
            otherwise
              ;
            end;
            inc(dataCount);
          end;
        otherwise
          logwrite('Unexpected message in nsProcessReply: $');
          logwriteln(HexStr(messageHeader, 2));
        end;
      end;

      nsEventWaitEnd, nsReplyWaitEnd, nsWaitEnd:
      begin
        if (ord(c) = $FF) then
        begin
          inc(endMarkerCount);
          if endMarkerCount = 3 then
          begin
            commandCompleted := true;

            if (messageState = nsEventWaitEnd) then
            begin
              messageState := nsNone;
              if (messageHeader = CustomEventPageExit) and Assigned(pageExitHandler) then
                pageExitHandler(fPid)
              else if (messageHeader = NexEventTouch) and Assigned(touchHandler) then
                touchHandler(fPid, fCid, fPressed)
              else if (messageHeader in [NexEventTouchCoord, NexEventTouchCoordSleep]) and
                 Assigned(touchCoordHandler) then
                touchCoordHandler(fX, fY, fPressed)
              else if (messageHeader in [NexEventAutoSleep..NexEventUpgrading,
                                         NexEventTransparentDataDone..NexEventStartup]) and
                      Assigned(generalEventHandler) then
                generalEventHandler(messageHeader);
            end
            else if messageState = nsWaitEnd then
              logwriteln('Resynced with end of message');

            messageState := nsNone;
          end;
        end
        else if (c = #0) and (messageHeader in [NexCommandInvalid, NexEventStartup]) then
        begin
          if startupZeroes = 1 then
          begin
            messageHeader := NexEventStartup;
            messageState := nsEventWaitEnd;
            startupZeroes := 0;
          end
          else
            inc(startupZeroes);
        end
        // Not an end of message sequence, mark this message as error, \
        // reset FF count and wait for FF FF FF to resync
        else
        begin
          if not (messageState = nsWaitEnd) then
          begin
            logwrite('Unexpected character while waiting for terminating sequence: $');
            logwriteln(HexStr(ord(c), 2));
          end;
          messageState := nsWaitEnd;
          endMarkerCount := 0;
        end;
      end;
    end;
  end;
end;

function TNextionHandler.setText(const ID: TNextionComponent; value: shortstring): boolean;
var
  p, c: string[3];
begin
  Str(ID.pid, p);
  Str(ID.cid, c);
  value := 'p['+p+'].b['+c+'].txt="'+value+'"';
  sendCommand(value);
  Result := true;
end;

function TNextionHandler.getText(const ID: TNextionComponent; out
  text: shortstring): boolean;
var
  buf: string[32];
  timeoutCount: integer;
  p, c: string[3];
begin
  Str(ID.pid, p);
  Str(ID.cid, c);
  buf := 'get p['+p+'].b['+c+'].txt';
  sendCommand(buf);
  commandCompleted := false;
  timeoutCount := 10; // 0.1 sec
  processInputData;
  while not commandCompleted and (timeoutCount > 0) do
  begin
    Sleep(10);
    dec(timeoutCount);
    processInputData;
  end;
  Result := commandCompleted and (messageHeader = NexStringData);
  if timeoutcount = 0 then
    logwriteln('Timeout waiting for getText reply');
  if Result then
    text := fText
  else
    text := '';
end;

function TNextionHandler.setValue(const ID: TNextionComponent; value: integer): boolean;
var
  buf: string[32];
  p, c: string[3];
  v: string[10];
begin
  Str(ID.pid, p);
  Str(ID.cid, c);
  Str(value, v);
  buf := 'p['+p+'].b['+c+'].val='+v;
  sendCommand(buf);
  Result := true;
end;

function TNextionHandler.getValue(const ID: TNextionComponent; out val: integer
  ): boolean;
var
  buf: string[32];
  timeoutCount: integer;
  p, c: string[3];
begin
  Str(ID.pid, p);
  Str(ID.cid, c);
  buf := 'get p['+p+'].b['+c+'].val';
  sendCommand(buf);

  commandCompleted := false;
  timeoutCount := 20;
  processInputData;
  while not commandCompleted and (timeoutCount > 0) do
  begin
    Sleep(10);
    dec(timeoutCount);
    processInputData;
  end;
  Result := commandCompleted and (messageHeader = NexNumericData);
  if timeoutcount = 0 then
    logwriteln('Timeout waiting for getValue reply');

  if Result then
    val := fNumber
  else
    val := 0;
end;

function TNextionHandler.setCurrentPage(pageID: integer): boolean;
var
  cmd: string[16];
  p: string[3];
begin
  Str(pageID, p);
  cmd := 'page ' + p;
  sendCommand(cmd);
  Result := true;
end;

function TNextionHandler.getCurrentPage(out pageID: integer): boolean;
var
  timeoutCount: integer;
begin
  sendCommand('sendme');
  commandCompleted := false;
  timeoutCount := 10;
  processInputData;
  while not commandCompleted and (timeoutcount > 0) do
  begin
    Sleep(10);
    dec(timeoutCount);
    processInputData;
  end;

  if timeoutcount = 0 then
    logwriteln('Timeout waiting for getCurrentPage reply');

  Result := messageHeader = NexCurrentPageNo;
  pageID := fPid;
end;

procedure TNextionHandler.sendCommand(cmd: shortstring; timeout_ms: integer);
var
  timeoutCount: integer;
begin
  // Complete processing of current data
  timeoutCount := 20;
  processInputData;
  while not commandCompleted and (messageState <> nsNone) and (timeoutcount > 0) do
  begin
    Sleep(10);
    dec(timeoutCount);
    processInputData;
  end;

  // If still in transient state, reset state for this message
  // Risk of discarding asynchronous event data,
  // perhaps check if input buffer is empty?
  if (timeoutcount = 0) {and (messageState = nsWaitEnd)} then
  begin
    messageState := nsNone;
    // TODO: Flush input buffer, in case there is some stale data floating around.
  end;

  // Check if write handler is assigned, just in case...
  if Assigned(WriteHandler) then
  begin
    writeHandler(cmd);
    SetLength(cmd, 3);
    cmd[1] := #$FF;
    cmd[2] := #$FF;
    cmd[3] := #$FF;
    writeHandler(cmd);
  end;
end;

end.

