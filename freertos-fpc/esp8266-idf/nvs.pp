unit nvs;

interface

uses
  esp_err, portmacro;

const
  ESP_ERR_NVS_BASE = $1100;
  ESP_ERR_NVS_NOT_INITIALIZED      = ESP_ERR_NVS_BASE + $01;
  ESP_ERR_NVS_NOT_FOUND            = ESP_ERR_NVS_BASE + $02;
  ESP_ERR_NVS_TYPE_MISMATCH        = ESP_ERR_NVS_BASE + $03;
  ESP_ERR_NVS_READ_ONLY            = ESP_ERR_NVS_BASE + $04;
  ESP_ERR_NVS_NOT_ENOUGH_SPACE     = ESP_ERR_NVS_BASE + $05;
  ESP_ERR_NVS_INVALID_NAME         = ESP_ERR_NVS_BASE + $06;
  ESP_ERR_NVS_INVALID_HANDLE       = ESP_ERR_NVS_BASE + $07;
  ESP_ERR_NVS_REMOVE_FAILED        = ESP_ERR_NVS_BASE + $08;
  ESP_ERR_NVS_KEY_TOO_LONG         = ESP_ERR_NVS_BASE + $09;
  ESP_ERR_NVS_PAGE_FULL            = ESP_ERR_NVS_BASE + $0a;
  ESP_ERR_NVS_INVALID_STATE        = ESP_ERR_NVS_BASE + $0b;
  ESP_ERR_NVS_INVALID_LENGTH       = ESP_ERR_NVS_BASE + $0c;
  ESP_ERR_NVS_NO_FREE_PAGES        = ESP_ERR_NVS_BASE + $0d;
  ESP_ERR_NVS_VALUE_TOO_LONG       = ESP_ERR_NVS_BASE + $0e;
  ESP_ERR_NVS_PART_NOT_FOUND       = ESP_ERR_NVS_BASE + $0f;
  ESP_ERR_NVS_NEW_VERSION_FOUND    = ESP_ERR_NVS_BASE + $10;
  ESP_ERR_NVS_XTS_ENCR_FAILED      = ESP_ERR_NVS_BASE + $11;
  ESP_ERR_NVS_XTS_DECR_FAILED      = ESP_ERR_NVS_BASE + $12;
  ESP_ERR_NVS_XTS_CFG_FAILED       = ESP_ERR_NVS_BASE + $13;
  ESP_ERR_NVS_XTS_CFG_NOT_FOUND    = ESP_ERR_NVS_BASE + $14;
  ESP_ERR_NVS_ENCR_NOT_SUPPORTED   = ESP_ERR_NVS_BASE + $15;
  ESP_ERR_NVS_KEYS_NOT_INITIALIZED = ESP_ERR_NVS_BASE + $16;
  ESP_ERR_NVS_CORRUPT_KEY_PART     = ESP_ERR_NVS_BASE + $17;
  ESP_ERR_NVS_CONTENT_DIFFERS      = ESP_ERR_NVS_BASE + $18;
  ESP_ERR_NVS_WRONG_ENCRYPTION     = ESP_ERR_NVS_BASE + $19;
  NVS_DEFAULT_PART_NAME = 'nvs';

type
  Pnvs_handle = ^Tnvs_handle;
  Tnvs_handle = uint32;
  Pnvs_open_mode = ^Tnvs_open_mode;
  Tnvs_open_mode = (NVS_READONLY, NVS_READWRITE);

  Tnvs_type = (
    NVS_TYPE_U8   = $01,
    NVS_TYPE_I8   = $11,
    NVS_TYPE_U16  = $02,
    NVS_TYPE_I16  = $12,
    NVS_TYPE_U32  = $04,
    NVS_TYPE_I32  = $14,
    NVS_TYPE_U64  = $08,
    NVS_TYPE_I64  = $18,
    NVS_TYPE_STR  = $21,
    NVS_TYPE_BLOB = $42,
    NVS_TYPE_ANY  = $ff
  );

  Pnvs_entry_info = ^Tnvs_entry_info;
  Tnvs_entry_info = record
    namespace_name: array[0..15] of char;
    key: array[0..15] of char;
    _type: Tnvs_type;
  end;

  Tnvs_opaque_iterator = record end;
  Pnvs_iterator = ^Tnvs_iterator;
  Tnvs_iterator = ^Tnvs_opaque_iterator;

