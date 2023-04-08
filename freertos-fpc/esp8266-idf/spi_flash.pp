unit spi_flash;

{$include sdkconfig.inc}

interface

uses
  esp_err;

const
  ESP_ERR_FLASH_BASE = $10010;
  ESP_ERR_FLASH_OP_FAIL = ESP_ERR_FLASH_BASE + 1;
  ESP_ERR_FLASH_OP_TIMEOUT = ESP_ERR_FLASH_BASE + 2;
  SPI_FLASH_SEC_SIZE = 4096;
  SPI_READ_BUF_MAX = 64;
  SPI_FLASH_CACHE2PHYS_FAIL = $FFFFFFFF; // UINT32_MAX;

{$ifdef CONFIG_ENABLE_FLASH_MMAP}
type
  Pspi_flash_mmap_memory = ^Tspi_flash_mmap_memory;
  Tspi_flash_mmap_memory = (SPI_FLASH_MMAP_DATA, SPI_FLASH_MMAP_INST);

  Pspi_flash_mmap_handle = ^Tspi_flash_mmap_handle;
  Tspi_flash_mmap_handle = uint32;
{$endif}

function spi_flash_get_chip_size: Tsize; external;
function spi_flash_erase_sector(sector: Tsize): Tesp_err; external;
function spi_flash_erase_range(start_address: Tsize; size: Tsize): Tesp_err; external;
function spi_flash_write(dest_addr: Tsize; src: pointer;
  size: Tsize): Tesp_err; external;
function spi_flash_read(src_addr: Tsize; dest: pointer;
  size: Tsize): Tesp_err; external;
{$ifdef CONFIG_ENABLE_FLASH_MMAP}
function spi_flash_mmap(src_addr: Tsize; size: Tsize;
  memory: Tspi_flash_mmap_memory; out_ptr: Ppointer;
  out_handle: Pspi_flash_mmap_handle): Tesp_err; external;
procedure spi_flash_munmap(handle: Tspi_flash_mmap_handle); external;
{$endif}

function spi_flash_cache2phys(cached: pointer): uintptr; external;
{$ifdef CONFIG_ESP8266_OTA_FROM_OLD}
function esp_patition_table_init_location: longint; external;
function esp_patition_table_init_data(partition_info: pointer): longint; external;
{$endif}
{$ifdef CONFIG_ESP8266_BOOT_COPY_APP}
function esp_patition_copy_ota1_to_ota0(partition_info: pointer): longint; external;
{$endif}
{$ifdef CONFIG_ENABLE_TH25Q16HB_PATCH_0}
function th25q16hb_apply_patch_0(): integer;
{$endif}

implementation

end.
