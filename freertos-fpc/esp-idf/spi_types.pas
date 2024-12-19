unit spi_types;

{$include sdkconfig.inc}

interface

uses
  esp_bit_defs;

type
  Pspi_host_device = ^Tspi_host_device;
  Tspi_host_device = (
    SPI1_HOST := 0,
    SPI2_HOST := 1,
    SPI3_HOST := 2);

  Pspi_event = ^Tspi_event;
  Tspi_event = (
    SPI_EV_BUF_TX := BIT0,
    SPI_EV_BUF_RX := BIT1,
    SPI_EV_SEND_DMA_READY := BIT2,
    SPI_EV_SEND := BIT3,
    SPI_EV_RECV_DMA_READY := BIT4,
    SPI_EV_RECV := BIT5,
    SPI_EV_CMD9 := BIT6,
    SPI_EV_CMDA := BIT7,
    SPI_EV_TRANS := BIT8);

  Tspi_line_mode = record
    cmd_lines: byte;
    addr_lines: byte;
    data_lines: byte;
  end;

  Pspi_command = ^Tspi_command;
  Tspi_command = (
    SPI_CMD_HD_WRBUF := BIT0,
    SPI_CMD_HD_RDBUF := BIT1,
    SPI_CMD_HD_WRDMA := BIT2,
    SPI_CMD_HD_RDDMA := BIT3,
    SPI_CMD_HD_SEG_END := BIT4,
    SPI_CMD_HD_EN_QPI := BIT5,
    SPI_CMD_HD_WR_END := BIT6,
    SPI_CMD_HD_INT0 := BIT7,
    SPI_CMD_HD_INT1 := BIT8,
    SPI_CMD_HD_INT2 := BIT9);

const
  {$ifdef CONFIG_IDF_TARGET_ESP32}
  SPI_HOST = SPI1_HOST;
  HSPI_HOST = SPI2_HOST;
  VSPI_HOST = SPI3_HOST;
  {$elseif defined(CONFIG_IDF_TARGET_ESP32S2)}
  SPI_HOST = SPI1_HOST;
  FSPI_HOST = SPI2_HOST;
  HSPI_HOST = SPI3_HOST;
  {$endif}

implementation

end.
