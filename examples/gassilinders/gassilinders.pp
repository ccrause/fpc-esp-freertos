program gassilinders;

uses
  fmem, fthreads, task, portmacro, esp_err,
  readadc, nextionscreenconfig, shared,
  storage, pressureswitchover, handleSMS, logtouart,
  esp_system, rtc_wdt;

{$include freertosconfig.inc}

const
  restartInterval = 8*3600*configTICK_RATE_HZ;  // reset every 8 hours

var
  loopcount: uint32;
  resetTimeout: TTickType;

begin
  rtc_wdt_disable;
  initLogUart;
  startAdcThread;
  // Load saved settings from NVS
  if storage.loadSettings <> ESP_OK then
  begin
    logwriteln('');
    logwriteln('Error loading NVS settings, call initDefaultSettings');
    storage.initDefaultSettings;
  end;

  loopcount := 0;
  startSMShandlerThread;

  // Wait for Nextion to boot,
  // and readADC to collect enough readings before calling initCheckPressures
  Sleep(1000);
  initDisplays;
  initCheckPressures;

  resetTimeout := xTaskGetTickCount + restartInterval;
  repeat
    logwrite('-');
    // Only check pressures when not in manual mode
    if not storage.CylinderChangeoverSettings.ManualMode then
    begin
      checkPressures;
      Sleep(10);
    end;

    handleDisplayMessages;
    Sleep(230);
    // Only update displays every 8th iteration
    if ((loopcount and 7) = 0) {or flagUpdateValvePositions} then
    begin
      updateDisplays;
      Sleep(10);
    end;
    inc(loopcount);

    if xTaskGetTickCount > resetTimeout then
    begin
      // Reset network connection
      handleSMS.resetModemNetwork;
      // Wait until network reset is finished
      // or until maximum time of 20 seconds has passed.
      loopcount := 20;
      repeat
        Sleep(1000);
        dec(loopcount);
      until handleSMS.resetModemFlagCleared or (loopcount = 0);
      esp_restart;
    end;
    Sleep(200);
  until false;
end.
