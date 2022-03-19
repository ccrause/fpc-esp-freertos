unit uart;

interface

uses
  soc_caps, uart_types, esp_err, queue, portmacro;

type
  TProcedurePara1Pointer = procedure(para1: pointer);

const
  UART_NUM_0 = 0;
  UART_NUM_1 = 1;
  UART_NUM_2 = 2;
  UART_NUM_MAX = SOC_UART_NUM;
  UART_PIN_NO_CHANGE = -1;
  UART_FIFO_LEN = SOC_UART_FIFO_LEN;
  UART_BITRATE_MAX = SOC_UART_BITRATE_MAX;

type
  Puart_intr_config = ^Tuart_intr_config;
  Tuart_intr_config = record
    intr_enable_mask: uint32;
    rx_timeout_thresh: byte;
    txfifo_empty_intr_thresh: byte;
    rxfifo_full_thresh: byte;
  end;

  Puart_event_type = ^Tuart_eventype;
  Tuart_eventype = (UART_DATA, UART_BREAK, UART_BUFFER_FULL, UART_FIFO_OVF,
    UART_FRAME_ERR, UART_PARITY_ERR, UART_DATA_BREAK,
    UART_PATTERN_DET, UART_EVENT_MAX);

  Puart_event = ^Tuart_event;
  Tuart_event = record
    _type: Tuart_eventype;
    size: Tsize;
    timeout_flag: Tbool;
  end;

  Puart_isr_handle = ^Tuart_isr_handle;
  Tintr_handler = procedure(arg:pointer);
  Tintr_handle_data = record end;
  Tintr_handle = ^Tintr_handle_data;
  Tuart_isr_handle = Tintr_handle;

function uart_driver_install(uart_num: Tuart_port; rx_buffer_size: longint;
  tx_buffer_size: longint; queue_size: longint; uart_queue: PQueueHandle;
  intr_alloc_flags: longint): Tesp_err; external;
function uart_driver_delete(uart_num: Tuart_port): Tesp_err; external;
function uart_is_driver_installed(uart_num: Tuart_port): Tbool; external;
function uart_set_word_length(uart_num: Tuart_port;
  data_bit: Tuart_word_length): Tesp_err; external;
function uart_get_word_length(uart_num: Tuart_port;
  data_bit: Puart_word_length): Tesp_err; external;
function uart_set_stop_bits(uart_num: Tuart_port;
  stop_bits: Tuart_stop_bits): Tesp_err; external;
function uart_get_stop_bits(uart_num: Tuart_port;
  stop_bits: Puart_stop_bits): Tesp_err; external;
function uart_set_parity(uart_num: Tuart_port; parity_mode: Tuart_parity): Tesp_err;
  external;
function uart_get_parity(uart_num: Tuart_port; parity_mode: Puart_parity): Tesp_err;
  external;
function uart_set_baudrate(uart_num: Tuart_port; baudrate: uint32): Tesp_err;
  external;
function uart_get_baudrate(uart_num: Tuart_port; baudrate: Puint32): Tesp_err;
  external;
function uart_set_line_inverse(uart_num: Tuart_port;
  inverse_mask: uint32): Tesp_err; external;
function uart_set_hw_flow_ctrl(uart_num: Tuart_port; flow_ctrl: Tuart_hw_flowcontrol;
  rx_thresh: byte): Tesp_err; external;
function uart_set_sw_flow_ctrl(uart_num: Tuart_port; enable: Tbool;
  rx_thresh_xon: byte; rx_thresh_xoff: byte): Tesp_err; external;
function uart_get_hw_flow_ctrl(uart_num: Tuart_port;
  flow_ctrl: Puart_hw_flowcontrol): Tesp_err; external;
function uart_clear_intr_status(uart_num: Tuart_port;
  clr_mask: uint32): Tesp_err; external;
function uart_enable_intr_mask(uart_num: Tuart_port;
  enable_mask: uint32): Tesp_err; external;
function uart_disable_intr_mask(uart_num: Tuart_port;
  disable_mask: uint32): Tesp_err; external;
