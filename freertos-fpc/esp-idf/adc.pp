unit adc;

interface

{$include sdkconfig.inc}

uses
  esp_err, gpio, adc_types, gpio_types;

const
  ADC_ATTEN_0db = ADC_ATTEN_DB_0;
  ADC_ATTEN_2_5db = ADC_ATTEN_DB_2_5;
  ADC_ATTEN_6db = ADC_ATTEN_DB_6;
  ADC_ATTEN_11db = ADC_ATTEN_DB_11;
  ADC_WIDTH_9Bit = ADC_WIDTH_BIT_9;
  ADC_WIDTH_10Bit = ADC_WIDTH_BIT_10;
  ADC_WIDTH_11Bit = ADC_WIDTH_BIT_11;
  ADC_WIDTH_12Bit = ADC_WIDTH_BIT_12;

type
  Padc1_channel_t = ^Tadc1_channel_t;
  Tadc1_channel_t = (ADC1_CHANNEL_0 = 0, ADC1_CHANNEL_1, ADC1_CHANNEL_2,
    ADC1_CHANNEL_3, ADC1_CHANNEL_4, ADC1_CHANNEL_5,
    ADC1_CHANNEL_6, ADC1_CHANNEL_7,
    {$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
    ADC1_CHANNEL_8, ADC1_CHANNEL_9,
    {$endif}
    ADC1_CHANNEL_MAX);

  Padc2_channel_t = ^Tadc2_channel_t;
  Tadc2_channel_t = (ADC2_CHANNEL_0 = 0, ADC2_CHANNEL_1, ADC2_CHANNEL_2,
    ADC2_CHANNEL_3, ADC2_CHANNEL_4, ADC2_CHANNEL_5,
    ADC2_CHANNEL_6, ADC2_CHANNEL_7, ADC2_CHANNEL_8,
    ADC2_CHANNEL_9, ADC2_CHANNEL_MAX);

  Padc_unit_t = ^Tadc_unit_t;
  Tadc_unit_t = (ADC_UNIT_1 = 1, ADC_UNIT_2 = 2, ADC_UNIT_BOTH = 3,
    ADC_UNIT_ALTER = 7, ADC_UNIT_MAX);

  Padc_i2s_encode_t = ^Tadc_i2s_encode_t;
  Tadc_i2s_encode_t = (ADC_ENCODE_12BIT, ADC_ENCODE_11BIT, ADC_ENCODE_MAX);

function adc1_pad_get_io_num(channel: Tadc1_channel_t;
  gpio_num: Pgpio_num_t): Tesp_err_t; cdecl; external;

function adc1_config_width(width_bit: Tadc_bits_width_t): Tesp_err_t; cdecl; external;

function adc_set_data_width(adc_unit: Tadc_unit_t;
  width_bit: Tadc_bits_width_t): Tesp_err_t; cdecl; external;

function adc1_config_channel_atten(channel: Tadc1_channel_t;
  atten: Tadc_atten_t): Tesp_err_t; cdecl; external;

function adc1_get_raw(channel: Tadc1_channel_t): int32; cdecl; external;

procedure adc_power_on; cdecl; external;

procedure adc_power_off; cdecl; external;

function adc_gpio_init(adc_unit: Tadc_unit_t; channel: Tadc_channel_t): Tesp_err_t;
  cdecl; external;

function adc_set_data_inv(adc_unit: Tadc_unit_t; inv_en: longbool): Tesp_err_t; cdecl; external;

function adc_set_clk_div(clk_div: byte): Tesp_err_t; cdecl; external;

function adc_set_i2s_data_source(src: Tadc_i2s_source_t): Tesp_err_t; cdecl; external;

function adc_i2s_mode_init(adc_unit: Tadc_unit_t; channel: Tadc_channel_t): Tesp_err_t;
  cdecl; external;

procedure adc1_ulp_enable; cdecl; external;

function hall_sensor_read: int32; cdecl; external;

function adc2_pad_get_io_num(channel: Tadc2_channel_t;
  gpio_num: Pgpio_num_t): Tesp_err_t; cdecl; external;

function adc2_config_channel_atten(channel: Tadc2_channel_t;
  atten: Tadc_atten_t): Tesp_err_t; cdecl; external;

function adc2_get_raw(channel: Tadc2_channel_t; width_bit: Tadc_bits_width_t;
  raw_out: Pint32): Tesp_err_t; cdecl; external;

function adc2_vref_to_gpio(gpio: Tgpio_num_t): Tesp_err_t; cdecl; external;

implementation

end.
