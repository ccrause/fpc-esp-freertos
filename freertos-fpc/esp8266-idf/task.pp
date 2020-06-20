unit task;

{$include freertosconfig.inc}

interface

uses
  projdefs, portmacro, portable, list;

const
  tskKERNEL_VERSION_NUMBER = 'V10.0.1';
  tskKERNEL_VERSION_MAJOR = 10;
  tskKERNEL_VERSION_MINOR = 0;
  tskKERNEL_VERSION_BUILD = 1;

type
  //PTaskHandle = ^TTaskHandle;
  //TTaskHandle = pointer;
  //TBaseType = int32;
  TUBaseType = uint32;
  // Moved here from freertos
  {$ifndef configSTACK_DEPTH_TYPE}
    configSTACK_DEPTH_TYPE = uint16;
  {$endif}

  TTaskHookFunction = function(para1: pointer): TBaseType;

  PeTaskState = ^TeTaskState;
  TeTaskState = (eRunning = 0, eReady, eBlocked, eSuspended,
    eDeleted, eInvalid);

  PeNotifyAction = ^TeNotifyAction;
  TeNotifyAction = (eNoAction = 0, eSetBits, eIncrement, eSetValueWithOverwrite,
    eSetValueWithoutOverwrite);

  PxTIME_OUT = ^TxTIME_OUT;

  TxTIME_OUT = record
    xOverflowCount: TBaseType;
    xTimeOnEntering: TTickType;
  end;
  TTimeOut = TxTIME_OUT;
  PTimeOut = ^TTimeOut;

  PxMEMORY_REGION = ^TxMEMORY_REGION;
  TxMEMORY_REGION = record
    pvBaseAddress: pointer;
    ulLengthInBytes: uint32;
    ulParameters: uint32;
  end;
  TMemoryRegion = TxMEMORY_REGION;
  PMemoryRegion = ^TMemoryRegion;

type
  PxTASK_PARAMETERS = ^TxTASK_PARAMETERS;
  TxTASK_PARAMETERS = record
    pvTaskCode: TTaskFunction;
    pcName: PChar;
    usStackDepth: uint32;
    pvParameters: pointer;
    uxPriority: TUBaseType;
    puxStackBuffer: PStackType;
    xRegions: array[0..(portNUM_CONFIGURABLE_REGIONS) - 1] of TMemoryRegion;
    {$if defined(portUSING_MPU_WRAPPERS) and defined(configSUPPORT_STATIC_ALLOCATION) and
         (portUSING_MPU_WRAPPERS = 1) and (configSUPPORT_STATIC_ALLOCATION = 1))}
    pxTaskBuffer: PStaticTask;
    {$endif}
  end;
  TTaskParameters = TxTASK_PARAMETERS;
  PTaskParameters = ^TTaskParameters;

  PxTASK_STATUS = ^TxTASK_STATUS;
  TxTASK_STATUS = record
    xHandle: TTaskHandle;
    pcTaskName: PChar;
    xTaskNumber: TUBaseType;
    eCurrentState: TeTaskState;
    uxCurrentPriority: TUBaseType;
    uxBasePriority: TUBaseType;
    ulRunTimeCounter: uint32;
    pxStackBase: PStackType;
    usStackHighWaterMark: uint16;
  end;
  TTaskStatus = TxTASK_STATUS;
  PTaskStatus = ^TTaskStatus;

  PeSleepModeStatus = ^TeSleepModeStatus;
  TeSleepModeStatus = (eAbortSleep = 0, eStandardSleep, eNoTasksWaitingTimeout);

const
  tskIDLE_PRIORITY = 0;
  tskNO_AFFINITY = $7FFFFFFF; //CONFIG_FREERTOS_NO_AFFINITY, not used in ESP8266, define for compatibility with ESP32 code

procedure taskYIELD; inline;
procedure taskENTER_CRITICAL; inline;

function taskENTER_CRITICAL_FROM_ISR: longint;
procedure taskEXIT_CRITICAL;
function taskEXIT_CRITICAL_FROM_ISR(x: longint): pointer;
procedure taskDISABLE_INTERRUPTS;
procedure taskENABLE_INTERRUPTS;

