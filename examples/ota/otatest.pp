program otatest;

{$include sdkconfig.inc}
{$include credentials.ignore}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event, esp_ota_ops, esp_partition,
  wificonnect, esp_http_server, http_parser, task, esp_system
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
  versionStr = 'V0.2';
  //uploadForm = '<form action="/upload" method="POST" enctype="multipart/form-data">'#13#10 +
  //  '<input type="file" name="Uploaded file" required="required" accept="application/octet-stream">'#13#10 +
  //  '<button type="submit">Upload</button>'#13#10 +
  //  '</form>';

  uploadForm =
    '<html><head><title>Upload file</title></head>'#13#10 +
    '<script>'#13#10 +
    'var xhr = new XMLHttpRequest();'#13#10 +
    'function uploadProgress(event) {'#13#10 +
    ' if (event.lengthComputable) {'#13#10 +
    '  var pctComplete = event.loaded / event.total * 100;'#13#10 +
    '  document.getElementById("feedback").innerHTML = `Progress: ${pctComplete}%`;'#13#10 +
    ' } else { document.getElementById("feedback").innerHTML = `Progress: ${event.loaded} bytes`};'#13#10 +
    '}'#13#10 +

    'function uploaded() { document.getElementById("feedback").innerHTML = xhr.response; }'#13#10 +

    'function uploadError() { document.getElementById("feedback").innerHTML = "File upload failed"; }'#13#10 +

    'function doUpload() {'#13#10 +
    'var theFile = document.getElementById("filename").files[0];'#13#10 +
    'xhr.open("POST", "/upload", true);'#13#10 +
    'xhr.upload.addEventListener("progress", uploadProgress);'#13#10 +
    'xhr.upload.addEventListener("load", uploaded);'#13#10 +
    'xhr.upload.addEventListener("error", uploadError);'#13#10 +
    'xhr.upload.addEventListener("abort", uploadError);'#13#10 +

    'document.getElementById("feedback").innerHTML = `Starting upload`;'#13#10 +
    'xhr.setRequestHeader("Content-Type", "application/octet-stream");'#13#10 +
    'xhr.setRequestHeader("Content-Disposition", "attachment");'#13#10 +
    'xhr.send(theFile);'#13#10 +
    '};'#13#10 +
    '</script>'#13#10 +
    '<body>'#13#10 +
    '<form id="uploadform" action="/upload" method="POST" enctype="application/octet-stream">'#13#10 +
    '<input type="file" id="filename" required="required">'#13#10 +
    '<input type="button" name="Upload" value="Upload" onClick="doUpload()">'#13#10 +
    '</form>'#13#10 +
    '<p id="feedback">Waiting to upload file</p>'#13#10 +
    '</body></html>';

function root_handler(req: Phttpd_req): Tesp_err;
begin
  httpd_resp_send(req, uploadForm, length(uploadForm));
  result := ESP_OK;
end;

// The upload handler can also be tested using curl:
// curl -X POST -H 'Content-Type: application/octet-stream' -H 'Content-Disposition: attachment' -T ~/filename.txt -v --trace-ascii - 192.168.1.215/upload
function upload_handler(req: Phttpd_req): Tesp_err;
const
  errMsg = 'Error uploading file';
  successMsg = 'Successfully uploaded file';
var
  buf: array[0..255] of char;
  recv: int32;
  totalRecv: uint32;
  err: Tesp_err;
  contentlength: shortstring;
  imageMagicOK: boolean;

  update_handle: Tesp_ota_handle = 0;
  update_partition: Pesp_partition = nil;
begin
  writeln('Received upload post');
  result := ESP_OK;
  recv := httpd_req_get_hdr_value_str(req, 'Content-Length', @contentlength[1], length(contentlength));
  setlength(contentlength, recv);
  //WriteLn('Content length: ', contentlength);
  //writeln('File content:');
  totalRecv := 0;
  imageMagicOK := false;
  while (totalRecv < uint32(req^.content_len)) do
  begin
    FillChar(buf, length(buf), #0);
    recv := httpd_req_recv(req, @buf[0], length(buf));
    if recv > 0 then
    begin
      totalRecv := totalRecv + uint32(recv);
      //writeln('Received data: (', totalRecv, '/', req^.content_len, ')');
      // Only check magic byte on first iteration
      if not imageMagicOK then
      begin
        imageMagicOK := buf[0] = #$E9;
        if imageMagicOK then
        begin
          //writeln('Magic byte OK');
          update_partition := esp_ota_get_next_update_partition(nil);
          if (update_partition = nil) then
          begin
            writeln('Passive OTA partition not found');
            err := -1;
            break;
          end;

          //writeln('Writing to partition subtype ', update_partition^.subtype, ' at offset $', HexStr(update_partition^.address, 8));
          err := esp_ota_begin(update_partition, Tsize(OTA_SIZE_UNKNOWN), @update_handle);
          if (err <> ESP_OK) then
          begin
            writeln('esp_ota_begin failed, error=', err);
            err := -1;
            break;
          end;
          //writeln('esp_ota_begin succeeded');
        end
        else
        begin
          err := -1;
          writeln('Error unexpected image magic byte');
          break;
        end;
      end;
      if (recv > 0) then
      begin
        err := esp_ota_write(update_handle, @buf[0], recv);
        if (err <> ESP_OK) then
        begin
          writeln('esp_ota_write failed: ', err);
          break;
        end;
      end;
    end
    else
    begin
      if recv < 0 then
      begin
        err := recv;
        writeln('Error calling httpd_req_recv: ', uint32(err));
      end
      else
      begin
        // httpd_req_recv can also return 0 if peer closes connection
        // so check if all data has been received
        if totalRecv = uint32(req^.content_len) then
          err := ESP_OK
        else
          err := -1;
      end;
      break;
    end;
    // Upload messaging seems slow, try to yield here to make esp8266 slicing smoother
    vTaskDelay(1);
  end;

  if err = ESP_OK then
  begin
    writeln('Upload done');
    err := esp_ota_end(update_handle);
    if err = ESP_OK then
    begin
      err := esp_ota_set_boot_partition(update_partition);
      if err = ESP_OK then
      begin
        httpd_resp_send(req, successMsg, length(successMsg));
        // Try to complete sending response before rebooting
        writeln('Restarting...');
        vTaskDelay(10);
        esp_restart;
      end
      else
      begin
        writeln('esp_ota_set_boot_partition FAILED');
        httpd_resp_send(req, errMsg, length(errMsg));
      end;
    end
    else
      writeln('esp_ota_end FAILED');
  end
  else
    writeln('Upload FAILED');

  result := ESP_OK;
end;

function start_webserver: Thttpd_handle;
var
  server: Thttpd_handle;
  config: Thttpd_config;
  rootUriHandlerConfig, uploaderHandlerConfig: Thttpd_uri;
begin
  config := HTTPD_DEFAULT_CONFIG();
  with rootUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @root_handler;
    user_ctx  := nil;
  end;

  with uploaderHandlerConfig do
  begin
    uri       := '/upload';
    method    := HTTP_POST;
    handler   := @upload_handler;
    user_ctx  := nil;
  end;

  writeln('Starting server on port: ', config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    writeln('Registering URI handler');
    httpd_register_uri_handler(server, @rootUriHandlerConfig);
    httpd_register_uri_handler(server, @uploaderHandlerConfig);
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
  //createWifiAP('sensor', '');
  connectWifiAP(AP_NAME, PWD);
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
      {$ifdef CPULX6}
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
    vTaskDelay(1);
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

