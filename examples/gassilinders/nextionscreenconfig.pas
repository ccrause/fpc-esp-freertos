unit nextionscreenconfig;

interface

procedure startDisplayThread;

procedure UpdateValvePositions(valveAOpen, valveBOpen: boolean);

procedure doUploadSettingsToDisplay;

implementation

uses
  nextion, readadc, uart, uart_types,
  shared, gpio, gpio_types, storage, portmacro, logtouart;

{$include freertosconfig.inc} // To access configTICK_RATE_HZ

const
  UART_FIFO_BUFFER_SIZE = 2048;
  PrimaryUartPort = 0;
  PrimaryTX_PIN = 1;
  PrimaryRX_PIN = 3;

  // Uart connected to RS485 driver.  Control driver direction with RSE pin
  SecondaryUartPort = 1;
  SecondaryTX_PIN = 19;
  SecondaryRX_PIN = 18;
  SecondaryRSE_PIN = GPIO_NUM_5;

  // Component IDs page 1
  WarningPressureIdStart   = 4;
  WarningPressureIdEnd     = 8;
  LowPressureIdStart       = 9;
  LowPressureIdEnd         = 13;
  //Component IDs on page 2
  PhoneNumberIdStart       = 4;
  PhoneNumberIdEnd         = 8;
  WarningPressureId = 9;
  LowPressureId     = 10;
  AutoCylinderChangeoverId = 11;
  RepeatNotificationId     = 12;
  RepeatIntervalId         = 13;
  // Component IDs on page 3
  MinCylinderPressureId    = 4;
  HysteresisId             = 5;
  CylinderChangeDelayId    = 6;
  PreferredCylinderModeId  = 7;
  PreferredCylinderId      = 8;
  ManualModeId             = 9;
  CylinderSelectedId       = 10;

var
  nexPrimary, nexSecondary: TNextionHandler;

  pressureTextArray: array[0..9] of TNextionComponent = (
    (pid: 0; cid: 1),
    (pid: 0; cid: 12),
    (pid: 0; cid: 13),
    (pid: 0; cid: 14),
    (pid: 0; cid: 15),
    (pid: 0; cid: 16),
    (pid: 0; cid: 17),
    (pid: 0; cid: 18),
    (pid: 0; cid: 19),
    (pid: 0; cid: 20));

  pressureProgressArray: array[0..9] of TNextionComponent = (
    (pid: 0; cid: 2),
    (pid: 0; cid: 3),
    (pid: 0; cid: 4),
    (pid: 0; cid: 5),
    (pid: 0; cid: 6),
    (pid: 0; cid: 7),
    (pid: 0; cid: 8),
    (pid: 0; cid: 9),
    (pid: 0; cid: 10),
    (pid: 0; cid: 11));

  flagUpdateValvePositions: boolean;
  valveAIsOpen: boolean;
  valveBIsOpen: boolean;
  nexValveA: TNextionComponent = (pid: 0; cid: 24);
  nexValveB: TNextionComponent = (pid: 0; cid: 25);

  fUploadSettingsToDisplay: boolean;

// Ensure number of ADC channels and Nextion display elements are the same
// These constants are used for a compile time check only
const
  pressureTextArrayLength = length(pressureTextArray);
  pressureProgressArrayLength = length(pressureProgressArray);
{$if (pressureTextArrayLength <> totalADCChannels)}
  {$error pressureTextArrayLength <> totalADCChannels}
{$endif}
{$if (pressureTextArrayLength <> pressureProgressArrayLength)}
  {$error pressureTextArrayLength <> pressureProgressArrayLength}
{$endif}

procedure updateValvePositionsOnDisplays;
var
  v: uint32;
begin
  if valveAIsOpen then
    v := 0
  else
    v := 1;
  nexPrimary.setValue(nexValveA, v);
  nexSecondary.setValue(nexValveA, v);

  if valveBIsOpen then
    v := 0
  else
    v := 1;
  nexPrimary.setValue(nexValveB, v);
  nexSecondary.setValue(nexValveB, v);
end;

procedure doUploadSettingsToDisplay;
begin
  fUploadSettingsToDisplay := true;
end;

procedure UploadSettingsToDisplay;
var
  nex: TNextionComponent;
  i: integer;
