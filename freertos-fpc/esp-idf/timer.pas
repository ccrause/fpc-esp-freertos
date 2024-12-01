unit timer;

interface

uses
  esp_err, soc, portmacro, esp_intr_alloc,
  timer_types;

const
  TIMER_BASE_CLK = APB_CLK_FREQ;

type
  Ptimer_config = ^Ttimer_config;

  Ttimer_isr = function(para1: pointer): Tbool;

  Ptimer_isr_handle = ^Ttimer_isr_handle;
  Ttimer_isr_handle = Tintr_handle;

function timer_get_counter_value(group_num: Ttimer_group; timer_num: Ttimer_idx;
  timer_val: Puint64): Tesp_err; external;

function timer_get_counter_time_sec(group_num: Ttimer_group;
  timer_num: Ttimer_idx; time: Pdouble): Tesp_err; external;

function timer_set_counter_value(group_num: Ttimer_group; timer_num: Ttimer_idx;
  load_val: uint64): Tesp_err; external;

function timer_start(group_num: Ttimer_group; timer_num: Ttimer_idx): Tesp_err; external;

function timer_pause(group_num: Ttimer_group; timer_num: Ttimer_idx): Tesp_err; external;

function timer_set_counter_mode(group_num: Ttimer_group; timer_num: Ttimer_idx;
  counter_dir: Ttimer_count_dir): Tesp_err; external;

function timer_set_auto_reload(group_num: Ttimer_group; timer_num: Ttimer_idx;
  reload: Ttimer_autoreload): Tesp_err; external;

function timer_set_divider(group_num: Ttimer_group; timer_num: Ttimer_idx;
  divider: uint32): Tesp_err; external;

function timer_set_alarm_value(group_num: Ttimer_group; timer_num: Ttimer_idx;
  alarm_value: uint64): Tesp_err; external;

function timer_get_alarm_value(group_num: Ttimer_group; timer_num: Ttimer_idx;
  alarm_value: Puint64): Tesp_err; external;

function timer_set_alarm(group_num: Ttimer_group; timer_num: Ttimer_idx;
  alarm_en: Ttimer_alarm): Tesp_err; external;

function timer_isr_callback_add(group_num: Ttimer_group; timer_num: Ttimer_idx;
  isr_handler: Ttimer_isr; arg: pointer; intr_alloc_flags: longint): Tesp_err; external;

function timer_isr_callback_remove(group_num: Ttimer_group;
  timer_num: Ttimer_idx): Tesp_err; external;

function timer_isr_register(group_num: Ttimer_group; timer_num: Ttimer_idx;
  fn: Ttimer_isr; arg: pointer; intr_alloc_flags: longint;
  handle: Ptimer_isr_handle): Tesp_err; external;

function timer_init(group_num: Ttimer_group; timer_num: Ttimer_idx;
  config: Ptimer_config): Tesp_err; external;

function timer_deinit(group_num: Ttimer_group; timer_num: Ttimer_idx): Tesp_err; external;

function timer_get_config(group_num: Ttimer_group; timer_num: Ttimer_idx;
  config: Ptimer_config): Tesp_err; external;

function timer_group_intr_enable(group_num: Ttimer_group;
  intr_mask: Ttimer_intr): Tesp_err; external;

function timer_group_intr_disable(group_num: Ttimer_group;
  intr_mask: Ttimer_intr): Tesp_err; external;

function timer_enable_intr(group_num: Ttimer_group; timer_num: Ttimer_idx): Tesp_err;
  external;

function timer_disable_intr(group_num: Ttimer_group; timer_num: Ttimer_idx): Tesp_err;
  external;

procedure timer_group_clr_intr_status_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx); external;

procedure timer_group_enable_alarm_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx); external;

function timer_group_get_counter_value_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx): uint64; external;

procedure timer_group_set_alarm_value_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx; alarm_val: uint64); external;

procedure timer_group_set_counter_enable_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx; counter_en: Ttimer_start); external;

function timer_group_get_intr_status_in_isr(group_num: Ttimer_group): uint32; external;

function timer_group_get_auto_reload_in_isr(group_num: Ttimer_group;
  timer_num: Ttimer_idx): Tbool; external;

function timer_spinlock_take(group_num: Ttimer_group): Tesp_err; external;

function timer_spinlock_give(group_num: Ttimer_group): Tesp_err; external;

implementation

end.
