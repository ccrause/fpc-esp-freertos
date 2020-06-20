unit gpio;

interface

uses
  eagle_soc, esp_err;

const
  GPIO_Pin_0   = BIT0;
  GPIO_Pin_1   = BIT1;
  GPIO_Pin_2   = BIT2;
  GPIO_Pin_3   = BIT3;
  GPIO_Pin_4   = BIT4;
  GPIO_Pin_5   = BIT5;
  GPIO_Pin_6   = BIT6;
  GPIO_Pin_7   = BIT7;
  GPIO_Pin_8   = BIT8;
  GPIO_Pin_9   = BIT9;
  GPIO_Pin_10  = BIT10;
  GPIO_Pin_11  = BIT11;
  GPIO_Pin_12  = BIT12;
  GPIO_Pin_13  = BIT13;
  GPIO_Pin_14  = BIT14;
  GPIO_Pin_15  = BIT15;
  GPIO_Pin_16  = BIT16;
  GPIO_Pin_All = $1FFFF;
  GPIO_MODE_DEF_DISABLE     = 0;
  GPIO_MODE_DEF_INPUT       = BIT0;
  GPIO_MODE_DEF_OUTPUT      = BIT1;
  GPIO_MODE_DEF_OD          = BIT2;
  GPIO_PIN_COUNT = 17;

type
  Pgpio_num = ^Tgpio_num;
  Tgpio_num = (GPIO_NUM_0 = 0, GPIO_NUM_1 = 1, GPIO_NUM_2 = 2,
    GPIO_NUM_3 = 3, GPIO_NUM_4 = 4, GPIO_NUM_5 = 5,
    GPIO_NUM_6 = 6, GPIO_NUM_7 = 7, GPIO_NUM_8 = 8,
    GPIO_NUM_9 = 9, GPIO_NUM_10 = 10, GPIO_NUM_11 = 11,
    GPIO_NUM_12 = 12, GPIO_NUM_13 = 13, GPIO_NUM_14 = 14,
    GPIO_NUM_15 = 15, GPIO_NUM_16 = 16, GPIO_NUM_MAX = 17);

  Pgpio_int_type = ^Tgpio_int_type;
  Tgpio_int_type = (GPIO_INTR_DISABLE = 0, GPIO_INTR_POSEDGE = 1,
    GPIO_INTR_NEGEDGE = 2, GPIO_INTR_ANYEDGE = 3,
    GPIO_INTR_LOW_LEVEL = 4, GPIO_INTR_HIGH_LEVEL = 5,
    GPIO_INTR_MAX);

  Pgpio_mode = ^Tgpio_mode;
  Tgpio_mode = (GPIO_MODE_DISABLE = GPIO_MODE_DEF_DISABLE, GPIO_MODE_INPUT =
    GPIO_MODE_DEF_INPUT,
    GPIO_MODE_OUTPUT = GPIO_MODE_DEF_OUTPUT, GPIO_MODE_OUTPUT_OD =
    GPIO_MODE_DEF_OUTPUT or GPIO_MODE_DEF_OD);

  Pgpio_pull_mode = ^Tgpio_pull_mode;
  Tgpio_pull_mode = (GPIO_PULLUP_ONLY, GPIO_PULLDOWN_ONLY, GPIO_FLOATING);

  Pgpio_pullup = ^Tgpio_pullup;
  Tgpio_pullup = (GPIO_PULLUP_DISABLE = $0, GPIO_PULLUP_ENABLE = $1);

  Pgpio_pulldown = ^Tgpio_pulldown;
  Tgpio_pulldown = (GPIO_PULLDOWN_DISABLE = $0, GPIO_PULLDOWN_ENABLE = $1);

  Pgpio_config = ^Tgpio_config;
  Tgpio_config = record
    pin_bit_mask: uint32;
    mode: Tgpio_mode;
    pull_up_en: Tgpio_pullup;
    pull_down_en: Tgpio_pulldown;
    intr_type: Tgpio_int_type;
  end;

  Tgpio_isr = procedure(para1: pointer);
  Pgpio_isr_handle = ^Tgpio_isr_handle;
  Tgpio_isr_handle = pointer;

  TIsrProc = procedure(para: pointer);

function gpio_config(constref gpio_cfg: Tgpio_config): Tesp_err; external;
function gpio_set_intr_type(gpio_num: Tgpio_num;
  intr_type: Tgpio_int_type): Tesp_err; external;
function gpio_set_level(gpio_num: Tgpio_num; level: uint32): Tesp_err; external;
function gpio_get_level(gpio_num: Tgpio_num): longint; external;
function gpio_set_direction(gpio_num: Tgpio_num; mode: Tgpio_mode): Tesp_err;
  external;
function gpio_set_pull_mode(gpio_num: Tgpio_num; pull: Tgpio_pull_mode): Tesp_err;
  external;
function gpio_wakeup_enable(gpio_num: Tgpio_num;
  intr_type: Tgpio_int_type): Tesp_err; external;
function gpio_wakeup_disable(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_isr_register(fn: TIsrProc; arg: pointer;
  no_use: longint; handle_no_use: Pgpio_isr_handle): Tesp_err; external;
function gpio_pullup_en(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pullup_dis(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pulldown_en(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pulldown_dis(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_install_isr_service(no_use: longint): Tesp_err; external;
procedure gpio_uninstall_isr_service; external;
function gpio_isr_handler_add(gpio_num: Tgpio_num; isr_handler: Tgpio_isr;
  args: pointer): Tesp_err; external;
function gpio_isr_handler_remove(gpio_num: Tgpio_num): Tesp_err; external;

implementation

end.
