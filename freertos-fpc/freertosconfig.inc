{$include sdkconfig.inc}

{$ifndef CONFIG_FREERTOS_UNICORE}
  {$define portNUM_PROCESSORS := 2}
{$else}
  {$define portNUM_PROCESSORS := 1}
{$endif}

{$define XT_USE_THREAD_SAFE_CLIB := 0}
{$define configASSERT_2 := 0}
{$define portUSING_MPU_WRAPPERS := 0}
{$define configUSE_MUTEX := 1}
{$undef XT_USE_SWPRI}
{$ifdef CONFIG_FREERTOS_CORETIMER_0}
  {$define XT_TIMER_INDEX := 0}
{$elseif defined(CONFIG_FREERTOS_CORETIMER_1)}
  {$define XT_TIMER_INDEX := 1}
{$endif}
{$define configNUM_THREAD_LOCAL_STORAGE_POINTERS :=
  CONFIG_FREERTOS_THREAD_LOCAL_STORAGE_POINTERS}
{$define configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS := 1}
{$define configUSE_PREEMPTION := 1}
{$define configUSE_IDLE_HOOK := 1}
{$define configUSE_TICK_HOOK := 1}
{$define configTICK_RATE_HZ := CONFIG_FREERTOS_HZ}
{$ifdef SMALL_TEST}
  {$define configMAX_PRIORITIES := 7}
{$else}
  {$define configMAX_PRIORITIES := 25}
{$endif}
{$ifndef CONFIG_APPTRACE_ENABLE}
  {$define configMINIMAL_STACK_SIZE := 768}
{$else}
  {$define configMINIMAL_STACK_SIZE := 2048}
{$endif}
{$ifndef configIDLE_TASK_STACK_SIZE}
  {$define configIDLE_TASK_STACK_SIZE := CONFIG_FREERTOS_IDLE_TASK_STACKSIZE}
{$endif}
{$ifndef configISR_STACK_SIZE}
  {$define configISR_STACK_SIZE := CONFIG_FREERTOS_ISR_STACKSIZE}
{$endif}
  {$define configAPPLICATION_ALLOCATED_HEAP := 1}

//function configTOTAL_HEAP_SIZE: longint} { return type might be wrong }
  //configTOTAL_HEAP_SIZE := @_heap_end - @_heap_start) div (64 * 1024)}

{$define configMAX_TASK_NAME_LEN := CONFIG_FREERTOS_MAX_TASK_NAME_LEN}
{$ifdef CONFIG_FREERTOS_USE_TRACE_FACILITY}
  {$define configUSE_TRACE_FACILITY := 1}
{$endif}
{$ifdef CONFIG_FREERTOS_USE_STATS_FORMATTING_FUNCTIONS}
  {$define configUSE_STATS_FORMATTING_FUNCTIONS := 1}
{$endif}
{$ifdef CONFIG_FREERTOS_VTASKLIST_INCLUDE_COREID}
  {$define configTASKLIST_INCLUDE_COREID := 1}
{$endif}
{$ifdef CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS}
  {$define configGENERATE_RUN_TIME_STATS := 1}
{$endif}
{$define configUSE_TRACE_FACILITY_2 := 0}
{$define configBENCHMARK := 0}
{$define configUSE_16_BIT_TICKS := 0}
{$define configIDLE_SHOULD_YIELD := 0}
{$define configQUEUE_REGISTRY_SIZE := CONFIG_FREERTOS_QUEUE_REGISTRY_SIZE}
{$define configUSE_MUTEXES := 1}
{$define configUSE_RECURSIVE_MUTEXES := 1}
{$define configUSE_COUNTING_SEMAPHORES := 1}
{$ifdef CONFIG_FREERTOS_CHECK_STACKOVERFLOW_NONE}
  {$define configCHECK_FOR_STACK_OVERFLOW := 0}
{$elseif defined(CONFIG_FREERTOS_CHECK_STACKOVERFLOW_PTRVAL)}
  {$define configCHECK_FOR_STACK_OVERFLOW := 1}
{$elseif defined(CONFIG_FREERTOS_CHECK_STACKOVERFLOW_CANARY)}
  {$define configCHECK_FOR_STACK_OVERFLOW := 2}
{$endif}
{$define configUSE_CO_ROUTINES := 0}
{$define configMAX_CO_ROUTINE_PRIORITIES := 2}
{$define INCLUDE_vTaskPrioritySet := 1}
{$define INCLUDE_uxTaskPriorityGet := 1}
{$define INCLUDE_vTaskDelete := 1}
{$define INCLUDE_vTaskCleanUpResources := 0}
{$define INCLUDE_vTaskSuspend := 1}
{$define INCLUDE_vTaskDelayUntil := 1}
{$define INCLUDE_vTaskDelay := 1}
{$define INCLUDE_uxTaskGetStackHighWaterMark := 1}
{$define INCLUDE_pcTaskGetTaskName := 1}
{$define INCLUDE_xTaskGetIdleTaskHandle := 1}
{$define INCLUDE_pxTaskGetStackStart := 1}
{$define INCLUDE_xSemaphoreGetMutexHolder := 1}
{$define configKERNEL_INTERRUPT_PRIORITY := 1}
{$define configMAX_SYSCALL_INTERRUPT_PRIORITY := XCHAL_EXCM_LEVEL}
{$define configUSE_NEWLIB_REENTRANT := 1}
{$define configSUPPORT_DYNAMIC_ALLOCATION := 1}

