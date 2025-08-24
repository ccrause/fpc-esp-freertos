unit wificonnect;

{$include freertosconfig.inc}

interface

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event, esp_event_base,
  {$ifdef CPULX6}
  esp_netif_types, esp_wifi_default, esp_bit_defs, esp_netif_ip_addr,
  {$else}
  nvs_flash, eagle_soc, tcpip_adapter, esp_event_legacy, ip4_addr,
  {$endif}
  nvs, event_groups,
  esp_interface, projdefs, portmacro;

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
//{$include credentials.ignore}

var
  StationConnected: boolean;

// NOTE: hostName is an optional name for this network interface.
// It should be shorter than TCPIP_HOSTNAME_MAX_SIZE = 32 bytes

// Connect to an external access point using provided credetials
procedure connectWifiAP(const APName, APassword: shortstring; hostName: pchar = nil);

// Create a wifi access point with the given name and password
procedure createWifiAP(const APName, APassword: shortstring; hostName: pchar = nil);

implementation

uses
  task; //debugging only!

const
  MaxRetries     = 100; // or loop until reconnected?
  WifiConnected  = BIT0;
  APStarted      = BIT0;
  WifiFail       = BIT1;

var
  ret: longint;
  WifiEventGroup: TEventGroupHandle;
  retries: uint32 = 0;
  pHostName: pchar;

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

{$ifdef CPULX6}
procedure EventHandler_ESP32(Arg: pointer; AEventBase: Tesp_event_base;
                                  AEventID: int32; AEventData: pointer);
var
  event: Pip_event_got_ip;
  addr: uint32;
begin
  if (AEventBase = WIFI_EVENT) then
  begin
    case Twifi_event(AEventID) of
      WIFI_EVENT_STA_START:
      begin
        writeln('Wifi started, now connecting...');
        esp_wifi_connect();
      end;
      WIFI_EVENT_STA_DISCONNECTED:
      begin
        if (retries < MaxRetries) then
        begin
          esp_wifi_connect();
          inc(retries);
          writeln('Reconnect #, ', retries);
        end
        else
        begin
          writeln('### Connect to the AP fail');
          if assigned(WifiEventGroup) then
            xEventGroupSetBits(WifiEventGroup, WifiFail);
        end;
      end;
      WIFI_EVENT_AP_START:
      begin
        writeln('Wifi AP started...');
        if assigned(WifiEventGroup) then
          xEventGroupSetBits(WifiEventGroup, APStarted);
      end;
      else
      begin
        writeln('Received Wifi event: ', Twifi_event(AEventID));
      end;
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
        retries := 0;
        if assigned(WifiEventGroup) then
          xEventGroupSetBits(WifiEventGroup, WifiConnected);
      end
      else
        writeln('Received IP event: ', Tip_event(AEventID));
    end;
  end
  else
    writeln('Received event base = ', AEventBase, 'event ID = ', AEventID);
end;
{$else}
function EventHandler_ESP8266(ctx: pointer; event: Psystem_event): Tesp_err;
var
  addr: uint32;
  err: Tesp_err;
begin
  writeln('Event: ', event^.event_id);
  if (event^.event_id = SYSTEM_EVENT_STA_DISCONNECTED) then
  begin
    StationConnected := false;
    if (retries < MaxRetries) then
    begin
      esp_wifi_connect();
      inc(retries);
      writeln('Reconnect #, ', retries);
      vTaskDelay(10000 div portTICK_PERIOD_MS);  // debug, try to avoid watchdog timeout
    end
    else
    begin
      writeln('### Connect to the AP fail');
      vTaskDelay(1);  // debug, try to avoid watchdog timeout

      if assigned(WifiEventGroup) then
        xEventGroupSetBits(WifiEventGroup, WifiFail);
    end;
  end
  else if (event^.event_id = SYSTEM_EVENT_STA_GOT_IP) then
  begin
    StationConnected := true;
    addr := event^.event_info.got_ip.ip_info.ip.addr;
    writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
    retries := 0;
    if assigned(WifiEventGroup) then
      xEventGroupSetBits(WifiEventGroup, WifiConnected);
  end
  else if (event^.event_id = SYSTEM_EVENT_STA_LOST_IP) then
  begin
    StationConnected := false;
    writeln('Lost IP');
  end
  else if (event^.event_id = SYSTEM_EVENT_AP_START) then
  begin
    if pHostName <> nil then
    begin
      err := tcpip_adapter_set_hostname(TCPIP_ADAPTER_IF_STA, pHostName);
      if err <> ESP_OK then
        writeln('Error setting hostname: ', err);
    end;

    if assigned(WifiEventGroup) then
      xEventGroupSetBits(WifiEventGroup, APStarted);
  end
  else
  begin
    writeln(  'Wifi event received: ', event^.event_id);
  end;
  result := ESP_OK;