begin
  nex.pid := 1;
  for i := 0 to high(storage.PressureSettings.Warnings) do
  begin
    nex.cid := 4 + i;
    NexPrimary.setValue(nex, storage.PressureSettings.Warnings[i]);
    nex.cid := 9 + i;
    NexPrimary.setValue(nex, storage.PressureSettings.LowPressures[i]);
  end;

  nex.pid := 2;
  for i := 0 to high(storage.PhoneNumbers) do
  begin
    nex.cid := 4 + i;
    NexPrimary.setValue(nex, storage.PhoneNumbers[i]);
  end;
  nex.cid := 9;
  if snWarnPressure in storage.SMSNotificationSettings.Notifications then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 10;
  if snLowPressure in storage.SMSNotificationSettings.Notifications then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 11;
  if snAutoCylinderChangeOver in storage.SMSNotificationSettings.Notifications then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 12;
  if snRepeatNotifications in storage.SMSNotificationSettings.Notifications then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 13;
  NexPrimary.setValue(nex, storage.SMSNotificationSettings.RepeatInterval);

  nex.pid := 3;
  nex.cid := 4;
  NexPrimary.setValue(nex, storage.CylinderChangeoverSettings.MinCylinderPressure);
  nex.cid := 5;
  NexPrimary.setValue(nex, storage.CylinderChangeoverSettings.Hysteresis);
  nex.cid := 6;
  NexPrimary.setValue(nex, storage.CylinderChangeoverSettings.CylinderChangeDelay div configTICK_RATE_HZ);
  nex.cid := 7;
  if storage.CylinderChangeoverSettings.PreferredCylinderMode then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 8;
  NexPrimary.setValue(nex, storage.CylinderChangeoverSettings.PreferredCylinderIndex);
  nex.cid := 9;
  if storage.CylinderChangeoverSettings.ManualMode then
    i := 1
  else
    i := 0;
  NexPrimary.setValue(nex, i);
  nex.cid := 10;
  NexPrimary.setValue(nex, storage.CylinderChangeoverSettings.ManualCylinderSelected);
end;

procedure updateDisplays;
var
  val: string[8];
  i, pres, pct: integer;
begin
  for i := 0 to high(Pressures) do
  begin
    pres := Pressures[i];
    Str(pres, val);
    nexPrimary.setText(pressureTextArray[i], val);
    nexPrimary.processInputData;
    nexSecondary.setText(pressureTextArray[i], val);
    nexSecondary.processInputData;

    pct := (pres*10 + 11) div 22;
    nexPrimary.setValue(pressureProgressArray[i], pct);
    nexPrimary.processInputData;
    nexSecondary.setValue(pressureProgressArray[i], pct);
    nexSecondary.processInputData;
  end;

  if flagUpdateValvePositions then
  begin
    flagUpdateValvePositions := false;
    if valveAIsOpen then
      i := 0
    else
      i := 1;
    nexPrimary.setValue(nexValveA, i);
    nexSecondary.setValue(nexValveA, i);

    if valveBIsOpen then
      i := 0
    else
      i := 1;
    nexPrimary.setValue(nexValveB, i);
    nexSecondary.setValue(nexValveB, i);
  end;

  Sleep(10);
  if fUploadSettingsToDisplay then
  begin
    fUploadSettingsToDisplay := false;
    UploadSettingsToDisplay;
  end;
end;

procedure initPrimaryNextionUart;
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

  uart_driver_install(PrimaryUartPort, UART_FIFO_BUFFER_SIZE, UART_FIFO_BUFFER_SIZE, 0, nil, 0);
  uart_param_config(PrimaryUartPort, @uart_cfg);
  uart_set_pin(PrimaryUartPort, PrimaryTX_PIN, PrimaryRX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
  Sleep(100);
  uart_flush_input(PrimaryUartPort);
end;

procedure initSecondaryNextionUart;
var
  uart_cfg: Tuart_config;
  cfg: Tgpio_config;  // To control RSE pin of MAX485 tranceiver
begin
  uart_cfg.baud_rate  := 9600;
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
  uart_cfg.rx_flow_ctrl_thresh := 0; // unclear why this is required
  uart_cfg.source_clk := UART_SCLK_APB;

  uart_driver_install(SecondaryUartPort, UART_FIFO_BUFFER_SIZE, UART_FIFO_BUFFER_SIZE, 0, nil, 0);
  uart_param_config(SecondaryUartPort, @uart_cfg);
  uart_set_pin(SecondaryUartPort, SecondaryTX_PIN, SecondaryRX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);

  // Connected to RS485 driver. Switch RSE to high to enable transmitter driver
  cfg.pin_bit_mask := 1 shl ord(SecondaryRSE_PIN);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);
  gpio_set_level(SecondaryRSE_PIN, 1);

  Sleep(10);
  uart_flush_input(SecondaryUartPort);
end;

procedure sendString(uartnum: integer; data: shortstring);
var
  len: integer;
begin
  len := uart_write_bytes(uartnum, @data[1], length(data));
  if len < 0 then
    logwriteln('Error in sendString')
  else if len < length(data) then
    logwriteln('Less data sent');
