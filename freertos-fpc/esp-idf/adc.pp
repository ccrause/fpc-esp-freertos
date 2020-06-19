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
  Padc1_channel = ^Tadc1_channel;
  Tadc1_channel = (ADC1_CHANNEL_0 = 0, ADC1_CHANNEL_1, ADC1_CHANNEL_2,
    ADC1_CHANNEL_3, ADC1_CHANNEL_4, ADC1_CHANNEL_5,
    ADC1_CHANNEL_6, ADC1_CHANNEL_7,
    {$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
    ADC1_CHANNEL_8, ADC1_CHANNEL_9,
    {$endif}
    ADC1_CHANNEL_MAX);

  Padc2_channel = ^Tadc2_channel;
  Tadc2_channel = (ADC2_CHANNEL_0 = 0, ADC2_CHANNEL_1, ADC2_CHANNEL_2,
    ADC2_CHANNEL_3, ADC2_CHANNEL_4, ADC2_CHANNEL_5,
    ADC2_CHANNEL_6, ADC2_CHANNEL_7, ADC2_CHANNEL_8,
    ADC2_CHANNEL_9, ADC2_CHANNEL_MAX);

  Padc_unit = ^Tadc_unit;
  Tadc_unit = (ADC_UNIT_1 = 1, ADC_UNIT_2 = 2, ADC_UNIT_BOTH = 3,
    ADC_UNIT_ALTER = 7, ADC_UNIT_MAX);

  Padc_i2s_encode = ^Tadc_i2s_encode;
  Tadc_i2s_encode = (ADC_ENCODE_12BIT, ADC_ENCODE_11BIT, ADC_ENCODE_MAX);

function adc1_pad_get_io_num(channel: Tadc1_channel;
  gpio_num: Pgpio_num): Tesp_err; external;
function adc1_config_width(width_bit: Tadc_bits_width): Tesp_err; external;
function adc_set_data_width(adc_unit: Tadc_unit;
  width_bit: Tadc_bits_width): Tesp_err; external;
function adc1_config_channel_atten(channel: Tadc1_channel;
  atten: Tadc_atten): Tesp_err; external;
function adc1_get_raw(channel: Tadc1_channel): int32; external;
procedure adc_power_on; external;
procedure adc_power_off; external;
function adc_gpio_init(adc_unit: Tadc_unit; channel: Tadc_channel): Tesp_err;
  external;
function adc_set_data_inv(adc_unit: Tadc_unit; inv_en: longbool): Tesp_err; external;
function adc_set_clk_div(clk_div: byte): Tesp_err; external;
function adc_set_i2s_data_source(src: Tadc_i2s_source_t): Tesp_err; external;
function adc_i2s_mode_init(adc_unit: Tadc_unit; channel: Tadc_channel): Tesp_err;
  external;
procedure adc1_ulp_enable; external;
function hall_sensor_read: int32; external;
function adc2_pad_get_io_num(channel: Tadc2_channel;
  gpio_num: Pgpio_num): Tesp_err; external;
function adc2_config_channel_atten(channel: Tadc2_channel;
  atten: Tadc_atten): Tesp_err; external;
function adc2_get_raw(channel: Tadc2_channel; width_bit: Tadc_bits_width;
  raw_out: Pint32): Tesp_err; external;
function adc2_vref_to_gpio(gpio: Tgpio_num): Tesp_err; external;

implementation

end.
