unit uart;

interface

uses
  esp_err, queue, portmacro, eagle_soc;

const
  UART_FIFO_LEN = 128;
  UART_INTR_MASK = $1ff;
  UART_LINE_INV_MASK = $3f shl 19;
  UART_INVERSE_DISABLE = $0;
  UART_INVERSE_RXD = BIT19;
  UART_INVERSE_CTS = BIT20;
  UART_INVERSE_TXD = BIT22;
  UART_INVERSE_RTS = BIT23;

type
  PQueueHandle = ^TQueueHandle;

  Puart_mode = ^Tuart_mode;
  Tuart_mode = (UART_MODE_UART := $00);

  Puart_word_length = ^Tuart_word_length;
  Tuart_word_length = (UART_DATA_5_BITS := $0, UART_DATA_6_BITS := $1,
    UART_DATA_7_BITS := $2, UART_DATA_8_BITS := $3,
    UART_DATA_BITS_MAX := $4);

  Puart_stop_bits = ^Tuart_stop_bits;
  Tuart_stop_bits = (UART_STOP_BITS_1 := $1, UART_STOP_BITS_1_5 := $2,
    UART_STOP_BITS_2 := $3, UART_STOP_BITS_MAX := $4);

  Puart_port = ^Tuart_port;
  Tuart_port = (UART_NUM_0 := $0, UART_NUM_1 := $1, UART_NUM_MAX);

  Puart_parity = ^Tuart_parity;
  Tuart_parity = (UART_PARITY_DISABLE := $0, UART_PARITY_EVEN := $2,
    UART_PARITY_ODD := $3);

  Puart_hw_flowcontrol = ^Tuart_hw_flowcontrol;
  Tuart_hw_flowcontrol = (UART_HW_FLOWCTRL_DISABLE := $0, UART_HW_FLOWCTRL_RTS := $1,
    UART_HW_FLOWCTRL_CTS := $2, UART_HW_FLOWCTRL_CTS_RTS := $3,
    UART_HW_FLOWCTRL_MAX := $4);

  Puart_config = ^Tuart_config;
  Tuart_config = record
    baud_rate: longint;
    data_bits: Tuart_word_length;
    parity: Tuart_parity;
    stop_bits: Tuart_stop_bits;
    flow_ctrl: Tuart_hw_flowcontrol;
    rx_flow_ctrl_thresh: byte;
  end;

  Puart_intr_config = ^Tuart_intr_config;
  Tuart_intr_config = record
    intr_enable_mask: uint32;
    rx_timeout_thresh: byte;
    txfifo_empty_intr_thresh: byte;
    rxfifo_full_thresh: byte;
  end;

  Puart_event_type = ^Tuart_event_type;
  Tuart_event_type = (UART_DATA, UART_BUFFER_FULL, UART_FIFO_OVF,
    UART_FRAME_ERR, UART_PARITY_ERR, UART_EVENT_MAX
    );

  Puart_event = ^Tuart_event;
  Tuart_event = record
    _type: Tuart_event_type;
    size: Tsize;
  end;

  Tintr_handler = procedure(para1: pointer);

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

function uart_get_hw_flow_ctrl(uart_num: Tuart_port;
  flow_ctrl: Puart_hw_flowcontrol): Tesp_err; external;

function uart_enable_swap: Tesp_err; external;

function uart_disable_swap: Tesp_err; external;

function uart_clear_intr_status(uart_num: Tuart_port;
  mask: uint32): Tesp_err; external;

function uart_enable_intr_mask(uart_num: Tuart_port;
  enable_mask: uint32): Tesp_err; external;

function uart_disable_intr_mask(uart_num: Tuart_port;
  disable_mask: uint32): Tesp_err; external;

function uart_enable_rx_intr(uart_num: Tuart_port): Tesp_err; external;

function uart_disable_rx_intr(uart_num: Tuart_port): Tesp_err; external;

function uart_disable_tx_intr(uart_num: Tuart_port): Tesp_err; external;

function uart_enable_tx_intr(uart_num: Tuart_port; enable: longint;
  thresh: longint): Tesp_err; external;

function uart_isr_register(uart_num: Tuart_port; fn: Tintr_handler;
  arg: pointer): Tesp_err; external;

function uart_param_config(uart_num: Tuart_port;
  uart_conf: Puart_config): Tesp_err; external;

function uart_intr_config(uart_num: Tuart_port;
  uart_intr_conf: Puart_intr_config): Tesp_err; external;

function uart_driver_install(uart_num: Tuart_port; rx_buffer_size: longint;
  tx_buffer_size: longint; queue_size: longint; uart_queue: PQueueHandle;
  no_use: longint): Tesp_err; external;

function uart_driver_delete(uart_num: Tuart_port): Tesp_err; external;

function uart_wait_tx_done(uart_num: Tuart_port;
  ticks_to_wait: TTickType): Tesp_err; external;

function uart_tx_chars(uart_num: Tuart_port; buffer: PChar; len: uint32): longint;
  external;

function uart_write_bytes(uart_num: Tuart_port; src: PChar; size: Tsize): longint;
  external;

function uart_read_bytes(uart_num: Tuart_port; buf: PByte;
  length: uint32; ticks_to_wait: TTickType): longint; external;

function uart_flush(uart_num: Tuart_port): Tesp_err; external;

function uart_flush_input(uart_num: Tuart_port): Tesp_err; external;

function uart_get_buffered_data_len(uart_num: Tuart_port;
  size: Psize): Tesp_err; external;

function uart_set_rx_timeout(uart_num: Tuart_port;
  tout_thresh: byte): Tesp_err; external;

function uart_is_driver_installed(uart_num: Tuart_port): Tbool; external;

implementation

end.