end;

procedure sendStringPrimary(data: shortstring);
begin
  sendString(PrimaryUartPort, data);
end;

procedure sendStringSecondary(data: shortstring);
begin
  sendString(SecondaryUartPort, data);
end;

function readString(uartnum: integer): shortstring;
var
  len: integer;
begin
  uart_get_buffered_data_len(uartnum, @len);
  if len > 255 then
    len := 255;

  if len > 0 then
  begin
    SetLength(Result, len);
    FillByte(Result[1], 0, len);
    len := uart_read_bytes(uartnum, @Result[1], len, 1);
    logwrite('>> ');
    logwriteln(Result);
  end
  else
  begin
    Result := '';
    // Give another task some space
    Sleep(10);
  end;
end;

function readStringPrimary: shortstring;
begin
  Result := readString(PrimaryUartPort);
end;

function readStringSecondary: shortstring;
begin
  Result := readString(SecondaryUartPort);
end;

procedure readPage1FromDisplay;
var
  i, v: integer;
  tmpNexObj: TNextionComponent;
  updated: boolean;
begin
  tmpNexObj.pid := 1;
  updated := false;
  for i := WarningPressureIdStart to WarningPressureIdEnd do
  begin
    tmpNexObj.cid:= i;
    // Only update internal value if read succeeded
    if nexPrimary.getValue(tmpNexObj, v) then
    begin
      if uint32(v) <> storage.PressureSettings.Warnings[i - WarningPressureIdStart] then
      begin
        updated := true;
        storage.PressureSettings.Warnings[i - WarningPressureIdStart] := v;
      end;
    end;
  end;

  for i := LowPressureIdStart to LowPressureIdEnd do
  begin
    tmpNexObj.cid:= i;
    // Only update internal value if read succeeded
    if nexPrimary.getValue(tmpNexObj, v) then
    begin
      if uint32(v) <> storage.PressureSettings.Warnings[i - LowPressureIdEnd] then
      begin
        updated := true;
        storage.PressureSettings.Warnings[i - LowPressureIdEnd] := v;
      end;
    end;
  end;

  if updated then
  begin
    storage.savePressureSettings;
  end;
end;

procedure readPage2FromDisplay;
var
  i, v: integer;
  tmpNexObj: TNextionComponent;
  updated: boolean;
  tmpSMSNotificationsSet: TSMSNotificationsSet;
begin
  tmpNexObj.pid := 2;
  updated := false;
  for i := PhoneNumberIdStart to PhoneNumberIdEnd do
  begin
    tmpNexObj.cid:= i;
    // Only update internal value if read succeeded
    if nexPrimary.getValue(tmpNexObj, v) then
    begin
      if uint32(v) <> storage.PhoneNumbers[i - PhoneNumberIdStart] then
      begin
        updated := true;
        storage.PhoneNumbers[i - PhoneNumberIdStart] := v;
      end;
    end;
  end;

  tmpSMSNotificationsSet := [];

  tmpNexObj.cid := WarningPressureId;
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
    include(tmpSMSNotificationsSet, snWarnPressure);

  tmpNexObj.cid := LowPressureId;
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
    include(tmpSMSNotificationsSet, snLowPressure);

  tmpNexObj.cid := AutoCylinderChangeoverId;
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
    include(tmpSMSNotificationsSet, snAutoCylinderChangeOver);

  tmpNexObj.cid := RepeatNotificationId;
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
    include(tmpSMSNotificationsSet, snRepeatNotifications);

  updated := not(storage.SMSNotificationSettings.Notifications = tmpSMSNotificationsSet);
  if updated then
    storage.SMSNotificationSettings.Notifications := tmpSMSNotificationsSet;

  tmpNexObj.cid := RepeatIntervalId;
  // TODO: Perhaps force value > 0 on Nextion side?
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
  begin
    updated := updated or (uint32(v) <> storage.SMSNotificationSettings.RepeatInterval);
    storage.SMSNotificationSettings.RepeatInterval := v;
  end;

  if updated then
    storage.saveNotificationSettings;
end;

procedure readPage3FromDisplay;
var
  v: integer;
  tmpNexObj: TNextionComponent;
  updated, b: boolean;
