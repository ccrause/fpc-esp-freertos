unit esp_system;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_bit_defs;

const
  TWO_UNIVERSAL_MAC_ADDR = 2;
  FOUR_UNIVERSAL_MAC_ADDR = 4;
{$ifdef CONFIG_IDF_TARGET_ESP32}
  UNIVERSAL_MAC_ADDR_NUM = CONFIG_ESP32_UNIVERSAL_MAC_ADDRESSES;
{$else CONFIG_IDF_TARGET_ESP32S2BETA}
  UNIVERSAL_MAC_ADDR_NUM = CONFIG_ESP32S2_UNIVERSAL_MAC_ADDRESSES;
{$endif}
  CHIP_FEATURE_EMB_FLASH     = BIT0;      //!< Chip has embedded flash memory
  CHIP_FEATURE_WIFI_BGN      = BIT1;      //!< Chip has 2.4GHz WiFi
  CHIP_FEATURE_BLE           = BIT4;      //!< Chip has Bluetooth LE
  CHIP_FEATURE_BT            = BIT5;      //!< Chip has Bluetooth Classic

type
  Pesp_mac_type = ^Tesp_mac_type;
  Tesp_mac_type = (ESP_MAC_WIFI_STA, ESP_MAC_WIFI_SOFTAP, ESP_MAC_BT,
    ESP_MAC_ETH);

  Pesp_reset_reason = ^Tesp_reset_reason;
  Tesp_reset_reason = (ESP_RST_UNKNOWN, ESP_RST_POWERON, ESP_RST_EXT,
    ESP_RST_SW, ESP_RST_PANIC, ESP_RST_INT_WDT,
    ESP_RST_TASK_WDT, ESP_RST_WDT, ESP_RST_DEEPSLEEP,
    ESP_RST_BROWNOUT, ESP_RST_SDIO);

  Tshutdown_handler = procedure(para1: pointer);

  Pesp_chip_model = ^Tesp_chip_model;
  Tesp_chip_model = (CHIP_ESP32 = 1, CHIP_ESP32S2BETA = 2);

  Pesp_chip_info = ^Tesp_chip_info;
  Tesp_chip_info = record
    model: Tesp_chip_model;
    features: uint32;
    cores: byte;
    revision: byte;
  end;

function esp_register_shutdown_handler(handle: Tshutdown_handler): Tesp_err;
  external;
function esp_unregister_shutdown_handler(handle: Tshutdown_handler): Tesp_err;
  external;
procedure esp_restart; noreturn; external;
function esp_reset_reason: Tesp_reset_reason; external;
function esp_get_free_heap_size: uint32; external;
function esp_get_minimum_free_heap_size: uint32; external;
function esp_random: uint32; external;
procedure esp_fill_random(buf: pointer; len: Tsize); external;
function esp_base_mac_addr_set(mac: PByte): Tesp_err; external;
function esp_base_mac_addr_get(mac: PByte): Tesp_err; external;
function esp_efuse_mac_get_custom(mac: PByte): Tesp_err; external;
function esp_efuse_mac_get_default(mac: PByte): Tesp_err; external;
function esp_read_mac(mac: PByte; _type: Tesp_mac_type): Tesp_err; external;
function esp_derive_local_mac(local_mac: PByte; universal_mac: PByte): Tesp_err;
  external;
procedure esp_chip_info(out_info: Pesp_chip_info); external;

implementation

end.
