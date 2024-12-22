program sdcarddemo;

uses
  gpio, task, portmacro, spi_common, sdspi_host,
  esp_vfs_fat, sdmmc_types, esp_err, spi_types, c_dirent,
  c_filehandling, rtc_wdt, esp_log
  {$ifdef CPULX6}
  , gpio_types
  {$endif}
  ;

const
  mount_point = '/sd';
  outputfile = mount_point + '/out.txt';
  // SPI pin definitions for communication with SD card
  PIN_NUM_MISO  = 18;
  PIN_NUM_MOSI  = 16;
  PIN_NUM_CLK   = 17;
  PIN_NUM_CS    = 4;

var
  mountConfig: Tesp_vfs_fat_sdmmc_mount_config;
  card: Psdmmc_card;
  bus_cfg: Tspi_bus_config;
  ret: Tesp_err;
  host: Tsdmmc_host;
  slot_config: Tsdspi_device_config;

  // LibC global error number variable
  errno: integer; external Name '__errno';

procedure printSDCardInfo(acard: Psdmmc_card);
begin
  writeln('Card info.');
  with acard^ do
  begin
    with host do
    begin
      writeln('host:');
      writeln('  flags: ', flags);
      writeln('  slot: ', slot);
      writeln('  max_freq_khz: ', max_freq_khz);
      writeln('  io_voltage: ', io_voltage);
      writeln('  command_timeout_ms: ', command_timeout_ms);
    end;

    writeln('ocr: ', ocr);
    writeln('cid:');
    with cid_temp.cid do
    begin
      writeln('  mfg_id: ', HexStr(qword(mfg_id), 4));
      writeln('  oem_id: ', char(oem_id shr 8), char(oem_id));
      writeln('  Name: ', Name);
      writeln('  revision: ', revision);
      writeln('  serial: ', serial);
      writeln('  date: ', date);
    end;

    writeln('csd:');
    with csd do
    begin
      writeln('  csd_ver: ', csd_ver);
      writeln('  mmc_ver: ', mmc_ver);
      writeln('  capacity: ', capacity);
      writeln('  sector_size: ', sector_size);
      writeln('  read_block_len: ', read_block_len);
      writeln('  card_command_class: ', card_command_class);
      writeln('  tr_speed: ', tr_speed);
    end;

    writeln('scr');
    with scr do
    begin
      writeln('  sd_spec: ', sd_spec);
      writeln('  bus_width: ', bus_width);
    end;
    writeln('ext_csd.power_class: ', ext_csd.power_class);
    writeln('rca: ', rca);
    writeln('max_freq_khz: ', max_freq_khz);
    writeln('Capabilities ($', HexStr(_capabilities_, 8), '):');
    writeln('is_mem: ', is_mem);
    writeln('is_sdio: ', is_sdio);
    writeln('is_mmc: ', is_mmc);
    writeln('num_io_functions: ', num_io_functions);
    writeln('log_bus_width: ', log_bus_width);
    writeln('is_ddr: ', is_ddr);
  end;
end;

procedure listRoot;
var
  entrypath: shortstring;
  dir_entry: Pdirent;
  dir: PDIR;
  statinfo: Tstat;
  res: int32;
begin
  entrypath := MOUNT_POINT;
  dir := opendir(MOUNT_POINT);
  if (dir = nil) then
  begin
    writeln('Failed to stat dir : ', entrypath, '. Error: ', errno);
    exit;
  end
  else
    writeln('Success: stat dir ', entrypath);

  dir_entry := readdir(dir);
  while (dir_entry <> nil) do
  begin
    entrypath := MOUNT_POINT + '/' + PChar(@dir_entry^.d_name[0]);
    write(entrypath, ', ');

    res := integer(stat(PChar(@entrypath[1]), @statinfo));
    if res <> 0 then
      writeln('Error calling stat: ', res, '. Error: ', errno)
    else
    begin
      write('  mode    = ', statinfo.st_mode);
      case statinfo.st_mode and S_IFMT of
        S_IFDIR : writeln('(directory)');
        S_IFCHR : writeln('(character device)');
        S_IFBLK : writeln('(block device)');
        S_IFREG : writeln('(file)');
        S_IFLNK : writeln('(link)');
        S_IFSOCK: writeln('(socket)');
        S_IFIFO : writeln('(FIFO)');
      end;
      writeln('  size     = ', statinfo.st_size);
      writeln('  modified = ', statinfo.st_mtime.tv_sec);
    end;
    writeln;
    dir_entry := readdir(dir);
  end;

  closedir(dir);
  writeln;
