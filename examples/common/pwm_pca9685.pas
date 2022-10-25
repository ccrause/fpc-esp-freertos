unit pwm_pca9685;

interface

uses
  i2c_obj, esp_err;

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
    function Initialize(Ai2c: TI2cMaster; I2Caddress: byte = $40): Tesp_err;
    // Reset to power up state
    function reset: Tesp_err;
    // Enters sleep mode, disable PWM clock (and output) and preserves PWM settings
    // Hardware alternative: pull #OE pin to Vcc
    function enterSleep: Tesp_err;
    // Restarts after sleep mode was entered - previous PWM settings are preserved
    function exitSleep: Tesp_err;
    // If an improved frequency estimate for the chip is available
    // else a default value of 25 MHz is used for calculations
    procedure setOscillatorFrequency(AOscFreq: uint32);
    // Startup default is 200 Hz
    function setPWMFreq(freq: uint32): Tesp_err;
    function getPrescaleValue: byte;
    // Startup default is totem pole
    function setPinDriveMode(mode: TPinDrive): Tesp_err;
    // Set PWM ON and OFF start counts.  A PWM cycle is divided into 4096 counts.
    // For simple PWM, set onStartTime=0, then (offStartTime-1)/4096 will be the ON duty cycle
    function setPWM(channel: byte; onStartTime, offStartTime: uint16): Tesp_err;

    // Helper for typical Servo motors, specify ON time
    function setOnMicroseconds(channel: uint32; us: int16): Tesp_err;
    // Switch output to either high or low
    function setChannelFixedOutput(channel: uint32; outputHigh: boolean): Tesp_err;
    // Remove fixed full on/of bits of the specified channel
    function clearChannelFixedOutput(channel: uint32): Tesp_err;
  end;

implementation

uses
  task;

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

function TPwmPca9685.Initialize(Ai2c: TI2cMaster; I2Caddress: byte): Tesp_err;
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
  Result := fi2c.ReadByteFromReg(fI2CAddress, byte(MODE1), tmp);
  if Result <> ESP_OK then exit;

  tmp := tmp or AI;
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), tmp);
  if Result <> ESP_OK then exit;

  // Configure MODE2 register for totem pole drive (OUTDRV=1) and outputs change on I2C STOP (OCH=0)
  tmp := OUTDRV;
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE2), tmp);
end;

function TPwmPca9685.reset: Tesp_err;
var
  SWRST: byte = 6;
begin
  Result := fi2c.WriteBytes(0, @SWRST, 1);
end;

// If any PWM channel is active when calling enterSleep, the RESTART bit will be set in MODE1
function TPwmPca9685.enterSleep: Tesp_err;
var
  mode: byte;
begin
  Result := fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), mode);
  if Result <> ESP_OK then exit;

  mode := mode or SLEEP;
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), mode);
end;

// If RESTART bit is set, previously configured PWM channels should continue
function TPwmPca9685.exitSleep: Tesp_err;
var
  mode: byte;
begin
  Result := fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), mode);
  if Result <> ESP_OK then exit;

  mode := mode and not(SLEEP);
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), mode);
  if Result <> ESP_OK then exit;

  // If RESTART bit was set, restart PWM by writing a 1 to RESTART bit (Datasheet section 7.3.1.1)
  if (mode and RESTART) > 0 then
  begin
    // Delay for a minimum of 500 us
    vTaskDelay(1);
    Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), mode);
  end;
end;

procedure TPwmPca9685.setOscillatorFrequency(AOscFreq: uint32);
begin
  fOscFreq := AOscFreq;
end;

function TPwmPca9685.setPWMFreq(freq: uint32): Tesp_err;
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
  Result := fi2c.ReadBytefromReg(fI2CAddress, byte(MODE1), oldmode1);
  if Result <> ESP_OK then exit;

  newmode1 := oldmode1 and not(RESTART) or SLEEP;
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), newmode1);
  if Result <> ESP_OK then exit;

  Result := fi2c.WriteByteToReg(fI2CAddress, byte(PRE_SCALE), byte(prescaler));
  if Result <> ESP_OK then exit;

  // Restore previous mode
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE1), oldmode1);
end;

