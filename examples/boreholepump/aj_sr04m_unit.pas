unit aj_sr04m_unit;

interface

uses
  uart, uart_types;

type
  TAJ_SR04M = object
  private
    uart_port: Tuart_port;
    uart_cfg: Tuart_config;
  public
    procedure init(Auart_port: Tuart_port; txPin, rxPin: integer);
    // Read distance in mm
    // Returns true on success
    function readDistance(out dist: integer): boolean;
  end;

implementation

uses
  esp_err, portmacro;

procedure TAJ_SR04M.init(Auart_port: Tuart_port; txPin, rxPin: integer);
begin
  uart_port := Auart_port;
  uart_cfg.baud_rate  := 9600;
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
{$ifdef FPC_MCU_ESP32}
  uart_cfg.source_clk := UART_SCLK_APB;
{$endif}

  //esp_log_write(ESP_LOG_INFO, '+', 'Before driver install'#10);
{$ifdef FPC_MCU_ESP32}
  EspErrorCheck(uart_driver_install(uart_port, 256, 256, 0, nil, 0));
  EspErrorCheck(uart_param_config(uart_port, @uart_cfg));
  EspErrorCheck(uart_set_pin(uart_port, txPin, rxPin,
    UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));
{$else}
  EspErrorCheck(uart_param_config(uart_port, @uart_cfg));
  EspErrorCheck(uart_driver_install(uart_port, 256, 0, 0, nil, 0));
{$endif}
end;

function TAJ_SR04M.readDistance(out dist: integer): boolean;
var
  msg: byte;
  response: array[0..3] of byte;
begin
  dist := -1;
  msg := ord('U');

  Result := EspErrorCheck(uart_flush(uart_port));
  if not Result then exit;

  if uart_write_bytes(uart_port, @msg, 1) < 0 then
  begin
    writeln('Error: uart_write_bytes');
    Exit(False);
  end;

  if uart_read_bytes(uart_port, @response[0], length(response), 100 div portTICK_PERIOD_MS) <> 4 then
  begin
    writeln('Error: uart_read_bytes');
    Exit(False);
  end;

  // Start of message indicator
  Result := (response[0] = $FF) and (byte(response[1] + response[2] - 1) = response[3]);
  if Result then
    dist := response[2] + (response[1] shl 8)
  else
    writeln('TAJ_SR04M: Unexpected reply ', HexStr(response[0], 2), ' ',
      HexStr(response[1], 2), ' ', HexStr(response[2], 2), ' ',
      HexStr(response[3], 2));
end;

end.

