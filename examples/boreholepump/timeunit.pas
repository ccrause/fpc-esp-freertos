unit timeunit;

{ This unit is used to initialize SNTP and provide a string timestamp }

interface

uses
  c_time, esp_sntp;

procedure initTime;
procedure currentTimeAsString(out s: shortstring);

implementation

// Procedure called when a new SNTP time value is received
procedure sntpCallback(tv: Ptimeval);
begin
  writeln('sntpCallback received value: ', tv^.tv_sec, ' s');
  settimeofday(tv, nil);
  sntp_set_sync_status(SNTP_SYNC_STATUS_COMPLETED);
end;

procedure initTime;
begin
  //writeln('Setting timezone to GMT-2');
  setenv('TZ', 'GMT-2', 1);
  tzset();

  sntp_set_sync_mode(SNTP_SYNC_MODE_IMMED);  // or SNTP_SYNC_MODE_SMOOTH to make smooth adjustments
  //sntp_set_sync_interval(60000); // set to 60 seconds, default is 1 h
  sntp_setoperatingmode(SNTP_OPMODE_POLL);
  sntp_set_time_sync_notification_cb(@sntpCallback);
  sntp_setservername(0, '0.za.pool.ntp.org');
  sntp_setservername(1, '1.za.pool.ntp.org');
  sntp_setservername(2, '2.za.pool.ntp.org');
  sntp_setservername(3, '3.za.pool.ntp.org');
  sntp_setservername(4, 'pool.ntp.org');
  sntp_init();
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

end.

