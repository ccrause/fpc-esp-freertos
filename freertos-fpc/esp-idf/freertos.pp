unit FreeRTOS;

{$include freertosconfig.inc}
{$linklib freertos, static}

interface

uses
  portmacro, portable;

// First contents
type
  // Only used to access errno which is first field of record
  TDummyReentryRecord = record
    errno: integer;
  end;
  PReentryRecord = ^TDummyReentryRecord;

const
  portTICK_PERIOD_MS = 10;  // Configurable in ESP-IDF, assume default value

procedure vTaskDelay(xTicksToDelay: uint16); external;
function __getreent: PReentryRecord; external;
// End first contents

{$ifndef INCLUDE_xTaskGetIdleTaskHandle}
  {$define INCLUDE_xTaskGetIdleTaskHandle := 0}
{$endif}
{$ifndef INCLUDE_xTimerGetTimerDaemonTaskHandle}
  {$define INCLUDE_xTimerGetTimerDaemonTaskHandle := 0}
{$endif}
{$ifndef INCLUDE_xQueueGetMutexHolder}
  {$define INCLUDE_xQueueGetMutexHolder := 0}
{$endif}
{$ifndef INCLUDE_xSemaphoreGetMutexHolder}
  {$define INCLUDE_xSemaphoreGetMutexHolder := INCLUDE_xQueueGetMutexHolder}
{$endif}
{$ifndef INCLUDE_pcTaskGetTaskName}
  {$define INCLUDE_pcTaskGetTaskName := 1}
{$endif}
{$ifndef configUSE_APPLICATION_TASK_TAG}
  {$define configUSE_APPLICATION_TASK_TAG := 0}
{$endif}
{$ifndef INCLUDE_uxTaskGetStackHighWaterMark}
  {$define INCLUDE_uxTaskGetStackHighWaterMark := 0}
{$endif}
{$ifndef INCLUDE_pxTaskGetStackStart}
  {$define INCLUDE_pxTaskGetStackStart := 0}
{$endif}
{$ifndef INCLUDE_eTaskGetState}
  {$define INCLUDE_eTaskGetState := 0}
{$endif}
{$ifndef configUSE_RECURSIVE_MUTEXES}
  {$define configUSE_RECURSIVE_MUTEXES := 0}
{$endif}
{$ifndef configUSE_MUTEXES}
  {$define configUSE_MUTEXES := 0}
{$endif}
{$ifndef configUSE_TIMERS}
  {$define configUSE_TIMERS := 0}
{$endif}
{$ifndef configUSE_COUNTING_SEMAPHORES}
  {$define configUSE_COUNTING_SEMAPHORES := 0}
{$endif}
{$ifndef configUSE_ALTERNATIVE_API}
  {$define configUSE_ALTERNATIVE_API := 0}
{$endif}
{$ifndef portCRITICAL_NESTING_IN_TCB}
  {$define portCRITICAL_NESTING_IN_TCB := 0}
{$endif}
{$ifndef configMAX_TASK_NAME_LEN}
  {$define configMAX_TASK_NAME_LEN := 16}
{$endif}
{$ifndef configIDLE_SHOULD_YIELD}
  {$define configIDLE_SHOULD_YIELD := 1}
{$endif}
{$if defined(configMAX_TASK_NAME_LEN) and (configMAX_TASK_NAME_LEN < 1)}
{$error configMAX_TASK_NAME_LEN must be set to a minimum of 1 in FreeRTOSConfig.h}
{$endif}
{$ifndef INCLUDE_xTaskResumeFromISR}
  {$define INCLUDE_xTaskResumeFromISR := 1}
{$endif}
{$ifndef INCLUDE_xEventGroupSetBitFromISR}
  {$define INCLUDE_xEventGroupSetBitFromISR := 0}
{$endif}
{$ifndef INCLUDE_xTimerPendFunctionCall}
  {$define INCLUDE_xTimerPendFunctionCall := 0}
{$endif}
{$ifndef configASSERT}
  {$define configASSERT_DEFINED := 0}
{$else}
  {$define configASSERT_DEFINED := 1}
{$endif}

{$if defined(configUSE_TIMERS) and (configUSE_TIMERS = 1)}
{$ifndef configTIMER_TASK_PRIORITY}
{$error If configUSE_TIMERS is set to 1 then configTIMER_TASK_PRIORITY must also be defined.}
{$endif}

{$ifndef configTIMER_QUEUE_LENGTH}
{$error If configUSE_TIMERS is set to 1 then configTIMER_QUEUE_LENGTH must also be defined.}
{$endif}

