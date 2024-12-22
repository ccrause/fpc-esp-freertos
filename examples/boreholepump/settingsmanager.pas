unit settingsmanager;

{ This unit manages loading and saving of application settings via NVS }

interface

uses
  nvs, esp_err;

type
  TControllerSettings = packed record
    HLstop,                // high level stop, mm
    LLstart,               // low level start, mm
    restartDelay,          // delay before restart after low flow trip, minutes
    LFstop,                // low flow stop, L/min
    startDeadTime: int32;  // ignore low flow after pump start, s
  end;

var
  settings: TControllerSettings;

function loadSettings: Tesp_err;
function saveSettings: Tesp_err;

implementation

uses
  portmacro;

var
  storageHandle: Tnvs_handle;

function initNVS: Tesp_err;
begin
  Result := nvs_flash_init();
  if (Result = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6} or (Result = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    writeln('Erasing flash');
    EspErrorCheck(nvs_flash_erase());
    Result := nvs_flash_init();
  end;
  EspErrorCheck(Result);

  if Result = ESP_OK then
    Result := nvs_open('storage', NVS_READWRITE, @storageHandle);

  if not(Result = ESP_OK) then
  begin
    storageHandle := 0;
    writeln('nvs_open failed');
  end;
end;

function loadSettings: Tesp_err;
var
  sz: Tsize;
  err: Tesp_err;
begin
  Result := ESP_OK;
  err := initNVS;

  if err = ESP_OK then
  begin
    sz := SizeOf(settings);
    err := nvs_get_blob(storageHandle, 'settings', @settings, @sz);
    if (err <> ESP_OK) or (sz <> SizeOf(settings)) then
    begin
      write('Error reading settings: ');
      writeln(esp_err_to_name(Result));
      Result := ESP_FAIL;
    end;

    nvs_close(storageHandle)
  end;
end;

function saveSettings: Tesp_err;
begin
  Result := initNVS;

  if Result = ESP_OK then
  begin
    Result := nvs_set_blob(storageHandle, 'settings', @settings,
      SizeOf(settings));
    if Result <> ESP_OK then
    begin
      write('Error saving settings: ');
      writeln(esp_err_to_name(Result));
    end;

    if Result = ESP_OK then
    begin
      Result := nvs_commit(storageHandle);
      if Result <> ESP_OK then
      begin
        write('Error commiting settings: ');
        writeln(esp_err_to_name(Result));
      end;

      nvs_close(storageHandle);
    end;
  end;
end;

end.

