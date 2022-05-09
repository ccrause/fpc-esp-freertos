unit pwm_pca9685;

interface

uses
  i2c_obj;

type
  TPinDrive = (pdTotemPole, pdOpenDrain);

  { TPwmPca9685 }

  TPwmPca9685 = object
  private
    fi2c: TI2cMaster;
    fI2Caddress: byte;
    fOscFreq: uint32;
    fPWMFreq: uint32;
  public
    // I2C address should be 7-bit address
    procedure Initialize(Ai2c: TI2cMaster; I2Caddress: byte = $40);
    // Reset to power up state
    procedure reset;
    // Enters sleep mode, disable PWM clock (and output) and preserves PWM settings
    // Hardware alternative: pull #OE pin to Vcc
    procedure enterSleep;
    // Restarts after sleep mode was entered - previous PWM settings are preserved
    procedure exitSleep;
    // If an improved frequency estimate for the chip is available
    // else a default value of 25 MHz is used for calculations
    procedure setOscillatorFrequency(AOscFreq: uint32);
    // Startup default is 200 Hz
    procedure setPWMFreq(freq: uint32);
    function getPrescaleValue: byte;
    // Startup default is totem pole
    procedure setPinDriveMode(mode: TPinDrive);
    // Set PWM ON and OFF start counts.  A PWM cycle is divided into 4096 counts.
    // For simple PWM, set onStartTime=0, then (offStartTime-1)/4096 will be the ON duty cycle
    procedure setPWM(channel: byte; onStartTime, offStartTime: uint16);

    // Helper for typical Servo motors, specify ON time
    procedure setOnMicroseconds(channel: uint32; us: int16);
  end;

implementation

uses
  esp_err, task;

const
  MODE1         = $00;    // Mode Register 1
  MODE2         = $01;    // Mode Register 2
  SUBADR1       = $02;    // I2C-bus subaddress 1
  SUBADR2       = $03;    // I2C-bus subaddress 2
  SUBADR3       = $04;    // I2C-bus subaddress 3
  ALLCALLADR    = $05;    // LED All Call I2C-bus address
  LED0_ON_L     = $06;    // LED0 on tick, low byte
  LED0_ON_H     = $07;    // LED0 on tick, high byte
  LED0_OFF_L    = $08;    // LED0 off tick, low byte
  LED0_OFF_H    = $09;    // LED0 off tick, high byte
// etc all 16:  LED15_OFF_H = $45

  ALLLED_ON_L   = $FA;    // load all the LEDn_ON registers, low
  ALLLED_ON_H   = $FB;    // load all the LEDn_ON registers, high
  ALLLED_OFF_L  = $FC;    // load all the LEDn_OFF registers, low
  ALLLED_OFF_H  = $FD;    // load all the LEDn_OFF registers,high
  PRE_SCALE     = $FE;    // Prescaler for PWM output frequency
  TESTMODE      = $FF;    // defines the test mode to be entered

// MODE1 bits
  ALLCAL  = $01;    // 1 = respond to LED All Call I2C-bus address
  SUB3    = $02;    // 1 = respond to I2C-bus subaddress 3
  SUB2    = $04;    // 1 = respond to I2C-bus subaddress 2
  SUB1    = $08;    // 1 = respond to I2C-bus subaddress 1
  SLEEP   = $10;    // 1 = Low power mode. Oscillator off
  AI      = $20;    // 1 = Auto-Increment enabled
  EXTCLK  = $40;    // 1 = Use EXTCLK pin clock
  RESTART = $80;    // 1 = Restart enabled

// MODE2 bits
  OUTNE_0       = $01;    // 0 = output 0, 1 = if OUTDRV = 1 then output = high else output = high impendance
  OUTNE_1       = $02;    // 1 = output high impedance
  OUTDRV        = $04;    // 0 = open drain, 1 = totem pole
  OCH           = $08;    // 0 = Outputs change on STOP, 1 = outputs change on ACK
  INVRT         = $10;    // Output logic state inverted

  I2C_ADDRESS   = $40;    // Default PCA9685 I2C Slave Address
  F_OSC_Default = 25000000; // Int. osc. frequency in datasheet - typ. 23 - 27 MHz

  PRESCALE_MIN  = 3;      // minimum prescale value
  PRESCALE_MAX  = 255;    // maximum prescale value

{ TPwmPca9685 }

