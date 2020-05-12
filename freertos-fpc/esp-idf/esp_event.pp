unit esp_event;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_event_base;

type
  TUBaseType_t = uint32;
  TBaseType_t = int32;
  PBaseType_t = ^TBaseType_t;
  TTickType_t = uint32;
  PFILE = ^file;

  Pesp_event_loop_args_t = ^Tesp_event_loop_args_t;
  Tesp_event_loop_args_t = record
    queue_size: int32;
    task_name: pchar;
    task_priority: TUBaseType_t;
    task_stack_size: uint32;
    task_core_id: TBaseType_t;
  end;

function esp_event_loop_create(event_loop_args: Pesp_event_loop_args_t;
  event_loop: Pesp_event_loop_handle_t): Tesp_err_t; cdecl; external;

function esp_event_loop_delete(event_loop: Tesp_event_loop_handle_t): Tesp_err_t;
  cdecl; external;

function esp_event_loop_create_default: Tesp_err_t; cdecl; external;

function esp_event_loop_delete_default: Tesp_err_t; cdecl; external;

function esp_event_loop_run(event_loop: Tesp_event_loop_handle_t;
  ticks_to_run: TTickType_t): Tesp_err_t; cdecl; external;

function esp_event_handler_register(event_base: Tesp_event_base_t;
  event_id: int32; event_handler: Tesp_event_handler_t;
  event_handler_arg: pointer): Tesp_err_t; cdecl; external;

function esp_event_handler_register_with(event_loop: Tesp_event_loop_handle_t;
  event_base: Tesp_event_base_t; event_id: int32; event_handler: Tesp_event_handler_t;
  event_handler_arg: pointer): Tesp_err_t; cdecl; external;

function esp_event_handler_unregister(event_base: Tesp_event_base_t;
  event_id: int32; event_handler: Tesp_event_handler_t): Tesp_err_t; cdecl; external;

function esp_event_handler_unregister_with(event_loop: Tesp_event_loop_handle_t;
  event_base: Tesp_event_base_t; event_id: int32;
  event_handler: Tesp_event_handler_t): Tesp_err_t; cdecl; external;

function esp_event_post(event_base: Tesp_event_base_t; event_id: int32;
  event_data: pointer; event_data_size: Tsize_t; ticks_to_wait: TTickType_t): Tesp_err_t;
  cdecl; external;

function esp_event_post_to(event_loop: Tesp_event_loop_handle_t;
  event_base: Tesp_event_base_t; event_id: int32; event_data: pointer;
  event_data_size: Tsize_t; ticks_to_wait: TTickType_t): Tesp_err_t;
  cdecl; external;

{$ifdef CONFIG_ESP_EVENT_POST_FROM_ISR}
function esp_event_isr_post(event_base: Tesp_event_base_t; event_id: int32;
  event_data: pointer; event_data_size: Tsize_t; task_unblocked: PBaseType_t): Tesp_err_t;
  cdecl; external;

function esp_event_isr_post_to(event_loop: Tesp_event_loop_handle_t;
  event_base: Tesp_event_base_t; event_id: int32; event_data: pointer;
  event_data_size: Tsize_t; task_unblocked: PBaseType_t): Tesp_err_t;
  cdecl; external;
{$endif}

function esp_event_dump(afile: PFILE): Tesp_err_t; cdecl; external;

implementation

end.
