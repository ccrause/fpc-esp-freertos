unit task;

{$include freertosconfig.inc}

interface

uses
  portmacro, portable, list;

const
  tskKERNEL_VERSION_NUMBER  = 'V8.2.0';
  tskKERNEL_VERSION_MAJOR   = 8;
  tskKERNEL_VERSION_MINOR   = 2;
  tskKERNEL_VERSION_BUILD   = 0;
  tskNO_AFFINITY            = $7FFFFFFF; //2147483647;//INT_MAX

type
  TTaskHandle = pointer;
  PTaskHandle = ^TTaskHandle;
  TTaskHookFunction = function(para: pointer): TBaseType;
  PTickType = TTickType;
  PUBaseType = ^TUBaseType;

  TeTaskState = (eRunning = 0, eReady, eBlocked, eSuspended,
	  eDeleted);

  TeNotifyAction = (eNoAction = 0, eSetBits, eIncrement, eSetValueWithOverwrite,
    eSetValueWithoutOverwrite);

  TTimeOut = record
  	xOverflowCount: TBaseType;
	  xTimeOnEntering: TTickType;
  end;
  PTimeOut = ^TTimeOut;

//struct xMEMORY_REGION
  TMemoryRegion = record
	  pvBaseAddress: pointer;
	  ulLengthInBytes,
	  ulParameters: uint32;
  end;
  PMemoryRegion = ^TMemoryRegion;

//struct xTASK_PARAMETERS
  TTaskParameters = record
	  pvTaskCode: TTaskFunction;
	  pcName: PChar;
	  usStackDepth: uint32;
	  pvParameters: pointer;
	  uxPriority: TUBaseType;
	  puxStackBuffer: PStackType;
	  xRegions: array[0..portNUM_CONFIGURABLE_REGIONS-1] of TMemoryRegion;
  end;

//struct xTASK_STATUS
  TTaskStatus = record
	  xHandle: TTaskHandle;
	  pcTaskName: PChar;
	  xTaskNumber: TUBaseType;
	  eCurrentState: TeTaskState;
	  uxCurrentPriority: TUBaseType;
	  uxBasePriority: TUBaseType;
	  ulRunTimeCounter: uint32;
	  pxStackBase: PStackType;
	  usStackHighWaterMark: uint32;
{$ifdef configTASKLIST_INCLUDE_COREID}
	  xCoreID: TBaseType;
{$endif}
  end;
  PTaskStatus = ^TTaskStatus;

//typedef struct xTASK_SNAPSHOT
  TTaskSnapshot = record
	  pxTCB: pointer;
	  pxTopOfStack: PStackType;
	  pxEndOfStack: PStackType;
  end;
  PTaskSnapshot = ^TTaskSnapshot;

  TeSleepModeStatus = (eAbortSleep = 0, eStandardSleep, eNoTasksWaitingTimeout);

const
  tskIDLE_PRIORITY			= 0;

procedure taskYIELD; inline;

{$ifdef _ESP_FREERTOS_INTERNAL}
procedure taskENTER_CRITICAL(mux: PportMUX_TYPE); inline;		portENTER_CRITICAL(mux)
{$else}
{$warning 'taskENTER_CRITICAL(mux) is deprecated in ESP-IDF, consider using "portENTER_CRITICAL(mux)"'}
procedure  taskENTER_CRITICAL(mux: PportMUX_TYPE); inline;
{$endif}
procedure taskENTER_CRITICAL_ISR(mux: PportMUX_TYPE); inline;

{$ifdef _ESP_FREERTOS_INTERNAL}
procedure taskEXIT_CRITICAL(mux: PportMUX_TYPE); inline;
{$else}
{$warning 'taskEXIT_CRITICAL(mux) is deprecated in ESP-IDF, consider using "portEXIT_CRITICAL(mux)"'}
procedure taskEXIT_CRITICAL(mux: PportMUX_TYPE); inline;
{$endif}
procedure taskEXIT_CRITICAL_ISR(mux: PportMUX_TYPE); inline;
procedure taskDISABLE_INTERRUPTS(); inline;
procedure taskENABLE_INTERRUPTS(); inline;

