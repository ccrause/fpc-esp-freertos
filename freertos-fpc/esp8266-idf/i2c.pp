unit i2c;

interface

uses
  esp_err, portmacro, gpio;

type
  Pi2c_mode = ^Ti2c_mode;
  Ti2c_mode = (I2C_MODE_MASTER, I2C_MODE_MAX);

  Pi2c_rw = ^Ti2c_rw;
  Ti2c_rw = (I2C_MASTER_WRITE_ = 0, I2C_MASTER_READ_
    );

  Pi2c_opmode = ^Ti2c_opmode;
  Ti2c_opmode = (I2C_CMD_RESTART = 0, I2C_CMD_WRITE, I2C_CMD_READ,
    I2C_CMD_STOP);

  Pi2c_port = ^Ti2c_port;
  Ti2c_port = (I2C_NUM_0 = 0, I2C_NUM_MAX);

  Pi2c_ack_type = ^Ti2c_ack_type;
  Ti2c_ack_type = (I2C_MASTER_ACK = $0, I2C_MASTER_NACK = $1,
    I2C_MASTER_LAST_NACK = $2, I2C_MASTER_ACK_MAX
    );

  Pi2c_config = ^Ti2c_config;
  Ti2c_config = record
    mode: Ti2c_mode;
    sda_io_num: Tgpio_num;
    sda_pullup_en: Tgpio_pullup;
    scl_io_num: Tgpio_num;
    scl_pullup_en: Tgpio_pullup;
    clk_stretch_tick: uint32;
  end;

  Pi2c_cmd_handle = ^Ti2c_cmd_handle;
  Ti2c_cmd_handle = pointer;

function i2c_driver_install(i2c_num: Ti2c_port; mode: Ti2c_mode): Tesp_err; external;
function i2c_driver_delete(i2c_num: Ti2c_port): Tesp_err; external;
function i2c_param_config(i2c_num: Ti2c_port; i2c_conf: Pi2c_config): Tesp_err; external;
function i2c_set_pin(i2c_num: Ti2c_port; sda_io_num: longint;
  scl_io_num: longint; sda_pullup_en: Tgpio_pullup; scl_pullup_en: Tgpio_pullup;
  mode: Ti2c_mode): Tesp_err; external;
function i2c_cmd_link_create: Ti2c_cmd_handle; external;
procedure i2c_cmd_link_delete(cmd_handle: Ti2c_cmd_handle); external;
function i2c_master_start(cmd_handle: Ti2c_cmd_handle): Tesp_err; external;
function i2c_master_write_byte(cmd_handle: Ti2c_cmd_handle; Data: byte;
  ack_en: longbool): Tesp_err; external;
function i2c_master_write(cmd_handle: Ti2c_cmd_handle; Data: PByte;
  data_len: Tsize; ack_en: longbool): Tesp_err; external;
function i2c_master_read_byte(cmd_handle: Ti2c_cmd_handle; Data: PByte;
  ack: Ti2c_ack_type): Tesp_err; external;
function i2c_master_read(cmd_handle: Ti2c_cmd_handle; Data: PByte;
  data_len: Tsize; ack: Ti2c_ack_type): Tesp_err; external;
function i2c_master_stop(cmd_handle: Ti2c_cmd_handle): Tesp_err; external;
function i2c_master_cmd_begin(i2c_num: Ti2c_port; cmd_handle: Ti2c_cmd_handle;
  ticks_to_wait: TTickType): Tesp_err; external;

implementation

end.
