{$include sdkconfig.inc}

{$if defined(CONFIG_STACK_CHECK_ALL) or defined(CONFIG_STACK_CHECK_STRONG)}
    {$define STACK_OVERHEAD_CHECKER := 256}
{$else}
    {$define STACK_OVERHEAD_CHECKER := 0}
{$endif}

{$if defined(CONFIG_COMPILER_OPTIMIZATION_NONE)}
    {$define STACK_OVERHEAD_OPTIMIZATION := 320}
{$else}
    {$define STACK_OVERHEAD_OPTIMIZATION := 0}
{$endif}

{$if defined(CONFIG_APPTRACE_ENABLE)}
    {$define STACK_OVERHEAD_APPTRACE := 1280}
{$else}
    {$define STACK_OVERHEAD_APPTRACE := 0}
{$endif}

{$if defined(CONFIG_FREERTOS_WATCHPOINT_END_OF_STACK)}
    {$define STACK_OVERHEAD_WATCHPOINT := 60}
{$else}
    {$define STACK_OVERHEAD_WATCHPOINT := 0}
{$endif}

{$define configSTACK_OVERHEAD_TOTAL :=  STACK_OVERHEAD_CHECKER + STACK_OVERHEAD_OPTIMIZATION + STACK_OVERHEAD_APPTRACE + STACK_OVERHEAD_WATCHPOINT}

{ The arch-specific FreeRTOSConfig_arch.h in esp_additions/arch_include/<arch>.
  Placed here due to configSTACK_OVERHEAD_TOTAL. Todo: IDF-5712. }

// #include "freertos/FreeRTOSConfig_arch.h"

{$define configUSE_PREEMPTION := 1}
{$define configUSE_TICKLESS_IDLE := CONFIG_FREERTOS_USE_TICKLESS_IDLE}
{$if defined(configUSE_TICKLESS_IDLE)}
    {$define configEXPECTED_IDLE_TIME_BEFORE_SLEEP := CONFIG_FREERTOS_IDLE_TIME_BEFORE_SLEEP}
{$endif configUSE_TICKLESS_IDLE}
{$define configCPU_CLOCK_HZ := CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ * 1000000}
{$define configTICK_RATE_HZ := CONFIG_FREERTOS_HZ}
{$define configMAX_PRIORITIES := 25}
{$define configUSE_TIME_SLICING := 1}
{$define configUSE_16_BIT_TICKS := 0}
{$define configIDLE_SHOULD_YIELD := 0}
{$define configKERNEL_INTERRUPT_PRIORITY := }
{$define configNUMBER_OF_CORES := CONFIG_FREERTOS_NUMBER_OF_CORES}
{$define configNUM_CORES := configNUMBER_OF_CORES}
{$define configUSE_MUTEXES := 1}
{$define configUSE_RECURSIVE_MUTEXES := 1}
{$define configUSE_COUNTING_SEMAPHORES := 1}
{$define configUSE_QUEUE_SETS := 1}
{$define configQUEUE_REGISTRY_SIZE := CONFIG_FREERTOS_QUEUE_REGISTRY_SIZE}
{$define configUSE_TASK_NOTIFICATIONS := 1}
{$define configTASK_NOTIFICATION_ARRAY_ENTRIES := CONFIG_FREERTOS_TASK_NOTIFICATION_ARRAY_ENTRIES}

{$define configMAX_TASK_NAME_LEN := CONFIG_FREERTOS_MAX_TASK_NAME_LEN}

{$if CONFIG_FREERTOS_TLSP_DELETION_CALLBACKS}
  {$define configNUM_THREAD_LOCAL_STORAGE_POINTERS  :=  CONFIG_FREERTOS_THREAD_LOCAL_STORAGE_POINTERS * 2}
{$else CONFIG_FREERTOS_TLSP_DELETION_CALLBACKS}
    {$define configNUM_THREAD_LOCAL_STORAGE_POINTERS  :=  CONFIG_FREERTOS_THREAD_LOCAL_STORAGE_POINTERS}
{$endif CONFIG_FREERTOS_TLSP_DELETION_CALLBACKS}