procedure TPwmPca9685.Initialize(Ai2c: TI2cMaster; I2Caddress: byte);
var
  tmp: byte;
begin
  fi2c := Ai2c;
  fI2Caddress := I2Caddress;
  fOscFreq := F_OSC_Default;

  // Restore power on defaults
  reset;
  vTaskDelay(1);

  // Enable auto increment for sequential register writes
  EspErrorCheck(fi2c.ReadByteFromReg(fI2CAddress, byte(MODE1), tmp));
  tmp := tmp or AI;
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), tmp));

  // Configure MODE2 register for totem pole drive (OUTDRV=1) and outputs change on I2C ACK (OCH=1)
  tmp := OUTDRV or OCH;
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE2), tmp));
end;

procedure TPwmPca9685.reset;
var
  SWRST: byte = 6;
begin
  EspErrorCheck(fi2c.WriteBytes(0, @SWRST, 1));
end;

procedure TPwmPca9685.enterSleep;
var
  mode: byte;
begin
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), mode));
  mode := mode or SLEEP;
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), mode));
end;

procedure TPwmPca9685.exitSleep;
var
  oldmode1, newmode1: byte;
begin
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), oldmode1));
  // Clear sleep bit if RESTART is set
  if (oldmode1 and RESTART) > 0 then
  begin
    newmode1 := oldmode1 and not(SLEEP);
    EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), newmode1));
    // Delay for a minimum of 500 us
    vTaskDelay(1);
    newmode1 := oldmode1 or RESTART;
    EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), newmode1));
  end
  else
    writeln('exitSleep called but RESTART bit not set');
end;

procedure TPwmPca9685.setOscillatorFrequency(AOscFreq: uint32);
begin
  fOscFreq := AOscFreq;
end;

procedure TPwmPca9685.setPWMFreq(freq: uint32);
var
  prescaler: uint32;
  oldmode1, newmode1: byte;
begin
  fPWMFreq := freq;
  prescaler := (fOscFreq + 2048*freq) div (4096*freq) - 1;
  prescaler := (fOscFreq div (4096*freq)) - 1;
  // Minimum allowed is 3:
  if prescaler < 3 then
    prescaler := 3
  else if prescaler > 255 then
    prescaler := 255;

  // Sleep mode must be enabled to update PRE_SCALE
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), oldmode1));
  newmode1 := oldmode1 and not(RESTART) or SLEEP;
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), newmode1));

  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(PRE_SCALE), byte(prescaler)));

  // Restore previous mode
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), oldmode1));
end;

function TPwmPca9685.getPrescaleValue: byte;
begin
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(PRE_SCALE), Result));
end;

procedure TPwmPca9685.setPinDriveMode(mode: TPinDrive);
var
  mode2: byte;
begin
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(MODE2), mode2));
  if mode = pdTotemPole then
    mode2 := mode2 or OUTDRV
  else
    mode2 := mode2 and not(OUTDRV);
  EspErrorCheck(fi2c.WriteByteToReg(fI2CAddress, byte(MODE2), mode2));
end;

procedure TPwmPca9685.setPWM(channel: byte; onStartTime, offStartTime: uint16);
var
  tmp: array[0..3] of byte;
begin
  tmp[0] := byte(onStartTime);
  tmp[1] := onStartTime shr 8;
  tmp[2] := byte(offStartTime);
  tmp[3] := offStartTime shr 8;

  EspErrorCheck(fi2c.WriteBytesToReg(fI2CAddress, byte(LED0_ON_L + 4*channel), @tmp[0], 4));

  // Wait for settings to update, then check if SLEEP is cleared
  vTaskDelay(1);
  EspErrorCheck(fi2c.ReadBytesFromReg(fI2CAddress, byte(MODE1), @tmp[0], 1));
  if tmp[0] and SLEEP > 0 then
  begin
    tmp[0] := tmp[0] and not(SLEEP);
    EspErrorCheck(fi2c.WriteBytesToReg(fI2CAddress, byte(MODE1), @tmp[0], 1));
  end;
end;

procedure TPwmPca9685.setOnMicroseconds(channel: uint32; us: int16);
var
  offStart: uint16;
begin
  offStart := (((uint32(us) * 4096 * fPWMFreq + 500000)) div 1000000) - 1;
  setPWM(channel, 0, offStart);
end;

end.

