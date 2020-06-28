program realtimestats;

{$include sdkconfig.inc}
{$include freertosconfig.inc}
{$inline on}

uses
  fthreads, freertos, task, esp_err, semphr, portmacro, portable, projdefs,
  gpio {$ifdef CPULX6}, gpio_types {$endif};

const
  numSpinTasks            = 2;
  MaxIterations           = 50;     // Actual CPU cycles used will depend on compiler optimization
  spinTaskPriority        = 0;
  statsTaskPriority       = 0;
  taskArraySafetyMargin   = 5;          // Safety margin to cater for new tasks launched

var
  taskName: array[0..configMAX_TASK_NAME_LEN-1] of char;
  syncSpinTask: TSemaphoreHandle;
  syncStatsTask: TSemaphoreHandle;

function printRealTimeStats(xTicksToWait: TTickType): Tesp_err;
label
  exit_;
var
  startTaskArray: PTaskStatus = nil;
  endTaskArray: PTaskStatus = nil;
  startTaskArraySize, endTaskArraySize: TUBaseType;
  startRunTime, endRunTime: uint32;
  ret: Tesp_err;
  total_elapsed_time: uint32;
  i, j, k: int32;
  taskElapsedTime, percentageTime: uint32;
begin
  //Allocate array to store current task states
  startTaskArraySize := uxTaskGetNumberOfTasks() + taskArraySafetyMargin;
  startTaskArray := pvPortMalloc(sizeof(TTaskStatus) * startTaskArraySize);
  if (startTaskArray = nil) then
  begin
    ret := ESP_ERR_NO_MEM;
    goto exit_;
  end;
  //Get current task states
  startTaskArraySize := uxTaskGetSystemState(startTaskArray, startTaskArraySize, @startRunTime);
  if (startTaskArraySize = 0) then
  begin
    ret := ESP_ERR_INVALID_SIZE;
    goto exit_;
  end;

  vTaskDelay(xTicksToWait);

  //Allocate array to store tasks states post delay
  endTaskArraySize := uxTaskGetNumberOfTasks() + taskArraySafetyMargin;
  endTaskArray := pvPortMalloc(sizeof(TTaskStatus) * endTaskArraySize);
  if (endTaskArray = nil) then
  begin
    ret := ESP_ERR_NO_MEM;
    goto exit_;
  end;
  //Get post delay task states
  endTaskArraySize := uxTaskGetSystemState(endTaskArray, endTaskArraySize, @endRunTime);
  if (endTaskArraySize = 0) then
  begin
    ret := ESP_ERR_INVALID_SIZE;
    goto exit_;
  end;

  //Calculate total_elapsed_time in units of run time stats clock period.
  total_elapsed_time := (endRunTime - startRunTime);
  if (total_elapsed_time = 0) then
  begin
    ret := ESP_ERR_INVALID_STATE;
    goto exit_;
  end;

  writeln('| Task | Run Time | Percentage');
  // Match each task in startTaskArray to those in the endTaskArray
  for i := 0 to startTaskArraySize-1 do
  begin
    k := -1;
    for j := 0 to endTaskArraySize-1 do
    begin
      if (startTaskArray[i].xHandle = endTaskArray[j].xHandle) then
      begin
        k := j;
        //Mark that task have been matched by overwriting their handles
        startTaskArray[i].xHandle := nil;
        endTaskArray[j].xHandle := nil;
        break;
      end;
    end;
    //Check if matching task found
    if k >= 0 then
    begin
      taskElapsedTime := endTaskArray[k].ulRunTimeCounter - startTaskArray[i].ulRunTimeCounter;
      percentageTime := (taskElapsedTime * 100) div (total_elapsed_time * portNUM_PROCESSORS);
      writeln('| ',startTaskArray[i].pcTaskName, ' | ', taskElapsedTime, ' | ', percentageTime, '%');
    end;
  end;

  //Print unmatched tasks
  for i := 0 to startTaskArraySize-1 do
    if not(startTaskArray[i].xHandle = nil) then
      writeln('| ', startTaskArray[i].pcTaskName, ' | Deleted');

  for i := 0 to endTaskArraySize-1 do
    if not(endTaskArray[i].xHandle = nil) then
      writeln('| ', endTaskArray[i].pcTaskName, ' | Created');

  ret := ESP_OK;

exit_:    //Common return path
  vPortFree(startTaskArray);
  vPortFree(endTaskArray);
  result := ret;
end;

procedure spinTask(arg: pointer); // Require arg to match TTaskFunction definition
var
  Iterations: uint32 = 0;
  i: integer;