{$define configSTACK_DEPTH_TYPE := uint32}
{$if defined(CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY)}
    {$define configENABLE_BACKWARD_COMPATIBILITY := 1}
{$else CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY}
    {$define configENABLE_BACKWARD_COMPATIBILITY := 0}
{$endif CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY}
{$define configASSERT := assert}

{$define configSUPPORT_STATIC_ALLOCATION           := 1}
{$define configSUPPORT_DYNAMIC_ALLOCATION          := 1}
{$define configAPPLICATION_ALLOCATED_HEAP          := 1}
{$define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP := 0}

{$if defined(CONFIG_FREERTOS_USE_IDLE_HOOK)}
    {$define configUSE_IDLE_HOOK             :=  1}
{$else CONFIG_FREERTOS_USE_IDLE_HOOK}
  {$define configUSE_IDLE_HOOK             :=  0}
{$endif CONFIG_FREERTOS_USE_IDLE_HOOK}
{$if defined(CONFIG_FREERTOS_USE_TICK_HOOK)}
  {$define configUSE_TICK_HOOK             :=  1}
{$else CONFIG_FREERTOS_USE_TICK_HOOK}
  {$define configUSE_TICK_HOOK             :=  0}
{$endif CONFIG_FREERTOS_USE_TICK_HOOK}
{$if defined(CONFIG_FREERTOS_CHECK_STACKOVERFLOW_NONE)}
  {$define configCHECK_FOR_STACK_OVERFLOW  :=  0}
{$elseif defined(CONFIG_FREERTOS_CHECK_STACKOVERFLOW_PTRVAL)}
  {$define configCHECK_FOR_STACK_OVERFLOW  :=  1}
{$elseif defined(CONFIG_FREERTOS_CHECK_STACKOVERFLOW_CANARY)}
  {$define configCHECK_FOR_STACK_OVERFLOW  :=  2}
{$endif CONFIG_FREERTOS_CHECK_STACKOVERFLOW_NONE}
{$define configRECORD_STACK_HIGH_ADDRESS     :=  1}

{$ifdef CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS}
  {$define configGENERATE_RUN_TIME_STATS         :=  1}
{$endif CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS}
{$ifdef CONFIG_FREERTOS_USE_STATS_FORMATTING_FUNCTIONS}
    {$define configUSE_STATS_FORMATTING_FUNCTIONS :=  1}
{$endif CONFIG_FREERTOS_USE_STATS_FORMATTING_FUNCTIONS}

{$if not(defined(CONFIG_FREERTOS_SMP))}
  {$if defined(CONFIG_FREERTOS_RUN_TIME_COUNTER_TYPE_U32)}
    {$define configRUN_TIME_COUNTER_TYPE  :=  uint32}
  {$elseif defined(CONFIG_FREERTOS_RUN_TIME_COUNTER_TYPE_U64)}
    {$define configRUN_TIME_COUNTER_TYPE  :=  uint64}
  {$endif CONFIG_FREERTOS_RUN_TIME_COUNTER_TYPE_U64}
{$endif !CONFIG_FREERTOS_SMP}

{$define configUSE_CO_ROUTINES            :=  0}
{$define configMAX_CO_ROUTINE_PRIORITIES  :=  2}

{$if defined(CONFIG_FREERTOS_USE_TIMERS)}
  {$define configUSE_TIMERS                        :=  1}
  {$define configTIMER_TASK_PRIORITY               :=  CONFIG_FREERTOS_TIMER_TASK_PRIORITY}
  {$define configTIMER_QUEUE_LENGTH                :=  CONFIG_FREERTOS_TIMER_QUEUE_LENGTH}
  {$define configTIMER_TASK_STACK_DEPTH            :=  CONFIG_FREERTOS_TIMER_TASK_STACK_DEPTH}
  {$define configTIMER_SERVICE_TASK_NAME           :=  CONFIG_FREERTOS_TIMER_SERVICE_TASK_NAME}
  {$define configTIMER_SERVICE_TASK_CORE_AFFINITY  :=  CONFIG_FREERTOS_TIMER_SERVICE_TASK_CORE_AFFINITY}
{$else}
  {$define configUSE_TIMERS                        :=    0}
{$endif}


