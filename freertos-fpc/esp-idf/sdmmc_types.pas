unit sdmmc_types;

{$modeswitch advancedrecords}
{$linklib sdmmc, static}

interface

uses
  esp_err, portmacro;

type
  Psdmmc_csd = ^Tsdmmc_csd;

  Tsdmmc_csd = record
    csd_ver: longint;
    mmc_ver: longint;
    capacity: longint;
    sector_size: longint;
    read_block_len: longint;
    card_command_class: longint;
    tr_speed: longint;
  end;

  Psdmmc_cid = ^Tsdmmc_cid;

  Tsdmmc_cid = record
    mfg_id: longint;
    oem_id: longint;
    Name: array[0..7] of char;
    revision: longint;
    serial: longint;
    date: longint;
  end;


  Psdmmc_scr = ^Tsdmmc_scr;
  Tsdmmc_scr = record
    sd_spec: longint;
    bus_width: longint;
  end;


  Psdmmc_ext_csd = ^Tsdmmc_ext_csd;
  Tsdmmc_ext_csd = record
    power_class: byte;
  end;


  Psdmmc_response = ^Tsdmmc_response;
  Tsdmmc_response = array[0..3] of uint32;


  Psdmmc_switch_func_rsp = ^Tsdmmc_switch_func_rsp;
  Tsdmmc_switch_func_rsp = record
    Data: array[0..((512 div 8) div (sizeof(uint32))) - 1] of uint32;
  end;

  //SCF_CMD(flags)  = ((flags) & $00f0)

const
  SCF_ITSDONE     = $0001;
  SCF_CMD_AC      = $0000;
  SCF_CMD_ADTC    = $0010;
  SCF_CMD_BC      = $0020;
  SCF_CMD_BCR     = $0030;
  SCF_CMD_READ    = $0040;
  SCF_RSP_BSY     = $0100;
  SCF_RSP_136     = $0200;
  SCF_RSP_CRC     = $0400;
  SCF_RSP_IDX     = $0800;
  SCF_RSP_PRESENT = $1000;
  // response types
  SCF_RSP_R0     =  0;
  SCF_RSP_R1     =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX);
  SCF_RSP_R1B    =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX or SCF_RSP_BSY);
  SCF_RSP_R2     =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_136);
  SCF_RSP_R3     =  (SCF_RSP_PRESENT);
  SCF_RSP_R4     =  (SCF_RSP_PRESENT);
  SCF_RSP_R5     =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX);
  SCF_RSP_R5B    =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX or SCF_RSP_BSY);
  SCF_RSP_R6     =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX);
  SCF_RSP_R7     =  (SCF_RSP_PRESENT or SCF_RSP_CRC or SCF_RSP_IDX);
  // special flags
  SCF_WAIT_BUSY  =  $2000;

  SDMMC_HOST_FLAG_1BIT       = 1 shl 0;
  SDMMC_HOST_FLAG_4BIT       = 1 shl 1;
  SDMMC_HOST_FLAG_8BIT       = 1 shl 2;
  SDMMC_HOST_FLAG_SPI        = 1 shl 3;
  SDMMC_HOST_FLAG_DDR        = 1 shl 4;
  SDMMC_HOST_FLAG_DEINIT_ARG = 1 shl 5;
  SDMMC_FREQ_DEFAULT         = 20000;
  SDMMC_FREQ_HIGHSPEED       = 40000;
  SDMMC_FREQ_PROBING         = 400;
  SDMMC_FREQ_52M             = 52000;
  SDMMC_FREQ_26M             = 26000;

