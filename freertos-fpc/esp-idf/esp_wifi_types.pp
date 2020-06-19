unit esp_wifi_types;

{$include sdkconfig.inc}
{$inline on}
{$modeswitch advancedrecords}

interface

uses
  esp_bit_defs, esp_interface, esp_event_base;

const
  WIFI_IF_STA = ESP_IF_WIFI_STA;
  WIFI_IF_AP = ESP_IF_WIFI_AP;
  WIFI_PROMIS_FILTER_MASK_ALL = $FFFFFFFF;
  WIFI_PROMIS_FILTER_MASK_MGMT = 1;
  WIFI_PROMIS_FILTER_MASK_CTRL = 1 shl 1;
  WIFI_PROMIS_FILTER_MASK_DATA = 1 shl 2;
  WIFI_PROMIS_FILTER_MASK_MISC = 1 shl 3;
  WIFI_PROMIS_FILTER_MASK_DATA_MPDU = 1 shl 4;
  WIFI_PROMIS_FILTER_MASK_DATA_AMPDU = 1 shl 5;
  WIFI_PROMIS_CTRL_FILTER_MASK_ALL = $FF800000;
  WIFI_PROMIS_CTRL_FILTER_MASK_WRAPPER = 1 shl 23;
  WIFI_PROMIS_CTRL_FILTER_MASK_BAR = 1 shl 24;
  WIFI_PROMIS_CTRL_FILTER_MASK_BA = 1 shl 25;
  WIFI_PROMIS_CTRL_FILTER_MASK_PSPOLL = 1 shl 26;
  WIFI_PROMIS_CTRL_FILTER_MASK_RTS = 1 shl 27;
  WIFI_PROMIS_CTRL_FILTER_MASK_CTS = 1 shl 28;
  WIFI_PROMIS_CTRL_FILTER_MASK_ACK = 1 shl 29;
  WIFI_PROMIS_CTRL_FILTER_MASK_CFEND = 1 shl 30;
  WIFI_PROMIS_CTRL_FILTER_MASK_CFENDACK = 1 shl 31;
  WIFI_PROTOCOL_11B = 1;
  WIFI_PROTOCOL_11G = 2;
  WIFI_PROTOCOL_11N = 4;
  WIFI_PROTOCOL_LR = 8;
  WIFI_EVENT_MASK_ALL = $FFFFFFFF;
  WIFI_EVENT_MASK_NONE = 0;
  WIFI_EVENT_MASK_AP_PROBEREQRECVED = BIT0;