function uart_enable_rx_intr(uart_num: Tuart_port): Tesp_err; external;
function uart_disable_rx_intr(uart_num: Tuart_port): Tesp_err; external;
function uart_disable_tx_intr(uart_num: Tuart_port): Tesp_err; external;
function uart_enable_tx_intr(uart_num: Tuart_port; enable: longint;
  thresh: longint): Tesp_err; external;
function uart_isr_register(uart_num: Tuart_port; fn: TProcedurePara1Pointer;
  arg: pointer; intr_alloc_flags: longint; handle: Puart_isr_handle): Tesp_err;
  external;
function uart_isr_free(uart_num: Tuart_port): Tesp_err; external;
function uart_set_pin(uart_num: Tuart_port; tx_io_num: longint;
  rx_io_num: longint; rts_io_num: longint; cts_io_num: longint): Tesp_err; external;
function uart_set_rts(uart_num: Tuart_port; level: longint): Tesp_err; external;
function uart_set_dtr(uart_num: Tuart_port; level: longint): Tesp_err; external;
function uart_set_tx_idle_num(uart_num: Tuart_port;
  idle_num: uint16): Tesp_err; external;
function uart_param_config(uart_num: Tuart_port;
  uart_config: Puart_config): Tesp_err; external;
function uart_intr_config(uart_num: Tuart_port;
  intr_conf: Puart_intr_config): Tesp_err; external;
function uart_wait_tx_done(uart_num: Tuart_port;
  ticks_to_wait: TTickType): Tesp_err; external;
function uart_tx_chars(uart_num: Tuart_port; buffer: PChar; len: uint32): longint;
  external;
function uart_write_bytes(uart_num: Tuart_port; src: pointer; size: Tsize): longint;
  external;
function uart_write_bytes_with_break(uart_num: Tuart_port; src: pointer;
  size: Tsize; brk_len: longint): longint; external;
function uart_read_bytes(uart_num: Tuart_port; buf: pointer; length: uint32;
  ticks_to_wait: TTickType): longint; external;
function uart_flush(uart_num: Tuart_port): Tesp_err; external;
function uart_flush_input(uart_num: Tuart_port): Tesp_err; external;
function uart_get_buffered_data_len(uart_num: Tuart_port;
  size: Psize): Tesp_err; external;
function uart_disable_pattern_det_intr(uart_num: Tuart_port): Tesp_err; external;
{$ifdef CONFIG_IDF_TARGET_ESP32}
function uart_enable_pattern_det_intr(uart_num: Tuart_port;
  pattern_chr: char; chr_num: byte;
  chr_tout, post_idle, pre_idle: integer): Tesp_err; deprecated; external;
{$endif}
function uart_enable_pattern_det_baud_intr(uart_num: Tuart_port;
  pattern_chr: char; chr_num: byte; chr_tout: longint; post_idle: longint;
  pre_idle: longint): Tesp_err; external;
function uart_pattern_pop_pos(uart_num: Tuart_port): longint; external;
function uart_pattern_get_pos(uart_num: Tuart_port): longint; external;
function uart_pattern_queue_reset(uart_num: Tuart_port;
  queue_length: longint): Tesp_err; external;
function uart_set_mode(uart_num: Tuart_port; mode: Tuart_mode): Tesp_err;
  external;
function uart_set_rx_full_threshold(uart_num: Tuart_port;
  threshold: longint): Tesp_err; external;
function uart_set_tx_empty_threshold(uart_num: Tuart_port;
  threshold: longint): Tesp_err; external;
function uart_set_rx_timeout(uart_num: Tuart_port;
  tout_thresh: byte): Tesp_err; external;
function uart_get_collision_flag(uart_num: Tuart_port;
  collision_flag: Plongbool): Tesp_err; external;
function uart_set_wakeup_threshold(uart_num: Tuart_port;
  wakeup_threshold: longint): Tesp_err; external;
function uart_get_wakeup_threshold(uart_num: Tuart_port;
  out_wakeup_threshold: Plongint): Tesp_err; external;
function uart_wait_tx_idle_polling(uart_num: Tuart_port): Tesp_err; external;
function uart_set_loop_back(uart_num: Tuart_port; loop_back_en: Tbool): Tesp_err;
  external;
procedure uart_set_always_rx_timeout(uart_num: Tuart_port;
  always_rx_timeout_en: Tbool); external;

implementation

end.
