unit task;

{$include freertosconfig.inc}

interface

uses
  projdefs, portmacro, portable, list;

const
  // ESP8266_RTOS_SDK V3.4 sits at V10.0
  tskKERNEL_VERSION_NUMBER = 'V10.2.1';
  tskKERNEL_VERSION_MAJOR = 10;
  tskKERNEL_VERSION_MINOR = 2;
  tskKERNEL_VERSION_BUILD = 1;

type
  TTaskHookFunction = function(para1: pointer): TBaseType;

  PeTaskState = ^TeTaskState;
  TeTaskState = (eRunning = 0, eReady, eBlocked, eSuspended,
    eDeleted, eInvalid);

  PeNotifyAction = ^TeNotifyAction;
  TeNotifyAction = (eNoAction = 0, eSetBits, eIncrement, eSetValueWithOverwrite,
    eSetValueWithoutOverwrite);

  TTimeOut = record
    xOverflowCount: TBaseType;
    xTimeOnEntering: TTickType;
  end;
  PTimeOut = ^TTimeOut;

  TMemoryRegion = record
    pvBaseAddress: pointer;
    ulLengthInBytes: uint32;
    ulParameters: uint32;
  end;
  PMemoryRegion = ^TMemoryRegion;

  TTaskParameters = record
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
  PTaskParameters = ^TTaskParameters;

  TTaskStatus = record
    xHandle: TTaskHandle;
    pcTaskName: PChar;
    xTaskNumber: TUBaseType;
    eCurrentState: TeTaskState;
    uxCurrentPriority: TUBaseType;
    uxBasePriority: TUBaseType;
    ulRunTimeCounter: uint32;
    pxStackBase: PStackType;
    usStackHighWaterMark: uint16;
    {$if defined(configTASKLIST_INCLUDE_COREID)}
    	xCoreID: TBaseType;
    {$endif}
  end;
  PTaskStatus = ^TTaskStatus;

  PeSleepModeStatus = ^TeSleepModeStatus;
  TeSleepModeStatus = (eAbortSleep = 0, eStandardSleep, eNoTasksWaitingTimeout);

   TTaskSnapshot = record
    pxTCB: pointer;
    pxTopOfStack: PStackType;
    pxEndOfStack: PStackType;
  end;
  PTaskSnapshot = ^TTaskSnapshot;

const
  tskIDLE_PRIORITY = 0;
  tskNO_AFFINITY = $7FFFFFFF; //CONFIG_FREERTOS_NO_AFFINITY, define for compatibility with ESP32 (SMP) code
  taskSCHEDULER_SUSPENDED = TBaseType(0);
  taskSCHEDULER_NOT_STARTED = TBaseType(1);
  taskSCHEDULER_RUNNING = TBaseType(2);

procedure taskYIELD; external name 'portYIELD';
function taskENTER_CRITICAL_FROM_ISR: uint32; inline;
procedure taskDISABLE_INTERRUPTS; inline;
procedure taskENABLE_INTERRUPTS; inline;
procedure vTaskAllocateMPURegions(xTask: TTaskHandle; pxRegions: PMemoryRegion); external;
procedure vTaskDelete(xTaskToDelete: TTaskHandle); external;
procedure vTaskDelay(xTicksToDelay: TTickType); external;
procedure vTaskDelayUntil(pxPreviousWakeTime: PTickType; xTimeIncrement: TTickType); external;
function uxTaskPriorityGet(xTask: TTaskHandle): TUBaseType; external;
function uxTaskPriorityGetFromISR(xTask: TTaskHandle): TUBaseType; external;
function eTaskGetState(xTask: TTaskHandle): TeTaskState; external;
procedure vTaskPrioritySet(xTask: TTaskHandle; uxNewPriority: TUBaseType); external;
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
function uxTaskGetStackHighWaterMark(xTask: TTaskHandle): TUBaseType; external;
function xTaskCallApplicationTaskHook(xTask: TTaskHandle; pvParameter: pointer): TBaseType; external;
function xTaskGetIdleTaskHandle: TTaskHandle; external;
function uxTaskGetSystemState(pxTaskStatusArray: PTaskStatus;
  uxArraySize: TUBaseType; pulTotalRunTime: Puint32): TUBaseType; external;
procedure vTaskList(pcWriteBuffer: PChar); external;
procedure vTaskGetRunTimeStats(pcWriteBuffer: PChar); external;
function xTaskNotifyWait(ulBitsToClearOnEntry, ulBitsToClearOnExit: uint32;
  pulNotificationValue: PUInt32; xTicksToWait: TTickType): TBaseType; external;
