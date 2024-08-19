unit esp_wifi;

{$include sdkconfig.inc}

{$linklib esp_wifi, static}
{$linklib net80211, static}

// Needed by other libraries
{$linklib efuse, static}
{$linklib lwip, static}
{$linklib pp, static}
{$if IDF_VERSION < 50000}
  {$linklib coexist, static}
{$linklib tcpip_adapter, static}
{$endif}
{$linklib phy, static}
{$linklib core, static}
{$linklib rtc, static}
{$linklib wpa_supplicant, static}
{$linklib mbedtls, static}
{$linklib mesh, static}

{$if (IDF_VERSION >= 40307)}
  {$if (IDF_VERSION < 40405)}
    // esp-idf 4.3.7, 4.4.1
    {$linklib mbedcrypto, static}
  {$else}
    // esp-idf 4.4.5
    {$linklib tcp_transport, static}
    {$linklib esp-tls, static}
  {$endif}

  {$if (IDF_VERSION >= 40400)}
    {$linklib esp_phy, static}
  {$endif}
{$endif}

interface

uses
  esp_err, esp_bit_defs, esp_event, esp_event_legacy, esp_wifi_types,
  esp_wifi_crypto_types, wifi_os_adapter, portmacro;

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
  ESP_ERR_WIFI_POST = ESP_ERR_WIFI_BASE + 18;
  ESP_ERR_WIFI_INIT_STATE = ESP_ERR_WIFI_BASE + 19;
  ESP_ERR_WIFI_STOP_STATE = ESP_ERR_WIFI_BASE + 20;
  {$if defined(CONFIG_ESP32_WIFI_STATIC_TX_BUFFER_NUM)}
    WIFI_STATIC_TX_BUFFER_NUM = CONFIG_ESP32_WIFI_STATIC_TX_BUFFER_NUM;
  {$else}
    WIFI_STATIC_TX_BUFFER_NUM = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_SPIRAM_SUPPORT) or defined(CONFIG_ESP32S2_SPIRAM_SUPPORT) or defined(CONFIG_ESP32S3_SPIRAM_SUPPORT)}
    WIFI_CACHE_TX_BUFFER_NUM = CONFIG_ESP32_WIFI_CACHE_TX_BUFFER_NUM;
  {$else}
    WIFI_CACHE_TX_BUFFER_NUM = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_DYNAMIC_TX_BUFFER_NUM)}
    WIFI_DYNAMIC_TX_BUFFER_NUM = CONFIG_ESP32_WIFI_DYNAMIC_TX_BUFFER_NUM;
  {$else}
    WIFI_DYNAMIC_TX_BUFFER_NUM = 0;
  {$endif}
  {$if defined(CONFIG_ESP_WIFI_RX_MGMT_BUF_NUM_DEF) and (CONFIG_ESP_WIFI_RX_MGMT_BUF_NUM_DEF > -1)}
    WIFI_RX_MGMT_BUF_NUM_DEF = CONFIG_ESP_WIFI_RX_MGMT_BUF_NUM_DEF;
  {$else}
    WIFI_RX_MGMT_BUF_NUM_DEF = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_CSI_ENABLED) and (CONFIG_ESP32_WIFI_CSI_ENABLED = 1)}
    WIFI_CSI_ENABLED = 1;
  {$else}
    WIFI_CSI_ENABLED = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_AMPDU_RX_ENABLED) and (CONFIG_ESP32_WIFI_AMPDU_RX_ENABLED = 1)}
    WIFI_AMPDU_RX_ENABLED = 1;
  {$else}
    WIFI_AMPDU_RX_ENABLED = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_AMPDU_TX_ENABLED) and (CONFIG_ESP32_WIFI_AMPDU_TX_ENABLED = 1)}
    WIFI_AMPDU_TX_ENABLED = 1;
  {$else}
    WIFI_AMPDU_TX_ENABLED = 0;
  {$endif}
  {$if IDF_VERSION >= 40300}
    {$if defined(CONFIG_ESP_WIFI_AMSDU_TX_ENABLED)}
      {$define WIFI_AMSDU_TX_ENABLED := 1}
    {$else}
      {$define WIFI_AMSDU_TX_ENABLED := 0}
    {$endif}
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_NVS_ENABLED) and (CONFIG_ESP32_WIFI_NVS_ENABLED = 1)}
    WIFI_NVS_ENABLED = 1;
  {$else}
    WIFI_NVS_ENABLED = 0;
  {$endif}
  {$if defined(CONFIG_NEWLIB_NANO_FORMAT) and (CONFIG_NEWLIB_NANO_FORMAT = 1)}
    WIFI_NANO_FORMAT_ENABLED = 1;
  {$else}
    WIFI_NANO_FORMAT_ENABLED = 0;
  {$endif}
  WIFI_INIT_CONFIG_MAGIC = $1F2F3F4F;
  {$if defined(CONFIG_ESP32_WIFI_AMPDU_TX_ENABLED) and (CONFIG_ESP32_WIFI_AMPDU_TX_ENABLED = 1)}
    WIFI_DEFAULT_TX_BA_WIN = CONFIG_ESP32_WIFI_TX_BA_WIN;
  {$else}
    WIFI_DEFAULT_TX_BA_WIN = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_AMPDU_RX_ENABLED) and (CONFIG_ESP32_WIFI_AMPDU_RX_ENABLED = 1)}
    WIFI_DEFAULT_RX_BA_WIN = CONFIG_ESP32_WIFI_RX_BA_WIN;
  {$else}
    WIFI_DEFAULT_RX_BA_WIN = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_TASK_PINNED_TO_CORE_1) and (CONFIG_ESP32_WIFI_TASK_PINNED_TO_CORE_1 = 1)}
    WIFI_TASK_CORE_ID = 1;
  {$else}
    WIFI_TASK_CORE_ID = 0;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_SOFTAP_BEACON_MAX_LEN) and (CONFIG_ESP32_WIFI_SOFTAP_BEACON_MAX_LEN = 1)}
    WIFI_SOFTAP_BEACON_MAX_LEN = CONFIG_ESP32_WIFI_SOFTAP_BEACON_MAX_LEN;
  {$else}
    WIFI_SOFTAP_BEACON_MAX_LEN = 752;
  {$endif}
  {$if defined(CONFIG_ESP32_WIFI_MGMT_SBUF_NUM) and (CONFIG_ESP32_WIFI_MGMT_SBUF_NUM = 1)}
    WIFI_MGMT_SBUF_NUM = CONFIG_ESP32_WIFI_MGMT_SBUF_NUM;
  {$else}
    WIFI_MGMT_SBUF_NUM = 32;
  {$endif}
    CONFIG_FEATURE_WPA3_SAE_BIT = 1 shl 0;

  {$if defined(CONFIG_ESP_WIFI_STA_DISCONNECTED_PM_ENABLE)}
    {$define WIFI_STA_DISCONNECTED_PM_ENABLED := true}
  {$else}
    {$define WIFI_STA_DISCONNECTED_PM_ENABLED := false}
  {$endif}

