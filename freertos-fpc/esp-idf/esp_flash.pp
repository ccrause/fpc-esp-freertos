unit esp_flash;

interface

uses
  esp_err, spi_flash_types;

type
  Pbool = ^Tbool;
  Tbool = longbool;
  Puint32 = ^uint32;

  Pspi_flash_chip = ^Tspi_flash_chip;
  Tspi_flash_chip = record end;

  Pesp_flash_region = ^Tesp_flash_region;
  Tesp_flash_region = record
    offset: uint32;
    size: uint32;
  end;

  Pesp_flash_os_functions = ^Tesp_flash_os_functions;
  Tesp_flash_os_functions = record
    start: function(arg: pointer): Tesp_err; cdecl;
    end_: function(arg: pointer): Tesp_err; cdecl;
    region_protected: function(arg: pointer; start_addr: Tsize;
        size: Tsize): Tesp_err; cdecl;
    delay_ms: function(arg: pointer; ms: uint32): Tesp_err; cdecl;
  end;

  Pesp_flash = ^Tesp_flash;
  Tesp_flash = record
    host: Pspi_flash_host_driver;
    chip_drv: Pspi_flash_chip;
    os_func: Pesp_flash_os_functions;
    os_func_data: pointer;
    read_mode: Tesp_flash_io_mode;
    size: uint32;
    chip_id: uint32;
  end;

function esp_flash_init(chip: Pesp_flash): Tesp_err; cdecl; external;

function esp_flash_chip_driver_initialized(chip: Pesp_flash): Tbool; cdecl; external;

function esp_flash_read_id(chip: Pesp_flash; out_id: Puint32): Tesp_err;
  cdecl; external;

function esp_flash_get_size(chip: Pesp_flash; out_size: Puint32): Tesp_err;
  cdecl; external;

function esp_flash_erase_chip(chip: Pesp_flash): Tesp_err; cdecl; external;

function esp_flash_erase_region(chip: Pesp_flash; start: uint32;
  len: uint32): Tesp_err; cdecl; external;

function esp_flash_get_chip_write_protect(chip: Pesp_flash;
  write_protected: Pbool): Tesp_err; cdecl; external;

function esp_flash_set_chip_write_protect(chip: Pesp_flash;
  write_protect: Tbool): Tesp_err; cdecl; external;

function esp_flash_get_protectable_regions(chip: Pesp_flash;
  out_regions: Pesp_flash_region; out_num_regions: Puint32): Tesp_err; cdecl; external;

function esp_flash_get_protected_region(chip: Pesp_flash;
  region: Pesp_flash_region; out_protected: Pbool): Tesp_err; cdecl; external;

function esp_flash_set_protected_region(chip: Pesp_flash;
  region: Pesp_flash_region; protect: Tbool): Tesp_err; cdecl; external;

function esp_flash_read(chip: Pesp_flash; buffer: pointer; address: uint32;
  length: uint32): Tesp_err; cdecl; external;

function esp_flash_write(chip: Pesp_flash; buffer: pointer; address: uint32;
  length: uint32): Tesp_err; cdecl; external;

function esp_flash_write_encrypted(chip: Pesp_flash; address: uint32;
  buffer: pointer; length: uint32): Tesp_err; cdecl; external;

function esp_flash_read_encrypted(chip: Pesp_flash; address: uint32;
  out_buffer: pointer; length: uint32): Tesp_err; cdecl; external;

var
  esp_flash_default_chip : Pesp_flash; cvar; external;

// Macro not converted:
// static inline bool esp_flash_is_quad_mode(const esp_flash_t *chip)
//    return (chip->read_mode == SPI_FLASH_QIO) || (chip->read_mode == SPI_FLASH_QOUT);

implementation

end.
