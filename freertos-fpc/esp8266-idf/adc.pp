unit adc;

interface

uses
  esp_err;

type
  Padc_mode = ^Tadc_mode;
  Tadc_mode = (ADC_READ_TOUT_MODE = 0, ADC_READ_VDD_MODE,
    ADC_READ_MAX_MODE);

  Padc_config = ^Tadc_config;
  Tadc_config = record
    mode: Tadc_mode;
    clk_div: byte;
  end;

function adc_read(Data: puint16): Tesp_err; external;
function adc_read_fast(Data: puint16; len: uint16): Tesp_err; external;
function adc_deinit: Tesp_err; external;
function adc_init(config: Padc_config): Tesp_err; external;

implementation

end.
