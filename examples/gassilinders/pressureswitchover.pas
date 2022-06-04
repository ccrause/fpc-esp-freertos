unit pressureswitchover;

interface

{$include freertosconfig.inc}

uses
  storage, readadc;

type
  TValveOpen = (vsValveA, vsValveB);

//procedure startPressureMonitorThread;

// Return currently selected open valve (A or B)
function getCurrentOpenValve: char;

// Non-thread methods
procedure initCheckPressures;
procedure checkPressures;

// Public so that it can be called from nextionscreenconfig in manual mode
procedure setValves(valveToOpen: TValveOpen);

implementation

uses
  portmacro, shared, task, nextionscreenconfig, pwm_pca9685, i2c_obj,
  esp_err, handleSMS, logtouart;

type
  TPressureEvent = (peNone, peWarning, peLow);
  TPressureWatch = record
    event: TPressureEvent;
    eventTriggerTime: uint32;
    triggered: boolean;
  end;

const
  cylA = 8;
  cylB = 9;
  ServoClosedPos = 500;
  ServoOpenPos = 1200;
  EventWaitTicks = 6*configTICK_RATE_HZ;

var
  fi2c: TI2cMaster;
  pwm: TPwmPca9685;
  valveCurrentlyOpen: TValveOpen;
  waitForChangeover: boolean;
  timeoutStart: TTickType;
  skipSMSNotificationOnStartup: boolean;
  pressureWatches: array[0..totalADCChannels-1] of TPressureWatch;

procedure resetPressureWatches;
var
  i: uint32;
begin
  for i := 0 to high(pressureWatches) do
  begin
    pressureWatches[i].event := peNone;
    pressureWatches[i].eventTriggerTime := $FFFFFFFF; // MaxUInt, cannot trigger timeout
    pressureWatches[i].triggered := false;
  end;
end;

function getCurrentOpenValve: char;
begin
  if valveCurrentlyOpen = vsValveA then
    Result := 'A'
  else
    Result := 'B';
end;

procedure setOnMicroSecondsWithRetry(channel: uint32; us: int16);
var
  err: Tesp_err;
begin
  err := pwm.setOnMicroseconds(channel, us);
  if err <> ESP_OK then
  begin
    Sleep(10);
    logwrite('Retry setting valve position: ');
    logwriteln(int32(err));
    err := pwm.setOnMicroseconds(channel, us);
    logwrite('Error setting valve position: ');
    logwriteln(int32(err));
  end;
end;

procedure setValves(valveToOpen: TValveOpen);
var
  A, B: boolean;
  s: string[24];
begin
  valveCurrentlyOpen := valveToOpen;
  logwrite('Open valve ');
  if valveToOpen = vsValveA then
    logwriteln('A')
  else
    logwriteln('B');

  A := valveToOpen = vsValveA;
  B := valveToOpen = vsValveB;
  nextionscreenconfig.updateValvePositions(A, B);
  if valveToOpen = vsValveA then
  begin
    setOnMicroSecondsWithRetry(0, ServoOpenPos);
    setOnMicroSecondsWithRetry(1, ServoClosedPos);
  end
  else
  begin
    setOnMicroSecondsWithRetry(0, ServoClosedPos);
    setOnMicroSecondsWithRetry(1, ServoOpenPos);
  end;

  if (snAutoCylinderChangeOver in storage.SMSNotificationSettings.Notifications) and
     not skipSMSNotificationOnStartup then
  begin
    s := 'Switched to ' + CylinderNames[8 + ord(valveToOpen)];
    sendNotification(s);
  end;
end;

procedure initCheckPressures;
var
  p1, p2: uint32;
  err: Tesp_err;
