unit pwm_mcpwm;

interface

// PWM generator based on the MCPWM peripheral
// Simplistic view where timers = operators
// 2x MCPWM units
// 3x timers / unit
// 2x Generators / timer

// ESP32 has 2 units with 3 timers each, so in total 6 independent PWM generators.
// Each generator can generate 2 outputs, but with the same frequency.

uses
  mcpwm, mcpwm_types, esp_err;

type
  TPWM_mcpwm = object
  private
    fPWMunit: Tmcpwm_unit;
    fPWMtimer: Tmcpwm_timer;
    fPWMgenerator: Tmcpwm_generator;
    fPWMchannel: Tmcpwm_io_signals;
    fOutputPin: int32;
  public
    function init(PWMunit: Tmcpwm_unit; PWMtimer: Tmcpwm_timer;
      PWMgenerator: Tmcpwm_generator; pin: int32): Tesp_err;
    function setDuty(duty: single): Tesp_err;
    function setFrequency(freq: uint32): Tesp_err;
    function stop: Tesp_err;
    function start: Tesp_err;
  end;

  { TStepperPWM }

  TStepperPWM = object
  private
    fPWM: TPWM_mcpwm;
    fEnablePin: int32;
  public
    enabledState: boolean;  // if true, enabled when HIGH
    stepsPerRevolution: uint32; // 200 = 1.8 deg/step
    microSteps: uint32;     // 1 = half step, 2 = 1/4 step, 3 = 1/8 step...
    function init(PWMunit: Tmcpwm_unit; PWMtimer: Tmcpwm_timer;
      PWMgenerator: Tmcpwm_generator; stepPin: int32; enablePin: int32): Tesp_err;

    procedure setEnablePin(pin: uint32);
    function stop: Tesp_err;
    function start: Tesp_err;

    procedure setRPM(rpm: uint32);
  end;

implementation

uses
  gpio, gpio_types;

{ TStepperPWM }

function TStepperPWM.init(PWMunit: Tmcpwm_unit; PWMtimer: Tmcpwm_timer;
  PWMgenerator: Tmcpwm_generator; stepPin: int32; enablePin: int32): Tesp_err;
var
  cfg: Tgpio_config;
begin
  writeln('Stepper init');
  Result := fPWM.init(PWMunit, PWMtimer, PWMgenerator, stepPin);

  writeln('Stepper setDuty');
  fPWM.setDuty(50);
  microSteps := 0;
  stepsPerRevolution := 200;
  fEnablePin := enablePin;
  writeln('Stepper set enable pin');
  if enablePin >= 0 then
  begin
    cfg.pin_bit_mask := 1 shl ord(enablePin);
    cfg.mode := GPIO_MODE_OUTPUT;
    cfg.pull_up_en := GPIO_PULLUP_DISABLE;
    cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
    cfg.intr_type := GPIO_INTR_DISABLE;
    gpio_config(cfg);
    enabledState := true;
    gpio_set_direction(Tgpio_num(enablePin), GPIO_MODE_OUTPUT);
  end;
end;

procedure TStepperPWM.setEnablePin(pin: uint32);
begin
  fEnablePin := pin;
end;

function TStepperPWM.stop: Tesp_err;
begin
  Result := fPWM.stop;
  if fEnablePin >= 0 then
  begin
    if enabledState then
      gpio_set_level(Tgpio_num(fEnablePin), 0)
    else
      gpio_set_level(Tgpio_num(fEnablePin), 1);
  end;
end;

function TStepperPWM.start: Tesp_err;
begin
  Result := fPWM.start;
  if fEnablePin >= 0 then
  begin
    if enabledState then
      gpio_set_level(Tgpio_num(fEnablePin), 1)
    else
      gpio_set_level(Tgpio_num(fEnablePin), 0);
  end;
end;

procedure TStepperPWM.setRPM(rpm: uint32);
var
  v: uint32;
begin
  v := rpm * (1 shl microSteps) * stepsPerRevolution;
  v := v div 60;
  fPWM.setFrequency(v);
end;

function TPWM_mcpwm.init(PWMunit: Tmcpwm_unit; PWMtimer: Tmcpwm_timer;
  PWMgenerator: Tmcpwm_generator; pin: int32): Tesp_err;
var
  config: Tmcpwm_config;
  f: uint32;
begin
  fPWMunit := PWMunit;
  fPWMtimer := PWMtimer;
  fPWMgenerator := PWMgenerator;
  fOutputPin := pin;
  fPWMchannel := Tmcpwm_io_signals(ord(PWMtimer)*2 + ord(PWMgenerator));

  writeln('PWM setting output pin');
  Result := mcpwm_gpio_init(PWMunit, fPWMchannel, fOutputPin);

  // Try not to change settings if unit&timer has been configured
  // previously for a different generator on the same timer
  // This will generate a runtime error message MCPWM DRIVER NOT INITIALIZED
  // if this is the first time the current timer is initialized.
  //f := mcpwm_get_frequency(PWMunit, PWMtimer);
  //writeln('Previous freq: ', f);
  //if f < 16 then
    f := 16;

  with config do
  begin
    frequency := f;  // Hz
    //if PWMgenerator = MCPWM_GEN_A then
    begin
      cmpr_a := 0;
      cmpr_b := 0; //mcpwm_get_duty(PWMunit, PWMtimer, MCPWM_GEN_B);
    end;
    //else
    //begin
    //  cmpr_a := mcpwm_get_duty(PWMunit, PWMtimer, MCPWM_GEN_A);
    //  cmpr_b := 0;
    //end;
    duty_mode := MCPWM_DUTY_MODE_0; // duty cycle proportional to high time
    counter_mode := MCPWM_UP_COUNTER; // For symmetric MCPWM, frequency is half of MCPWM frequency set
  end;
  writeln('PWM mcpwm_init');
  Result := mcpwm_init(PWMunit, PWMtimer, @config);
end;

function TPWM_mcpwm.setDuty(duty: single): Tesp_err;
begin
  writeln('setDuty: ', duty);
  Result := mcpwm_set_duty(fPWMunit, fPWMtimer, fPWMgenerator, duty);
end;

function TPWM_mcpwm.setFrequency(freq: uint32): Tesp_err;
begin
  writeln('setFrequency: ', freq);
  Result := mcpwm_set_frequency(fPWMunit, fPWMtimer, freq);
end;

function TPWM_mcpwm.stop: Tesp_err;
begin
  Result := mcpwm_stop(fPWMunit, fPWMtimer);
end;

function TPWM_mcpwm.start: Tesp_err;
begin
  Result := mcpwm_start(fPWMunit, fPWMtimer);
end;

end.

