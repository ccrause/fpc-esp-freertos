unit mcpwm;

{$linklib gcc, static}  // Required by esp-idf libraries to link to floating point routines provided by compiler

interface

uses
  mcpwm_types, esp_err, esp_intr_alloc;

type
  Pmcpwm_io_signals = ^Tmcpwm_io_signals;
  Tmcpwm_io_signals = (MCPWM0A := 0, MCPWM0B, MCPWM1A, MCPWM1B, MCPWM2A,
    MCPWM2B, MCPWM_SYNC_0, MCPWM_SYNC_1, MCPWM_SYNC_2,
    MCPWM_FAULT_0, MCPWM_FAULT_1, MCPWM_FAULT_2,
    MCPWM_CAP_0 := 84, MCPWM_CAP_1, MCPWM_CAP_2
    );

  Pmcpwm_pin_config = ^Tmcpwm_pin_config;
  Tmcpwm_pin_config = record
    mcpwm0a_out_num: int32;
    mcpwm0b_out_num: int32;
    mcpwm1a_out_num: int32;
    mcpwm1b_out_num: int32;
    mcpwm2a_out_num: int32;
    mcpwm2b_out_num: int32;
    mcpwm_sync0_in_num: int32;
    mcpwm_sync1_in_num: int32;
    mcpwm_sync2_in_num: int32;
    mcpwm_fault0_in_num: int32;
    mcpwm_fault1_in_num: int32;
    mcpwm_fault2_in_num: int32;
    mcpwm_cap0_in_num: int32;
    mcpwm_cap1_in_num: int32;
    mcpwm_cap2_in_num: int32;
  end;

  Pmcpwm_unit = ^Tmcpwm_unit;
  Tmcpwm_unit = (MCPWM_UNIT_0 := 0, MCPWM_UNIT_1, MCPWM_UNIT_MAX);

  Pmcpwm_timer = ^Tmcpwm_timer;
  Tmcpwm_timer = (MCPWM_TIMER_0 := 0, MCPWM_TIMER_1, MCPWM_TIMER_2,
    MCPWM_TIMER_MAX);

  Pmcpwm_generator = ^Tmcpwm_generator;
  Tmcpwm_generator = (MCPWM_GEN_A := 0, MCPWM_GEN_B, MCPWM_GEN_MAX);

const
  MCPWM_OPR_A = MCPWM_GEN_A;
  MCPWM_OPR_B = MCPWM_GEN_B;
  MCPWM_OPR_MAX = MCPWM_GEN_MAX;

type
  Pmcpwm_operator = ^Tmcpwm_operator;
  Tmcpwm_operator = Tmcpwm_generator;

  Pmcpwm_carrier_os = ^Tmcpwm_carrier_os;
  Tmcpwm_carrier_os = (MCPWM_ONESHOT_MODE_DIS := 0, MCPWM_ONESHOT_MODE_EN);

  Pmcpwm_carrier_out_ivt = ^Tmcpwm_carrier_out_ivt;
  Tmcpwm_carrier_out_ivt = (MCPWM_CARRIER_OUT_IVT_DIS := 0, MCPWM_CARRIER_OUT_IVT_EN);

  Pmcpwm_fault_signal = ^Tmcpwm_fault_signal;
  Tmcpwm_fault_signal = (MCPWM_SELECT_F0 := 0, MCPWM_SELECT_F1, MCPWM_SELECT_F2);

  Pmcpwm_fault_input_level = ^Tmcpwm_fault_input_level;
  Tmcpwm_fault_input_level = (MCPWM_LOW_LEVEL_TGR := 0, MCPWM_HIGH_LEVEL_TGR);

  Pmcpwm_action_on_pwmxa = ^Tmcpwm_action_on_pwmxa;
  Tmcpwm_action_on_pwmxa = Tmcpwm_output_action;

const
  MCPWM_NO_CHANGE_IN_MCPWMXA = MCPWM_ACTION_NO_CHANGE;
  MCPWM_FORCE_MCPWMXA_LOW = MCPWM_ACTION_FORCE_LOW;
  MCPWM_FORCE_MCPWMXA_HIGH = MCPWM_ACTION_FORCE_HIGH;
  MCPWM_TOG_MCPWMXA = MCPWM_ACTION_TOGGLE;

type
  Pmcpwm_action_on_pwmxb = ^Tmcpwm_action_on_pwmxb;
  Tmcpwm_action_on_pwmxb = Tmcpwm_output_action;

const
  MCPWM_NO_CHANGE_IN_MCPWMXB = MCPWM_ACTION_NO_CHANGE;
  MCPWM_FORCE_MCPWMXB_LOW = MCPWM_ACTION_FORCE_LOW;
  MCPWM_FORCE_MCPWMXB_HIGH = MCPWM_ACTION_FORCE_HIGH;
  MCPWM_TOG_MCPWMXB = MCPWM_ACTION_TOGGLE;