const
  taskSCHEDULER_SUSPENDED		 = 0;
  taskSCHEDULER_NOT_STARTED	 = 1;
  taskSCHEDULER_RUNNING		   = 2;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
  function xTaskCreatePinnedToCore(pvTaskCode: TTaskFunction;
										pcName: PChar; const usStackDepth: uint32;
										pvParameters: pointer;
										uxPriority: TUBaseType;
										pvCreatedTask: PTaskHandle;
										xCoreID: TBaseType): TBaseType; external;
{$endif}

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
function xTaskCreate(
			pvTaskCode: TTaskFunction;
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

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
function xTaskCreateStatic(
			pvTaskCode: TTaskFunction;
			pcName: PChar;
			const ulStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType;
			pxStackBuffer: PStackType;
			pxTaskBuffer: PStaticTask): TTaskHandle; inline; // IRAM_ATTR
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS =  1)}
function xTaskCreateRestricted(pxTaskDefinition: PTaskParameters; pxCreatedTask: PTaskHandle): TBaseType; external;
{$endif}

procedure vTaskAllocateMPURegions(xTask: TTaskHandle; pxRegions: PMemoryRegion); external;
procedure vTaskDelete(xTaskToDelete: TTaskHandle); external;
procedure vTaskDelay(xTicksToDelay: TTickType); external;

procedure vTaskDelayUntil(pxPreviousWakeTime: PTickType; xTimeIncrement: TTickType); external;
function uxTaskPriorityGet(xTask: TTaskHandle): TUBaseType; external;
function uxTaskPriorityGetFromISR(xTask:TTaskHandle): TUBaseType; external;
function eTaskGetState(xTask: TTaskHandle): TeTaskState; external;
procedure vTaskPrioritySet(xTask: TTaskHandle; uxNewPriority: TUBaseType); external;
procedure vTaskSuspend(xTaskToSuspend: TTaskHandle); external;
procedure vTaskResume(xTaskToResume: TTaskHandle); external;
function  xTaskResumeFromISR(xTaskToResume: TTaskHandle): TBaseType; external;
procedure vTaskStartScheduler; external;
procedure vTaskEndScheduler; external;
procedure vTaskSuspendAll; external;
function xTaskResumeAll: TBaseType; external;
function xTaskGetTickCount: TTickType; external;
function xTaskGetTickCountFromISR: TTickType; external;
function uxTaskGetNumberOfTasks: TUBaseType; external;
function pcTaskGetTaskName(xTaskToQuery: TTaskHandle): PChar; external;
function uxTaskGetStackHighWaterMark(xTask: TTaskHandle): TUBaseType; external;
function pxTaskGetStackStart(xTask: TTaskHandle): PByte; external;

(* When using trace macros it is sometimes necessary to include task.h before
FreeRTOS.h.  When this is done TaskHookFunction_t will not yet have been defined,
so the following two prototypes will cause a compilation error.  This can be
fixed by simply guarding against the inclusion of these two prototypes unless
they are explicitly required by the configUSE_APPLICATION_TASK_TAG configuration
constant. *)
{$ifdef configUSE_APPLICATION_TASK_TAG}
	{$if configUSE_APPLICATION_TASK_TAG =  1}
		procedure vTaskSetApplicationTaskTag(xTask: TTaskHandle; pxHookFunction: TTaskHookFunction); external;

		function xTaskGetApplicationTaskTag(xTask: TTaskHandle): TTaskHookFunction; external;
	{$endif} (* configUSE_APPLICATION_TASK_TAG = 1 *)
{$endif} (* ifdef configUSE_APPLICATION_TASK_TAG *)
{$if defined(configNUM_THREAD_LOCAL_STORAGE_POINTERS) and (configNUM_THREAD_LOCAL_STORAGE_POINTERS > 0 )}
	procedure vTaskSetThreadLocalStoragePointer(xTaskToSet: TTaskHandle; xIndex: TBaseType; pvValue: pointer); external;
	function pvTaskGetThreadLocalStoragePointer(xTaskToQuery: TTaskHandle; xIndex: TBaseType): pointer; external;

	{$ifdef configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS}
		type
      TTlsDeleteCallbackFunction = procedure (para1: int32; para2: pointer);

		procedure vTaskSetThreadLocalStoragePointerAndDelCallback(xTaskToSet: TTaskHandle;
          xIndex: TBaseType; pvValue: pointer; pvDelCallback: TTlsDeleteCallbackFunction); external;
	{$endif}
{$endif}

function xTaskCallApplicationTaskHook(xTask: TTaskHandle; pvParameter: pointer): TBaseType; external;
function xTaskGetIdleTaskHandle: TTaskHandle; external;
function xTaskGetIdleTaskHandleForCPU(cpuid: TUBaseType): TTaskHandle; external;
function uxTaskGetSystemState(pxTaskStatusArray: PTaskStatus;
      uxArraySize: TUBaseType; pulTotalRunTime: PUint32): TUBaseType; external;