function TPwmPca9685.getPrescaleValue: byte;
begin
  EspErrorCheck(fi2c.ReadBytefromReg(fI2CAddress, byte(PRE_SCALE), Result));
end;

function TPwmPca9685.setPinDriveMode(mode: TPinDrive): Tesp_err;
var
  mode2: byte;
begin
  Result := fi2c.ReadBytefromReg(fI2CAddress, byte(MODE2), mode2);
  if Result <> ESP_OK then exit;

  if mode = pdTotemPole then
    mode2 := mode2 or OUTDRV
  else
    mode2 := mode2 and not(OUTDRV);
  Result := fi2c.WriteByteToReg(fI2CAddress, byte(MODE2), mode2);
end;

function TPwmPca9685.setPWM(channel: byte; onStartTime, offStartTime: uint16): Tesp_err;
var
  tmp: array[0..3] of byte;
  err: Tesp_err;
begin
  tmp[0] := byte(onStartTime);
  tmp[1] := onStartTime shr 8;
  tmp[2] := byte(offStartTime);
  tmp[3] := offStartTime shr 8;

  Result := fi2c.WriteBytesToReg(fI2CAddress, byte(LED0_ON_L + 4*channel), @tmp[0], 4);
  if Result <> ESP_OK then exit;

  // Wait for settings to update, then check if SLEEP is cleared
  vTaskDelay(1);
  Result := fi2c.ReadBytesFromReg(fI2CAddress, byte(MODE1), @tmp[0], 1);
  if Result <> ESP_OK then exit;

  if tmp[0] and SLEEP > 0 then
  begin
    tmp[0] := tmp[0] and not(SLEEP);
    Result := fi2c.WriteBytesToReg(fI2CAddress, byte(MODE1), @tmp[0], 1);
  end;
end;

function TPwmPca9685.setOnMicroseconds(channel: uint32; us: int16): Tesp_err;
var
  offStart: uint16;
begin
  if us = 0 then
    offStart := 0
  else
    offStart := (((uint32(us) * 4096 * fPWMFreq + 500000)) div 1000000) - 1;
  Result := setPWM(channel, 0, offStart);
end;

function TPwmPca9685.setChannelFixedOutput(channel: uint32; outputHigh: boolean): Tesp_err;
var
  tmp: byte;
begin
  if outputHigh then
  begin
    Result := fi2c.ReadByteFromReg(fI2CAddress, byte((LED0_ON_L+1) + 4*channel), tmp);
    if Result <> ESP_OK then exit;
    tmp := tmp or (1 shl 4);
    Result := fi2c.WriteBytesToReg(fI2CAddress, byte((LED0_ON_L+1) + 4*channel), @tmp, 1);
  end
  else
  begin
    Result := fi2c.ReadByteFromReg(fI2CAddress, byte((LED0_ON_L+3) + 4*channel), tmp);
    if Result <> ESP_OK then exit;
    tmp := tmp or (1 shl 4);
    Result := fi2c.WriteBytesToReg(fI2CAddress, byte((LED0_ON_L+3) + 4*channel), @tmp, 1);
  end;
end;

function TPwmPca9685.clearChannelFixedOutput(channel: uint32): Tesp_err;
var
  tmp: byte;
begin
  Result := fi2c.ReadByteFromReg(fI2CAddress, byte((LED0_ON_L+1) + 4*channel), tmp);
  if Result <> ESP_OK then exit;
  tmp := tmp and $EF;  // Clear bit 4
  Result := fi2c.WriteBytesToReg(fI2CAddress, byte((LED0_ON_L+1) + 4*channel), @tmp, 1);

  Result := fi2c.ReadByteFromReg(fI2CAddress, byte((LED0_ON_L+3) + 4*channel), tmp);
  if Result <> ESP_OK then exit;
  tmp := tmp and $EF;  // Clear bit 4
  Result := fi2c.WriteBytesToReg(fI2CAddress, byte((LED0_ON_L+3) + 4*channel), @tmp, 1);
end;

end.

