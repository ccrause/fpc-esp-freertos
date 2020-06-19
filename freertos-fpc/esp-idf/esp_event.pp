unit esp_event;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_event_base, portmacro, portable;

type
  PFILE = ^file;

  Pesp_event_loop_args = ^Tesp_event_loop_args;
  Tesp_event_loop_args = record
    queue_size: int32;
    task_name: pchar;
    task_priority: TUBaseType;
    task_stack_size: uint32;
    task_core_id: TBaseType;
  end;

function esp_event_loop_create(event_loop_args: Pesp_event_loop_args;
  event_loop: Pesp_event_loop_handle): Tesp_err; external;
function esp_event_loop_delete(event_loop: Tesp_event_loop_handle): Tesp_err;
  external;
function esp_event_loop_create_default: Tesp_err; external;
function esp_event_loop_delete_default: Tesp_err; external;
function esp_event_loop_run(event_loop: Tesp_event_loop_handle;
  ticks_to_run: TTickType): Tesp_err; external;
function esp_event_handler_register(event_base: Tesp_event_base;
  event_id: int32; event_handler: Tesp_event_handler;
  event_handler_arg: pointer): Tesp_err; external;
function esp_event_handler_register_with(event_loop: Tesp_event_loop_handle;
  event_base: Tesp_event_base; event_id: int32; event_handler: Tesp_event_handler;
  event_handler_arg: pointer): Tesp_err; external;
function esp_event_handler_unregister(event_base: Tesp_event_base;
  event_id: int32; event_handler: Tesp_event_handler): Tesp_err; external;
function esp_event_handler_unregister_with(event_loop: Tesp_event_loop_handle;
  event_base: Tesp_event_base; event_id: int32;
  event_handler: Tesp_event_handler): Tesp_err; external;
function esp_event_post(event_base: Tesp_event_base; event_id: int32;
  event_data: pointer; event_data_size: Tsize; ticks_to_wait: TTickType): Tesp_err;
  external;
function esp_event_post_to(event_loop: Tesp_event_loop_handle;
  event_base: Tesp_event_base; event_id: int32; event_data: pointer;
  event_data_size: Tsize; ticks_to_wait: TTickType): Tesp_err;
  external;

{$ifdef CONFIG_ESP_EVENT_POST_FROM_ISR}
function esp_event_isr_post(event_base: Tesp_event_base; event_id: int32;
  event_data: pointer; event_data_size: Tsize; task_unblocked: PBaseType): Tesp_err;
  external;
function esp_event_isr_post_to(event_loop: Tesp_event_loop_handle;
  event_base: Tesp_event_base; event_id: int32; event_data: pointer;
  event_data_size: Tsize; task_unblocked: PBaseType): Tesp_err;
  external;
{$endif}

function esp_event_dump(afile: PFILE): Tesp_err; external;

implementation

end.
