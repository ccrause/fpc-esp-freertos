program gassilinders;

uses
  fmem, fthreads, freertos, task, nextion, portmacro, esp_err,
  gpio_types, readadc, nextionscreenconfig, shared,
  storage, pressureswitchover, handleSMS, logtouart,
  esp_heap_caps;

procedure testNVS;
var
  i: integer;
begin
  writeln('initDefaultSettings');
  initDefaultSettings;

  writeln('savePressureSettings');
  savePressureSettings;
  writeln('saveNotificationSettings');
  saveNotificationSettings;
  writeln('saveCylinderChangeoverSettings');
  saveCylinderChangeoverSettings;

  FillByte(storage.PressureSettings.Warnings[0], length(storage.PressureSettings.Warnings)*SizeOf(integer), $FF);
  FillByte(storage.PressureSettings.LowPressures[0], length(storage.PressureSettings.LowPressures)*SizeOf(integer), $FF);
  FillByte(storage.PhoneNumbers[0], length(storage.PhoneNumbers)*SizeOf(integer), $FF);
  SMSNotificationSettings.Notifications := [];
  SMSNotificationSettings.RepeatInterval := 0;
  with CylinderChangeoverSettings do
  begin
    MinCylinderPressure := $FFFF;
    Hysteresis := $FFFF;
    CylinderChangeDelay := $FFFF;
    PreferredCylinderMode := true;
    PreferredCylinderIndex := $FFFF;
    ManualMode := false;
    ManualCylinderSelected := $FFFF;
  end;

  Sleep(1000);
  writeln;
  writeln('Loading settings');
  loadSettings;

  writeln('Warning settings:');
  for i := 0 to high(storage.PressureSettings.Warnings) do
    writeln(storage.PressureSettings.Warnings[i]);
  writeln('LowPressures settings:');
  for i := 0 to high(storage.PressureSettings.Warnings) do
    writeln(storage.PressureSettings.LowPressures[i]);
  writeln;

  writeln('PhoneNumbers');
  for i := 0 to high(storage.PhoneNumbers) do
    writeln(storage.PhoneNumbers[i]);

  writeln;
  writeln('CylinderChangeoverSettings');
  with CylinderChangeoverSettings do
  begin
    writeln('MinCylinderPressure: ', MinCylinderPressure);
    writeln('Hysteresis: ', Hysteresis);
    writeln('CylinderChangeDelay: ', CylinderChangeDelay);
    writeln('PreferredCylinderMode: ', PreferredCylinderMode);
    writeln('PreferredCylinderIndex: ', PreferredCylinderIndex);
    writeln('ManualMode: ', ManualMode);
    writeln('ManualCylinderSelected: ', ManualCylinderSelected);
  end;
end;

var
  loopcount: uint32;

begin
  //testNVS;
  //exit;

  initLogUart;
  //logwriteln(#13#10'initADC');
  //initADC;
  startAdcThread;

  if storage.loadSettings <> ESP_OK then
  begin
    logwriteln('');
    logwriteln('Error loading NVS settings, call initDefaultSettings');
    storage.initDefaultSettings;
  end;

  loopcount := 0;
  startSMShandlerThread;

  // Wait for Nextion to boot
  Sleep(1000);
  initDisplays;
  //initModem;

  // Wait for ADC thread to collect enough data for initial settings
  initCheckPressures;  // nonthreaded version

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
    //Sleep(10);
    //processModemEvents;
    Sleep(230);

    if ((loopcount and 7) = 0) or flagUpdateValvePositions then
    begin
      updateDisplays;
      Sleep(10);
    end;
    inc(loopcount);
  until false;
end.

{
OpenOCD command:
~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/bin/openocd -f ~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/share/openocd/scripts/interface/ftdi/ft232h-jtag.cfg -f ~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/share/openocd/scripts/board/esp-wroom-32.cfg

Flash command:
~/fpc/xtensa/esp-idf-4.3.2/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB1 --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 gassilinders.bin

Objdump command:
~/.espressif/tools/xtensa-esp32-elf/esp-2021r2-8.4.0/xtensa-esp32-elf/bin/xtensa-esp32-elf-objdump -d gassilinders.elf > gassilinders.lss

Dump nvs partition
~/fpc/xtensa/esp-idf-4.3.2/components/partition_table/parttool.py --port=/dev/ttyUSB0 read_partition --partition-name=nvs --output=tmp.hex

}
