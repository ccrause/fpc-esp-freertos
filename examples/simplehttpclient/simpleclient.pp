program simpleclient;

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
begin
  case evt^.event_id of
    HTTP_EVENT_ERROR:        writeln('HTTP_EVENT_ERROR');
    HTTP_EVENT_ON_CONNECTED: writeln('HTTP_EVENT_ON_CONNECTED');
    HTTP_EVENT_HEADER_SENT:  writeln('HTTP_EVENT_HEADER_SENT');
    HTTP_EVENT_ON_HEADER:    writeln('HTTP_EVENT_ON_HEADER, key=', evt^.header_key, 'value=', evt^.header_value);
    HTTP_EVENT_ON_DATA:      writeln('HTTP_EVENT_ON_DATA, len=', evt^.data_len);
    HTTP_EVENT_ON_FINISH:    writeln('HTTP_EVENT_ON_FINISH');
    HTTP_EVENT_DISCONNECTED: writeln('HTTP_EVENT_DISCONNECTED');
  end;
  result := ESP_OK;
end;


var
  config: Tesp_http_client_config;
  client: Tesp_http_client_handle;
  err: Tesp_err;
  buf: array[0..512] of char;
  i: integer;

begin
  connectWifiAP(AP_NAME, PWD);
  writeln('Starting web server...');

  config.url := 'http://httpbin.org/get';
  config.event_handler := @myhttp_event_handler;
  client := esp_http_client_init(@config);

   // Perform simple GET
   err := esp_http_client_perform(client);
   if (err = ESP_OK) then
   begin
     writeln('HTTP GET Status = ',
              esp_http_client_get_status_code(client),
              ', content_length = ',
              esp_http_client_get_content_length(client));
     i := -1;
     while i < 0 do
     begin
       // Not sure this loop works properly if buf is not large enough for the full response
       FillChar(buf[0], length(buf), #0);
       i := esp_http_client_read(client, @buf[0], length(buf)-1);
       if i > 0 then
         write(buf);
       vTaskDelay(10);
     end;
   end
   else
     writeln('HTTP GET request failed: ', esp_err_to_name(err));

  repeat
    vTaskDelay(100);
    writeln(',');
  until false;
end.