begin
  tmpNexObj.pid := 3;
  updated := false;

  tmpNexObj.cid := MinCylinderPressureId;
  // TODO: Perhaps force value > 0 on Nextion side?
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
  begin
    updated := uint32(v) <> storage.CylinderChangeoverSettings.MinCylinderPressure;
    storage.CylinderChangeoverSettings.MinCylinderPressure := v;
  end;

  tmpNexObj.cid := HysteresisId;
  // TODO: Perhaps force value > 0 on Nextion side?
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
  begin
    updated := updated or (uint32(v) <> storage.CylinderChangeoverSettings.Hysteresis);
    storage.CylinderChangeoverSettings.Hysteresis := v;
  end;

  tmpNexObj.cid := CylinderChangeDelayId;
  // TODO: Perhaps force value > 0 on Nextion side?
  if nexPrimary.getValue(tmpNexObj, v) and (v > 0) then
  begin
    v := v * portTICK_PERIOD_MS;
    updated := updated or (uint32(v) <> storage.CylinderChangeoverSettings.CylinderChangeDelay);
    storage.CylinderChangeoverSettings.CylinderChangeDelay := v;
  end;

  tmpNexObj.cid := PreferredCylinderModeId;
  // Switch, so mode is limited to 0 or 1
  if nexPrimary.getValue(tmpNexObj, v) then
  begin
    b := v <> 0;
    updated := updated or (b <> storage.CylinderChangeoverSettings.PreferredCylinderMode);
    storage.CylinderChangeoverSettings.PreferredCylinderMode := b;
  end;

  tmpNexObj.cid := PreferredCylinderId;
  // Switch, so ID is limited to 0 or 1
  if nexPrimary.getValue(tmpNexObj, v) then
  begin
    updated := updated or (uint32(v) <> storage.CylinderChangeoverSettings.PreferredCylinderIndex);
    storage.CylinderChangeoverSettings.PreferredCylinderIndex := v;
  end;

  tmpNexObj.cid := ManualModeId;
  // Switch, so mode is limited to 0 or 1
  if nexPrimary.getValue(tmpNexObj, v) then
  begin
    b := v <> 0;
    updated := updated or (b <> storage.CylinderChangeoverSettings.ManualMode);
    storage.CylinderChangeoverSettings.ManualMode := b;
  end;

  tmpNexObj.cid := CylinderSelectedId;
  // Switch, so ID is limited to 0 or 1
  if nexPrimary.getValue(tmpNexObj, v) then
  begin
    updated := updated or (uint32(v) <> storage.CylinderChangeoverSettings.ManualCylinderSelected);
    storage.CylinderChangeoverSettings.ManualCylinderSelected := v;
  end;

  if updated then
    storage.saveCylinderChangeoverSettings;
end;

// Only attach to primary display for updating edited values
procedure pageExitHandler(pid: integer);
begin
  logwriteln('#');
  case pid of
    // Pressure set points (warning, Low)
    1: savePressureSettings;
    // Phone numbers and notification settings
    2: saveNotificationSettings;
    // Cylinder changeover settings
    3: saveCylinderChangeoverSettings;
  end;
end;

procedure initDisplays;
begin
  flagUpdateValvePositions := false;
{$ifndef debugprint}
  initSecondaryNextionUart;
  nexSecondary.writeHandler := @sendStringSecondary;
{$endif}
  nexSecondary.init;
  // Try to discard possible junk in Nextion input buffer
  nexSecondary.sendCommand('');
  nexSecondary.sendCommand('rest');

  initPrimaryNextionUart;
  nexPrimary.readHandler := @readStringPrimary;
  nexPrimary.writeHandler := @sendStringPrimary;
  nexPrimary.pageExitHandler := @pageExitHandler;
  nexPrimary.init;
  // Try to discard possible junk in Nextion input buffer
  nexPrimary.sendCommand('');
  nexPrimary.sendCommand('rest');

  // Wait for displays to restart before issuing commands
  Sleep(100);
  // Disable result codes on Nextion
  nexSecondary.sendCommand('bkcmd=0');
  // Disable touch events on Nextion
  nexSecondary.sendCommand('tsw 255,0');
  // Ensure displaying page 0
  nexSecondary.setCurrentPage(0);

  // Wait for displays to restart before issuing commands
  Sleep(100);
  // Disable result codes on Nextion
  nexPrimary.sendCommand('bkcmd=0');
end;

procedure handleDisplayMessages;
begin
  nexPrimary.processInputData;
  nexSecondary.processInputData;
end;

function displayThread(parameter : pointer): ptrint; noreturn;
begin
  initDisplays;
  repeat
    handleDisplayMessages;
    updateDisplays;
    Sleep(250);
  until false;
end;

procedure startDisplayThread;
var
  threadID: TThreadID;
begin
  BeginThread(@displayThread,  // thread to launch
             nil,              // pointer parameter to be passed to thread function
             threadID,         // new thread ID, not used further
             4096);            // stacksize
end;

procedure updateValvePositions(valveAOpen, valveBOpen: boolean);
begin
  flagUpdateValvePositions := true;
  valveAIsOpen := valveAOpen;
  valveBIsOpen := valveBOpen;
end;

end.

