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
    _set_isr: procedure(n: int32; f: pointer; arg: pointer); cdecl;
    _ints_on: procedure(mask: uint32); cdecl;
    _ints_off: procedure(mask: uint32); cdecl;
    _spin_lock_create: function: pointer; cdecl;
    _spin_lock_delete: procedure(lock: pointer); cdecl;
    _wifi_int_disable: function(wifi_int_mux: pointer): uint32; cdecl;
    _wifi_int_restore: procedure(wifi_int_mux: pointer; tmp: uint32); cdecl;
    _task_yield_from_isr: procedure; cdecl;
    _semphr_create: function(max: uint32; init: uint32): pointer; cdecl;
    _semphr_delete: procedure(semphr: pointer); cdecl;
    _semphr_take: function(semphr: pointer; block_time_tick: uint32): int32; cdecl;
    _semphr_give: function(semphr: pointer): int32; cdecl;
    _wifi_thread_semphr_get: function: pointer; cdecl;
    _mutex_create: function: pointer; cdecl;
    _recursive_mutex_create: function: pointer; cdecl;
    _mutex_delete: procedure(mutex: pointer); cdecl;
    _mutex_lock: function(mutex: pointer): int32; cdecl;
    _mutex_unlock: function(mutex: pointer): int32; cdecl;
    _queue_create: function(queue_len: uint32; item_size: uint32): pointer; cdecl;
    _queue_delete: procedure(queue: pointer); cdecl;
    _queue_send: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32; cdecl;
    _queue_send_from_isr: function(queue: pointer; item: pointer;
        hptw: pointer): int32; cdecl;
    _queue_send_to_back: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32; cdecl;
    _queue_send_to_front: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32; cdecl;
    _queue_recv: function(queue: pointer; item: pointer;
        block_time_tick: uint32): int32; cdecl;
    _queue_msg_waiting: function(queue: pointer): uint32; cdecl;
    _event_group_create: function: pointer; cdecl;
    _event_group_delete: procedure(event: pointer); cdecl;
    _event_group_set_bits: function(event: pointer; bits: uint32): uint32; cdecl;
    _event_group_clear_bits: function(event: pointer; bits: uint32): uint32; cdecl;
    _event_group_wait_bits: function(event: pointer; bits_to_wait_for: uint32;
        clear_on_exit: int32; wait_for_all_bits: int32;
        block_time_tick: uint32): uint32; cdecl;
    _task_create_pinned_to_core: function(task_func: pointer;
        Name: PChar; stack_depth: uint32; param: pointer; prio: uint32;
        task_handle: pointer; core_id: uint32): int32; cdecl;
    _task_create: function(task_func: pointer; Name: PChar;
        stack_depth: uint32; param: pointer; prio: uint32;
        task_handle: pointer): int32; cdecl;
    _task_delete: procedure(task_handle: pointer); cdecl;
    _task_delay: procedure(tick: uint32); cdecl;
    _task_ms_to_tick: function(ms: uint32): int32; cdecl;
    _task_get_current_task: function: pointer; cdecl;
    _task_get_max_priority: function: int32; cdecl;
    _malloc: function(size: uint32): pointer; cdecl;
    _free: procedure(p: pointer); cdecl;
    _event_post: function(event_base: PChar; event_id: int32;
        event_data: pointer; event_data_size: Tsize; ticks_to_wait: uint32): int32; cdecl;
    _get_free_heap_size: function: uint32; cdecl;
    _rand: function: uint32; cdecl;
    _dport_access_stall_other_cpu_start_wrap: procedure; cdecl;
    _dport_access_stall_other_cpu_end_wrap: procedure; cdecl;
    _phy_rf_deinit: function(module: uint32): int32; cdecl;
    _phy_load_cal_and_init: procedure(module: uint32); cdecl;
    {$ifdef CONFIG_IDF_TARGET_ESP32}
    _phy_common_clock_enable: procedure; cdecl;
    _phy_common_clock_disable: procedure; cdecl;
    {$endif}
    _read_mac: function(mac: PByte; _type: uint32): int32; cdecl;
    _timer_arm: procedure(timer: pointer; tmout: uint32; _repeat: longbool); cdecl;
    _timer_disarm: procedure(timer: pointer); cdecl;
    _timer_done: procedure(ptimer: pointer); cdecl;
    _timer_setfn: procedure(ptimer: pointer; pfunction: pointer; parg: pointer); cdecl;
    _timer_arm_us: procedure(ptimer: pointer; us: uint32; _repeat: longbool); cdecl;
    _periph_module_enable: procedure(periph: uint32); cdecl;
    _periph_module_disable: procedure(periph: uint32); cdecl;
    _esp_timer_get_time: function: int64; cdecl;
    _nvs_set_i8: function(handle: uint32; key: PChar; Value: int8): int32; cdecl;
    _nvs_get_i8: function(handle: uint32; key: PChar;
        out_value: Pint8): int32; cdecl;
    _nvs_set_u8: function(handle: uint32; key: PChar;
        Value: byte): int32; cdecl;
    _nvs_get_u8: function(handle: uint32; key: PChar;
        out_value: PByte): int32; cdecl;
    _nvs_set_u16: function(handle: uint32; key: PChar;
        Value: uint16): int32; cdecl;
    _nvs_get_u16: function(handle: uint32; key: PChar;
        out_value: Puint16): int32; cdecl;
    _nvs_open: function(Name: PChar; open_mode: uint32;
        out_handle: Puint32): int32; cdecl;
    _nvs_close: procedure(handle: uint32); cdecl;
    _nvs_commit: function(handle: uint32): int32; cdecl;
    _nvs_set_blob: function(handle: uint32; key: PChar; Value: pointer;
        length: Tsize): int32; cdecl;
    _nvs_get_blob: function(handle: uint32; key: PChar;
        out_value: pointer; length: Pint32): int32; cdecl;
    _nvs_erase_key: function(handle: uint32; key: PChar): int32; cdecl;
    _get_random: function(buf: PByte; len: Tsize): int32; cdecl;
    _get_time: function(t: pointer): int32; cdecl;
    _random: function: uint32; cdecl;
    {$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
    _slowclk_cal_get: function: uint32; cdecl;
    {$endif}
    _log_write: procedure(level: uint32; tag: PChar; format: PChar); varargs; cdecl;
    _log_writev: procedure(level: uint32; tag: PChar; format: PChar); varargs; cdecl;
    _log_timestamp: function: uint32; cdecl;
    _malloc_internal: function(size: Tsize): pointer; cdecl;
    _realloc_internal: function(ptr: pointer; size: Tsize): pointer; cdecl;
    _calloc_internal: function(n: Tsize; size: Tsize): pointer; cdecl;
    _zalloc_internal: function(size: Tsize): pointer; cdecl;
    _wifi_malloc: function(size: Tsize): pointer; cdecl;
    _wifi_realloc: function(ptr: pointer; size: Tsize): pointer; cdecl;
    _wifi_calloc: function(n: Tsize; size: Tsize): pointer; cdecl;
    _wifi_zalloc: function(size: Tsize): pointer; cdecl;
    _wifi_create_queue: function(queue_len: int32;
        item_size: int32): pointer; cdecl;
    _wifi_delete_queue: procedure(queue: pointer); cdecl;
    _modem_sleep_enter: function(module: uint32): int32; cdecl;
    _modem_sleep_exit: function(module: uint32): int32; cdecl;
    _modem_sleep_register: function(module: uint32): int32; cdecl;
    _modem_sleep_deregister: function(module: uint32): int32; cdecl;
    _coex_status_get: function: uint32; cdecl;
    _coex_condition_set: procedure(_type: uint32; dissatisfy: longbool); cdecl;
    _coex_wifi_request: function(event: uint32; latency: uint32;
        duration: uint32): int32; cdecl;
    _coex_wifi_release: function(event: uint32): int32; cdecl;
    _magic: int32;
  end;

var
  g_wifi_osi_funcs: Twifi_osi_funcs; cvar; external;

implementation

end.
