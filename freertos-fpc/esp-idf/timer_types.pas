unit timer_types;

interface

uses
  esp_bit_defs, soc_caps;

type
  Ptimer_group = ^Ttimer_group;
  Ttimer_group = (
    TIMER_GROUP_0 := 0,
    {$if declared(SOC_TIMER_GROUPS) and (SOC_TIMER_GROUPS > 1)}
    TIMER_GROUP_1 := 1,
    {$endif}
    TIMER_GROUP_MAX);

  Ptimer_idx = ^Ttimer_idx;
  Ttimer_idx = (
    TIMER_0 := 0,
    {$if SOC_TIMER_GROUP_TIMERS_PER_GROUP > 1}
    TIMER_1 := 1,
    {$endif}
    TIMER_MAX);

  Ptimer_count_dir = ^Ttimer_count_dir;
  Ttimer_count_dir = (
    TIMER_COUNT_DOWN := 0,
    TIMER_COUNT_UP := 1,
    TIMER_COUNT_MAX);

  Ptimer_start = ^Ttimer_start;
  Ttimer_start = (
    TIMER_PAUSE := 0,
    TIMER_START_ := 1);

  Ptimer_intr = ^Ttimer_intr;
  Ttimer_intr = (
    TIMER_INTR_T0 := BIT0,
    {$if declared(SOC_TIMER_GROUP_TIMERS_PER_GROUP) and (SOC_TIMER_GROUP_TIMERS_PER_GROUP > 1)}
    TIMER_INTR_T1 := BIT1,
    TIMER_INTR_WDT := BIT2,
    {$else}
    TIMER_INTR_WDT := BIT1,
    {$endif}
    TIMER_INTR_NONE := 0);

  Ttimer_alarm = (
    TIMER_ALARM_DIS := 0,
    TIMER_ALARM_EN = 1,
    TIMER_ALARM_MAX);

  Ptimer_intr_mode = ^Ttimer_intr_mode;
  Ttimer_intr_mode = (
    TIMER_INTR_LEVEL := 0,
    TIMER_INTR_MAX);

  Ptimer_autoreload = ^Ttimer_autoreload;
  Ttimer_autoreload = (
    TIMER_AUTORELOAD_DIS := 0,
    TIMER_AUTORELOAD_EN := 1,
    TIMER_AUTORELOAD_MAX);

  {$if declared(SOC_TIMER_GROUP_SUPPORT_XTAL) and (SOC_TIMER_GROUP_SUPPORT_XTAL > 0)}
  Ptimer_src_clk = ^Ttimer_src_clk;
  Ttimer_src_clk = (
    TIMER_SRC_CLK_APB := 0,
    TIMER_SRC_CLK_XTAL := 1);
  {$endif}

  Ptimer_config = ^Ttimer_config;
  Ttimer_config = record
    alarm_en: Ttimer_alarm;
    counter_en: Ttimer_start;
    intr_type: Ttimer_intr_mode;
    counter_dir: Ttimer_count_dir;
    auto_reload: Ttimer_autoreload;
    divider: uint32;
    {$if declared(SOC_TIMER_GROUP_SUPPORT_XTAL) and (SOC_TIMER_GROUP_SUPPORT_XTAL > 0)}
    clk_src: Ttimer_src_clk;
    {$endif}
  end;

implementation

end.
