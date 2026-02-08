unit i2c_obj;

interface

uses
  esp_err;

type
  { TI2cMaster }
  // Note: The device's I2C address should be left adjusted
  TI2cMaster = object
    procedure Initialize(i2cPort, SdaPin, SclPin: integer);
    procedure Finalize;
    //function ReadByte(address: byte; out data: byte): Tesp_err;
    function ReadByteFromReg(i2caddress, regAddress: byte; out data: byte): Tesp_err; overload;
    function ReadByteFromReg(i2caddress: byte; regAddress: uint16; out data: byte): Tesp_err; overload;
    function ReadBytesFromReg(i2caddress, regAddress: byte; data: PByte; size: byte): Tesp_err; overload;
    function ReadBytesFromReg(i2caddress: byte; regAddress: uint16; data: PByte; size: byte): Tesp_err; overload;
    //function ReadBytes(address: byte; data: PByte; size: byte): Tesp_err;

    //function WriteByte(address: byte; const data: byte): Tesp_err;
    function WriteByteToReg(i2caddress, regAddress: byte; const data: byte): Tesp_err; overload;
    function WriteByteToReg(i2caddress: byte; regAddress: uint16; const data: byte): Tesp_err; overload;
    function WriteBytesToReg(i2caddress, regAddress: byte; data: PByte; size: byte
      ): Tesp_err; overload;
    function WriteBytesToReg(i2caddress: byte; regAddress: uint16; data: PByte; size: byte
      ): Tesp_err; overload;

    function WriteBytes(address: byte; const data: PByte; size: byte): Tesp_err;
    function CheckAddress(address: byte): Tesp_err;
  private
    Fi2cPort: integer;
    function ReadByte(address: byte; out data: byte): Tesp_err;
    //function ReadByteFromReg(i2caddress, regAddress: byte; out data: byte): Tesp_err;
    //function ReadBytesFromReg(i2caddress, regAddress: byte; data: PByte; size: byte): Tesp_err;
    function ReadBytes(address: byte; data: PByte; size: byte): Tesp_err;

    function WriteByte(address: byte; const data: byte): Tesp_err;
    //function WriteByteToReg(i2caddress, regAddress: byte; const data: byte): Tesp_err;
    //function WriteBytesToReg(i2caddress, regAddress: byte; data: PByte; size: byte
    //  ): Tesp_err;
    //function WriteBytes(address: byte; const data: PByte; size: byte): Tesp_err;
   end;

implementation

uses
  i2c, {$ifdef CPULX6}gpio_types{$else}gpio{$endif}, portmacro;

{ TI2cMaster }

procedure TI2cMaster.Initialize(i2cPort, SdaPin, SclPin: integer);
var
  config: Ti2c_config;
  ret: Tesp_err;
begin
  Fi2cPort := i2cPort;
  FillByte(config, SizeOf(config), 0);
  with config do
  begin
    mode := I2C_MODE_MASTER;
    sda_io_num := Tgpio_num(SdaPin);
    scl_io_num := Tgpio_num(SclPin);
    {$ifdef CPULX6}
    master.clk_speed := 100000;  // 100 kHz, take it easy for now
    master.clk_flags := 0;  // Normal
    sda_pullup_en := true;
    scl_pullup_en := true;
    {$else CPULX6}
    clk_stretch_tick := 300;
    sda_pullup_en := GPIO_PULLUP_ENABLE;
    scl_pullup_en := GPIO_PULLUP_ENABLE;
    {$endif CPULX6}
  end;

  ret := i2c_driver_install(Ti2c_port(Fi2cPort), config.mode {$ifdef CPULX6}, 0, 0, 0{$endif});
  if ret <> ESP_OK then
    writeln('Error calling i2c_driver_install: ', esp_err_to_name(ret));

  ret := i2c_param_config(Ti2c_port(Fi2cPort), @config);
  if ret <> ESP_OK then
    writeln('Error calling i2c_param_config: ', esp_err_to_name(ret));
end;

procedure TI2cMaster.Finalize;
begin
  i2c_driver_delete(Ti2c_port(Fi2cPort));
end;

function TI2cMaster.ReadByte(address: byte; out data: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, address or 1, true);
  i2c_master_read_byte(cmd, @data, I2C_MASTER_NACK);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 1000 div portTICK_PERIOD_MS);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.ReadByteFromReg(i2caddress, regAddress: byte; out data: byte
  ): Tesp_err;
begin
  //result := WriteByte(i2caddress, regAddress);
  //if result = ESP_OK then
  //  result := ReadByte(i2caddress, data);
  result := ReadBytesFromReg(i2caddress, regAddress, @data, 1);
