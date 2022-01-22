program fpcthreads;

{$include freertosconfig.inc}
{$inline on}

uses
  fthreads, task, esp_err, portmacro, portable, projdefs,
  gpio {$ifdef CPULX6}, gpio_types {$endif};

const
  numSpinTasks            = 2;
  MaxIterations           = 500;     // Actual CPU cycles used will depend on compiler optimization
  taskArraySafetyMargin   = 5;          // Safety margin to cater for new tasks launched

var
  startSpinTask: PRTLEvent;
  blinkCS: TRTLCriticalSection;

// To avoid using one of the util units
procedure printLeftAlignedPadded(const s: shortstring; width: uint32);
var
  numPads: int32;
begin
  write(s);
  numPads := width - length(s);
  while numPads > 0 do
  begin
    write(' ');
    dec(numPads);
  end;
end;

function printRealTimeStats(xTicksToWait: TTickType): Tesp_err;
var
  startTaskArray: PTaskStatus = nil;
  endTaskArray: PTaskStatus = nil;
  startTaskArraySize, endTaskArraySize: TUBaseType;
  startRunTime, endRunTime: uint32;
  elapsedTime: uint32;
  i, j, k: int32;
  taskElapsedTime, percentageTime: uint32;
  s: shortstring;
begin
  result := ESP_OK;
  startTaskArraySize := uxTaskGetNumberOfTasks() + taskArraySafetyMargin;
  GetMem(startTaskArray, sizeof(TTaskStatus) * startTaskArraySize);
  if (startTaskArray <> nil) then
  begin
    //Get current task states
    startTaskArraySize := uxTaskGetSystemState(startTaskArray, startTaskArraySize, @startRunTime);

    if (startTaskArraySize > 0) then
    begin
      // Wait while stats accumulate...
      vTaskDelay(xTicksToWait);
      endTaskArraySize := uxTaskGetNumberOfTasks() + taskArraySafetyMargin;
      GetMem(endTaskArray, sizeof(TTaskStatus) * endTaskArraySize);
      if (endTaskArray <> nil) then
      begin
        //Get post delay task states
        endTaskArraySize := uxTaskGetSystemState(endTaskArray, endTaskArraySize, @endRunTime);
        if (endTaskArraySize > 0) then
        begin
          elapsedTime := (endRunTime - startRunTime);
          if (elapsedTime > 0) then
          begin
            // Now calculate and format results
            writeln(' Task             | Run Time   | Percentage');
            writeln('------------------+------------+-----------');
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
                percentageTime := (taskElapsedTime * 100) div (elapsedTime * portNUM_PROCESSORS);
                write(' ');
                printLeftAlignedPadded(startTaskArray[i].pcTaskName, 16);
                write(' | ');
                Str(taskElapsedTime, s);
                printLeftAlignedPadded(s, 10);
                writeln(' | ', percentageTime: 3, '%');
              end;
            end;
            writeln('------------------+------------+-----------');

            //Print unmatched tasks
            for i := 0 to startTaskArraySize-1 do
              if not(startTaskArray[i].xHandle = nil) then
                writeln(startTaskArray[i].pcTaskName: 16, ' | Deleted');

            for i := 0 to endTaskArraySize-1 do
              if not(endTaskArray[i].xHandle = nil) then
                writeln(endTaskArray[i].pcTaskName: 16, ' | Created');

          end // elapsedTime > 0
          else
            Result := ESP_ERR_INVALID_STATE;

        end // endTaskArraySize > 0
        else
          Result := ESP_ERR_INVALID_SIZE;

        FreeMem(endTaskArray);
      end // endTaskArray <> nil
      else
        Result := ESP_ERR_NO_MEM;

    end  // startTaskArraySize > 0
    else
      Result := ESP_ERR_INVALID_SIZE;

    FreeMem(startTaskArray);
  end // startTaskArray <> nil
end;

function spinThread(arg: pointer): ptrint;
var
  Iterations: uint32 = 0;
  i: integer;
begin
  Iterations := MaxIterations div (uint32(arg) + 1);

  // Wait for start event...
  RTLEventWaitFor(startSpinTask);
  while true do
  begin
    // Spin...
    for i := 0 to Iterations-1 do
    begin
      asm NOP end;
      if i div 10 = 0 then
        ThreadSwitch; // Thread switch occasionally to make other threads more responsive
    end;
    vTaskDelay(pdMS_TO_TICKS(10));
  end;
end;

const
  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  //LED = GPIO_NUM_13; // Sonoff Basic

function blinkThread(parameter : pointer) : ptrint; noreturn;
var
  cfg: Tgpio_config;
begin
  // Configure pin state
  cfg.pin_bit_mask := 1 shl ord(LED);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);
  gpio_set_direction(LED, GPIO_MODE_OUTPUT);
  repeat
    EnterCriticalSection(blinkCS);
    LeaveCriticalSection(blinkCS); // immediately release CS again, it is used as a gate only
    gpio_set_level(LED, 0);
    vTaskDelay(250 div portTICK_PERIOD_MS);
    gpio_set_level(LED, 1);
    vTaskDelay(250 div portTICK_PERIOD_MS);
  until false;
end;

var
  i: integer;
  blinkID: TThreadID;
  statsTick: uint32;
  loopcount: uint32 = 0;
  taskName: shortstring;

begin
  InitCriticalSection(blinkCS);
  EnterCriticalSection(blinkCS);  // blinkCS will now block

  writeln('Starting blink thread');
  // Calling BeginThread without a name will assign a default name 'fpc-#'
  // where # is the number of unnamed threads started
  BeginThread(@blinkThread,       // thread to launch
             nil,                 // pointer parameter to be passed to thread function
             blinkID,             // new thread ID
             4*1024);             // stacksize

  //Allow other core to finish initialization
  vTaskDelay(pdMS_TO_TICKS(100));

  //Create semaphores to synchronize
  startSpinTask := RTLEventCreate;
  //Create spin tasks
  for i := 0 to numSpinTasks-1 do
  begin
    Str(i, taskName);
    insert('spin-', taskName, 1);
    writeln('Creating Task', i);
    // Pass i as parameter to task
    // Larger i will run fewer spin cycles
    fBeginThreadNamed(1024,         // stacksize
                      @spinThread,  // thread to launch
                      pointer(i),   // pointer parameter to be passed to thread function
                      blinkID,      // the new thread ID
                      taskName);
  end;

  vTaskDelay(pdMS_TO_TICKS(100));
  writeln('Starting spinTasks');
  //Start all the spin tasks
  for i := 0 to numSpinTasks-1 do
  begin
    RTLEventSetEvent(startSpinTask);
    // Potential race situation where next RTLEventSetEvent is called
    // before spinThread had an opportunity to read first event.
    // Put delay here so that spin thread gets an opportunity to read the first event.
    // An alternative design could be a pair of ping-pong events.
    vTaskDelay(50);
  end;

  writeln('Main running on core ID ', xPortGetCoreID);
  // Wait period between stats calls, in sys ticks
  statsTick := pdMS_TO_TICKS(2000);
  repeat
    inc(loopcount);
    // Block/unblock blink loop
    if odd(loopcount) then
    begin
      writeln('Resume blink');
      LeaveCriticalSection(blinkCS);
    end
    else
    begin
      writeln('Pause blink');
      EnterCriticalSection(blinkCS);
    end;
    vTaskDelay(statsTick);
    writeln(#10'Getting real time stats over ',statsTick, ' ticks'#10);
    if (printRealTimeStats(statsTick) = ESP_OK) then
      writeln('Real time stats obtained')
    else
      writeln('Error getting real time stats'#10);
  until false;
end.