{$ifndef configTIMER_TASK_STACK_DEPTH}
{$error If configUSE_TIMERS is set to 1 then configTIMER_TASK_STACK_DEPTH must also be defined.}
{$endif}
{$endif}

{$ifndef INCLUDE_xTaskGetSchedulerState}
  {$define INCLUDE_xTaskGetSchedulerState := 0}
{$endif}
{$ifndef INCLUDE_xTaskGetCurrentTaskHandle}
  {$define INCLUDE_xTaskGetCurrentTaskHandle := 0}
{$endif}
{$ifndef portSET_INTERRUPT_MASK_FROM_ISR}
  {$define portSET_INTERRUPT_MASK_FROM_ISR := 0}
{$endif}
{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint): pointer;
{$endif}
{$ifndef portCLEAN_UP_TCB}
function portCLEAN_UP_TCB(pxTCB: longint): pointer;
{$endif}
{$ifndef portSETUP_TCB}
function portSETUP_TCB(pxTCB: longint): pointer;
{$endif}
{$ifndef configQUEUE_REGISTRY_SIZE}
  {$define configQUEUE_REGISTRY_SIZE := 0}
{$endif}
{$ifndef portPOINTER_SIZE_TYPE}
type
  portPOINTER_SIZE_TYPE = uint32;
{$endif}
{$ifndef configCHECK_FOR_STACK_OVERFLOW}
  {$define configCHECK_FOR_STACK_OVERFLOW := 0}
{$endif}

