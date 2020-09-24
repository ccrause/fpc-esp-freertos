unit esp_app_format;

{$modeswitch advancedrecords}
{$inline on}

interface

const
  ESP_IMAGE_HEADER_MAGIC     = $E9;
  ESP_IMAGE_MAX_SEGMENTS     = 16;
  ESP_APP_DESC_MAGIC_WORD    = $ABCD5432;

type
  {$push}
  {$packenum 2} // Force the size of this enum to 16 bits
  Tesp_chip_id = (ESP_CHIP_ID_ESP32 = $0000,
    ESP_CHIP_ID_INVALID = $FFFF);
  {$pop}

  Tesp_image_spi_mode = (ESP_IMAGE_SPI_MODE_QIO,
    ESP_IMAGE_SPI_MODE_QOUT,
    ESP_IMAGE_SPI_MODE_DIO,
    ESP_IMAGE_SPI_MODE_DOUT,
    ESP_IMAGE_SPI_MODE_FAST_READ,
    ESP_IMAGE_SPI_MODE_SLOW_READ);

  Tesp_image_spi_freq = (ESP_IMAGE_SPI_SPEED_40M,
    ESP_IMAGE_SPI_SPEED_26M,
    ESP_IMAGE_SPI_SPEED_20M,
    ESP_IMAGE_SPI_SPEED_80M = $f);

  Tesp_image_flash_size_t = (ESP_IMAGE_FLASH_SIZE_1MB = 0,
    ESP_IMAGE_FLASH_SIZE_2MB,
    ESP_IMAGE_FLASH_SIZE_4MB,
    ESP_IMAGE_FLASH_SIZE_8MB,
    ESP_IMAGE_FLASH_SIZE_16MB,
    ESP_IMAGE_FLASH_SIZE_MAX);

  TBitRange4 = 0..15;
  Tesp_image_header = packed record
  private
    function get_spi_speed: TBitRange4; inline;
    procedure set_spi_speed(speed:TBitRange4); inline;
    function get_spi_size: TBitRange4; inline;
    procedure set_spi_size(size: TBitRange4); inline;
  public
    magic: byte;
    segment_count: byte;
    spi_mode: byte;
    _spi_speed_size: byte;
    entry_addr: uint32;
    wp_pin: byte;
    spi_pin_drv: array[0..2] of byte;
    chip_id: Tesp_chip_id;
    min_chip_rev: byte;
    reserved: array[0..7] of byte;
    hash_appended: byte;
    property spi_speed: TBitRange4 read get_spi_speed write set_spi_speed;
    property spi_size: TBitRange4 read get_spi_size write set_spi_size;
  end;

  Tesp_image_segment_header = record
    load_addr,
    data_len: uint32;
  end;

  Pesp_app_desc = ^Tesp_app_desc;
  Tesp_app_desc = record
    magic_word: uint32;
    secure_version: uint32;
    reserv1: array[0..1] of uint32;
    version: array[0..31] of char;
    project_name: array[0..31] of char;
    time: array[0..15] of char;
    date: array[0..15] of char;
    idf_ver: array[0..31] of char;
    app_elf_sha256: array[0..31] of byte;
    reserv2: array[0..19] of uint32;
  end;

implementation

// Binary size checks
const
  Tesp_chip_id_sz = sizeof(Tesp_chip_id);
  {$if Tesp_chip_id_sz <> 2}
    {$Error 'SizeOf(Tesp_chip_id) should be exactly 2 bytes'}
  {$endif}

  Tesp_image_header_sz = sizeof(Tesp_image_header);
  {$if Tesp_image_header_sz <> 24}
    {$Error 'SizeOf(Tesp_image_header) should be exactly 24 bytes'}
  {$endif}

  Tesp_app_desc_sz = sizeof(Tesp_app_desc);
  {$if Tesp_app_desc_sz <> 256}
    {$Error 'SizeOf(Tesp_app_desc) should be exactly 256 bytes'}
  {$endif}

function Tesp_image_header.get_spi_speed: TBitRange4;
begin
  result := _spi_speed_size and $f;
end;

procedure Tesp_image_header.set_spi_speed(speed: TBitRange4);
begin
  _spi_speed_size := (_spi_speed_size and $f0) or speed;
end;

function Tesp_image_header.get_spi_size: TBitRange4;
begin
  result := (_spi_speed_size shr 4);
end;

procedure Tesp_image_header.set_spi_size(size: TBitRange4);
begin
  _spi_speed_size := (_spi_speed_size and $0f) or byte(size shl 4);
end;

end.
