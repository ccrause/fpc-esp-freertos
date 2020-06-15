program nvs_test;

uses
  nvs, esp_err;

var
  err: longint;
  my_handle: Tnvs_handle;
  restart_counter: int32 = 0; // value will default to 0, if not set yet in NVS

begin
  err := nvs_flash_init();
  if ((err = ESP_ERR_NVS_NO_FREE_PAGES) or (err = ESP_ERR_NVS_NEW_VERSION_FOUND)) then
  begin
    EspErrorCheck(nvs_flash_erase());
    err := nvs_flash_init();
  end;
  EspErrorCheck(err);

  writeln('Opening Non-Volatile Storage (NVS) handle... ');
  err := nvs_open('storage', NVS_READWRITE, @my_handle);
  if not(err = ESP_OK) then
    writeln('Error opening NVS handle: ', err)
  else
    writeln('Done');

  writeln('Reading restart counter from NVS ... ');
  err := nvs_get_i32(my_handle, 'restart_counter', @restart_counter);
  case err of
    ESP_OK:
      writeln('Restart counter = ', restart_counter);
    ESP_ERR_NVS_NOT_FOUND:
      writeln('The value is not initialized yet!');
    else
      writeln('Error reading NVS: ', err);
  end;

  inc(restart_counter);
  err := nvs_set_i32(my_handle, 'restart_counter', restart_counter);
  if not(err = ESP_OK) then
    writeln('Error writing restart counter: ', esp_err_to_name(err))
  else
  begin
    err := nvs_commit(my_handle);
    if not(err = ESP_OK) then
      writeln('Error writing restart counter: ', esp_err_to_name(err));
    nvs_close(my_handle);
  end;
end.
