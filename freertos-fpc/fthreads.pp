{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2002 by Peter Vreman,
    member of the Free Pascal development team.

    FreeRTOS threading support implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit fthreads;

{$inline on}

interface

const
  DefaultStackSize = 4*1024;

{ every platform can have it's own implementation of GetCPUCount; use the define
  HAS_GETCPUCOUNT to disable the default implementation which simply returns 1 }
function GetCPUCount: LongWord;

property CPUCount: LongWord read GetCPUCount;

procedure SysInitMultithreading;

function fBeginThreadNamed(StackSize: PtrUInt;
  ThreadFunction: TThreadFunc; P: pointer;
  var ThreadId: TThreadID; aname: string): TThreadID;

implementation

uses
  fmem, task, semphr, portmacro, portable;

{$include freertosconfig.inc}

const
// FreeRTOS have some TLS space per task, use DataIndex to identify the
// location of FPC's TLS pointer in this space
// TODO: check if FPC TLS space required can fit into the FreeRTOS TLS block, could save memory that way.
  DataIndex: PtrUInt = 0; // Require setting "Number of thread local storage pointers" to larger than 0 under FreeRTOS options in config
  ThreadVarBlockSize: dword = 0;
  TLSAPISupported: boolean = false;
  pdTRUE = 1;

var
  FreeRTOSThreadManager: TThreadManager;
  TLSInitialized: boolean32 = false;

procedure HandleError(Errno : Longint); external name 'FPC_HANDLEERROR';
procedure fpc_threaderror; [external name 'FPC_THREADERROR'];

procedure SysInitThreadvar (var Offset: dword; Size: dword);
begin
  {$ifdef CPUXTENSA}
  ThreadVarBlockSize := align(ThreadVarBlockSize, 4);
  {$endif CPUXTENSA}
  Offset := ThreadVarBlockSize;
  Inc(ThreadVarBlockSize, Size);
end;

procedure SysAllocateThreadVars;
var
  p: pointer;
begin
  { we've to allocate the memory from the OS }
  { because the FPC heap management uses     }
  { exceptions which use threadvars but      }
  { these aren't allocated yet ...           }
  { allocate room on the heap for the thread vars }
  if TLSAPISupported and TLSInitialized then // let's stick with the FreeRTOS TLS block for now
  begin
    // TODO: Not sure whether it is safe to call GetMem or the OS provided routine...
    p := GetMem(ThreadVarBlockSize); // ThreadVarBlockSize is global, the TLS size is the same for all the threads;
    vTaskSetThreadLocalStoragePointer(nil, DataIndex, p);
  end
  else
    HandleError(3); // path not found, meaning TLS is not available on target

  // Zero fill thread storage block
  FillByte(p^, ThreadVarBlockSize, 3);
end;


function SysRelocateThreadVar(Offset: dword): pointer;
var
  p: pointer;
begin
  p := pvTaskGetThreadLocalStoragePointer(nil, DataIndex);
  if p = nil then
  begin
    SysAllocateThreadVars;
    InitThread(DefaultStackSize);
    p := pvTaskGetThreadLocalStoragePointer(nil, DataIndex);
  end;

  SysRelocateThreadVar := p + Offset;
end;


procedure SysInitMultithreading;
begin
  // consider here only the FreeRTOS provided TLS space for now
  //if InterLockedExchange(longint(TLSInitialized),ord(true)) = 0 then
  begin
    begin
      TLSAPISupported := true;
      IsMultiThread := true;
      TLSInitialized := true;

      // 1. Calls init_all_unit_threadvars which
      //    a) Calls init_all_unit_threadvars which calls init_unit_threadvars in a loop which
      //       i) Calls InitThreadvar which returns offset into threadvar block and increment ThreadBlockVarSize with size of variable
      // 2. Calls AllocateThreadVars with the final block size stored in global variable ThreadBlockVarSize
      //    a) Allocate memory for the TLS block
      //    b) Store pointer to TLS data block with vTaskSetThreadLocalStoragePointer
      // 3. Calls copy_all_unit_threadvars which iterates over copy_unit_threadvars which then:
      //    a) Call RelocateThreadVar to get a destination pointer, and which should increment the pointer
      //    b) Call Move to copy data from the original storage to the TLS block
      InitThreadVars(@SysRelocateThreadVar);
    end
  end;
end;


procedure SysFiniMultithreading;
var
 p: pointer;
begin
  if IsMultiThread then
  begin
    if TLSAPISupported then
    begin
      p := pvTaskGetThreadLocalStoragePointer(nil, DataIndex);
      if p <> nil then
        FreeMem(p);
    end
  end;
end;


procedure SysReleaseThreadVars;
var
  p: pointer;
begin
  if TLSAPISupported then
  begin
    p := pvTaskGetThreadLocalStoragePointer(nil, DataIndex);
    if p <> nil then
      FreeMem(p);
  end
  else
    RunError(3);
end;

{*****************************************************************************
                            Thread starting
*****************************************************************************}

type
  pthreadinfo = ^tthreadinfo;
  tthreadinfo = record
    f : tthreadfunc;
    p : pointer;
    stklen : cardinal;
  end;

var
  threadCount: uint32 = 0;

// FreeRTOS tasks are defined as procedure (param: pointer),
// while TThreadFunc is defined as function(parameter : pointer) : ptrint;
procedure ThreadMain(param : pointer);
var
  ti : tthreadinfo;
begin
  { Allocate local thread vars, this must be the first thing,
    because the exception management and io depends on threadvars }
  SysAllocateThreadVars;
  { Copy parameter to local data }
{$ifdef DEBUG_MT}
  writeln('New thread started, initialising ...');
{$endif DEBUG_MT}
  ti := pthreadinfo(param)^;
  dispose(pthreadinfo(param));
  { Initialize thread }
  InitThread(ti.stklen);
  { Start thread function }
{$ifdef DEBUG_MT}
  writeln('Jumping to thread function');
{$endif DEBUG_MT}
  ti.f(ti.p);
  DoneThread;  // Other units don't call DoneThread, but it seems necessary to clean up before deleting task
  vTaskDelete(nil); // Inform FreeRTOS to delete task
end;

// Keep the name short, FreeRTOS defaults to a 16 char length
function fBeginThreadNamed(StackSize: PtrUInt;
  ThreadFunction: TThreadFunc; P: pointer;
  var ThreadId: TThreadID; aname: string): TThreadID;
var
  TI: PThreadInfo;
  RC: cardinal;
begin
{ WriteLn is not a good idea before thread initialization...
  $ifdef DEBUG_MT
  WriteLn ('Creating new thread');
 $endif DEBUG_MT}
{ Initialize multithreading if not done }
  SysInitMultithreading;
{ the only way to pass data to the newly created thread
  in a MT safe way, is to use the heap }
  New(TI);
  TI^.F := ThreadFunction;
  TI^.P := P;
  TI^.StkLen := StackSize;
  ThreadID := 0;
{$ifdef DEBUG_MT}
  WriteLn ('Starting new thread');
{$endif DEBUG_MT}
  RC := xTaskCreate(@ThreadMain,           // pointer to wrapper procedure
                    PChar(@aname[1]),      // task name, cannot yet assign a debug name after task creation
                    StackSize,             // ...
                    TI,                    // Thread info passed as parameter
                    1,                     // Priority, idle task priority is 0, so make this slightly higher
                    @ThreadID);            // Task handle to created task

  if RC = pdTRUE then
    fBeginThreadNamed := ThreadID
  else
  begin
    fBeginThreadNamed := 0;
{$IFDEF DEBUG_MT}
    WriteLn ('Thread creation failed');
{$ENDIF DEBUG_MT}
    Dispose (TI);
    RunError(203); // Only failure value defined is errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY
  end;
end;

function SysBeginThread (SA: pointer; StackSize : PtrUInt;
                         ThreadFunction: TThreadFunc; P: pointer;
                         CreationFlags: dword; var ThreadId: TThreadID): TThreadID;
var
  s: shortstring;
begin
  inc(threadCount);
  Str(threadCount, s);
  insert('fpc-', s, 1);

  SysBeginThread := fBeginThreadNamed(StackSize, ThreadFunction, P, ThreadId, s);
end;

procedure SysEndThread (ExitCode: cardinal);
begin
  DoneThread;
  vTaskDelete(nil); // delete current task
  ExitCode := 0; // TODO: propagate exit code
end;


procedure SysThreadSwitch;
begin
  taskYield;
end;


function SysSuspendThread (ThreadHandle: TThreadID): dword;
begin
  vTaskSuspend(pointer(ThreadHandle));
  SysSuspendThread := 0;
end;


function SysResumeThread (ThreadHandle: TThreadID): dword;
begin
  vTaskResume(pointer(ThreadHandle));
  SysResumeThread := 0;
end;

function SysKillThread (ThreadHandle: TThreadID): dword;
begin
  vTaskDelete(TTaskHandle(ThreadHandle)); // no finesse...
  SysKillThread := 0;
end;

{$PUSH}
{$WARNINGS OFF}
function SysCloseThread (ThreadHandle: TThreadID): dword;
begin
  // ??
end;
{$POP}

function SysWaitForThreadTerminate (ThreadHandle: TThreadID;
                                    TimeoutMs: longint): dword;
begin
  // FreeRTOS doesn't have something like this that I know of.
  // Perhaps can call xTaskNotify, but then the task loop must check for a notification...
  // Or call vTaskGetInfo in a loop and check TTaskStatus - but this is not available for esp-idf
  SysWaitForThreadTerminate := 1;
end;

function SysThreadSetPriority(ThreadHandle: TThreadID; Prio: longint): boolean;
{0..some small positive number, idle priority is 0, most SDK tasks seem to run at level 1}
begin
  if Prio < 0 then
    Prio := 0;
  vTaskPrioritySet(TTaskHandle(ThreadHandle), Prio);
  SysThreadSetPriority := true;
end;


function SysThreadGetPriority(ThreadHandle: TThreadID): longint;
begin
  SysThreadGetPriority := uxTaskPriorityGet(TTaskHandle(ThreadHandle));
end;


function SysGetCurrentThreadID: TThreadID;
begin
  SysGetCurrentThreadID := TThreadID(xTaskGetCurrentTaskHandle);
end;

procedure SysSetThreadDebugNameA(threadHandle: TThreadID; const ThreadName: AnsiString);
begin
  {$Warning SetThreadDebugName needs to be implemented}
  // Name can only be set at task creation time
end;


procedure SysSetThreadDebugNameU(threadHandle: TThreadID; const ThreadName: UnicodeString);
begin
  {$Warning SetThreadDebugName needs to be implemented}
end;


procedure SysInitCriticalSection(var CS);
begin
  TSemaphoreHandle(CS) := xSemaphoreCreateMutex;
  if pointer(CS) = nil then
  begin
    FPC_ThreadError;
  end;
end;

procedure SysDoneCriticalSection(var CS);
begin
  xSemaphoreGiveRecursive(TSemaphoreHandle(CS));
  vSemaphoreDelete(TSemaphoreHandle(CS));
end;

procedure SysEnterCriticalSection(var CS);
var
  RC: cardinal;
begin
  RC := xSemaphoreTake(TSemaphoreHandle(CS), portMAX_DELAY);
  if RC <> pdTRUE then
  begin
    FPC_ThreadError;
  end;
end;

function SysTryEnterCriticalSection(var CS): longint;
begin
  if xSemaphoreTake(TSemaphoreHandle(CS), 0) = pdTRUE then
    SysTryEnterCriticalSection := 1
  else
    SysTryEnterCriticalSection := 0;
end;

procedure SysLeaveCriticalSection(var CS);
var
  RC: cardinal;
begin
  RC := xSemaphoreGive(TSemaphoreHandle(CS));
  if RC <> pdTRUE then
  begin
     FPC_ThreadError;
  end;
end;

type
  TBasicEventState = record
    FHandle: TSemaphoreHandle;
    FLastError: longint;
  end;
  PLocalEventRec = ^TBasicEventState;


//const
//  wrSignaled  = 0;
//  wrTimeout   = 1;
//  wrAbandoned = 2;  (* This cannot happen for an event semaphore with OS/2? *)
//  wrError     = 3;
//  Error_Timeout = 640;
//  OS2SemNamePrefix = '\SEM32\';  // Remain OS2 compatible?

// initialstate = true means semaphore is owned by current thread, others waiting on this will block
function SysBasicEventCreate (EventAttributes: Pointer;
     AManualReset, InitialState: boolean; const Name: ansistring): PEventState;
begin
  New(PLocalEventRec(SysBasicEventCreate));
  PLocalEventRec(SysBasicEventCreate)^.FHandle := xSemaphoreCreateMutex;
  if PLocalEventRec(SysBasicEventCreate)^.FHandle = nil then
  begin
    Dispose (PLocalEventRec (SysBasicEventCreate));
    FPC_ThreadError;
  end
  else if InitialState then
    xSemaphoreTake(PLocalEventRec(SysBasicEventCreate)^.FHandle, 0);  // No timeout given because sem is not yet visible elsewhere
end;


procedure SysBasicEventDestroy (State: PEventState);
begin
  if State = nil then
    FPC_ThreadError
  else
    vSemaphoreDelete(PLocalEventRec (State)^.FHandle);
end;


procedure SysBasicEventResetEvent (State: PEventState);
begin
  if State = nil then
    FPC_ThreadError
  else
  begin
    if xSemaphoreGive(PLocalEventRec(State)^.FHandle) <> pdTRUE then
      FPC_ThreadError;
  end;
end;


procedure SysBasicEventSetEvent (State: PEventState);
begin
  //if State = nil then
  //  FPC_ThreadError
  //else
  //begin
  //
  //  RC := DosPostEventSem (PLocalEventRec (State)^.FHandle);
  //  if RC <> 0 then
  //   OSErrorWatch (RC);
  // end;
end;


function SysBasicEventWaitFor (Timeout: Cardinal; State: PEventState): longint;
begin
  //if State = nil then
  // FPC_ThreadError
  //else
  // begin
  //  RC := DosWaitEventSem (PLocalEventRec (State)^.FHandle, Timeout);
  //  case RC of
  //   0: Result := wrSignaled;
  //   Error_Timeout: Result := wrTimeout;
  //  else
  //   begin
  //    Result := wrError;
  //    OSErrorWatch (RC);
  //    PLocalEventRec (State)^.FLastError := RC;
  //   end;
  //  end;
  // end;
end;


function SysRTLEventCreate: PRTLEvent;
begin
  // xSemaphoreCreateBinary returns a pointer
  SysRTLEventCreate := PRTLEvent(xSemaphoreCreateBinary);
  if SysRTLEventCreate = nil then
    FPC_ThreadError;
end;


procedure SysRTLEventDestroy (AEvent: PRTLEvent);
begin
  vSemaphoreDelete(TSemaphoreHandle(AEvent));
end;


procedure SysRTLEventSetEvent (AEvent: PRTLEvent);
begin
  // First obtain semaphore before giving it
  //if xSemaphoreTake(TSemaphoreHandle(AEvent), 10) = pdTRUE then
    xSemaphoreGive(TSemaphoreHandle(AEvent))
  //else
  //  FPC_ThreadError;
end;


procedure SysRTLEventWaitFor (AEvent: PRTLEvent);
begin
  if not (xSemaphoreTake(TSemaphoreHandle(AEvent), portMAX_DELAY) = pdTRUE) then
    FPC_ThreadError;
end;


// Timeout in ms
procedure SysRTLEventWaitForTimeout (AEvent: PRTLEvent; Timeout: longint);
begin
  xSemaphoreTake(TSemaphoreHandle(AEvent), Timeout div portTICK_PERIOD_MS);
end;


procedure SysRTLEventResetEvent (AEvent: PRTLEvent);
begin
  if not (xSemaphoreTake(TSemaphoreHandle(AEvent), 0) = pdTRUE) then
    FPC_ThreadError;
end;


{$DEFINE HAS_GETCPUCOUNT}
function GetCPUCount: LongWord;
begin
  // FreeRTOS doesn't have a GetCPUCount equivalent...
  {$ifdef FPC_MCU_ESP32}
  GetCPUCount := 2;
  {$else}
  GetCPUCount := 1;
  {$endif}
end;


procedure InitSystemThreads;
begin
  //esp_log_write(ESP_LOG_INFO, '', 'SysRelocateThreadVar: %x', @SysRelocateThreadVar);
  with FreeRTOSThreadManager do
  begin
    InitManager            :=Nil;
    DoneManager            :=Nil;
    BeginThread            := @SysBeginThread;
    EndThread              := @SysEndThread;
    SuspendThread          := @SysSuspendThread;
    ResumeThread           := @SysResumeThread;
    KillThread             := @SysKillThread;
    CloseThread            := @SysCloseThread;
    ThreadSwitch           := @SysThreadSwitch;
    WaitForThreadTerminate := @SysWaitForThreadTerminate;
    ThreadSetPriority      := @SysThreadSetPriority;
    ThreadGetPriority      := @SysThreadGetPriority;
    GetCurrentThreadId     := @SysGetCurrentThreadId;
    SetThreadDebugNameA    := @SysSetThreadDebugNameA;
    {$ifdef FPC_HAS_FEATURE_UNICODESTRINGS}
    SetThreadDebugNameU    := @SysSetThreadDebugNameU;
    {$endif FPC_HAS_FEATURE_UNICODESTRINGS}
    InitCriticalSection    := @SysInitCriticalSection;
    DoneCriticalSection    := @SysDoneCriticalSection;
    EnterCriticalSection   := @SysEnterCriticalSection;
    TryEnterCriticalSection:= @SysTryEnterCriticalSection;
    LeaveCriticalSection   := @SysLeaveCriticalSection;
    InitThreadVar          := @SysInitThreadVar;
    RelocateThreadVar      := @SysRelocateThreadVar;
    AllocateThreadVars     := @SysAllocateThreadVars;
    ReleaseThreadVars      := @SysReleaseThreadVars;
    BasicEventCreate       :=nil;//@SysBasicEventCreate;
    BasicEventDestroy      :=nil;//@SysBasicEventDestroy;
    BasicEventSetEvent     :=nil;//@SysBasicEventSetEvent;
    BasicEventResetEvent   :=nil;//@SysBasicEventResetEvent;
    BasiceventWaitFor      :=nil;//@SysBasiceventWaitFor;
    RTLEventCreate         := @SysRTLEventCreate;
    RTLEventDestroy        := @SysRTLEventDestroy;
    RTLEventSetEvent       := @SysRTLEventSetEvent;
    RTLEventResetEvent     := @SysRTLEventResetEvent;
    RTLEventWaitFor        := @SysRTLEventWaitFor;
    RTLEventWaitForTimeout := @SysRTLEventWaitForTimeout;
  end;
  SetThreadManager(FreeRTOSThreadManager);
end;

initialization
  if ThreadingAlreadyUsed then
    begin
      writeln('Threading has been used before cthreads was initialized.');
      writeln('Make cthreads one of the first units in your uses clause.');
      runerror(211);
    end;
  InitSystemThreads;

finalization

end.
