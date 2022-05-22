program fpcthreads;

{$include freertosconfig.inc}
{$inline on}

uses
  fmem, fthreads, task, esp_err, portmacro, portable, projdefs,
  gpio {$ifdef CPULX6}, gpio_types {$endif};

const
  numSpinTasks            = 5;
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

function printRealTimeStats: Tesp_err;
var
  startTaskArray: PTaskStatus = nil;
  startTaskArraySize: TUBaseType;
  startRunTime: uint32;
  i: int32;
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
      // Now calculate and format results
      writeln('=====================================================================================');
      writeln('| Task             | Pinned to core | Run Time   | Min stack clearance | State      |');
      writeln('|------------------+----------------+------------+---------------------+------------|');
      // Match each task in startTaskArray to those in the endTaskArray
      for i := 0 to startTaskArraySize-1 do
      begin
        write('| ');
        if (uint32(startTaskArray[i].pcTaskName) < $3f000000) or
           (uint32(startTaskArray[i].pcTaskName) > $3fffffff) then
          printLeftAlignedPadded('?????', 16)
        else
          printLeftAlignedPadded(startTaskArray[i].pcTaskName, 16);
        write(' | ');

        {$if defined(configTASKLIST_INCLUDE_COREID)}
        if startTaskArray[i].xCoreID = tskNO_AFFINITY then
          printLeftAlignedPadded('no', 14)
        else
        begin
          Str(startTaskArray[i].xCoreID, s);
          printLeftAlignedPadded(s, 14);
        end;
        {$else}
        printLeftAlignedPadded('-', 14);
        {$endif}
        write(' | ');

        Str(startTaskArray[i].ulRunTimeCounter, s);
        printLeftAlignedPadded(s, 10);
        write(' | ');

        Str(startTaskArray[i].usStackHighWaterMark, s);
        printLeftAlignedPadded(s, 19);

        write(' | ');
        Str(startTaskArray[i].eCurrentState, s);
        printLeftAlignedPadded(s, 11);
        writeln('|');
      end;
      writeln('=====================================================================================');
    end; // startTaskArraySize > 0
    FreeMem(startTaskArray);
  end // startTaskArray <> nil
end;

function spinThread(arg: pointer): ptrint; noreturn;
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

begin
  //Create RTL event to signal spin threads
  startSpinTask := RTLEventCreate;
  //Create spin tasks
  for i := 0 to numSpinTasks-1 do
  begin
    writeln('Creating fpc task ', i);
    // Pass i as parameter to task
    // Larger i will run fewer spin cycles
    BeginThread(@spinThread,        // thread to launch
               nil,//pointer(i),          // pointer parameter to be passed to thread function
               blinkID,             // new thread ID
               2*1024);             // stacksize
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

  // Blink thread...
  InitCriticalSection(blinkCS);
  EnterCriticalSection(blinkCS);  // blinkCS will now block
  writeln('Starting blink thread');
  fBeginThreadNamed(2*1024,        // stacksize
                    @blinkThread,  // thread to launch
                    nil,           // pointer parameter to be passed to thread function
                    blinkID,       // the new thread ID
                    'blink');

  //Allow other core to finish initialization
  vTaskDelay(pdMS_TO_TICKS(100));
  writeln('After blink thread');

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
    if not(printRealTimeStats = ESP_OK) then
      writeln('Error getting real time stats'#10);
  until false;
end.
