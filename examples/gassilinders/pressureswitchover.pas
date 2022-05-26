unit pressureswitchover;

interface

uses
  storage, readadc;

//procedure startPressureMonitorThread;

// Return currently selected open valve (A or B)
function getCurrentOpenValve: char;

// Non-thread methods
procedure initCheckPressures;
procedure checkPressures;

implementation

uses
  portmacro, shared, task, nextionscreenconfig, pwm_pca9685, i2c_obj,
  esp_err, handleSMS, logtouart;

type
  TValveOpen = (vsValveA, vsValveB);

const
  cylA = 8;
  cylB = 9;

  ServoClosedPos = 500;
  ServoOpenPos = 1200;

var
  fi2c: TI2cMaster;
  pwm: TPwmPca9685;
  valveCurrentlyOpen: TValveOpen;
  waitForChangeover: boolean;
  timeoutStart: TTickType;
  skipSMSNotificationOnStartup: boolean;

function getCurrentOpenValve: char;
begin
  if valveCurrentlyOpen = vsValveA then
    Result := 'A'
  else
    Result := 'B';
end;

procedure setValves(valveToOpen: TValveOpen);
var
  A, B: boolean;
begin
  logwrite('Open valve ');
  if valveToOpen = vsValveA then
    logwrite('A')
  else
    logwrite('B');

  A := valveToOpen = vsValveA;
  B := valveToOpen = vsValveB;
  nextionscreenconfig.updateValvePositions(A, B);
  if valveToOpen = vsValveA then
  begin
    pwm.setOnMicroseconds(0, ServoOpenPos);
    pwm.setOnMicroseconds(1, ServoClosedPos);
  end
  else
  begin
    pwm.setOnMicroseconds(0, ServoClosedPos);
    pwm.setOnMicroseconds(1, ServoOpenPos);
  end;
  if (snAutoCylinderChangeOver in storage.SMSNotificationSettings.Notifications) and
     not skipSMSNotificationOnStartup then
    doNotifySMS;
end;

procedure initCheckPressures;
var
  p1, p2: uint32;
begin
  skipSMSNotificationOnStartup := true;
  fi2c.Initialize(0, 21, 22);  // I2C port, SDA pin, SCL pin
  pwm.Initialize(fi2c);
  pwm.setOscillatorFrequency(26050000);
  pwm.setPWMFreq(50);
  pwm.setOnMicroseconds(0, ServoOpenPos);
  pwm.setOnMicroseconds(1, ServoClosedPos);

  waitForChangeover := false;
  // Allow ADC to collect some readings
  //Sleep(500);
  p1 := Pressures[cylA];
  p2 := Pressures[cylB];
  // Pick lower pressure cylinder to empty first
  if (p1 < p2) and (p1 >= storage.CylinderChangeoverSettings.MinCylinderPressure) then
    valveCurrentlyOpen := vsValveA
  else
    valveCurrentlyOpen := vsValveB;
  setValves(valveCurrentlyOpen);
  skipSMSNotificationOnStartup := false;
end;

procedure checkPressuresNormal;
var
  p1, p2: uint32;
begin
  p1 := Pressures[cylA];
  p2 := Pressures[cylB];

  // Default action: Pick a cylinder, then empty it completely
  // before switching to the other cylinder
  if (valveCurrentlyOpen = vsValveA) then
  begin
    if (p1 < storage.CylinderChangeoverSettings.MinCylinderPressure) and
       (p1 + storage.CylinderChangeoverSettings.Hysteresis < p2) then
    begin
      if not waitForChangeover then
      begin
        waitForChangeover := true;
        timeoutStart := xTaskGetTickCount;
      end
      else if (xTaskGetTickCount - timeoutStart) > storage.CylinderChangeoverSettings.CylinderChangeDelay then
      begin
        valveCurrentlyOpen := vsValveB;
        setValves(valveCurrentlyOpen);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if (p1 > storage.CylinderChangeoverSettings.MinCylinderPressure) then
    begin
      waitForChangeover := false;
    end;
  end
  else if (valveCurrentlyOpen = vsValveB) then
  begin
    if (p2 < storage.CylinderChangeoverSettings.MinCylinderPressure) and
       (p2 + storage.CylinderChangeoverSettings.Hysteresis < p1) then
    begin
      if not waitForChangeover then
      begin
        waitForChangeover := true;
        timeoutStart := xTaskGetTickCount;
      end
      else if (xTaskGetTickCount - timeoutStart) > storage.CylinderChangeoverSettings.CylinderChangeDelay then
      begin
        valveCurrentlyOpen := vsValveA;
        setValves(valveCurrentlyOpen);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if (p2 > storage.CylinderChangeoverSettings.MinCylinderPressure) then
    begin
      waitForChangeover := false;
    end;
  end;
end;

procedure checkPressuresPrefCyl;
var
  p1, p2: uint32;
begin
  p1 := Pressures[cylA];
  p2 := Pressures[cylB];

  if (storage.CylinderChangeoverSettings.PreferredCylinderIndex = 0) then
  begin
    if (p1 + storage.CylinderChangeoverSettings.Hysteresis < storage.CylinderChangeoverSettings.MinCylinderPressure) then
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
        valveCurrentlyOpen := vsValveB;
        setValves(valveCurrentlyOpen);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if (p1 > storage.CylinderChangeoverSettings.MinCylinderPressure) and
            (waitForChangeover or (valveCurrentlyOpen = vsValveB)) then
    begin
      logwriteln('Cancel switchover');
      valveCurrentlyOpen := vsValveA;
      setValves(valveCurrentlyOpen);
      waitForChangeover := false;
    end;
  end
  else if (storage.CylinderChangeoverSettings.PreferredCylinderIndex = 1) then
  begin
    if (p2 + storage.CylinderChangeoverSettings.Hysteresis < storage.CylinderChangeoverSettings.MinCylinderPressure) then
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
        valveCurrentlyOpen := vsValveA;
        setValves(valveCurrentlyOpen);
        waitForChangeover := false;
      end;
    end
    // Cancel change-over if pressure is above minimum again
    else if (p2 > storage.CylinderChangeoverSettings.MinCylinderPressure) and
            (waitForChangeover or (valveCurrentlyOpen = vsValveA)) then
    begin
      logwriteln('Cancel switchover');
      valveCurrentlyOpen := vsValveB;
      setValves(valveCurrentlyOpen);
      waitForChangeover := false;
    end;
  end;
end;

procedure checkPressures;
begin
  if storage.CylinderChangeoverSettings.PreferredCylinderMode then
    checkPressuresPrefCyl
  else
    checkPressuresNormal;
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

