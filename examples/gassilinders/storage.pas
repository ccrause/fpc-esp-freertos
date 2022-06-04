unit storage;

interface

uses
  nvs, esp_err;

const
  numGasStations = 5;
  numPhoneNumbers = 5;

type
  TPressureSettings = record
    Warnings: array[0..numGasStations-1] of uint32;
    LowPressures: array[0..numGasStations-1] of uint32;
  end;

  TPhoneNumberArray = array[0..numPhoneNumbers-1] of uint32;

  TSMSNotificationFlags = (snWarnPressure, snLowPressure, snAutoCylinderChangeOver, snRepeatNotifications);
  TSMSNotificationsSet = set of TSMSNotificationFlags;
  TSMSNotificationSettings = record
    Notifications:  TSMSNotificationsSet;
    RepeatInterval: uint32;  // hours
  end;

  TCylinderChangeoverSettings = record
    MinCylinderPressure: uint32;
    Hysteresis: uint32;
    CylinderChangeDelay: uint32; // in ticks, note display is in seconds
    PreferredCylinderMode: boolean;
    PreferredCylinderIndex: uint32; // 0 = A, 1 = B
    ManualMode: boolean;
    ManualCylinderSelected: uint32; // 0 = A, 1 = B
  end;

var
  // Used on Nextion for colour coding of cylinder pressures,
  // also used for SMS notification thresholds
  PressureSettings: TPressureSettings;
  // Phone number whitelist to send SMSs to
  PhoneNumbers: TPhoneNumberArray;
  // What items should be reported via SMS notification,
  // also interval for repeat notifications
  SMSNotificationSettings: TSMSNotificationSettings;

  CylinderChangeoverSettings: TCylinderChangeoverSettings;

// If settings haven't been saved before, load defaults
function loadSettings: Tesp_err;
function savePressureSettings: Tesp_err;
function saveNotificationSettings: Tesp_err;
function saveCylinderChangeoverSettings: Tesp_err;

procedure initDefaultSettings;

implementation

uses
  portmacro, nextionscreenconfig, logtouart;

var
  storageHandle: Tnvs_handle;

{$include freertosconfig.inc} // To access configTICK_RATE_HZ

