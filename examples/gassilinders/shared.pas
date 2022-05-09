unit shared;

interface

uses
  task, portmacro;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32

implementation

procedure sleep(Milliseconds: cardinal);
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

end.

