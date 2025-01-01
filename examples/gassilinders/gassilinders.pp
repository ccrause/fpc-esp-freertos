program gassilinders;

uses
  fmem, fthreads, task, portmacro, esp_err,
  readadc, nextionscreenconfig, shared,
  storage, pressureswitchover, handleSMS, logtouart,
  esp_system;

{$include freertosconfig.inc}

const
  restartInterval = 8*3600*configTICK_RATE_HZ;  // reset every 8 hours

var
  loopcount: uint32;
  resetTimeout: TTickType;

begin
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

{
OpenOCD command:
~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/bin/openocd -f ~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/share/openocd/scripts/interface/ftdi/ft232h-jtag.cfg -f ~/.espressif/tools/openocd-esp32/v0.11.0-esp32-20211220/openocd-esp32/share/openocd/scripts/board/esp-wroom-32.cfg

Flash command:
~/fpc/xtensa/esp-idf-4.3.2/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 gassilinders.bin

Flash bootloader
~/fpc/xtensa/esp-idf-4.3.2/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 /home/christo/fpc/xtensa/esp-idf-4.3.2/libs/bootloader.bin 0x8000 /home/christo/fpc/xtensa/esp-idf-4.3.2/libs/partitions_singleapp.bin

Objdump command:
~/.espressif/tools/xtensa-esp32-elf/esp-2021r2-8.4.0/xtensa-esp32-elf/bin/xtensa-esp32-elf-objdump -d gassilinders.elf > gassilinders.lss

Dump nvs partition
~/fpc/xtensa/esp-idf-4.3.2/components/partition_table/parttool.py --port=/dev/ttyUSB0 read_partition --partition-name=nvs --output=tmp.hex

}
