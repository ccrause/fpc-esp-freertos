program i2cscan;

uses
  freertos, gpio, task, portmacro, esp_err
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  , i2c_obj;

var
  i2cMaster: TI2cMaster;
  ret: Tesp_err;

procedure i2c_scan;
var
  i, j, addr: uint32;
  ret: Tesp_err;
begin
  writeln;
  writeln('Scanning right adjusted addresses $00 - $7f');
  writeln('   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F');
  for i := 0 to 7 do
  begin
    Write(HexStr(i, 1), '0 ');
    for j := 0 to 15 do
    begin
      addr := (i shl 4) or j;
      ret := i2cMaster.CheckAddress(addr);
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

begin
  i2cMaster.Initialize(0, 4, 5);
  i2c_scan;
  while True do
    vTaskDelay(100);
end.
