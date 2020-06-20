unit esp_wifi_types;

{$inline on}
{$modeswitch advancedrecords}

interface

uses
  esp_interface, eagle_soc;

type
  Pwifi_ps_type = ^Twifi_ps_type;
  Twifi_ps_type = (WIFI_PS_NONE, WIFI_PS_MIN_MODEM, WIFI_PS_MAX_MODEM);

const
  WIFI_IF_STA = ESP_IF_WIFI_STA;
  WIFI_IF_AP = ESP_IF_WIFI_AP;
  WIFI_PROMIS_FILTER_MASK_ALL = $FFFFFFFF;
  WIFI_PROMIS_FILTER_MASK_MGMT = 1;
  WIFI_PROMIS_FILTER_MASK_CTRL = 1 shl 1;
  WIFI_PROMIS_FILTER_MASK_DATA = 1 shl 2;
  WIFI_PROMIS_FILTER_MASK_MISC = 1 shl 3;
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
  WIFI_EVENT_MASK_ALL               = $FFFFFFFF;
  WIFI_EVENT_MASK_NONE              = 0;
  WIFI_EVENT_MASK_AP_PROBEREQRECVED = BIT0;

  WIFI_PS_MODEM = WIFI_PS_MIN_MODEM;
  ESP_WIFI_MAX_CONN_NUM = 10;
  WIFI_VENDOR_IE_ELEMENT_ID = $DD;

