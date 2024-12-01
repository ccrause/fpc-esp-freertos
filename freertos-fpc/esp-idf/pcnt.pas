unit pcnt;

interface

uses
  esp_intr_alloc, pcnt_types, soc_caps, esp_err;

const
  PCNT_PIN_NOT_USED = -(1);

type
  Ppcnt_isr_handle = ^Tpcnt_isr_handle;
  Tpcnt_isr_handle = Tintr_handle;

  Ppcnt_port = ^Tpcnt_port;
  Tpcnt_port = (PCNT_PORT_0, PCNT_PORT_MAX);

  Ppcnt_unit = ^Tpcnt_unit;
  Tpcnt_unit = (
    PCNT_UNIT_0, PCNT_UNIT_1, PCNT_UNIT_2, PCNT_UNIT_3,
    {$if SOC_PCNT_UNITS_PER_GROUP > 4}
    PCNT_UNIT_4, PCNT_UNIT_5, PCNT_UNIT_6, PCNT_UNIT_7,
    {$endif}
    PCNT_UNIT_MAX);

  Ppcnt_channel = ^Tpcnt_channel;
  Tpcnt_channel = (PCNT_CHANNEL_0, PCNT_CHANNEL_1, PCNT_CHANNEL_MAX);

  Ppcnt_evt_type = ^Tpcnt_evt_type;
  Tpcnt_evt_type = (
    PCNT_EVT_THRES_1 := 1 shl 2,
    PCNT_EVT_THRES_0 := 1 shl 3,
    PCNT_EVT_L_LIM := 1 shl 4,
    PCNT_EVT_H_LIM := 1 shl 5,
    PCNT_EVT_ZERO := 1 shl 6,
    PCNT_EVT_MAX);

  Ppcnt_ctrl_mode = ^Tpcnt_ctrl_mode;
  Tpcnt_ctrl_mode = Tpcnt_channel_level_action;

const
  PCNT_MODE_KEEP = PCNT_CHANNEL_LEVEL_ACTION_KEEP;
  PCNT_MODE_REVERSE = PCNT_CHANNEL_LEVEL_ACTION_INVERSE;
  PCNT_MODE_DISABLE = PCNT_CHANNEL_LEVEL_ACTION_HOLD;
  PCNT_MODE_MAX = 3;

type
  Ppcnt_count_mode = ^Tpcnt_count_mode;
  Tpcnt_count_mode = Tpcnt_channel_edge_action;

const
  PCNT_COUNT_DIS = PCNT_CHANNEL_EDGE_ACTION_HOLD;
  PCNT_COUNT_INC = PCNT_CHANNEL_EDGE_ACTION_INCREASE;
  PCNT_COUNT_DEC = PCNT_CHANNEL_EDGE_ACTION_DECREASE;
  PCNT_COUNT_MAX = 3;

type
  Ppcnt_config = ^Tpcnt_config;

  Tpcnt_config = record
    pulse_gpio_num: longint;
    ctrl_gpio_num: longint;
    lctrl_mode: Tpcnt_ctrl_mode;
    hctrl_mode: Tpcnt_ctrl_mode;
    pos_mode: Tpcnt_count_mode;
    neg_mode: Tpcnt_count_mode;
    counter_h_lim: int16;
    counter_l_lim: int16;
    unit_: Tpcnt_unit;
    channel: Tpcnt_channel;
  end;

function pcnt_unit_config(pcnt_config: Ppcnt_config): Tesp_err; external;

function pcnt_get_counter_value(pcnt_unit: Tpcnt_unit; Count: Pint16): Tesp_err;
  external;

function pcnt_counter_pause(pcnt_unit: Tpcnt_unit): Tesp_err; external;

function pcnt_counter_resume(pcnt_unit: Tpcnt_unit): Tesp_err; external;

function pcnt_counter_clear(pcnt_unit: Tpcnt_unit): Tesp_err; external;

function pcnt_intr_enable(pcnt_unit: Tpcnt_unit): Tesp_err; external;

function pcnt_intr_disable(pcnt_unit: Tpcnt_unit): Tesp_err; external;

function pcnt_event_enable(unit_: Tpcnt_unit; evt_type: Tpcnt_evt_type): Tesp_err;
  external;

function pcnt_event_disable(unit_: Tpcnt_unit; evt_type: Tpcnt_evt_type): Tesp_err;
  external;

function pcnt_set_event_value(unit_: Tpcnt_unit; evt_type: Tpcnt_evt_type;
  Value: int16): Tesp_err; external;

function pcnt_get_event_value(unit_: Tpcnt_unit; evt_type: Tpcnt_evt_type;
  Value: Pint16): Tesp_err; external;

function pcnt_get_event_status(unit_: Tpcnt_unit; status: Puint32): Tesp_err; external;

function pcnt_isr_unregister(handle: Tpcnt_isr_handle): Tesp_err; external;

function pcnt_isr_register(fn: Tintr_handler; arg: pointer;
  intr_alloc_flags: longint; handle: Ppcnt_isr_handle): Tesp_err; external;

function pcnt_set_pin(unit_: Tpcnt_unit; channel: Tpcnt_channel;
  pulse_io: longint; ctrl_io: longint): Tesp_err; external;

function pcnt_filter_enable(unit_: Tpcnt_unit): Tesp_err; external;

function pcnt_filter_disable(unit_: Tpcnt_unit): Tesp_err; external;

function pcnt_set_filter_value(unit_: Tpcnt_unit; filter_val: uint16): Tesp_err;
  external;

function pcnt_get_filter_value(unit_: Tpcnt_unit; filter_val: Puint16): Tesp_err;
  external;

function pcnt_set_mode(unit_: Tpcnt_unit; channel: Tpcnt_channel;
  pos_mode: Tpcnt_count_mode; neg_mode: Tpcnt_count_mode; hctrl_mode: Tpcnt_ctrl_mode;
  lctrl_mode: Tpcnt_ctrl_mode): Tesp_err; external;

function pcnt_isr_handler_add(unit_: Tpcnt_unit; isr_handler: Tintr_handler;
  args: pointer): Tesp_err; external;

function pcnt_isr_service_install(intr_alloc_flags: longint): Tesp_err; external;

procedure pcnt_isr_service_uninstall; external;

function pcnt_isr_handler_remove(unit_: Tpcnt_unit): Tesp_err; external;

implementation

end.
