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
  TTaskHandle_t = pointer;
  PTaskHandle_t = ^TTaskHandle_t;
  TTaskHookFunction_t = function(para: pointer): TBaseType_t;
  PTickType_t = TTickType_t;
  PUBaseType_t = ^TUBaseType_t;

  TeTaskState = (eRunning = 0, eReady, eBlocked, eSuspended,
	  eDeleted);

  TeNotifyAction = (eNoAction = 0, eSetBits, eIncrement, eSetValueWithOverwrite,
    eSetValueWithoutOverwrite);

  TTimeOut_t = record
  	xOverflowCount: TBaseType_t;
	  xTimeOnEntering: TTickType_t;
  end;
  PTimeOut_t = ^TTimeOut_t;

//struct xMEMORY_REGION
  TMemoryRegion_t = record
	  pvBaseAddress: pointer;
	  ulLengthInBytes,
	  ulParameters: uint32;
  end;
  PMemoryRegion_t = ^TMemoryRegion_t;

//struct xTASK_PARAMETERS
  TTaskParameters_t = record
	  pvTaskCode: TTaskFunction_t;
	  pcName: PChar;
	  usStackDepth: uint32;
	  pvParameters: pointer;
	  uxPriority: TUBaseType_t;
	  puxStackBuffer: PStackType_t;
	  xRegions: array[0..portNUM_CONFIGURABLE_REGIONS-1] of TMemoryRegion_t;
  end;

//struct xTASK_STATUS
  TTaskStatus_t = record
	  xHandle: TTaskHandle_t;
	  pcTaskName: PChar;
	  xTaskNumber: TUBaseType_t;
	  eCurrentState: TeTaskState;
	  uxCurrentPriority: TUBaseType_t;
	  uxBasePriority: TUBaseType_t;
	  ulRunTimeCounter: uint32;
	  pxStackBase: PStackType_t;
	  usStackHighWaterMark: uint32;
{$ifdef configTASKLIST_INCLUDE_COREID}
	  xCoreID: TBaseType_t;
{$endif}
  end;
  PTaskStatus_t = ^TTaskStatus_t;

//typedef struct xTASK_SNAPSHOT
  TTaskSnapshot_t = record
	  pxTCB: pointer;
	  pxTopOfStack: PStackType_t;
	  pxEndOfStack: PStackType_t;
  end;
  PTaskSnapshot_t = ^TTaskSnapshot_t;

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
  function xTaskCreatePinnedToCore(pvTaskCode: TTaskFunction_t;
										pcName: PChar; const usStackDepth: uint32;
										pvParameters: pointer;
										uxPriority: TUBaseType_t;
										pvCreatedTask: PTaskHandle_t;
										xCoreID: TBaseType_t): TBaseType_t; external;
{$endif}

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION =  1)}
function xTaskCreate(
			pvTaskCode: TTaskFunction_t;
			pcName: PChar;
			const usStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType_t;
			pvCreatedTask: PTaskHandle_t): TBaseType_t; inline; // IRAM_ATTR
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
function xTaskCreateStaticPinnedToCore(pvTaskCode: TTaskFunction_t;
												pcName: PChar;
												const ulStackDepth: uint32;
												pvParameters: pointer;
												uxPriority: TUBaseType_t;
												pxStackBuffer: PStackType_t;
												pxTaskBuffer: PStaticTask_t;
												const xCoreID: TBaseType_t): TTaskHandle_t; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
function xTaskCreateStatic(
			pvTaskCode: TTaskFunction_t;
			pcName: PChar;
			const ulStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType_t;
			pxStackBuffer: PStackType_t;
			pxTaskBuffer: PStaticTask_t): TTaskHandle_t; inline; // IRAM_ATTR
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS =  1)}
function xTaskCreateRestricted(pxTaskDefinition: PTaskParameters_t; pxCreatedTask: PTaskHandle_t): TBaseType_t; external;
{$endif}

procedure vTaskAllocateMPURegions(xTask: TTaskHandle_t; pxRegions: PMemoryRegion_t); external;
procedure vTaskDelete(xTaskToDelete: TTaskHandle_t); external;
procedure vTaskDelay(xTicksToDelay: TTickType_t); external;