end;

var
  f: TextFile;
  fb: File of byte;
  i: integer;
  ioRes: word;

begin
  rtc_wdt_disable; // In case WDT was initialized by bootloader
  esp_log_level_set('*', ESP_LOG_WARN);

  mountConfig.format_if_mount_failed := false;
  mountConfig.max_files := 5;
  mountConfig.allocation_unit_size := 16 * 1024;

  INIT_SDSPI_HOST_DEFAULT(host);
  with bus_cfg do
  begin
    mosi_io_num := PIN_NUM_MOSI;
    miso_io_num := PIN_NUM_MISO;
    sclk_io_num := PIN_NUM_CLK;
    quadwp_io_num := -1;
    quadhd_io_num := -1;
    max_transfer_sz := 4000;
  end;

  write('Initializing SPI bus: ');
  ret := spi_bus_initialize(Tspi_host_device(host.slot), @bus_cfg, SPI_DMA_CH1);
  if (ret = ESP_OK) then
  begin
    writeln('OK');

    // This initializes the slot without card detect (CD) and write protect (WP) signals.
    // Modify slot_config.gpio_cd and slot_config.gpio_wp if your board has these signals.
    INIT_SDSPI_DEVICE_CONFIG_DEFAULT(slot_config);
    slot_config.gpio_cs := Tgpio_num(PIN_NUM_CS);
    slot_config.host_id := tspi_host_device(host.slot);

    write('Mount SD card with FATFS driver: ');
    ret := esp_vfs_fat_sdspi_mount(mount_point, @host, @slot_config, @mountConfig, @card);
    if ret = ESP_OK then
    begin
      writeln('OK');

      printSDCardInfo(card);
      writeln;
      listRoot;

      writeln(#10'Appending to out.txt');
      {$push}{$I-} // disable runtime I/O errors
      AssignFile(f, outputfile);
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
        for i := 0 to 4 do
          writeln(f,  i, ',', 2*i);
      end;
      CloseFile(f);
      ioRes := IOResult;
      if ioRes > 0 then
        writeln('IO error ', ioRes, ' when closing file');

      // Find size of file. File needs to be opened.
      AssignFile(fb, outputfile);
      FileMode := 2;
      Reset(fb);
      ioRes := IOResult;
      if ioRes > 0 then
        writeln('IO error ', ioRes, ' when calling Reset');

      writeln('FileSize = ', FileSize(fb));
      ioRes := IOResult;
      if ioRes > 0 then
        writeln('IO error ', ioRes, ' when calling FileSize');

      CloseFile(fb);
      ioRes := IOResult;
      if ioRes > 0 then
        writeln('IO error ', ioRes, ' when closing file');
      {$pop} // restore previous runtime error state
      writeln('Done');

      write('Unmount: ');
      if esp_vfs_fat_sdcard_unmount(mount_point, card) = ESP_OK then
        writeln('OK')
      else
        writeln(esp_err_to_name(ret), '. Error: ', errno);
    end  //esp_vfs_fat_sdspi_mount = ESP_OK
    else
      writeln('Error - ', esp_err_to_name(ret));

    write('Freeing SPI bus: ');
    ret :=   spi_bus_free(Tspi_host_device(host.slot));
    if (ret = ESP_OK) then
      writeln('OK')
    else
      writeln('Error - ', esp_err_to_name(ret));
  end  // spi_bus_initialize = ESP_OK
  else
    writeln('Error - ', esp_err_to_name(ret));

  repeat
    vTaskDelay(100);
    writeln('.');
  until false;
end.

