unit wificonnect;

interface

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event,
  {$ifdef CPULX6}
  esp_netif_types, esp_wifi_default, esp_event_base, esp_bit_defs,
  {$else}
  nvs_flash, eagle_soc, tcpip_adapter, esp_event_loop,
  {$endif}
  nvs, event_groups,
  esp_interface, projdefs, portmacro;

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
//{$include credentials.ignore}

procedure connectWifi(const APName, APassword: string);

implementation

const
  MaxRetries     = 5;
  WifiConnected  = BIT0;
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
  writeln('Event: ', AEventBase, ' - eventid: ', AEventID);
  if (AEventBase = WIFI_EVENT) and (Twifi_event(AEventID) = WIFI_EVENT_STA_START) then
  begin
    writeln('Wifi started, now connecting...');
    esp_wifi_connect();
  end
  else if (AEventBase = WIFI_EVENT) and (Twifi_event(AEventID) = WIFI_EVENT_STA_DISCONNECTED) then
  begin
    if (retries < MaxRetries) then
    begin
      esp_wifi_connect();
      inc(retries);
      writeln('Reconnect #, ', retries);
    end
    else
    begin
      xEventGroupSetBits(WifiEventGroup, WifiFail);
      writeln('### Connect to the AP fail');
    end;
  end
  else if (AEventBase = IP_EVENT) and (Tip_event(AEventID) = IP_EVENT_STA_GOT_IP) then
  begin
    event := Pip_event_got_ip(AEventData);
    addr := event^.ip_info.ip.addr;
    writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
    retries := 0;
    xEventGroupSetBits(WifiEventGroup, WifiConnected);
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
      xEventGroupSetBits(WifiEventGroup, WifiFail);
      writeln('### Connect to the AP fail');
    end;
  end
  else if (event^.event_id = SYSTEM_EVENT_STA_GOT_IP) then
  begin
    addr := event^.event_info.got_ip.ip_info.ip.addr;
    writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
    retries := 0;
    xEventGroupSetBits(WifiEventGroup, WifiConnected);
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
  WifiEventGroup := xEventGroupCreate();
  {$ifdef CPULX106}
  tcpip_adapter_init;
  {$endif}
  EspErrorCheck(esp_netif_init());
  EspErrorCheck(esp_event_loop_create_default());
  {$ifdef CPULX6}
  esp_netif_create_default_wifi_sta();
  {$endif}
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));
  {$ifdef CPULX6}
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

procedure connectWifi(const APName, APassword: string);
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

end.

