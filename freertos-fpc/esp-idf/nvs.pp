unit nvs;

{$include sdkconfig.inc}

interface

uses
  esp_err, esp_partition;

{$linklib nvs_flash, static}
{$linklib stdc++, static}  // required by nvs_flash for new/delete
{$linklib gcc, static}     // required by libstdc++

type
  Pint16 = ^int16;
  Pint8 = int8;
  Psize_t = ^int32;
  Pnvs_handle_t = ^Tnvs_handle_t;
  Tnvs_handle_t = uint32;

const
  ESP_ERR_NVS_BASE = $1100;
  ESP_ERR_NVS_NOT_INITIALIZED = ESP_ERR_NVS_BASE + $01;
  ESP_ERR_NVS_NOT_FOUND = ESP_ERR_NVS_BASE + $02;
  ESP_ERR_NVS_TYPE_MISMATCH = ESP_ERR_NVS_BASE + $03;
  ESP_ERR_NVS_READ_ONLY = ESP_ERR_NVS_BASE + $04;
  ESP_ERR_NVS_NOT_ENOUGH_SPACE = ESP_ERR_NVS_BASE + $05;
  ESP_ERR_NVS_INVALID_NAME = ESP_ERR_NVS_BASE + $06;
  ESP_ERR_NVS_INVALID_HANDLE = ESP_ERR_NVS_BASE + $07;
  ESP_ERR_NVS_REMOVE_FAILED = ESP_ERR_NVS_BASE + $08;
  ESP_ERR_NVS_KEY_TOO_LONG = ESP_ERR_NVS_BASE + $09;
  ESP_ERR_NVS_PAGE_FULL = ESP_ERR_NVS_BASE + $0a;
  ESP_ERR_NVS_INVALID_STATE = ESP_ERR_NVS_BASE + $0b;
  ESP_ERR_NVS_INVALID_LENGTH = ESP_ERR_NVS_BASE + $0c;
  ESP_ERR_NVS_NO_FREE_PAGES = ESP_ERR_NVS_BASE + $0d;
  ESP_ERR_NVS_VALUE_TOO_LONG = ESP_ERR_NVS_BASE + $0e;
  ESP_ERR_NVS_PART_NOT_FOUND = ESP_ERR_NVS_BASE + $0f;
  ESP_ERR_NVS_NEW_VERSION_FOUND = ESP_ERR_NVS_BASE + $10;
  ESP_ERR_NVS_XTS_ENCR_FAILED = ESP_ERR_NVS_BASE + $11;
  ESP_ERR_NVS_XTS_DECR_FAILED = ESP_ERR_NVS_BASE + $12;
  ESP_ERR_NVS_XTS_CFG_FAILED = ESP_ERR_NVS_BASE + $13;
  ESP_ERR_NVS_XTS_CFG_NOT_FOUND = ESP_ERR_NVS_BASE + $14;
  ESP_ERR_NVS_ENCR_NOT_SUPPORTED = ESP_ERR_NVS_BASE + $15;
  ESP_ERR_NVS_KEYS_NOT_INITIALIZED = ESP_ERR_NVS_BASE + $16;
  ESP_ERR_NVS_CORRUPT_KEY_PART = ESP_ERR_NVS_BASE + $17;
  ESP_ERR_NVS_CONTENT_DIFFERS = ESP_ERR_NVS_BASE + $18;
  NVS_DEFAULT_PART_NAME = 'nvs';
  NVS_PART_NAME_MAX_SIZE = 16;

type
  Pnvs_open_mode_t = ^Tnvs_open_mode_t;
  Tnvs_open_mode_t = (NVS_READONLY, NVS_READWRITE);

  Pnvs_type_t = ^Tnvs_type_t;
  Tnvs_type_t = (NVS_TYPE_U8 = $01, NVS_TYPE_I8 = $11, NVS_TYPE_U16 = $02,
    NVS_TYPE_I16 = $12, NVS_TYPE_U32 = $04, NVS_TYPE_I32 = $14,
    NVS_TYPE_U64 = $08, NVS_TYPE_I64 = $18, NVS_TYPE_STR = $21,
    NVS_TYPE_BLOB = $42, NVS_TYPE_ANY = $ff);

  Pnvs_entry_info_t = ^Tnvs_entry_info_t;
  Tnvs_entry_info_t = record
    namespace_name: array[0..15] of char;
    key: array[0..15] of char;
    _type: Tnvs_type_t;
  end;

  Tnvs_opaque_iterator_t = record end;
  Pnvs_iterator_t = ^Tnvs_iterator_t;
  Tnvs_iterator_t = ^Tnvs_opaque_iterator_t;

function nvs_open(Name: PChar; open_mode: Tnvs_open_mode_t;
  out_handle: Pnvs_handle_t): Tesp_err_t; cdecl; external;

function nvs_open_from_partition(part_name: PChar; Name: PChar;
  open_mode: Tnvs_open_mode_t; out_handle: Pnvs_handle_t): Tesp_err_t; cdecl; external;

function nvs_set_i8(handle: Tnvs_handle_t; key: PChar; Value: int8): Tesp_err_t;
  cdecl; external;

function nvs_set_u8(handle: Tnvs_handle_t; key: PChar; Value: byte): Tesp_err_t;
  cdecl; external;

function nvs_set_i16(handle: Tnvs_handle_t; key: PChar;
  Value: int16): Tesp_err_t; cdecl; external;

