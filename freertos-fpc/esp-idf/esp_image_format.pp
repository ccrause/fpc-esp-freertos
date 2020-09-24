unit esp_image_format;

{$include sdkconfig.inc}

interface

const
  ESP_ERR_IMAGE_BASE = $2000;
  ESP_ERR_IMAGE_FLASH_FAIL = ESP_ERR_IMAGE_BASE + 1;
  ESP_ERR_IMAGE_INVALID = ESP_ERR_IMAGE_BASE + 2;
  ESP_IMAGE_HASH_LEN = 32;
  ESP_BOOTLOADER_RESERVE_RTC =
{$ifdef CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC}
    CONFIG_BOOTLOADER_RESERVE_RTC_SIZE + CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC_SIZE;
{$elseif defined(CONFIG_BOOTLOADER_SKIP_VALIDATE_IN_DEEP_SLEEP)}
    CONFIG_BOOTLOADER_RESERVE_RTC_SIZE;
{$endif}

type
  Pesp_image_metadata = ^Tesp_image_metadata;
  Tesp_image_metadata = record
    start_addr: uint32;
    image: Tesp_image_header_t;
    segments: array[0..(ESP_IMAGE_MAX_SEGMENTS) - 1] of Tesp_image_segment_header_t;
    segment_data: array[0..(ESP_IMAGE_MAX_SEGMENTS) - 1] of uint32;
    image_len: uint32;
    image_digest: array[0..31] of byte;
  end;

type
  Pesp_image_load_mode = ^Tesp_image_load_mode;
  Tesp_image_load_mode = (ESP_IMAGE_VERIFY, ESP_IMAGE_VERIFY_SILENT
  {$ifdef BOOTLOADER_BUILD}
    , ESP_IMAGE_LOAD, ESP_IMAGE_LOAD_NO_VALIDATE
  {$endif}
    );

{$ifdef CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC}
{$endif}

type
  Prtc_retain_mem = ^Trtc_retain_mem;
  Trtc_retain_mem = record
    partition: Tesp_partition_pos;
    reboot_counter: uint16;
    reserve: uint16;
    {$ifdef CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC}
      custom: array[0..(CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC_SIZE) - 1] of byte;
    {$endif}
    crc: uint32;
  end;
{$ifdef CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC}
  {$if (CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC_SIZE mod 4) = 0}
    {$Error 'CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC_SIZE must be a multiple of 4 bytes'}
  {$endif}
{$endif}

{$if defined(CONFIG_BOOTLOADER_SKIP_VALIDATE_IN_DEEP_SLEEP) or defined(CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC)}
  {$if (CONFIG_BOOTLOADER_RESERVE_RTC_SIZE mod 4) = 0}
    {$Error 'CONFIG_BOOTLOADER_RESERVE_RTC_SIZE must be a multiple of 4 bytes'};
  {$endif}
{$endif}

  Pesp_image_flash_mappingt = ^Tesp_image_flash_mapping;
  Tesp_image_flash_mapping = record
    drom_addr: uint32;
    drom_load_addr: uint32;
    drom_size: uint32;
    irom_addr: uint32;
    irom_load_addr: uint32;
    irom_size: uint32;
  end;

{$if defined(CONFIG_BOOTLOADER_SKIP_VALIDATE_IN_DEEP_SLEEP) or defined(CONFIG_BOOTLOADER_CUSTOM_RESERVE_RTC)}
  {$if (sizeof(Trtc_retain_mem) <= ESP_BOOTLOADER_RESERVE_RTC}
    {$Error 'Reserved RTC area must exceed size of Trtc_retain_mem}
  {$endif}
{$endif}

function esp_image_verify(mode: Tesp_image_load_mode; part: Pesp_partition_pos;
  Data: Pesp_image_metadata): Tesp_err; external;
function bootloader_load_image(part: Pesp_partition_pos;
  Data: Pesp_image_metadata): Tesp_err; external;
function bootloader_load_image_no_verify(part: Pesp_partition_pos;
  Data: Pesp_image_metadata): Tesp_err; external;
function esp_image_verify_bootloader(length: Puint32_t): Tesp_err; external;
function esp_image_verify_bootloader_data(Data: Pesp_image_metadata): Tesp_err;
  external;

implementation

end.