end;

procedure on_wifi_disconnect(arg: pointer; event_base: Tesp_event_base;
                             event_id: int32; event_data: pointer);
begin
  writeln('Wi-Fi disconnected, trying to reconnect...');
  if Psystem_event_sta_disconnected(event_data)^.reason = ord(WIFI_REASON_BASIC_RATE_NOT_SUPPORT) then
  begin
    //Switch to 802.11 bgn mode */
    esp_wifi_set_protocol(ESP_IF_WIFI_STA, WIFI_PROTOCOL_11B or WIFI_PROTOCOL_11G or WIFI_PROTOCOL_11N);
  end;
  StationConnected := false;
  EspErrorCheck(esp_wifi_connect());
end;

procedure on_wifi_connect(arg: pointer; event_base: Tesp_event_base;
                             event_id: int32; event_data: pointer);
begin
  writeln('Wifi connected');
end;

procedure on_got_ip(arg: pointer; event_base: Tesp_event_base;
                             event_id: int32; event_data: pointer);
var
  addr: uint32;
begin
  addr := Pip_event_got_ip(event_data)^.ip_info.ip.addr;
  writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
  retries := 0;
  StationConnected := true;
  if assigned(WifiEventGroup) then
    xEventGroupSetBits(WifiEventGroup, WifiConnected);
end;

procedure on_lost_ip(arg: pointer; event_base: Tesp_event_base;
                             event_id: int32; event_data: pointer);
begin
  writeln('Lost ip');
  StationConnected := false;
end;

{$endif}

procedure WifiInitStationMode(const APName, APassword: shortstring);
const
  eventLoopInitDone: boolean = false;
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  bits: TEventBits;
begin
  retries := 0;
  WifiEventGroup := xEventGroupCreate();
  {$ifdef CPULX106}
  tcpip_adapter_init;
  {$endif}
  writeln('esp_netif_init');
  EspErrorCheck(esp_netif_init());
  writeln('esp_event_loop_create_default');
  EspErrorCheck(esp_event_loop_create_default());
  {$ifdef CPULX6}
  esp_netif_create_default_wifi_sta();
  {$endif}
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  writeln('esp_wifi_init');
  EspErrorCheck(esp_wifi_init(@cfg));
  {$ifdef CPULX6}
  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32), nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler_ESP32), nil));
  {$else}
  if not eventLoopInitDone then
    eventLoopInitDone := true;
  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ord(WIFI_EVENT_STA_CONNECTED), @on_wifi_connect, nil));
  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ord(WIFI_EVENT_STA_DISCONNECTED), @on_wifi_disconnect, nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), @on_got_ip, nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_LOST_IP), @on_lost_ip, nil));
  {$endif}

  writeln('esp_wifi_set_mode');
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA) );

  // If no AP name is given, just start wifi - it should use the previously saved credentials if available
  if APName <> '' then
  begin
    // Seems like the name and password are not treated as NULL terminated
    // so zero everything
    FillChar(wifi_config, sizeof(wifi_config), #0);
    CopyStringToBuffer(APName, @(wifi_config.sta.ssid[0]));
    CopyStringToBuffer(APassword, @(wifi_config.sta.password[0]));
    writeln('esp_wifi_set_config');
    EspErrorCheck(esp_wifi_set_config(ESP_IF_WIFI_STA, @wifi_config));
  end;
  writeln('esp_wifi_start');
  EspErrorCheck(esp_wifi_start());
  {$ifdef CPULX6}
  //EspErrorCheck(esp_netif_set_hostname(@esp_interface, 'esp32-fpc'));
  {$else}
  EspErrorCheck(esp_wifi_connect());

  if pHostName <> nil then
    EspErrorCheck(tcpip_adapter_set_hostname(TCPIP_ADAPTER_IF_STA, pHostName));
  {$endif}

  // Wait until either WifiConnected or WifiFail bit gets set
  // by xEventGroupSetBits call in EventHandler_ESP32

  bits := xEventGroupWaitBits(WifiEventGroup,
          WifiConnected or WifiFail,
          pdFALSE,
          pdFALSE,
          10 * configTICK_RATE_HZ);  // timeout after 10 seconds
          //portMAX_DELAY);

  if (bits and WifiConnected) = WifiConnected then
    writeln('Connected. Test connection by pinging the above IP address from the same network')
  else if (bits and WifiFail) = WifiFail then
    writeln('### Failed to connect')
  else
    writeln('Unexpected: timeout waiting for WifiEventGroup');

  // Done, now clean up event group
  {$ifdef CPULX6}
  EspErrorCheck(esp_event_handler_unregister(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler_ESP32)));
  EspErrorCheck(esp_event_handler_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32)));
  {$endif}
  vEventGroupDelete(WifiEventGroup);