type
  Psdmmc_command = ^Tsdmmc_command;
  Tsdmmc_command = record
    opcode: uint32;
    arg: uint32;
    response: Tsdmmc_response;
    data: pointer;
    datalen: int32;
    blklen: int32;
    flags: integer;
    error: Tesp_err;
    timeout_ms: integer;
  end;

  Tsdmmc_init_func = function: tesp_err;
  Psdmmc_host = ^Tsdmmc_host;

  Tsmmc_deinit_func = record
    case boolean of
    true: (
      //esp_err_t (*deinit)(void);  /*!< host function to deinitialize the driver */
      deinit: function (): Tesp_err;);
    false: (
      //esp_err_t (*deinit_p)(int slot);  /*!< host function to deinitialize the driver, called with the `slot` */
      deinit_p: function (slot: integer): Tesp_err;);
  end;

  Tsdmmc_host = record
    flags: uint32;
    slot: integer;
    max_freq_khz: integer;
    io_voltage: single;   // float, confirm size
    init: function: Tesp_err;
    //esp_err_t (*set_bus_width)(int slot, size_t width);    /*!< host function to set bus width */
    set_bus_width: function (slot: integer; width: int32): Tesp_err;

    //size_t (*get_bus_width)(int slot); /*!< host function to get bus width */
    get_bus_width: function (slot: integer): int32;

    //esp_err_t (*set_bus_ddr_mode)(int slot, bool ddr_enable); /*!< host function to set DDR mode */
    set_bus_ddr_mode: function (slot: integer; ddr_enable: longbool): Tesp_err;

    //esp_err_t (*set_card_clk)(int slot, uint32_t freq_khz); /*!< host function to set card clock frequency */
    set_card_clk: function (slot: integer; freq_khz: uint32): Tesp_err;

    //esp_err_t (*do_transaction)(int slot, sdmmc_command_t* cmdinfo);    /*!< host function to do a transaction */
    do_transaction: function (slot: integer; cmdinfo: Psdmmc_command): Tesp_err;

    //union {
    //    esp_err_t (*deinit)(void);  /*!< host function to deinitialize the driver */
    //    esp_err_t (*deinit_p)(int slot);  /*!< host function to deinitialize the driver, called with the `slot` */
    //};
    deinit_func: Tsmmc_deinit_func;

    //esp_err_t (*io_int_enable)(int slot); /*!< Host function to enable SDIO interrupt line */
    io_int_enable: function (slot: integer): Tesp_err;

    //esp_err_t (*io_int_wait)(int slot, TickType_t timeout_ticks); /*!< Host function to wait for SDIO interrupt line to be active */
    io_int_wait: function (slot: integer; timeout_ticks: TTickType): Tesp_err;

    command_timeout_ms: integer;
  end;


  Tsdmmc_cid_temp = record
    case boolean of
      true: (cid: Tsdmmc_cid);
      false: (raw_cid: Tsdmmc_response);
  end;

  TBitRange2 = 0..3;
  TBitRange3 = 0..7;

  { Tsdmmc_card }

  Tsdmmc_card = record
  private
    function get_is_mem: boolean; inline;
    function get_is_sdio: boolean; inline;
    function get_is_mmc: boolean; inline;
    function get_num_io_functions: TBitRange3; inline;
    function get_log_bus_width: TBitRange2; inline;
    function get_is_ddr: boolean; inline;
    procedure set_is_mem(const avalue: boolean); inline;
    procedure set_is_sdio(const avalue: boolean); inline;
    procedure set_is_mmc(const avalue: boolean); inline;
    procedure set_num_io_functions(const avalue: TBitRange3); inline;
    procedure set_log_bus_width(const avalue: TBitRange2); inline;
    procedure set_is_ddr(const avalue: boolean); inline;
 public
    host: Tsdmmc_host;
    ocr: uint32;
    //union {
    //    sdmmc_cid_t cid;            /*!< decoded CID (Card IDentification) register value */
    //    sdmmc_response_t raw_cid;   /*!< raw CID of MMC card to be decoded
    //                                     after the CSD is fetched in the data transfer mode*/
    //};
    cid_temp: Tsdmmc_cid_temp;
    csd: Tsdmmc_csd;
    scr: Tsdmmc_scr;
    ext_csd: Tsdmmc_ext_csd;
    rca: uint16;
    max_freq_khz: uint16;

    _capabilities_: uint32;
    //uint32_t is_mem : 1;
    //uint32_t is_sdio : 1;
    //uint32_t is_mmc : 1;
    //uint32_t num_io_functions : 3;
    //uint32_t log_bus_width : 2;
    //uint32_t is_ddr : 1;
    //uint32_t reserved : 23;
    property is_mem: boolean read get_is_mem write set_is_mem;
    property is_sdio: boolean read get_is_sdio write set_is_sdio;
    property is_mmc: boolean read get_is_mmc write set_is_mmc;
    property num_io_functions: TBitRange3 read get_num_io_functions write set_num_io_functions;
    property log_bus_width: TBitRange2 read get_log_bus_width write set_log_bus_width;
    property is_ddr: boolean read get_is_ddr write set_is_ddr;
  end;
  Psdmmc_card = ^Tsdmmc_card;
  PPsdmmc_card = ^Psdmmc_card;

implementation

{ Tsdmmc_card }

function Tsdmmc_card.get_is_mem: boolean;
begin
  Result := boolean(_capabilities_ and 1);
end;

function Tsdmmc_card.get_is_sdio: boolean;
begin
  Result := boolean((_capabilities_ shr 1) and 1);
end;

function Tsdmmc_card.get_is_mmc: boolean;
begin
  Result := boolean((_capabilities_ shr 2) and 1);
end;

function Tsdmmc_card.get_num_io_functions: TBitRange3;
begin
  Result := (_capabilities_ shr 3) and 7;
end;

function Tsdmmc_card.get_log_bus_width: TBitRange2;
begin
  Result := (_capabilities_ shr 6) and 3;
end;

function Tsdmmc_card.get_is_ddr: boolean;
begin
  Result := boolean((_capabilities_ shr 8) and 1);
end;

procedure Tsdmmc_card.set_is_mem(const avalue: boolean);
begin
  _capabilities_ := (_capabilities_ and $FFFFFFFE) or ord(avalue);
end;

procedure Tsdmmc_card.set_is_sdio(const avalue: boolean);
begin
  _capabilities_ := (_capabilities_ and $FFFFFFFD) or (ord(avalue) shl 1);
end;

procedure Tsdmmc_card.set_is_mmc(const avalue: boolean);
begin
  _capabilities_ := (_capabilities_ and $FFFFFFFB) or (ord(avalue) shl 2);
end;

procedure Tsdmmc_card.set_num_io_functions(const avalue: TBitRange3);
begin
  _capabilities_ := (_capabilities_ and $FFFFFFC7) or (avalue shl 3);
end;

procedure Tsdmmc_card.set_log_bus_width(const avalue: TBitRange2);
begin
  _capabilities_ := (_capabilities_ and $FFFFFF3F) or (avalue shl 6);
end;

procedure Tsdmmc_card.set_is_ddr(const avalue: boolean);
begin
  _capabilities_ := (_capabilities_ and $FFFFFEFF) or (ord(avalue) shl 8);
end;

end.
