program adctest;

{$include freertosconfig.inc}

uses
  esp_err, adc, task, portmacro;

const
  NO_OF_SAMPLES = 64;

var
  adc_config: Tadc_config;
  adc_reading, adc_total: uint16;
  i: integer;

begin
  // Depend on menuconfig->Component config->PHY->vdd33_const value
  // When measuring system voltage(ADC_READ_VDD_MODE), vdd33_const must be set to 255.
  adc_config.mode := ADC_READ_TOUT_MODE;
  adc_config.clk_div := 8; // ADC sample collection clock = 80MHz/clk_div = 10MHz
  EspErrorCheck(adc_init(@adc_config));

  repeat
    adc_total := 0;
    for i := 0 to NO_OF_SAMPLES-1 do
    begin
      EspErrorCheck(adc_read(@adc_reading));
      adc_reading := adc_reading + adc_reading;
    end;

    adc_total := adc_total div NO_OF_SAMPLES;
    writeln('ADC', ' Raw: ', adc_reading);

    vTaskDelay(1000 div portTICK_PERIOD_MS);
  until false;
end.
