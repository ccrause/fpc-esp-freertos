unit sdmmc_cmd;

interface

uses
  esp_err, sdmmc_types, portmacro;

type
  PFILE = ^TFILE;
  TFILE = pointer;

  Psdmmc_card = ^Tsdmmc_card;
  Psdmmc_host = ^Tsdmmc_host;
  Psize = ^Tsize;

function sdmmc_card_init(host: Psdmmc_host; out_card: Psdmmc_card): Tesp_err;
  external;

procedure sdmmc_card_print_info(stream: PFILE; card: Psdmmc_card); external;

function sdmmc_write_sectors(card: Psdmmc_card; src: pointer;
  start_sector: Tsize; sector_count: Tsize): Tesp_err; external;

function sdmmc_read_sectors(card: Psdmmc_card; dst: pointer;
  start_sector: Tsize; sector_count: Tsize): Tesp_err; external;

function sdmmc_io_read_byte(card: Psdmmc_card; _function: uint32;
  reg: uint32; out_byte: Puint8): Tesp_err; external;

function sdmmc_io_write_byte(card: Psdmmc_card; _function: uint32;
  reg: uint32; in_byte: byte; out_byte: Pbyte): Tesp_err; external;

function sdmmc_io_read_bytes(card: Psdmmc_card; _function: uint32;
  addr: uint32; dst: pointer; size: Tsize): Tesp_err; external;

function sdmmc_io_write_bytes(card: Psdmmc_card; _function: uint32;
  addr: uint32; src: pointer; size: Tsize): Tesp_err; external;

function sdmmc_io_read_blocks(card: Psdmmc_card; _function: uint32;
  addr: uint32; dst: pointer; size: Tsize): Tesp_err; external;

function sdmmc_io_write_blocks(card: Psdmmc_card; _function: uint32;
  addr: uint32; src: pointer; size: Tsize): Tesp_err; external;

function sdmmc_io_enable_int(card: Psdmmc_card): Tesp_err; external;

function sdmmc_io_wait_int(card: Psdmmc_card; timeout_ticks: TTickType): Tesp_err;
  external;

function sdmmc_io_get_cis_data(card: Psdmmc_card; out_buffer: PByte;
  buffer_size: Tsize; inout_cis_size: Psize): Tesp_err; external;

function sdmmc_io_print_cis_info(buffer: Pbyte; buffer_size: Tsize;
  fp: PFILE): Tesp_err; external;

implementation


end.
