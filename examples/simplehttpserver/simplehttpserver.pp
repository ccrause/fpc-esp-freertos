program simplehttpserver;

uses
  freertos,
  wificonnect,
  esp_http_server, esp_err, http_parser,
  portable, task;

{$macro on}
{$inline on}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

const
  htmlpage = '<!DOCTYPE html><html><body><h1>Welcome to FPC + ESP-IDF</h1><p><img src="/fpclogo.gif" alt="FPC"></p></body></html>';

// Import fpc logo in gif format as array of char
{$include ../common/fpclogo.inc}

function hello_get_handler(req: Phttpd_req): Tesp_err;
var
  buf: PChar;
  buf_len: uint32;
begin
  buf_len := httpd_req_get_hdr_value_len(req, 'Host') + 1;
  if (buf_len > 1) then
  begin
    buf := pvPortMalloc(buf_len);
    if (httpd_req_get_hdr_value_str(req, 'Host', buf, buf_len) = ESP_OK) then
      writeln('Found header => Host: ', buf);
    vPortFree(buf);
  end;

  httpd_resp_send(req, htmlpage, length(htmlpage));

  result := ESP_OK;
end;

function fpclogo_get_handler(req: Phttpd_req): Tesp_err;
var
  buf: PChar;
  buf_len: uint32;
begin
  buf_len := httpd_req_get_hdr_value_len(req, 'Host') + 1;
  if (buf_len > 1) then
  begin
    buf := pvPortMalloc(buf_len);
    if (httpd_req_get_hdr_value_str(req, 'Host', buf, buf_len) = ESP_OK) then
      writeln('Found header => Host: ', buf);
    vPortFree(buf);
  end;

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
  connectWifiAP(AP_NAME, PWD);
  writeln('Starting web server...');
  start_webserver;

  repeat
    vTaskDelay(10);
  until false;
end.