function initNVS: Tesp_err;
begin
  Result := nvs_flash_init();
  if (Result = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6} or (Result = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    logwriteln('Erasing flash');
    EspErrorCheck(nvs_flash_erase());
    Result := nvs_flash_init();
  end;
  EspErrorCheck(Result);

  if Result = ESP_OK then
    Result := nvs_open('storage', NVS_READWRITE, @storageHandle);

  if not(Result = ESP_OK) then
  begin
    storageHandle := 0;
    logwriteln('nvs_open failed');
  end;
end;

procedure initDefaultSettings;
var
  i: integer;
begin
  for i := 0 to numGasStations-1 do
  begin
    PressureSettings.Warnings[i] := 55;
    PressureSettings.LowPressures[i] := 22;
  end;

  PhoneNumbers[0] := 0836282994;
  PhoneNumbers[1] := 0846801221;
  PhoneNumbers[2] := 0;
  PhoneNumbers[3] := 0;
  PhoneNumbers[4] := 0;

  SMSNotificationSettings.Notifications := [{snWarnPressure, snLowPressure,} snAutoCylinderChangeOver];
  SMSNotificationSettings.RepeatInterval := 24;

  CylinderChangeoverSettings.MinCylinderPressure := 20;
  CylinderChangeoverSettings.Hysteresis := 5;
  CylinderChangeoverSettings.CylinderChangeDelay := 2 * configTICK_RATE_HZ;
  CylinderChangeoverSettings.PreferredCylinderMode := false;
  CylinderChangeoverSettings.PreferredCylinderIndex := 0; // 0 = A, 1 = B
  CylinderChangeoverSettings.ManualMode := false;
  CylinderChangeoverSettings.ManualCylinderSelected := 0; // 0 = A, 1 = B

  nextionscreenconfig.doUploadSettingsToDisplay;
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
    sz := SizeOf(PressureSettings);
    err := nvs_get_blob(storageHandle, 'PresSettings', @PressureSettings, @sz);
    if (err <> ESP_OK) or (sz <> SizeOf(PressureSettings)) then
    begin
      logwrite('Error reading pressure settings: ');
      logwriteln(esp_err_to_name(Result));
      Result := ESP_FAIL;
    end;

    sz := SizeOf(PhoneNumbers);
    err := nvs_get_blob(storageHandle, 'PhoneNumbers', @PhoneNumbers, @sz);
    if (err <> ESP_OK) or (sz <> SizeOf(PhoneNumbers)) then
    begin
      Result := ESP_FAIL;
      logwrite('Error reading phone numbers: ');
      logwriteln(esp_err_to_name(Result));
    end;

    sz := SizeOf(SMSNotificationSettings);
    err := nvs_get_blob(storageHandle, 'SMSNotif', @SMSNotificationSettings, @sz);
    if (err <> ESP_OK) or (sz <> SizeOf(SMSNotificationSettings)) then
    begin
      Result := ESP_FAIL;
      logwrite('Error reading SMS notification settings: ');
      logwriteln(esp_err_to_name(Result));
    end;

    sz := SizeOf(CylinderChangeoverSettings);
    err := nvs_get_blob(storageHandle, 'CylChangeover', @CylinderChangeoverSettings, @sz);
    if (err <> ESP_OK) or (sz <> SizeOf(CylinderChangeoverSettings)) then
    begin
      Result := ESP_FAIL;
      logwrite('Error reading cylinder changeover settings: ');
      logwriteln(esp_err_to_name(Result));
    end;

    nvs_close(storageHandle)
  end;
end;

function savePressureSettings: Tesp_err;
begin
  Result := initNVS;

  if Result = ESP_OK then
  begin
    Result := nvs_set_blob(storageHandle, 'PresSettings', @PressureSettings,
                          SizeOf(PressureSettings));
    if Result <> ESP_OK then
    begin
      logwrite('Error saving PressureSettings: ');
      logwriteln(esp_err_to_name(Result));
    end;

    if Result = ESP_OK then
    begin
      Result := nvs_commit(storageHandle);
      if Result = ESP_OK then
        nvs_close(storageHandle);
    end;
  end;
end;

function saveNotificationSettings: Tesp_err;
var
  err: Tesp_err;
begin
  Result := initNVS;

  if Result = ESP_OK then
  begin
    err := nvs_set_blob(storageHandle, 'PhoneNumbers', @PhoneNumbers,
                          SizeOf(PhoneNumbers));
    if err <> ESP_OK then
    begin
      Result := err;
      logwrite('Error saving PhoneNumbers: ');
      logwriteln(esp_err_to_name(err));
    end;

    err := nvs_set_blob(storageHandle, 'SMSNotif', @SMSNotificationSettings,
                             SizeOf(SMSNotificationSettings));
    if err <> ESP_OK then
    begin
      Result := err;
      logwrite('Error saving SMSNotificationSettings: ');
      logwriteln(esp_err_to_name(err));
    end;

    if Result = ESP_OK then
    begin
      Result := nvs_commit(storageHandle);
      if Result = ESP_OK then
        nvs_close(storageHandle);
    end;
  end;
end;

function saveCylinderChangeoverSettings: Tesp_err;
begin
  Result := initNVS;

  if Result = ESP_OK then
  begin
    Result := nvs_set_blob(storageHandle, 'CylChangeover', @CylinderChangeoverSettings,
                           SizeOf(CylinderChangeoverSettings));
    if Result <> ESP_OK then
    begin
      logwrite('Error saving CylinderChangeoverSettings: ');
      logwriteln(esp_err_to_name(Result));
    end;

    if Result = ESP_OK then
    begin
      Result := nvs_commit(storageHandle);
      if Result = ESP_OK then
        nvs_close(storageHandle);
    end;
  end;
end;

end.

