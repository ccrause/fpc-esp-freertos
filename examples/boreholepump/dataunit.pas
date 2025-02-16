unit dataunit;

{ This unit hosts global current and time series data and
  implementas data logging via SD card. }

interface

uses
  semphr;

const
  mount_point = '/sd';
  logfile = mount_point + '/data.csv';

var
  dataSem: TSemaphoreHandle;
  dataIndex: integer;
  currentLevel: integer;
  currentFlow: single;
  // History saved every minute
  // Buffers sized for 1440 points = 24 hours
  // Scale 6016 - 198 mm
  levels: array[0..1439] of uint32;
  // Scale 0 - 300 dL/min
  flows: array[0..1439] of uint32;

procedure logToFile(const ALevel: integer; const AFlow: single);

implementation

uses
  timeunit, hardwareconfig, esp_vfs_fat, sdmmc_types, spi_common, esp_err,
  spi_types, sdspi_host, gpio_types,
  c_filehandling; // required to register file handling based on libC

var
  bus_cfg: Tspi_bus_config;  // For some reason this cannot be a local variable, the fields are read incorrectly

procedure logToFile(const ALevel: integer; const AFlow: single);
var
  mountConfig: Tesp_vfs_fat_sdmmc_mount_config;
  card: Psdmmc_card;
  ret: Tesp_err;
  host: Tsdmmc_host;
  slot_config: Tsdspi_device_config;
  f: TextFile;
  tmp: string[20]; // 2024/12/22 10:14:33
  ioRes: word;
begin
  mountConfig.format_if_mount_failed := false;
  mountConfig.max_files := 2;
  mountConfig.allocation_unit_size := 16 * 1024;

  INIT_SDSPI_HOST_DEFAULT(host);
  with bus_cfg do
  begin
    mosi_io_num := sdMOSIpin;
    miso_io_num := sdMISOpin;
    sclk_io_num := sdCLKpin;
    quadwp_io_num := -1;
    quadhd_io_num := -1;
    max_transfer_sz := 4000;
  end;

  if EspErrorCheck( spi_bus_initialize(Tspi_host_device(host.slot), @bus_cfg, SPI_DMA_CH1), 'spi_bus_initialize') then
  begin
    // This initializes the slot without card detect (CD) and write protect (WP) signals.
    // Modify slot_config.gpio_cd and slot_config.gpio_wp if your board has these signals.
    INIT_SDSPI_DEVICE_CONFIG_DEFAULT(slot_config);
    slot_config.gpio_cs := Tgpio_num(sdCSpin);
    slot_config.host_id := tspi_host_device(host.slot);

    if EspErrorCheck(esp_vfs_fat_sdspi_mount(mount_point, @host, @slot_config, @mountConfig, @card), 'esp_vfs_fat_sdspi_mount') then
    begin
      {$push}{$I-} // disable runtime I/O errors
      AssignFile(f, logfile);
      Append(f);
      ioRes := IOResult;
      // If file doesn't exist, create it
      if ioRes = 2 then
      begin
        writeln('File doesn''t exist, creating new file');
        Rewrite(f);
        ioRes := IOResult;
      end;

      if ioRes = 0 then
      begin
        currentTimeAsString(tmp);
        writeln(f, tmp, ',', Alevel,',', Aflow);
      end
      else
        writeln('IO error ', ioRes, ', no data written to log file');

      CloseFile(f);
      ioRes := IOResult;
      if ioRes > 0 then
        writeln('IO error ', ioRes, ' when closing log file');
      {$pop} // restore previous runtime error state

      EspErrorCheck(esp_vfs_fat_sdcard_unmount(mount_point, card), 'esp_vfs_fat_sdcard_unmount');
    end;  // esp_vfs_fat_sdspi_mount

    EspErrorCheck(spi_bus_free(Tspi_host_device(host.slot)), 'spi_bus_free');
  end;  // spi_bus_initialize
end;

end.