var
  g_wifi_default_wpa_crypto_funcs: Twpa_crypto_funcs; cvar; external;
  g_wifi_feature_caps: uint64; cvar; external;

type
  TMac = array[0..5] of byte;
  Pint8 = ^int8;

  Pwifi_init_config = ^Twifi_init_config;
  Twifi_init_config = record
    {$if IDF_VERSION < 50000}
    event_handler: Tsystem_event_handler;
    {$endif}
    osi_funcs: Pwifi_osi_funcs;
    wpa_crypto_funcs: Twpa_crypto_funcs;
    static_rx_buf_num: int32;
    dynamic_rx_buf_num: int32;
    tx_buf_type: int32;
    static_tx_buf_num: int32;
    dynamic_tx_buf_num: int32;
    {$if IDF_VERSION >= 40307}
    rx_mgmt_buf_type: uint32;
    rx_mgmt_buf_num: uint32;
    {$endif}
    {$if IDF_VERSION >= 40200}
    cache_tx_buf_num: int32;
    {$endif}
    csi_enable: int32;
    ampdu_rx_enable: int32;
    ampdu_tx_enable: int32;
    {$if IDF_VERSION >= 40300}
    amsdu_tx_enable: int32;
    {$endif}
    nvs_enable: int32;
    nano_enable: int32;
    {$if IDF_VERSION < 40200}
    tx_ba_win: int32;
    {$endif}
    rx_ba_win: int32;
    wifi_task_core_id_ : int32; // Disambiguate from name of constant
    beacon_max_len: int32;
    mgmt_sbuf_num: int32;
    feature_caps: uint64;
    {$if IDF_VERSION >= 40209}
    sta_disconnected_pm: boolean;
    {$endif}
    {$if IDF_VERSION >= 40404}
    espnow_max_encrypt_num: int32;
    {$endif}
    magic: int32;
  end;

  Twifi_promiscuous_cb = procedure(buf: pointer;
    _type: Twifi_promiscuous_pkt_type);

  Tesp_vendor_ie_cb = procedure(ctx: pointer; _type: Twifi_vendor_ie_type;
    sa: TMac; vnd_ie: Pvendor_ie_data; rssi: int32);

  Twifi_csi_cb = procedure(ctx: pointer; Data: Pwifi_csi_info);

