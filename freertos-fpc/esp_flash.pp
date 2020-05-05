unit esp_flash;

interface

uses
  esp_err, spi_flash_types;

type
  Pbool = ^Tbool;
  Tbool = longbool;
  Puint32_t = ^uint32;

  Pspi_flash_chip_t = ^Tspi_flash_chip_t;
  Tspi_flash_chip_t = record end;

  Pesp_flash_region_t = ^Tesp_flash_region_t;
  Tesp_flash_region_t = record
    offset: uint32;
    size: uint32;
  end;

  Pesp_flash_os_functions_t = ^Tesp_flash_os_functions_t;
  Tesp_flash_os_functions_t = record
    start: function(arg: pointer): Tesp_err_t; cdecl;
    end_: function(arg: pointer): Tesp_err_t; cdecl;
    region_protected: function(arg: pointer; start_addr: Tsize_t;
        size: Tsize_t): Tesp_err_t; cdecl;
    delay_ms: function(arg: pointer; ms: uint32): Tesp_err_t; cdecl;
  end;

  Pesp_flash_t = ^Tesp_flash_t;
  Tesp_flash_t = record
    host: Pspi_flash_host_driver_t;
    chip_drv: Pspi_flash_chip_t;
    os_func: Pesp_flash_os_functions_t;
    os_func_data: pointer;
    read_mode: Tesp_flash_io_mode_t;
    size: uint32;
    chip_id: uint32;
  end;

function esp_flash_init(chip: Pesp_flash_t): Tesp_err_t; cdecl; external;

function esp_flash_chip_driver_initialized(chip: Pesp_flash_t): Tbool; cdecl; external;

function esp_flash_read_id(chip: Pesp_flash_t; out_id: Puint32_t): Tesp_err_t;
  cdecl; external;

function esp_flash_get_size(chip: Pesp_flash_t; out_size: Puint32_t): Tesp_err_t;
  cdecl; external;

function esp_flash_erase_chip(chip: Pesp_flash_t): Tesp_err_t; cdecl; external;

function esp_flash_erase_region(chip: Pesp_flash_t; start: uint32;
  len: uint32): Tesp_err_t; cdecl; external;

function esp_flash_get_chip_write_protect(chip: Pesp_flash_t;
  write_protected: Pbool): Tesp_err_t; cdecl; external;

function esp_flash_set_chip_write_protect(chip: Pesp_flash_t;
  write_protect: Tbool): Tesp_err_t; cdecl; external;

function esp_flash_get_protectable_regions(chip: Pesp_flash_t;
  out_regions: Pesp_flash_region_t; out_num_regions: Puint32_t): Tesp_err_t; cdecl; external;

function esp_flash_get_protected_region(chip: Pesp_flash_t;
  region: Pesp_flash_region_t; out_protected: Pbool): Tesp_err_t; cdecl; external;

function esp_flash_set_protected_region(chip: Pesp_flash_t;
  region: Pesp_flash_region_t; protect: Tbool): Tesp_err_t; cdecl; external;

function esp_flash_read(chip: Pesp_flash_t; buffer: pointer; address: uint32;
  length: uint32): Tesp_err_t; cdecl; external;

function esp_flash_write(chip: Pesp_flash_t; buffer: pointer; address: uint32;
  length: uint32): Tesp_err_t; cdecl; external;

function esp_flash_write_encrypted(chip: Pesp_flash_t; address: uint32;
  buffer: pointer; length: uint32): Tesp_err_t; cdecl; external;

function esp_flash_read_encrypted(chip: Pesp_flash_t; address: uint32;
  out_buffer: pointer; length: uint32): Tesp_err_t; cdecl; external;

var
  esp_flash_default_chip : Pesp_flash_t; cvar; external;

// Macro not converted:
// static inline bool esp_flash_is_quad_mode(const esp_flash_t *chip)
//    return (chip->read_mode == SPI_FLASH_QIO) || (chip->read_mode == SPI_FLASH_QOUT);

implementation

end.
