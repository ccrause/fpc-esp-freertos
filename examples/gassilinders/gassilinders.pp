program gassilinders;

uses
  fthreads, freertos, task, nextion, portmacro, esp_err,
  gpio_types, uart, uart_types, readadc, nextionscreenconfig, shared,
  storage, pressureswitchover;

procedure testNVS;
begin
  writeln('Loading settings');
  loadSettings;
  write('Phone numbers loaded. #0: ');
  //for i := low(PhoneNumbers) to high(PhoneNumbers) do
    writeln(PhoneNumbers[0]);
  writeln('Now changing phone number 0 and saving.');
  PhoneNumbers[0] := PhoneNumbers[0] + 123;
  storage.saveNotificationSettings;

  //writeln;
  //writeln('Pressure.Warning[4] = ', PressureSettings.Warnings[numGasStations-1]);
  //PressureSettings.Warnings[0] := PressureSettings.Warnings[0] + 3;
  //PressureSettings.Warnings[numGasStations-1] := PressureSettings.Warnings[numGasStations-1] + 1;
  //savePressureSettings;

end;

begin
  startAdcThread;
  startDisplayThread;
  // While storage thread isn't running, at least load defaults
  storage.initDefaultSettings;
  // Wait for displays to finish initializing
  Sleep(500);
  startPressureMonitorThread;
  repeat
    Sleep(250);
  until false;
end.

