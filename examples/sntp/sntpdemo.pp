program sntpdemo;

{$macro on}
{$inline on}

uses
  task,
  wificonnect, esp_sntp,
  esp_err, portmacro, esp_log,
  rtc_wdt,
  projdefs,
  c_time;

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

procedure sntpCallback(tv: Ptimeval);
begin
  writeln('sntpCallback received value: ', tv^.tv_sec, ' s');
  settimeofday(tv, nil);
  sntp_set_sync_status(SNTP_SYNC_STATUS_COMPLETED);
end;

// Simple formatting procedure because SysUtils.Format() is not available
procedure currentTimeAsString(out s: shortstring);
var
  now: Ttime;
  timeinfo: Ttm;
  tmp: string[8];
begin
  time(@now);
  localtime_r(@now, @timeinfo);

  Str(timeinfo.tm_year + 1900, tmp);
  s := tmp + '/';
  Str(timeinfo.tm_mon + 1, tmp);
  if length(tmp) = 1 then tmp := '0' + tmp;
  s := s + tmp + '/';
  Str(timeinfo.tm_mday, tmp);
  if length(tmp) = 1 then tmp := '0' + tmp;
  s := s + tmp + ' ';
  Str(timeinfo.tm_hour, tmp);
  if length(tmp) = 1 then tmp := '0' + tmp;
  s := s + tmp + ':';
  Str(timeinfo.tm_min, tmp);
  if length(tmp) = 1 then tmp := '0' + tmp;
  s := s + tmp + ':';
  Str(timeinfo.tm_sec, tmp);
  if length(tmp) = 1 then tmp := '0' + tmp;
  s := s + tmp;
end;

var
  sbuf: shortstring;

begin
  rtc_wdt_disable; // In case WDT was initialized by bootloader
  esp_log_level_set('*', ESP_LOG_WARN);

  writeln('Setting timezone to GMT-2');
  setenv('TZ', 'GMT-2', 1);
  tzset();

  writeln('Connecting to wifi AP');
  connectWifiAP(AP_NAME, PWD);

  sntp_set_sync_mode(SNTP_SYNC_MODE_IMMED);  // or SNTP_SYNC_MODE_SMOOTH to make smooth adjustments
  //sntp_set_sync_interval(60000); // set to 60 seconds, default is 1 h
  sntp_setoperatingmode(SNTP_OPMODE_POLL);
  sntp_set_time_sync_notification_cb(@sntpCallback);
  sntp_setservername(0, 'pool.ntp.org');
  sntp_init();

  // Loop runs every 5 second
  repeat
    vTaskDelay(pdMS_TO_TICKS(5000));
    currentTimeAsString(sbuf);
    writeln(sbuf);
  until false;
end.
