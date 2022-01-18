program simplehttpclient;

{$include freertosconfig.inc}
uses
  freertos,
  wificonnect,
  esp_err, http_parser,
  portable, task, esp_http_client;

{$macro on}
{$inline on}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

function myhttp_event_handler(evt: Pesp_http_client_event): Tesp_err;
var
  i: integer;
begin
  case evt^.event_id of
    HTTP_EVENT_ERROR:        writeln('HTTP_EVENT_ERROR');
    HTTP_EVENT_ON_CONNECTED: writeln('HTTP_EVENT_ON_CONNECTED');
    HTTP_EVENT_HEADER_SENT:  writeln('HTTP_EVENT_HEADER_SENT');
    HTTP_EVENT_ON_HEADER:    writeln('HTTP_EVENT_ON_HEADER = ', evt^.header_key, 'value=', evt^.header_value);
    HTTP_EVENT_ON_DATA:
      begin
        writeln;
        // Just dump data for now
        for i := 0 to evt^.data_len-1 do
          write(pchar(evt^.data)[i]);
      end;
    HTTP_EVENT_ON_FINISH:    writeln(LineEnding, LineEnding, 'HTTP_EVENT_ON_FINISH');
    HTTP_EVENT_DISCONNECTED: writeln('HTTP_EVENT_DISCONNECTED');
  end;
  result := ESP_OK;
end;

var
  config: Tesp_http_client_config;
  client: Tesp_http_client_handle;
  err: Tesp_err;

begin
  connectWifiAP(AP_NAME, PWD);
  writeln('Starting web server...');

  //config.url := 'http://httpbin.org/get';
  config.url := 'http://worldclockapi.com/api/json/utc/now';
  config.event_handler := @myhttp_event_handler;
  client := esp_http_client_init(@config);

  repeat
    // Perform simple GET
    err := esp_http_client_perform(client);
    if (err <> ESP_OK) then
      writeln('HTTP GET request failed: ', esp_err_to_name(err));

    writeln;
    vTaskDelay(10*CONFIG_FREERTOS_HZ);
  until false;
end.
