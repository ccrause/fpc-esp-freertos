program blink;

uses
  freertos, gpio, task, portmacro
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  ;

const
  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  //LED = GPIO_NUM_13; // Sonoff Basic

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

var
  cfg: Tgpio_config;

begin
//  Below function only implemented on ESP32, on ESP8266 it is implemented as a convoluted macro
//  gpio_pad_select_gpio(ord(LED));

// For compatibility rather set the GPIO function using the gpio_config function
  cfg.pin_bit_mask := 1 shl ord(LED);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

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
