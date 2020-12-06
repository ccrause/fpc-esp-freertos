unit esp_system;

{$include freertosconfig.inc}
{$linklib util, static}             // required for esp_crc8
{$linklib wpa, static}              // required for esp_random
{$linklib wpa_supplicant, static}   // required for pbkdf2_sha1

interface

uses
  esp_err, eagle_soc;

const
  CRYSTAL_USED = 26;
  CHIP_FEATURE_EMB_FLASH  = BIT0;      // Chip has embedded flash memory
  CHIP_FEATURE_WIFI_BGN   = BIT1;      // Chip has 2.4GHz WiFi
  CHIP_FEATURE_BLE        = BIT4;      // Chip has Bluetooth LE
  CHIP_FEATURE_BT         = BIT5;      // Chip has Bluetooth Classic

type
  Pesp_mac_type = ^Tesp_mac_type;
  Tesp_mac_type = (ESP_MAC_WIFI_STA, ESP_MAC_WIFI_SOFTAP);

  Pesp_reset_reason = ^Tesp_reset_reason;
  Tesp_reset_reason = (ESP_RST_UNKNOWN = 0, ESP_RST_POWERON, ESP_RST_EXT,
    ESP_RST_SW, ESP_RST_PANIC, ESP_RST_INT_WDT,
    ESP_RST_TASK_WDT, ESP_RST_WDT, ESP_RST_DEEPSLEEP,
    ESP_RST_BROWNOUT, ESP_RST_SDIO);

function esp_base_mac_addr_set(mac: PByte): Tesp_err; external;
function esp_base_mac_addr_get(mac: PByte): Tesp_err; external;
function esp_efuse_mac_get_default(mac: PByte): Tesp_err; external;
function esp_read_mac(mac: PByte; _type: Tesp_mac_type): Tesp_err; external;
function esp_derive_local_mac(local_mac: PByte; universal_mac: PByte): Tesp_err; external;

type
  Pesp_cpu_freq = ^Tesp_cpu_freq;
  Tesp_cpu_freq = (ESP_CPU_FREQ_80M = 1, ESP_CPU_FREQ_160M = 2);

procedure esp_set_cpu_freq(cpu_freq: Tesp_cpu_freq); external;
procedure system_restore; noreturn; external;
procedure esp_restart; noreturn; external;
function esp_reset_reason: Tesp_reset_reason; external;
function esp_get_free_heap_size: uint32; external;
function esp_get_minimum_free_heap_size: uint32; external;
function esp_random: uint32; external;
procedure esp_fill_random(buf: pointer; len: Tsize); external;

type
  Pflash_size_map = ^Tflash_size_map;
  Tflash_size_map = (FLASH_SIZE_4M_MAP_256_256 = 0, FLASH_SIZE_2M,
    FLASH_SIZE_8M_MAP_512_512, FLASH_SIZE_16M_MAP_512_512,
    FLASH_SIZE_32M_MAP_512_512, FLASH_SIZE_16M_MAP_1024_1024,
    FLASH_SIZE_32M_MAP_1024_1024, FLASH_SIZE_32M_MAP_2048_2048,
    FLASH_SIZE_64M_MAP_1024_1024, FLASH_SIZE_128M_MAP_1024_1024,
    FALSH_SIZE_MAP_MAX);

  Pesp_chip_model = ^Tesp_chip_model;
  Tesp_chip_model = (CHIP_ESP8266 = 0, CHIP_ESP32 = 1);

type
  Pesp_chip_info = ^Tesp_chip_info;
  Tesp_chip_info = record
    model: Tesp_chip_model;
    features: uint32;
    cores: byte;
    revision: byte;
  end;

procedure esp_chip_info(out_info: Pesp_chip_info); external;
function system_get_flash_size_map: Tflash_size_map; external;

implementation

end.
