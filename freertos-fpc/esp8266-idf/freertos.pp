unit freertos;

{$include freertosconfig.inc}
{$linklib freertos, static}

interface

{$ifndef configUSE_NEWLIB_REENTRANT}
  {$define configUSE_NEWLIB_REENTRANT := 0}
{$endif}

uses
  portmacro, portable
{$if configUSE_NEWLIB_REENTRANT = 1}
  , reent
{$endif}
  ;

{$ifndef configMINIMAL_STACK_SIZE}
  {$error Missing definition:  configMINIMAL_STACK_SIZE must be defined in FreeRTOSConfig.h.  configMINIMAL_STACK_SIZE defines the size (in words) of the stack allocated to the idle task.  Refer to the demo project provided for your port for a suitable value.}
{$endif}
{$ifndef configMAX_PRIORITIES}
  {$error Missing definition:  configMAX_PRIORITIES must be defined in FreeRTOSConfig.h.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}
{$if configMAX_PRIORITIES < 1}
  {$error configMAX_PRIORITIES must be defined to be greater than or equal to 1.}
{$endif}
{$ifndef configUSE_PREEMPTION}
  {$error Missing definition:  configUSE_PREEMPTION must be defined in FreeRTOSConfig.h as either 1 or 0.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}
{$ifndef configUSE_IDLE_HOOK}
  {$error Missing definition:  configUSE_IDLE_HOOK must be defined in FreeRTOSConfig.h as either 1 or 0.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}
{$ifndef configUSE_TICK_HOOK}
  {$error Missing definition:  configUSE_TICK_HOOK must be defined in FreeRTOSConfig.h as either 1 or 0.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}
{$ifndef configUSE_16_BIT_TICKS}
  {$error Missing definition:  configUSE_16_BIT_TICKS must be defined in FreeRTOSConfig.h as either 1 or 0.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}

{$ifndef configUSE_CO_ROUTINES}
  {$define configUSE_CO_ROUTINES := 0}
{$endif}
{$ifndef INCLUDE_vTaskPrioritySet}
  {$define INCLUDE_vTaskPrioritySet := 0}
{$endif}
{$ifndef INCLUDE_uxTaskPriorityGet}
  {$define INCLUDE_uxTaskPriorityGet := 0};
{$endif}
{$ifndef INCLUDE_vTaskDelete}
  {$define INCLUDE_vTaskDelete := 0}
{$endif}
{$ifndef INCLUDE_vTaskSuspend}
  {$define INCLUDE_vTaskSuspend := 0}
{$endif}
{$ifndef INCLUDE_vTaskDelayUntil}
  {$define INCLUDE_vTaskDelayUntil := 0}
{$endif}
{$ifndef INCLUDE_vTaskDelay}
  {$define INCLUDE_vTaskDelay := 0}
{$endif}
{$ifndef INCLUDE_xTaskGetIdleTaskHandle}
  {$define INCLUDE_xTaskGetIdleTaskHandle := 0}
{$endif}
{$ifndef INCLUDE_xTaskAbortDelay}
  {$define INCLUDE_xTaskAbortDelay := 0}
{$endif}
{$ifndef INCLUDE_xQueueGetMutexHolder}
  {$define INCLUDE_xQueueGetMutexHolder := 0}
{$endif}
{$ifndef INCLUDE_xSemaphoreGetMutexHolder}
  {$define INCLUDE_xSemaphoreGetMutexHolder := INCLUDE_xQueueGetMutexHolder}
{$endif}
{$ifndef INCLUDE_xTaskGetHandle}
  {$define INCLUDE_xTaskGetHandle := 0}
{$endif}
{$ifndef INCLUDE_uxTaskGetStackHighWaterMark}
  {$define INCLUDE_uxTaskGetStackHighWaterMark := 0}
{$endif}
{$ifndef INCLUDE_eTaskGetState}
  {$define INCLUDE_eTaskGetState := 0}
{$endif}
{$ifndef INCLUDE_xTaskResumeFromISR}
  {$define INCLUDE_xTaskResumeFromISR := 1}
{$endif}
{$ifndef INCLUDE_xTimerPendFunctionCall}
  {$define INCLUDE_xTimerPendFunctionCall := 0}
{$endif}
{$ifndef INCLUDE_xTaskGetSchedulerState}
  {$define INCLUDE_xTaskGetSchedulerState := 0}
{$endif}
{$ifndef INCLUDE_xTaskGetCurrentTaskHandle}
  {$define INCLUDE_xTaskGetCurrentTaskHandle := 0}
{$endif}
{$if not(configUSE_CO_ROUTINES = 0)}
  {$ifndef configMAX_CO_ROUTINE_PRIORITIES}
    {$error configMAX_CO_ROUTINE_PRIORITIES must be greater than or equal to 1.}
  {$endif}
{$endif}
{$ifndef configUSE_DAEMON_TASK_STARTUP_HOOK}
  {$define configUSE_DAEMON_TASK_STARTUP_HOOK := 0}
{$endif}
{$ifndef configUSE_APPLICATION_TASK_TAG}
  {$define configUSE_APPLICATION_TASK_TAG := 0}
{$endif}
{$ifndef configNUM_THREAD_LOCAL_STORAGE_POINTERS}
  {$define configNUM_THREAD_LOCAL_STORAGE_POINTERS := 0}
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
{$if configMAX_TASK_NAME_LEN < 1}
  {$error configMAX_TASK_NAME_LEN must be set to a minimum of 1 in FreeRTOSConfig.h}
{$endif}
{$ifndef configASSERT}
  //#define configASSERT( x )
  {$define configASSERT_DEFINED := 0}
{$else}
  {$define configASSERT_DEFINED := 1}
{$endif}
{$if configUSE_TIMERS = 1}
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

