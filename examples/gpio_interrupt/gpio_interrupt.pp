program gpio_interrupt;

uses
  freertos, gpio, task, portmacro, queue
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  ;

const
  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  //LED = GPIO_NUM_13; // Sonoff Basic
  INPUT_PIN = GPIO_NUM_0; // Re-use the Flash/Boot button present on many boards

var
  gpio_evt_queue: TQueueHandle = nil;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

procedure gpio_isr_handler(arg: pointer); {section IRAM}
var
  gpio_num: uint32;
begin
  gpio_num := uint32(arg); // arg is configured to be the gpio pin number
  xQueueSendFromISR(gpio_evt_queue, @gpio_num, nil);
end;

procedure gpio_task_example(arg: pointer);
var
  io_num: uint32;
  outputlevel: uint32;
begin
  repeat
    if not(xQueueReceive(gpio_evt_queue, @io_num, portMAX_DELAY) = 0) then
    begin
      outputlevel := gpio_get_level(LED);
      writeln('GPIO[', io_num, '] intr, output level: ', outputlevel);
      outputlevel := 1 xor outputlevel;  // toggle state
      writeln('New output level: ', outputlevel);
      gpio_set_level(LED, outputlevel);
    end;
  until false;
end;

var
  cfg: Tgpio_config;

begin
  // Output
  cfg.pin_bit_mask := 1 shl ord(LED);
  cfg.mode := Tgpio_mode(ord(GPIO_MODE_INPUT) or ord(GPIO_MODE_OUTPUT)); // Pin gets read again, so must be INPUT_OUTPUT
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  // Input
  cfg.pin_bit_mask := 1 shl ord(INPUT_PIN);
  cfg.mode := GPIO_MODE_INPUT;
  cfg.pull_up_en := GPIO_PULLUP_ENABLE; // on NODEMCU DevKit V1 there isn't a pullup on gpio0, so it must be pulled high
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_NEGEDGE;
  gpio_config(cfg);

  //create a queue to handle gpio event from isr
  gpio_evt_queue := xQueueCreate(10, sizeof(uint32));
  //start gpio task
  xTaskCreate(@gpio_task_example, 'gpio_task', 2048, nil, 10, nil);

  //install gpio isr service
  gpio_install_isr_service(0);
  //hook isr handler for specific gpio pin
  gpio_isr_handler_add(INPUT_PIN, @gpio_isr_handler, pointer(INPUT_PIN));

  // Basically don't exit app_main, the RTL halt code will put the controller into deep sleep.
  // Could configure an external wake-up source (ext0/1) and then enter deep sleep
  // in this loop for ESP32.
  // On ESP8266 it seems that only a reset signal can wake cpu from deep sleep.
  repeat
    writeln('.');
    sleep(1000);
  until false;
end.