function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType; inline;
procedure vTaskNotifyGiveFromISR(xTaskToNotify: TTaskHandle; pxHigherPriorityTaskWoken: PBaseType); external;
function ulTaskNotifyTake(xClearCountOnExit: TBaseType; xTicksToWait: TTickType): uint32; external;
function xTaskIncrementTick: TBaseType; external;
procedure vTaskPlaceOnEventList(pxEventList: PList; xTicksToWait: TTickType); external;
procedure vTaskPlaceOnUnorderedEventList(pxEventList: PList; xItemValue: TTickType; xTicksToWait: TTickType); external;
function xTaskRemoveFromEventList(pxEventList: PList): TBaseType; external;
procedure vTaskSwitchContext; external;
function uxTaskResetEventItemValue: TTickType; external;
function xTaskGetCurrentTaskHandle: TTaskHandle; external;
procedure vTaskSetTimeOutState(pxTimeOut: PTimeOut); external;
function xTaskCheckForTimeOut(pxTimeOut: PTimeOut; pxTicksToWait: PTickType): TBaseType; external;
procedure vTaskMissedYield; external;
function xTaskGetSchedulerState: TBaseType; external;
function xTaskPriorityDisinherit(pxMutexHolder: TTaskHandle): TBaseType; external;
function uxTaskGetTaskNumber(xTask: TTaskHandle): TUBaseType; external;
procedure vTaskSetTaskNumber(xTask: TTaskHandle; uxHandle: TUBaseType); external;
procedure vTaskStepTick(xTicksToJump: TTickType); external;
function eTaskConfirmSleepModeStatus: TeSleepModeStatus; external;
function pvTaskIncrementMutexHeldCount: pointer; external;
function uxTaskGetSnapshotAll(pxTaskSnapshotArray: PTaskSnapshot;
  uxArraySize: TUBaseType; pxTcbSz: PUBaseType): TUBaseType; external;

{$if portNUM_PROCESSORS > 1}
  function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType): TTaskHandle; external;
  function xTaskGetIdleTaskHandleForCPU(cpuid: TUBaseType): TTaskHandle; external;
  procedure taskENTER_CRITICAL(mux: PportMUX_TYPE); external name 'portENTER_CRITICAL';
  procedure taskEXIT_CRITICAL(mux: PportMUX_TYPE); external name 'portEXIT_CRITICAL';

  {$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
    function xTaskCreatePinnedToCore(pvTaskCode: TTaskFunction;
      pcName: PChar; const usStackDepth: uint32;
		  pvParameters: pointer;
		  uxPriority: TUBaseType;
		  pvCreatedTask: PTaskHandle;
		  xCoreID: TBaseType): TBaseType; external;

    function xTaskCreate(pvTaskCode: TTaskFunction;
      pcName: PChar;
		  const usStackDepth: uint32;
		  pvParameters: pointer;
		  uxPriority: TUBaseType;
		  pvCreatedTask: PTaskHandle): TBaseType; inline; // IRAM_ATTR
  {$endif}

  {$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
    function xTaskCreateStaticPinnedToCore(pvTaskCode: TTaskFunction;
	    pcName: PChar;
	    const ulStackDepth: uint32;
	    pvParameters: pointer;
	    uxPriority: TUBaseType;
	    pxStackBuffer: PStackType;
	    pxTaskBuffer: PStaticTask;
	    const xCoreID: TBaseType): TTaskHandle; external;
  {$endif}
{$else portNUM_PROCESSORS}  // unicore implementations
  // Not really necessary, but defined for compatibility between SMP & unicore
  function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType): TTaskHandle; inline;
  procedure taskENTER_CRITICAL; external name 'portENTER_CRITICAL';
  procedure taskEXIT_CRITICAL; external name 'portEXIT_CRITICAL';

  {$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
    function xTaskCreate(pxTaskCode: TTaskFunction; pcName: PChar;
      usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
      uxPriority: TUBaseType; pxCreatedTask: PTaskHandle): TBaseType;
      external;

    function xTaskCreatePinnedToCore(pxTaskCode: TTaskFunction; pcName: PChar;
      usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
      uxPriority: TUBaseType; pxCreatedTask: PTaskHandle; xCoreID: TBaseType): TBaseType;
  {$endif}

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
{$endif portNUM_PROCESSORS}


function pcTaskGetName(xTaskToQuery: TTaskHandle): PChar; external;
function xTaskGetHandle(pcNameToQuery: PChar): TTaskHandle; external;
function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle; ulValue: uint32;
  eAction: TeNotifyAction; pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
function xTaskNotify(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction): TBaseType; inline;
function xTaskAbortDelay(xTask: TTaskHandle): TBaseType; external;
procedure vTaskGetInfo(xTask: TTaskHandle; pxTaskStatus: PTaskStatus;
  xGetFreeStackSpace: TBaseType; eState: TeTaskState); external;
function xTaskGenericNotify(xTaskToNotify: TTaskHandle; ulValue: uint32;
  eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32): TBaseType; external;
function xTaskNotifyAndQuery(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction;
  pulPreviousNotifyValue: puint32): TBaseType; inline;
function xTaskGenericNotifyFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;
function xTaskNotifyAndQueryFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
function xTaskNotifyStateClear(xTask: TTaskHandle): TBaseType; external;
procedure vTaskPlaceOnEventListRestricted(pxEventList: PList; xTicksToWait: TTickType; xWaitIndefinitely: TBaseType); external;
function xTaskPriorityInherit(pxMutexHolder: TTaskHandle): TBaseType; external;
procedure vTaskPriorityDisinheritAfterTimeout(pxMutexHolder: TTaskHandle;
  uxHighestPriorityWaitingTask: TUBaseType); external;
procedure vTaskInternalSetTimeOutState(pxTimeOut: PTimeOut); external;

{$if defined(FPC_MCU_ESP32) or defined(FPC_MCU_ESP32S2)}
  function pxTaskGetStackStart(xTask: TTaskHandle): PByte; external;
  function xTaskGetAffinity(xTask: TTaskHandle): TBaseType; external;
  function xTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem; xItemValue: TTickType): TBaseType; external;
{$else neither ESP32 nor ESP32S2}
  procedure vTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem; xItemValue: TTickType); external;
{$endif}