function nvs_set_u16(handle: Tnvs_handle_t; key: PChar;
  Value: uint16): Tesp_err_t; cdecl; external;

function nvs_set_i32(handle: Tnvs_handle_t; key: PChar;
  Value: int32): Tesp_err_t; cdecl; external;

function nvs_set_u32(handle: Tnvs_handle_t; key: PChar;
  Value: uint32): Tesp_err_t; cdecl; external;

function nvs_set_i64(handle: Tnvs_handle_t; key: PChar;
  Value: int64): Tesp_err_t; cdecl; external;

function nvs_set_u64(handle: Tnvs_handle_t; key: PChar;
  Value: uint64): Tesp_err_t; cdecl; external;

function nvs_set_str(handle: Tnvs_handle_t; key: PChar; Value: PChar): Tesp_err_t;
  cdecl; external;

function nvs_set_blob(handle: Tnvs_handle_t; key: PChar; Value: pointer;
  length: Tsize_t): Tesp_err_t; cdecl; external;

function nvs_get_i8(handle: Tnvs_handle_t; key: PChar;
  out_value: Pint8): Tesp_err_t; cdecl; external;

function nvs_get_u8(handle: Tnvs_handle_t; key: PChar;
  out_value: PByte): Tesp_err_t; cdecl; external;

function nvs_get_i16(handle: Tnvs_handle_t; key: PChar;
  out_value: Pint16): Tesp_err_t; cdecl; external;

function nvs_get_u16(handle: Tnvs_handle_t; key: PChar;
  out_value: PUInt16): Tesp_err_t; cdecl; external;

function nvs_get_i32(handle: Tnvs_handle_t; key: PChar;
  out_value: PInt32): Tesp_err_t; cdecl; external;

function nvs_get_u32(handle: Tnvs_handle_t; key: PChar;
  out_value: PUInt32): Tesp_err_t; cdecl; external;

function nvs_get_i64(handle: Tnvs_handle_t; key: PChar;
  out_value: PInt64): Tesp_err_t; cdecl; external;

function nvs_get_u64(handle: Tnvs_handle_t; key: PChar;
  out_value: PUInt64): Tesp_err_t; cdecl; external;

function nvs_get_str(handle: Tnvs_handle_t; key: PChar; out_value: PChar;
  length: Psize_t): Tesp_err_t; cdecl; external;

function nvs_get_blob(handle: Tnvs_handle_t; key: PChar; out_value: pointer;
  length: Psize_t): Tesp_err_t; cdecl; external;

function nvs_erase_key(handle: Tnvs_handle_t; key: PChar): Tesp_err_t; cdecl; external;

function nvs_erase_all(handle: Tnvs_handle_t): Tesp_err_t; cdecl; external;

function nvs_commit(handle: Tnvs_handle_t): Tesp_err_t; cdecl; external;

procedure nvs_close(handle: Tnvs_handle_t); cdecl; external;

type
  Pnvs_stats_t = ^Tnvs_stats_t;
  Tnvs_stats_t = record
    used_entries: Tsize_t;
    free_entries: Tsize_t;
    total_entries: Tsize_t;
    namespace_count: Tsize_t;
  end;

function nvs_get_stats(part_name: PChar; nvs_stats: Pnvs_stats_t): Tesp_err_t;
  cdecl; external;

function nvs_get_used_entry_count(handle: Tnvs_handle_t;
  used_entries: Psize_t): Tesp_err_t; cdecl; external;

function nvs_entry_find(part_name: PChar; namespace_name: PChar;
  _type: Tnvs_type_t): Tnvs_iterator_t; cdecl; external;

function nvs_entry_next(iterator: Tnvs_iterator_t): Tnvs_iterator_t; cdecl; external;

procedure nvs_entry_info(iterator: Tnvs_iterator_t; out_info: Pnvs_entry_info_t);
  cdecl; external;

procedure nvs_release_iterator(iterator: Tnvs_iterator_t); cdecl; external;

// From nvs_flash.h
const
  NVS_KEY_SIZE = 32;

type
  Pnvs_sec_cfg_t = ^Tnvs_sec_cfg_t;
  Tnvs_sec_cfg_t = record
    eky: array[0..(NVS_KEY_SIZE) - 1] of byte;
    tky: array[0..(NVS_KEY_SIZE) - 1] of byte;
  end;

function nvs_flash_init: Tesp_err_t; cdecl; external;

function nvs_flash_init_partition(partition_label: PChar): Tesp_err_t; cdecl; external;

function nvs_flash_deinit: Tesp_err_t; cdecl; external;

function nvs_flash_deinit_partition(partition_label: PChar): Tesp_err_t; cdecl; external;

function nvs_flash_erase: Tesp_err_t; cdecl; external;

function nvs_flash_erase_partition(part_name: PChar): Tesp_err_t; cdecl; external;

function nvs_flash_secure_init(cfg: Pnvs_sec_cfg_t): Tesp_err_t; cdecl; external;

function nvs_flash_secure_init_partition(partition_label: PChar;
  cfg: Pnvs_sec_cfg_t): Tesp_err_t; cdecl; external;

function nvs_flash_generate_keys(partition: Pesp_partition_t;
  cfg: Pnvs_sec_cfg_t): Tesp_err_t; cdecl; external;

function nvs_flash_read_security_cfg(partition: Pesp_partition_t;
  cfg: Pnvs_sec_cfg_t): Tesp_err_t; cdecl; external;

implementation

end.
