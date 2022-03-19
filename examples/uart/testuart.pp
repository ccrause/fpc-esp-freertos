program testuart;

uses
  freertos, task, portmacro, uart, esp_err
  {$ifdef FPC_MCU_ESP32}, uart_types{$endif};

procedure sleep(Milliseconds: cardinal);  // Should be in SysUtils but including it causes an error in ESP32
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

const
{$ifdef FPC_MCU_ESP32}
  UART_PORT = 1;
  TX1_PIN = 19;
  RX1_PIN = 18;
{$else}
  // Use UART1 on GPIO2 / D4
  UART_PORT: Tuart_port = UART_NUM_1;
  // ESP8266 only have fixed pin assignments
{$endif}
  msg = 'UART test message'#13#10;

var
  uart_cfg: Tuart_config;

begin
{$ifdef FPC_MCU_ESP32}
  uart_cfg.baud_rate  := 115200;
{$else}
  // On my esp8266 board the baud rate is low by a factor 26/40
  // Adjust baud rate specified to get to the actual desired baud:
  uart_cfg.baud_rate  := (115200*40) div 26;
{$endif}
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
{$ifdef FPC_MCU_ESP32}
  uart_cfg.source_clk := UART_SCLK_APB;
{$endif}

{$ifdef FPC_MCU_ESP32}
  EspErrorCheck(uart_driver_install(UART_PORT, 1024, 0, 0, nil, 0));
  EspErrorCheck(uart_param_config(UART_PORT, @uart_cfg));
  EspErrorCheck(uart_set_pin(UART_PORT, TX1_PIN, RX1_PIN,
    UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));
{$else}
  EspErrorCheck(uart_param_config(UART_PORT, @uart_cfg));
  EspErrorCheck(uart_driver_install(UART_PORT, 256, 0, 0, nil, 0));
{$endif}

  repeat
    writeln('Standard output');
    uart_write_bytes(UART_PORT, @msg[1], length(msg));
    sleep(1000);
  until false;
end.
