unit sdspi_host;

interface

{$include sdkconfig.inc}

uses
  esp_err, sdmmc_types, gpio_types,
  spi_types, portmacro;

type
  Psdspi_dev_handle = ^Tsdspi_dev_handle;
  Tsdspi_dev_handle = longint;

{$if defined(CONFIG_IDF_TARGET_ESP32) or defined(CONFIG_IDF_TARGET_ESP32S2)}
const
  SDSPI_DEFAULT_HOST = HSPI_HOST;
{$else}
const
  SDSPI_DEFAULT_HOST = SPI2_HOST;
{$endif}

procedure INIT_SDSPI_HOST_DEFAULT(out sdmmc_host: Tsdmmc_host); inline;

type
  Psdspi_device_config = ^Tsdspi_device_config;
  Tsdspi_device_config = record
    host_id: Tspi_host_device;
    gpio_cs: Tgpio_num;
    gpio_cd: Tgpio_num;
    gpio_wp: Tgpio_num;
    gpio_int: Tgpio_num;
  end;

const
  SDSPI_SLOT_NO_CD = GPIO_NUM_NC;
  SDSPI_SLOT_NO_WP = GPIO_NUM_NC;
  SDSPI_SLOT_NO_INT = GPIO_NUM_NC;

procedure INIT_SDSPI_DEVICE_CONFIG_DEFAULT(out sdspi_device_config: Tsdspi_device_config); inline;

function sdspi_host_init: Tesp_err; external;
function sdspi_host_init_device(dev_config: Psdspi_device_config;
  out_handle: Psdspi_dev_handle): Tesp_err; external;
function sdspi_host_remove_device(handle: Tsdspi_dev_handle): Tesp_err; external;
function sdspi_host_do_transaction(handle: Tsdspi_dev_handle;
  cmdinfo: Psdmmc_command): Tesp_err; external;
function sdspi_host_set_card_clk(host: Tsdspi_dev_handle;
  freq_khz: uint32): Tesp_err; external;
function sdspi_host_deinit: Tesp_err; external;
function sdspi_host_io_int_enable(handle: Tsdspi_dev_handle): Tesp_err; external;
function sdspi_host_io_int_wait(handle: Tsdspi_dev_handle;
  timeouticks: TTickType): Tesp_err; external;

type
  Psdspi_slot_config = ^Tsdspi_slot_config;
  Tsdspi_slot_config = record
    gpio_cs: Tgpio_num;
    gpio_cd: Tgpio_num;
    gpio_wp: Tgpio_num;
    gpio_int: Tgpio_num;
    gpio_miso: Tgpio_num;
    gpio_mosi: Tgpio_num;
    gpio_sck: Tgpio_num;
    dma_channel: longint;
  end;

procedure SDSPI_SLOT_CONFIG_DEFAULT(var sdspi_slot_config: Tsdspi_slot_config); inline;

function sdspi_host_init_slot(slot: longint; slot_config: Psdspi_slot_config): Tesp_err;
  cdecl; external;

implementation

procedure INIT_SDSPI_HOST_DEFAULT(out sdmmc_host: Tsdmmc_host); inline;
begin
  with sdmmc_host do
  begin
    flags := SDMMC_HOST_FLAG_SPI or SDMMC_HOST_FLAG_DEINIT_ARG;
    slot := ord(SDSPI_DEFAULT_HOST);
    max_freq_khz := SDMMC_FREQ_DEFAULT;
    io_voltage := 3.3;
    init := @sdspi_host_init;
    set_bus_width := nil;
    get_bus_width := nil;
    set_bus_ddr_mode := nil;
    set_card_clk := @sdspi_host_set_card_clk;
    do_transaction := @sdspi_host_do_transaction;
    deinit_func.deinit_p := @sdspi_host_remove_device;
    io_int_enable := @sdspi_host_io_int_enable;
    io_int_wait := @sdspi_host_io_int_wait;
    command_timeout_ms := 0;
  end;
end;

procedure INIT_SDSPI_DEVICE_CONFIG_DEFAULT(
  out sdspi_device_config: Tsdspi_device_config);
begin
  with sdspi_device_config do
  begin
    host_id   := SDSPI_DEFAULT_HOST;
    gpio_cs   := GPIO_NUM_13;
    gpio_cd   := SDSPI_SLOT_NO_CD;
    gpio_wp   := SDSPI_SLOT_NO_WP;
    gpio_int  := GPIO_NUM_NC;
  end;
end;

procedure SDSPI_SLOT_CONFIG_DEFAULT(var sdspi_slot_config: Tsdspi_slot_config);
begin
  with sdspi_slot_config do
  begin
    gpio_cs   := GPIO_NUM_13;
    gpio_cd   := SDSPI_SLOT_NO_CD;
    gpio_wp   := SDSPI_SLOT_NO_WP;
    gpio_int  := GPIO_NUM_NC;
    gpio_miso := GPIO_NUM_2;
    gpio_mosi := GPIO_NUM_15;
    gpio_sck  := GPIO_NUM_14;
    dma_channel := 1;
  end;
end;

end.
