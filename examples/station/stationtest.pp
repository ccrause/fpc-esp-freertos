program stationtest;

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_netif_types, esp_event,
  esp_wifi_default, nvs, freertos, event_groups, esp_event_base, esp_bit_defs,
  esp_interface, projdefs, portmacro, esp_log;

{$macro on}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

const
  EXAMPLE_ESP_MAXIMUM_RETRY = 5;
  WIFI_CONNECTED_BIT        = BIT0;
  WIFI_FAIL_BIT             = BIT1;

var
  ret: longint;
  s_wifi_event_group: TEventGroupHandle_t;
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

procedure event_handler(arg: pointer; event_base: Tesp_event_base_t;
                                  event_id: int32; event_data: pointer);
var
  event: Pip_event_got_ip_t;
  addr: uint32;
begin
  writeln('Event: ', event_base, ' - eventid: ', event_id);
  if (event_base = WIFI_EVENT) and (Twifi_event_t(event_id) = WIFI_EVENT_STA_START) then
  begin
    writeln('Wifi started, now connecting...');
    esp_wifi_connect();
  end
  else if (event_base = WIFI_EVENT) and (Twifi_event_t(event_id) = WIFI_EVENT_STA_DISCONNECTED) then
  begin
    if (retries < EXAMPLE_ESP_MAXIMUM_RETRY) then
    begin
      esp_wifi_connect();
      inc(retries);
      writeln('Reconnect #, ', retries);
    end
    else
    begin
      xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
      writeln('### Connect to the AP fail');
    end;
  end
  else if (event_base = IP_EVENT) and (Tip_event_t(event_id) = IP_EVENT_STA_GOT_IP) then
  begin
    event := Pip_event_got_ip_t(event_data);
    addr := event^.ip_info.ip.addr;
    writeln('Got ip: ',  addr and $FF, '.', (addr shr 8) and $FF, '.', (addr shr 16) and $FF, '.', addr shr 24);
    retries := 0;
    xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
  end
  else
    writeln('Received event base = ', event_base, 'event ID = ', event_id);
end;


procedure wifi_init_sta;
var
  cfg: Twifi_init_config_t;
  wifi_config: Twifi_config_t;
  bits: TEventBits_t;
  i: integer;
begin
  s_wifi_event_group := xEventGroupCreate();
  EspErrorCheck(esp_netif_init());
  EspErrorCheck(esp_event_loop_create_default());
  esp_netif_create_default_wifi_sta();
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg));
  EspErrorCheck(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler_t(@event_handler), nil));
  EspErrorCheck(esp_event_handler_register(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler_t(@event_handler), nil));

  // Seems like the name and password are not treated as NULL terminated
  // so zero everything
  FillChar(wifi_config, sizeof(wifi_config), #0);
  CopyStringToBuffer(AP_NAME, @(wifi_config.sta.ssid[0]));
  CopyStringToBuffer(PWD, @(wifi_config.sta.password[0]));

  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA) );
  EspErrorCheck(esp_wifi_set_config(ESP_IF_WIFI_STA, @wifi_config));
  EspErrorCheck(esp_wifi_start());

  // Wait until either WIFI_CONNECTED_BIT or WIFI_FAIL_BIT bit gets set
  // by xEventGroupSetBits call in event_handler
  bits := xEventGroupWaitBits(s_wifi_event_group,
          WIFI_CONNECTED_BIT or WIFI_FAIL_BIT,
          pdFALSE,
          pdFALSE,
          portMAX_DELAY);

  if (bits and WIFI_CONNECTED_BIT) = WIFI_CONNECTED_BIT then
    writeln('Connected to ap')
  else if (bits and WIFI_FAIL_BIT) = WIFI_FAIL_BIT then
    writeln('### Failed to connect')
  else
    writeln('## UNEXPECTED EVENT, bits = ', bits);

  // Done, now clean up event group
  EspErrorCheck(esp_event_handler_unregister(IP_EVENT, ord(IP_EVENT_STA_GOT_IP), Tesp_event_handler_t(@event_handler)));
  EspErrorCheck(esp_event_handler_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, Tesp_event_handler_t(@event_handler)));
  vEventGroupDelete(s_wifi_event_group);
end;

begin
  // In case default logging causes flood of messages
  esp_log_level_set('*', ESP_LOG_WARN);

  // Initialize nvs, wifi driver stores credentials on successful connection
  ret := nvs_flash_init();
  if (ret = ESP_ERR_NVS_NO_FREE_PAGES) or (ret = ESP_ERR_NVS_NEW_VERSION_FOUND) then
  begin
    writeln('nvs_flash_erase');
    EspErrorCheck(nvs_flash_erase());
    writeln('nvs_flash_init()');
    ret := nvs_flash_init();
  end;
  EspErrorCheck(ret);

  // Now set ESP32 to station mode and connect to access point
  wifi_init_sta;
  // Now do nothing, please check on wifi router if this device MAC is connected
end.