end;

function TI2cMaster.ReadByteFromReg(i2caddress: byte; regAddress: uint16; out
  data: byte): Tesp_err;
begin
  result := ReadBytesFromReg(i2caddress, regAddress, @data, 1);
end;

function TI2cMaster.ReadBytesFromReg(i2caddress, regAddress: byte; data: PByte;
  size: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  // Write register to be read
  i2c_master_write_byte(cmd, i2caddress, true);
  i2c_master_write(cmd, @regAddress, 1, true);

  // Now read data
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, i2caddress or 1, true);
  if (size > 1) then
  begin
    i2c_master_read(cmd, data, size-1, I2C_MASTER_ACK);
    inc(data, size-1);
  end;
  i2c_master_read_byte(cmd, data, I2C_MASTER_NACK);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 1000 div portTICK_PERIOD_MS);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.ReadBytesFromReg(i2caddress: byte; regAddress: uint16;
  data: PByte; size: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
  addr: array[0..1] of byte;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, i2caddress, true);
  // Write register to be read in MSB order
  addr[0] := (regAddress shr 8);
  addr[1] := byte(regAddress);
  i2c_master_write(cmd, @addr, 2, true);
  // Required???
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 1000 div portTICK_PERIOD_MS);
  i2c_cmd_link_delete(cmd);

  // Only bother with the read cycle if the previous transaction was OK
  if result = ESP_OK then
  begin
    cmd := i2c_cmd_link_create();
    // Now read data
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, i2caddress or 1, true);
    if (size > 1) then
    begin
      i2c_master_read(cmd, data, size-1, I2C_MASTER_ACK);
      inc(data, size-1);
    end;
    i2c_master_read_byte(cmd, data, I2C_MASTER_NACK);
    i2c_master_stop(cmd);
    result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 1000 div portTICK_PERIOD_MS);
    i2c_cmd_link_delete(cmd);
  end;
end;

function TI2cMaster.ReadBytes(address: byte; data: PByte; size: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, address or 1, true);

  if (size > 1) then
  begin
    i2c_master_read(cmd, data, size-1, I2C_MASTER_ACK);
    inc(data, size-1);
  end;
  i2c_master_read_byte(cmd, data, I2C_MASTER_NACK);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 1000 div portTICK_PERIOD_MS);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.WriteByte(address: byte; const data: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, address, true);
  i2c_master_write (cmd, @data, 1, true);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 10);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.WriteByteToReg(i2caddress, regAddress: byte;
  const data: byte): Tesp_err;
var
  temp: array[0..1] of byte;
begin
  temp[0] := regAddress;
  temp[1] := data;
  result := WriteBytes(i2caddress, @temp[0], length(temp));
end;

function TI2cMaster.WriteByteToReg(i2caddress: byte; regAddress: uint16;
  const data: byte): Tesp_err;
var
  temp: array[0..2] of byte;
begin
  // Register address sent MSB
  temp[0] := regAddress shr 8;
  temp[1] := byte(regAddress);
  temp[2] := data;
  result := WriteBytes(i2caddress, @temp[0], length(temp));
end;

function TI2cMaster.WriteBytesToReg(i2caddress, regAddress: byte;
  data: PByte; size: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  // Write register address
  i2c_master_write_byte(cmd, i2caddress, true);
  i2c_master_write(cmd, @regAddress, 1, true);

  // Now write data
  i2c_master_write(cmd, data, size, true);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 10);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.WriteBytesToReg(i2caddress: byte; regAddress: uint16;
  data: PByte; size: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
  addr: array[0..1] of byte;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  // Write register address
  i2c_master_write_byte(cmd, i2caddress, true);
  addr[0] := regAddress shr 8;
  i2c_master_write(cmd, @addr, 1, true);
  addr[1] := byte(regAddress);
  i2c_master_write(cmd, @addr, 2, true);

  // Now write data
  i2c_master_write(cmd, data, size, true);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 10);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.WriteBytes(address: byte; const data: PByte; size: byte
  ): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create();
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, address, true);
  i2c_master_write (cmd, data, size, true);
  i2c_master_stop(cmd);
  result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 10);
  i2c_cmd_link_delete(cmd);
end;

function TI2cMaster.CheckAddress(address: byte): Tesp_err;
var
  cmd: Ti2c_cmd_handle;
begin
  cmd := i2c_cmd_link_create;
  i2c_master_start(cmd);
  i2c_master_write_byte(cmd, address or 1, true);
  i2c_master_stop(cmd);
  Result := i2c_master_cmd_begin(Ti2c_port(Fi2cPort), cmd, 10);
  i2c_cmd_link_delete(cmd);
end;

end.

