program simplehttpserver;

{ This demonstrates starting a connection to wifi and fall-back to
  softAP with a login page to enter details for wifi connection.
  Login to wifi uses blank SSID/password, so it will attempt connecting to
  stored wifi network credentials first.

  To work on esp8266 requires the SO_REUSEADDR option to re-use the server
  port number.  This requires the following commit:
  https://github.com/espressif/ESP8266_RTOS_SDK/commit/d93c5bb861b9ecf46efa49d9d5efd8a1ed5ac63b
  which requires the master branch, not v3.4.

  Once connected to a wifi network, a simple http server is started that
  shows a welcome message, display am ami,mated gif and reports the SSID
  and signal strength of the wifi connection.
  }

uses
  wificonnect2,
  esp_http_server, esp_err, http_parser,
  task, {$ifdef CPULX6}rtc_wdt,{$endif} ap_login,
  esp_log, esp_wifi, esp_wifi_types;

{$ifdef CPULX106}
// For esp8266 esp_wifi_stop depends on esp_now_deinit
{$linklib espnow, static}
{$endif}

{$macro on}
{$inline on}

const
  htmlpage1 = '<!DOCTYPE html><html><body><h1>Welcome to FPC + ESP-IDF</h1><p><img src="/fpclogo.gif" alt="FPC"></p>';
  // insert other info here
  htmlpage2 = '</body></html>';

// Import fpc logo in gif format as array of char
{$include fpclogo.inc}

function hello_get_handler(req: Phttpd_req): Tesp_err;
var
  APinfo: Twifi_ap_record;
  s: shortstring;
  sval: string[4];
begin
  httpd_resp_send_chunk(req, htmlpage1, length(htmlpage1));

  // Show SSID and RSSI
  if esp_wifi_sta_get_ap_info(@APinfo) = ESP_OK then
  begin
    Str(APinfo.rssi, sval);
    s := 'Connected to: ' + PChar(@APinfo.ssid[0]) +
         ' <'+sval+' dB>';

    httpd_resp_send_chunk(req, @s[1], length(s));
  end;

  httpd_resp_send_chunk(req, htmlpage2, length(htmlpage2));
  httpd_resp_send_chunk(req, nil, 0);
  result := ESP_OK;
end;

function fpclogo_get_handler(req: Phttpd_req): Tesp_err;
begin
  httpd_resp_set_type(req, 'image/gif');
  httpd_resp_send(req, fpclogo, length(fpclogo));
  result := ESP_OK;
end;

function start_webserver: Thttpd_handle;
var
  server: Thttpd_handle;
  config: Thttpd_config;
  helloUriHandlerConfig: Thttpd_uri;
  fpcUriHandlerConfig: Thttpd_uri;
begin
  config := HTTPD_DEFAULT_CONFIG();

  with helloUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @hello_get_handler;
    user_ctx  := nil;
  end;

  with fpcUriHandlerConfig do
  begin
    uri       := '/fpclogo.gif';
    method    := HTTP_GET;
    handler   := @fpclogo_get_handler;
    user_ctx  := nil;
  end;

  writeln('Starting server on port: ', config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    writeln('Registering URI handler');
    httpd_register_uri_handler(server, @helloUriHandlerConfig);
    httpd_register_uri_handler(server, @fpcUriHandlerConfig);
    result := server;
  end
  else
  begin
    result := nil;
    writeln('### Failed to start httpd');
  end;
end;

begin
  {$ifdef CPULX6}
  rtc_wdt_disable; // In case WDT was initialized by bootloader
  {$endif}
  esp_log_level_set('*', ESP_LOG_WARN);

  tmpSSID := '';
  tmpPassword := '';
  repeat
    connectWifiAP(tmpSSID, tmpPassword);
    if not stationConnected then
    begin
      writeln('Could not connect to wifi, starting local access point');
      stopWifi;
      // Get list of access points for APserver
      wifi_scan;

      reconnect := false;
      createWifiAP('selectSSID', '');
      start_APserver;
      while not reconnect do
        vTaskDelay(100);

      writeln('Attempting reconnecting to wifi');
      stop_APserver;
      stopWifi;
    end;
  until stationConnected;

  writeln('Starting web server...');
  start_webserver;

  repeat
    vTaskDelay(100);
  until false;
end.
