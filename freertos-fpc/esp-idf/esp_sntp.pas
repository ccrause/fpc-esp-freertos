unit esp_sntp;

interface

uses
  c_time;

type
  Psntp_sync_mode = ^Tsntp_sync_mode;
  Tsntp_sync_mode = (
    SNTP_SYNC_MODE_IMMED,
    SNTP_SYNC_MODE_SMOOTH);

  Psntp_sync_status = ^Tsntp_sync_status;
  Tsntp_sync_status = (
    SNTP_SYNC_STATUS_RESET,
    SNTP_SYNC_STATUS_COMPLETED,
    SNTP_SYNC_STATUS_IN_PROGRESS);

  Tsntp_sync_time_cb = procedure(tv: Ptimeval);

procedure sntp_sync_time(tv: Ptimeval); external;
procedure sntp_set_sync_mode(sync_mode: Tsntp_sync_mode); external;
function sntp_get_sync_mode: Tsntp_sync_mode; external;
function sntp_get_sync_status: Tsntp_sync_status; external;
procedure sntp_set_sync_status(sync_status: Tsntp_sync_status); external;
procedure sntp_set_time_sync_notification_cb(callback: Tsntp_sync_time_cb); external;
procedure sntp_set_sync_interval(interval_ms: uint32); external;
function sntp_get_sync_interval: uint32; external;
function sntp_restart: boolean; external;

// Definitions from lwip/apps/sntp.h
const
  SNTP_OPMODE_POLL       = 0;
  SNTP_OPMODE_LISTENONLY = 1;

procedure sntp_init(); external;
procedure sntp_stop(); external;
procedure sntp_setservername(idx: byte; server: PChar); external;
procedure sntp_setoperatingmode(operating_mode: byte); external;

implementation

end.
