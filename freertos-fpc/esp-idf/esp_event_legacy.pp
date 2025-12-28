unit esp_event_legacy;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_wifi_types, esp_netif_types, esp_event_base, portmacro;

type
  Psystem_event_id = ^Tsystem_event_id;
  Tsystem_event_id = (SYSTEM_EVENT_WIFI_READY = 0, SYSTEM_EVENT_SCAN_DONE,
    SYSTEM_EVENT_STA_START, SYSTEM_EVENT_STA_STOP,
    SYSTEM_EVENT_STA_CONNECTED, SYSTEM_EVENT_STA_DISCONNECTED,
    SYSTEM_EVENT_STA_AUTHMODE_CHANGE, SYSTEM_EVENT_STA_GOT_IP,
    SYSTEM_EVENT_STA_LOST_IP, SYSTEM_EVENT_STA_WPS_ER_SUCCESS,
    SYSTEM_EVENT_STA_WPS_ER_FAILED, SYSTEM_EVENT_STA_WPS_ER_TIMEOUT,
    SYSTEM_EVENT_STA_WPS_ER_PIN, SYSTEM_EVENT_STA_WPS_ER_PBC_OVERLAP,
    SYSTEM_EVENT_AP_START, SYSTEM_EVENT_AP_STOP,
    SYSTEM_EVENT_AP_STACONNECTED, SYSTEM_EVENT_AP_STADISCONNECTED,
    SYSTEM_EVENT_AP_STAIPASSIGNED, SYSTEM_EVENT_AP_PROBEREQRECVED,
    SYSTEM_EVENT_GOT_IP6, SYSTEM_EVENT_ETH_START,
    SYSTEM_EVENT_ETH_STOP, SYSTEM_EVENT_ETH_CONNECTED,
    SYSTEM_EVENT_ETH_DISCONNECTED, SYSTEM_EVENT_ETH_GOT_IP,
    SYSTEM_EVENT_MAX);

{$ifndef SYSTEM_EVENT_AP_STA_GOT_IP6}
const
  SYSTEM_EVENT_AP_STA_GOT_IP6 = SYSTEM_EVENT_GOT_IP6;
{$endif}

type
  Psystem_event_sta_wps_fail_reason = ^Tsystem_event_sta_wps_fail_reason;
  Tsystem_event_sta_wps_fail_reason = Twifi_event_sta_wps_fail_reason;

  Psystem_event_sta_scan_done = ^Tsystem_event_sta_scan_done;
  Tsystem_event_sta_scan_done = Twifi_event_sta_scan_done;

  Psystem_event_sta_connected = ^Tsystem_event_sta_connected;
  Tsystem_event_sta_connected = Twifi_event_sta_connected;

  Psystem_event_sta_disconnected = ^Tsystem_event_sta_disconnected;
  Tsystem_event_sta_disconnected = Twifi_event_sta_disconnected;

  Psystem_event_sta_authmode_change = ^Tsystem_event_sta_authmode_change;
  Tsystem_event_sta_authmode_change = Twifi_event_sta_authmode_change;

  Psystem_event_sta_wps_er_pin = ^Tsystem_event_sta_wps_er_pin;
  Tsystem_event_sta_wps_er_pin = Twifi_event_sta_wps_er_pin;

  Psystem_event_ap_staconnected = ^Tsystem_event_ap_staconnected;
  Tsystem_event_ap_staconnected = Twifi_event_ap_staconnected;

  Psystem_event_ap_stadisconnected = ^Tsystem_event_ap_stadisconnected;
  Tsystem_event_ap_stadisconnected = Twifi_event_ap_stadisconnected;

  Psystem_event_ap_probe_req_rx = ^Tsystem_event_ap_probe_req_rx;
  Tsystem_event_ap_probe_req_rx = Twifi_event_ap_probe_req_rx;

  Psystem_event_ap_staipassigned = ^Tsystem_event_ap_staipassigned;
  Tsystem_event_ap_staipassigned = Tip_event_ap_staipassigned;

  Psystem_event_sta_got_ip = ^Tsystem_event_sta_got_ip;
  Tsystem_event_sta_got_ip = Tip_event_got_ip;

  Psystem_event_got_ip6 = ^Tsystem_event_got_ip6;
  Tsystem_event_got_ip6 = Tip_event_got_ip6;

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

  Tsystem_event_handler = function(event_base: Tesp_event_base;
    event_id: int32; event_data: pointer; event_data_size: Tsize;
    ticks_to_wait: TTickType): Tesp_err;

function esp_event_send_internal(event_base: Tesp_event_base;
  event_id: int32; event_data: pointer; event_data_size: Tsize;
  ticks_to_wait: TTickType): Tesp_err; external;

procedure esp_event_set_default_eth_handlers; external;

type
  Tsystem_event_cb = function(ctx: pointer; event: Psystem_event): Tesp_err;

// Deprecated:
// esp_err_t esp_event_send(system_event_t *event) __attribute__ ((deprecated));
// esp_err_t esp_event_process_default(system_event_t *event) __attribute__ ((deprecated));
// void esp_event_set_default_wifi_handlers(void) __attribute__ ((deprecated));
// esp_err_t esp_event_loop_init(system_event_cb_t cb, void *ctx) __attribute__ ((deprecated));
// system_event_cb_t esp_event_loop_set_cb(system_event_cb_t cb, void *ctx) __attribute__ ((deprecated));

implementation

end.