begin
  skipSMSNotificationOnStartup := true;
  fi2c.Initialize(0, 21, 22);  // I2C port, SDA pin, SCL pin
  err := pwm.Initialize(fi2c);
  if err <> ESP_OK then
  begin
    Sleep(100);
    err := pwm.Initialize(fi2c);
    if err <> ESP_OK then
      logwriteln('Error initializing PWM');
  end;
  pwm.setOscillatorFrequency(26050000);
  pwm.setPWMFreq(50);
  //pwm.setOnMicroseconds(0, ServoClosedPos);
  //pwm.setOnMicroseconds(1, ServoClosedPos);

  waitForChangeover := false;
  // Allow ADC to collect some readings
  //Sleep(500);
  p1 := Pressures[cylA];
  p2 := Pressures[cylB];

  // Set valves according to manual position
  if storage.CylinderChangeoverSettings.ManualMode then
  begin
    if storage.CylinderChangeoverSettings.ManualCylinderSelected = 0 then
      setValves(vsValveA)
    else
      setValves(vsValveB);
  end
  else
  begin
    // Pick lower pressure cylinder to empty first
    if storage.CylinderChangeoverSettings.PreferredCylinderMode then
    begin
      if (storage.CylinderChangeoverSettings.PreferredCylinderIndex = 0) then
      begin
        if (p1 > storage.CylinderChangeoverSettings.MinCylinderPressure) or (p1 > p2) then
          setValves(vsValveA)
        else
          setValves(vsValveB);
      end
      else
      begin
        if (p2 > storage.CylinderChangeoverSettings.MinCylinderPressure) or (p2 > p1) then
          setValves(vsValveB)
        else
          setValves(vsValveA);
      end;
    end
    else if ((p1 <= p2) and (p1 >= storage.CylinderChangeoverSettings.MinCylinderPressure)) or
            ((p1 >= p2) and (p2 < storage.CylinderChangeoverSettings.MinCylinderPressure)) then
      setValves(vsValveA)
    else
      setValves(vsValveB);
  end;

  skipSMSNotificationOnStartup := false;
  resetPressureWatches;
end;

procedure checkPressuresNormal;
var
  pCurrent, pNext: uint32;
  nextValve: TValveOpen;
begin
  if (valveCurrentlyOpen = vsValveA) then
  begin
    nextValve := vsValveB;
    pCurrent := Pressures[cylA];
    pNext := Pressures[cylB];
  end
  else
  begin
    nextValve := vsValveA;
    pCurrent := Pressures[cylB];
    pNext := Pressures[cylA];
  end;

  // Default action: Pick a cylinder, then empty it completely
  // before switching to the other cylinder
  if (pCurrent < storage.CylinderChangeoverSettings.MinCylinderPressure) and
     (pCurrent + storage.CylinderChangeoverSettings.Hysteresis < pNext) then
  begin
    if not waitForChangeover then
    begin
      waitForChangeover := true;
      timeoutStart := xTaskGetTickCount;
    end
    else if (xTaskGetTickCount - timeoutStart) > storage.CylinderChangeoverSettings.CylinderChangeDelay then
    begin
      setValves(nextValve);
      waitForChangeover := false;
    end;
  end
  // Cancel change-over if pressure is above minimum again
  else if (pCurrent > storage.CylinderChangeoverSettings.MinCylinderPressure) then
  begin
    waitForChangeover := false;
  end;
end;

procedure checkPressuresPrefCyl;
var
  pPrefCyl, pBackup: uint32;
  prefValve, backupValve: TValveOpen;
begin
  if (storage.CylinderChangeoverSettings.PreferredCylinderIndex = 0) then
  begin
    prefValve := vsValveA;
    backupValve := vsValveB;
    pPrefCyl := Pressures[cylA];
    pBackup := Pressures[cylB];
  end
  else
  begin
    prefValve := vsValveB;
    backupValve := vsValveA;
    pPrefCyl := Pressures[cylB];
    pBackup := Pressures[cylA];
  end;

  if prefValve = valveCurrentlyOpen then
  begin
    if (pPrefCyl + storage.CylinderChangeoverSettings.Hysteresis <= storage.CylinderChangeoverSettings.MinCylinderPressure) and
       (pBackup > pPrefCyl) then
    begin
      if not waitForChangeover then
      begin
        logwriteln('Start switchover time');
        waitForChangeover := true;
        timeoutStart := xTaskGetTickCount;
      end
      else if (xTaskGetTickCount - timeoutStart) > storage.CylinderChangeoverSettings.CylinderChangeDelay then
      begin
        logwriteln('Switching over');
        setValves(backupValve);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if (pPrefCyl > storage.CylinderChangeoverSettings.MinCylinderPressure) and
            waitForChangeover then
    begin
      logwriteln('Cancel switchover');
      waitForChangeover := false;
    end;
  end
  else // On not preferred cylinder, decide when to switch
  begin
    if (pPrefCyl >= storage.CylinderChangeoverSettings.Hysteresis + storage.CylinderChangeoverSettings.MinCylinderPressure) or
       (pPrefCyl >= pBackup + storage.CylinderChangeoverSettings.Hysteresis) then
    begin
      if not waitForChangeover then
      begin
        logwriteln('Start switchover');
        waitForChangeover := true;
        timeoutStart := xTaskGetTickCount;
      end
      else if (xTaskGetTickCount - timeoutStart) > storage.CylinderChangeoverSettings.CylinderChangeDelay then
      begin
        logwriteln('Switching over');
        setValves(prefValve);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if waitForChangeover and
            ((pPrefCyl < storage.CylinderChangeoverSettings.MinCylinderPressure) or
            (pPrefCyl < pBackup)) then
    begin
      logwriteln('Cancel switchover');
      waitForChangeover := false;
    end;
  end;