type
  Pint8_t = ^int8;

  Pwifi_mode = ^Twifi_mode;
  Twifi_mode = (WIFI_MODE_NULL = 0, WIFI_MODE_STA, WIFI_MODE_AP,
    WIFI_MODE_APSTA, WIFI_MODE_MAX);

  Pwifi_interface = ^Twifi_interface;
  Twifi_interface = Tesp_interface;

  Pwifi_country_policy = ^Twifi_country_policy;
  Twifi_country_policy = (WIFI_COUNTRY_POLICY_AUTO, WIFI_COUNTRY_POLICY_MANUAL);

  Pwifi_country = ^Twifi_country;
  Twifi_country = record
    cc: array[0..2] of char;
    schan: byte;
    nchan: byte;
    max_tx_power: int8;
    policy: Twifi_country_policy;
  end;

  Pwifi_auth_mode = ^Twifi_auth_mode;
  Twifi_auth_mode = (WIFI_AUTH_OPEN = 0, WIFI_AUTH_WEP, WIFI_AUTH_WPA_PSK,
    WIFI_AUTH_WPA2_PSK, WIFI_AUTH_WPA_WPA2_PSK,
    WIFI_AUTH_WPA2_ENTERPRISE, WIFI_AUTH_WPA3_PSK,
    WIFI_AUTH_MAX);

  Pwifi_err_reason = ^Twifi_err_reason;
  Twifi_err_reason = (WIFI_REASON_UNSPECIFIED = 1, WIFI_REASON_AUTH_EXPIRE = 2,
    WIFI_REASON_AUTH_LEAVE = 3, WIFI_REASON_ASSOC_EXPIRE = 4,
    WIFI_REASON_ASSOC_TOOMANY = 5, WIFI_REASON_NOT_AUTHED = 6,
    WIFI_REASON_NOT_ASSOCED = 7, WIFI_REASON_ASSOC_LEAVE = 8,
    WIFI_REASON_ASSOC_NOT_AUTHED = 9, WIFI_REASON_DISASSOC_PWRCAP_BAD = 10,
    WIFI_REASON_DISASSOC_SUPCHAN_BAD = 11,
    WIFI_REASON_IE_INVALID = 13, WIFI_REASON_MIC_FAILURE = 14,
    WIFI_REASON_4WAY_HANDSHAKE_TIMEOUT = 15,
    WIFI_REASON_GROUP_KEY_UPDATE_TIMEOUT = 16,
    WIFI_REASON_IE_IN_4WAY_DIFFERS = 17, WIFI_REASON_GROUP_CIPHER_INVALID = 18,
    WIFI_REASON_PAIRWISE_CIPHER_INVALID = 19,
    WIFI_REASON_AKMP_INVALID = 20, WIFI_REASON_UNSUPP_RSN_IE_VERSION = 21,
    WIFI_REASON_INVALID_RSN_IE_CAP = 22, WIFI_REASON_802_1X_AUTH_FAILED = 23,
    WIFI_REASON_CIPHER_SUITE_REJECTED = 24,
    WIFI_REASON_INVALID_PMKID = 53, WIFI_REASON_BEACON_TIMEOUT = 200,
    WIFI_REASON_NO_AP_FOUND = 201, WIFI_REASON_AUTH_FAIL = 202,
    WIFI_REASON_ASSOC_FAIL = 203, WIFI_REASON_HANDSHAKE_TIMEOUT = 204,
    WIFI_REASON_CONNECTION_FAIL = 205);

  Pwifi_second_chan = ^Twifi_second_chan;
  Twifi_second_chan = (WIFI_SECOND_CHAN_NONE = 0, WIFI_SECOND_CHAN_ABOVE,
    WIFI_SECOND_CHAN_BELOW);

  Pwifi_scan_type = ^Twifi_scan_type;
  Twifi_scan_type = (WIFI_SCAN_TYPE_ACTIVE = 0, WIFI_SCAN_TYPE_PASSIVE);

  Pwifi_active_scan_time = ^Twifi_active_scan_time;
  Twifi_active_scan_time = record
    min: uint32;
    max: uint32;
  end;

  Pwifi_scan_time = ^Twifi_scan_time;
  Twifi_scan_time = record
    case longint of
      0: (active: Twifi_active_scan_time);
      1: (passive: uint32);
  end;

  Pwifi_scan_config = ^Twifi_scan_config;
  Twifi_scan_config = record
    ssid: PByte;
    bssid: PByte;
    channel: byte;
    show_hidden: longbool;
    scan_type: Twifi_scan_type;
    scan_time: Twifi_scan_time;
  end;

  Pwifi_cipher_type = ^Twifi_cipher_type;
  Twifi_cipher_type = (WIFI_CIPHER_TYPE_NONE = 0, WIFI_CIPHER_TYPE_WEP40,
    WIFI_CIPHER_TYPE_WEP104, WIFI_CIPHER_TYPE_TKIP,
    WIFI_CIPHER_TYPE_CCMP, WIFI_CIPHER_TYPE_TKIP_CCMP,
    WIFI_CIPHER_TYPE_AES_CMAC128, WIFI_CIPHER_TYPE_UNKNOWN);

  Pwifi_ant = ^Twifi_ant;
  Twifi_ant = (WIFI_ANT_ANT0, WIFI_ANT_ANT1, WIFI_ANT_MAX);

  TBitRange1 = 0..1;
  TBitRange2 = 0..3;
  TBitRange3 = 0..7;
  TBitRange4 = 0..15;
  TBitRange5 = 0..31;
  TBitRange6 = 0..63;
  TBitRange7 = 0..127;
  TBitRange8 = 0..255;
  Pwifi_ap_record = ^Twifi_ap_record;

  { Twifi_ap_record }
  Twifi_ap_record = record
  private
    function Getphy_11b: TBitRange1; inline;
    function Getphy_11g: TBitRange1; inline;
    function Getphy_11n: TBitRange1; inline;
    function Getphy_lr: TBitRange1; inline;
    function Getwps: TBitRange1; inline;
    procedure Setphy_11b(const avalue: TBitRange1); inline;
    procedure Setphy_11g(const avalue: TBitRange1); inline;
    procedure Setphy_11n(const avalue: TBitRange1); inline;
    procedure Setphy_lr(const avalue: TBitRange1); inline;
    procedure Setwps(const avalue: TBitRange1); inline;
  public
    bssid: array[0..5] of byte;
    ssid: array[0..32] of byte;
    primary: byte;
    second: Twifi_second_chan;
    rssi: int8;
    authmode: Twifi_auth_mode;
    pairwise_cipher: Twifi_cipher_type;
    group_cipher: Twifi_cipher_type;
    ant: Twifi_ant;
    _phy_: byte;
    reserved: array[0..2] of byte;
    country: Twifi_country;
    property phy_11b: TBitRange1 read Getphy_11b write Setphy_11b;
    property phy_11g: TBitRange1 read Getphy_11g write Setphy_11g;
    property phy_11n: TBitRange1 read Getphy_11n write Setphy_11n;
    property phy_lr: TBitRange1 read Getphy_lr write Setphy_lr;
    property wps: TBitRange1 read Getwps write Setwps;
  end;

  Pwifi_scan_method = ^Twifi_scan_method;
  Twifi_scan_method = (WIFI_FAST_SCAN = 0, WIFI_ALL_CHANNEL_SCAN);

  Pwifi_sort_method = ^Twifi_sort_method;
  Twifi_sort_method = (WIFI_CONNECT_AP_BY_SIGNAL = 0, WIFI_CONNECT_AP_BY_SECURITY);

  Pwifi_scan_threshold = ^Twifi_scan_threshold;
  Twifi_scan_threshold = record
    rssi: int8;
    authmode: Twifi_auth_mode;
  end;

  Pwifi_ps_type = ^Twifi_ps_type;
  Twifi_ps_type = (WIFI_PS_NONE, WIFI_PS_MIN_MODEM, WIFI_PS_MAX_MODEM);

  Pwifi_bandwidth = ^Twifi_bandwidth;
  Twifi_bandwidth = (WIFI_BW_HT20 = 1, WIFI_BW_HT40);

  Pwifi_pmf_config = ^Twifi_pmf_config;
  Twifi_pmf_config = record
    capable: longbool;
    required: longbool;
  end;

  Pwifi_ap_config = ^Twifi_ap_config;
  Twifi_ap_config = record
    ssid: array[0..31] of byte;
    password: array[0..63] of byte;
    ssid_len: byte;
    channel: byte;
    authmode: Twifi_auth_mode;
    ssid_hidden: byte;
    max_connection: byte;
    beacon_interval: uint16;
  end;

  Pwifi_sta_config = ^Twifi_sta_config;
  Twifi_sta_config = record
    ssid: array[0..31] of byte;
    password: array[0..63] of byte;
    scan_method: Twifi_scan_method;
    bssid_set: longbool;
    bssid: array[0..5] of byte;
    channel: byte;
    listen_interval: uint16;
    sort_method: Twifi_sort_method;
    threshold: Twifi_scan_threshold;
    pmf_cfg: Twifi_pmf_config;
  end;

  Pwifi_config = ^Twifi_config;
  Twifi_config = record
    case longint of
      0: (ap: Twifi_ap_config);
      1: (sta: Twifi_sta_config);
  end;

  Pwifi_sta_info = ^Twifi_sta_info;
  { Twifi_sta_info }
  Twifi_sta_info = record
  private
    function Getphy_11b: TBitRange1; inline;
    function Getphy_11g: TBitRange1; inline;
    function Getphy_11n: TBitRange1; inline;
    function Getphy_lr: TBitRange1; inline;
    function Getwps: TBitRange1; inline;
    procedure Setphy_11b(const avalue: TBitRange1); inline;
    procedure Setphy_11g(const avalue: TBitRange1); inline;
    procedure Setphy_11n(const avalue: TBitRange1); inline;
    procedure Setphy_lr(const avalue: TBitRange1); inline;
    procedure Setwps(const avalue: TBitRange1); inline;
  public
    mac: array[0..5] of byte;
    rssi: int8;
    _phy_: byte;
    reserved: array[0..2] of byte;
    property phy_11b: TBitRange1 read Getphy_11b write Setphy_11b;
    property phy_11g: TBitRange1 read Getphy_11g write Setphy_11g;
    property phy_11n: TBitRange1 read Getphy_11n write Setphy_11n;
    property phy_lr: TBitRange1 read Getphy_lr write Setphy_lr;
    property wps: TBitRange1 read Getwps write Setwps;
  end;