function nvs_open(Name: PChar; open_mode: Tnvs_open_mode;
  out_handle: Pnvs_handle): Tesp_err; external;
function nvs_open_from_partition(part_name: PChar; Name: PChar;
  open_mode: Tnvs_open_mode; out_handle: Pnvs_handle): Tesp_err; external;
function nvs_set_i8(handle: Tnvs_handle; key: PChar; Value: int8): Tesp_err;
  external;
function nvs_set_u8(handle: Tnvs_handle; key: PChar; Value: byte): Tesp_err;
  external;
function nvs_set_i16(handle: Tnvs_handle; key: PChar; Value: int16): Tesp_err;
  external;
function nvs_set_u16(handle: Tnvs_handle; key: PChar; Value: uint16): Tesp_err;
  external;
function nvs_set_i32(handle: Tnvs_handle; key: PChar; Value: int32): Tesp_err;
  external;
function nvs_set_u32(handle: Tnvs_handle; key: PChar; Value: uint32): Tesp_err;
  external;
function nvs_set_i64(handle: Tnvs_handle; key: PChar; Value: int64): Tesp_err;
  external;
function nvs_set_u64(handle: Tnvs_handle; key: PChar; Value: uint64): Tesp_err;
  external;
function nvs_set_str(handle: Tnvs_handle; key: PChar; Value: PChar): Tesp_err;
  external;
function nvs_set_blob(handle: Tnvs_handle; key: PChar; Value: pointer;
  length: Tsize): Tesp_err; external;
function nvs_get_i8(handle: Tnvs_handle; key: PChar; out_value: Pint8): Tesp_err;
  external;
function nvs_get_u8(handle: Tnvs_handle; key: PChar; out_value: Puint8): Tesp_err;
  external;
function nvs_get_i16(handle: Tnvs_handle; key: PChar; out_value: Pint16): Tesp_err;
  external;
function nvs_get_u16(handle: Tnvs_handle; key: PChar;
  out_value: Puint16): Tesp_err; external;
function nvs_get_i32(handle: Tnvs_handle; key: PChar; out_value: Pint32): Tesp_err;
  external;
function nvs_get_u32(handle: Tnvs_handle; key: PChar;
  out_value: Puint32): Tesp_err; external;
function nvs_get_i64(handle: Tnvs_handle; key: PChar; out_value: Pint64): Tesp_err;
  external;
function nvs_get_u64(handle: Tnvs_handle; key: PChar;
  out_value: Puint64): Tesp_err; external;
function nvs_get_str(handle: Tnvs_handle; key: PChar; out_value: PChar;
  length: Psize): Tesp_err; external;
function nvs_get_blob(handle: Tnvs_handle; key: PChar; out_value: pointer;
  length: Psize): Tesp_err; external;
function nvs_erase_key(handle: Tnvs_handle; key: PChar): Tesp_err; external;
function nvs_erase_all(handle: Tnvs_handle): Tesp_err; external;
function nvs_commit(handle: Tnvs_handle): Tesp_err; external;
procedure nvs_close(handle: Tnvs_handle); external;

type
  Pnvs_stats = ^Tnvs_stats;
  Tnvs_stats = record
    used_entries: Tsize;
    free_entries: Tsize;
    total_entries: Tsize;
    namespace_count: Tsize;
  end;

function nvs_get_stats(part_name: pchar; nvs_stats: Pnvs_stats): Tesp_err; external;
function nvs_get_used_entry_count(handle: Tnvs_handle; used_entries: Psize): Tnvs_stats; external;
function nvs_entry_find(part_name: pchar; namespace_name: pchar; Atype: Tnvs_type): Tnvs_iterator; external;
function nvs_entry_next(iterator: Tnvs_iterator): Tnvs_iterator; external;
procedure nvs_entry_info(iterator: Tnvs_iterator; out_info: Pnvs_entry_info); external;
procedure nvs_release_iterator(iterator: Tnvs_iterator); external;

implementation

end.
