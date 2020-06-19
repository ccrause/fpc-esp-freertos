unit wifi_os_adapter;

{$include sdkconfig.inc}

interface

uses
  esp_err;

const
  ESP_WIFI_OS_ADAPTER_VERSION = $00000004;
  ESP_WIFI_OS_ADAPTER_MAGIC = $DEADBEAF;
  OSI_FUNCS_TIME_BLOCKING = $ffffffff;
  OSI_QUEUE_SEND_FRONT = 0;
  OSI_QUEUE_SEND_BACK = 1;
  OSI_QUEUE_SEND_OVERWRITE = 2;

type
  Pint8 = ^int8;
  Puint16 = ^uint16;
  Puint32 = ^uint32;
  Pint32 = ^int32;

type
  Pwifi_osi_funcs = ^Twifi_osi_funcs;
  Twifi_osi_funcs = record
    _version: int32;
    _set_isr: procedure(n: int32; f: pointer; arg: pointer);
    _ints_on: procedure(mask: uint32);
    _ints_off: procedure(mask: uint32);
    _spin_lock_create: function: pointer;
    _spin_lock_delete: procedure(lock: pointer);
    _wifi_int_disable: function(wifi_int_mux: pointer): uint32;
    _wifi_int_restore: procedure(wifi_int_mux: pointer; tmp: uint32);
    _task_yield_from_isr: procedure;
    _semphr_create: function(max: uint32; init: uint32): pointer;
    _semphr_delete: procedure(semphr: pointer);
    _semphr_take: function(semphr: pointer; block_time_tick: uint32): int32;
    _semphr_give: function(semphr: pointer): int32;
    _wifi_thread_semphr_get: function: pointer;
    _mutex_create: function: pointer;
    _recursive_mutex_create: function: pointer;
    _mutex_delete: procedure(mutex: pointer);
    _mutex_lock: function(mutex: pointer): int32;
    _mutex_unlock: function(mutex: pointer): int32;
    _queue_create: function(queue_len: uint32; item_size: uint32): pointer;
    _queue_delete: procedure(queue: pointer);
    _queue_send: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32;
    _queue_send_from_isr: function(queue: pointer; item: pointer;
        hptw: pointer): int32;
    _queue_send_to_back: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32;
    _queue_send_to_front: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32;
    _queue_recv: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32;
    _queue_msg_waiting: function(queue: pointer): uint32;
    _event_group_create: function: pointer;
    _event_group_delete: procedure(event: pointer);
    _event_group_set_bits: function(event: pointer; bits: uint32): uint32;
    _event_group_clear_bits: function(event: pointer; bits: uint32): uint32;
    _event_group_wait_bits: function(event: pointer; bits_to_wait_for: uint32;
        clear_on_exit: int32; wait_for_all_bits: int32;
        block_time_tick: uint32): uint32;
    _task_create_pinned_to_core: function(task_func: pointer;
        Name: PChar; stack_depth: uint32; param: pointer; prio: uint32;
        task_handle: pointer; core_id: uint32): int32;
    _task_create: function(task_func: pointer; Name: PChar;
        stack_depth: uint32; param: pointer; prio: uint32;
        task_handle: pointer): int32;
    _task_delete: procedure(task_handle: pointer);
    _task_delay: procedure(tick: uint32);
    _task_ms_to_tick: function(ms: uint32): int32;
    _task_get_current_task: function: pointer;
    _task_get_max_priority: function: int32;
    _malloc: function(size: uint32): pointer;
    _free: procedure(p: pointer);
    _event_post: function(event_base: PChar; event_id: int32;
        event_data: pointer; event_data_size: Tsize; ticks_to_wait: uint32): int32;
    _get_free_heap_size: function: uint32;
    _rand: function: uint32;
    _dport_access_stall_other_cpu_start_wrap: procedure;
    _dport_access_stall_other_cpu_end_wrap: procedure;
    _phy_rf_deinit: function(module: uint32): int32;
    _phy_load_cal_and_init: procedure(module: uint32);
    {$ifdef CONFIG_IDF_TARGET_ESP32}
    _phy_common_clock_enable: procedure;
    _phy_common_clock_disable: procedure;
    {$endif}
    _read_mac: function(mac: PByte; _type: uint32): int32;
    _timer_arm: procedure(timer: pointer; tmout: uint32; _repeat: longbool);
    _timer_disarm: procedure(timer: pointer);
    _timer_done: procedure(ptimer: pointer);
    _timer_setfn: procedure(ptimer: pointer; pfunction: pointer; parg: pointer);
    _timer_arm_us: procedure(ptimer: pointer; us: uint32; _repeat: longbool);
    _periph_module_enable: procedure(periph: uint32);
    _periph_module_disable: procedure(periph: uint32);
    _esp_timer_get_time: function: int64;
    _nvs_set_i8: function(handle: uint32; key: PChar; Value: int8): int32;
    _nvs_get_i8: function(handle: uint32; key: PChar;
        out_value: Pint8): int32;
    _nvs_set_u8: function(handle: uint32; key: PChar;
        Value: byte): int32;
    _nvs_get_u8: function(handle: uint32; key: PChar;
        out_value: PByte): int32;
    _nvs_set_u16: function(handle: uint32; key: PChar;
        Value: uint16): int32;
    _nvs_get_u16: function(handle: uint32; key: PChar;
        out_value: Puint16): int32;
    _nvs_open: function(Name: PChar; open_mode: uint32;
        out_handle: Puint32): int32;
    _nvs_close: procedure(handle: uint32);
    _nvs_commit: function(handle: uint32): int32;
    _nvs_set_blob: function(handle: uint32; key: PChar; Value: pointer;
        length: Tsize): int32;
    _nvs_get_blob: function(handle: uint32; key: PChar;
        out_value: pointer; length: Pint32): int32;
    _nvs_erase_key: function(handle: uint32; key: PChar): int32;
    _get_random: function(buf: PByte; len: Tsize): int32;
    _get_time: function(t: pointer): int32;
    _random: function: uint32;
    {$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
    _slowclk_cal_get: function: uint32;
    {$endif}
    _log_write: procedure(level: uint32; tag: PChar; format: PChar); varargs;
    _log_writev: procedure(level: uint32; tag: PChar; format: PChar); varargs;
    _log_timestamp: function: uint32;
    _malloc_internal: function(size: Tsize): pointer;
    _realloc_internal: function(ptr: pointer; size: Tsize): pointer;
    _calloc_internal: function(n: Tsize; size: Tsize): pointer;
    _zalloc_internal: function(size: Tsize): pointer;
    _wifi_malloc: function(size: Tsize): pointer;
    _wifi_realloc: function(ptr: pointer; size: Tsize): pointer;
    _wifi_calloc: function(n: Tsize; size: Tsize): pointer;
    _wifi_zalloc: function(size: Tsize): pointer;
    _wifi_create_queue: function(queue_len: int32;
        item_size: int32): pointer;
    _wifi_delete_queue: procedure(queue: pointer);
    _modem_sleep_enter: function(module: uint32): int32;
    _modem_sleep_exit: function(module: uint32): int32;
    _modem_sleep_register: function(module: uint32): int32;
    _modem_sleep_deregister: function(module: uint32): int32;
    _coex_status_get: function: uint32;
    _coex_condition_set: procedure(_type: uint32; dissatisfy: longbool);
    _coex_wifi_request: function(event: uint32; latency: uint32;
        duration: uint32): int32;
    _coex_wifi_release: function(event: uint32): int32;
    _magic: int32;
  end;

var
  g_wifi_osi_funcs: Twifi_osi_funcs; cvar; external;

implementation

end.
