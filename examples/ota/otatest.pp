program otatest;

{$include freertosconfig.inc}
{$include credentials.ignore}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event, esp_ota_ops, esp_partition,
  wificonnect, esp_http_server, http_parser, task, esp_system, portmacro, otapush
  {$ifdef CPULX6}, esp_wifi_default, esp_app_format, nvs {$endif}
  {$ifdef CPULX106}, nvs_flash, esp_event_loop{$endif};

var
  it: Tesp_partition_iterator;
  part: Pesp_partition;
  pt: Tesp_partition_type;
  {$ifdef CPULX6}
  nvs_it: Tnvs_iterator;
  info: Tnvs_entry_info;
  {$endif}
  part_conf, part_running: Pesp_partition;

const
  versionStr = 'V0.d';

  homeScreen = '<html><head><title>Welcome [' + versionStr + ']</title></head>'#13#10 +
    '<body>'#13#10 +
    '<p>Firmware version: ' + versionStr + '</p>'#13#10 +
    '<p>Go to <a href="/upload">upload page</a> to upload new firmware</p>'#13#10 +
    '</body></html>';

function rootGetHandler(req: Phttpd_req): Tesp_err;
begin
  httpd_resp_send(req, homeScreen, length(homeScreen));
  result := ESP_OK;
end;

function start_webserver: Thttpd_handle;
var
  server: Thttpd_handle;
  config: Thttpd_config;
  rootUriHandlerConfig, uploaderGetHandlerConfig,
  uploaderPostHandlerConfig: Thttpd_uri;
begin
  config := HTTPD_DEFAULT_CONFIG();
  with rootUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @rootGetHandler;
    user_ctx  := nil;
  end;

  with uploaderGetHandlerConfig do
  begin
    uri       := '/upload';
    method    := HTTP_GET;
    handler   := @otapush.uploadGetHandler;
    user_ctx  := nil;
  end;

  with uploaderPostHandlerConfig do
  begin
    uri       := '/upload';
    method    := HTTP_POST;
    handler   := @otapush.uploadPostHandler;
    user_ctx  := nil;
  end;

  writeln('Starting server on port: ', config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    writeln('Registering URI handler');
    httpd_register_uri_handler(server, @rootUriHandlerConfig);
    httpd_register_uri_handler(server, @uploaderGetHandlerConfig);
    httpd_register_uri_handler(server, @uploaderPostHandlerConfig);
    result := server;
  end
  else
  begin
    result := nil;
    writeln('### Failed to start httpd');
  end;
end;

begin
  writeln('Version string: ', versionStr);
  writeln;
  createWifiAP('sensor', '');
  //connectWifiAP(AP_NAME, PWD);
  writeln('Starting web server...');
  start_webserver;

  writeln;
  writeln('Listing partitions...');
  for pt := low(Tesp_partition_type) to high(Tesp_partition_type) do
  begin
    writeln('  Partion type: ', pt);
    it := esp_partition_find(pt, ESP_PARTITION_SUBTYPE_ANY, nil);
    while it <> nil do
    begin
      part := esp_partition_get(it);
      writeln('    Found partition "', part^._label, '" at offset $', HexStr(part^.address, 4), ' with size ', part^.size, '. Subtype = ', part^.subtype);
      {$ifdef _CPULX6}
      if (pt = ESP_PARTITION_TYPE_DATA) and (part^.subtype = ESP_PARTITION_SUBTYPE_DATA_NVS) then
      begin
        if nvs_flash_init_partition(part^._label) = ESP_OK then
        begin
          nvs_it := nvs_entry_find(part^._label, nil, NVS_TYPE_ANY);
          if nvs_it <> nil then
            writeln('    Listing NVS name space information:');
          while nvs_it <> nil do
          begin
            nvs_entry_info(nvs_it, @info);
            writeln('      Name space: ', info.namespace_name, ', key: ', info.key, ', type: ', info._type);
            nvs_it := nvs_entry_next(nvs_it);
          end;
        end
        else
          writeln('    Error calling nvs_flash_init');
      end;
      {$endif}
      it := esp_partition_next(it);
    end;
    esp_partition_iterator_release(it);
    writeln;
  end;

  part_conf := esp_ota_get_boot_partition;
  if part_conf <> nil then
  begin
    writeln('Configured to boot from OTA partition at offset: $', HexStr(part_conf^.address, 8), ' [', part_conf^._label, ']');
    part_running := esp_ota_get_running_partition;
    writeln('Running from OTA partition at offset: $', HexStr(part_running^.address, 8), ' [', part_running^._label, ']');
  end
  else
    writeln('OTA partition not found');

  repeat
    vTaskDelay(10 * configTICK_RATE_HZ);
  until false;
end.

// Flash firmware over serial (first time upload)
//  esptool.py -p /dev/ttyUSB0 -b 460800 --before default_reset --after hard_reset --chip auto  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x10000 otatest.bin

//Flash mapping for esp8266 (generate bootloader and partition info by building the OTA example from SDK)
// 0x0000 ~/xtensa/examples/simple-ota-esp8266/build/bootloader/bootloader.bin
// 0xd000 ~/xtensa/examples/simple-ota-esp8266/build/ota_data_initial.bin
// 0x8000 ~/xtensa/examples/simple-ota-esp8266/build/partitions_two_ota.bin
// 0x10000 firmware.bin

// Flash ota partition information and firmaware for esp8266:
// esptool.py -p /dev/ttyUSB0 -b 500000 --chip auto --before default_reset --after hard_reset  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x0000 ~/xtensa/examples/simple-ota-esp8266/build/bootloader/bootloader.bin 0xd000 ~/xtensa/examples/simple-ota-esp8266/build/ota_data_initial.bin 0x8000 ~/xtensa/examples/simple-ota-esp8266/build/partitions_two_ota.bin 0x10000 otatest.bin

// Flash ota partition and firmware for esp32:
// esptool.py --chip auto -p /dev/ttyUSB0 --baud 500000 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 ~/xtensa/examples/simple_ota_example/build/bootloader/bootloader.bin 0xd000 ~/xtensa/examples/simple_ota_example/build/ota_data_initial.bin 0x8000 ~/xtensa/examples/simple_ota_example/build/partitions_two_ota.bin 0x10000 firmware.bin

// Flash mapping:
// 0x1000 ~/xtensa/examples/simple_ota_example/build/bootloader/bootloader.bin
// 0xd000 ~/xtensa/examples/simple_ota_example/build/ota_data_initial.bin
// 0x8000 ~/xtensa/examples/simple_ota_example/build/partitions_two_ota.bin
// 0x10000 firmware.bin

