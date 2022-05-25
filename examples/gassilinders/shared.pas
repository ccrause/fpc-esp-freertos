unit shared;

interface

uses
  task, portmacro;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32

procedure memReport;

procedure printTaskReport;

implementation

uses
  esp_heap_caps, logtouart;

procedure sleep(Milliseconds: cardinal);
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

procedure memReport;
var
  s: string[16];
  v: uint32;
begin
  logwrite('Internal RAM free: ');
  v := heap_caps_get_free_size(MALLOC_CAP_INTERNAL);
  Str(v, s);
  logwriteln(s);

  logwrite('Data RAM free: ');
  v := heap_caps_get_free_size(MALLOC_CAP_8BIT);
  Str(v, s);
  logwriteln(s);
end;


// To avoid using one of the util units
procedure printLeftAlignedPadded(const s: shortstring; width: uint32);
var
  numPads: int32;
begin
  logwrite(s);
  numPads := width - length(s);
  while numPads > 0 do
  begin
    logwrite(' ');
    dec(numPads);
  end;
end;

procedure printTaskReport;
var
  startTaskArray: PTaskStatus = nil;
  startTaskArraySize: TUBaseType;
  startRunTime: uint32;
  i: int32;
  s: shortstring;
begin
  startTaskArraySize := uxTaskGetNumberOfTasks() + 4;
  GetMem(startTaskArray, sizeof(TTaskStatus) * startTaskArraySize);
  if (startTaskArray <> nil) then
  begin
    //Get current task states
    startTaskArraySize := uxTaskGetSystemState(startTaskArray, startTaskArraySize, @startRunTime);

    if (startTaskArraySize > 0) then
    begin
      // Now calculate and format results
      //writeln('=====================================================================================');
      logwriteln('| Task             | Pinned to core | Run Time   | Min stack clearance | State      |');
      //writeln('|------------------+----------------+------------+---------------------+------------|');
      // Match each task in startTaskArray to those in the endTaskArray
      for i := 0 to startTaskArraySize-1 do
      begin
        logwrite('| ');
        if (uint32(startTaskArray[i].pcTaskName) < $3f000000) or
           (uint32(startTaskArray[i].pcTaskName) > $3fffffff) then
          printLeftAlignedPadded('?????', 16)
        else
          printLeftAlignedPadded(startTaskArray[i].pcTaskName, 16);
        logwrite(' | ');

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
        logwrite(' | ');

        Str(startTaskArray[i].ulRunTimeCounter, s);
        printLeftAlignedPadded(s, 10);
        logwrite(' | ');

        Str(startTaskArray[i].usStackHighWaterMark, s);
        printLeftAlignedPadded(s, 19);

        logwrite(' | ');
        Str(startTaskArray[i].eCurrentState, s);
        printLeftAlignedPadded(s, 11);
        logwriteln('|');
      end;
      //writeln('=====================================================================================');
    end; // startTaskArraySize > 0
    FreeMem(startTaskArray);
  end // startTaskArray <> nil
end;

end.