function taskSCHEDULER_SUSPENDED: TBaseType;

function taskSCHEDULER_NOT_STARTED: TBaseType;

function taskSCHEDULER_RUNNING: TBaseType;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function xTaskCreate(pxTaskCode: TTaskFunction; pcName: PChar;
  usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
  uxPriority: TUBaseType; pxCreatedTask: PTaskHandle): TBaseType;
  external;
{$endif}

function xTaskCreatePinnedToCore(pxTaskCode: TTaskFunction; pcName: PChar;
  usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
  uxPriority: TUBaseType; pxCreatedTask: PTaskHandle; xCoreID: TBaseType): TBaseType;

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
function xTaskCreateStatic(pxTaskCode: TTaskFunction; pcName: PChar;
  ulStackDepth: uint32; pvParameters: pointer; uxPriority: TUBaseType;
  puxStackBuffer: PStackType; pxTaskBuffer: PStaticTask): TTaskHandle;
  external;
{$endif}


{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
function xTaskCreateRestricted(pxTaskDefinition: PTaskParameters;
  pxCreatedTask: PTaskHandle): TBaseType; external;
{$endif}

{$if defined(portUSING_MPU_WRAPPERS)and defined(configSUPPORT_STATIC_ALLOCATION) and
     ((portUSING_MPU_WRAPPERS = 1 ) and ( configSUPPORT_STATIC_ALLOCATION = 1))}
function xTaskCreateRestrictedStatic(pxTaskDefinition: PTaskParameters;
  pxCreatedTask: PTaskHandle): TBaseType; external;
{$endif}

procedure vTaskAllocateMPURegions(xTask: TTaskHandle; pxRegions: PMemoryRegion);
  external;

procedure vTaskDelete(xTaskToDelete: TTaskHandle); external;

procedure vTaskDelay(xTicksToDelay: TTickType); external;
procedure vTaskDelayUntil(pxPreviousWakeTime: PTickType; xTimeIncrement: TTickType);
  external;

function xTaskAbortDelay(xTask: TTaskHandle): TBaseType; external;

function uxTaskPriorityGet(xTask: TTaskHandle): TUBaseType; external;

function uxTaskPriorityGetFromISR(xTask: TTaskHandle): TUBaseType; external;

function eTaskGetState(xTask: TTaskHandle): TeTaskState; external;

procedure vTaskGetInfo(xTask: TTaskHandle; pxTaskStatus: PTaskStatus;
  xGetFreeStackSpace: TBaseType; eState: TeTaskState); external;

procedure vTaskPrioritySet(xTask: TTaskHandle; uxNewPriority: TUBaseType);
  external;

procedure vTaskSuspend(xTaskToSuspend: TTaskHandle); external;

procedure vTaskResume(xTaskToResume: TTaskHandle); external;

function xTaskResumeFromISR(xTaskToResume: TTaskHandle): TBaseType; external;


procedure vTaskStartScheduler; external;

procedure vTaskEndScheduler; external;

procedure vTaskSuspendAll; external;

function xTaskResumeAll: TBaseType; external;


function xTaskGetTickCount: TTickType; external;

function xTaskGetTickCountFromISR: TTickType; external;

function uxTaskGetNumberOfTasks: TUBaseType; external;

function pcTaskGetName(xTaskToQuery: TTaskHandle): PChar; external;



function xTaskGetHandle(pcNameToQuery: PChar): TTaskHandle; external;


function uxTaskGetStackHighWaterMark(xTask: TTaskHandle): TUBaseType;
  external;

{$if defined(configUSE_APPLICATION_TASK_TAG) and (configUSE_APPLICATION_TASK_TAG = 1)}
procedure vTaskSetApplicationTaskTag(xTask: TTaskHandle;
  pxHookFunction: TTaskHookFunction); external;
function xTaskGetApplicationTaskTag(xTask: TTaskHandle): TTaskHookFunction;
  external;
{$endif}

{$if defined(configNUM_THREAD_LOCAL_STORAGE_POINTERS) and (configNUM_THREAD_LOCAL_STORAGE_POINTERS > 0)}
procedure vTaskSetThreadLocalStoragePointer(xTaskToSet: TTaskHandle;
  xIndex: TBaseType; pvValue: pointer); external;
function pvTaskGetThreadLocalStoragePointer(xTaskToQuery: TTaskHandle;
  xIndex: TBaseType): pointer; external;
function pvTaskGetThreadLocalStorageBufferPointer(xTaskToQuery: TTaskHandle;
  xIndex: TBaseType): ppointer; external;

  {$if (configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS)}
  type
    TTlsDeleteCallbackFunction = procedure(para1: longint; para2: pointer);

  procedure vTaskSetThreadLocalStoragePointerAndDelCallback(xTaskToSet: TTaskHandle;
    xIndex: TBaseType; pvValue: pointer; pvDelCallback: TTlsDeleteCallbackFunction);
    external;
  {$endif}
{$endif}


function xTaskCallApplicationTaskHook(xTask: TTaskHandle;
  pvParameter: pointer): TBaseType; external;

function xTaskGetIdleTaskHandle: TTaskHandle; external;
function uxTaskGetSystemState(pxTaskStatusArray: PTaskStatus;
  uxArraySize: TUBaseType; pulTotalRunTime: Puint32): TUBaseType; external;
procedure vTaskList(pcWriteBuffer: PChar); external;
procedure vTaskGetRunTimeStats(pcWriteBuffer: PChar); external;
function xTaskGenericNotify(xTaskToNotify: TTaskHandle; ulValue: uint32;
  eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32): TBaseType;
  external;

function xTaskNotify(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction): TBaseType;
function xTaskNotifyAndQuery(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction;
  pulPreviousNotifyValue: puint32): TBaseType;

function xTaskGenericNotifyFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;

function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;

function xTaskNotifyAndQueryFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;

function xTaskNotifyWait(ulBitsToClearOnEntry: uint32; ulBitsToClearOnExit: uint32;
  pulNotificationValue: Puint32; xTicksToWait: TTickType): TBaseType;
  external;

function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType;

procedure vTaskNotifyGiveFromISR(xTaskToNotify: TTaskHandle;
  pxHigherPriorityTaskWoken: PBaseType); external;
function ulTaskNotifyTake(xClearCountOnExit: TBaseType;
  xTicksToWait: TTickType): uint32; external;
function xTaskNotifyStateClear(xTask: TTaskHandle): TBaseType; external;
function xTaskIncrementTick: TBaseType; external;

procedure vTaskPlaceOnEventList(pxEventList: PList; xTicksToWait: TTickType);
  external;

procedure vTaskPlaceOnUnorderedEventList(pxEventList: PList;
  xItemValue: TTickType; xTicksToWait: TTickType); external;
procedure vTaskPlaceOnEventListRestricted(pxEventList: PList;
  xTicksToWait: TTickType; xWaitIndefinitely: TBaseType); external;
function xTaskRemoveFromEventList(pxEventList: PList): TBaseType; external;
procedure vTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem;
  xItemValue: TTickType); external;