type
  Pwifi_interface = ^Twifi_interface;
  Twifi_interface = Tesp_interface;

  Pwifi_mode = ^Twifi_mode;
  Twifi_mode = (WIFI_MODE_NULL = 0, WIFI_MODE_STA, WIFI_MODE_AP,
    WIFI_MODE_APSTA, WIFI_MODE_MAX);

  Pwifi_country_policy_t = ^Twifi_country_policy;
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
    WIFI_AUTH_WPA2_ENTERPRISE, WIFI_AUTH_MAX);

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
    WIFI_REASON_BEACON_TIMEOUT = 200, WIFI_REASON_NO_AP_FOUND = 201,
    WIFI_REASON_AUTH_FAIL = 202, WIFI_REASON_ASSOC_FAIL = 203,
    WIFI_REASON_HANDSHAKE_TIMEOUT = 204, WIFI_REASON_BASIC_RATE_NOT_SUPPORT = 205);

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
    WIFI_CIPHER_TYPE_UNKNOWN);

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
    reserved: array[0..2] of byte;//0..$FFFFFF;
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

  Pwifi_fast_scan_threshold = ^Twifi_fast_scan_threshold;
  Twifi_fast_scan_threshold = record
    rssi: int8;
    authmode: Twifi_auth_mode;
  end;

  Pwifi_state = ^Twifi_state;
  Twifi_state = (WIFI_STATE_DEINIT = 0, WIFI_STATE_INIT,
    WIFI_STATE_START);

  Pesp_pm_config_esp8266 = ^Tesp_pm_config_esp8266;
  Tesp_pm_config_esp8266 = record
    max_freq_mhz: longint;
    min_freq_mhz: longint;
    light_sleep_enable: longbool;
  end;

  Pwifi_bandwidth = ^Twifi_bandwidth;
  Twifi_bandwidth = (WIFI_BW_HT20 = 1, WIFI_BW_HT40);

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
    threshold: Twifi_fast_scan_threshold;
  end;

  Pwifi_config = ^Twifi_config;
  Twifi_config = record
    case longint of
      0: (ap: Twifi_ap_config);
      1: (sta: Twifi_sta_config);
  end;

  Pwifi_sta_info = ^Twifi_sta_info;
  Twifi_sta_info = record
  private
    function Getphy_11b: TBitRange1; inline;
    function Getphy_11g: TBitRange1; inline;
    function Getphy_11n: TBitRange1; inline;
    function Getphy_lr: TBitRange1; inline;
    procedure Setphy_11b(const avalue: TBitRange1); inline;
    procedure Setphy_11g(const avalue: TBitRange1); inline;
    procedure Setphy_11n(const avalue: TBitRange1); inline;
    procedure Setphy_lr(const avalue: TBitRange1); inline;
  public
    mac: array[0..5] of byte;
    _phy_: byte;
    reserved: array[0..2] of byte;
    property phy_11b: TBitRange1 read Getphy_11b write Setphy_11b;
    property phy_11g: TBitRange1 read Getphy_11g write Setphy_11g;
    property phy_11n: TBitRange1 read Getphy_11n write Setphy_11n;
    property phy_lr: TBitRange1 read Getphy_lr write Setphy_lr;
  end;

  Pwifi_sta_list = ^Twifi_sta_list;
  Twifi_sta_list = record
    sta: array[0..(ESP_WIFI_MAX_CONN_NUM) - 1] of Twifi_sta_info;
    num: longint;
  end;

  Pwifi_storage = ^Twifi_storage;
  Twifi_storage = (WIFI_STORAGE_FLASH, WIFI_STORAGE_RAM);

  Pwifi_vendor_ie_type = ^Twifi_vendor_ie_type;
  Twifi_vendor_ie_type = (WIFI_VND_IE_TYPE_BEACON, WIFI_VND_IE_TYPE_PROBE_REQ,
    WIFI_VND_IE_TYPE_PROBE_RESP, WIFI_VND_IE_TYPE_ASSOC_REQ,
    WIFI_VND_IE_TYPE_ASSOC_RESP);

  Pwifi_vendor_ie_id = ^Twifi_vendor_ie_id;
  Twifi_vendor_ie_id = (WIFI_VND_IE_ID_0, WIFI_VND_IE_ID_1);

  Pvendor_ie_data = ^Tvendor_ie_data;
  Tvendor_ie_data = record
    element_id: byte;
    length: byte;
    vendor_oui: array[0..2] of byte;
    vendor_oui_type: byte;
    payload: array[0..0] of byte;
  end;

  Pwifi_pkt_rx_ctrl = ^Twifi_pkt_rx_ctrl;
  Twifi_pkt_rx_ctrl = record
    rssi: 0..255;           // 8
    rate: 0..$f;            // 4
    is_group: 0..1;         // 1
    reserved1: 0..1;        // 1
    sig_mode: 0..3;         // 2
    legacy_length: 0..$FFF; // 12
    damatch0: 0..1;         // 1
    damatch1: 0..1;         // 1
    bssidmatch0: 0..1;      // 1
    bssidmatch1: 0..1;      // 1
    mcs: 0..$7F;            // 7
    cwb: 0..1;              // 1
    HT_length: 0..$FFFF;    // 16
    smoothing: 0..1;        // 1
    not_sounding: 0..1;     // 1
    reserved3: 0..1;        // 1
    aggregation: 0..1;      // 1
    stbc: 0..3;             // 2
    fec_coding: 0..1;       // 1
    sgi: 0..1;              // 1
    rxend_state: 0..$FF;    // 8
    ampdu_cnt: 0..$FF;      // 8
    channel: 0..$F;         // 4
    reserved4: 0..$F;       // 4
    noise_floor: 0..$FF;    // 8
  end;                      // 96

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

  Pwifi_tx_result = ^Twifi_tx_result;
  Twifi_tx_result = (TX_STATUS_SUCCESS = 1, TX_STATUS_SRC_EXCEED,
    TX_STATUS_LRC_EXCEED, TX_STATUS_DISCARD);

  Pwifi_tx_rate = ^Twifi_tx_rate;
  Twifi_tx_rate = (PHY_RATE_1_LONG, PHY_RATE_2_LONG, PHY_RATE_5_LONG,
    PHY_RATE_11_LONG, PHY_RATE_RESERVED, PHY_RATE_2_SHORT,
    PHY_RATE_5_SHORT, PHY_RATE_11_SHORT, PHY_RATE_48,
    PHY_RATE_24, PHY_RATE_12, PHY_RATE_6, PHY_RATE_54,
    PHY_RATE_36, PHY_RATE_18, PHY_RATE_9);

  Pwifi_tx_status = ^Twifi_tx_status;
  Twifi_tx_status = record
    wifi_tx_result: 0..$FF;  // 8
    wifi_tx_src: 0..$3F;     // 6
    wifi_tx_lrc: 0..$3F;     // 6
    wifi_tx_rate: 0..$FF;    // 8
    unused: 0..$F;           // 4
  end;

implementation

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

end.
