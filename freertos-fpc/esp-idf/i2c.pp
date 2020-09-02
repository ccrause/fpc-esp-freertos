unit i2c;

{$include freertosconfig.inc}

interface

uses
  esp_err, soc, i2c_caps, portmacro, gpio, gpio_types;

const
  // Constants from i2c_caps.h
  SOC_I2C_NUM = 2;
  SOC_I2C_FIFO_LEN = 32;
  I2C_INTR_MASK = $3fff;
  I2C_SUPPORT_HW_FSM_RST = 0;
  I2C_SUPPORT_HW_CLR_BUS = 0;

  // Constants from i2c.h
  I2C_APB_CLK_FREQ = APB_CLK_FREQ;
  I2C_NUM_0 = 0;
  I2C_NUM_1 = 1;
  I2C_NUM_MAX = SOC_I2C_NUM;

type
  // Types from i2c_types.h
  Pi2c_port = ^Ti2c_port;
  Ti2c_port = longint;

  Pi2c_mode = ^Ti2c_mode;
  Ti2c_mode = (I2C_MODE_SLAVE = 0, I2C_MODE_MASTER, I2C_MODE_MAX);

  Pi2c_rw = ^Ti2c_rw;
  Ti2c_rw = (I2C_MASTER_WRITE_ = 0, I2C_MASTER_READ_); // avoid name clash with function names

  Pi2c_opmode = ^Ti2c_opmode;
  Ti2c_opmode = (I2C_CMD_RESTART = 0, I2C_CMD_WRITE, I2C_CMD_READ,
    I2C_CMD_STOP, I2C_CMD_END);

  Pi2c_trans_mode = ^Ti2c_trans_mode;
  Ti2c_trans_mode = (I2C_DATA_MODE_MSB_FIRST = 0, I2C_DATA_MODE_LSB_FIRST = 1,
    I2C_DATA_MODE_MAX);

  Pi2c_addr_mode = ^Ti2c_addr_mode;
  Ti2c_addr_mode = (I2C_ADDR_BIT_7 = 0, I2C_ADDR_BIT_10, I2C_ADDR_BIT_MAX);

  Pi2c_ack_type = ^Ti2c_ack_type;
  Ti2c_ack_type = (I2C_MASTER_ACK = $0, I2C_MASTER_NACK = $1,
    I2C_MASTER_LAST_NACK = $2, I2C_MASTER_ACK_MAX);

  Pi2c_sclk = ^Ti2c_sclk;
  Ti2c_sclk = (I2C_SCLK_REF_TICK, I2C_SCLK_APB);

  Pi2c_config = ^Ti2c_config;
  Ti2c_config = record
    mode: Ti2c_mode;
    sda_io_num,
    scl_io_num:  Tgpio_num;
    sda_pullup_en,
    scl_pullup_en: boolean;
    case boolean of
      true:
        (master:  record
          clk_speed: uint32;
        end);
      false:
        (slave: record
          addr_10bit_en: byte;
          slave_addr: byte;
        end);
  end;

  // Type declarations from i2c.h
  Pi2c_cmd_handle = ^Ti2c_cmd_handle;
  Ti2c_cmd_handle = pointer;

  Tintr_handle = Tgpio_isr_handle;
  Pintr_handle = ^Tintr_handle;

  TI2Cfunction = procedure(para1: pointer);

function i2c_driver_install(i2c_num: Ti2c_port; mode: Ti2c_mode;
  slv_rx_buf_len: Tsize; slv_tx_buf_len: TSize; intr_alloc_flags: longint): Tesp_err;
  external;
function i2c_driver_delete(i2c_num: Ti2c_port): Tesp_err; external;
function i2c_param_config(i2c_num: Ti2c_port; i2c_conf: Pi2c_config): Tesp_err;
  external;
function i2c_reset_tx_fifo(i2c_num: Ti2c_port): Tesp_err; external;
function i2c_reset_rx_fifo(i2c_num: Ti2c_port): Tesp_err; external;
function i2c_isr_register(i2c_num: Ti2c_port; fn: TI2Cfunction;
  arg: pointer; intr_alloc_flags: longint; handle: Pintr_handle): Tesp_err; external;
