unit wificonnect;

interface

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event,
  {$ifdef CPULX6}
  esp_netif_types, esp_wifi_default, esp_event_base, esp_bit_defs, esp_netif_ip_addr,
  {$else}
  nvs_flash, eagle_soc, tcpip_adapter, esp_event_loop, ip4_addr,
  {$endif}
  nvs, event_groups,
  esp_interface, projdefs, portmacro;

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
//{$include credentials.ignore}

// Connect to an external access point using provided credetials
procedure connectWifiAP(const APName, APassword: string);

// Create a wifi access point with the given name and password
procedure createWifiAP(const APName, APassword: string);

implementation

uses
  task; //debugging only!

const
  MaxRetries     = 5;
  WifiConnected  = BIT0;
  APStarted      = BIT0;
  WifiFail       = BIT1;

var
  ret: longint;
  WifiEventGroup: TEventGroupHandle;
  retries: uint32 = 0;

// Rather use StrPLCopy, but while sysutils are not yet working...
procedure CopyStringToBuffer(const s: string; const buf: PChar);
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
begin
  writeln('Event: ', event^.event_id);
  if (event^.event_id = SYSTEM_EVENT_STA_START) then
  begin
    writeln('Wifi started, now connecting...');
    esp_wifi_connect();
  end
  else if (event^.event_id = SYSTEM_EVENT_STA_DISCONNECTED) then
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
  end
  else if (event^.event_id = SYSTEM_EVENT_STA_GOT_IP) then
  begin
    addr := event^.event_info.got_ip.ip_info.ip.addr;
    writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
    retries := 0;
    writeln('### Connect to the AP fail');
    if assigned(WifiEventGroup) then
      xEventGroupSetBits(WifiEventGroup, WifiConnected);
  end
  else if (event^.event_id = SYSTEM_EVENT_AP_START) then
  begin
    if assigned(WifiEventGroup) then
      xEventGroupSetBits(WifiEventGroup, APStarted);
  end
  else
  begin
    writeln(  'Wifi event received: ', event^.event_id);
  end;
  result := ESP_OK;
end;
{$endif}

procedure WifiInitStationMode(const APName, APassword: string);
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  bits: TEventBits;
begin
  writeln('xEventGroupCreate');
  vTaskDelay(10);
  WifiEventGroup := xEventGroupCreate();
  {$ifdef CPULX106}
  tcpip_adapter_init;
  {$endif}
  writeln('esp_netif_init');
  vTaskDelay(10);
  EspErrorCheck(esp_netif_init());
  writeln('esp_event_loop_create_default');
  vTaskDelay(10);
  EspErrorCheck(esp_event_loop_create_default());
  {$ifdef CPULX6}
  esp_netif_create_default_wifi_sta();
  {$endif}
  writeln('WIFI_INIT_CONFIG_DEFAULT');
  vTaskDelay(10);
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  writeln('esp_wifi_init');
  vTaskDelay(10);
  EspErrorCheck(esp_wifi_init(@cfg));
  {$ifdef CPULX6}
  writeln('esp_event_handler_register');
  vTaskDelay(10);
  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32), nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler_ESP32), nil));
  {$else}
  EspErrorCheck(esp_event_loop_init(Tsystem_event_cb(@EventHandler_ESP8266), nil));
  {$endif}
  // Seems like the name and password are not treated as NULL terminated
  // so zero everything
  FillChar(wifi_config, sizeof(wifi_config), #0);
  CopyStringToBuffer(APName, @(wifi_config.sta.ssid[0]));
  CopyStringToBuffer(APassword, @(wifi_config.sta.password[0]));

  writeln('esp_wifi_set_mode');
  vTaskDelay(10);
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA) );
  EspErrorCheck(esp_wifi_set_config(ESP_IF_WIFI_STA, @wifi_config));
  EspErrorCheck(esp_wifi_start());

  // Wait until either WifiConnected or WifiFail bit gets set
  // by xEventGroupSetBits call in EventHandler_ESP32

  bits := xEventGroupWaitBits(WifiEventGroup,
          WifiConnected or WifiFail,
          pdFALSE,
          pdFALSE,
          portMAX_DELAY);

  if (bits and WifiConnected) = WifiConnected then
    writeln('Connected. Test connection by pinging the above IP address from the same network')
  else if (bits and WifiFail) = WifiFail then
    writeln('### Failed to connect')
  else
    writeln('## UNEXPECTED EVENT, bits = ', bits);

  // Done, now clean up event group
  {$ifdef CPULX6}
  EspErrorCheck(esp_event_handler_unregister(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler_ESP32)));
  EspErrorCheck(esp_event_handler_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32)));
  {$endif}
  vEventGroupDelete(WifiEventGroup);
end;

procedure connectWifiAP(const APName, APassword: string);
begin
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
  end;
  EspErrorCheck(ret);

  WifiInitStationMode(APName, APassword);
end;

procedure createWifiAP(const APName, APassword: string);
var
  cfg: Twifi_init_config;
  wifi_config: Twifi_config;
  bits: TEventBits;
  {$ifdef CPULX106}
  info: Ttcpip_adapter_ip_info;
  {$else}
  netif_handle: Pesp_netif;
  info: Tesp_netif_ip_info;
  {$endif}
begin
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

//  WifiEventGroup := xEventGroupCreate();

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
  // This doesn't seem to work on ESP32
  //esp_netif_dhcps_stop(netif_handle);
  //esp_netif_set_ip_info(netif_handle, @info);
  //esp_netif_dhcps_start(netif_handle);
  {$endif}

  //esp_wifi_set_storage(WIFI_STORAGE_RAM);

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

  // Wait until APStarted bit gets set
  // by xEventGroupSetBits call in EventHandler_ESP32
  //writeln('Waiting for AP to start');
  //bits := xEventGroupWaitBits(WifiEventGroup,
  //        APStarted,
  //        pdFALSE,
  //        pdFALSE,
  //        portMAX_DELAY);

  // Done, now clean up event group
  {$ifdef CPULX6}
  //EspErrorCheck(esp_event_handler_unregister(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler(@EventHandler_ESP32)));
  //EspErrorCheck(esp_event_handler_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler(@EventHandler_ESP32)));
  {$endif}
  //vEventGroupDelete(WifiEventGroup);
end;

end.

