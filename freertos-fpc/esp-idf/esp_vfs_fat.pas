unit esp_vfs_fat;

interface

uses
  esp_err, sdmmc_types, sdspi_host, portmacro,
  ff;

function esp_vfs_fat_register(base_path: PChar; fat_drive: PChar;
  max_files: Tsize; out_fs: PPFATFS): Tesp_err; external;
function esp_vfs_fat_unregister_path(base_path: PChar): Tesp_err; external;

type
  Pesp_vfs_fat_mount_config = ^Tesp_vfs_fat_mount_config;
  Tesp_vfs_fat_mount_config = record
    format_if_mount_failed: longbool;
    max_files: longint;
    allocation_unit_size: Tsize;
  end;

  Pesp_vfs_fat_sdmmc_mount_config = ^Tesp_vfs_fat_sdmmc_mount_config;
  Tesp_vfs_fat_sdmmc_mount_config = Tesp_vfs_fat_mount_config;

  // From wear_leveling.h
  Twl_handle = int32;
  Pwl_handle = pint32;

function esp_vfs_fat_sdmmc_mount(base_path: PChar; host_config: Psdmmc_host;
  slot_config: pointer; mount_config: Pesp_vfs_fat_mount_config;
  out_card: PPsdmmc_card): Tesp_err; external;

function esp_vfs_fat_sdspi_mount(base_path: PChar; host_config_input: Psdmmc_host;
  slot_config: Psdspi_device_config; mount_config: Pesp_vfs_fat_mount_config;
  out_card: PPsdmmc_card): Tesp_err; external;

function esp_vfs_fat_sdmmc_unmount: Tesp_err; external;

function esp_vfs_fat_sdcard_unmount(base_path: PChar;
  card: Psdmmc_card): Tesp_err; external;

function esp_vfs_fat_spiflash_mount(base_path: PChar; partition_label: PChar;
  mount_config: Pesp_vfs_fat_mount_config; wl_handle: Pwl_handle): Tesp_err;
  cdecl; external;

function esp_vfs_fat_spiflash_unmount(base_path: PChar;
  wl_handle: Twl_handle): Tesp_err; external;

function esp_vfs_fat_rawflash_mount(base_path: PChar; partition_label: PChar;
  mount_config: Pesp_vfs_fat_mount_config): Tesp_err; external;

function esp_vfs_fat_rawflash_unmount(base_path: PChar;
  partition_label: PChar): Tesp_err; external;

implementation

end.
