unit timeralarm;

interface

uses
  timer, timer_types, task, portmacro;

type
  { TTimerAlarm }

  TTimerAlarm = object
  private
    timerGroup: Ttimer_group;
    timerIndex: Ttimer_idx;
    alarmInterval: integer;
    autoReload: Ttimer_autoreload;
    taskToNotify: TTaskHandle;
  public
    procedure initTimerAlarm(Agroup: TTimer_group; Atimer: TTimer_idx;
      AautoReload: Ttimer_autoreload; AtimerInterval_sec: integer;
      AtaskToNotify: TTaskHandle);
  end;
  PTimerAlarm = ^TTimerAlarm;

implementation

uses
  projdefs;

const
  TIMER_DIVIDER = 16;  //  Hardware timer clock divider
  TIMER_SCALE   = (TIMER_BASE_CLK div TIMER_DIVIDER);

function timerAlarmCallback(args: pointer): Tbool; section '.iram1';
var
  xHigherPriorityTaskWoken: TBaseType;
  obj: PTimerAlarm;
begin
  xHigherPriorityTaskWoken := pdFALSE;
  obj := PTimerAlarm(args);
  timer_group_set_alarm_value_in_isr(obj^.timerGroup, obj^.timerIndex, obj^.alarmInterval);
  vTaskNotifyGiveFromISR(obj^.taskToNotify, @xHigherPriorityTaskWoken);
  Result := xHigherPriorityTaskWoken = pdTRUE; // return whether we need to yield at the end of ISR
end;

{ TTimerAlarm }

procedure TTimerAlarm.initTimerAlarm(Agroup: TTimer_group; Atimer: TTimer_idx;
  AautoReload: Ttimer_autoreload; AtimerInterval_sec: integer;
  AtaskToNotify: TTaskHandle);
var
  config: Ttimer_config;
begin
  timerGroup := Agroup;
  timerIndex := Atimer;
  autoReload := AautoReload;
  alarmInterval := Atimerinterval_sec * TIMER_SCALE;
  taskToNotify := AtaskToNotify;

  config.divider := TIMER_DIVIDER;
  config.counter_dir := TIMER_COUNT_UP;
  config.counter_en := TIMER_PAUSE;
  config.alarm_en := TIMER_ALARM_EN;
  config.auto_reload := autoReload;
  config.intr_type := TIMER_INTR_LEVEL;
  // default clock source is APB

  timer_init(timerGroup, timerIndex, @config);
  timer_set_counter_value(timerGroup, timerIndex, 0);

  // Configure the alarm value and the interrupt on alarm. */
  timer_set_alarm_value(timerGroup, timerIndex, alarmInterval);
  timer_enable_intr(timerGroup, timerIndex);

  timer_isr_callback_add(timerGroup, timerIndex, @timerAlarmCallback, @Self, 0);
  timer_start(timerGroup, timerIndex);
end;

end.

