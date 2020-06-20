unit esp_event;

interface

uses
  esp_wifi_types, tcpip_adapter, ip_addr, ip4_addr,
  esp_err;

{$ifndef SYSTEM_EVENT_AP_STA_GOT_IP6}
const
  SYSTEM_EVENT_AP_STA_GOT_IP6 = SYSTEM_EVENT_GOT_IP6;
{$endif}

type
  Psystem_event_id = ^Tsystem_event_id;
  Tsystem_event_id = (SYSTEM_EVENT_WIFI_READY = 0, SYSTEM_EVENT_SCAN_DONE,
    SYSTEM_EVENT_STA_START, SYSTEM_EVENT_STA_STOP,
    SYSTEM_EVENT_STA_CONNECTED, SYSTEM_EVENT_STA_DISCONNECTED,
    SYSTEM_EVENT_STA_AUTHMODE_CHANGE, SYSTEM_EVENT_STA_GOT_IP,
    SYSTEM_EVENT_STA_LOST_IP, SYSTEM_EVENT_STA_WPS_ER_SUCCESS,
    SYSTEM_EVENT_STA_WPS_ER_FAILED, SYSTEM_EVENT_STA_WPS_ER_TIMEOUT,
    SYSTEM_EVENT_STA_WPS_ER_PIN, SYSTEM_EVENT_AP_START,
    SYSTEM_EVENT_AP_STOP, SYSTEM_EVENT_AP_STACONNECTED,
    SYSTEM_EVENT_AP_STADISCONNECTED, SYSTEM_EVENT_AP_STAIPASSIGNED,
    SYSTEM_EVENT_AP_PROBEREQRECVED, SYSTEM_EVENT_GOT_IP6,
    SYSTEM_EVENT_ETH_START, SYSTEM_EVENT_ETH_STOP,
    SYSTEM_EVENT_ETH_CONNECTED, SYSTEM_EVENT_ETH_DISCONNECTED,
    SYSTEM_EVENT_ETH_GOT_IP, SYSTEM_EVENT_MAX);

  Psystem_event_sta_wps_fail_reason = ^Tsystem_event_sta_wps_fail_reason;
  Tsystem_event_sta_wps_fail_reason = (WPS_FAIL_REASON_NORMAL =
    0, WPS_FAIL_REASON_RECV_M2D,
    WPS_FAIL_REASON_MAX);

  Psystem_event_sta_scan_done = ^Tsystem_event_sta_scan_done;
  Tsystem_event_sta_scan_done = record
    status: uint32;
    number: byte;
    scan_id: byte;
  end;

  Psystem_event_sta_connected = ^Tsystem_event_sta_connected;
  Tsystem_event_sta_connected = record
    ssid: array[0..31] of byte;
    ssid_len: byte;
    bssid: array[0..5] of byte;
    channel: byte;
    authmode: Twifi_auth_mode;
  end;

  Psystem_event_sta_disconnected = ^Tsystem_event_sta_disconnected;
  Tsystem_event_sta_disconnected = record
    ssid: array[0..31] of byte;
    ssid_len: byte;
    bssid: array[0..5] of byte;
    reason: byte;
  end;

  Psystem_event_sta_authmode_change = ^Tsystem_event_sta_authmode_change;
  Tsystem_event_sta_authmode_change = record
    old_mode: Twifi_auth_mode;
    new_mode: Twifi_auth_mode;
  end;

  Psystem_event_sta_got_ip = ^Tsystem_event_sta_got_ip;
  Tsystem_event_sta_got_ip = record
    ip_info: Ttcpip_adapter_ip_info;
    ip_changed: longbool;
  end;

  Psystem_event_sta_wps_er_pin = ^Tsystem_event_sta_wps_er_pin;
  Tsystem_event_sta_wps_er_pin = record
    pin_code: array[0..7] of byte;
  end;

  Psystem_event_got_ip6 = ^Tsystem_event_got_ip6;
  Tsystem_event_got_ip6 = record
    if_index: Ttcpip_adapter_if;
    ip6_info: Ttcpip_adapter_ip6_info;
  end;

  Psystem_event_ap_staconnected = ^Tsystem_event_ap_staconnected;
  Tsystem_event_ap_staconnected = record
    mac: array[0..5] of byte;
    aid: byte;
  end;

  Psystem_event_ap_stadisconnected = ^Tsystem_event_ap_stadisconnected;
  Tsystem_event_ap_stadisconnected = record
    mac: array[0..5] of byte;
    aid: byte;
  end;

  Psystem_event_ap_probe_req_rx = ^Tsystem_event_ap_probe_req_rx;
  Tsystem_event_ap_probe_req_rx = record
    rssi: longint;
    mac: array[0..5] of byte;
  end;

  Psystem_event_ap_staipassigned = ^Tsystem_event_ap_staipassigned;
  Tsystem_event_ap_staipassigned = record
    ip: Tip4_addr;
  end;

  Psystem_event_info = ^Tsystem_event_info;
  Tsystem_event_info = record
    case longint of
      0: (connected: Tsystem_event_sta_connected);
      1: (disconnected: Tsystem_event_sta_disconnected);
      2: (scan_done: Tsystem_event_sta_scan_done);
      3: (auth_change: Tsystem_event_sta_authmode_change);
      4: (got_ip: Tsystem_event_sta_got_ip);
      5: (sta_er_pin: Tsystem_event_sta_wps_er_pin);
      6: (sta_er_fail_reason: Tsystem_event_sta_wps_fail_reason);
      7: (sta_connected: Tsystem_event_ap_staconnected);
      8: (sta_disconnected: Tsystem_event_ap_stadisconnected);
      9: (ap_probereqrecved: Tsystem_event_ap_probe_req_rx);
      10: (ap_staipassigned: Tsystem_event_ap_staipassigned);
      11: (got_ip6: Tsystem_event_got_ip6);
  end;

  Psystem_event = ^Tsystem_event;
  Tsystem_event = record
    event_id: Tsystem_event_id;
    event_info: Tsystem_event_info;
  end;

  Tsystem_event_handler = function(event: Psystem_event): Tesp_err;

function esp_event_send(event: Psystem_event): Tesp_err; external;
function esp_event_process_default(event: Psystem_event): Tesp_err; external;
procedure esp_event_set_default_wifi_handlers; external;
function esp_event_loop_create_default: Tesp_err; external;

implementation

end.