// Move to portmacro
//{$ifndef portSET_INTERRUPT_MASK_FROM_ISR}
//function portSET_INTERRUPT_MASK_FROM_ISR: longint;
//{$endif}
//{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
//function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint)
//  : pointer;
//{$endif}
{$ifndef portCLEAN_UP_TCB}
function portCLEAN_UP_TCB(pxTCB: longint): pointer;
{$endif}
{$ifndef portPRE_TASK_DELETE_HOOK}
//  #define portPRE_TASK_DELETE_HOOK( pvTaskToDelete, pxYieldPending )
{$endif}
{$ifndef portSETUP_TCB}
function portSETUP_TCB(pxTCB: longint): pointer;
{$endif}
{$ifndef configQUEUE_REGISTRY_SIZE}
  {$define configQUEUE_REGISTRY_SIZE := 0}
{$endif}
{$if ( configQUEUE_REGISTRY_SIZE < 1 )}
(* error
  #define vQueueAddToRegistry( xQueue, pcName )
in define line 282 *)
(* error
  #define vQueueUnregisterQueue( xQueue )
in define line 283 *)
(* error
  #define pcQueueGetName( xQueue )
in define line 284 *)
{$endif}

// TODO: Not sure this should be defined here
{$ifndef portPOINTER_SIZE_TYPE}
type
  portPOINTER_SIZE_TYPE = uint32;
{$endif}

{$ifndef traceSTART}
(* error
  #define traceSTART()
in define line 295 *)
{$endif}
{$ifndef traceEND}
(* error
  #define traceEND()
in define line 301 *)
{$endif}
{$ifndef traceTASK_SWITCHED_IN}
(* error
  #define traceTASK_SWITCHED_IN()
in define line 307 *)
{$endif}
{$ifndef traceINCREASE_TICK_COUNT}
(* error
  #define traceINCREASE_TICK_COUNT( x )
in define line 313 *)
{$endif}
{$ifndef traceLOW_POWER_IDLE_BEGIN}
(* error
  #define traceLOW_POWER_IDLE_BEGIN()
in define line 318 *)
{$endif}
{$ifndef  traceLOW_POWER_IDLE_END}
(* error
  #define traceLOW_POWER_IDLE_END()
in define line 323 *)
{$endif}
{$ifndef traceTASK_SWITCHED_OUT}

(* error
  #define traceTASK_SWITCHED_OUT()
in define line 329 *)
{$endif}
{$ifndef traceTASK_PRIORITY_INHERIT}
(* error
  #define traceTASK_PRIORITY_INHERIT( pxTCBOfMutexHolder, uxInheritedPriority )
in define line 338 *)
{$endif}
{$ifndef traceTASK_PRIORITY_DISINHERIT}
(* error
  #define traceTASK_PRIORITY_DISINHERIT( pxTCBOfMutexHolder, uxOriginalPriority )
in define line 346 *)
{$endif}
{$ifndef traceBLOCKING_ON_QUEUE_RECEIVE}
(* error
  #define traceBLOCKING_ON_QUEUE_RECEIVE( pxQueue )
in define line 354 *)
{$endif}
{$ifndef traceBLOCKING_ON_QUEUE_PEEK}
(* error
  #define traceBLOCKING_ON_QUEUE_PEEK( pxQueue )
in define line 362 *)
{$endif}
{$ifndef traceBLOCKING_ON_QUEUE_SEND}
(* error
  #define traceBLOCKING_ON_QUEUE_SEND( pxQueue )
in define line 370 *)
{$endif}
{$ifndef configCHECK_FOR_STACK_OVERFLOW}
  {$define configCHECK_FOR_STACK_OVERFLOW := 0}
{$endif}
{$ifndef configRECORD_STACK_HIGH_ADDRESS}
  {$define configRECORD_STACK_HIGH_ADDRESS := 0}
{$endif}
{$ifndef configINCLUDE_FREERTOS_TASK_C_ADDITIONS_H}
  {$define configINCLUDE_FREERTOS_TASK_C_ADDITIONS_H := 0}
{$endif}

