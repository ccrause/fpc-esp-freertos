program i2cscan;

uses
  freertos, gpio, task, portmacro, esp_err
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  , i2c;

const
  WRITE_BIT = I2C_MASTER_WRITE_;
  READ_BIT = I2C_MASTER_READ_;
  ACK_CHECK_EN = true;
  I2CPort = {$ifdef CPULX6}0{$else}I2C_NUM_0{$endif};

procedure i2c_scan;
var
  i, j, addr: uint32;
  cmd: Ti2c_cmd_handle;
  ret: Tesp_err;
begin
  writeln('Starting scanning right adjusted addresses $00 - $7f.');
  writeln;
  writeln('   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F');
  for i := 0 to 7 do
  begin
    write(HexStr(i, 1), '0 ');
    for j := 0 to 15 do
    begin
      cmd := i2c_cmd_link_create;
      i2c_master_start(cmd);
      addr := (i shl 4) or j;
      i2c_master_write_byte(cmd, (addr << 1) or ord(WRITE_BIT), ACK_CHECK_EN);
      i2c_master_stop(cmd);
      ret := i2c_master_cmd_begin(I2C_NUM_0, cmd, 50 div portTICK_PERIOD_MS);
      i2c_cmd_link_delete(cmd);
      if (ret = ESP_OK) then
          write(HexStr(addr, 2), ' ')
      else if (ret = ESP_ERR_TIMEOUT) then
          write('er ')
      else
        write('.. ');
    end;
    writeln;
  end;
end;

var
  config: Ti2c_config;
  ret: Tesp_err;

begin
  with config do
  begin
    mode := I2C_MODE_MASTER;
    {$ifdef CPULX6}
    sda_io_num := GPIO_NUM_18;
    scl_io_num := GPIO_NUM_19;
    sda_pullup_en := true;
    scl_pullup_en := true;
    master.clk_speed := 50000;  // 50 kHz, don't miss devices supporting only slow bus speeds
    {$else CPULX6}
    sda_io_num := Tgpio_num(5); // Pin D1 on NodeMCU DevKit V1
    scl_io_num := Tgpio_num(4); // Pin D2 on NodeMCU DevKit V1
    clk_stretch_tick := 300;
    sda_pullup_en := GPIO_PULLUP_ENABLE;
    scl_pullup_en := GPIO_PULLUP_ENABLE;
    {$endif CPULX6}
  end;

  ret := i2c_driver_install(I2CPort, config.mode {$ifdef CPULX6}, 0, 0, 0{$endif});
  if ret <> ESP_OK then
    writeln('Error calling i2c_driver_install: ', esp_err_to_name(ret));

  ret := i2c_param_config(I2C_NUM_0, @config);
  if ret <> ESP_OK then
    writeln('Error calling i2c_param_config: ', esp_err_to_name(ret));

  i2c_scan;

  while true do
    vTaskDelay(100);

  i2c_driver_delete(I2CPort);
end.

//  -Tfreertos -Pxtensa -MObjFPC -Scghi -O1 -g -l -vewnhibq -n @~/fpc/3.3.1/fpc.cfg -Fi/home/christo/fpc/xtensa/examples/blink/lib/xtensa-freertos -Fi/home/christo/fpc/xtensa/freertos-fpc -Fi/home/christo/fpc/xtensa/freertos-fpc/esp-idf -Fl/home/christo/xtensa/esp-idf/libs -Fl/home/christo/.espressif/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/xtensa-esp32-elf/lib -Fl/home/christo/.espressif/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/lib/gcc/xtensa-esp32-elf/8.2.0 -Fu/home/christo/fpc/xtensa/freertos-fpc -Fu/home/christo/fpc/xtensa/freertos-fpc/esp-idf -Fu/home/christo/fpc/xtensa/examples/blink/ -FU/home/christo/fpc/xtensa/examples/blink/lib/xtensa-freertos/ -FE/home/christo/fpc/xtensa/examples/blink/ -o/home/christo/fpc/xtensa/examples/blink/blink -Tfreertos  -Wpesp32  -Cawindowed  -XP/home/christo/.espressif/tools/xtensa-esp32-elf/esp-2020r1-8.2.0/xtensa-esp32-elf/bin/xtensa-esp32-elf- /home/christo/fpc/xtensa/examples/blink/blink.pp

// esptool.py --chip auto --port /dev/ttyUSB0 --baud 500000 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 1MB 0x10000 /home/christo/fpc/xtensa/examples/blink/blink.bin

