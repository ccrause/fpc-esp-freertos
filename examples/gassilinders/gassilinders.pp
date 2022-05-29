program gassilinders;

uses
  fmem, fthreads, freertos, task, nextion, portmacro, esp_err,
  gpio_types, readadc, nextionscreenconfig, shared,
  storage, pressureswitchover, handleSMS, logtouart,
  esp_heap_caps;

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

var
  //v: uint32;
  //s: string[16];
  loopcount: uint32;

begin
  initLogUart;
  //logwriteln(#13#10'initADC');
  //initADC;
  startAdcThread;

  // Preload initial pressure readings
  //readAdcData;
  //readAdcData;
  //readAdcData;
  //readAdcData;
  Sleep(1000);

  storage.initDefaultSettings;

  initModem;
  loopcount := 0;
  initDisplays;

  // While storage thread isn't running, at least load defaults
  logwriteln(#13#10'initCheckPressures');
  initCheckPressures;  // nonthreaded version

  //startSMShandlerThread;

  repeat
    logwrite('-');
    //readAdcData;
    //Sleep(10);

    // Only check pressures when not in manual mode
    if not storage.CylinderChangeoverSettings.ManualMode then
    begin
      checkPressures;
      Sleep(10);
    end;

    handleDisplayMessages;
    Sleep(10);
    processModemEvents;
    Sleep(230);

    if ((loopcount and 7) = 0) or flagUpdateValvePositions then
    begin
      updateDisplays;
      Sleep(10);
    end;

    //if (loopcount and 7) = 0 then
    //begin
    //  logwriteln('');
    //  printTaskReport;
    //  logwriteln('');
    //end;
    inc(loopcount);
  until false;
end.

