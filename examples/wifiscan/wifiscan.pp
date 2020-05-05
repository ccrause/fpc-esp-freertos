program wifiscan;

{$include sdkconfig.inc}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_netif_types, esp_event,
  esp_wifi_default, nvs;

procedure printAPInfo(const AP: Twifi_ap_record_t);
var
  pb: PByte;
begin
  pb := @AP.ssid[0];
  while (pb^ > 0) and (pb - @AP.ssid[0] < 33) do
  begin
    if pb^ > 31 then
      write(char(pb^))
    else
      write('.');
    inc(pb);
  end;
  writeln;

  write('  bssid: ');
  pb := @AP.bssid[0];
  while (pb^ > 0) and (pb - @AP.bssid[0] < 6) do
  begin
    write(HexStr(pb^,2), ' ');
    inc(pb);
  end;
  writeln;

  writeln('  primary: ', AP.primary);
  writeln('  secondary: ', AP.second);
  writeln('  rssi: ', AP.rssi);
  writeln('  AuthMode: ', AP.authmode);
  writeln('  Pairwise cipher: ', AP.pairwise_cipher);
  writeln('  Group cipher: ', AP.group_cipher);
  writeln('  Antenna: ', AP.ant);
  writeln('  Supported wifi modes');
  writeln('    b: ', boolean(AP.phy_11b));
  writeln('    g: ', boolean(AP.phy_11g));
  writeln('    n: ', boolean(AP.phy_11n));
  writeln('    lr: ', boolean(AP.phy_lr));
  with AP.country do
  begin
    writeln('  Country info');
    write('    Country code: ');
    pb := @AP.country.cc[0];
    while (pb^ > 0) and (pb - @AP.country.cc[0] < 3) do
    begin
      if pb^ > 31 then
        write(char(pb^))
      else
        write('.');
      inc(pb);
    end;
    writeln;

    writeln('    Start channel: ', schan);
    writeln('    End channel: ', nchan);
    writeln('    Max power: ', max_tx_power);
    writeln('    Policy: ', policy);
  end;
end;

procedure wifi_scan;
const
  number = 6;
var
  sta_netif: Pesp_netif_t;
  cfg: Twifi_init_config_t;
  ap_info: array[0..number-1] of Twifi_ap_record_t;
  ap_info_len: uint16 = number;
  i: integer;
begin
  writeln('Enter scan');
  EspErrorCheck(esp_netif_init());
  EspErrorCheck(esp_event_loop_create_default());
  sta_netif := esp_netif_create_default_wifi_sta();
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA));
  EspErrorCheck(esp_wifi_start());
  EspErrorCheck(esp_wifi_scan_start(nil, true));
  ap_info_len := length(ap_info);
  EspErrorCheck(esp_wifi_scan_get_ap_records(@ap_info_len, @ap_info[0]));

  for i := 0 to ap_info_len-1 do
  begin
    write('AP #', i, ': ');
    printAPInfo(ap_info[i]);
    writeln;
  end;
end;

var
  ret: longint;

begin
  ret := nvs_flash_init();
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND) then
  begin
    nvs_flash_erase();
    ret := nvs_flash_init();
  end;
  wifi_scan();
end.

(***Compile program with
~/fpc/avr-new/compiler/xtensa/pp -Fu~/fpc/avr-new/rtl/units/xtensa-freertos/ -Tfreertos -Cawindowed -XPxtensa-esp32-elf- -al -Wpesp32 -Fl~/xtensa/esp-idf/libs -Fl$HOME/.espressif/tools/xtensa-esp32-elf/esp-2019r2-8.2.0/xtensa-esp32-elf/xtensa-esp32-elf/lib/ adc.pp

 ***Flash to esp32 with:

 - Assuming boot & partition for this sdk has been flashed before, only this app needs to be flashed:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 /home/christo/fpc/xtensa/adc/adc.bin

- If this is the first time a project with this IDF is built, also flash boot loader and partitions:
$ python /home/christo/xtensa/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 /home/christo/fpc/xtensa/helloworld/bootloader.bin 0x10000 /home/christo/fpc/xtensa/adc/adc.bin 0x8000 /home/christo/fpc/xtensa/helloworld/partitions_singleapp.bin

*)

