program simpleserver;

uses
  freertos, wificonnect, esp_log, esp_http_server, esp_err, http_parser,
  portable;

{$macro on}
{$inline on}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

const
  TAG = 'example';
  htmlpage = '<!DOCTYPE html><html><body><h1>Welcome to FPC + ESP-IDF</h1><p><img src="/fpclogo.gif" alt="FPC"></p></body></html>';

// Import fpc logo in gif format as array of char
{$include fpclogo.inc}

function hello_get_handler(req: Phttpd_req_t): Tesp_err_t; cdecl;
var
  buf: PChar;
  buf_len: uint32;
begin
  buf_len := httpd_req_get_hdr_value_len(req, 'Host') + 1;
  if (buf_len > 1) then
  begin
    buf := pvPortMalloc(buf_len);
    if (httpd_req_get_hdr_value_str(req, 'Host', buf, buf_len) = ESP_OK) then
      esp_log_write(ESP_LOG_INFO, TAG, 'Found header => Host: %s'#10, buf);
    vPortFree(buf);
  end;

  httpd_resp_send(req, htmlpage, length(htmlpage));

  result := ESP_OK;
end;

function fpclogo_get_handler(req: Phttpd_req_t): Tesp_err_t; cdecl;
var
  buf: PChar;
  buf_len: uint32;
begin
  buf_len := httpd_req_get_hdr_value_len(req, 'Host') + 1;
  if (buf_len > 1) then
  begin
    buf := pvPortMalloc(buf_len);
    if (httpd_req_get_hdr_value_str(req, 'Host', buf, buf_len) = ESP_OK) then
      esp_log_write(ESP_LOG_INFO, TAG, 'Found header => Host: %s'#10, buf);
    vPortFree(buf);
  end;

  httpd_resp_set_type(req, 'image/gif');
  httpd_resp_send(req, fpclogo, length(fpclogo));
  result := ESP_OK;
end;

function start_webserver: Thttpd_handle_t;
var
  server: Thttpd_handle_t;
  config: Thttpd_config_t;
  helloUriHandlerConfig: Thttpd_uri_t;
  fpcUriHandlerConfig: Thttpd_uri_t;
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

  esp_log_write(ESP_LOG_INFO, 'example', 'Starting server on port: %d'#10, config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    esp_log_write(ESP_LOG_INFO, TAG, 'Registering URI handler'#10);
    httpd_register_uri_handler(server, @helloUriHandlerConfig);
    httpd_register_uri_handler(server, @fpcUriHandlerConfig);
    result := server;
  end
  else
  begin
    result := nil;
    esp_log_write(ESP_LOG_ERROR, TAG, '### Failed to start httpd'#10);
  end;
end;

begin
  esp_log_level_set('wifi', ESP_LOG_WARN);

  connectWifi(AP_NAME, PWD);
  esp_log_write(ESP_LOG_INFO, TAG, 'Starting web server...'#10);
  start_webserver;

  repeat
    vTaskDelay(10);
  until false;
end.
