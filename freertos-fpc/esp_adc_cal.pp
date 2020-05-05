unit esp_adc_cal;

{$linklib esp_adc_cal, static}

interface

uses
  esp_err, adc_types, adc;

type
  Puint32 = ^uint32;

  Pesp_adc_cal_value_t = ^Tesp_adc_cal_value_t;
  Tesp_adc_cal_value_t = (ESP_ADC_CAL_VAL_EFUSE_VREF = 0, ESP_ADC_CAL_VAL_EFUSE_TP = 1,
    ESP_ADC_CAL_VAL_DEFAULT_VREF = 2);

  Pesp_adc_cal_characteristics_t = ^Tesp_adc_cal_characteristics_t;
  Tesp_adc_cal_characteristics_t = record
    adc_num: Tadc_unit_t;
    atten: Tadc_atten_t;
    bit_width: Tadc_bits_width_t;
    coeff_a: uint32;
    coeff_b: uint32;
    vref: uint32;
    low_curve: Puint32;
    high_curve: Puint32;
  end;

function esp_adc_cal_check_efuse(value_type: Tesp_adc_cal_value_t): Tesp_err_t;
  cdecl; external;

function esp_adc_cal_characterize(adc_num: Tadc_unit_t; atten: Tadc_atten_t;
  bit_width: Tadc_bits_width_t; default_vref: uint32;
  chars: Pesp_adc_cal_characteristics_t): Tesp_adc_cal_value_t; cdecl; external;

function esp_adc_cal_raw_to_voltage(adc_reading: uint32;
  chars: Pesp_adc_cal_characteristics_t): uint32; cdecl; external;

function esp_adc_cal_get_voltage(channel: Tadc_channel_t;
  chars: Pesp_adc_cal_characteristics_t; voltage: Puint32): Tesp_err_t; cdecl; external;

implementation

end.
