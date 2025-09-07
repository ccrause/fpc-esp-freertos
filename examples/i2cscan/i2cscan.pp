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
  ACK_CHECK_EN = True;
  I2CPort = {$ifdef CPULX6} 0 {$else} I2C_NUM_0 {$endif};

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
    Write(HexStr(i, 1), '0 ');
    for j := 0 to 15 do
    begin
      cmd := i2c_cmd_link_create;
      i2c_master_start(cmd);
      addr := (i shl 4) or j;
      i2c_master_write_byte(cmd, (addr << 1) or Ord(WRITE_BIT), ACK_CHECK_EN);
      i2c_master_stop(cmd);
      ret := i2c_master_cmd_begin(I2C_NUM_0, cmd, 50 div portTICK_PERIOD_MS);
      i2c_cmd_link_delete(cmd);
      if (ret = ESP_OK) then
        Write(HexStr(addr, 2), ' ')
      else if (ret = ESP_ERR_TIMEOUT) then
        Write('er ')
      else
        Write('.. ');
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
    sda_io_num := GPIO_NUM_21;//18;
    scl_io_num := GPIO_NUM_22;//19;
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

  while True do
    vTaskDelay(100);

  i2c_driver_delete(I2CPort);
end.