{$ifndef traceMOVED_TASK_TO_READY_STATE}
(* error
  #define traceMOVED_TASK_TO_READY_STATE( pxTCB )
in define line 388 *)
{$endif}
{$ifndef tracePOST_MOVED_TASK_TO_READY_STATE}
(* error
  #define tracePOST_MOVED_TASK_TO_READY_STATE( pxTCB )
in define line 392 *)
{$endif}
{$ifndef traceQUEUE_CREATE}
(* error
  #define traceQUEUE_CREATE( pxNewQueue )
in define line 396 *)
{$endif}
{$ifndef traceQUEUE_CREATE_FAILED}
(* error
  #define traceQUEUE_CREATE_FAILED( ucQueueType )
in define line 400 *)
{$endif}
{$ifndef traceCREATE_MUTEX}
(* error
  #define traceCREATE_MUTEX( pxNewQueue )
in define line 404 *)
{$endif}
{$ifndef traceCREATE_MUTEX_FAILED}
(* error
  #define traceCREATE_MUTEX_FAILED()
in define line 408 *)
{$endif}
{$ifndef traceGIVE_MUTEX_RECURSIVE}
(* error
  #define traceGIVE_MUTEX_RECURSIVE( pxMutex )
in define line 412 *)
{$endif}
{$ifndef traceGIVE_MUTEX_RECURSIVE_FAILED}
(* error
  #define traceGIVE_MUTEX_RECURSIVE_FAILED( pxMutex )
in define line 416 *)
{$endif}
{$ifndef traceTAKE_MUTEX_RECURSIVE}
(* error
  #define traceTAKE_MUTEX_RECURSIVE( pxMutex )
in define line 420 *)
{$endif}
{$ifndef traceTAKE_MUTEX_RECURSIVE_FAILED}
(* error
  #define traceTAKE_MUTEX_RECURSIVE_FAILED( pxMutex )
in define line 424 *)
{$endif}
{$ifndef traceCREATE_COUNTING_SEMAPHORE}
(* error
  #define traceCREATE_COUNTING_SEMAPHORE()
in define line 428 *)
{$endif}
{$ifndef traceCREATE_COUNTING_SEMAPHORE_FAILED}
(* error
  #define traceCREATE_COUNTING_SEMAPHORE_FAILED()
in define line 432 *)
{$endif}
{$ifndef traceQUEUE_SEND}
(* error
  #define traceQUEUE_SEND( pxQueue )
in define line 436 *)
{$endif}
{$ifndef traceQUEUE_SEND_FAILED}
(* error
  #define traceQUEUE_SEND_FAILED( pxQueue )
in define line 440 *)
{$endif}
{$ifndef traceQUEUE_RECEIVE}
(* error
  #define traceQUEUE_RECEIVE( pxQueue )
in define line 444 *)
{$endif}
{$ifndef traceQUEUE_PEEK}
(* error
  #define traceQUEUE_PEEK( pxQueue )
in define line 448 *)
{$endif}
{$ifndef traceQUEUE_PEEK_FAILED}
(* error
  #define traceQUEUE_PEEK_FAILED( pxQueue )
in define line 452 *)
{$endif}
{$ifndef traceQUEUE_PEEK_FROM_ISR}
(* error
  #define traceQUEUE_PEEK_FROM_ISR( pxQueue )
in define line 456 *)
{$endif}
{$ifndef traceQUEUE_RECEIVE_FAILED}
(* error
  #define traceQUEUE_RECEIVE_FAILED( pxQueue )
in define line 460 *)
{$endif}
{$ifndef traceQUEUE_SEND_FROM_ISR}
(* error
  #define traceQUEUE_SEND_FROM_ISR( pxQueue )
in define line 464 *)
{$endif}
{$ifndef traceQUEUE_SEND_FROM_ISR_FAILED}
(* error
  #define traceQUEUE_SEND_FROM_ISR_FAILED( pxQueue )
in define line 468 *)
{$endif}
{$ifndef traceQUEUE_RECEIVE_FROM_ISR}
(* error
  #define traceQUEUE_RECEIVE_FROM_ISR( pxQueue )
in define line 472 *)
{$endif}
{$ifndef traceQUEUE_RECEIVE_FROM_ISR_FAILED}
(* error
  #define traceQUEUE_RECEIVE_FROM_ISR_FAILED( pxQueue )
in define line 476 *)
{$endif}
{$ifndef traceQUEUE_PEEK_FROM_ISR_FAILED}
(* error
  #define traceQUEUE_PEEK_FROM_ISR_FAILED( pxQueue )
in define line 480 *)
{$endif}
{$ifndef traceQUEUE_DELETE}
(* error
  #define traceQUEUE_DELETE( pxQueue )
in define line 484 *)
{$endif}
{$ifndef traceTASK_CREATE}
(* error
  #define traceTASK_CREATE( pxNewTCB )
in define line 488 *)
{$endif}
{$ifndef traceTASK_CREATE_FAILED}
(* error
  #define traceTASK_CREATE_FAILED()
in define line 492 *)
{$endif}
{$ifndef traceTASK_DELETE}
(* error
  #define traceTASK_DELETE( pxTaskToDelete )
in define line 496 *)
{$endif}
{$ifndef traceTASK_DELAY_UNTIL}
(* error
  #define traceTASK_DELAY_UNTIL( x )
in define line 500 *)
{$endif}
{$ifndef traceTASK_DELAY}
(* error
  #define traceTASK_DELAY()
in define line 504 *)
{$endif}
{$ifndef traceTASK_PRIORITY_SET}
(* error
  #define traceTASK_PRIORITY_SET( pxTask, uxNewPriority )
in define line 508 *)
{$endif}
{$ifndef traceTASK_SUSPEND}
(* error
  #define traceTASK_SUSPEND( pxTaskToSuspend )
in define line 512 *)
{$endif}
{$ifndef traceTASK_RESUME}
(* error
  #define traceTASK_RESUME( pxTaskToResume )
in define line 516 *)
{$endif}
{$ifndef traceTASK_RESUME_FROM_ISR}
(* error
  #define traceTASK_RESUME_FROM_ISR( pxTaskToResume )
in define line 520 *)
{$endif}
{$ifndef traceTASK_INCREMENT_TICK}
(* error
  #define traceTASK_INCREMENT_TICK( xTickCount )
in define line 524 *)
{$endif}
{$ifndef traceTIMER_CREATE}
(* error
  #define traceTIMER_CREATE( pxNewTimer )
in define line 528 *)
{$endif}
{$ifndef traceTIMER_CREATE_FAILED}
(* error
  #define traceTIMER_CREATE_FAILED()
in define line 532 *)
{$endif}
{$ifndef traceTIMER_COMMAND_SEND}
(* error
  #define traceTIMER_COMMAND_SEND( xTimer, xMessageID, xMessageValueValue, xReturn )
in define line 536 *)
{$endif}
{$ifndef traceTIMER_EXPIRED}
(* error
  #define traceTIMER_EXPIRED( pxTimer )
in define line 540 *)
{$endif}
{$ifndef traceTIMER_COMMAND_RECEIVED}
(* error
  #define traceTIMER_COMMAND_RECEIVED( pxTimer, xMessageID, xMessageValue )
in define line 544 *)
{$endif}
{$ifndef traceMALLOC}
(* error
    #define traceMALLOC( pvAddress, uiSize )
in define line 548 *)
{$endif}
{$ifndef traceFREE}
(* error
    #define traceFREE( pvAddress, uiSize )
in define line 552 *)
{$endif}
{$ifndef traceEVENT_GROUP_CREATE}
(* error
  #define traceEVENT_GROUP_CREATE( xEventGroup )
in define line 556 *)
{$endif}
{$ifndef traceEVENT_GROUP_CREATE_FAILED}
(* error
  #define traceEVENT_GROUP_CREATE_FAILED()
in define line 560 *)
{$endif}
{$ifndef traceEVENT_GROUP_SYNC_BLOCK}
(* error
  #define traceEVENT_GROUP_SYNC_BLOCK( xEventGroup, uxBitsToSet, uxBitsToWaitFor )
in define line 564 *)
{$endif}
{$ifndef traceEVENT_GROUP_SYNC_END}
function traceEVENT_GROUP_SYNC_END(
  xEventGroup, uxBitsToSet, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
{$endif}
{$ifndef traceEVENT_GROUP_WAIT_BITS_BLOCK}
(* error
  #define traceEVENT_GROUP_WAIT_BITS_BLOCK( xEventGroup, uxBitsToWaitFor )
in define line 572 *)
{$endif}
{$ifndef traceEVENT_GROUP_WAIT_BITS_END}
function traceEVENT_GROUP_WAIT_BITS_END(
  xEventGroup, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
{$endif}
{$ifndef traceEVENT_GROUP_CLEAR_BITS}
(* error 
  #define traceEVENT_GROUP_CLEAR_BITS( xEventGroup, uxBitsToClear )
in define line 580 *)
{$endif}
{$ifndef traceEVENT_GROUP_CLEAR_BITS_FROM_ISR}
(* error 
  #define traceEVENT_GROUP_CLEAR_BITS_FROM_ISR( xEventGroup, uxBitsToClear )
in define line 584 *)
{$endif}
{$ifndef traceEVENT_GROUP_SET_BITS}
(* error 
  #define traceEVENT_GROUP_SET_BITS( xEventGroup, uxBitsToSet )
in define line 588 *)
{$endif}
{$ifndef traceEVENT_GROUP_SET_BITS_FROM_ISR}
(* error 
  #define traceEVENT_GROUP_SET_BITS_FROM_ISR( xEventGroup, uxBitsToSet )
in define line 592 *)
{$endif}
{$ifndef traceEVENT_GROUP_DELETE}
(* error 
  #define traceEVENT_GROUP_DELETE( xEventGroup )
in define line 596 *)
{$endif}
{$ifndef tracePEND_FUNC_CALL}
(* error 
  #define tracePEND_FUNC_CALL(xFunctionToPend, pvParameter1, ulParameter2, ret)
in define line 600 *)
{$endif}
{$ifndef tracePEND_FUNC_CALL_FROM_ISR}
(* error 
  #define tracePEND_FUNC_CALL_FROM_ISR(xFunctionToPend, pvParameter1, ulParameter2, ret)
in define line 604 *)
{$endif}
{$ifndef traceQUEUE_REGISTRY_ADD}
(* error 
  #define traceQUEUE_REGISTRY_ADD(xQueue, pcQueueName)
in define line 608 *)
{$endif}
{$ifndef traceTASK_NOTIFY_TAKE_BLOCK}
(* error 
  #define traceTASK_NOTIFY_TAKE_BLOCK()
in define line 612 *)
{$endif}
{$ifndef traceTASK_NOTIFY_TAKE}
(* error 
  #define traceTASK_NOTIFY_TAKE()
in define line 616 *)
{$endif}
{$ifndef traceTASK_NOTIFY_WAIT_BLOCK}
(* error 
  #define traceTASK_NOTIFY_WAIT_BLOCK()
in define line 620 *)
{$endif}
{$ifndef traceTASK_NOTIFY_WAIT}
(* error 
  #define traceTASK_NOTIFY_WAIT()
in define line 624 *)
{$endif}
{$ifndef traceTASK_NOTIFY}
(* error 
  #define traceTASK_NOTIFY()
in define line 628 *)
{$endif}
{$ifndef traceTASK_NOTIFY_FROM_ISR}
(* error 
  #define traceTASK_NOTIFY_FROM_ISR()
in define line 632 *)
{$endif}
{$ifndef traceTASK_NOTIFY_GIVE_FROM_ISR}
(* error 
  #define traceTASK_NOTIFY_GIVE_FROM_ISR()
in define line 636 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_CREATE_FAILED}
(* error 
  #define traceSTREAM_BUFFER_CREATE_FAILED( xIsMessageBuffer )
in define line 640 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_CREATE_STATIC_FAILED}
(* error 
  #define traceSTREAM_BUFFER_CREATE_STATIC_FAILED( xReturn, xIsMessageBuffer )
in define line 644 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_CREATE}
(* error 
  #define traceSTREAM_BUFFER_CREATE( pxStreamBuffer, xIsMessageBuffer )
in define line 648 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_DELETE}
(* error 
  #define traceSTREAM_BUFFER_DELETE( xStreamBuffer )
in define line 652 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_RESET}
(* error 
  #define traceSTREAM_BUFFER_RESET( xStreamBuffer )
in define line 656 *)
{$endif}
{$ifndef traceBLOCKING_ON_STREAM_BUFFER_SEND}
(* error 
  #define traceBLOCKING_ON_STREAM_BUFFER_SEND( xStreamBuffer )
in define line 660 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_SEND}
(* error 
  #define traceSTREAM_BUFFER_SEND( xStreamBuffer, xBytesSent )
in define line 664 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_SEND_FAILED}
(* error 
  #define traceSTREAM_BUFFER_SEND_FAILED( xStreamBuffer )
in define line 668 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_SEND_FROM_ISR}
(* error 
  #define traceSTREAM_BUFFER_SEND_FROM_ISR( xStreamBuffer, xBytesSent )
in define line 672 *)
{$endif}
{$ifndef traceBLOCKING_ON_STREAM_BUFFER_RECEIVE}
(* error 
  #define traceBLOCKING_ON_STREAM_BUFFER_RECEIVE( xStreamBuffer )
in define line 676 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_RECEIVE}
(* error 
  #define traceSTREAM_BUFFER_RECEIVE( xStreamBuffer, xReceivedLength )
in define line 680 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_RECEIVE_FAILED}
(* error 
  #define traceSTREAM_BUFFER_RECEIVE_FAILED( xStreamBuffer )
in define line 684 *)
{$endif}
{$ifndef traceSTREAM_BUFFER_RECEIVE_FROM_ISR}
(* error
  #define traceSTREAM_BUFFER_RECEIVE_FROM_ISR( xStreamBuffer, xReceivedLength )
in define line 688 *)
{$endif}
{$ifndef configGENERATE_RUN_TIME_STATS}
  {$define configGENERATE_RUN_TIME_STATS := 0}
{$endif}

// Moved definitions from freertosconfig.inc
{$ifdef CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS}
  {$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_CPU_CLK}
    var g_esp_os_cpu_clk: uint64; cvar; external;
    function portGET_RUN_TIME_COUNTER_VALUE: uint64;  g_esp_os_cpu_clk
  {$elseif defined(CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER)}
    function esp_get_time: uint32; external;
    procedure portALT_GET_RUN_TIME_COUNTER_VALUE(var x: uint32); inline;
    {$define portALT_GET_RUN_TIME_COUNTER_VALUE}
  {$endif}
{$endif}

{$if (configGENERATE_RUN_TIME_STATS = 1)}
  {$ifndef portCONFIGURE_TIMER_FOR_RUN_TIME_STATS}
    {$error If configGENERATE_RUN_TIME_STATS is defined then portCONFIGURE_TIMER_FOR_RUN_TIME_STATS must also be defined.  portCONFIGURE_TIMER_FOR_RUN_TIME_STATS should call a port layer function to setup a peripheral timer/counter that can then be used as the run time counter time base.}
  {$endif}
  {$ifndef portGET_RUN_TIME_COUNTER_VALUE}
    {$ifndef portALT_GET_RUN_TIME_COUNTER_VALUE}
      {$error If configGENERATE_RUN_TIME_STATS is defined then either portGET_RUN_TIME_COUNTER_VALUE or portALT_GET_RUN_TIME_COUNTER_VALUE must also be defined.  See the examples provided and the FreeRTOS web site for more information.}
    {$endif}
  {$endif}
{$endif}

{$ifndef portCONFIGURE_TIMER_FOR_RUN_TIME_STATS}
(* error
  #define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()
in define line 710 *)
{$endif}
{$ifndef configUSE_MALLOC_FAILED_HOOK}
  {$define configUSE_MALLOC_FAILED_HOOK := 0}
{$endif}
{$ifndef portPRIVILEGE_BIT}
function portPRIVILEGE_BIT: TUBaseType;
{$endif}
{$ifndef portYIELD_WITHIN_API}
  {$define portYIELD_WITHIN_API := portYIELD}
{$endif}
{$ifndef portSUPPRESS_TICKS_AND_SLEEP}
(* error
  #define portSUPPRESS_TICKS_AND_SLEEP( xExpectedIdleTime )
in define line 726 *)
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
{$ifndef configPRE_SUPPRESS_TICKS_AND_SLEEP_PROCESSING}
(* error
  #define configPRE_SUPPRESS_TICKS_AND_SLEEP_PROCESSING( x )
in define line 742 *)
{$endif}
{$ifndef configPRE_SLEEP_PROCESSING}
(* error
  #define configPRE_SLEEP_PROCESSING( x )
in define line 746 *)
{$endif}
{$ifndef configPOST_SLEEP_PROCESSING}
(* error
  #define configPOST_SLEEP_PROCESSING( x )
in define line 750 *)
{$endif}
{$ifndef configUSE_QUEUE_SETS}
  {$define configUSE_QUEUE_SETS := 0}
{$endif}
{$ifndef portTASK_USES_FLOATING_POINT}
(* error
  #define portTASK_USES_FLOATING_POINT()
in define line 758 *)
{$endif}
{$ifndef portTASK_CALLS_SECURE_FUNCTIONS}
(* error
  #define portTASK_CALLS_SECURE_FUNCTIONS()
in define line 762 *)
{$endif}
{$ifndef configUSE_TIME_SLICING}
  {$define configUSE_TIME_SLICING := 1}
{$endif}
{$ifndef configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS}
  {$define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS := 0}
{$endif}
{$ifndef configUSE_STATS_FORMATTING_FUNCTIONS}
  {$define configUSE_STATS_FORMATTING_FUNCTIONS := 0}
{$endif}
{$ifndef portASSERT_IF_INTERRUPT_PRIORITY_INVALID}
(* error
  #define portASSERT_IF_INTERRUPT_PRIORITY_INVALID()
in define line 778 *)
{$endif}
{$ifndef configUSE_TRACE_FACILITY}
  {$define configUSE_TRACE_FACILITY := 0}
{$endif}
{$ifndef mtCOVERAGE_TEST_MARKER}
(* error
  #define mtCOVERAGE_TEST_MARKER()
in define line 786 *)
{$endif}
{$ifndef mtCOVERAGE_TEST_DELAY}
(* error
  #define mtCOVERAGE_TEST_DELAY()
in define line 790 *)
{$endif}
{$ifndef portASSERT_IF_IN_ISR}
(* error
  #define portASSERT_IF_IN_ISR()
in define line 794 *)
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
//{$ifndef configSTACK_DEPTH_TYPE}
//type
//  configSTACK_DEPTH_TYPE = uint16;
//{$endif}

{$if not(configUSE_TICKLESS_IDLE = 0)}
  {$if not(INCLUDE_vTaskSuspend = 1)}
    {$error INCLUDE_vTaskSuspend must be set to 1 if configUSE_TICKLESS_IDLE is not set to 0}
  {$endif}
{$endif}

{$if( (configSUPPORT_STATIC_ALLOCATION = 0 ) and (configSUPPORT_DYNAMIC_ALLOCATION = 0))}
  {$error configSUPPORT_STATIC_ALLOCATION and configSUPPORT_DYNAMIC_ALLOCATION cannot both be 0, but can both be 1.}
{$endif}
{$if ((configUSE_RECURSIVE_MUTEXES = 1) and not(configUSE_MUTEXES = 1))}
  {$error configUSE_MUTEXES must be set to 1 to use recursive mutexes}
{$endif}
{$ifndef configINITIAL_TICK_COUNT}
  {$define configINITIAL_TICK_COUNT := 0}
{$endif}

procedure portTICK_TYPE_ENTER_CRITICAL;
procedure portTICK_TYPE_EXIT_CRITICAL;
function portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR: longint;
function portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR(x: longint): pointer;

{$ifndef configENABLE_BACKWARD_COMPATIBILITY}
  {.$define configENABLE_BACKWARD_COMPATIBILITY := 1}
{$endif}
{$ifndef configPRINTF}

(* error
  #define configPRINTF( X )
in define line 882 *)
{$endif}
{$ifndef configMAX}
function configMAX(a, b: longint): longint;
{$endif}
{$ifndef configMIN}
function configMIN(a, b: longint): longint;
{$endif}

{$if defined(configENABLE_BACKWARD_COMPATIBILITY) and (configENABLE_BACKWARD_COMPATIBILITY = 1)}
type
  eTaskStateGet = eTaskGetState;
  portTickType = TTickType;
  xTaskHandle = TTaskHandle;
  xQueueHandle = TQueueHandle;
  xSemaphoreHandle = TSemaphoreHandle;
  xQueueSetHandle = TQueueSetHandle;
  xQueueSetMemberHandle = TQueueSetMemberHandle;
  xTimeOutType = TTimeOut;
  xMemoryRegion = TMemoryRegion;
  xTaskParameters = TTaskParameters;
  xTaskStatusType = TTaskStatus;
  xTimerHandle = TTimerHandle;
  xCoRoutineHandle = TCoRoutineHandle;
  pdTASK_HOOK_CODE = TTaskHookFunction;
  tmrTIMER_CALLBACK = TTimerCallbackFunction;
  pdTASK_CODE = TTaskFunction;
  xListItem = TListItem;
  xList = TList;
  pcTaskGetTaskName = pcTaskGetName;
  pcTimerGetTimerName = pcTimerGetName;
  pcQueueGetQueueName = pcQueueGetName;
  vTaskGetTaskInfo = vTaskGetInfo;

const
  portTICK_RATE_MS = portTICK_PERIOD_MS;
{$endif}

{$if not(configUSE_ALTERNATIVE_API = 0 )}
  {$error The alternative API was deprecated some time ago, and was removed in FreeRTOS V9.0 0}
{$endif}

{$ifndef configUSE_TASK_FPU_SUPPORT}
  {$define configUSE_TASK_FPU_SUPPORT := 1}
{$endif}

type
  PxSTATIC_LIST_ITEM = ^TxSTATIC_LIST_ITEM;
  TxSTATIC_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..3] of pointer;
  end;
  TStaticListItem = TxSTATIC_LIST_ITEM;

  PxSTATIC_MINI_LIST_ITEM = ^TxSTATIC_MINI_LIST_ITEM;
  TxSTATIC_MINI_LIST_ITEM = record
    xDummy1: TTickType;
    pvDummy2: array[0..1] of pointer;
  end;
  TStaticMiniListItem = TxSTATIC_MINI_LIST_ITEM;

  PxSTATIC_LIST = ^TxSTATIC_LIST;
  TxSTATIC_LIST = record
    uxDummy1: TUBaseType;
    pvDummy2: pointer;
    xDummy3: TStaticMiniListItem;
  end;
  TStaticList = TxSTATIC_LIST;
  PStaticList = ^TStaticList;

type
  PxSTATIC_TCB = ^TxSTATIC_TCB;
  TxSTATIC_TCB = record
    pxDummy1: pointer;
  	{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
    xDummy2: TxMPU_SETTINGS;
    {$endif}
    xDummy3: array[0..1] of TStaticListItem;
    uxDummy5: TUBaseType;
    pxDummy6: pointer;
    ucDummy7: array[0..(configMAX_TASK_NAME_LEN) - 1] of byte;
  	{$if ((portSTACK_GROWTH > 0 ) or (configRECORD_STACK_HIGH_ADDRESS = 1))}
    pxDummy8: pointer;
    {$endif}
  	{$if (portCRITICAL_NESTING_IN_TCB = 1)}
    uxDummy9: TUBaseType;
    {$endif}
  	{$if (configUSE_TRACE_FACILITY = 1)}
    uxDummy10: array[0..1] of TUBaseType;
    {$endif}
  	{$if (configUSE_MUTEXES = 1)}
    uxDummy12: array[0..1] of TUBaseType;
    {$endif}
  	{$if (configUSE_APPLICATION_TASK_TAG = 1)}
    pxDummy14: pointer;
    {$endif}
  	{$if (configNUM_THREAD_LOCAL_STORAGE_POINTERS > 0)}
    pvDummy15: array[0..(configNUM_THREAD_LOCAL_STORAGE_POINTERS) - 1] of pointer;
    {$endif}
  	{$if (configGENERATE_RUN_TIME_STATS = 1)}
    ulDummy16: uint32;
    {$endif}
  	{$if (configUSE_NEWLIB_REENTRANT = 1)}
    xDummy17: Treent;
    {$endif}
  	{$if (configUSE_TASK_NOTIFICATIONS = 1)}
    ulDummy18: uint32;
    ucDummy19: byte;
    {$endif}
  	{$if defined(configSUPPORT_STATIC_ALLOCATION) and defined(configSUPPORT_DYNAMIC_ALLOCATION) and defined(portUSING_MPU_WRAPPERS) and
         (((configSUPPORT_STATIC_ALLOCATION = 1) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)) or (portUSING_MPU_WRAPPERS = 1))}
    uxDummy20: byte;
    {$endif}
  	{$if (INCLUDE_xTaskAbortDelay = 1)}
    ucDummy21: byte;
    {$endif}
  end;
  TStaticTask_t = TxSTATIC_TCB;
  PStaticTask_t = ^TStaticTask_t;

  PxSTATIC_QUEUE = ^TxSTATIC_QUEUE;
  TxSTATIC_QUEUE = record
    pvDummy1: array[0..2] of pointer;
    u: record
      case longint of
        0: (pvDummy2: pointer);
        1: (uxDummy2: TUBaseType);
    end;
    xDummy3: array[0..1] of TStaticList;
    uxDummy4: array[0..2] of TUBaseType;
    ucDummy5: array[0..1] of byte;
  	{$if ((configSUPPORT_STATIC_ALLOCATION = 1) and (configSUPPORT_DYNAMIC_ALLOCATION = 1))}
    ucDummy6: byte;
    {$endif}
  	{$if (configUSE_QUEUE_SETS = 1)}
    pvDummy7: pointer;
    {$endif}
  	{$if (configUSE_TRACE_FACILITY = 1)}
    uxDummy8: TUBaseType;
    ucDummy9: byte;
    {$endif}
  end;
  TStaticQueue = TxSTATIC_QUEUE;
  PStaticQueue = ^TStaticQueue;

  PStaticSemaphore = ^TStaticSemaphore;
  TStaticSemaphore = TStaticQueue;

  PxSTATIC_EVENT_GROUP = ^TxSTATIC_EVENT_GROUP;
  TxSTATIC_EVENT_GROUP = record
    xDummy1: TTickType;
    xDummy2: TStaticList;
  	{$if (configUSE_TRACE_FACILITY = 1)}
    uxDummy3: TUBaseType;
    {$endif}
  	{$if ((configSUPPORT_STATIC_ALLOCATION = 1) and (configSUPPORT_DYNAMIC_ALLOCATION = 1))}
    ucDummy4: byte;
    {$endif}
  end;
  TStaticEventGroup = TxSTATIC_EVENT_GROUP;
  PStaticEventGroup = ^TStaticEventGroup;

  PxSTATIC_TIMER = ^TxSTATIC_TIMER;
  TxSTATIC_TIMER = record
    pvDummy1: pointer;
    xDummy2: TStaticListItem;
    xDummy3: TTickType;
    uxDummy4: TUBaseType;
    pvDummy5: array[0..1] of pointer;
  	{$if (configUSE_TRACE_FACILITY = 1)}
    uxDummy6: TUBaseType;
    {$endif}
  	{$if ((configSUPPORT_STATIC_ALLOCATION = 1) and (configSUPPORT_DYNAMIC_ALLOCATION = 1))}
    ucDummy7: byte;
    {$endif}
  end;
  TStaticTimer = TxSTATIC_TIMER;
  PStaticTimer = ^TStaticTimer;

  PxSTATIC_STREAM_BUFFER = ^TxSTATIC_STREAM_BUFFER;
  TxSTATIC_STREAM_BUFFER = record
    uxDummy1: array[0..3] of Tsize;
    pvDummy2: array[0..2] of pointer;
    ucDummy3: byte;
  	{$if (configUSE_TRACE_FACILITY = 1)}
    uxDummy4: TUBaseType;
    {$endif}
  end;
  TStaticStreamBuffer = TxSTATIC_STREAM_BUFFER;
  PStaticStreamBuffer = ^TStaticStreamBuffer;

  PStaticMessageBuffer = ^TStaticMessageBuffer;
  TStaticMessageBuffer = TStaticStreamBuffer;

implementation

//{$ifndef portSET_INTERRUPT_MASK_FROM_ISR}
//function portSET_INTERRUPT_MASK_FROM_ISR: longint;
//begin
//  portSET_INTERRUPT_MASK_FROM_ISR := 0;
//end;
//{$endif}
//
//{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
//function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint): pointer;
//begin
//  portCLEAR_INTERRUPT_MASK_FROM_ISR := pointer(uxSavedStatusValue);
//end;
//{$endif}

function portCLEAN_UP_TCB(pxTCB: longint): pointer;
begin
  portCLEAN_UP_TCB := pointer(pxTCB);
end;

function portSETUP_TCB(pxTCB: longint): pointer;
begin
  portSETUP_TCB := pointer(pxTCB);
end;

function traceEVENT_GROUP_SYNC_END(
  xEventGroup, uxBitsToSet, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
begin
  traceEVENT_GROUP_SYNC_END := pointer(xTimeoutOccurred);
end;

function traceEVENT_GROUP_WAIT_BITS_END(
  xEventGroup, uxBitsToWaitFor, xTimeoutOccurred: longint): pointer;
begin
  traceEVENT_GROUP_WAIT_BITS_END := pointer(xTimeoutOccurred);
end;

{ was #define dname def_expr }
function portPRIVILEGE_BIT: TUBaseType;
begin
  portPRIVILEGE_BIT := TUBaseType($00);
end;

procedure portTICK_TYPE_ENTER_CRITICAL;
begin
  {$if (portTICK_TYPE_IS_ATOMIC = 0)}
  portENTER_CRITICAL;
  {$endif}
end;

procedure portTICK_TYPE_EXIT_CRITICAL;
begin
  {$if (portTICK_TYPE_IS_ATOMIC = 0)}
  portEXIT_CRITICAL;
  {$endif}
end;

function portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR: longint;
begin
  {$if (portTICK_TYPE_IS_ATOMIC = 0)}
  portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR := portSET_INTERRUPT_MASK_FROM_ISR;
  {$else}
  portTICK_TYPE_SET_INTERRUPT_MASK_FROM_ISR := 0;
  {$endif}
end;

function portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR(x: longint): pointer;
begin
  {$if (portTICK_TYPE_IS_ATOMIC = 0)}
  portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR := portCLEAR_INTERRUPT_MASK_FROM_ISR(x);
  {$else}
  portTICK_TYPE_CLEAR_INTERRUPT_MASK_FROM_ISR := pointer(x);
  {$endif}
end;

function configMAX(a, b: longint): longint;
var
  if_local1: longint;
  (* result types are not known *)
begin
  if a > b then
    if_local1 := a
  else
    if_local1 := b;
  configMAX := if_local1;
end;

function configMIN(a, b: longint): longint;
var
  if_local1: longint;
  (* result types are not known *)
begin
  if a < b then
    if_local1 := a
  else
    if_local1 := b;
  configMIN := if_local1;
end;

{$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_CPU_CLK}
  function portGET_RUN_TIME_COUNTER_VALUE: uint64;
  begin
    portGET_RUN_TIME_COUNTER_VALUE := g_esp_os_cpu_clk;
  end;
{$elseif defined(CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER)}
  procedure portALT_GET_RUN_TIME_COUNTER_VALUE(var x: uint32);
  begin
    x := esp_get_time;
  end;
{$endif}


end.
