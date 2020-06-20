unit esp_wifi;

{$include freertosconfig.inc}

interface

uses
  esp_err, esp_wifi_types, esp_event;

type
  TMac = array[0..5] of byte;

const
  ESP_ERR_WIFI_NOT_INIT = ESP_ERR_WIFI_BASE + 1;
  ESP_ERR_WIFI_NOT_STARTED = ESP_ERR_WIFI_BASE + 2;
  ESP_ERR_WIFI_NOT_STOPPED = ESP_ERR_WIFI_BASE + 3;
  ESP_ERR_WIFI_IF = ESP_ERR_WIFI_BASE + 4;
  ESP_ERR_WIFI_MODE = ESP_ERR_WIFI_BASE + 5;
  ESP_ERR_WIFI_STATE = ESP_ERR_WIFI_BASE + 6;
  ESP_ERR_WIFI_CONN = ESP_ERR_WIFI_BASE + 7;
  ESP_ERR_WIFI_NVS = ESP_ERR_WIFI_BASE + 8;
  ESP_ERR_WIFI_MAC = ESP_ERR_WIFI_BASE + 9;
  ESP_ERR_WIFI_SSID = ESP_ERR_WIFI_BASE + 10;
  ESP_ERR_WIFI_PASSWORD = ESP_ERR_WIFI_BASE + 11;
  ESP_ERR_WIFI_TIMEOUT = ESP_ERR_WIFI_BASE + 12;
  ESP_ERR_WIFI_WAKE_FAIL = ESP_ERR_WIFI_BASE + 13;
  ESP_ERR_WIFI_WOULD_BLOCK = ESP_ERR_WIFI_BASE + 14;
  ESP_ERR_WIFI_NOT_CONNECT = ESP_ERR_WIFI_BASE + 15;
  ESP_ERR_WIFI_PM_MODE_OPEN = ESP_ERR_WIFI_BASE + 18;
  ESP_ERR_WIFI_FPM_MODE = ESP_ERR_WIFI_BASE + 19;
  ESP_WIFI_PARAM_USE_NVS = 0;
  {$if defined(CONFIG_ESP8266_WIFI_AMPDU_RX_ENABLED) and (CONFIG_ESP8266_WIFI_AMPDU_RX_ENABLED = 1)}
    WIFI_AMPDU_RX_ENABLED = 1;
    WIFI_AMPDU_RX_BA_WIN = CONFIG_ESP8266_WIFI_RX_BA_WIN_SIZE;
    WIFI_RX_MAX_SINGLE_PKT_LEN = 1600;
  {$else}
    WIFI_AMPDU_RX_ENABLED = 0;
    WIFI_AMPDU_RX_BA_WIN = 0;
    WIFI_RX_MAX_SINGLE_PKT_LEN = 1600 - 524;
  {$endif}
  WIFI_AMPDU_RX_AMPDU_BUF_LEN = 256;
  WIFI_AMPDU_RX_AMPDU_BUF_NUM = 5;
  WIFI_HW_RX_BUFFER_LEN = 524;
  {$if defined(CONFIG_ESP8266_WIFI_QOS_ENABLED) and (CONFIG_ESP8266_WIFI_QOS_ENABLED = 1)}
    WIFI_QOS_ENABLED = 1;
  {$else}
    WIFI_QOS_ENABLED = 0;
  {$endif}
  {$if defined(CONFIG_ESP8266_WIFI_AMSDU_ENABLED) and (CONFIG_ESP8266_WIFI_AMSDU_ENABLED = 1)}
    WIFI_AMSDU_RX_ENABLED = 1;
  {$undef WIFI_RX_MAX_SINGLE_PKT_LEN}
    WIFI_RX_MAX_SINGLE_PKT_LEN = 3000;
  {$else}
    WIFI_AMSDU_RX_ENABLED = 0;
  {$endif}
  {$if defined(CONFIG_ESP8266_WIFI_NVS_ENABLED) and (CONFIG_ESP8266_WIFI_NVS_ENABLED = 1)}
    WIFI_NVS_ENABLED = 1;
  {$else}
    WIFI_NVS_ENABLED = 0;
  {$endif}
  WIFI_INIT_CONFIG_MAGIC = $1F2F3F4F;

type
  Pwifi_init_config = ^Twifi_init_config;
  Twifi_init_config = record
    event_handler: Tsystem_event_handler;
    osi_funcs: pointer;
    qos_enable: byte;
    ampdu_rx_enable: byte;
    rx_ba_win: byte;
    rx_ampdu_buf_num: byte;
    rx_ampdu_buf_len: uint32;
    rx_max_single_pkt_len: uint32;
    rx_buf_len: uint32;
    amsdu_rx_enable: byte;
    rx_buf_num: byte;
    rx_pkt_num: byte;
    left_continuous_rx_buf_num: byte;
    tx_buf_num: byte;
    nvs_enable: byte;
    nano_enable: byte;
    magic: uint32;
  end;

  Twifi_promiscuous_cb = procedure(buf: pointer;
    _type: Twifi_promiscuous_pkt_type);

  Tesp_vendor_ie_cb = procedure(ctx: pointer; _type: Twifi_vendor_ie_type;
    sa: TMac; vnd_ie: Pvendor_ie_data_t; rssi: longint);

procedure WIFI_INIT_CONFIG_DEFAULT(out cfg: Twifi_init_config);