// Functionality dependent on configuration options

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

implementation

{$if portNUM_PROCESSORS > 1}
  {$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
    function xTaskCreate(
		      pvTaskCode: TTaskFunction;
		      pcName: PChar;
		      const usStackDepth: uint32;
		      pvParameters: pointer;
		      uxPriority: TUBaseType;
		      pvCreatedTask: PTaskHandle): TBaseType;
    begin
      xTaskCreate :=
        xTaskCreatePinnedToCore(pvTaskCode, pcName, usStackDepth, pvParameters,
          uxPriority, pvCreatedTask, tskNO_AFFINITY);
    end;
  {$endif}
{$else portNUM_PROCESSORS}
  {$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
    function xTaskCreatePinnedToCore(pxTaskCode: TTaskFunction; pcName: PChar;
      usStackDepth: configSTACK_DEPTH_TYPE; pvParameters: pointer;
      uxPriority: TUBaseType; pxCreatedTask: PTaskHandle; xCoreID: TBaseType): TBaseType;
    begin
      xTaskCreatePinnedToCore := xTaskCreate(pxTaskCode, pcName, usStackDepth,
        pvParameters, uxPriority, pxCreatedTask);
    end;
  {$endif}

  function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType): TTaskHandle;
  begin
    xTaskGetCurrentTaskHandleForCPU := xTaskGetCurrentTaskHandle;
  end;
{$endif portNUM_PROCESSORS}

function taskENTER_CRITICAL_FROM_ISR: uint32;
begin
  taskENTER_CRITICAL_FROM_ISR := portSET_INTERRUPT_MASK_FROM_ISR;
end;

procedure taskEXIT_CRITICAL_FROM_ISR(state: uint32);
begin
  portCLEAR_INTERRUPT_MASK_FROM_ISR(state);
end;

procedure taskDISABLE_INTERRUPTS;
begin
  portDISABLE_INTERRUPTS;
end;

procedure taskENABLE_INTERRUPTS;
begin
  portENABLE_INTERRUPTS;
end;

function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle; ulValue: uint32;
  eAction: TeNotifyAction; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTaskNotifyFromISR := xTaskGenericNotifyFromISR(xTaskToNotify,
    ulValue, eAction, nil, pxHigherPriorityTaskWoken);
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

function xTaskNotifyAndQueryFromISR(xTaskToNotify: TTaskHandle;
  ulValue: uint32; eAction: TeNotifyAction; pulPreviousNotificationValue: Puint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTaskNotifyAndQueryFromISR :=
    xTaskGenericNotifyFromISR(xTaskToNotify, ulValue, eAction,
    pulPreviousNotificationValue, pxHigherPriorityTaskWoken);
end;

{$if defined(FPC_MCU_ESP32) or defined(FPC_MCU_ESP32S2)}
  function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType;
  begin
    xTaskNotifyGive := xTaskNotify(xTaskToNotify, 0, eIncrement);
  end;
{$else}
  function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType;
  begin
    xTaskNotifyGive := xTaskGenericNotify(xTaskToNotify, 0, eIncrement, nil);
  end;
{$endif}

end.
