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
  WebMessage = 'Hello from FPC with ESP-IDF';

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

  httpd_resp_send(req, WebMessage, length(WebMEssage));
  result := ESP_OK;
end;

function start_webserver: Thttpd_handle_t;
var
  server: Thttpd_handle_t;
  config: Thttpd_config_t;
  helloUriHandlerConfig: Thttpd_uri_t;
begin
  config := HTTPD_DEFAULT_CONFIG();

  with helloUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @hello_get_handler;
    user_ctx  := nil;
  end;

  esp_log_write(ESP_LOG_INFO, 'example', 'Starting server on port: %d'#10, config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    esp_log_write(ESP_LOG_INFO, TAG, 'Registering URI handler'#10);
    httpd_register_uri_handler(server, @helloUriHandlerConfig);
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
