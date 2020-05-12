unit esp_event_legacy;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_wifi_types, esp_netif, esp_netif_types, esp_event_base;

type
  TTickType_t = uint32;

  Psystem_event_id_t = ^Tsystem_event_id_t;
  Tsystem_event_id_t = (SYSTEM_EVENT_WIFI_READY = 0, SYSTEM_EVENT_SCAN_DONE,
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
  Psystem_event_sta_wps_fail_reason_t = ^Tsystem_event_sta_wps_fail_reason_t;
  Tsystem_event_sta_wps_fail_reason_t = Twifi_event_sta_wps_fail_reason_t;

  Psystem_event_sta_scan_done_t = ^Tsystem_event_sta_scan_done_t;
  Tsystem_event_sta_scan_done_t = Twifi_event_sta_scan_done_t;

  Psystem_event_sta_connected_t = ^Tsystem_event_sta_connected_t;
  Tsystem_event_sta_connected_t = Twifi_event_sta_connected_t;

  Psystem_event_sta_disconnected_t = ^Tsystem_event_sta_disconnected_t;
  Tsystem_event_sta_disconnected_t = Twifi_event_sta_disconnected_t;

  Psystem_event_sta_authmode_change_t = ^Tsystem_event_sta_authmode_change_t;
  Tsystem_event_sta_authmode_change_t = Twifi_event_sta_authmode_change_t;

  Psystem_event_sta_wps_er_pin_t = ^Tsystem_event_sta_wps_er_pin_t;
  Tsystem_event_sta_wps_er_pin_t = Twifi_event_sta_wps_er_pin_t;

  Psystem_event_ap_staconnected_t = ^Tsystem_event_ap_staconnected_t;
  Tsystem_event_ap_staconnected_t = Twifi_event_ap_staconnected_t;

  Psystem_event_ap_stadisconnected_t = ^Tsystem_event_ap_stadisconnected_t;
  Tsystem_event_ap_stadisconnected_t = Twifi_event_ap_stadisconnected_t;

  Psystem_event_ap_probe_req_rx_t = ^Tsystem_event_ap_probe_req_rx_t;
  Tsystem_event_ap_probe_req_rx_t = Twifi_event_ap_probe_req_rx_t;

  Psystem_event_ap_staipassigned_t = ^Tsystem_event_ap_staipassigned_t;
  Tsystem_event_ap_staipassigned_t = Tip_event_ap_staipassigned_t;

  Psystem_event_sta_got_ip_t = ^Tsystem_event_sta_got_ip_t;
  Tsystem_event_sta_got_ip_t = Tip_event_got_ip_t;

  Psystem_event_got_ip6_t = ^Tsystem_event_got_ip6_t;
  Tsystem_event_got_ip6_t = Tip_event_got_ip6_t;

  Psystem_event_info_t = ^Tsystem_event_info_t;
  Tsystem_event_info_t = record
    case longint of
      0: (connected: Tsystem_event_sta_connected_t);
      1: (disconnected: Tsystem_event_sta_disconnected_t);
      2: (scan_done: Tsystem_event_sta_scan_done_t);
      3: (auth_change: Tsystem_event_sta_authmode_change_t);
      4: (got_ip: Tsystem_event_sta_got_ip_t);
      5: (sta_er_pin: Tsystem_event_sta_wps_er_pin_t);
      6: (sta_er_fail_reason: Tsystem_event_sta_wps_fail_reason_t);
      7: (sta_connected: Tsystem_event_ap_staconnected_t);
      8: (sta_disconnected: Tsystem_event_ap_stadisconnected_t);
      9: (ap_probereqrecved: Tsystem_event_ap_probe_req_rx_t);
      10: (ap_staipassigned: Tsystem_event_ap_staipassigned_t);
      11: (got_ip6: Tsystem_event_got_ip6_t);
  end;

  Psystem_event_t = ^Tsystem_event_t;
  Tsystem_event_t = record
    event_id: Tsystem_event_id_t;
    event_info: Tsystem_event_info_t;
  end;

  Tsystem_event_handler_t = function(event_base: Tesp_event_base_t;
    event_id: int32; event_data: pointer; event_data_size: Tsize_t;
    ticks_to_wait: TTickType_t): Tesp_err_t; cdecl;

function esp_event_send_internal(event_base: Tesp_event_base_t;
  event_id: int32; event_data: pointer; event_data_size: Tsize_t;
  ticks_to_wait: TTickType_t): Tesp_err_t; cdecl; external;

procedure esp_event_set_default_eth_handlers; cdecl; external;

type
  Tsystem_event_cb_t = function(ctx: pointer; event: Psystem_event_t): Tesp_err_t; cdecl;

// Deprecated:
// esp_err_t esp_event_send(system_event_t *event) __attribute__ ((deprecated));
// esp_err_t esp_event_process_default(system_event_t *event) __attribute__ ((deprecated));
// void esp_event_set_default_wifi_handlers(void) __attribute__ ((deprecated));
// esp_err_t esp_event_loop_init(system_event_cb_t cb, void *ctx) __attribute__ ((deprecated));
// system_event_cb_t esp_event_loop_set_cb(system_event_cb_t cb, void *ctx) __attribute__ ((deprecated));

implementation

end.
