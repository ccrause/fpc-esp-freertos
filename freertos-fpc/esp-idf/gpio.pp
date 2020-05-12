unit gpio;

{$include sdkconfig.inc}

interface
// Translated from esp_rom/include/esp32/rom/gpio.h
// Differences between esp32 and esp32s2 are ifdef'ed below
uses
  esp_err, esp_bit_defs, gpio_types, io_mux_reg;

const
  GPIO_ID_PIN0 = 0;
  GPIO_FUNC_IN_HIGH = $38;
  {$ifdef CONFIG_IDF_TARGET_ESP32}
  GPIO_FUNC_IN_LOW = $30;
  {$else}
  GPIO_FUNC_IN_LOW = $3C;
  {$endif}

type
  PGPIO_INT_TYPE = ^TGPIO_INT_TYPE;
  TGPIO_INT_TYPE = (GPIO_PIN_INTR_DISABLE = 0, GPIO_PIN_INTR_POSEDGE = 1,
    GPIO_PIN_INTR_NEGEDGE = 2, GPIO_PIN_INTR_ANYEDGE = 3,
    GPIO_PIN_INTR_LOLEVEL = 4, GPIO_PIN_INTR_HILEVEL = 5);

  Tgpio_intr_handler_fn_t = procedure(intr_mask: uint32; high: longbool;
    arg: pointer); cdecl;


procedure gpio_init; cdecl; external;

procedure gpio_output_set(set_mask: uint32; clear_mask: uint32;
  enable_mask: uint32; disable_mask: uint32); cdecl; external;

procedure gpio_output_set_high(set_mask: uint32; clear_mask: uint32;
  enable_mask: uint32; disable_mask: uint32); cdecl; external;

function gpio_input_get: uint32; cdecl; external;

function gpio_input_get_high: uint32; cdecl; external;

procedure gpio_intr_handler_register(fn: Tgpio_intr_handler_fn_t;
  arg: pointer); cdecl; external;

function gpio_intr_pending: uint32; cdecl; external;

function gpio_intr_pending_high: uint32; cdecl; external;

procedure gpio_intr_ack(ack_mask: uint32); cdecl; external;

procedure gpio_intr_ack_high(ack_mask: uint32); cdecl; external;

procedure gpio_pin_wakeup_enable(i: uint32; intr_state: TGPIO_INT_TYPE); cdecl; external;

procedure gpio_pin_wakeup_disable; cdecl; external;

procedure gpio_matrix_in(gpio: uint32; signal_idx: uint32; inv: longbool); cdecl; external;

procedure gpio_matrix_out(gpio: uint32; signal_idx: uint32;
  out_inv: longbool; oen_inv: longbool); cdecl; external;

procedure gpio_pad_select_gpio(gpio_num: byte); cdecl; external;

procedure gpio_pad_set_drv(gpio_num: byte; drv: byte); cdecl; external;

procedure gpio_pad_pullup(gpio_num: byte); cdecl; external;

procedure gpio_pad_pulldown(gpio_num: byte); cdecl; external;

procedure gpio_pad_unhold(gpio_num: byte); cdecl; external;

procedure gpio_pad_hold(gpio_num: byte); cdecl; external;

// Translation of driver/include/driver/gpio.h
type
  Tgpio_isr_handle_t = pointer;
  Pgpio_isr_handle_t = ^Tgpio_isr_handle_t;
  TIsrProc = procedure(para: pointer); cdecl;

function gpio_config(pGPIOConfig: Pgpio_config_t): Tesp_err_t; cdecl; external;

function gpio_reset_pin(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_set_intr_type(gpio_num: Tgpio_num_t;
  intr_type: Tgpio_int_type_t): Tesp_err_t; cdecl; external;

function gpio_intr_enable(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_intr_disable(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_set_level(gpio_num: Tgpio_num_t; level: uint32): Tesp_err_t; cdecl; external;

function gpio_get_level(gpio_num: Tgpio_num_t): int32; cdecl; external;

function gpio_set_direction(gpio_num: Tgpio_num_t; mode: Tgpio_mode_t): Tesp_err_t;
  cdecl; external;

function gpio_set_pull_mode(gpio_num: Tgpio_num_t; pull: Tgpio_pull_mode_t): Tesp_err_t;
  cdecl; external;

function gpio_wakeup_enable(gpio_num: Tgpio_num_t;
  intr_type: Tgpio_int_type_t): Tesp_err_t; cdecl; external;

function gpio_wakeup_disable(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_isr_register(fn: TIsrProc; arg: pointer;
  intr_alloc_flags: int32; handle: Pgpio_isr_handle_t): Tesp_err_t; cdecl; external;

function gpio_pullup_en(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_pullup_dis(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_pulldown_en(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_pulldown_dis(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_install_isr_service(intr_alloc_flags: int32): Tesp_err_t; cdecl; external;

procedure gpio_uninstall_isr_service; cdecl; external;

function gpio_isr_handler_add(gpio_num: Tgpio_num_t; isr_handler: Tgpio_isr_t;
  args: pointer): Tesp_err_t; cdecl; external;

function gpio_isr_handler_remove(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_set_drive_capability(gpio_num: Tgpio_num_t;
  strength: Tgpio_drive_cap_t): Tesp_err_t; cdecl; external;

function gpio_get_drive_capability(gpio_num: Tgpio_num_t;
  strength: Pgpio_drive_cap_t): Tesp_err_t; cdecl; external;

function gpio_hold_en(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

function gpio_hold_dis(gpio_num: Tgpio_num_t): Tesp_err_t; cdecl; external;

procedure gpio_deep_sleep_hold_en; cdecl; external;

procedure gpio_deep_sleep_hold_dis; cdecl; external;

procedure gpio_iomux_in(gpio_num: uint32; signal_idx: uint32); cdecl; external;

procedure gpio_iomux_out(gpio_num: byte; func: int32; oen_inv: longbool); cdecl; external;

{$ifdef GPIO_SUPPORTS_FORCE_HOLD}
function gpio_force_hold_all: Tesp_err_t; cdecl; external;
function gpio_force_unhold_all: Tesp_err_t; cdecl; external;
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