function esp_wifi_init(config: Pwifi_init_config): Tesp_err; external;
function esp_wifi_deinit: Tesp_err; external;
function esp_wifi_set_mode(mode: Twifi_mode): Tesp_err; external;
function esp_wifi_get_mode(mode: Pwifi_mode): Tesp_err; external;
function esp_wifi_start: Tesp_err; external;
function esp_wifi_stop: Tesp_err; external;
function esp_wifi_restore: Tesp_err; external;
function esp_wifi_connect: Tesp_err; external;
function esp_wifi_disconnect: Tesp_err; external;
function esp_wifi_clear_fast_connect: Tesp_err; external;
function esp_wifi_deauth_sta(aid: uint16): Tesp_err; external;
function esp_wifi_scan_start(config: Pwifi_scan_config;
  block: longbool): Tesp_err; external;
function esp_wifi_scan_stop: Tesp_err; external;
function esp_wifi_scan_get_ap_num(number: Puint16): Tesp_err; external;
function esp_wifi_scan_get_ap_records(number: Puint16;
  ap_records: Pwifi_ap_record): Tesp_err; external;
function esp_wifi_sta_get_ap_info(ap_info: Pwifi_ap_record): Tesp_err; external;
function esp_wifi_set_ps(_type: Twifi_ps_type): Tesp_err; external;
function esp_wifi_get_ps(_type: Pwifi_ps_type): Tesp_err; external;
function esp_wifi_set_protocol(ifx: Twifi_interface;
  protocol_bitmap: byte): Tesp_err; external;
function esp_wifi_get_protocol(ifx: Twifi_interface;
  protocol_bitmap: PByte): Tesp_err; external;
function esp_wifi_set_bandwidth(ifx: Twifi_interface;
  bw: Twifi_bandwidth): Tesp_err; external;
function esp_wifi_get_bandwidth(ifx: Twifi_interface;
  bw: Pwifi_bandwidth): Tesp_err; external;
function esp_wifi_set_channel(primary: byte; second: Twifi_second_chan): Tesp_err;
  external;
function esp_wifi_get_channel(primary: PByte; second: Pwifi_second_chan): Tesp_err;
  external;
function esp_wifi_set_country(country: Pwifi_country): Tesp_err; external;
function esp_wifi_get_country(country: Pwifi_country): Tesp_err; external;
function esp_wifi_set_mac(ifx: Twifi_interface; mac: TMac): Tesp_err; external;
function esp_wifi_get_mac(ifx: Twifi_interface; mac: TMac): Tesp_err; external;
function esp_wifi_set_promiscuous_rx_cb(cb: Twifi_promiscuous_cb): Tesp_err;
  external;
function esp_wifi_set_promiscuous(en: longbool): Tesp_err; external;
function esp_wifi_get_promiscuous(en: Plongbool): Tesp_err; external;
function esp_wifi_set_promiscuous_filter(filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_get_promiscuous_filter(filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_set_config(ainterface: Twifi_interface;
  conf: Pwifi_config): Tesp_err; external;
function esp_wifi_set_promiscuous_ctrl_filter(
  filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_get_promiscuous_ctrl_filter(
  filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_get_config(ainterface: Twifi_interface;
  conf: Pwifi_config): Tesp_err; external;
function esp_wifi_ap_get_sta_list(sta: Pwifi_sta_list): Tesp_err; external;
function esp_wifi_set_storage(storage: Twifi_storage): Tesp_err; external;
function esp_wifi_set_vendor_ie(enable: longbool; _type: Twifi_vendor_ie_type;
  idx: Twifi_vendor_ie_id; vnd_ie: pointer): Tesp_err; external;
function esp_wifi_set_vendor_ie_cb(cb: Tesp_vendor_ie_cb;
  ctx: pointer): Tesp_err; external;
function esp_wifi_set_max_tx_power(power: int8): Tesp_err; external;
procedure esp_wifi_set_max_tx_power_via_vdd33(vdd33: uint16); external;
function esp_wifi_get_vdd33: uint16; external;
function esp_wifi_get_max_tx_power(power: pbyte): Tesp_err; external;
function esp_wifi_set_event_mask(mask: uint32): Tesp_err; external;
function esp_wifi_get_event_mask(mask: Puint32): Tesp_err; external;
function esp_wifi_80211_tx(ifx: Twifi_interface; buffer: pointer;
  len: longint; en_sys_seq: longbool): Tesp_err; external;
function esp_wifi_get_state: Twifi_state; external;

implementation

procedure WIFI_INIT_CONFIG_DEFAULT(out cfg: Twifi_init_config);
begin
  with cfg do
  begin
    event_handler := @esp_event_send;
    osi_funcs := nil;
    qos_enable := WIFI_QOS_ENABLED;
    ampdu_rx_enable := WIFI_AMPDU_RX_ENABLED;
    rx_ba_win := WIFI_AMPDU_RX_BA_WIN;
    rx_ampdu_buf_num := WIFI_AMPDU_RX_AMPDU_BUF_NUM;
    rx_ampdu_buf_len := WIFI_AMPDU_RX_AMPDU_BUF_LEN;
    rx_max_single_pkt_len := WIFI_RX_MAX_SINGLE_PKT_LEN;
    rx_buf_len := WIFI_HW_RX_BUFFER_LEN;
    amsdu_rx_enable := WIFI_AMSDU_RX_ENABLED;
    rx_buf_num := CONFIG_ESP8266_WIFI_RX_BUFFER_NUM;
    rx_pkt_num := CONFIG_ESP8266_WIFI_RX_PKT_NUM;
    left_continuous_rx_buf_num := CONFIG_ESP8266_WIFI_LEFT_CONTINUOUS_RX_BUFFER_NUM;
    tx_buf_num := CONFIG_ESP8266_WIFI_TX_PKT_NUM;
    nvs_enable := WIFI_NVS_ENABLED;
    nano_enable := 0;
    magic := WIFI_INIT_CONFIG_MAGIC;
  end;
end;

end.