function i2c_isr_free(handle: Tintr_handle): Tesp_err; external;
function i2c_set_pin(i2c_num: Ti2c_port; sda_io_num: longint;
  scl_io_num: longint; sda_pullup_en: longbool; scl_pullup_en: longbool;
  mode: Ti2c_mode): Tesp_err; external;
function i2c_cmd_link_create: Ti2c_cmd_handle; external;
procedure i2c_cmd_link_delete(cmd_handle: Ti2c_cmd_handle); external;
function i2c_master_start(cmd_handle: Ti2c_cmd_handle): Tesp_err; external;
function i2c_master_write_byte(cmd_handle: Ti2c_cmd_handle; Data: byte;
  ack_en: longbool): Tesp_err; external;
function i2c_master_write(cmd_handle: Ti2c_cmd_handle; Data: PByte;
  data_len: TSize; ack_en: longbool): Tesp_err; external; // Note: ack_en was defined as byte.  Change to longbool to be compatible with surrounding code and esp8266
function i2c_master_read_byte(cmd_handle: Ti2c_cmd_handle; PData: PByte;
  ack: Ti2c_ack_type): Tesp_err; external;
function i2c_master_read(cmd_handle: Ti2c_cmd_handle; Data: Pbyte;
  data_len: TSize; ack: Ti2c_ack_type): Tesp_err; external;
function i2c_master_stop(cmd_handle: Ti2c_cmd_handle): Tesp_err; external;
function i2c_master_cmd_begin(i2c_num: Ti2c_port; cmd_handle: Ti2c_cmd_handle;
  ticks_to_wait: TTickType): Tesp_err; external;
function i2c_slave_write_buffer(i2c_num: Ti2c_port; Data: byte;
  size: longint; ticks_to_wait: TTickType): longint; external;
function i2c_slave_read_buffer(i2c_num: Ti2c_port; Data: byte;
  max_size: TSize; ticks_to_wait: TTickType): longint; external;
function i2c_set_period(i2c_num: Ti2c_port; high_period: longint;
  low_period: longint): Tesp_err; external;
function i2c_get_period(i2c_num: Ti2c_port; high_period: Plongint;
  low_period: Plongint): Tesp_err; external;
function i2c_filter_enable(i2c_num: Ti2c_port; cyc_num: byte): Tesp_err;
  external;
function i2c_filter_disable(i2c_num: Ti2c_port): Tesp_err; external;
function i2c_set_start_timing(i2c_num: Ti2c_port; setup_time: longint;
  hold_time: longint): Tesp_err; external;
function i2c_get_start_timing(i2c_num: Ti2c_port; setup_time: Plongint;
  hold_time: Plongint): Tesp_err; external;
function i2c_set_stop_timing(i2c_num: Ti2c_port; setup_time: longint;
  hold_time: longint): Tesp_err; external;
function i2c_get_stop_timing(i2c_num: Ti2c_port; setup_time: Plongint;
  hold_time: Plongint): Tesp_err; external;
function i2c_set_data_timing(i2c_num: Ti2c_port; sample_time: longint;
  hold_time: longint): Tesp_err; external;
function i2c_get_data_timing(i2c_num: Ti2c_port; sample_time: Plongint;
  hold_time: Plongint): Tesp_err; external;
function i2c_set_timeout(i2c_num: Ti2c_port; timeout: longint): Tesp_err; external;
function i2c_get_timeout(i2c_num: Ti2c_port; timeout: Plongint): Tesp_err;
  external;
function i2c_set_data_mode(i2c_num: Ti2c_port; tx_trans_mode: Ti2c_trans_mode;
  rx_trans_mode: Ti2c_trans_mode): Tesp_err; external;
function i2c_get_data_mode(i2c_num: Ti2c_port; tx_trans_mode: Pi2c_trans_mode;
  rx_trans_mode: Pi2c_trans_mode): Tesp_err; external;

implementation

end.
