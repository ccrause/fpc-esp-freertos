unit esp_spi_flash;

{$include sdkconfig.inc}

interface

uses
  esp_err;

const
  ESP_ERR_FLASH_OP_FAIL = ESP_ERR_FLASH_BASE + 1;
  ESP_ERR_FLASH_OP_TIMEOUT = ESP_ERR_FLASH_BASE + 2;
  SPI_FLASH_SEC_SIZE = 4096;
  SPI_FLASH_MMU_PAGE_SIZE = $10000;
  SPI_FLASH_CACHE2PHYS_FAIL = $FFFFFFFF; //UINT32_MAX;

type
  Pspi_flash_wrap_mode_t = ^Tspi_flash_wrap_mode_t;
  Tspi_flash_wrap_mode_t = (FLASH_WRAP_MODE_8B = 0, FLASH_WRAP_MODE_16B = 2,
    FLASH_WRAP_MODE_32B = 4, FLASH_WRAP_MODE_64B = 6,
    FLASH_WRAP_MODE_DISABLE = 1);

  Pspi_flash_mmap_memory_t = ^Tspi_flash_mmap_memory_t;
  Tspi_flash_mmap_memory_t = (SPI_FLASH_MMAP_DATA, SPI_FLASH_MMAP_INST);

  Pspi_flash_mmap_handle_t = ^Tspi_flash_mmap_handle_t;
  Tspi_flash_mmap_handle_t = uint32;

  Tspi_flash_guard_start_func_t = procedure(para1: pointer); cdecl;
  Tspi_flash_guard_end_func_t = procedure(para1: pointer); cdecl;
  Tspi_flash_op_lock_func_t = procedure(para1: pointer); cdecl;
  Tspi_flash_op_unlock_func_t = procedure(para1: pointer); cdecl;
  Tspi_flash_is_safe_write_address_t = function(addr: Tsize_t; size: Tsize_t): longbool; cdecl;

  Pspi_flash_guard_funcs_t = ^Tspi_flash_guard_funcs_t;
  Tspi_flash_guard_funcs_t = record
    start: Tspi_flash_guard_start_func_t;
    end_: Tspi_flash_guard_end_func_t;
    op_lock: Tspi_flash_op_lock_func_t;
    op_unlock: Tspi_flash_op_unlock_func_t;
    {$ifndef CONFIG_SPI_FLASH_DANGEROUS_WRITE_ALLOWED}
    is_safe_write_address: Tspi_flash_is_safe_write_address_t;
    {$endif CONFIG_SPI_FLASH_DANGEROUS_WRITE_ALLOWED}
  end;


function spi_flash_wrap_set(mode: Tspi_flash_wrap_mode_t): Tesp_err_t; cdecl; external;

procedure spi_flash_init; cdecl; external;

function spi_flash_get_chip_size: Tsize_t; cdecl; external;

function spi_flash_erase_sector(sector: Tsize_t): Tesp_err_t; cdecl; external;

function spi_flash_erase_range(start_address: Tsize_t; size: Tsize_t): Tesp_err_t;
  cdecl; external;

function spi_flash_write(dest_addr: Tsize_t; src: pointer;
  size: Tsize_t): Tesp_err_t; cdecl; external;

function spi_flash_write_encrypted(dest_addr: Tsize_t; src: pointer;
  size: Tsize_t): Tesp_err_t; cdecl; external;

function spi_flash_read(src_addr: Tsize_t; dest: pointer;
  size: Tsize_t): Tesp_err_t; cdecl; external;

function spi_flash_read_encrypted(src: Tsize_t; dest: pointer;
  size: Tsize_t): Tesp_err_t; cdecl; external;

function spi_flash_mmap(src_addr: Tsize_t; size: Tsize_t;
  memory: Tspi_flash_mmap_memory_t; out_ptr: Ppointer;
  out_handle: Pspi_flash_mmap_handle_t): Tesp_err_t; cdecl; external;

function spi_flash_mmap_pages(pages: int32; page_count: Tsize_t;
  memory: Tspi_flash_mmap_memory_t; out_ptr: Ppointer;
  out_handle: Pspi_flash_mmap_handle_t): Tesp_err_t; cdecl; external;

procedure spi_flash_munmap(handle: Tspi_flash_mmap_handle_t); cdecl; external;

procedure spi_flash_mmap_dump; cdecl; external;

function spi_flash_mmap_get_free_pages(memory: Tspi_flash_mmap_memory_t): uint32;
  cdecl; external;

function spi_flash_cache2phys(cached: pointer): Tsize_t; cdecl; external;

function spi_flash_phys2cache(phys_offs: Tsize_t;
  memory: Tspi_flash_mmap_memory_t): pointer; cdecl; external;

function spi_flash_cache_enabled: longbool; cdecl; external;

procedure spi_flash_enable_cache(cpuid: uint32); cdecl; external;

procedure spi_flash_guard_set(funcs: Pspi_flash_guard_funcs_t); cdecl; external;

function spi_flash_guard_get: Pspi_flash_guard_funcs_t; cdecl; external;

{$ifdef CONFIG_SPI_FLASH_ENABLE_COUNTERS}
type
  Pspi_flash_counter_t = ^Tspi_flash_counter_t;
  Tspi_flash_counter_t = record
    Count: uint32;
    time: uint32;
    bytes: uint32;
  end;

  Pspi_flash_counters_t = ^Tspi_flash_counters_t;

  Tspi_flash_counters_t = record
    Read: Tspi_flash_counter_t;
    Write: Tspi_flash_counter_t;
    erase: Tspi_flash_counter_t;
  end;


procedure spi_flash_reset_counters; cdecl; external;

procedure spi_flash_dump_counters; cdecl; external;

function spi_flash_get_counters: Pspi_flash_counters_t; cdecl; external;
{$endif CONFIG_SPI_FLASH_ENABLE_COUNTERS}

var
  g_flash_guard_default_ops : Tspi_flash_guard_funcs_t; cvar; external;
  g_flash_guard_no_os_ops : Tspi_flash_guard_funcs_t; cvar; external;

implementation

end.
