program blink;

uses
  freertos, gpio, gpio_types;

const
  LED = GPIO_NUM_2;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

begin
  gpio_pad_select_gpio(ord(LED));
  gpio_set_direction(LED, GPIO_MODE_OUTPUT);
  repeat
    writeln('.');
    gpio_set_level(LED, 0);
    sleep(1000);
    writeln('*');
    gpio_set_level(LED, 1);
    sleep(1000);
  until false;
end.
