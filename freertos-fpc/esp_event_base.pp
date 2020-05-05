unit esp_event_base;

interface

const
  ESP_EVENT_ANY_BASE = nil;
  ESP_EVENT_ANY_ID = -(1);

type
  Pesp_event_base_t = ^Tesp_event_base_t;
  Tesp_event_base_t = pchar;

  Pesp_event_loop_handle_t = ^Tesp_event_loop_handle_t;
  Tesp_event_loop_handle_t = pointer;

  Tesp_event_handler_t = procedure(event_handler_arg: pointer;
    event_base: Tesp_event_base_t; event_id: int32; event_data: pointer); cdecl;

implementation

end.
