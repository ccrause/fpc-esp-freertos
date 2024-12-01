unit esp_task_wdt;

interface

uses
  esp_err, portmacro;

function esp_task_wdt_init(timeout: uint32; panic:Tbool): Tesp_err; external;
function esp_task_wdt_deinit:Tesp_err; external;
function esp_task_wdt_add(handle: TTaskHandle): Tesp_err; external;
function esp_task_wdt_reset: Tesp_err; external;
function esp_task_wdt_delete(handle: TTaskHandle): Tesp_err; external;
function esp_task_wdt_status(handle: TTaskHandle):Tesp_err; external;

implementation

end.