procedure vTaskSwitchContext; external;
function uxTaskResetEventItemValue: TTickType; external;
function xTaskGetCurrentTaskHandle: TTaskHandle; external;
procedure vTaskSetTimeOutState(pxTimeOut: PTimeOut); external;
function xTaskCheckForTimeOut(pxTimeOut: PTimeOut;
  pxTicksToWait: PTickType): TBaseType; external;
procedure vTaskMissedYield; external;
function xTaskGetSchedulerState: TBaseType; external;
function xTaskPriorityInherit(pxMutexHolder: TTaskHandle): TBaseType; external;
function xTaskPriorityDisinherit(pxMutexHolder: TTaskHandle): TBaseType;
  external;
procedure vTaskPriorityDisinheritAfterTimeout(pxMutexHolder: TTaskHandle;
  uxHighestPriorityWaitingTask: TUBaseType); external;
function uxTaskGetTaskNumber(xTask: TTaskHandle): TUBaseType; external;
procedure vTaskSetTaskNumber(xTask: TTaskHandle; uxHandle: TUBaseType);
  external;
procedure vTaskStepTick(xTicksToJump: TTickType); external;
function eTaskConfirmSleepModeStatus: TeSleepModeStatus; external;
function pvTaskIncrementMutexHeldCount: pointer; external;
procedure vTaskInternalSetTimeOutState(pxTimeOut: PTimeOut); external;

