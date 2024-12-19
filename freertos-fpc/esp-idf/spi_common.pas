unit spi_common;

interface

uses
  esp_err, spi_types;

const
  SPI_MAX_DMA_LEN = 4096 - 4;
  SPICOMMON_BUSFLAG_SLAVE = 0;
  SPICOMMON_BUSFLAG_MASTER = 1 shl 0;
  SPICOMMON_BUSFLAG_IOMUX_PINS = 1 shl 1;
  SPICOMMON_BUSFLAG_GPIO_PINS = 1 shl 2;
  SPICOMMON_BUSFLAG_SCLK = 1 shl 3;
  SPICOMMON_BUSFLAG_MISO = 1 shl 4;
  SPICOMMON_BUSFLAG_MOSI = 1 shl 5;
  SPICOMMON_BUSFLAG_DUAL = 1 shl 6;
  SPICOMMON_BUSFLAG_WPHD = 1 shl 7;
  SPICOMMON_BUSFLAG_QUAD = SPICOMMON_BUSFLAG_DUAL or SPICOMMON_BUSFLAG_WPHD;
  SPICOMMON_BUSFLAG_NATIVE_PINS = SPICOMMON_BUSFLAG_IOMUX_PINS;

function SPI_SWAP_DATA_TX(Data, LEN: longint): longint;
function SPI_SWAP_DATA_RX(Data, LEN: longint): longint;

type
  Pspi_common_dma = ^Tspi_common_dma;
  Tspi_common_dma = (
    SPI_DMA_DISABLED := 0,
    SPI_DMA_CH1 := 1,
    SPI_DMA_CH2 := 2,
    SPI_DMA_CH_AUTO := 3);

  Pspi_dma_chan = ^Tspi_dma_chan;
  Tspi_dma_chan = Tspi_common_dma;

  Pspi_bus_config = ^Tspi_bus_config;
  Tspi_bus_config = record
    mosi_io_num: longint;
    miso_io_num: longint;
    sclk_io_num: longint;
    quadwp_io_num: longint;
    quadhd_io_num: longint;
    max_transfer_sz: longint;
    flags: uint32;
    intr_flags: longint;
  end;

function spi_bus_initialize(host_id: Tspi_host_device; bus_config: Pspi_bus_config;
  dma_chan: Tspi_dma_chan): Tesp_err; external;

function spi_bus_free(host_id: Tspi_host_device): Tesp_err; external;

implementation

function SPI_SWAP_DATA_TX(Data, LEN: longint): longint;
begin
  Result := NToBE(Data) shl (32 - LEN);
end;

function SPI_SWAP_DATA_RX(Data, LEN: longint): longint;
begin
  Result := BEToN(Data) shr (32 - LEN);
end;

end.
