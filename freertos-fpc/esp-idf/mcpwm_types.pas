unit mcpwm_types;

interface

uses
  esp_bit_defs;

type
  Pmcpwm_intr = ^Tmcpwm_intr;
  Tmcpwm_intr = (MCPWM_LL_INTR_CAP0 := BIT27, MCPWM_LL_INTR_CAP1 := BIT28,
    MCPWM_LL_INTR_CAP2 := BIT29);

  Pmcpwm_counter_type = ^Tmcpwm_counter_type;
  Tmcpwm_counter_type = (MCPWM_UP_COUNTER := 1, MCPWM_DOWN_COUNTER,
    MCPWM_UP_DOWN_COUNTER, MCPWM_COUNTER_MAX);

  Pmcpwm_duty_type = ^Tmcpwm_duty_type;
  Tmcpwm_duty_type = (MCPWM_DUTY_MODE_0 := 0, MCPWM_DUTY_MODE_1,
    MCPWM_HAL_GENERATOR_MODE_FORCE_LOW, MCPWM_HAL_GENERATOR_MODE_FORCE_HIGH,
    MCPWM_DUTY_MODE_MAX);

  Pmcpwm_output_action = ^Tmcpwm_output_action;
  Tmcpwm_output_action = (MCPWM_ACTION_NO_CHANGE := 0, MCPWM_ACTION_FORCE_LOW,
    MCPWM_ACTION_FORCE_HIGH, MCPWM_ACTION_TOGGLE);

  Pmcpwm_deadtime_type = ^Tmcpwm_deadtime_type;
  Tmcpwm_deadtime_type = (MCPWM_DEADTIME_BYPASS := 0, MCPWM_BYPASS_RED,
    MCPWM_BYPASS_FED, MCPWM_ACTIVE_HIGH_MODE,
    MCPWM_ACTIVE_LOW_MODE, MCPWM_ACTIVE_HIGH_COMPLIMENT_MODE,
    MCPWM_ACTIVE_LOW_COMPLIMENT_MODE, MCPWM_ACTIVE_RED_FED_FROM_PWMXA,
    MCPWM_ACTIVE_RED_FED_FROM_PWMXB, MCPWM_DEADTIME_TYPE_MAX);

  Pmcpwm_sync_signal = ^Tmcpwm_sync_signal;
  Tmcpwm_sync_signal = (MCPWM_SELECT_SYNC0 := 4, MCPWM_SELECT_SYNC1,
    MCPWM_SELECT_SYNC2);

  Pmcpwm_capture_on_edge = ^Tmcpwm_capture_on_edge;
  Tmcpwm_capture_on_edge = (MCPWM_NEG_EDGE := BIT0, MCPWM_POS_EDGE := BIT1,
    MCPWM_BOTH_EDGE := BIT1 or BIT0);

implementation

end.
