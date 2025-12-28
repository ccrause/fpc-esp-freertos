unit gpio_types;

{$include sdkconfig.inc}

interface

uses
  esp_bit_defs, io_mux_reg, gpio_caps;

type
  Pgpio_port = ^Tgpio_port;
  Tgpio_port = (GPIO_PORT_0 = 0, GPIO_PORT_MAX);

const
  GPIO_SEL_0              = BIT0;
  GPIO_SEL_1              = BIT1;
  GPIO_SEL_2              = BIT2;
  GPIO_SEL_3              = BIT3;
  GPIO_SEL_4              = BIT4;
  GPIO_SEL_5              = BIT5;
  GPIO_SEL_6              = BIT6;
  GPIO_SEL_7              = BIT7;
  GPIO_SEL_8              = BIT8;
  GPIO_SEL_9              = BIT9;
  GPIO_SEL_10             = BIT10;
  GPIO_SEL_11             = BIT11;
  GPIO_SEL_12             = BIT12;
  GPIO_SEL_13             = BIT13;
  GPIO_SEL_14             = BIT14;
  GPIO_SEL_15             = BIT15;
  GPIO_SEL_16             = BIT16;
  GPIO_SEL_17             = BIT17;
  GPIO_SEL_18             = BIT18;
  GPIO_SEL_19             = BIT19;
  GPIO_SEL_20             = BIT20;
  GPIO_SEL_21             = BIT21;
{$ifdef CONFIG_IDF_TARGET_ESP32}
  GPIO_SEL_22             = BIT22;
  GPIO_SEL_23             = BIT23;

  GPIO_SEL_25             = BIT25;
{$endif}
  GPIO_SEL_26             = BIT26;
  GPIO_SEL_27             = BIT27;
  GPIO_SEL_28             = BIT28;
  GPIO_SEL_29             = BIT29;
  GPIO_SEL_30             = BIT30;
  GPIO_SEL_31             = BIT31;
  GPIO_SEL_32             = 1 shl 32;
  GPIO_SEL_33             = 1 shl 33;
  GPIO_SEL_34             = 1 shl 34;
  GPIO_SEL_35             = 1 shl 35;
  GPIO_SEL_36             = 1 shl 36;
  GPIO_SEL_37             = 1 shl 37;
  GPIO_SEL_38             = 1 shl 38;
  GPIO_SEL_39             = 1 shl 39;
{$if defined(GPIO_PIN_COUNT) and (GPIO_PIN_COUNT > 40)}
  GPIO_SEL_40             = 1 shl 40;
  GPIO_SEL_41             = 1 shl 41;
  GPIO_SEL_42             = 1 shl 42;
  GPIO_SEL_43             = 1 shl 43;
  GPIO_SEL_44             = 1 shl 44;
  GPIO_SEL_45             = 1 shl 45;
  GPIO_SEL_46             = 1 shl 46;
{$endif}
  GPIO_PIN_REG_0          = IO_MUX_GPIO0_REG;
  GPIO_PIN_REG_1          = IO_MUX_GPIO1_REG;
  GPIO_PIN_REG_2          = IO_MUX_GPIO2_REG;
  GPIO_PIN_REG_3          = IO_MUX_GPIO3_REG;
  GPIO_PIN_REG_4          = IO_MUX_GPIO4_REG;
  GPIO_PIN_REG_5          = IO_MUX_GPIO5_REG;
  GPIO_PIN_REG_6          = IO_MUX_GPIO6_REG;
  GPIO_PIN_REG_7          = IO_MUX_GPIO7_REG;
  GPIO_PIN_REG_8          = IO_MUX_GPIO8_REG;
  GPIO_PIN_REG_9          = IO_MUX_GPIO9_REG;
  GPIO_PIN_REG_10         = IO_MUX_GPIO10_REG;
  GPIO_PIN_REG_11         = IO_MUX_GPIO11_REG;
  GPIO_PIN_REG_12         = IO_MUX_GPIO12_REG;
  GPIO_PIN_REG_13         = IO_MUX_GPIO13_REG;
  GPIO_PIN_REG_14         = IO_MUX_GPIO14_REG;
  GPIO_PIN_REG_15         = IO_MUX_GPIO15_REG;
  GPIO_PIN_REG_16         = IO_MUX_GPIO16_REG;
  GPIO_PIN_REG_17         = IO_MUX_GPIO17_REG;
  GPIO_PIN_REG_18         = IO_MUX_GPIO18_REG;
  GPIO_PIN_REG_19         = IO_MUX_GPIO19_REG;
  GPIO_PIN_REG_20         = IO_MUX_GPIO20_REG;
  GPIO_PIN_REG_21         = IO_MUX_GPIO21_REG;
  GPIO_PIN_REG_22         = IO_MUX_GPIO22_REG;
  GPIO_PIN_REG_23         = IO_MUX_GPIO23_REG;
  GPIO_PIN_REG_24         = IO_MUX_GPIO24_REG;
  GPIO_PIN_REG_25         = IO_MUX_GPIO25_REG;
  GPIO_PIN_REG_26         = IO_MUX_GPIO26_REG;
  GPIO_PIN_REG_27         = IO_MUX_GPIO27_REG;
{$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
  GPIO_PIN_REG_28         = IO_MUX_GPIO28_REG;
  GPIO_PIN_REG_29         = IO_MUX_GPIO29_REG;
  GPIO_PIN_REG_30         = IO_MUX_GPIO30_REG;
  GPIO_PIN_REG_31         = IO_MUX_GPIO31_REG;
{$endif}
  GPIO_PIN_REG_32         = IO_MUX_GPIO32_REG;
  GPIO_PIN_REG_33         = IO_MUX_GPIO33_REG;
  GPIO_PIN_REG_34         = IO_MUX_GPIO34_REG;
  GPIO_PIN_REG_35         = IO_MUX_GPIO35_REG;
  GPIO_PIN_REG_36         = IO_MUX_GPIO36_REG;
  GPIO_PIN_REG_37         = IO_MUX_GPIO37_REG;
  GPIO_PIN_REG_38         = IO_MUX_GPIO38_REG;
  GPIO_PIN_REG_39         = IO_MUX_GPIO39_REG;
{$if defined(GPIO_PIN_COUNT) and (GPIO_PIN_COUNT > 40)}
  GPIO_PIN_REG_40         = IO_MUX_GPIO40_REG;
  GPIO_PIN_REG_41         = IO_MUX_GPIO41_REG;
  GPIO_PIN_REG_42         = IO_MUX_GPIO42_REG;
  GPIO_PIN_REG_43         = IO_MUX_GPIO43_REG;
  GPIO_PIN_REG_44         = IO_MUX_GPIO44_REG;
  GPIO_PIN_REG_45         = IO_MUX_GPIO45_REG;
  GPIO_PIN_REG_46         = IO_MUX_GPIO46_REG;
{$endif}

type
  Pgpio_num = ^Tgpio_num;
  Tgpio_num = (GPIO_NUM_NC = -(1), GPIO_NUM_0 = 0, GPIO_NUM_1 = 1,
    GPIO_NUM_2 = 2, GPIO_NUM_3 = 3, GPIO_NUM_4 = 4,
    GPIO_NUM_5 = 5, GPIO_NUM_6 = 6, GPIO_NUM_7 = 7,
    GPIO_NUM_8 = 8, GPIO_NUM_9 = 9, GPIO_NUM_10 = 10,
    GPIO_NUM_11 = 11, GPIO_NUM_12 = 12, GPIO_NUM_13 = 13,
    GPIO_NUM_14 = 14, GPIO_NUM_15 = 15, GPIO_NUM_16 = 16,
    GPIO_NUM_17 = 17, GPIO_NUM_18 = 18, GPIO_NUM_19 = 19,
    GPIO_NUM_20 = 20, GPIO_NUM_21 = 21,
    {$ifdef CONFIG_IDF_TARGET_ESP32}
    GPIO_NUM_22 = 22,
    GPIO_NUM_23 = 23, GPIO_NUM_25 = 25,
    {$endif}
    GPIO_NUM_26 = 26,
    GPIO_NUM_27 = 27, GPIO_NUM_28 = 28, GPIO_NUM_29 = 29,
    GPIO_NUM_30 = 30, GPIO_NUM_31 = 31, GPIO_NUM_32 = 32,
    GPIO_NUM_33 = 33, GPIO_NUM_34 = 34, GPIO_NUM_35 = 35,
    GPIO_NUM_36 = 36, GPIO_NUM_37 = 37, GPIO_NUM_38 = 38,
    GPIO_NUM_39 = 39,
    {$if defined(GPIO_PIN_COUNT) and (GPIO_PIN_COUNT > 40)}
    GPIO_NUM_40 = 40, GPIO_NUM_41 = 41,
    GPIO_NUM_42 = 42, GPIO_NUM_43 = 43, GPIO_NUM_44 = 44,
    GPIO_NUM_45 = 45, GPIO_NUM_46 = 46,
    {$endif}
    GPIO_NUM_MAX);

  Pgpio_int_type = ^Tgpio_int_type;
  Tgpio_int_type = (GPIO_INTR_DISABLE = 0, GPIO_INTR_POSEDGE = 1,
    GPIO_INTR_NEGEDGE = 2, GPIO_INTR_ANYEDGE = 3,
    GPIO_INTR_LOW_LEVEL = 4, GPIO_INTR_HIGH_LEVEL = 5,
    GPIO_INTR_MAX);

  Pgpio_mode = ^Tgpio_mode;
  Tgpio_mode = (
    GPIO_MODE_DISABLE = GPIO_MODE_DEF_DISABLE,
    GPIO_MODE_INPUT = GPIO_MODE_DEF_INPUT,
    GPIO_MODE_OUTPUT = GPIO_MODE_DEF_OUTPUT,
    GPIO_MODE_INPUT_OUTPUT = GPIO_MODE_DEF_INPUT or GPIO_MODE_DEF_OUTPUT,
    GPIO_MODE_OUTPUT_OD = GPIO_MODE_DEF_OUTPUT or GPIO_MODE_DEF_OD,
    GPIO_MODE_INPUT_OUTPUT_OD = (GPIO_MODE_DEF_INPUT or GPIO_MODE_DEF_OUTPUT) or GPIO_MODE_DEF_OD
    );

  Pgpio_pullup = ^Tgpio_pullup;
  Tgpio_pullup = (GPIO_PULLUP_DISABLE = $0, GPIO_PULLUP_ENABLE = $1);

  Pgpio_pulldown = ^Tgpio_pulldown;
  Tgpio_pulldown = (GPIO_PULLDOWN_DISABLE = $0, GPIO_PULLDOWN_ENABLE = $1);

  Pgpio_config = ^Tgpio_config;
  Tgpio_config = record
    pin_bit_mask: uint64;
    mode: Tgpio_mode;
    pull_up_en: Tgpio_pullup;
    pull_down_en: Tgpio_pulldown;
    intr_type: Tgpio_int_type;
  end;

  Pgpio_pull_mode = ^Tgpio_pull_mode;
  Tgpio_pull_mode = (GPIO_PULLUP_ONLY, GPIO_PULLDOWN_ONLY, GPIO_PULLUP_PULLDOWN,
    GPIO_FLOATING);

  Pgpio_drive_cap = ^Tgpio_drive_cap;
  Tgpio_drive_cap = (GPIO_DRIVE_CAP_0 = 0, GPIO_DRIVE_CAP_1 = 1,
    GPIO_DRIVE_CAP_2 = 2, GPIO_DRIVE_CAP_DEFAULT = 2,
    GPIO_DRIVE_CAP_3 = 3, GPIO_DRIVE_CAP_MAX);

  Tgpio_isr = procedure(para1: pointer);

implementation

end.
