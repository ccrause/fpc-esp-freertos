unit flowmeter;

{ This unit implements a pulse counter based flow meter.
  Compatible with pulse type flow sensors such as YF-Bx }

interface

uses
  pcnt;

type
  { TPulseFlowmeter }

  TPulseFlowmeter = object
  private
    _pin: integer;
    _unit: Tpcnt_unit;
  public
    // Init configures and set counter running
    procedure init(pcnt_unit: Tpcnt_unit; pin: uint16);
    function getReading: uint16;
  end;

implementation

uses
  esp_err;

{ TPulseFlowmeter }

procedure TPulseFlowmeter.init(pcnt_unit: Tpcnt_unit; pin: uint16);
var
  config: Tpcnt_config;
begin
  _pin := pin;
  _unit := pcnt_unit;
  with config do
  begin
    pulse_gpio_num := _pin;
    ctrl_gpio_num  := PCNT_PIN_NOT_USED;
    lctrl_mode     := PCNT_MODE_KEEP;
    hctrl_mode     := PCNT_MODE_KEEP;
    pos_mode       := PCNT_COUNT_INC;
    neg_mode       := PCNT_COUNT_INC;
    counter_h_lim  := 0;
    counter_l_lim  := 0;
    unit_          := _unit;
    channel        := PCNT_CHANNEL_0;
  end;
  EspErrorCheck(pcnt_unit_config(@config));

  // Use filter to ignore short spikes using pcnt_set_filter_value & pcnt_filter_enable
  EspErrorCheck(pcnt_set_filter_value(_unit, 1023));
  EspErrorCheck(pcnt_filter_enable(_unit));

  EspErrorCheck(pcnt_counter_pause(_unit));
  EspErrorCheck(pcnt_counter_clear(_unit));
  EspErrorCheck(pcnt_counter_resume(_unit));
end;

function TPulseFlowmeter.getReading: uint16;
begin
  if not EspErrorCheck(pcnt_get_counter_value(_unit, @Result)) then
    Result := $FFFF;
end;

end.