{$if defined(CONFIG_FREERTOS_SUPPORT_STATIC_ALLOCATION)}
  {$define configSUPPORT_STATIC_ALLOCATION := CONFIG_FREERTOS_SUPPORT_STATIC_ALLOCATION}
{$endif}

{$ifdef CONFIG_FREERTOS_ENABLE_STATIC_TASK_CLEAN_UP}
//procedure vPortCleanUpTCB(pxTCB: pointer)} cdecl} external}
//function portCLEAN_UP_TCB(pxTCB: longint): longint}
{$endif}

{$define configUSE_TIMERS := 1}
{$define configTIMER_TASK_PRIORITY := CONFIG_FREERTOS_TIMER_TASK_PRIORITY}
{$define configTIMER_QUEUE_LENGTH := CONFIG_FREERTOS_TIMER_QUEUE_LENGTH}
{$define configTIMER_TASK_STACK_DEPTH := CONFIG_FREERTOS_TIMER_TASK_STACK_DEPTH}
{$define INCLUDE_xTimerPendFunctionCall := 1}
{$define INCLUDE_eTaskGetState := 1}
{$define configUSE_QUEUE_SETS := 1}
{$if defined(CONFIG_FREERTOS_USE_TICKLESS_IDLE)}
  {$define configUSE_TICKLESS_IDLE := CONFIG_FREERTOS_USE_TICKLESS_IDLE}
  {$define configEXPECTED_IDLE_TIME_BEFORE_SLEEP :=
    CONFIG_FREERTOS_IDLE_TIME_BEFORE_SLEEP}
{$endif}
{$define configXT_BOARD := 1}
{$define configXT_SIMULATOR := 0}
{$ifdef CONFIG_ESP32_ENABLE_COREDUMP}
  {$define configENABLE_TASK_SNAPSHOT := 1}
{$endif}
{$ifndef configENABLE_TASK_SNAPSHOT}
  {$define configENABLE_TASK_SNAPSHOT := 1}
{$endif}
{$if defined(CONFIG_SYSVIEW_ENABLE)}
{ $include "SEGGER_SYSVIEW_FreeRTOS.h"}
{$undef INLINE // to avoid redefinition}
{$endif}
{$if CONFIG_FREERTOS_CHECK_MUTEX_GIVEN_BY_OWNER}
  {$define configCHECK_MUTEX_GIVEN_BY_OWNER := 1}
{$else}
  {$define configCHECK_MUTEX_GIVEN_BY_OWNER := 0}
{$endif}
