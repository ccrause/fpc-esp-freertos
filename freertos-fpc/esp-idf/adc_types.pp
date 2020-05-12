unit adc_types;

{$include sdkconfig.inc}

interface

type
  Padc_channel_t = ^Tadc_channel_t;
  Tadc_channel_t = (ADC_CHANNEL_0 = 0, ADC_CHANNEL_1, ADC_CHANNEL_2,
    ADC_CHANNEL_3, ADC_CHANNEL_4, ADC_CHANNEL_5,
    ADC_CHANNEL_6, ADC_CHANNEL_7, ADC_CHANNEL_8,
    ADC_CHANNEL_9, ADC_CHANNEL_MAX);

  Padc_atten_t = ^Tadc_atten_t;
  Tadc_atten_t = (ADC_ATTEN_DB_0 = 0, ADC_ATTEN_DB_2_5 = 1,
    ADC_ATTEN_DB_6 = 2, ADC_ATTEN_DB_11 = 3,
    ADC_ATTEN_MAX);

  Padc_i2s_source_t = ^Tadc_i2s_source_t;
  Tadc_i2s_source_t = (ADC_I2S_DATA_SRC_IO_SIG = 0, ADC_I2S_DATA_SRC_ADC = 1,
    ADC_I2S_DATA_SRC_MAX);

  Padc_bits_width_t = ^Tadc_bits_width_t;
  Tadc_bits_width_t = (ADC_WIDTH_BIT_9 = 0, ADC_WIDTH_BIT_10 = 1,
    ADC_WIDTH_BIT_11 = 2, ADC_WIDTH_BIT_12 = 3,
    ADC_WIDTH_MAX);

implementation

end.
