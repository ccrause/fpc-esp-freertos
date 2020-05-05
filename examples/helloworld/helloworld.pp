program helloworld;

{$define nvstest}

uses
  freertos, gpio,
  {$ifdef nvstest}nvs,{$endif}
  esp_err, esp_bit_defs, gpio_types;

const
  LED = GPIO_NUM_2;

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

var
  err: longint;
  {$ifdef nvstest}my_handle: Tnvs_handle_t;{$endif}
  restart_counter: int32 = 0; // value will default to 0, if not set yet in NVS

begin
  // Initialize NVS
  {$ifdef nvstest}
  err := nvs_flash_init();
  if ((err = ESP_ERR_NVS_NO_FREE_PAGES) or (err = ESP_ERR_NVS_NEW_VERSION_FOUND)) then
  begin
    EspErrorCheck(nvs_flash_erase());
    err := nvs_flash_init();
  end;
  EspErrorCheck(err);

  // Open
  writeln('Opening Non-Volatile Storage (NVS) handle... ');
  err := nvs_open('storage', NVS_READWRITE, @my_handle);
  if not(err = ESP_OK) then
    writeln('Error opening NVS handle: ', err)
  else
    writeln('Done');

  // Read
  writeln('Reading restart counter from NVS ... ');
  err := nvs_get_i32(my_handle, 'restart_counter', @restart_counter);
  case err of
    ESP_OK:
      writeln('Restart counter = ', restart_counter);
    ESP_ERR_NVS_NOT_FOUND:
      writeln('The value is not initialized yet!');
    else
      writeln('Error reading NVS: ', err);
  end;

  inc(restart_counter);
  err := nvs_set_i32(my_handle, 'restart_counter', restart_counter);
  if not(err = ESP_OK) then
    writeln('Error writing restart counter: ', esp_err_to_name(err))
  else
  begin
    err := nvs_commit(my_handle);
    if not(err = ESP_OK) then
      writeln('Error writing restart counter: ', esp_err_to_name(err));
    nvs_close(my_handle);
  end;
  {$endif}
  gpio_pad_select_gpio(ord(LED));
  gpio_set_direction(LED, GPIO_MODE_OUTPUT);
  repeat
    write('_'#10);
    gpio_set_level(LED, 0);
    sleep(1000);
    write('#'#10);
    gpio_set_level(LED, 1);
    sleep(1000);
  until false;
end.

(***Compile program with
~/fpc/avr-new/compiler/xtensa/pp -Fu~/fpc/avr-new/rtl/units/xtensa-freertos/ -Tfreertos -Cawindowed -XPxtensa-esp32-elf- -al -Wpesp32 -Fl~/xtensa/esp-idf/libs -Fl$HOME/.espressif/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/xtensa-esp32-elf/lib/ helloworld.pp

 ***Flash to esp32 with:

 - Assuming boot & partition for this sdk has been flashed before, only this app needs to be flashed:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 /home/christo/fpc/xtensa/helloworld/helloworld.bin

- If this is the first time a project with this IDF is built, also flash boot loader and partitions:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 /home/christo/fpc/xtensa/helloworld/bootloader.bin 0x10000 /home/christo/fpc/xtensa/helloworld/helloworld.bin 0x8000 /home/christo/fpc/xtensa/helloworld/partitions_singleapp.bin

*)