type
  PxTASK_SNAPSHOT = ^TxTASK_SNAPSHOT;
  TxTASK_SNAPSHOT = record
    pxTCB: pointer;
    pxTopOfStack: PStackType;
    pxEndOfStack: PStackType;
  end;
  TTaskSnapshot = TxTASK_SNAPSHOT;
  PTaskSnapshot = ^TTaskSnapshot;

function uxTaskGetSnapshotAll(pxTaskSnapshotArray: PTaskSnapshot;
  uxArraySize: TUBaseType; pxTcbSz: PUBaseType): TUBaseType; external;


implementation

function xTaskCreatePinnedToCore(pxTaskCode: TTaskFunction; pcName: PChar;
  usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
  uxPriority: TUBaseType; pxCreatedTask: PTaskHandle; xCoreID: TBaseType): TBaseType;
begin
  xTaskCreate(pxTaskCode, pcName, usStackDepth, pvParameters, uxPriority,
              pxCreatedTask);
end;

procedure taskYIELD;
begin
  portYIELD;
end;

procedure taskENTER_CRITICAL;
begin
  portENTER_CRITICAL;
end;

function taskENTER_CRITICAL_FROM_ISR: longint;
begin
  taskENTER_CRITICAL_FROM_ISR := portSET_INTERRUPT_MASK_FROM_ISR;
end;

procedure taskEXIT_CRITICAL;
begin
  portEXIT_CRITICAL;
end;

function taskEXIT_CRITICAL_FROM_ISR(x: longint): pointer;
begin
  taskEXIT_CRITICAL_FROM_ISR := portCLEAR_INTERRUPT_MASK_FROM_ISR(x);
end;

procedure taskDISABLE_INTERRUPTS;
begin
  portDISABLE_INTERRUPTS;
end;

procedure taskENABLE_INTERRUPTS;
begin
  portENABLE_INTERRUPTS;
end;

function taskSCHEDULER_SUSPENDED: TBaseType;
begin
  taskSCHEDULER_SUSPENDED := TBaseType(0);
end;

function taskSCHEDULER_NOT_STARTED: TBaseType;
begin
  taskSCHEDULER_NOT_STARTED := TBaseType(1);
end;

function taskSCHEDULER_RUNNING: TBaseType;
begin
  taskSCHEDULER_RUNNING := TBaseType(2);
end;

function xTaskNotify(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction): TBaseType;
begin
  xTaskNotify := xTaskGenericNotify(xTaskToNotify, ulValue, eAction, nil);
end;

function xTaskNotifyAndQuery(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction;
  pulPreviousNotifyValue: puint32): TBaseType;
begin
  xTaskNotifyAndQuery := xTaskGenericNotify(xTaskToNotify, ulValue,
    eAction, pulPreviousNotifyValue);
end;

function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTaskNotifyFromISR := xTaskGenericNotifyFromISR(xTaskToNotify,
    ulValue, eAction, nil, pxHigherPriorityTaskWoken);
end;

function xTaskNotifyAndQueryFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTaskNotifyAndQueryFromISR :=
    xTaskGenericNotifyFromISR(xTaskToNotify, ulValue, eAction,
    pulPreviousNotificationValue, pxHigherPriorityTaskWoken);
end;

function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType;
begin
  xTaskNotifyGive := xTaskGenericNotify(xTaskToNotify, 0, eIncrement, nil);
end;

function xTaskGetCurrentTaskHandleForCPU(_cpu: TTaskHandle): pointer;
begin
  xTaskGetCurrentTaskHandleForCPU := xTaskGetCurrentTaskHandle;
end;

end.