type
  Pmcpwm_capture_signal = ^Tmcpwm_capture_signal;
  Tmcpwm_capture_signal = (MCPWM_SELECT_CAP0 := 0, MCPWM_SELECT_CAP1,
    MCPWM_SELECT_CAP2);

  Pmcpwm_config = ^Tmcpwm_config;
  Tmcpwm_config = record
    frequency:  uint32;
    cmpr_a: single;
    cmpr_b: single;
    duty_mode: Tmcpwm_duty_type;
    counter_mode: Tmcpwm_counter_type;
  end;

  Pmcpwm_carrier_config = ^Tmcpwm_carrier_config;
  Tmcpwm_carrier_config = record
    carrier_period: byte;
    carrier_duty: byte;
    pulse_width_in_os: byte;
    carrier_os_mode: Tmcpwm_carrier_os;
    carrier_ivt_mode: Tmcpwm_carrier_out_ivt;
  end;

 TIsrProc = procedure(para1: pointer);

function mcpwm_gpio_init(mcpwm_num: Tmcpwm_unit; io_signal: Tmcpwm_io_signals;
  gpio_num: int32): Tesp_err; external;

function mcpwm_set_pin(mcpwm_num: Tmcpwm_unit;
  mcpwm_pin: Pmcpwm_pin_config): Tesp_err; external;

function mcpwm_init(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  mcpwm_conf: Pmcpwm_config): Tesp_err; external;

function mcpwm_set_frequency(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  frequency: uint32): Tesp_err; external;

function mcpwm_set_duty(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_generator; duty: single): Tesp_err; external;

function mcpwm_set_duty_in_us(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_generator; duty_in_us: uint32): Tesp_err; external;

function mcpwm_set_duty_type(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_generator; duty_type: Tmcpwm_duty_type): Tesp_err; external;

function mcpwm_get_frequency(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer):  uint32; external;

function mcpwm_get_duty(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_operator): single; external;

function mcpwm_set_signal_high(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_generator): Tesp_err; external;

function mcpwm_set_signal_low(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  gen: Tmcpwm_generator): Tesp_err; external;

function mcpwm_start(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer): Tesp_err;
  external;

function mcpwm_stop(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer): Tesp_err;
  external;

function mcpwm_carrier_init(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  carrier_conf: Pmcpwm_carrier_config): Tesp_err; external;

function mcpwm_carrier_enable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer): Tesp_err; external;

function mcpwm_carrier_disable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer): Tesp_err; external;

function mcpwm_carrier_set_period(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; carrier_period: byte): Tesp_err; external;

function mcpwm_carrier_set_duty_cycle(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; carrier_duty: byte): Tesp_err; external;

function mcpwm_carrier_oneshot_mode_enable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; pulse_width: byte): Tesp_err; external;

function mcpwm_carrier_oneshot_mode_disable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer): Tesp_err; external;

function mcpwm_carrier_output_invert(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; carrier_ivt_mode: Tmcpwm_carrier_out_ivt): Tesp_err;
  external;

function mcpwm_deadtime_enable(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  dt_mode: Tmcpwm_deadtime_type; red:  uint32; fed: uint32): Tesp_err; external;

function mcpwm_deadtime_disable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer): Tesp_err; external;

function mcpwm_fault_init(mcpwm_num: Tmcpwm_unit;
  intput_level: Tmcpwm_fault_input_level; fault_sig: Tmcpwm_fault_signal): Tesp_err;
  external;

function mcpwm_fault_set_oneshot_mode(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; fault_sig: Tmcpwm_fault_signal;
  action_on_pwmxa: Tmcpwm_output_action;
  action_on_pwmxb: Tmcpwm_output_action): Tesp_err; external;

function mcpwm_fault_set_cyc_mode(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer; fault_sig: Tmcpwm_fault_signal;
  action_on_pwmxa: Tmcpwm_output_action;
  action_on_pwmxb: Tmcpwm_output_action): Tesp_err; external;

function mcpwm_fault_deinit(mcpwm_num: Tmcpwm_unit;
  fault_sig: Tmcpwm_fault_signal): Tesp_err; external;

function mcpwm_capture_enable(mcpwm_num: Tmcpwm_unit;
  cap_sig: Tmcpwm_capture_signal; cap_edge: Tmcpwm_capture_on_edge;
  num_of_pulse: uint32): Tesp_err; external;

function mcpwm_capture_disable(mcpwm_num: Tmcpwm_unit;
  cap_sig: Tmcpwm_capture_signal): Tesp_err; external;

function mcpwm_capture_signal_get_value(mcpwm_num: Tmcpwm_unit;
  cap_sig: Tmcpwm_capture_signal):  uint32; external;

function mcpwm_capture_signal_get_edge(mcpwm_num: Tmcpwm_unit;
  cap_sig: Tmcpwm_capture_signal):  uint32; external;

function mcpwm_sync_enable(mcpwm_num: Tmcpwm_unit; timer_num: Tmcpwm_timer;
  sync_sig: Tmcpwm_sync_signal; phase_val: uint32): Tesp_err; external;

function mcpwm_sync_disable(mcpwm_num: Tmcpwm_unit;
  timer_num: Tmcpwm_timer): Tesp_err; external;

function mcpwm_isr_register(mcpwm_num: Tmcpwm_unit; fn: TIsrProc;
  arg: pointer; intr_alloc_flags: int32; handle: Pintr_handle): Tesp_err; external;

implementation

end.
