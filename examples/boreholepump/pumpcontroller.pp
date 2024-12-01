program pumpcontroller;

{$macro on}
{$inline on}

uses
  wificonnect,
  webserver,
  pcnt,
  esp_err, portmacro, esp_log,
  rtc_wdt, aj_sr04m_unit, flowmeter,
  projdefs, timer, timer_types,
  queue, dataunit,
  semphr, storage, pinsconfig, runstateunit;

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

type
  PTimerInfo = ^TTimerInfo;
  TTimerInfo = record
    timerGroup: Ttimer_group;
    timerIndex: Ttimer_idx;
    alarmInterval: integer;
    autoReload: Ttimer_autoreload;
  end;

  Texample_timer_event = record
    //info: TTimerInfo;
    timer_counter_value: uint64;
  end;

const
  TIMER_DIVIDER = 16;  //  Hardware timer clock divider
  TIMER_SCALE   = (TIMER_BASE_CLK div TIMER_DIVIDER);

var
  s_timer_queue: TQueueHandle;
  timerInfo: TTimerInfo;

function timer_group_isr_callback(args: pointer): Tbool; section '.iram1';
var
  high_task_awoken: TBaseType;
  timer_counter_value: uint64;
  info: PTimerInfo;
  evt: Texample_timer_event;
begin
  high_task_awoken := pdFALSE;
  info := PTimerInfo(args);

  timer_counter_value := timer_group_get_counter_value_in_isr(info^.timerGroup, info^.timerIndex);

  evt.timer_counter_value := timer_counter_value;

  if info^.autoReload = TIMER_AUTORELOAD_DIS then
  begin
    timer_counter_value := timer_counter_value + info^.alarmInterval * TIMER_SCALE;
    timer_group_set_alarm_value_in_isr(info^.timerGroup, info^.timerIndex, timer_counter_value);
  end;

  ///* Now just send the event data back to the main program task */
  xQueueSendFromISR(s_timer_queue, @evt, @high_task_awoken);

  Result := high_task_awoken = pdTRUE; // return whether we need to yield at the end of ISR
end;

///**
// * @brief Initialize selected timer of timer group
// *
// * @param group Timer Group number, index from 0
// * @param timer timer ID, index from 0
// * @param auto_reload whether auto-reload on alarm event
// * @param timer_interval_sec interval of alarm
// */
procedure example_tg_timer_init(group: TTimer_group; timer: TTimer_idx;
  auto_reload: Ttimer_autoreload; timer_interval_sec: integer);
var
  config: Ttimer_config;
begin
  config.divider := TIMER_DIVIDER;
  config.counter_dir := TIMER_COUNT_UP;
  config.counter_en := TIMER_PAUSE;
  config.alarm_en := TIMER_ALARM_EN;
  config.auto_reload := auto_reload;
  config.intr_type := TIMER_INTR_LEVEL;
  // default clock source is APB

  timer_init(group, timer, @config);
  // Timer's counter will initially start from value below.
  //   Also, if auto_reload is set, this value will be automatically reload on alarm */
  timer_set_counter_value(group, timer, 0);

  // Configure the alarm value and the interrupt on alarm. */
  timer_set_alarm_value(group, timer, timer_interval_sec * TIMER_SCALE);
  timer_enable_intr(group, timer);

  timerInfo.timerGroup := group;
  timerInfo.timerIndex := timer;
  timerInfo.autoReload := auto_reload;
  timerInfo.alarmInterval := timer_interval_sec;

  timer_isr_callback_add(group, timer, @timer_group_isr_callback, @timerInfo, 0);
  timer_start(group, timer);
end;

var
  levelSensor: TAJ_SR04M;
  flowsensor: TPulseFlowmeter;
  level: integer;
  flow: single;
  count, oldcount: uint16;
  evt: Texample_timer_event;
  dataCount: integer;
  runState: TRunStateMachine;

// ~/fpc/xtensa/esp-idf-4.4.7/components/esptool_py/esptool/esptool.py -p /dev/ttyUSB0 -b 921600 -c auto write_flash 0x10000 pumpcontroller.bin

const
  maxCount = 60;  // Save data every minute

begin
  rtc_wdt_disable; // In case WDT was initialized by bootloader
  esp_log_level_set('*', ESP_LOG_WARN);

  oldcount := 0;
  dataIndex := 0;
  dataCount := 0;
  level := 0;
  flow := 0;
  runState.init();

  dataSem := xSemaphoreCreateMutex;
  xSemaphoreGive(dataSem);

  s_timer_queue := xQueueCreate(10, sizeof(Texample_timer_event));
  example_tg_timer_init(TIMER_GROUP_0, TIMER_0, TIMER_AUTORELOAD_EN, 1);

  if loadSettings() = ESP_FAIL then
  begin
    // Set default values
    settings.LLstart      := 750; // mm
    settings.HLstop       := 500; // mm
    settings.restartDelay := 15;  // minutes
    settings.LFstop       := 10;  // L/min
    settings.startDeadTime:= 15;  // s
  end;

  connectWifiAP(AP_NAME, PWD);
  writeln('Starting web server...');
  start_webserver;

  writeln('init level sensor');
  levelSensor.init(levelSensorUart, levelSensorTxPin, levelSensorRxPin);

  writeln('init pulse counter');
  flowsensor.init(flowSensorCounterUnit, flowSensorPulsePin);
  writeln('Done init'#10);

  // Loop runs every 1 second
  repeat
    xQueueReceive(s_timer_queue, @evt, portMAX_DELAY);
    count := flowsensor.getReading;
    //writeln;

    if levelSensor.readDistance(currentLevel) then
    begin
      write('Level = ', currentLevel:4, 'mm   ');
      level := level + currentLevel;
    end
    else // Communication error, assume same reading as disconnected sensor
      currentLevel := 6016;

    if count < uint16($FFFF) then
    begin
      //writeln('Count = ', count);
      currentFlow := (count - oldcount) / 27; // Datasheet factor: 6.6;
      writeln('flow = ', currentFlow:1:2, ' L/min');
      oldcount := count;
      flow := flow + currentFlow;
    end
    else
    begin  // Unlikely, but then what to do?
      currentFlow := 0;
      writeln('Error reading flowsensor.');
    end;

    if dataCount >= maxCount-1 then
    begin
      level := level div maxCount;
      flow := flow / maxCount;

      xSemaphoreTake(dataSem, portMAX_DELAY);
      levels[dataIndex] := level;
      flows[dataIndex] := round(flow*10); // convert to dL/min, then it is already scaled for plotting
      inc(dataIndex);
      if dataIndex > high(levels) then
        dataIndex := 0;
      xSemaphoreGive(dataSem);

      dataCount := 0;
      level := 0;
      flow := 0;
    end
    else
      inc(dataCount);

    runState.update(currentLevel, currentFlow);
  until false;
end.
