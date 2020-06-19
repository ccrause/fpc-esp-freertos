unit esp_event_base;

interface

const
  ESP_EVENT_ANY_BASE = nil;
  ESP_EVENT_ANY_ID = -(1);

type
  Pesp_event_base = ^Tesp_event_base;
  Tesp_event_base = pchar;

  Pesp_event_loop_handle = ^Tesp_event_loop_handle;
  Tesp_event_loop_handle = pointer;

  Tesp_event_handler = procedure(event_handler_arg: pointer;
    event_base: Tesp_event_base; event_id: int32; event_data: pointer);

implementation

end.
