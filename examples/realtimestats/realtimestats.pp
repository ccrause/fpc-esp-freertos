program realtimestats;

{$include sdkconfig.inc}
{$include freertosconfig.inc}
{$inline on}

uses
  freertos, task, esp_err, semphr, portmacro, portable, projdefs, esp_log;

const
  numSpinTasks            = 3;
  MaxIterations           = 500000;     // Actual CPU cycles used will depend on compiler optimization
  spinTaskPriority        = 2;
  statsTaskPriority       = 3;
  taskArraySafetyMargin   = 5;          // Safety margin to cater for new tasks launched
  TAG                     = 'example';

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

procedure spinTask(arg: pointer); // Require arg to match TTaskFunction_t definition
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
      asm NOP end;
    vTaskDelay(pdMS_TO_TICKS(100));
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
    vTaskDelay(pdMS_TO_TICKS(1000));  // slow down task activation for printing
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

var
  i: integer;

begin
  //Allow other core to finish initialization
  vTaskDelay(pdMS_TO_TICKS(100));

  //Create semaphores to synchronize
  syncSpinTask := xSemaphoreCreateCounting(numSpinTasks, 0);
  syncStatsTask := xSemaphoreCreateBinary();

  //Create spin tasks
  FillChar(taskName[0], sizeof(taskName), #0);
  taskname[0] := 'T'; taskname[1] := 'a'; taskname[2] := 's'; taskname[3] := 'k';

  for i := 0 to numSpinTasks-1 do
  begin
    taskName[4] := char(ord('0') + i);
    // Pass i as parameter to task
    xTaskCreatePinnedToCore(@spinTask, PChar(@taskName[0]), 1024, pointer(i), spinTaskPriority, nil, tskNO_AFFINITY);
  end;

  //Create and start stats task
  xTaskCreatePinnedToCore(@statsTask, 'stats', 4*1024, nil, statsTaskPriority, nil, 0);//tskNO_AFFINITY);
  xSemaphoreGive(syncStatsTask);

  // Do not fall through to FPC_EXIT, which calls sleep
  repeat
    vTaskDelay(pdMS_TO_TICKS(500));
  until false;
end.