procedure vTaskList(pcWriteBuffer: PChar); external;
procedure vTaskGetRunTimeStats(pcWriteBuffer: PChar); external;
function xTaskNotify(xTaskToNotify: TTaskHandle; ulValue: uint32; eAction: TeNotifyAction): TBaseType; external;
function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle; ulValue: uint32;
      eAction: TeNotifyAction; pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;
function xTaskNotifyWait(ulBitsToClearOnEntry, ulBitsToClearOnExit: uint32;
      pulNotificationValue: PUint32; xTicksToWait: TTickType): TBaseType; external;

function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType; inline;

procedure vTaskNotifyGiveFromISR(xTaskToNotify: TTaskHandle; pxHigherPriorityTaskWoken: PBaseType); external;
function ulTaskNotifyTake(xClearCountOnExit: TBaseType; xTicksToWait: TTickType): uint32; external;
function xTaskIncrementTick: TBaseType; external;
procedure vTaskPlaceOnEventList(pxEventList: PList; xTicksToWait: TTickType); external;
procedure vTaskPlaceOnUnorderedEventList(pxEventList: PList; xItemValue: TTickType; xTicksToWait: TTickType); external;
procedure vTaskPlaceOnEventListRestricted(pxEventList: PList; xTicksToWait: TTickType); external;
function xTaskRemoveFromEventList(pxEventList: PList): TBaseType; external;
function xTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem; xItemValue: TTickType): TBaseType; external;
procedure vTaskSwitchContext; external;
function uxTaskResetEventItemValue: TTickType; external;
function xTaskGetCurrentTaskHandle: TTaskHandle; external;
function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType): TTaskHandle; external;
procedure vTaskSetTimeOutState(pxTimeOut: PTimeOut); external;
function xTaskCheckForTimeOut(pxTimeOut: PTimeOut; pxTicksToWait: PTickType): TBaseType; external;
procedure vTaskMissedYield; external;
function xTaskGetSchedulerState: TBaseType; external;
procedure vTaskPriorityInherit(pxMutexHolder: TTaskHandle); external;
function xTaskPriorityDisinherit(pxMutexHolder: TTaskHandle): TBaseType; external;
function uxTaskGetTaskNumber(xTask: TTaskHandle): TUBaseType; external;
function xTaskGetAffinity(xTask: TTaskHandle): TBaseType; external;
procedure vTaskSetTaskNumber(xTask: TTaskHandle; uxHandle: TUBaseType); external;
procedure vTaskStepTick(xTicksToJump: TTickType); external;
function eTaskConfirmSleepModeStatus: TeSleepModeStatus; external;
function pvTaskIncrementMutexHeldCount: pointer; external;
function uxTaskGetSnapshotAll(pxTaskSnapshotArray: PTaskSnapshot;
      uxArraySize: TUBaseType; pxTcbSz: PUBaseType): TUBaseType; external;

implementation

procedure taskYIELD;
begin
  portYIELD;
end;

procedure taskENTER_CRITICAL(mux: PportMUX_TYPE);
begin
  portENTER_CRITICAL(mux);
end;

procedure taskENTER_CRITICAL_ISR(mux: PportMUX_TYPE);
begin
  portENTER_CRITICAL_ISR(mux);
end;

procedure taskEXIT_CRITICAL(mux: PportMUX_TYPE);
begin
  portEXIT_CRITICAL(mux);
end;

procedure taskEXIT_CRITICAL_ISR(mux: PportMUX_TYPE);
begin
  portEXIT_CRITICAL_ISR(mux);
end;

procedure taskDISABLE_INTERRUPTS();
begin
  portDISABLE_INTERRUPTS();
end;

procedure taskENABLE_INTERRUPTS();
begin
  portENABLE_INTERRUPTS();
end;

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

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
function xTaskCreateStatic(
			pvTaskCode: TTaskFunction;
			pcName: PChar;
			const ulStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType;
			pxStackBuffer: PStackType;
			pxTaskBuffer: PStaticTask): TTaskHandle;
begin
  xTaskCreateStatic :=
    xTaskCreateStaticPinnedToCore(pvTaskCode, pcName, ulStackDepth,
      pvParameters, uxPriority, pxStackBuffer, pxTaskBuffer, tskNO_AFFINITY);
end;
{$endif}

function xTaskNotifyGive(xTaskToNotify: TTaskHandle): TBaseType;
begin
  xTaskNotifyGive := xTaskNotify(xTaskToNotify, 0, eIncrement);
end;

end.