{$ifndef traceMOVED_TASK_TO_READY_STATE}
procedure traceMOVED_TASK_TO_READY_STATE(pxTCB: pointer); inline; // dummy implementation
{$endif}
{$ifndef traceREADDED_TASK_TO_READY_STATE}
procedure traceREADDED_TASK_TO_READY_STATE(pxTCB: pointer); inline;
{$endif}
{$ifndef traceEVENT_GROUP_SYNC_END}
function traceEVENT_GROUP_SYNC_END(xEventGroup, uxBitsToSet,
  uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
{$endif}
{$ifndef traceEVENT_GROUP_WAIT_BITS_END}
function traceEVENT_GROUP_WAIT_BITS_END(
  xEventGroup, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
{$endif}
{$ifndef configGENERATE_RUN_TIME_STATS}
  {$define configGENERATE_RUN_TIME_STATS := 0}
{$endif}
{$if configGENERATE_RUN_TIME_STATS = 1}
{$ifndef portCONFIGURE_TIMER_FOR_RUN_TIME_STATS}
{$error If configGENERATE_RUN_TIME_STATS is defined then portCONFIGURE_TIMER_FOR_RUN_TIME_STATS must also be defined.  portCONFIGURE_TIMER_FOR_RUN_TIME_STATS should call a port layer function to setup a peripheral timer/counter that can then be used as the run time counter time base.}
{$endif}

{$ifndef portGET_RUN_TIME_COUNTER_VALUE}
{$ifndef portALT_GET_RUN_TIME_COUNTER_VALUE}
{$error If configGENERATE_RUN_TIME_STATS is defined then either portGET_RUN_TIME_COUNTER_VALUE or portALT_GET_RUN_TIME_COUNTER_VALUE must also be defined.  See the examples provided and the FreeRTOS web site for more information.}
{$endif}
{$endif}
{$endif}
{$ifndef configUSE_MALLOC_FAILED_HOOK}
  {$define configUSE_MALLOC_FAILED_HOOK := 0}
{$endif}
{$ifndef portPRIVILEGE_BIT}
  {$define portPRIVILEGE_BIT := 0}
{$endif}
{$ifndef portYIELD_WITHIN_API}
  procedure portYIELD_WITHIN_API; inline;
{$endif}
{$ifndef pvPortMallocAligned}
function pvPortMallocAligned(sz: longint; puxStackBuffer: pointer): pointer;
{$endif}
{$ifndef vPortFreeAligned}
procedure vPortFreeAligned(pvBlockToFree: pointer);
{$endif}
{$ifndef configEXPECTED_IDLE_TIME_BEFORE_SLEEP}
  {$define configEXPECTED_IDLE_TIME_BEFORE_SLEEP := 2}
{$endif}
{$if configEXPECTED_IDLE_TIME_BEFORE_SLEEP < 2}
{$error configEXPECTED_IDLE_TIME_BEFORE_SLEEP must not be less than 2}
{$endif}
{$ifndef configUSE_TICKLESS_IDLE}
  {$define configUSE_TICKLESS_IDLE := 0}
{$endif}
{$ifndef configUSE_QUEUE_SETS}
  {$define configUSE_QUEUE_SETS := 0}
{$endif}
{$ifndef configUSE_TIME_SLICING}
  {$define configUSE_TIME_SLICING := 1}
{$endif}
{$ifndef configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS}
  {$define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS := 0}
{$endif}
{$ifndef configUSE_NEWLIB_REENTRANT}
  {$define configUSE_NEWLIB_REENTRANT := 0}
{$endif}
{$ifndef configUSE_STATS_FORMATTING_FUNCTIONS}
  {$define configUSE_STATS_FORMATTING_FUNCTIONS := 0}
{$endif}
{$ifndef configTASKLIST_INCLUDE_COREID}
  {$define configTASKLIST_INCLUDE_COREID := 0}
{$endif}
{$ifndef configUSE_TRACE_FACILITY}
  {$define configUSE_TRACE_FACILITY := 0}
{$endif}
{$ifndef configUSE_PORT_OPTIMISED_TASK_SELECTION}
  {$define configUSE_PORT_OPTIMISED_TASK_SELECTION := 0}
{$endif}
{$ifndef configAPPLICATION_ALLOCATED_HEAP}
  {$define configAPPLICATION_ALLOCATED_HEAP := 0}
{$endif}
{$ifndef configUSE_TASK_NOTIFICATIONS}
  {$define configUSE_TASK_NOTIFICATIONS := 1}
{$endif}
{$ifndef portTICK_TYPE_IS_ATOMIC}
  {$define portTICK_TYPE_IS_ATOMIC := 0}
{$endif}
{$ifndef configSUPPORT_STATIC_ALLOCATION}
  {$define configSUPPORT_STATIC_ALLOCATION := 0}
{$endif}
{$ifndef configSUPPORT_DYNAMIC_ALLOCATION}
  {$define configSUPPORT_DYNAMIC_ALLOCATION := 1}
{$endif}
{$if( ( configSUPPORT_STATIC_ALLOCATION = 0 ) and ( configSUPPORT_DYNAMIC_ALLOCATION = 0 ) )}
{$error configSUPPORT_STATIC_ALLOCATION and configSUPPORT_DYNAMIC_ALLOCATION cannot both be 0, but can both be 1.}
{$endif}
{$if defined(portTICK_TYPE_IS_ATOMIC) and (portTICK_TYPE_IS_ATOMIC = 0 )}
procedure portTICK_TYPE_ENTER_CRITICAL(mux: PportMUX_TYPE);
procedure portTICK_TYPE_EXIT_CRITICAL(mux: PportMUX_TYPE);
{$endif}
function portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR: longint;
function portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR(x: longint): pointer;

{$ifndef configESP32_PER_TASK_DATA}
  {$define configESP32_PER_TASK_DATA := 1}
{$endif}

type
  PxSTATIC_LIST_ITEM = ^TxSTATIC_LIST_ITEM;
  TxSTATIC_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..3] of pointer;
  end;
  TStaticListItem_t = TxSTATIC_LIST_ITEM ;

  PxSTATIC_MINI_LIST_ITEM = ^TxSTATIC_MINI_LIST_ITEM;
  TxSTATIC_MINI_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..1] of pointer;
  end;
  TStaticMiniListItem_t = TxSTATIC_MINI_LIST_ITEM;

  PxSTATIC_LIST = ^TxSTATIC_LIST;
  TxSTATIC_LIST = record
    uxDummy1: uint32;
    pvDummy2: pointer;
    xDummy3: TStaticMiniListItem_t;
  end;
  TStaticList_t = TxSTATIC_LIST;
  PStaticList_t = ^TStaticList_t;

