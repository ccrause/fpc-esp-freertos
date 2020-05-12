unit gpio_caps;

interface

uses
  esp_bit_defs;

const
  SOC_GPIO_PORT                 = 1;
  GPIO_PIN_COUNT                = 40;
  GPIO_SUPPORTS_RTC_INDEPENDENT = 0;
  GPIO_SUPPORTS_FORCE_HOLD      = 0;
  GPIO_APP_CPU_INTR_ENA         = BIT0;
  GPIO_APP_CPU_NMI_INTR_ENA     = BIT1;
  GPIO_PRO_CPU_INTR_ENA         = BIT2;
  GPIO_PRO_CPU_NMI_INTR_ENA     = BIT3;
  GPIO_SDIO_EXT_INTR_ENA        = BIT4;
  GPIO_MODE_DEF_DISABLE         = 0;
  GPIO_MODE_DEF_INPUT           = BIT0;
  GPIO_MODE_DEF_OUTPUT          = BIT1;
  GPIO_MODE_DEF_OD              = BIT2;

implementation

end.
