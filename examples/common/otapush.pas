unit otapush;

interface

uses
  esp_http_server, esp_err;

var
  // Global flag to indicate upload in progress
  // can be used to skip time consuming actions to free up capacity for http handling
  busyWithUpload: boolean = false;

// Display form with file select option to initiate upload
function uploadGetHandler(req: Phttpd_req): Tesp_err;
// Receive post with file to upload
function uploadPostHandler(req: Phttpd_req): Tesp_err;

implementation

uses
  esp_ota_ops, esp_partition, task, portmacro, esp_system;

const
  uploadForm =
    '<html><head><title>Upload file</title></head>'#13#10 +
    '<script>'#13#10 +
    'var xhr = new XMLHttpRequest();'#13#10 +
    'function uploadProgress(event) {'#13#10 +
    ' if (event.lengthComputable) {'#13#10 +
    '  var pctComplete = Math.round(event.loaded / event.total * 100);'#13#10 +
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
    '<p id="feedback">Click [Browse...] to select a file, then click [Upload] to start uploading process</p>'#13#10 +
    '</body></html>';

function uploadGetHandler(req: Phttpd_req): Tesp_err;
begin
  httpd_resp_send(req, uploadForm, length(uploadForm));
  result := ESP_OK;
end;

// The upload handler can also be tested using curl:
// curl -X POST -H 'Content-Type: application/octet-stream' -H 'Content-Disposition: attachment' -T ~/filename.txt -v --trace-ascii - 192.168.1.215/upload
function uploadPostHandler(req: Phttpd_req): Tesp_err;
const
  errMsg = 'Error uploading file';
  successMsg = 'Successfully uploaded file';
var
  buf: array[0..255] of char;
  recv: int32;
  totalRecv: uint32;
  err: Tesp_err;
  imageMagicOK: boolean;

  update_handle: Tesp_ota_handle = 0;
  update_partition: Pesp_partition = nil;
begin
  writeln('Received upload post');
  busyWithUpload := true;
  result := ESP_OK;
  if req^.content_len = 0 then
  begin
    writeln('Empty content in upload');
    exit;
  end;
  totalRecv := 0;
  imageMagicOK := false;
  while (totalRecv < uint32(req^.content_len)) do
  begin
    FillChar(buf, length(buf), #0);
    recv := httpd_req_recv(req, @buf[0], length(buf));
    if recv > 0 then
    begin
      totalRecv := totalRecv + uint32(recv);
      // Only check magic byte on first iteration
      if not imageMagicOK then
      begin
        imageMagicOK := buf[0] = #$E9;
        if imageMagicOK then
        begin
          update_partition := esp_ota_get_next_update_partition(nil);
          if (update_partition = nil) then
          begin
            writeln('Passive OTA partition not found');
            err := -1;
            break;
          end;

          err := esp_ota_begin(update_partition, Tsize(OTA_SIZE_UNKNOWN), @update_handle);
          if (err <> ESP_OK) then
          begin
            writeln('esp_ota_begin failed, error=', err);
            err := -1;
            break;
          end;
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
        begin
          writeln('Error not all data received before connection closed');
          err := -1;
        end;
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
        writeln('Restarting...');
        // Try to complete sending response before rebooting
        vTaskDelay(1000 div portTICK_PERIOD_MS);
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

  busyWithUpload := false;
end;

end.

