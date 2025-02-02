unit wificonnect2;

{ This is a helper unit to either connect to an access point
  or to create a local access point.

  The global variable stationConnected is true when connected to an AP. }

{$include freertosconfig.inc}

interface

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event, esp_event_base,
  {$ifdef CPULX6}
  esp_netif_types, esp_wifi_default, esp_bit_defs, esp_netif_ip_addr,
  {$else}
  nvs_flash, eagle_soc, tcpip_adapter, ip4_addr,
  {$endif}
  nvs, event_groups,
  esp_interface, projdefs;

var
  stationConnected: boolean;

// NOTE: hostName is an optional name for this network interface.
// It should not exceed TCPIP_HOSTNAME_MAX_SIZE = 32 bytes

// Connect to an external access point using provided credetials
procedure connectWifiAP(const APName, APassword: shortstring; hostName: pchar = nil);

// Create a wifi access point with the given name and password
procedure createWifiAP(const APName, APassword: shortstring);

procedure stopWifi;

implementation

const
  WifiConnect    = BIT0;
  WifiFail       = BIT1;

var
  WifiEventGroup: TEventGroupHandle;
  {$ifdef CPULX6}
  netif_handle: Pesp_netif;
  {$endif}
  isNetifInit: boolean = false;
  isEventLoopCreated: boolean = false;

// Rather use StrPLCopy, but while sysutils are not yet working...
procedure CopyStringToBuffer(const s: shortstring; const buf: PChar);
var
  i: integer;
  pc: Pchar;
begin
  i := 1;
  pc := buf;
  while i <= length(s) do
  begin
    pc^ := s[i];
    inc(pc);
    inc(i);
  end;
end;

procedure EventHandler(Arg: pointer; AEventBase: Tesp_event_base;
                       AEventID: int32; AEventData: pointer);
var
  event: Pip_event_got_ip;
  addr: uint32;
begin
  if (AEventBase = WIFI_EVENT) then
  begin
    case Twifi_event(AEventID) of
      WIFI_EVENT_STA_START: esp_wifi_connect();

      WIFI_EVENT_STA_DISCONNECTED:
      begin
        stationConnected := false;
        esp_wifi_connect();
      end;

      else
        writeln('Received Wifi event: ', Twifi_event(AEventID));
    end;
  end
  else if (AEventBase = IP_EVENT) then
  begin
    case Tip_event(AEventID) of
      IP_EVENT_STA_GOT_IP:
      begin
        event := Pip_event_got_ip(AEventData);
        addr := event^.ip_info.ip.addr;
        writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
        stationConnected := true;

        if assigned(WifiEventGroup) then
          xEventGroupSetBits(WifiEventGroup, WifiConnect);
      end;

      IP_EVENT_STA_LOST_IP: stationConnected := false;

      else
        writeln('Received IP event: ', Tip_event(AEventID));
    end;
  end
  else
    writeln('Received event base = ', AEventBase, 'event ID = ', AEventID);
end;

