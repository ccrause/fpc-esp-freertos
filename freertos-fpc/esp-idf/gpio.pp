unit gpio;

{$include sdkconfig.inc}

interface
// Translated from esp_rom/include/esp32/rom/gpio.h
// Differences between esp32 and esp32s2 are ifdef'ed below
uses
  esp_err, esp_bit_defs, gpio_types;

const
  GPIO_ID_PIN0 = 0;
  GPIO_FUNC_IN_HIGH = $38;
  {$ifdef CONFIG_IDF_TARGET_ESP32}
  GPIO_FUNC_IN_LOW = $30;
  {$else}
  GPIO_FUNC_IN_LOW = $3C;
  {$endif}

type
  Tgpio_intr_handler_fn = procedure(intr_mask: uint32; high: longbool;
    arg: pointer);

procedure gpio_init; external;
procedure gpio_output_set(set_mask: uint32; clear_mask: uint32;
  enable_mask: uint32; disable_mask: uint32); external;
procedure gpio_output_set_high(set_mask: uint32; clear_mask: uint32;
  enable_mask: uint32; disable_mask: uint32); external;
function gpio_input_get: uint32; external;
function gpio_input_get_high: uint32; external;
procedure gpio_intr_handler_register(fn: Tgpio_intr_handler_fn;
  arg: pointer); external;
function gpio_intr_pending: uint32; external;
function gpio_intr_pending_high: uint32; external;
procedure gpio_intr_ack(ack_mask: uint32); external;
procedure gpio_intr_ack_high(ack_mask: uint32); external;
procedure gpio_pin_wakeup_enable(i: uint32; intr_state: TGPIO_INT_TYPE); external;
procedure gpio_pin_wakeup_disable; external;
procedure gpio_matrix_in(gpio: uint32; signal_idx: uint32; inv: longbool); external;
procedure gpio_matrix_out(gpio: uint32; signal_idx: uint32;
  out_inv: longbool; oen_inv: longbool); external;
procedure gpio_pad_select_gpio(gpio_num: byte); external;
procedure gpio_pad_set_drv(gpio_num: byte; drv: byte); external;
procedure gpio_pad_pullup(gpio_num: byte); external;
procedure gpio_pad_pulldown(gpio_num: byte); external;
procedure gpio_pad_unhold(gpio_num: byte); external;
procedure gpio_pad_hold(gpio_num: byte); external;

// Translation of driver/include/driver/gpio.h
type
  Tgpio_isr_handle = pointer;
  Pgpio_isr_handle = ^Tgpio_isr_handle;
  TIsrProc = procedure(para: pointer);

function gpio_config(constref GPIOConfig: Tgpio_config): Tesp_err; external;
function gpio_reset_pin(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_set_intr_type(gpio_num: Tgpio_num;
  intr_type: Tgpio_int_type): Tesp_err; external;
function gpio_intr_enable(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_intr_disable(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_set_level(gpio_num: Tgpio_num; level: uint32): Tesp_err; external;
function gpio_get_level(gpio_num: Tgpio_num): int32; external;
function gpio_set_direction(gpio_num: Tgpio_num; mode: Tgpio_mode): Tesp_err;
  external;
function gpio_set_pull_mode(gpio_num: Tgpio_num; pull: Tgpio_pull_mode): Tesp_err;
  external;
function gpio_wakeup_enable(gpio_num: Tgpio_num;
  intr_type: Tgpio_int_type): Tesp_err; external;
function gpio_wakeup_disable(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_isr_register(fn: TIsrProc; arg: pointer;
  intr_alloc_flags: int32; handle: Pgpio_isr_handle): Tesp_err; external;
function gpio_pullup_en(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pullup_dis(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pulldown_en(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_pulldown_dis(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_install_isr_service(intr_alloc_flags: int32): Tesp_err; external;
procedure gpio_uninstall_isr_service; external;
function gpio_isr_handler_add(gpio_num: Tgpio_num; isr_handler: Tgpio_isr;
  args: pointer): Tesp_err; external;
function gpio_isr_handler_remove(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_set_drive_capability(gpio_num: Tgpio_num;
  strength: Tgpio_drive_cap): Tesp_err; external;
function gpio_get_drive_capability(gpio_num: Tgpio_num;
  strength: Pgpio_drive_cap): Tesp_err; external;
function gpio_hold_en(gpio_num: Tgpio_num): Tesp_err; external;
function gpio_hold_dis(gpio_num: Tgpio_num): Tesp_err; external;
procedure gpio_deep_sleep_hold_en; external;
procedure gpio_deep_sleep_hold_dis; external;
procedure gpio_iomux_in(gpio_num: uint32; signal_idx: uint32); external;
procedure gpio_iomux_out(gpio_num: byte; func: int32; oen_inv: longbool); external;
{$ifdef GPIO_SUPPORTS_FORCE_HOLD}
function gpio_force_hold_all: Tesp_err; external;
function gpio_force_unhold_all: Tesp_err; external;
{$endif}

//function GPIO_REG_READ(reg: longint): longint;
//function GPIO_REG_WRITE(reg, val: longint): longint;
//function GPIO_ID_PIN(n: longint): longint;
//function GPIO_PIN_ADDR(i: longint): longint;
//function GPIO_ID_IS_PIN_REGISTER(reg_id: longint): longint;
//function GPIO_REGID_TO_PINIDX(reg_id: longint): Treg_id;
procedure GPIO_OUTPUT_SET(gpio_no, bit_value: longint);
procedure GPIO_DIS_OUTPUT(gpio_no: longint);
function GPIO_INPUT_GET(gpio_no: longint): longint;

implementation

procedure GPIO_OUTPUT_SET(gpio_no, bit_value: longint);
var
  bv: uint32;
begin
  if bit_value = 0 then
    bv := 0
  else
    bv := 1;

  if gpio_no < 32 then
    gpio_output_set(bit_value shl gpio_no, bv shl gpio_no, 1 shl gpio_no, 0)
  else
    gpio_output_set_high(bit_value shl (gpio_no - 32),
      bv shl (gpio_no - 32), 1 shl (gpio_no - 32), 0);
end;

procedure GPIO_DIS_OUTPUT(gpio_no: longint);
begin
  if gpio_no < 32 then
    gpio_output_set(0, 0, 0, 1 shl gpio_no)
  else
    gpio_output_set_high(0, 0, 0, 1 shl (gpio_no - 32));
end;

function GPIO_INPUT_GET(gpio_no: longint): longint;
begin
  if gpio_no < 32 then
    GPIO_INPUT_GET := (gpio_input_get shr gpio_no) and BIT0
  else
    GPIO_INPUT_GET := (gpio_input_get_high shr (gpio_no - 32)) and BIT0;
end;

end.