const
  ESP_WIFI_MAX_CONN_NUM = 10;

type
  Pwifi_sta_list = ^Twifi_sta_list;
  Twifi_sta_list = record
    sta: array[0..(ESP_WIFI_MAX_CONN_NUM) - 1] of Twifi_sta_info;
    num: int32;
  end;

  Pwifi_storage = ^Twifi_storage;
  Twifi_storage = (WIFI_STORAGE_FLASH, WIFI_STORAGE_RAM);

  Pwifi_vendor_ie_type = ^Twifi_vendor_ie_type;
  Twifi_vendor_ie_type = (WIFI_VND_IE_TYPE_BEACON, WIFI_VND_IE_TYPE_PROBE_REQ,
    WIFI_VND_IE_TYPE_PROBE_RESP, WIFI_VND_IE_TYPE_ASSOC_REQ,
    WIFI_VND_IE_TYPE_ASSOC_RESP);

  Pwifi_vendor_ie_id = ^Twifi_vendor_ie_id;
  Twifi_vendor_ie_id = (WIFI_VND_IE_ID_0, WIFI_VND_IE_ID_1);

const
  WIFI_VENDOR_IE_ELEMENT_ID = $DD;

type
  Pvendor_ie_data = ^Tvendor_ie_data;
  Tvendor_ie_data = record
    element_id: byte;
    length: byte;
    vendor_oui: array[0..2] of byte;
    vendor_oui_type: byte;
    payload: array[0..0] of byte;
  end;

  Twifi_pkt_rx_ctrl = bitpacked record
    rssi: 0..255;           // 8 bit // signed
    rate: 0..$1f;           // 5
    reserved1: 0..1;        // 1
    sig_mode: 0..3;         // 2
    reserved2: 0..$FFFF;    // 16
    mcs: 0..127;            // 7
    cwb: 0..1;              // 1
    reserved3: 0 ..$FFFF;   // 16
    smoothing: 0..1;        // 1
    not_sounding: 0..1;     // 1
    reserved4: 0..1;        // 1
    aggregation: 0..1;      // 1
    stbc: 0..3;             // 2
    fec_coding: 0..1;       // 1
    sgi: 0..1;              // 1
    {$ifdef CONFIG_IDF_TARGET_ESP32}
    noise_floor: 0..255;    // 8
    {$else}//$elif CONFIG_IDF_TARGET_ESP32S2BETA}
    reserved5: 0..255;     // 8
    {$endif}
    ampdu_cnt: 0..255;     // 8
    channel: 0..15;        // 4
    secondary_channel: 0..15; // 4
    reserved6: 0..255;     // 8
    timestamp: 0..$FFFFFFFF; // 32
    reserved7: 0..$FFFFFFFF; // 32
    reserved8: 0..$7FFFFFFF; // 31
    ant: 0..1;               // 1
    {$ifdef CONFIG_IDF_TARGET_ESP32S2BETA}
    noise_floor: 0..255;     // 8
    reserved9: 0..$00FFFFFF; // 24
    {$endif}
    sig_len: 0..$0FFF;       // 12
    reserved10: 0..$0FFF;    // 12
    rx_state: 0..255;        // 8
  end;
  Pwifi_pkt_rx_ctrl = ^Twifi_pkt_rx_ctrl;

  Pwifi_promiscuous_pkt = ^Twifi_promiscuous_pkt;
  Twifi_promiscuous_pkt = record
    rx_ctrl: Twifi_pkt_rx_ctrl;
    payload: array[0..0] of byte;
  end;

  Pwifi_promiscuous_pkt_type = ^Twifi_promiscuous_pkt_type;
  Twifi_promiscuous_pkt_type = (WIFI_PKT_MGMT, WIFI_PKT_CTRL, WIFI_PKT_DATA,
    WIFI_PKT_MISC);

  Pwifi_promiscuous_filter = ^Twifi_promiscuous_filter;
  Twifi_promiscuous_filter = record
    filter_mask: uint32;
  end;

  Pwifi_csi_config = ^Twifi_csi_config;
  Twifi_csi_config = record
    lltf_en: longbool;
    htltf_en: longbool;
    stbc_htltf2_en: longbool;
    ltf_merge_en: longbool;
    channel_filter_en: longbool;
    manu_scale: longbool;
    shift: byte;
  end;

  Pwifi_csi_info = ^Twifi_csi_info;
  Twifi_csi_info = record
    rx_ctrl: Twifi_pkt_rx_ctrl;
    mac: array[0..5] of byte;
    first_word_invalid: longbool;
    buf: Pint8_t;
    len: uint16;
  end;

  Pwifi_ant_gpio = ^Twifi_ant_gpio;
  Twifi_ant_gpio = bitpacked record
    gpio_select: 0..1;
    gpio_num: 0..127;
  end;

  Pwifi_ant_gpio_config = ^Twifi_ant_gpio_config;
  Twifi_ant_gpio_config = record
    gpio_cfg: array[0..3] of Twifi_ant_gpio;
  end;

  Pwifi_ant_mode = ^Twifi_ant_mode;
  Twifi_ant_mode = (WIFI_ANT_MODE_ANT0, WIFI_ANT_MODE_ANT1, WIFI_ANT_MODE_AUTO,
    WIFI_ANT_MODE_MAX);

  Pwifi_ant_config = ^Twifi_ant_config;
  { Twifi_ant_config }
  Twifi_ant_config = record
  private
    function GetAnt0: TBitRange4;
    function GetAnt1: TBitRange4;
    procedure SetAnt0(AValue: TBitRange4);
    procedure SetAnt1(AValue: TBitRange4);
  public
    rx_ant_mode: Twifi_ant_mode;
    rx_ant_default: Twifi_ant;
    tx_ant_mode: Twifi_ant_mode;
    _enable: byte;
    property enable_ant0: TBitRange4 read GetAnt0 write SetAnt0;
    property enable_ant1: TBitRange4 read GetAnt1 write SetAnt1;
  end;

  Pwifi_phy_rate = ^Twifi_phy_rate;
  Twifi_phy_rate = (WIFI_PHY_RATE_1M_L = $00, WIFI_PHY_RATE_2M_L = $01,
    WIFI_PHY_RATE_5M_L = $02, WIFI_PHY_RATE_11M_L = $03,
    WIFI_PHY_RATE_2M_S = $05, WIFI_PHY_RATE_5M_S = $06,
    WIFI_PHY_RATE_11M_S = $07, WIFI_PHY_RATE_48M = $08,
    WIFI_PHY_RATE_24M = $09, WIFI_PHY_RATE_12M = $0A,
    WIFI_PHY_RATE_6M = $0B, WIFI_PHY_RATE_54M = $0C,
    WIFI_PHY_RATE_36M = $0D, WIFI_PHY_RATE_18M = $0E,
    WIFI_PHY_RATE_9M = $0F, WIFI_PHY_RATE_MCS0_LGI = $10,
    WIFI_PHY_RATE_MCS1_LGI = $11, WIFI_PHY_RATE_MCS2_LGI = $12,
    WIFI_PHY_RATE_MCS3_LGI = $13, WIFI_PHY_RATE_MCS4_LGI = $14,
    WIFI_PHY_RATE_MCS5_LGI = $15, WIFI_PHY_RATE_MCS6_LGI = $16,
    WIFI_PHY_RATE_MCS7_LGI = $17, WIFI_PHY_RATE_MCS0_SGI = $18,
    WIFI_PHY_RATE_MCS1_SGI = $19, WIFI_PHY_RATE_MCS2_SGI = $1A,
    WIFI_PHY_RATE_MCS3_SGI = $1B, WIFI_PHY_RATE_MCS4_SGI = $1C,
    WIFI_PHY_RATE_MCS5_SGI = $1D, WIFI_PHY_RATE_MCS6_SGI = $1E,
    WIFI_PHY_RATE_MCS7_SGI = $1F, WIFI_PHY_RATE_LORA_250K = $29,
    WIFI_PHY_RATE_LORA_500K = $2A, WIFI_PHY_RATE_MAX);

  Pwifi_event = ^Twifi_event;
  Twifi_event = (WIFI_EVENT_WIFI_READY = 0, WIFI_EVENT_SCAN_DONE,
    WIFI_EVENT_STA_START, WIFI_EVENT_STA_STOP,
    WIFI_EVENT_STA_CONNECTED, WIFI_EVENT_STA_DISCONNECTED,
    WIFI_EVENT_STA_AUTHMODE_CHANGE, WIFI_EVENT_STA_WPS_ER_SUCCESS,
    WIFI_EVENT_STA_WPS_ER_FAILED, WIFI_EVENT_STA_WPS_ER_TIMEOUT,
    WIFI_EVENT_STA_WPS_ER_PIN, WIFI_EVENT_STA_WPS_ER_PBC_OVERLAP,
    WIFI_EVENT_AP_START, WIFI_EVENT_AP_STOP,
    WIFI_EVENT_AP_STACONNECTED, WIFI_EVENT_AP_STADISCONNECTED,
    WIFI_EVENT_AP_PROBEREQRECVED, WIFI_EVENT_MAX);

  Pwifi_event_sta_scan_done = ^Twifi_event_sta_scan_done;
  Twifi_event_sta_scan_done = record
    status: uint32;
    number: byte;
    scan_id: byte;
  end;

  Pwifi_event_sta_connected = ^Twifi_event_sta_connected;
  Twifi_event_sta_connected = record
    ssid: array[0..31] of byte;
    ssid_len: byte;
    bssid: array[0..5] of byte;
    channel: byte;
    authmode: Twifi_auth_mode;
  end;

  Pwifi_event_sta_disconnected = ^Twifi_event_sta_disconnected;
  Twifi_event_sta_disconnected = record
    ssid: array[0..31] of byte;
    ssid_len: byte;
    bssid: array[0..5] of byte;
    reason: byte;
  end;

  Pwifi_event_sta_authmode_change = ^Twifi_event_sta_authmode_change;
  Twifi_event_sta_authmode_change = record
    old_mode: Twifi_auth_mode;
    new_mode: Twifi_auth_mode;
  end;

  Pwifi_event_sta_wps_er_pin = ^Twifi_event_sta_wps_er_pin;
  Twifi_event_sta_wps_er_pin = record
    pin_code: array[0..7] of byte;
  end;

  Pwifi_event_sta_wps_fail_reason = ^Twifi_event_sta_wps_fail_reason;
  Twifi_event_sta_wps_fail_reason = (WPS_FAIL_REASON_NORMAL =
    0, WPS_FAIL_REASON_RECV_M2D,
    WPS_FAIL_REASON_MAX);

  Pwifi_event_ap_staconnected = ^Twifi_event_ap_staconnected;
  Twifi_event_ap_staconnected = record
    mac: array[0..5] of byte;
    aid: byte;
  end;

  Pwifi_event_ap_stadisconnected = ^Twifi_event_ap_stadisconnected;
  Twifi_event_ap_stadisconnected = record
    mac: array[0..5] of byte;
    aid: byte;
  end;

  Pwifi_event_ap_probe_req_rx = ^Twifi_event_ap_probe_req_rx;
  Twifi_event_ap_probe_req_rx = record
    rssi: int32;
    mac: array[0..5] of byte;
  end;