{$if defined(CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY)}
  {$define configENABLE_BACKWARD_COMPATIBILITY   := 1}
{$else CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY}
  {$define configENABLE_BACKWARD_COMPATIBILITY   := 0}
{$endif CONFIG_FREERTOS_ENABLE_BACKWARD_COMPATIBILITY}

{$define INCLUDE_vTaskPrioritySet                 :=  1}
{$define INCLUDE_uxTaskPriorityGet                :=  1}
{$define INCLUDE_vTaskDelete                      :=  1}
{$define INCLUDE_vTaskSuspend                     :=  1}
{$define INCLUDE_vTaskDelay                       :=  1}
{$define INCLUDE_xTaskGetIdleTaskHandle           :=  1}
{$define INCLUDE_xTaskAbortDelay                  :=  1}
{$define INCLUDE_xSemaphoreGetMutexHolder         :=  1}
{$define INCLUDE_xTaskGetHandle                   :=  1}
{$define INCLUDE_uxTaskGetStackHighWaterMark      :=  1}
{$define INCLUDE_eTaskGetState                    :=  1}
{$define INCLUDE_xTaskResumeFromISR               :=  1}
{$if CONFIG_FREERTOS_USE_TIMERS}
  {$define INCLUDE_xTimerPendFunctionCall         :=  1}
{$else}
  {$define INCLUDE_xTimerPendFunctionCall         :=  0}
{$endif}
{$define INCLUDE_xTaskGetSchedulerState           :=  1}
{$define INCLUDE_xTaskGetCurrentTaskHandle        :=  1}


{$if defined(CONFIG_FREERTOS_USE_APPLICATION_TASK_TAG)}
  {$define configUSE_APPLICATION_TASK_TAG   := 1}
{$endif CONFIG_FREERTOS_USE_APPLICATION_TASK_TAG}

{$define configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES  :=  CONFIG_FREERTOS_USE_LIST_DATA_INTEGRITY_CHECK_BYTES}

{$if defined(CONFIG_FREERTOS_SMP) and (CONFIG_FREERTOS_NUMBER_OF_CORES > 1)}
    {$define configUSE_CORE_AFFINITY             := 1}
    {$define configRUN_MULTIPLE_PRIORITIES       := 1}
    {$define configUSE_TASK_PREEMPTION_DISABLE   := 1}
{$endif CONFIG_FREERTOS_SMP and (CONFIG_FREERTOS_NUMBER_OF_CORES > 1)}

{$define portNUM_PROCESSORS   := configNUMBER_OF_CORES}

// Moved from freertos.h
{$define TICK_TYPE_WIDTH_16_BITS   := 0}
{$define TICK_TYPE_WIDTH_32_BITS   := 1}
{$define TICK_TYPE_WIDTH_64_BITS   := 2}

{$if not defined(configUSE_16_BIT_TICKS) and not defined(configTICK_TYPE_WIDTH_IN_BITS)}
    {$error Missing definition:  One of configUSE_16_BIT_TICKS and configTICK_TYPE_WIDTH_IN_BITS must be defined in FreeRTOSConfig.h.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}

{$if defined(configUSE_16_BIT_TICKS) and defined(configTICK_TYPE_WIDTH_IN_BITS)}
    {$error Only one of configUSE_16_BIT_TICKS and configTICK_TYPE_WIDTH_IN_BITS must be defined in FreeRTOSConfig.h.  See the Configuration section of the FreeRTOS API documentation for details.}
{$endif}

{$ifndef configTICK_TYPE_WIDTH_IN_BITS}
  {$if configUSE_16_BIT_TICKS = 1 }
        {$define configTICK_TYPE_WIDTH_IN_BITS   := TICK_TYPE_WIDTH_16_BITS}
    {$else}
        {$define configTICK_TYPE_WIDTH_IN_BITS   := TICK_TYPE_WIDTH_32_BITS}
    {$endif}
{$endif}