procedure WIFI_INIT_CONFIG_DEFAULT(var data: Twifi_init_config);

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
function esp_wifi_get_promiscuous(en: Pbool): Tesp_err; external;
function esp_wifi_set_promiscuous_filter(filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_get_promiscuous_filter(filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_set_promiscuous_ctrl_filter(
  filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_get_promiscuous_ctrl_filter(
  filter: Pwifi_promiscuous_filter): Tesp_err;
  external;
function esp_wifi_set_config(interface_: Twifi_interface;
  conf: Pwifi_config): Tesp_err; external;
function esp_wifi_get_config(interface_: Twifi_interface;
  conf: Pwifi_config): Tesp_err; external;
function esp_wifi_ap_get_sta_list(sta: Pwifi_sta_list): Tesp_err; external;
function esp_wifi_set_storage(storage: Twifi_storage): Tesp_err; external;
function esp_wifi_set_vendor_ie(enable: longbool; _type: Twifi_vendor_ie_type;
  idx: Twifi_vendor_ie_id; vnd_ie: pointer): Tesp_err; external;
function esp_wifi_set_vendor_ie_cb(cb: Tesp_vendor_ie_cb;
  ctx: pointer): Tesp_err; external;
function esp_wifi_set_max_tx_power(power: int8): Tesp_err; external;
function esp_wifi_get_max_tx_power(power: Pint8): Tesp_err; external;
function esp_wifi_set_event_mask(mask: uint32): Tesp_err; external;
function esp_wifi_get_event_mask(mask: Puint32): Tesp_err; external;
function esp_wifi_80211_tx(ifx: Twifi_interface; buffer: pointer;
  len: int32; en_sys_seq: longbool): Tesp_err; external;
function esp_wifi_set_csi_rx_cb(cb: Twifi_csi_cb; ctx: pointer): Tesp_err;
  external;
function esp_wifi_set_csi_config(config: Pwifi_csi_config): Tesp_err; external;
function esp_wifi_set_csi(en: longbool): Tesp_err; external;
function esp_wifi_set_ant_gpio(config: Pwifi_ant_gpio_config): Tesp_err; external;
function esp_wifi_get_ant_gpio(config: Pwifi_ant_gpio_config): Tesp_err; external;
function esp_wifi_set_ant(config: Pwifi_ant_config): Tesp_err; external;
function esp_wifi_get_ant(config: Pwifi_ant_config): Tesp_err; external;

implementation

procedure WIFI_INIT_CONFIG_DEFAULT(var data: Twifi_init_config);
begin
  with data do
  begin
    {$if IDF_VERSION < 50000}
    event_handler := @esp_event_send_internal;
    {$endif}
    osi_funcs := @g_wifi_osi_funcs;

    wpa_crypto_funcs := g_wifi_default_wpa_crypto_funcs;
    static_rx_buf_num := CONFIG_ESP32_WIFI_STATIC_RX_BUFFER_NUM;
    dynamic_rx_buf_num := CONFIG_ESP32_WIFI_DYNAMIC_RX_BUFFER_NUM;
    tx_buf_type := CONFIG_ESP32_WIFI_TX_BUFFER_TYPE;
    static_tx_buf_num := WIFI_STATIC_TX_BUFFER_NUM;
    dynamic_tx_buf_num := WIFI_DYNAMIC_TX_BUFFER_NUM;
    {$if IDF_VERSION >= 40307}
    rx_mgmt_buf_type := CONFIG_ESP_WIFI_DYNAMIC_RX_MGMT_BUF;
    rx_mgmt_buf_num := WIFI_RX_MGMT_BUF_NUM_DEF;
    {$endif}
    {$if IDF_VERSION >= 40200}
    cache_tx_buf_num :=  WIFI_CACHE_TX_BUFFER_NUM;
    {$endif}
    csi_enable := WIFI_CSI_ENABLED;
    ampdu_rx_enable := WIFI_AMPDU_RX_ENABLED;
    ampdu_tx_enable := WIFI_AMPDU_TX_ENABLED;
    {$if IDF_VERSION >= 40300}
    amsdu_tx_enable := WIFI_AMSDU_TX_ENABLED;
    {$endif}
    nvs_enable := WIFI_NVS_ENABLED;
    nano_enable := WIFI_NANO_FORMAT_ENABLED;
    {$if IDF_VERSION < 40200}
    tx_ba_win := WIFI_DEFAULT_TX_BA_WIN;
    {$endif}
    rx_ba_win := WIFI_DEFAULT_RX_BA_WIN;
    wifi_task_core_id_ := WIFI_TASK_CORE_ID;
    beacon_max_len := WIFI_SOFTAP_BEACON_MAX_LEN;
    mgmt_sbuf_num := WIFI_MGMT_SBUF_NUM;
    feature_caps := g_wifi_feature_caps;
    {$if IDF_VERSION >= 40300}
    sta_disconnected_pm := WIFI_STA_DISCONNECTED_PM_ENABLED;
    {$endif}
    {$if IDF_VERSION >= 40404}
    espnow_max_encrypt_num := CONFIG_ESP_WIFI_ESPNOW_MAX_ENCRYPT_NUM;
    {$endif}
    magic := WIFI_INIT_CONFIG_MAGIC;
  end;
end;

end.
