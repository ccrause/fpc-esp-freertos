unit logtouart;

interface

procedure initLogUart;

procedure logwrite(s: shortstring);
procedure logwriteln(s: shortstring);

procedure logwrite(v: int32);
procedure logwriteln(v: int32);

implementation

uses
  uart_types, uart, semphr, projdefs;

const
  UartPort = 1;
  TX_PIN = 19;
  RX_PIN = 18;

var
  lock: TSemaphoreHandle;

procedure initLogUart;
var
  uart_cfg: Tuart_config;
begin
{$ifdef debugprint}
  lock := xSemaphoreCreateMutex;
  uart_cfg.baud_rate  := 115200;
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
  uart_cfg.rx_flow_ctrl_thresh := 0; // unclear why this is required
  uart_cfg.source_clk := UART_SCLK_APB;

  uart_driver_install(UartPort, 4*1024, 4*1024, 0, nil, 0);
  uart_param_config(UartPort, @uart_cfg);
  uart_set_pin(UartPort, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
{$elseif defined(logtostdout)}
  // no special init
{$endif}
end;

procedure logwrite(s: shortstring);
begin
{$ifdef debugprint}
  if xSemaphoreTake(lock, 200) = pdTRUE then
  begin
    uart_write_bytes(UartPort, @s[1], length(s));
    xSemaphoreGive(lock);
  end;
{$elseif defined(logtostdout)}
  write(s);
{$endif}
end;

procedure logwriteln(s: shortstring);
begin
{$ifdef debugprint}
  s := s + #13#10;
  if xSemaphoreTake(lock, 200) = pdTRUE then
  begin
    uart_write_bytes(UartPort, @s[1], length(s));
    xSemaphoreGive(lock);
  end;
{$elseif defined(logtostdout)}
  writeln(s);
{$endif}
end;

procedure logwrite(v: int32);
var
  s: string[16];
begin
{$ifdef debugprint}
  Str(v, s);
  if xSemaphoreTake(lock, 200) = pdTRUE then
  begin
    uart_write_bytes(UartPort, @s[1], length(s));
    xSemaphoreGive(lock);
  end;
{$elseif defined(logtostdout)}
  write(s);
{$endif}
end;

procedure logwriteln(v: int32);
var
  s: string[16];
begin
{$ifdef debugprint}
  Str(v, s);
  s := s + #13#10;
  if xSemaphoreTake(lock, 200) = pdTRUE then
  begin
    uart_write_bytes(UartPort, @s[1], length(s));
    xSemaphoreGive(lock);
  end;
{$elseif defined(logtostdout)}
  writeln(v);
{$endif}
end;

end.