type
  PxSTATIC_TCB = ^TxSTATIC_TCB;
  TxSTATIC_TCB = record
  end;
  TStaticTask_t = TxSTATIC_TCB;
  PStaticTask_t = ^TStaticTask_t;

  PxSTATIC_QUEUE = ^TxSTATIC_QUEUE;
  TxSTATIC_QUEUE = record
    pvDummy1: array[0..2] of pointer;
    u: record
      case longint of
        0: (pvDummy2: pointer);
        1: (uxDummy2: uint32);
    end;
    xDummy3: array[0..1] of TStaticList_t;
    uxDummy4: array[0..2] of uint32;
    ucDummy6: byte;
    pvDummy7: pointer;
    uxDummy8: uint32;
    ucDummy9: byte;
    muxDummy: TportMUX_TYPE;
  end;
  TStaticQueue_t = TxSTATIC_QUEUE;
  PStaticQueue_t = ^TStaticQueue_t;

  PStaticSemaphore_t = ^TStaticSemaphore_t;
  TStaticSemaphore_t = TStaticQueue_t;

  PxSTATIC_EVENT_GROUP = ^TxSTATIC_EVENT_GROUP;
  TxSTATIC_EVENT_GROUP = record
    xDummy1: TTickType;
    xDummy2: TStaticList_t;
    uxDummy3: uint32;
    ucDummy4: byte;
    muxDummy: TportMUX_TYPE;
  end;
  TStaticEventGroup_t = TxSTATIC_EVENT_GROUP;
  PStaticEventGroup_t = ^TStaticEventGroup_t;

  PxSTATIC_TIMER = ^TxSTATIC_TIMER;
  TxSTATIC_TIMER = record
    pvDummy1: pointer;
    xDummy2: TStaticListItem_t;
    xDummy3: TTickType;
    uxDummy4: uint32;
    pvDummy5: array[0..1] of pointer;
    uxDummy6: uint32;
    ucDummy7: byte;
  end;
  //TStaticTimer_t = TxSTATIC_TIMER;
  //PStaticTimer_t = ^TStaticTimer_t;

implementation

{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint): pointer;
begin
  portCLEAR_INTERRUPT_MASK_FROM_ISR := pointer(uxSavedStatusValue);
end;
{$endif}

{$ifndef portCLEAN_UP_TCB}
function portCLEAN_UP_TCB(pxTCB: longint): pointer;
begin
  portCLEAN_UP_TCB := pointer(pxTCB);
end;
{$endif}

{$ifndef portSETUP_TCB}
function portSETUP_TCB(pxTCB: longint): pointer;
begin
  portSETUP_TCB := pointer(pxTCB);
end;
{$endif}

{$ifndef traceMOVED_TASK_TO_READY_STATE}
procedure traceMOVED_TASK_TO_READY_STATE(pxTCB: pointer); inline; // dummy implementation
begin
end;
{$endif}

{$ifndef traceREADDED_TASK_TO_READY_STATE}
procedure traceREADDED_TASK_TO_READY_STATE(pxTCB: pointer); inline;
begin
  traceMOVED_TASK_TO_READY_STATE(pxTCB);
end;
{$endif}

{$ifndef traceEVENT_GROUP_SYNC_END}
function traceEVENT_GROUP_SYNC_END(xEventGroup, uxBitsToSet,
  uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
begin
  traceEVENT_GROUP_SYNC_END := pointer(xTimeoutOccurred);
end;
{$endif}

{$ifndef traceEVENT_GROUP_WAIT_BITS_END}
function traceEVENT_GROUP_WAIT_BITS_END(
  xEventGroup, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
begin
  traceEVENT_GROUP_WAIT_BITS_END := pointer(xTimeoutOccurred);
end;
{$endif}

{$ifndef portYIELD_WITHIN_API}
procedure portYIELD_WITHIN_API;
begin
  portYIELD;
end;
{$endif}

function pvPortMallocAligned(sz: longint; puxStackBuffer: pointer): pointer;
begin
  if puxStackBuffer = nil then
    pvPortMallocAligned := pvPortMalloc(sz)
  else
    pvPortMallocAligned := puxStackBuffer;
end;

{$ifndef pvPortMallocAligned}
procedure vPortFreeAligned(pvBlockToFree: pointer);
begin
  vPortFree(pvBlockToFree);
end;
{$endif}

{$if defined(portTICK_TYPE_IS_ATOMIC) and (portTICK_TYPE_IS_ATOMIC = 0)}
procedure portTICK_TYPE_ENTER_CRITICAL(mux: PportMUX_TYPE);
begin
  portENTER_CRITICAL(mux);
end;

procedure portTICK_TYPE_EXIT_CRITICAL(mux: PportMUX_TYPE);
begin
  portEXIT_CRITICAL(mux);
end;
{$endif}

function portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR(x: longint): pointer;
begin
  {$if( portTICK_TYPE_IS_ATOMIC = 0 )}
  portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR := portCLEAR_INTERRUPT_MASK_FROM_ISR(x);
  {$else}
  portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR := nil;
  {$endif}
end;

function portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR: longint;
begin
  {$if( portTICK_TYPE_IS_ATOMIC = 0 )}
  portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR := portSET_INTERRUPT_MASK_FROM_ISR;
  {$else}
  portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR := 0;
  {$endif}
end;

end.