var
  WIFI_EVENT: Tesp_event_base; cvar; external;

implementation

{ Twifi_ant_config }

function Twifi_ant_config.GetAnt0: TBitRange4;
begin
  GetAnt0 := _enable and 15;
end;

function Twifi_ant_config.GetAnt1: TBitRange4;
begin
  GetAnt1 := (_enable shr 4) and 15;
end;

procedure Twifi_ant_config.SetAnt0(AValue: TBitRange4);
begin
  _enable := (_enable and $F0) or AValue;
end;

procedure Twifi_ant_config.SetAnt1(AValue: TBitRange4);
begin
  _enable := (_enable and $0F) or (AValue shl 4);
end;

{ Twifi_sta_info }

function Twifi_sta_info.Getphy_11b: TBitRange1;
begin
  Getphy_11b := _phy_ and 1;
end;

function Twifi_sta_info.Getphy_11g: TBitRange1;
begin
  Getphy_11g := (_phy_ and 2) shr 1;
end;

function Twifi_sta_info.Getphy_11n: TBitRange1;
begin
  Getphy_11n := (_phy_ and 4) shr 2;
end;

function Twifi_sta_info.Getphy_lr: TBitRange1;
begin
  Getphy_lr := (_phy_ and 8) shr 3;
end;

function Twifi_sta_info.Getwps: TBitRange1;
begin
  Getwps := (_phy_ and 16) shr 4;
