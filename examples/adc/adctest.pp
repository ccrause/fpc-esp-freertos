program adctest;

{$include /home/christo/fpc/avr-new/rtl/freertos/xtensa/sdkconfig.inc}

uses
  esp_err, gpio, adc, esp_adc_cal, adc_types, freertos;

const
  DEFAULT_VREF   = 1100;        //Use adc2_vref_to_gpio() to obtain a better estimate
  NO_OF_SAMPLES  = 64;          //Multisampling

var
{$ifdef CONFIG_IDF_TARGET_ESP32}
  adc_chars: Tesp_adc_cal_characteristics_t;
  channel: Tadc_channel_t = ADC_CHANNEL_6;     //GPIO34 if ADC1, GPIO14 if ADC2
{$elseif defined(CONFIG_IDF_TARGET_ESP32S2BETA)}
  channel: Tadc1_channel_t = ADC1_CHANNEL_6;     // GPIO7 if ADC1, GPIO17 if ADC2
{$endif}
  atten: Tadc_atten_t = ADC_ATTEN_DB_0;
  ADCunitNo: Tadc_unit_t = ADC_UNIT_1;  // ADC2 cannot be used when wifi is running

  val_type: Tesp_adc_cal_value_t;
  adc_reading: uint32;
  i: integer;
  raw: longint;
  voltage: uint32;

{$ifdef CONFIG_IDF_TARGET_ESP32}
procedure check_efuse;
begin
  //Check TP is burned into eFuse
  if (esp_adc_cal_check_efuse(ESP_ADC_CAL_VAL_EFUSE_TP) = ESP_OK) then
    writeln('eFuse Two Point: Supported')
  else
    writeln('eFuse Two Point: NOT supported');

    //Check Vref is burned into eFuse
  if (esp_adc_cal_check_efuse(ESP_ADC_CAL_VAL_EFUSE_VREF) = ESP_OK) then
    writeln('eFuse Vref: Supported')
  else
      writeln('eFuse Vref: NOT supported');
end;

procedure print_char_val_type(val_type: Tesp_adc_cal_value_t);
begin
  if (val_type = ESP_ADC_CAL_VAL_EFUSE_TP) then
    writeln('Characterized using Two Point Value\n')
  else if (val_type = ESP_ADC_CAL_VAL_EFUSE_VREF) then
    writeln('Characterized using eFuse Vref\n')
  else
    writeln('Characterized using Default Vref\n');
end;
{$endif}

begin
{$ifdef CONFIG_IDF_TARGET_ESP32}
  //Check if Two Point or Vref are burned into eFuse
  check_efuse();
{$endif}

  //Configure ADC
  if (ADCunitNo = ADC_UNIT_1) then
  begin
    writeln('adc1_config_width(ADC_WIDTH_BIT_12)');
    adc1_config_width(ADC_WIDTH_BIT_12);
    writeln('    adc1_config_channel_atten(Tadc1_channel_t(channel), atten)');
    adc1_config_channel_atten(Tadc1_channel_t(channel), atten);
  end
  else
    adc2_config_channel_atten(Tadc2_channel_t(channel), atten);

{$ifdef CONFIG_IDF_TARGET_ESP32}
  //Characterize ADC
  writeln('esp_adc_cal_characterize');
  val_type := esp_adc_cal_characterize(ADCunitNo, atten, ADC_WIDTH_BIT_12, DEFAULT_VREF, @adc_chars);
  print_char_val_type(val_type);
{$endif}

  repeat
    adc_reading := 0;
    for i := 0 to NO_OF_SAMPLES-1 do
    begin
      if (ADCunitNo = ADC_UNIT_1) then
        adc_reading := adc_reading + adc1_get_raw(Tadc1_channel_t(channel))
      else
      begin
        adc2_get_raw(Tadc2_channel_t(channel), ADC_WIDTH_BIT_12, @raw);
        adc_reading := adc_reading + raw;
      end;
    end;
    adc_reading := adc_reading div NO_OF_SAMPLES;
{$ifdef CONFIG_IDF_TARGET_ESP32}
    //Convert adc_reading to voltage in mV
    voltage := esp_adc_cal_raw_to_voltage(adc_reading, @adc_chars);
    writeln('Raw: ', adc_reading, #9'Voltage: ',voltage, 'mV');
    //writeln('Raw: %d\tVoltage: %dmV\n', adc_reading, voltage);
{$elseif defined(CONFIG_IDF_TARGET_ESP32S2BETA)}
    writeln('ADC', unit_, ' CH', channel, ' Raw: ', adc_reading);
    //writeln('ADC%d CH%d Raw: %d\t\n', unit_, channel, adc_reading);
{$endif}
    vTaskDelay(1000 div portTICK_PERIOD_MS);
  until false;
end.


(***Compile program with
~/fpc/avr-new/compiler/xtensa/pp -Fu~/fpc/avr-new/rtl/units/xtensa-freertos/ -Tfreertos -Cawindowed -XPxtensa-esp32-elf- -al -Wpesp32 -Fl~/xtensa/esp-idf/libs -Fl$HOME/.espressif/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/xtensa-esp32-elf/lib/ adc.pp

 ***Flash to esp32 with:

 - Assuming boot & partition for this sdk has been flashed before, only this app needs to be flashed:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 /home/christo/fpc/xtensa/adc/adc.bin

- If this is the first time a project with this IDF is built, also flash boot loader and partitions:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 /home/christo/fpc/xtensa/helloworld/bootloader.bin 0x10000 /home/christo/fpc/xtensa/adc/adc.bin 0x8000 /home/christo/fpc/xtensa/helloworld/partitions_singleapp.bin

*)
