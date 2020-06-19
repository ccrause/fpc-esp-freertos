unit esp_partition;

interface

uses
  esp_err, esp_flash, esp_spi_flash;

type
  Pesp_partition_type = ^Tesp_partition_type;
  Tesp_partition_type = (ESP_PARTITION_TYPE_APP = $00, ESP_PARTITION_TYPE_DATA = $01);

  Pesp_partition_subtype = ^Tesp_partition_subtype;
  Tesp_partition_subtype = (ESP_PARTITION_SUBTYPE_APP_FACTORY = $00,
    ESP_PARTITION_SUBTYPE_APP_OTA_MIN = $10,
    ESP_PARTITION_SUBTYPE_APP_OTA_0   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 0,
    ESP_PARTITION_SUBTYPE_APP_OTA_1   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 1,
    ESP_PARTITION_SUBTYPE_APP_OTA_2   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 2,
    ESP_PARTITION_SUBTYPE_APP_OTA_3   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 3,
    ESP_PARTITION_SUBTYPE_APP_OTA_4   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 4,
    ESP_PARTITION_SUBTYPE_APP_OTA_5   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 5,
    ESP_PARTITION_SUBTYPE_APP_OTA_6   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 6,
    ESP_PARTITION_SUBTYPE_APP_OTA_7   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 7,
    ESP_PARTITION_SUBTYPE_APP_OTA_8   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 8,
    ESP_PARTITION_SUBTYPE_APP_OTA_9   = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 9,
    ESP_PARTITION_SUBTYPE_APP_OTA_10  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 10,
    ESP_PARTITION_SUBTYPE_APP_OTA_11  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 11,
    ESP_PARTITION_SUBTYPE_APP_OTA_12  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 12,
    ESP_PARTITION_SUBTYPE_APP_OTA_13  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 13,
    ESP_PARTITION_SUBTYPE_APP_OTA_14  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 14,
    ESP_PARTITION_SUBTYPE_APP_OTA_15  = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 15,
    ESP_PARTITION_SUBTYPE_APP_OTA_MAX = ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + 16,
    ESP_PARTITION_SUBTYPE_APP_TEST    = $20, ESP_PARTITION_SUBTYPE_DATA_OTA = $00,
    ESP_PARTITION_SUBTYPE_DATA_PHY    = $01, ESP_PARTITION_SUBTYPE_DATA_NVS = $02,
    ESP_PARTITION_SUBTYPE_DATA_COREDUMP = $03,
    ESP_PARTITION_SUBTYPE_DATA_NVS_KEYS = $04,
    ESP_PARTITION_SUBTYPE_DATA_EFUSE_EM = $05,
    ESP_PARTITION_SUBTYPE_DATA_ESPHTTPD = $80,
    ESP_PARTITION_SUBTYPE_DATA_FAT = $81, ESP_PARTITION_SUBTYPE_DATA_SPIFFS = $82,
    ESP_PARTITION_SUBTYPE_ANY = $ff);

  Tesp_partition_iterator_opaque_ = record end;
  Pesp_partition_iterator = ^Tesp_partition_iterator;
  Tesp_partition_iterator = ^Tesp_partition_iterator_opaque_;

  Pesp_partition = ^Tesp_partition;
  PPesp_partition = ^Pesp_partition;
  Tesp_partition = record
    flash_chip: Pesp_flash;
    _type: Tesp_partition_type;
    subtype: Tesp_partition_subtype;
    address: uint32;
    size: uint32;
    _label: array[0..16] of char;
    encrypted: Tbool;
  end;

function esp_partition_find(_type: Tesp_partition_type;
  subtype: Tesp_partition_subtype; _label: pchar): Tesp_partition_iterator;
  external;
function esp_partition_find_first(_type: Tesp_partition_type;
  subtype: Tesp_partition_subtype; _label: pchar): Pesp_partition; external;
function esp_partition_get(iterator: Tesp_partition_iterator): Pesp_partition;
  external;
function esp_partition_next(iterator: Tesp_partition_iterator):
  Tesp_partition_iterator;
  external;
procedure esp_partition_iterator_release(iterator: Tesp_partition_iterator);
  external;
function esp_partition_verify(partition: Pesp_partition): Pesp_partition;
  external;
function esp_partition_read(partition: Pesp_partition; src_offset: Tsize;
  dst: pointer; size: Tsize): Tesp_err; external;
function esp_partition_write(partition: Pesp_partition; dst_offset: Tsize;
  src: pointer; size: Tsize): Tesp_err; external;
function esp_partition_erase_range(partition: Pesp_partition;
  offset: Tsize; size: Tsize): Tesp_err; external;
function esp_partition_mmap(partition: Pesp_partition; offset: Tsize;
  size: Tsize; memory: Tspi_flash_mmap_memory; out_ptr: Ppointer;
  out_handle: Pspi_flash_mmap_handle): Tesp_err; external;
function esp_partition_get_sha256(partition: Pesp_partition;
  sha_256: PByte): Tesp_err; external;
function esp_partition_check_identity(partition_1: Pesp_partition;
  partition_2: Pesp_partition): Tbool; external;
function esp_partition_register_external(flash_chip: Pesp_flash;
  offset: Tsize; size: Tsize; _label: pchar; _type: Tesp_partition_type;
  subtype: Tesp_partition_subtype;
  out_partition: PPesp_partition): Tesp_err; external;
function esp_partition_deregister_external(partition: Pesp_partition): Tesp_err;
  external;

function ESP_PARTITION_SUBTYPE_OTA(i: longint): Tesp_partition_subtype;

implementation

function ESP_PARTITION_SUBTYPE_OTA(i: longint): Tesp_partition_subtype;
begin
  ESP_PARTITION_SUBTYPE_OTA := Tesp_partition_subtype(ord(ESP_PARTITION_SUBTYPE_APP_OTA_MIN) + (i and $f));
end;

end.
