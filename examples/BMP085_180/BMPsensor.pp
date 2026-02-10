program BMPsensor;

uses
  freertos, gpio, task, i2c_obj, portmacro, esp_err,
  {$ifdef CPULX6}
  gpio_types, rtc_wdt,
  {$endif}
  i2c,
  fmem, bmp085_180;

const
  I2CPort = 0;

var
  myI2C: TI2cMaster;
  bmp: TBMPxxx;
  b: byte;
  T: int32;
  P: uint32;
  oss: TOversampling;

begin
  {$ifdef CPULX6}
  rtc_wdt_disable;
  myI2C.Initialize(I2CPort, 16, 17);
  {$else}
  myI2C.Initialize(I2CPort, 4, 5);   // Pins D1, D2 on NodeMCU DevKit V1
  {$endif}

  if not bmp.init(myI2C) then
    writeln('bmp.init FAILED');

  b := 0;
  write('Device ID: $');
  if bmp.readID(b) then
    writeln(HexStr((b), 2))
  else
    writeln('ERR');

  if b <> $55 then
  begin
    writeln('Device could not be identified as BMP085 or BMP180');
    exit;
  end;


  repeat
    for oss := os1 to os8 do
    begin
      write('oss = ', ord(oss), ': ');
      bmp.setOverSampling(oss);
      if bmp.readTP(T, P) then
        writeln('T = ', T div 10, '.', T mod 10, ' C, P = ', P, ' Pa')
      else
        writeln('TP = ERR');

      vTaskDelay(200);
    end;
  until false;
end.

// esptool.py --chip auto --port /dev/ttyUSB0 --baud 500000 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 1MB 0x10000 /home/christo/fpc/xtensa/examples/blink/blink.bin

