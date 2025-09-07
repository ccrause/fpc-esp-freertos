unit esp_flash_partitions;

{$include sdkconfig.inc}

interface

uses
  esp_err, portmacro;

const
  ESP_PARTITION_MAGIC = $50AA;
  ESP_PARTITION_MAGIC_MD5 = $EBEB;
  PART_TYPE_APP = $00;
  PART_SUBTYPE_FACTORY = $00;
  PART_SUBTYPE_OTA_FLAG = $10;
  PART_SUBTYPE_OTA_MASK = $0f;
  PART_SUBTYPE_TEST = $20;
  PART_TYPE_DATA = $01;
  PART_SUBTYPE_DATA_OTA = $00;
  PART_SUBTYPE_DATA_RF = $01;
  PART_SUBTYPE_DATA_WIFI = $02;
  PART_SUBTYPE_DATA_NVS_KEYS = $04;
  PART_SUBTYPE_DATA_EFUSE_EM = $05;
  PART_TYPE_END = $ff;
  PART_SUBTYPE_END = $ff;
  PART_FLAG_ENCRYPTED = 1 shl 0;
  ESP_BOOTLOADER_DIGEST_OFFSET = $0;
  ESP_BOOTLOADER_OFFSET = $1000;
  ESP_PARTITION_TABLE_OFFSET = CONFIG_PARTITION_TABLE_OFFSET;
  ESP_PARTITION_TABLE_MAX_LEN = $C00;

type
  Pesp_ota_img_states = ^Tesp_ota_img_states;
  Tesp_ota_img_states = (ESP_OTA_IMG_NEW = $0, ESP_OTA_IMG_PENDING_VERIFY = $1,
    ESP_OTA_IMG_VALID = $2, ESP_OTA_IMG_INVALID = $3,
    ESP_OTA_IMG_ABORTED = $4, ESP_OTA_IMG_UNDEFINED = -1); // $FFFFFFFF);

  Pesp_ota_select_entry = ^Tesp_ota_select_entry;
  Tesp_ota_select_entry = record
    ota_seq: uint32;
    seq_label: array[0..19] of byte;
    ota_state: uint32;
    crc: uint32;
  end;

  Pesp_partition_pos = ^Tesp_partition_pos;
  Tesp_partition_pos = record
    offset: uint32;
    size: uint32;
  end;

  Pesp_partition_info = ^Tesp_partition_info;
  Tesp_partition_info = record
    magic: uint16;
    _type: byte;
    subtype: byte;
    pos: Tesp_partition_pos;
    _label: array[0..15] of byte;
    flags: uint32;
  end;

const
  ESP_PARTITION_TABLE_MAX_ENTRIES = ESP_PARTITION_TABLE_MAX_LEN div (sizeof(Tesp_partition_info));

function esp_partition_table_verify(partition_table: Pesp_partition_info;
  log_errors: longbool; num_partitions: Plongint): Tesp_err; external;
function esp_partition_main_flash_region_safe(addr: Tsize;
  size: Tsize): longbool; external;

implementation

end.