function initNVS: Tesp_err;
begin
  Result := nvs_flash_init();
  if (Result = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6}or (Result = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    writeln('nvs_flash_erase');
    EspErrorCheck(nvs_flash_erase());
    writeln('nvs_flash_init()');
    Result := nvs_flash_init();
  end
  else if Result <> ESP_OK then
    writeln('NVS init error: ', Result);
end;

procedure connectWifiAP(const APName, APassword: shortstring; hostName: pchar);
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  bits: TEventBits;
begin
  EspErrorCheck(initNVS);

  stationConnected := false;
  WifiEventGroup := xEventGroupCreate();

  if not isNetifInit then
    EspErrorCheck(esp_netif_init());

  if not isEventLoopCreated then
  begin
    EspErrorCheck(esp_event_loop_create_default());
    isEventLoopCreated := true;
  end;
  {$ifdef CPULX6}
  netif_handle := esp_netif_create_default_wifi_sta();
  {$endif}

  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));

  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler), nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler), nil));

  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA) );

  // If no AP name is given, just start wifi
  // it should use previously saved credentials if available
  if APName <> '' then
  begin
    FillChar(wifi_config, sizeof(wifi_config), #0);
    CopyStringToBuffer(APName, @(wifi_config.sta.ssid[0]));
    CopyStringToBuffer(APassword, @(wifi_config.sta.password[0]));
    EspErrorCheck(esp_wifi_set_config(ESP_IF_WIFI_STA, @wifi_config));
  end;

  EspErrorCheck(esp_wifi_start());

  if hostName <> nil then
    {$ifdef CPULX6}
    EspErrorCheck(esp_netif_set_hostname(netif_handle, @hostName[1]));
    {$else}
    EspErrorCheck(tcpip_adapter_set_hostname(TCPIP_ADAPTER_IF_STA, @hostName[1]));
    {$endif}

  EspErrorCheck(esp_wifi_connect());

  // Wait until either WifiConnected or WifiFail bit gets set
  // by xEventGroupSetBits call in EventHandler_ESP32
  bits := xEventGroupWaitBits(WifiEventGroup,
          WifiConnect or WifiFail,
          pdFALSE,
          pdFALSE,
          10 * configTICK_RATE_HZ);  // timeout after 10 seconds

  if (bits and WifiConnect) = WifiConnect then
    writeln('Connected. Test connection by pinging the above IP address from the same network')
  else if (bits and WifiFail) = WifiFail then
    writeln('### Failed to connect')
  else
    writeln('Unexpected: timeout waiting for WifiEventGroup');
end;

procedure createWifiAP(const APName, APassword: shortstring);
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  {$ifdef CPULX106}
  info: Ttcpip_adapter_ip_info;
  {$else}
  info: Tesp_netif_ip_info;
  {$endif}
begin
  EspErrorCheck(initNVS);

  if not isNetifInit then
    EspErrorCheck(esp_netif_init());

  if not isEventLoopCreated then
  begin
    EspErrorCheck(esp_event_loop_create_default());
    isEventLoopCreated := true;
  end;

  FillByte(info, 0, sizeof(info));
  info.ip.addr := IP4ToAddress(192, 168, 4, 1);
  info.gw.addr := IP4ToAddress(192, 168, 4, 1);
  info.netmask.addr := IP4ToAddress(255, 255, 255, 0);

  {$ifdef CPULX106}
  tcpip_adapter_init;
  EspErrorCheck(tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_AP));
  EspErrorCheck(tcpip_adapter_set_ip_info(TCPIP_ADAPTER_IF_AP, @info));
  EspErrorCheck(tcpip_adapter_dhcps_start(TCPIP_ADAPTER_IF_AP));
  {$else}
  netif_handle := esp_netif_create_default_wifi_ap();
  esp_netif_dhcps_stop(netif_handle);
  esp_netif_set_ip_info(netif_handle, @info);
  esp_netif_dhcps_start(netif_handle);
  {$endif}

  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));

  FillChar(wifi_config, sizeof(wifi_config), #0);
  if APassword = '' then
    wifi_config.ap.authmode := WIFI_AUTH_OPEN
  else
  begin
    CopyStringToBuffer(APassword, @(wifi_config.ap.password[0]));
    wifi_config.ap.authmode := WIFI_AUTH_WPA2_PSK;
  end;
  CopyStringToBuffer(APName, @(wifi_config.ap.ssid[0]));
  wifi_config.ap.ssid_len := length(APName);
  wifi_config.ap.channel := 1;
  wifi_config.ap.ssid_hidden := 0;
  wifi_config.ap.beacon_interval := 100;
  wifi_config.ap.max_connection := 4;

  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_AP));
  EspErrorCheck(esp_wifi_set_config(WIFI_IF_AP, @wifi_config));
  EspErrorCheck(esp_wifi_start());
end;

procedure stopWifi;
begin
  esp_wifi_stop();
  esp_wifi_deinit();
  {$ifdef CPULX6}
  esp_wifi_clear_default_wifi_driver_and_handlers(netif_handle);
  esp_netif_destroy(netif_handle);
  {$else}
  tcpip_adapter_clear_default_wifi_handlers;
  {$endif}
end;

end.
