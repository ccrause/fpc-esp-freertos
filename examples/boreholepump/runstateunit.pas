unit runstateunit;

{ This unit implements a finite state machine that keeps track of the
  pump logic state and execute actions as required per state. }

interface

type
  TRunState = (
    rsIdle,               // Waiting for low level to start pump
    rsRunNoStopTimeout,   // Run without checks until timer expires
    rsRun,                // Run and check high level and low flow
    rsLowFlowTimeout);       // Stop and wait for timeout then move to idle

  { TRunStateMachine }

  TRunStateMachine = object
  private
    fState: TRunState;
    fRunNoStopTimeout: integer;
    fLowFlowTimeout: integer;

    procedure fStop;
    procedure fStart;
    procedure setLowLevel;
    procedure clearLowLevel;
  public
    constructor init;
    // Note: level interpretation is inverse!
    procedure update(level: integer; flow: single);
  end;

implementation

uses
  settingsmanager, gpio, gpio_types, hardwareconfig;

{ TRunStateMachine }

procedure TRunStateMachine.fStop;
begin
  gpio_set_level(Tgpio_num(pumpOutputPin), 0);
end;

procedure TRunStateMachine.fStart;
begin
  gpio_set_level(Tgpio_num(pumpOutputPin), 1);
end;

procedure TRunStateMachine.setLowLevel;
begin
  gpio_set_level(Tgpio_num(lowLevelPin), 1);
end;

procedure TRunStateMachine.clearLowLevel;
begin
  gpio_set_level(Tgpio_num(lowLevelPin), 0);
end;

constructor TRunStateMachine.init;
var
  cfg: Tgpio_config;
begin
  cfg.pin_bit_mask := (1 shl pumpOutputPin) or (1 shl lowLevelPin);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);
  gpio_set_direction(Tgpio_num(pumpOutputPin), GPIO_MODE_OUTPUT);
  gpio_set_level(Tgpio_num(pumpOutputPin), 0);

  fState := rsIdle;
  fRunNoStopTimeout := 0;
  fLowFlowTimeout := 0;
end;

procedure TRunStateMachine.update(level: integer; flow: single);
begin
{ Start/stop checks:
    IDLE - level low? -> RUN_NO_LF(count)
    RUN_NO_LF - timeout? -> RUN
    RUN - level high? -> IDLE
                      \ - low flow? -> IDLE_TIME
    IDLE_TIME - timeout? -> IDLE
}
  case fState of
    rsIdle:               // Waiting for low level to start pump
    begin
      if level > settings.LLstart then
      begin
        fStart();
        fState := rsRunNoStopTimeout;
        fRunNoStopTimeout := settings.startDeadTime;  // seconds
        writeln('state: rsIdle -> rsRunNoStopTimeout');
      end;
    end;

    rsRunNoStopTimeout:   // Run without checks until timer expires
    begin
      if fRunNoStopTimeout > 0 then
        dec(fRunNoStopTimeout)
      else
      begin
        fState := rsRun;
        writeln('state: rsRunNoStopTimeout -> rsRun');
      end;
    end;

    rsRun:                // check high level and low flow
    begin
      if (level < settings.HLstop) then
      begin
        fStop();
        fState := rsIdle;
        writeln('state: rsRun -> rsIdle');
      end
      else if (flow < settings.LFstop) then
      begin
        fStop();
        fState := rsLowFlowTimeout;
        fLowFlowTimeout := settings.restartDelay * 60;
        writeln('state: rsRun -> rsLowFlowTimeout');
      end;
    end;

    rsLowFlowTimeout:        // Stop and wait for timeout then move to idle
    begin
      if fLowFlowTimeout > 0 then
        dec(fLowFlowTimeout)
      else
      begin
        fState := rsIdle;
        writeln('state: rsLowFlowTimeout -> rsIdle');
      end;
    end;
  end; // case runState

  // Check for low level
  if level > settings.LLstart then
    setLowLevel()
  else
    clearLowLevel();
end;

end.

