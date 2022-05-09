unit pressureswitchover;

interface

uses
  storage, readadc;

procedure startPressureMonitorThread;

// Non-thread methods
procedure initCheckPressures;
procedure checkPressures;

implementation

uses
  portmacro, shared, task, nextionscreenconfig, pwm_pca9685, i2c_obj,
  esp_err;

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
end;

var
  p1, p2: uint32;
  valveCurrentlyOpen: TValveOpen;
  waitForChangeover: boolean;
  timeoutStart: TTickType;

procedure dumpRegisters;
const
  regNames: array[0..1] of string[7] = (
    'MODE1  ',
    'MODE2  ');
var
  i, b: byte;
  S: string[11];
begin
  for i := 0 to high(regNames) do
  begin
    EspErrorCheck(fi2c.ReadByteFromReg(byte($40), i, b));
    writeln(regNames[i], ' : ', HexStr(b, 2));
  end;
  writeln;

  // Only read LED 0 registers
  for i := 6 to 9 do
  begin
    b := (i-6) div 4;
    s := 'LED' + HexStr(b, 2);
    b := (i-6) mod 4;
    if b < 2 then
      s := s + '_ON__'
    else
      s := s + '_OFF_';
    if odd(b) then
      s := s + 'H'
    else
      s := s + 'L';
    EspErrorCheck(fi2c.ReadByteFromReg(byte($40), i, b));
    writeln(i, ' : ', HexStr(b, 2));
  end;

  i := $FE; // Prescaler register
  EspErrorCheck(fi2c.ReadByteFromReg(byte($40), i, b));
  writeln('PRE_SCALE : ', HexStr(b, 2));
end;

procedure initCheckPressures;
begin
  fi2c.Initialize(0, 21, 22);  // I2C port, SDA pin, SCL pin
  pwm.Initialize(fi2c);
  //dumpRegisters;
  pwm.setOscillatorFrequency(26050000);
  pwm.setPWMFreq(50);
  pwm.setOnMicroseconds(0, ServoClosedPos);
  pwm.setOnMicroseconds(1, ServoClosedPos);

  waitForChangeover := false;
  // Allow ADC to collect some readings
  //Sleep(500);
  p1 := inputs[cylA];
  p2 := inputs[cylB];
  if p1 > p2 then
    valveCurrentlyOpen := vsValveA
  else
    valveCurrentlyOpen := vsValveB;
  setValves(valveCurrentlyOpen);
  //dumpRegisters;
end;

procedure checkPressures;
begin
  p1 := inputs[cylA];

  if p1 < 200 then
    p1 := 200;
  p1 := (p1 - 200)*10; // P input: 0 - 220 bar, tmp : 0 - 23000
  p1 := (p1 * 22 + 1150) div 2300;

  p2 := inputs[cylB];
  if p2 < 200 then
    p2 := 200;
  p2 := (p2 - 200)*10; // P input: 0 - 220 bar, tmp : 0 - 23000
  p2 := (p2 * 22 + 1150) div 2300;

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
    else if (p1 > storage.CylinderChangeoverSettings.MinCylinderPressure) and
       (p1 > p2) then
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
    else if (p2 > storage.CylinderChangeoverSettings.MinCylinderPressure) and
       (p2 > p1) then
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
             4024);            // stacksize
end;


end.

