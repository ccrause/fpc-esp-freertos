program %%APPNAME%%;

uses
  freertos, gpio, task, portmacro
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  ;

var
  cfg: Tgpio_config;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

begin
  repeat
    writeln('Hello World!');
    sleep(1000);
  until false;
end.
