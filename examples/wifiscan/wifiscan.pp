program wifiscan;

{$include sdkconfig.inc}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event
  {$ifdef CPULX6}, esp_wifi_default{$endif}
  , nvs
  {$ifdef CPULX106}, nvs_flash, esp_event_legacy{$endif};

{$ifdef CPULX106}
function eventhandler(ctx: pointer; event: Psystem_event): Tesp_err;
begin
  writeln('Event -  ', event^.event_id);
  Result := ESP_OK;
end;
{$endif}

procedure printAPInfo(const AP: Twifi_ap_record);
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
  if ord(AP.second) <= ord(WIFI_SECOND_CHAN_BELOW) then
    writeln('  secondary: ', AP.second)
  else
    writeln('  secondary: INVALID');
  writeln('  rssi: ', AP.rssi);
  if ord(AP.authmode) < ord(WIFI_AUTH_MAX) then
    writeln('  AuthMode: ', AP.authmode)
  else
    writeln('  AuthMode: INVALID');
  if ord(AP.pairwise_cipher) <= ord(WIFI_CIPHER_TYPE_UNKNOWN) then
    writeln('  Pairwise cipher: ', AP.pairwise_cipher)
  else
    writeln('  Pairwise cipher: INVALID');
  if ord(AP.group_cipher) <= ord(WIFI_CIPHER_TYPE_UNKNOWN) then
    writeln('  Group cipher: ', AP.group_cipher)
  else
    writeln('  Group cipher: INVALID');
  if ord(AP.ant) <= ord(WIFI_ANT_MAX) then
    writeln('  Antenna: ', AP.ant)
  else
    writeln('  Antenna: INVALID');
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
    if ord(policy) <= ord(WIFI_COUNTRY_POLICY_MANUAL) then
      writeln('    Policy: ', policy)
    else
      writeln('    Policy: INVALID');
  end;
end;

procedure wifi_scan;
const
  number = 10;
var
  {$ifdef CPULX6}sta_netif: Pesp_netif;{$endif}
  cfg: Twifi_init_config;
  ap_info: array[0..number-1] of Twifi_ap_record;
  ap_info_len: uint16 = number;
  i: integer;
begin
  writeln('Enter scan');
  {$ifdef CPULX6}
  EspErrorCheck(esp_netif_init());
  EspErrorCheck(esp_event_loop_create_default());
  sta_netif := esp_netif_create_default_wifi_sta();
  {$else}
  EspErrorCheck(esp_event_loop_init(@eventhandler, nil));
  {$endif}
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA));
  EspErrorCheck(esp_wifi_start());
  EspErrorCheck(esp_wifi_scan_start(nil, true));
  ap_info_len := length(ap_info);
  EspErrorCheck(esp_wifi_scan_get_ap_records(@ap_info_len, @ap_info[0]));
  EspErrorCheck(esp_wifi_scan_get_ap_num(@ap_info_len));

  if ap_info_len > 0 then
    for i := 0 to ap_info_len-1 do
    begin
      write('AP #', i, ': ');
      printAPInfo(ap_info[i]);
      writeln;
    end
  else
    writeln('No AP records returned.');
end;

var
  ret: longint;

begin
  ret := nvs_flash_init();
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6}or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    nvs_flash_erase();
    ret := nvs_flash_init();
  end;
  wifi_scan();
end.