end;

var
  staticStr: string[250];

procedure checkPressures;
var
  i: uint32;
  s: string[24];
begin
  // Check cylinder switchover
  if storage.CylinderChangeoverSettings.PreferredCylinderMode then
    checkPressuresPrefCyl
  else
    checkPressuresNormal;

  // Check for alerts
  // TODO: Check if any warnings are active before running loop
  //FillChar(staticStr[1], length(staticStr), #0);
  SetLength(staticStr, 0);
  for i := 0 to high(pressureWatches) do
  begin
    if (Pressures[i] <= storage.PressureSettings.LowPressures[i shr 1]) then
    begin
      // Fire alert when event has been set, not triggered, and after dead time
      if (pressureWatches[i].event = peLow) and not pressureWatches[i].triggered and
         (xTaskGetTickCount > pressureWatches[i].eventTriggerTime) then
      begin
        // Trigger alert, but only if SMS flag is enabled.
        // Else keep untriggered until SMS flag is set
        if (snLowPressure in storage.SMSNotificationSettings.Notifications) then
        begin
          if length(staticStr) < 230 then
          begin
            s := CylinderNames[i] + ': L'#10;
            insert(s, staticStr, length(staticStr)+1);
            pressureWatches[i].triggered := true;
          end;
        end
      end
      else if (pressureWatches[i].event <> peLow) then
      begin
        pressureWatches[i].event := peLow;
        pressureWatches[i].eventTriggerTime := xTaskGetTickCount + EventWaitTicks;
        pressureWatches[i].triggered := false;
      end;
    end
    else if Pressures[i] <= storage.PressureSettings.Warnings[i shr 1] then
    begin
      if (pressureWatches[i].event = peWarning) and not pressureWatches[i].triggered and
         (xTaskGetTickCount > pressureWatches[i].eventTriggerTime) then
      begin
        if (snWarnPressure in storage.SMSNotificationSettings.Notifications) then
        begin
          // Warning alert!
          if length(staticStr) < 230 then
          begin
            s := CylinderNames[i] + ': W'#10;
            insert(s, staticStr, length(staticStr)+1);
            pressureWatches[i].triggered := true;
          end;
        end;
      end
      else if (pressureWatches[i].event <> peWarning) then
      begin
        pressureWatches[i].event := peWarning;
        pressureWatches[i].eventTriggerTime := xTaskGetTickCount + EventWaitTicks;
        pressureWatches[i].triggered := false;
      end;
    end
    else // Pressure above warning, reset for this cylinder
    begin
      pressureWatches[i].event := peNone;
      pressureWatches[i].eventTriggerTime := $FFFFFFFF;
      pressureWatches[i].triggered := false;
    end;
  end;
  if (length(staticStr) > 1) then
  begin
    logwrite('Pressure notification length = ');
    logwriteln(length(staticStr));
    logwriteln(staticStr);
    sendNotification(staticStr);
  end;
end;

function monitorPressureThread(parameter : pointer) : ptrint; noreturn;
begin
  initCheckPressures;
  repeat
    checkPressures;
    Sleep(250);
  until false;
end;

procedure startPressureMonitorThread;
var
  threadID: TThreadID;
begin
  BeginThread(@monitorPressureThread,      // thread to launch
             nil,              // pointer parameter to be passed to thread function
             threadID,         // new thread ID, not used further
             4096);            // stacksize
end;

end.