procedure vTaskDelayUntil(pxPreviousWakeTime: PTickType_t; xTimeIncrement: TTickType_t); external;
function uxTaskPriorityGet(xTask: TTaskHandle_t): TUBaseType_t; external;
function uxTaskPriorityGetFromISR(xTask:TTaskHandle_t): TUBaseType_t; external;
function eTaskGetState(xTask: TTaskHandle_t): TeTaskState; external;
procedure vTaskPrioritySet(xTask: TTaskHandle_t; uxNewPriority: TUBaseType_t); external;
procedure vTaskSuspend(xTaskToSuspend: TTaskHandle_t); external;
procedure vTaskResume(xTaskToResume: TTaskHandle_t); external;
function  xTaskResumeFromISR(xTaskToResume: TTaskHandle_t): TBaseType_t; external;
procedure vTaskStartScheduler; external;
procedure vTaskEndScheduler; external;
procedure vTaskSuspendAll; external;
function xTaskResumeAll: TBaseType_t; external;
function xTaskGetTickCount: TTickType_t; external;
function xTaskGetTickCountFromISR: TTickType_t; external;
function uxTaskGetNumberOfTasks: TUBaseType_t; external;
function pcTaskGetTaskName(xTaskToQuery: TTaskHandle_t): PChar; external;
function uxTaskGetStackHighWaterMark(xTask: TTaskHandle_t): TUBaseType_t; external;
function pxTaskGetStackStart(xTask: TTaskHandle_t): PByte; external;

(* When using trace macros it is sometimes necessary to include task.h before
FreeRTOS.h.  When this is done TaskHookFunction_t will not yet have been defined,
so the following two prototypes will cause a compilation error.  This can be
fixed by simply guarding against the inclusion of these two prototypes unless
they are explicitly required by the configUSE_APPLICATION_TASK_TAG configuration
constant. *)
{$ifdef configUSE_APPLICATION_TASK_TAG}
	{$if configUSE_APPLICATION_TASK_TAG =  1}
		procedure vTaskSetApplicationTaskTag(xTask: TTaskHandle_t; pxHookFunction: TTaskHookFunction_t); external;

		function xTaskGetApplicationTaskTag(xTask: TTaskHandle_t): TTaskHookFunction_t; external;
	{$endif} (* configUSE_APPLICATION_TASK_TAG = 1 *)
{$endif} (* ifdef configUSE_APPLICATION_TASK_TAG *)
{$if defined(configNUM_THREAD_LOCAL_STORAGE_POINTERS) and (configNUM_THREAD_LOCAL_STORAGE_POINTERS > 0 )}
	procedure vTaskSetThreadLocalStoragePointer(xTaskToSet: TTaskHandle_t; xIndex: TBaseType_t; pvValue: pointer); external;
	function pvTaskGetThreadLocalStoragePointer(xTaskToQuery: TTaskHandle_t; xIndex: TBaseType_t): pointer; external;

	{$ifdef configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS}
		type
      TTlsDeleteCallbackFunction_t = procedure (para1: int32; para2: pointer);

		procedure vTaskSetThreadLocalStoragePointerAndDelCallback(xTaskToSet: TTaskHandle_t;
          xIndex: TBaseType_t; pvValue: pointer; pvDelCallback: TTlsDeleteCallbackFunction_t); external;
	{$endif}
{$endif}

function xTaskCallApplicationTaskHook(xTask: TTaskHandle_t; pvParameter: pointer): TBaseType_t; external;
function xTaskGetIdleTaskHandle: TTaskHandle_t; external;
function xTaskGetIdleTaskHandleForCPU(cpuid: TUBaseType_t): TTaskHandle_t; external;
function uxTaskGetSystemState(pxTaskStatusArray: PTaskStatus_t;
      uxArraySize: TUBaseType_t; pulTotalRunTime: PUint32): TUBaseType_t; external;
procedure vTaskList(pcWriteBuffer: PChar); external;
procedure vTaskGetRunTimeStats(pcWriteBuffer: PChar); external;
function xTaskNotify(xTaskToNotify: TTaskHandle_t; ulValue: uint32; eAction: TeNotifyAction): TBaseType_t; external;
function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle_t; ulValue: uint32;
      eAction: TeNotifyAction; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t; external;