end;

procedure connectWifiAP(const APName, APassword: shortstring; hostName: pchar);
begin
  pHostName := hostName;
  // In case default logging causes flood of messages
  //esp_log_level_set('*', ESP_LOG_WARN);

  // Initialize nvs, wifi driver stores credentials on successful connection
  ret := nvs_flash_init();
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6}or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    writeln('nvs_flash_erase');
    EspErrorCheck(nvs_flash_erase());
    writeln('nvs_flash_init()');
    ret := nvs_flash_init();
  end
  else if ret <> ESP_OK then
    writeln('nvs_flash_init error: ', ret);

  WifiInitStationMode(APName, APassword);
end;

procedure createWifiAP(const APName, APassword: shortstring; hostName: pchar);
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  {$ifdef CPULX106}
  info: Ttcpip_adapter_ip_info;
  {$else}
  netif_handle: Pesp_netif;
  info: Tesp_netif_ip_info;
  {$endif}
begin
  pHostName := hostName;
  writeln('nvs_flash_init');
  ret := nvs_flash_init();
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6}or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    writeln('nvs_flash_erase');
    EspErrorCheck(nvs_flash_erase());
    writeln('nvs_flash_init()');
    ret := nvs_flash_init();
  end;
  EspErrorCheck(ret);

  EspErrorCheck(esp_netif_init());
  EspErrorCheck(esp_event_loop_create_default());

  {$ifdef CPULX106}
  tcpip_adapter_init;
  FillByte(info, 0, sizeof(info));
	info.ip.addr := IP4ToAddress(192, 168, 4, 1);
  info.gw.addr := IP4ToAddress(192, 168, 4, 1);
  info.netmask.addr := IP4ToAddress(255, 255, 255, 0);
  EspErrorCheck(tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_AP));
  EspErrorCheck(tcpip_adapter_set_ip_info(TCPIP_ADAPTER_IF_AP, @info));
  EspErrorCheck(tcpip_adapter_dhcps_start(TCPIP_ADAPTER_IF_AP));
  {$else}
  netif_handle := esp_netif_create_default_wifi_ap();
  {$endif}

  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));

  {$ifdef CPULX6}
  // Writing from these events seem to cause an error 101 later on
  //writeln('esp_event_handler_register');
  //EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32), nil));
  //EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_AP_STAIPASSIGNED), Tesp_event_handler(@EventHandler_ESP32), nil));
  {$else}
  EspErrorCheck(esp_event_loop_init(Tsystem_event_cb(@EventHandler_ESP8266), nil));
  {$endif}
  // Seems like the name and password are not treated as NULL terminated
  // so zero everything
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

end.