end;

procedure Twifi_sta_info.Setphy_11b(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FE) or (avalue shl 0);
end;

procedure Twifi_sta_info.Setphy_11g(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FD) or (avalue shl 1);
end;

procedure Twifi_sta_info.Setphy_11n(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FB) or (avalue shl 2);
end;

procedure Twifi_sta_info.Setphy_lr(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $F7) or (avalue shl 3);
end;

procedure Twifi_sta_info.Setwps(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $EF) or (avalue shl 4);
end;

{ Twifi_ap_record }

function Twifi_ap_record.Getphy_11b: TBitRange1;
begin
  Getphy_11b := _phy_ and 1;
end;

function Twifi_ap_record.Getphy_11g: TBitRange1;
begin
  Getphy_11g := (_phy_ and 2) shr 1;
end;

function Twifi_ap_record.Getphy_11n: TBitRange1;
begin
  Getphy_11n := (_phy_ and 4) shr 2;
end;

function Twifi_ap_record.Getphy_lr: TBitRange1;
begin
  Getphy_lr := (_phy_ and 8) shr 3;
end;

function Twifi_ap_record.Getwps: TBitRange1;
begin
  Getwps := (_phy_ and 16) shr 4;
end;

procedure Twifi_ap_record.Setphy_11b(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FE) or (avalue shl 0);
end;

procedure Twifi_ap_record.Setphy_11g(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FD) or (avalue shl 1);
end;

procedure Twifi_ap_record.Setphy_11n(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $FB) or (avalue shl 2);
end;

procedure Twifi_ap_record.Setphy_lr(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $F7) or (avalue shl 3);
end;

procedure Twifi_ap_record.Setwps(const avalue: TBitRange1);
begin
  _phy_ := (_phy_ and $EF) or (avalue shl 4);
end;

end.