begin
  Iterations := MaxIterations div (uint32(arg) + 1);
  xSemaphoreTake(syncSpinTask, portMAX_DELAY);
  while true do
  begin
    // Spin...
    for i := 0 to Iterations-1 do
    begin
      asm NOP end;
      if i div 10 = 0 then // give a bit more time for serial loop to respond quicker
        portYIELD;
    end;
    vTaskDelay(pdMS_TO_TICKS(10));
  end;
end;

procedure statsTask(arg: pointer);
var
  i: integer;
  statsTick: uint32;
begin
  statsTick := pdMS_TO_TICKS(1000);
  xSemaphoreTake(syncStatsTask, portMAX_DELAY);

  //Start all the spin tasks
  for i := 0 to numSpinTasks-1 do
  begin
    xSemaphoreGive(syncSpinTask);
  end;

  writeln('statstask running on core ID ', xPortGetCoreID);

  //Print real time stats periodically
  while true do
  begin
    writeln(#10'Getting real time stats over ',statsTick, ' ticks'#10);
    if (printRealTimeStats(statsTick) = ESP_OK) then
      writeln('Real time stats obtained')
    else
      writeln('Error getting real time stats'#10);

    vTaskDelay(pdMS_TO_TICKS(5000));
  end;
end;

const
  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  //LED = GPIO_NUM_13; // Sonoff Basic

var
  cfg: Tgpio_config;

function blinkThread(parameter : pointer) : ptrint;
begin
  repeat
    gpio_set_level(LED, 0);
    vTaskDelay(1000 div portTICK_PERIOD_MS);
    gpio_set_level(LED, 1);
    vTaskDelay(500 div portTICK_PERIOD_MS);
  until false;
end;

var
  i: integer;
  blinkID: TThreadID;
  c: char;

begin
  // Configure pin state
  cfg.pin_bit_mask := 1 shl ord(LED);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);
  gpio_set_direction(LED, GPIO_MODE_OUTPUT);

  writeln('Configured LED pin, starting blink...');
  //vTaskDelay(500 div portTICK_PERIOD_MS);

  BeginThread(nil,          // sa : Pointer;                            - not used for FreeRTOS
              1024,         // stacksize : SizeUInt;
              @blinkThread, // ThreadFunction : tthreadfunc;
              nil,          // p : pointer;
              0,            // creationFlags : dword;                   - not used for FreeRTOS
              blinkID);     // var ThreadId : TThreadID) : TThreadID;

  //Allow other core to finish initialization
  vTaskDelay(pdMS_TO_TICKS(100));
  writeln('Created blink thread with ID: ', blinkID);
  writeln(LineEnding, 'Blink thread can be [S]uspended, [R]esumed or [K]illed.', LineEnding);

  //Create semaphores to synchronize
  syncSpinTask := xSemaphoreCreateCounting(numSpinTasks, 0);
  syncStatsTask := xSemaphoreCreateBinary();

  //Create spin tasks
  FillChar(taskName[0], sizeof(taskName), #0);
  taskname[0] := 'T'; taskname[1] := 'a'; taskname[2] := 's'; taskname[3] := 'k';

  for i := 0 to numSpinTasks-1 do
  begin
    taskName[4] := char(ord('0') + i);
    writeln('Creating Task', i);
    // Pass i as parameter to task
    xTaskCreatePinnedToCore(@spinTask, PChar(@taskName[0]), 1024, pointer(i), 0, nil, tskNO_AFFINITY);
  end;

  //Create and start stats task
  writeln('Creating stats');
  vTaskDelay(pdMS_TO_TICKS(10));
  xTaskCreatePinnedToCore(@statsTask, 'stats', 4*1024, nil, statsTaskPriority, nil, 0);//tskNO_AFFINITY);
  xSemaphoreGive(syncStatsTask);

  // Thread control loop
  repeat
    read(c);
    case c of
      's', 'S':
        begin
          if blinkID <> 0 then
          begin
            SuspendThread(blinkID);
            writeln('Suspended');
          end;
        end;
      'r', 'R':
      begin
        if blinkID <> 0 then
        begin
          ResumeThread(blinkID);
          writeln('Resumed');
        end;
      end;
      'k', 'K':
      begin
        if blinkID <> 0 then
        begin
          writeln('Bye');
          KillThread(blinkID);
          blinkID := 0;
        end;
      end
    else
      ;
    end;
    vTaskDelay(pdMS_TO_TICKS(10));
  until false;
end.
