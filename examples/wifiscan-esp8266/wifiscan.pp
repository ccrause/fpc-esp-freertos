program wifiscan;

{$include sdkconfig.inc}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_event,
  nvs, nvs_flash, task, esp_event_loop;

function eventhandler(ctx: pointer; event: Psystem_event): Tesp_err; cdecl;
begin
  writeln('Event -  ', event^.event_id);
  Result := ESP_OK;
end;

procedure printAPInfo(const AP: Twifi_ap_record);
var
  pb: PByte;
  i: integer;
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
    i := 0;
    while (pb^ > 0) and (pb - @AP.country.cc[0] < 3) and ( i < 3) do
    begin
      if pb^ > 31 then
        write(char(pb^))
      else
        write('.');
      inc(pb);
      inc(i);
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
  number = 10;
var
  cfg: Twifi_init_config;
  ap_info: array[0..number-1] of Twifi_ap_record;
  ap_info_len: uint16 = number;
  i: integer;
begin
  EspErrorCheck(esp_event_loop_init(@eventhandler, nil));
  writeln('Enter scan');
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA));
  EspErrorCheck(esp_wifi_start());
  EspErrorCheck(esp_wifi_scan_start(nil, true));
  ap_info_len := length(ap_info);
  EspErrorCheck(esp_wifi_scan_get_ap_records(@ap_info_len, @ap_info[0]));
  EspErrorCheck(esp_wifi_scan_get_ap_num(@ap_info_len));

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
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) {or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND)} then
  begin
    nvs_flash_erase();
    ret := nvs_flash_init();
  end;

  wifi_scan();
  repeat
    vTaskDelay(10);
  until false;
end.

