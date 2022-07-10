program steppermotor;

{$define debugNextion}

uses
  portmacro, esp_err, task,
  nextion, mcpwm, pwm_mcpwm, uart, uart_types;

const
  // Stepper driver pin configuration
  StepPin = 14;
  EnPin = 13;

  // Nextion display configuration
  UART_FIFO_BUFFER_SIZE = 2*2048;
  UartPort = 1;
  TX_PIN = 27;
  RX_PIN = 26;
  RPM_ID          = 1;
  StartSwitchID   = 2;
  OKButtonID      = 4;
  nexRPM:         TNextionComponent = (pid: 0; cid: RPM_ID);
  nexStartSwitch: TNextionComponent = (pid: 0; cid: StartSwitchID);

var
  stepper: TStepperPWM;
  nexDisplay: TNextionHandler;

procedure sleep(Milliseconds: cardinal);
begin
  vTaskDelay(Milliseconds div portTICK_PERIOD_MS);
end;

procedure initNextionUart;
var
  uart_cfg: Tuart_config;
  err: Tesp_err;
begin
  uart_cfg.baud_rate  := 9600; // Default for Nextion serial interface
  uart_cfg.data_bits  := UART_DATA_8_BITS;
  uart_cfg.parity     := UART_PARITY_DISABLE;
  uart_cfg.stop_bits  := UART_STOP_BITS_1;
  uart_cfg.flow_ctrl  := UART_HW_FLOWCTRL_DISABLE;
  uart_cfg.rx_flow_ctrl_thresh := 0;
  uart_cfg.source_clk := UART_SCLK_APB;

  err := uart_driver_install(UartPort, UART_FIFO_BUFFER_SIZE, UART_FIFO_BUFFER_SIZE, 0, nil, 0);
  if err <> ESP_OK then
    writeln('Error calling uart_driver_install');

  uart_param_config(UartPort, @uart_cfg);
  uart_set_pin(UartPort, TX_PIN, RX_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
  Sleep(100);
  uart_flush_input(UartPort);
end;

procedure sendString(data: shortstring);
var
  len: integer;
begin
  {$ifdef debugNextion} writeln('Nextion >> ', data); {$endif}
  len := uart_write_bytes(UartPort, @data[1], length(data));
  if len < 0 then
    writeln('Error in sendString')
  else if len < length(data) then
    writeln('Less data sent');
end;

function readString: shortstring;
var
  len: integer;
begin
  len := 250;
  SetLength(Result, len);
  FillByte(Result[1], 0, len);
  len := uart_read_bytes(UartPort, @Result[1], len, 1);
  if len > 0 then
  begin
    SetLength(Result, len);
    {$ifdef debugNextion} writeln('Nextion << ', Result); {$endif}
  end
  else
    Result := '';
end;

procedure handleTouchEvent(pid, cid: integer; pressed: boolean);
var
  v: integer;
begin
  {$ifdef debugNextion} writeln('Nextion event: pid = ', pid, ', cid = ', cid, ', pressed = ', pressed); {$endif}
  // Start switch is on page 0
  if (pid = 0) and (cid = StartSwitchID) then
  begin
    if nexDisplay.getValue(nexStartSwitch, v) then
    begin
      if v = 1 then
      begin
        stepper.start;
        writeln('stepper.start');
      end
      else
      begin
        stepper.stop;
        writeln('stepper.stop');
      end;
    end
  end
  // Keypad OK button is on page 1
  else if (pid = 1) and (cid = OKButtonID) then
  begin
    if nexDisplay.getValue(nexRPM, v) and (v > 0) then
    begin
      stepper.setRPM(v);
    end;
  end
  else
    writeln('Unexpected Nextion event');
end;

procedure initDisplay;
begin
  initNextionUart;
  nexDisplay.readHandler := @readString;
  nexDisplay.writeHandler := @sendString;
  nexDisplay.touchHandler := @handleTouchEvent;
  nexDisplay.init;
  // Discard possible junk in Nextion input buffer
  nexDisplay.sendCommand('');
  nexDisplay.sendCommand('rest');
  // Wait for displays to restart before issuing commands
  Sleep(250);
  uart_flush_input(UartPort);
  // Disable result codes on Nextion
  nexDisplay.sendCommand('bkcmd=0');
end;

begin
  stepper.init(MCPWM_UNIT_0, MCPWM_TIMER_0, MCPWM_GEN_A, StepPin, EnPin);
  // Set the state of the enable pin (the A4988 driver is enabled when the enable pin is low)
  stepper.enabledState := false;
  // Calling stop stops the PWM signal and also set the enable pin to the inactive state
  stepper.stop;

  initDisplay;

  repeat
    nexDisplay.processInputData;
    Sleep(100);
  until false;
end.
