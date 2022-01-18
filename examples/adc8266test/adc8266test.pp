program adcesp8266test;

{$include freertosconfig.inc}

uses
  esp_err, adc, task, portmacro;

const
  NO_OF_SAMPLES = 64;  // Note: more samples could lead to 16 bit overflow (65 * 1023 = 66496)

var
  adc_config: Tadc_config;
  adc_reading, adc_average: uint16;
  i: integer;

begin
  // Depend on menuconfig->Component config->PHY->vdd33_const value
  // When measuring system voltage(ADC_READ_VDD_MODE), vdd33_const must be set to 255.
  adc_config.mode := ADC_READ_TOUT_MODE;
  adc_config.clk_div := 32; // ADC sample collection clock = 80MHz/clk_div = 2.5MHz
  EspErrorCheck(adc_init(@adc_config));

  repeat
    adc_average := 0;
    for i := 0 to NO_OF_SAMPLES-1 do
    begin
      EspErrorCheck(adc_read(@adc_reading));
      adc_average := adc_average + adc_reading;
    end;

    adc_average := adc_average div NO_OF_SAMPLES;
    writeln('ADC: ', adc_average);

    vTaskDelay(1000 div portTICK_PERIOD_MS);
  until false;
end.
