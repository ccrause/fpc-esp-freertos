unit task;

{$include freertosconfig.inc}

interface

uses
  portmacro, portable, list;
// #include "list.h"

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
function xTaskCreateRestricted(pxTaskDefinition: PTaskParameters_t; pxCreatedTask: PTaskHandle_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
{$endif}

procedure vTaskAllocateMPURegions(xTask: TTaskHandle_t; pxRegions: PMemoryRegion_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskDelete(xTaskToDelete: TTaskHandle_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskDelay(xTicksToDelay: TTickType_t); external; //PRIVILEGED_FUNCTION;

procedure vTaskDelayUntil(pxPreviousWakeTime: PTickType_t; xTimeIncrement: TTickType_t); external; //PRIVILEGED_FUNCTION;
function uxTaskPriorityGet(xTask: TTaskHandle_t): TUBaseType_t; external; //PRIVILEGED_FUNCTION;
function uxTaskPriorityGetFromISR(xTask:TTaskHandle_t): TUBaseType_t; external; //PRIVILEGED_FUNCTION;
function eTaskGetState(xTask: TTaskHandle_t): TeTaskState; external; //PRIVILEGED_FUNCTION;
procedure vTaskPrioritySet(xTask: TTaskHandle_t; uxNewPriority: TUBaseType_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskSuspend(xTaskToSuspend: TTaskHandle_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskResume(xTaskToResume: TTaskHandle_t); external; //PRIVILEGED_FUNCTION;
function  xTaskResumeFromISR(xTaskToResume: TTaskHandle_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskStartScheduler; external; //PRIVILEGED_FUNCTION;
procedure vTaskEndScheduler; external; //PRIVILEGED_FUNCTION;
procedure vTaskSuspendAll; external; //PRIVILEGED_FUNCTION;
function xTaskResumeAll: TBaseType_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetTickCount: TTickType_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetTickCountFromISR: TTickType_t; external; //PRIVILEGED_FUNCTION;
function uxTaskGetNumberOfTasks: TUBaseType_t; external; //PRIVILEGED_FUNCTION;
function pcTaskGetTaskName(xTaskToQuery: TTaskHandle_t): PChar; external; //PRIVILEGED_FUNCTION;
function uxTaskGetStackHighWaterMark(xTask: TTaskHandle_t): TUBaseType_t; external; //PRIVILEGED_FUNCTION;
function pxTaskGetStackStart(xTask: TTaskHandle_t): PByte; external; //PRIVILEGED_FUNCTION;

(* When using trace macros it is sometimes necessary to include task.h before
FreeRTOS.h.  When this is done TaskHookFunction_t will not yet have been defined,
so the following two prototypes will cause a compilation error.  This can be
fixed by simply guarding against the inclusion of these two prototypes unless
they are explicitly required by the configUSE_APPLICATION_TASK_TAG configuration
constant. *)
{$ifdef configUSE_APPLICATION_TASK_TAG}
	{$if configUSE_APPLICATION_TASK_TAG =  1}
		procedure vTaskSetApplicationTaskTag(xTask: TTaskHandle_t; pxHookFunction: TTaskHookFunction_t); external; //PRIVILEGED_FUNCTION;

		function xTaskGetApplicationTaskTag(xTask: TTaskHandle_t): TTaskHookFunction_t; external; //PRIVILEGED_FUNCTION;
	{$endif} (* configUSE_APPLICATION_TASK_TAG = 1 *)
{$endif} (* ifdef configUSE_APPLICATION_TASK_TAG *)
{$if defined(configNUM_THREAD_LOCAL_STORAGE_POINTERS) and (configNUM_THREAD_LOCAL_STORAGE_POINTERS > 0 )}
	procedure vTaskSetThreadLocalStoragePointer(xTaskToSet: TTaskHandle_t; xIndex: TBaseType_t; pvValue: pointer); external; //PRIVILEGED_FUNCTION;
	function pvTaskGetThreadLocalStoragePointer(xTaskToQuery: TTaskHandle_t; xIndex: TBaseType_t): pointer; external; //PRIVILEGED_FUNCTION;

	{$ifdef configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS}
		type
      TTlsDeleteCallbackFunction_t = procedure (para1: int32; para2: pointer);

		procedure vTaskSetThreadLocalStoragePointerAndDelCallback(xTaskToSet: TTaskHandle_t;
          xIndex: TBaseType_t; pvValue: pointer; pvDelCallback: TTlsDeleteCallbackFunction_t); external;
	{$endif}
{$endif}

function xTaskCallApplicationTaskHook(xTask: TTaskHandle_t; pvParameter: pointer): TBaseType_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetIdleTaskHandle: TTaskHandle_t; external;
function xTaskGetIdleTaskHandleForCPU(cpuid: TUBaseType_t): TTaskHandle_t; external;
function uxTaskGetSystemState(pxTaskStatusArray: PTaskStatus_t;
      uxArraySize: TUBaseType_t; pulTotalRunTime: PUint32): TUBaseType_t; external;
procedure vTaskList(pcWriteBuffer: PChar); external; //PRIVILEGED_FUNCTION; (*lint !e971 Unqualified char types are allowed for strings and single characters only. *)
procedure vTaskGetRunTimeStats(pcWriteBuffer: PChar); external; //PRIVILEGED_FUNCTION; (*lint !e971 Unqualified char types are allowed for strings and single characters only. *)
function xTaskNotify(xTaskToNotify: TTaskHandle_t; ulValue: uint32; eAction: TeNotifyAction): TBaseType_t; external;
function xTaskNotifyFromISR(xTaskToNotify: TTaskHandle_t; ulValue: uint32;
      eAction: TeNotifyAction; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t; external;
function xTaskNotifyWait(ulBitsToClearOnEntry, ulBitsToClearOnExit: uint32;
      pulNotificationValue: PUint32; xTicksToWait: TTickType_t): TBaseType_t; external;

function xTaskNotifyGive(xTaskToNotify: TTaskHandle_t): TBaseType_t; inline;

procedure vTaskNotifyGiveFromISR(xTaskToNotify: TTaskHandle_t; pxHigherPriorityTaskWoken: PBaseType_t); external;
function ulTaskNotifyTake(xClearCountOnExit: TBaseType_t; xTicksToWait: TTickType_t): uint32; external;
function xTaskIncrementTick: TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskPlaceOnEventList(pxEventList: PList_t; xTicksToWait: TTickType_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskPlaceOnUnorderedEventList(pxEventList: PList_t; xItemValue: TTickType_t; xTicksToWait: TTickType_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskPlaceOnEventListRestricted(pxEventList: PList_t; xTicksToWait: TTickType_t); external; //PRIVILEGED_FUNCTION;
function xTaskRemoveFromEventList(pxEventList: PList_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
function xTaskRemoveFromUnorderedEventList(pxEventListItem: PListItem_t; xItemValue: TTickType_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskSwitchContext; external; //PRIVILEGED_FUNCTION;
function uxTaskResetEventItemValue: TTickType_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetCurrentTaskHandle: TTaskHandle_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetCurrentTaskHandleForCPU(cpuid: TBaseType_t): TTaskHandle_t; external;
procedure vTaskSetTimeOutState(pxTimeOut: PTimeOut_t); external; //PRIVILEGED_FUNCTION;
function xTaskCheckForTimeOut(pxTimeOut: PTimeOut_t; pxTicksToWait: PTickType_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskMissedYield; external; //PRIVILEGED_FUNCTION;
function xTaskGetSchedulerState: TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskPriorityInherit(pxMutexHolder: TTaskHandle_t); external; //PRIVILEGED_FUNCTION;
function xTaskPriorityDisinherit(pxMutexHolder: TTaskHandle_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
function uxTaskGetTaskNumber(xTask: TTaskHandle_t): TUBaseType_t; external; //PRIVILEGED_FUNCTION;
function xTaskGetAffinity(xTask: TTaskHandle_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
procedure vTaskSetTaskNumber(xTask: TTaskHandle_t; uxHandle: TUBaseType_t); external; //PRIVILEGED_FUNCTION;
procedure vTaskStepTick(xTicksToJump: TTickType_t); external; //PRIVILEGED_FUNCTION;
function eTaskConfirmSleepModeStatus: TeSleepModeStatus; external; //PRIVILEGED_FUNCTION;
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

