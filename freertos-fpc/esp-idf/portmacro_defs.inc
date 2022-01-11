{$if defined(CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER) and (CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER = 1)}
  {$define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS := 1}
{$endif}

// This is mapped to xthal_get_ccount in portmacro
{$define portGET_RUN_TIME_COUNTER_VALUE := 1}
