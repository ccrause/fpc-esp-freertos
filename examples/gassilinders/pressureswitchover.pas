unit pressureswitchover;

interface

uses
  storage, readadc;

procedure startPressureMonitorThread;

// Return currently selected open valve (A or B)
function getCurrentOpenValve: char;

// Non-thread methods
procedure initCheckPressures;
procedure checkPressures;

implementation

uses
  portmacro, shared, task, nextionscreenconfig, pwm_pca9685, i2c_obj,
  esp_err, handleSMS;

type
  TValveOpen = (vsValveA, vsValveB);

const
  cylA = 8;
  cylB = 9;

  ServoClosedPos = 500;
  ServoOpenPos = 1500;

var
  fi2c: TI2cMaster;
  pwm: TPwmPca9685;
  valveCurrentlyOpen: TValveOpen;
  waitForChangeover: boolean;
  timeoutStart: TTickType;

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
  doNotifySMS;
end;

procedure initCheckPressures;
var
  p1, p2: uint32;
begin
  fi2c.Initialize(0, 21, 22);  // I2C port, SDA pin, SCL pin
  pwm.Initialize(fi2c);
  pwm.setOscillatorFrequency(26050000);
  pwm.setPWMFreq(50);
  pwm.setOnMicroseconds(0, ServoClosedPos);
  pwm.setOnMicroseconds(1, ServoClosedPos);

  waitForChangeover := false;
  // Allow ADC to collect some readings
  //Sleep(500);
  p1 := Pressures[cylA];
  p2 := Pressures[cylB];
  // Pick lower pressure cylinder to empty first
  if p1 < p2 then
    valveCurrentlyOpen := vsValveA
  else
    valveCurrentlyOpen := vsValveB;
  setValves(valveCurrentlyOpen);
end;

procedure checkPressures;
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

