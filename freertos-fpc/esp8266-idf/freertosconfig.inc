{$inline on}
{$include sdkconfig.inc}

{$define portNUM_PROCESSORS       := 1}
{$define configUSE_PREEMPTION		  := 1}

{$define configUSE_IDLE_HOOK		  := 1}
{$define configUSE_TICK_HOOK		  := 1}

{$define configUSE_TICKLESS_IDLE 	:= 1}
{$define configCPU_CLOCK_HZ			  := 80000000}
{$define configTICK_RATE_HZ			  := CONFIG_FREERTOS_HZ}
{$define configMAX_PRIORITIES		  := 15}
{$if defined(CONFIG_ESP8266_WIFI_DEBUG_LOG_ENABLE) and (CONFIG_ESP8266_WIFI_DEBUG_LOG_ENABLE=1)}
  {$define configMINIMAL_STACK_SIZE	:= 2048}
{$else}
  {$define configMINIMAL_STACK_SIZE	:= 768}
{$endif}
//{$define configTOTAL_HEAP_SIZE		( ( size_t ) ( 17 * 1024 ) )
{$define configMAX_TASK_NAME_LEN	:= 16}
{$define configUSE_16_BIT_TICKS		:= 0}
{$define configIDLE_SHOULD_YIELD	:= 1}

{$define INCLUDE_xTaskGetIdleTaskHandle := 1}
{$define INCLUDE_xTimerGetTimerDaemonTaskHandle := 1}

{$ifndef CONFIG_FREERTOS_WATCHPOINT_END_OF_STACK}
  {$define configCHECK_FOR_STACK_OVERFLOW  := 2}
{$endif}

{$define configUSE_MUTEXES         := 1}
{$define configUSE_RECURSIVE_MUTEXES := 1}
{$define configUSE_COUNTING_SEMAPHORES := 1}
{$define configUSE_TIMERS    := 1}

{$if configUSE_TIMERS = 1}
  {$define configTIMER_TASK_PRIORITY := tskIDLE_PRIORITY + 2}
  {$define configTIMER_QUEUE_LENGTH := 10}
  {$define configTIMER_TASK_STACK_DEPTH  := CONFIG_FREERTOS_TIMER_STACKSIZE}
  {$define INCLUDE_xTimerPendFunctionCall := 1}
{$endif}

{$define configUSE_CO_ROUTINES 	:=	0}
{$define configMAX_CO_ROUTINE_PRIORITIES := 2}

{$define INCLUDE_vTaskPrioritySet		:= 1}
{$define INCLUDE_uxTaskPriorityGet	:= 1}
{$define INCLUDE_vTaskDelete				:= 1}
{$define INCLUDE_vTaskCleanUpResources	:= 0}
{$define INCLUDE_vTaskSuspend			:= 1}
{$define INCLUDE_vTaskDelayUntil			:= 1}
{$define INCLUDE_vTaskDelay				:= 1}

{$define INCLUDE_xTaskGetCurrentTaskHandle := 1}
{$define INCLUDE_uxTaskGetStackHighWaterMark := 1}

{$define INCLUDE_xSemaphoreGetMutexHolder   := 1}

{$define configKERNEL_INTERRUPT_PRIORITY 		:= 255}
{$define configMAX_SYSCALL_INTERRUPT_PRIORITY 	:= 191}

{$define configLIBRARY_KERNEL_INTERRUPT_PRIORITY	:= 15}

{$ifdef CONFIG_FREERTOS_ENABLE_REENT}
  {$define configUSE_NEWLIB_REENTRANT  := 1}
{$endif}

{$ifdef CONFIG_ENABLE_PTHREAD}
  {$define configNUM_THREAD_LOCAL_STORAGE_POINTERS := 3}
{$else}
  {$define configNUM_THREAD_LOCAL_STORAGE_POINTERS := 2}
{$endif}
{$define configTHREAD_LOCAL_STORAGE_DELETE_CALLBACKS := 1}

{$define configRECORD_STACK_HIGH_ADDRESS := 1}

{$ifdef CONFIG_TASK_SWITCH_FASTER}
  {$define TASK_SW_ATTR := IRAM_ATTR}
{$else}
  {$define TASK_SW_ATTR}
{$endif}

{$if defined(CONFIG_USE_QUEUE_SETS) and (CONFIG_USE_QUEUE_SETS = 1)}
  {$define configUSE_QUEUE_SETS := 1}
{$endif}

{$ifdef CONFIG_FREERTOS_USE_TRACE_FACILITY}
  {$define configUSE_TRACE_FACILITY        := 1}
{$endif}

{$ifdef CONFIG_FREERTOS_USE_STATS_FORMATTING_FUNCTIONS}
{$define configUSE_STATS_FORMATTING_FUNCTIONS    := 1}
{$endif}

// Don't include function definitions in this config,
// define them in a unit somehwere when required.
{$ifdef CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS}
  {$define configGENERATE_RUN_TIME_STATS           := 1}
  {$define configSUPPORT_DYNAMIC_ALLOCATION        := 1}
  {$define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS}
  {$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_CPU_CLK}
    // move this to freertos unit
    // extern uint64_t g_esp_os_cpu_clk;
    //{$define portGET_RUN_TIME_COUNTER_VALUE()  g_esp_os_cpu_clk
  {$elseif defined(CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER)}
    //uint32_t esp_get_time(void);
    //{$define portALT_GET_RUN_TIME_COUNTER_VALUE(x)    x = (uint32_t)esp_get_time()
  {$endif}
{$endif}

//{$define traceINCREASE_TICK_COUNT(_ticks)    esp_increase_tick_cnt(_ticks)

{$ifndef configIDLE_TASK_STACK_SIZE}
  {$define configIDLE_TASK_STACK_SIZE := CONFIG_FREERTOS_IDLE_TASK_STACKSIZE}
{$endif}

{$ifndef configENABLE_TASK_SNAPSHOT}
  {$define configENABLE_TASK_SNAPSHOT          := 1}
{$endif}
