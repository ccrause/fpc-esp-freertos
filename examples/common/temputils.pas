unit temputils;

// Some commonly used utility functions from RTL that isn't working properly at the moment

interface

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32


implementation

uses
  task, portmacro;

procedure sleep(Milliseconds: cardinal);
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

end.