function xTaskNotifyWait(ulBitsToClearOnEntry, ulBitsToClearOnExit: uint32;
      pulNotificationValue: PUint32; xTicksToWait: TTickType_t): TBaseType_t; external;

function xTaskNotifyGive(xTaskToNotify: TTaskHandle_t): TBaseType_t; inline;

procedure vTaskNotifyGiveFromISR(xTaskToNotify: TTaskHandle_t; pxHigherPriorityTaskWoken: PBaseType_t); external;
function ulTaskNotifyTake(xClearCountOnExit: TBaseType_t; xTicksToWait: TTickType_t): uint32; external;
function xTaskIncrementTick: TBaseType_t; external;
procedure vTaskPlaceOnEventList(pxEventList: PList_t; xTicksToWait: TTickType_t); external;
procedure vTaskPlaceOnUnorderedEventList(pxEventList: PList_t; xItemValue: TTickType_t; xTicksToWait: TTickType_t); external;
procedure vTaskPlaceOnEventListRestricted(pxEventList: PList_t; xTicksToWait: TTickType_t); external;
function xTaskRemoveFromEventList(pxEventList: PList_t): TBaseType_t; external;
function xTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem_t; xItemValue: TTickType_t): TBaseType_t; external;
procedure vTaskSwitchContext; external;
function uxTaskResetEventItemValue: TTickType_t; external;
function xTaskGetCurrentTaskHandle: TTaskHandle_t; external;
function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType_t): TTaskHandle_t; external;
procedure vTaskSetTimeOutState(pxTimeOut: PTimeOut_t); external;
function xTaskCheckForTimeOut(pxTimeOut: PTimeOut_t; pxTicksToWait: PTickType_t): TBaseType_t; external;
procedure vTaskMissedYield; external;
function xTaskGetSchedulerState: TBaseType_t; external;
procedure vTaskPriorityInherit(pxMutexHolder: TTaskHandle_t); external;
function xTaskPriorityDisinherit(pxMutexHolder: TTaskHandle_t): TBaseType_t; external;
function uxTaskGetTaskNumber(xTask: TTaskHandle_t): TUBaseType_t; external;
function xTaskGetAffinity(xTask: TTaskHandle_t): TBaseType_t; external;
procedure vTaskSetTaskNumber(xTask: TTaskHandle_t; uxHandle: TUBaseType_t); external;
procedure vTaskStepTick(xTicksToJump: TTickType_t); external;
function eTaskConfirmSleepModeStatus: TeSleepModeStatus; external;
function pvTaskIncrementMutexHeldCount: pointer; external;
function uxTaskGetSnapshotAll(pxTaskSnapshotArray: PTaskSnapshot_t;
      uxArraySize: TUBaseType_t; pxTcbSz: PUBaseType_t): TUBaseType_t; external;

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
			pvTaskCode: TTaskFunction_t;
			pcName: PChar;
			const usStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType_t;
			pvCreatedTask: PTaskHandle_t): TBaseType_t;
begin
  xTaskCreate :=
    xTaskCreatePinnedToCore(pvTaskCode, pcName, usStackDepth, pvParameters,
      uxPriority, pvCreatedTask, tskNO_AFFINITY);
end;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION =  1)}
function xTaskCreateStatic(
			pvTaskCode: TTaskFunction_t;
			pcName: PChar;
			const ulStackDepth: uint32;
			pvParameters: pointer;
			uxPriority: TUBaseType_t;
			pxStackBuffer: PStackType_t;
			pxTaskBuffer: PStaticTask_t): TTaskHandle_t;
begin
  xTaskCreateStatic :=
    xTaskCreateStaticPinnedToCore(pvTaskCode, pcName, ulStackDepth,
      pvParameters, uxPriority, pxStackBuffer, pxTaskBuffer, tskNO_AFFINITY);
end;
{$endif}

function xTaskNotifyGive(xTaskToNotify: TTaskHandle_t): TBaseType_t;
begin
  xTaskNotifyGive := xTaskNotify(xTaskToNotify, 0, eIncrement);
end;

end.

