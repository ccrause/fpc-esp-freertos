unit uart_types;

interface

type
  Puart_port = ^Tuart_port;
  Tuart_port = longint;

  Puart_mode = ^Tuart_mode;
  Tuart_mode = (UART_MODE_UART := $00, UART_MODE_RS485_HALF_DUPLEX := $01,
    UART_MODE_IRDA := $02, UART_MODE_RS485_COLLISION_DETECT := $03,
    UART_MODE_RS485_APP_CTRL := $04);

  Puart_word_length = ^Tuart_word_length;
  Tuart_word_length = (UART_DATA_5_BITS := $0, UART_DATA_6_BITS := $1,
    UART_DATA_7_BITS := $2, UART_DATA_8_BITS := $3,
    UART_DATA_BITS_MAX := $4);

  Puart_stop_bits = ^Tuart_stop_bits;
  Tuart_stop_bits = (UART_STOP_BITS_1 := $1, UART_STOP_BITS_1_5 := $2,
    UART_STOP_BITS_2 := $3, UART_STOP_BITS_MAX := $4);

  Puart_parity = ^Tuart_parity;
  Tuart_parity = (UART_PARITY_DISABLE := $0, UART_PARITY_EVEN := $2,
    UART_PARITY_ODD := $3);

  Puart_hw_flowcontrol = ^Tuart_hw_flowcontrol;
  Tuart_hw_flowcontrol = (UART_HW_FLOWCTRL_DISABLE := $0, UART_HW_FLOWCTRL_RTS := $1,
    UART_HW_FLOWCTRL_CTS := $2, UART_HW_FLOWCTRL_CTS_RTS := $3,
    UART_HW_FLOWCTRL_MAX := $4);

  Puart_signal_inv = ^Tuart_signal_inv;
  Tuart_signal_inv = (UART_SIGNAL_INV_DISABLE := 0, UART_SIGNAL_IRDA_TX_INV := $1 shl 0,
    UART_SIGNAL_IRDA_RX_INV := $1 shl 1, UART_SIGNAL_RXD_INV := $1 shl 2,
    UART_SIGNAL_CTS_INV := $1 shl 3, UART_SIGNAL_DSR_INV := $1 shl 4,
    UART_SIGNAL_TXD_INV := $1 shl 5, UART_SIGNAL_RTS_INV := $1 shl 6,
    UART_SIGNAL_DTR_INV := $1 shl 7);

  Puart_sclk = ^Tuart_sclk;
  Tuart_sclk = (UART_SCLK_APB := $0, UART_SCLK_RTC := $1,
    UART_SCLK_XTAL := $2, UART_SCLK_REF_TICK := $3);

  Puart_at_cmd = ^Tuart_at_cmd;
  Tuart_at_cmd = record
    cmd_char: byte;
    char_num: byte;
    gap_tout: uint32;
    pre_idle: uint32;
    post_idle: uint32;
  end;

  Puart_sw_flowctrl = ^Tuart_sw_flowctrl;
  Tuart_sw_flowctrl = record
    xon_char: byte;
    xoff_char: byte;
    xon_thrd: byte;
    xoff_thrd: byte;
  end;

  Tuart_config = record
    baud_rate: int32;
    data_bits: Tuart_word_length;
    parity: Tuart_parity;
    stop_bits: Tuart_stop_bits;
    flow_ctrl: Tuart_hw_flowcontrol;
    rx_flow_ctrl_thresh: byte;
    //source_clk: Tuart_sclk;
    case boolean of
      false: (source_clk: Tuart_sclk);
      true:  (use_ref_tick: longbool);
  end;
  Puart_config = ^Tuart_config;

implementation

end.
