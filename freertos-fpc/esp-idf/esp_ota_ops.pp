unit esp_ota_ops;

interface

uses
  esp_err, esp_partition, esp_app_format, esp_flash_partitions, portmacro;

const
  OTA_SIZE_UNKNOWN = $ffffffff;
  ESP_ERR_OTA_BASE = $1500;
  ESP_ERR_OTA_PARTITION_CONFLICT = ESP_ERR_OTA_BASE + $01;
  ESP_ERR_OTA_SELECT_INFO_INVALID = ESP_ERR_OTA_BASE + $02;
  ESP_ERR_OTA_VALIDATE_FAILED = ESP_ERR_OTA_BASE + $03;
  ESP_ERR_OTA_SMALL_SEC_VER = ESP_ERR_OTA_BASE + $04;
  ESP_ERR_OTA_ROLLBACK_FAILED = ESP_ERR_OTA_BASE + $05;
  ESP_ERR_OTA_ROLLBACK_INVALID_STATE = ESP_ERR_OTA_BASE + $06;

type
  Pesp_ota_handle = ^Tesp_ota_handle;
  Tesp_ota_handle = uint32;

function esp_ota_get_app_description: Pesp_app_desc; external;
function esp_ota_get_app_elf_sha256(dst: PChar; size: Tsize): longint; external;
function esp_ota_begin(partition: Pesp_partition; image_size: Tsize;
  out_handle: Pesp_ota_handle): Tesp_err; external;
function esp_ota_write(handle: Tesp_ota_handle; Data: pointer;
  size: Tsize): Tesp_err; external;
function esp_ota_end(handle: Tesp_ota_handle): Tesp_err; external;
function esp_ota_set_boot_partition(partition: Pesp_partition): Tesp_err;
  external;
function esp_ota_get_boot_partition: Pesp_partition; external;
function esp_ota_get_running_partition: Pesp_partition; external;
function esp_ota_get_next_update_partition(start_from: Pesp_partition): Pesp_partition;
  external;
function esp_ota_get_partition_description(partition: Pesp_partition;
  app_desc: Pesp_app_desc): Tesp_err; external;
function esp_ota_mark_app_valid_cancel_rollback: Tesp_err; external;
function esp_ota_mark_app_invalid_rollback_and_reboot: Tesp_err; external;
function esp_ota_get_last_invalid_partition: Pesp_partition; external;
function esp_ota_get_state_partition(partition: Pesp_partition;
  ota_state: Pesp_ota_img_states): Tesp_err; external;
function esp_ota_erase_last_boot_app_partition: Tesp_err; external;
function esp_ota_check_rollback_is_possible: longbool; external;

implementation

end.
