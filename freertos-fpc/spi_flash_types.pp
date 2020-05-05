unit spi_flash_types;

interface

uses
  esp_err;

type
  Puint32 = ^uint32;

  Pspi_flash_trans_t = ^Tspi_flash_trans_t;
  Tspi_flash_trans_t = record
    command: byte;
    mosi_len: byte;
    miso_len: byte;
    address_bitlen: byte;
    address: uint32;
    mosi_data: PByte;
    miso_data: PByte;
  end;

  Pesp_flash_speed_t = ^Tesp_flash_speed_t;
  Tesp_flash_speed_t = (ESP_FLASH_5MHZ = 0, ESP_FLASH_10MHZ, ESP_FLASH_20MHZ,
    ESP_FLASH_26MHZ, ESP_FLASH_40MHZ, ESP_FLASH_80MHZ,
    ESP_FLASH_SPEED_MAX);

  Pesp_flash_io_mode_t = ^Tesp_flash_io_mode_t;
  Tesp_flash_io_mode_t = (SPI_FLASH_SLOWRD = 0, SPI_FLASH_FASTRD,
    SPI_FLASH_DOUT, SPI_FLASH_DIO, SPI_FLASH_QOUT,
    SPI_FLASH_QIO, SPI_FLASH_READ_MODE_MAX);

  Pspi_flash_host_driver_t = ^Tspi_flash_host_driver_t;
  Tspi_flash_host_driver_t = record
    driver_data: pointer;
    dev_config: function(driver: Pspi_flash_host_driver_t): Tesp_err_t; cdecl;
    common_command: function(driver: Pspi_flash_host_driver_t;
        t: Pspi_flash_trans_t): Tesp_err_t; cdecl;
    read_id: function(driver: Pspi_flash_host_driver_t;
        id: Puint32): Tesp_err_t; cdecl;
    erase_chip: procedure(driver: Pspi_flash_host_driver_t); cdecl;
    erase_sector: procedure(driver: Pspi_flash_host_driver_t;
        start_address: uint32); cdecl;
    erase_block: procedure(driver: Pspi_flash_host_driver_t;
        start_address: uint32); cdecl;
    read_status: function(driver: Pspi_flash_host_driver_t;
        out_sr: PByte): Tesp_err_t; cdecl;
    set_write_protect: function(driver: Pspi_flash_host_driver_t;
        wp: longbool): Tesp_err_t; cdecl;
    program_page: procedure(driver: Pspi_flash_host_driver_t;
        buffer: pointer; address: uint32; length: uint32); cdecl;
    supports_direct_write: function(driver: Pspi_flash_host_driver_t;
        p: pointer): longbool; cdecl;
    supports_direct_read: function(driver: Pspi_flash_host_driver_t;
        p: pointer): longbool; cdecl;
    max_write_bytes: int32;
    Read: function(driver: Pspi_flash_host_driver_t; buffer: pointer;
        address: uint32; read_len: uint32): Tesp_err_t; cdecl;
    max_read_bytes: int32;
    host_idle: function(driver: Pspi_flash_host_driver_t): longbool; cdecl;
    configure_host_io_mode: function(driver: Pspi_flash_host_driver_t;
        command: uint32; addr_bitlen: uint32; dummy_bitlen_base: int32;
        io_mode: Tesp_flash_io_mode_t): Tesp_err_t; cdecl;
    poll_cmd_done: procedure(driver: Pspi_flash_host_driver_t); cdecl;
    flush_cache: function(driver: Pspi_flash_host_driver_t;
        addr: uint32; size: uint32): Tesp_err_t; cdecl;
  end;

const
  ESP_FLASH_SPEED_MIN = ESP_FLASH_5MHZ;
  SPI_FLASH_READ_MODE_MIN = SPI_FLASH_SLOWRD;

implementation

end.
