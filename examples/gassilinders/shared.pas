unit shared;

interface

uses
  task, portmacro;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32

procedure memReport;

implementation

uses
  esp_heap_caps, logtouart;

procedure sleep(Milliseconds: cardinal);
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

procedure memReport;
var
  s: string[16];
  v: uint32;
begin
  logwrite('Internal RAM free: ');
  v := heap_caps_get_free_size(MALLOC_CAP_INTERNAL);
  Str(v, s);
  logwriteln(s);

  logwrite('Data RAM free: ');
  v := heap_caps_get_free_size(MALLOC_CAP_8BIT);
  Str(v, s);
  logwriteln(s);
end;


end.

