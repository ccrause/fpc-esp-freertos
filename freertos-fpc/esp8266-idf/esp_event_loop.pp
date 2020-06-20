unit esp_event_loop;

{$include freertosconfig.inc}

interface

uses
  esp_err, esp_event, queue;

const
  EVENT_LOOP_STACKSIZE = CONFIG_EVENT_LOOP_STACK_SIZE;

type
  Tsystem_event_cb = function(ctx: pointer; event: Psystem_event): Tesp_err;

function esp_event_loop_init(cb: Tsystem_event_cb; ctx: pointer): Tesp_err;
  external;
function esp_event_loop_set_cb(cb: Tsystem_event_cb;
  ctx: pointer): Tsystem_event_cb; external;
function esp_event_loop_get_queue: TQueueHandle; external;

implementation

end.
