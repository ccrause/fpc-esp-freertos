unit nvs_flash;

interface

uses
  esp_err, esp_partition;

const
  NVS_KEY_SIZE = 32;

type
  Pnvs_sec_cfg = ^Tnvs_sec_cfg;
  Tnvs_sec_cfg = record
    eky: array[0..NVS_KEY_SIZE-1] of byte;
    tky: array[0..NVS_KEY_SIZE-1] of byte;
  end;

function nvs_flash_init: Tesp_err; external;
function nvs_flash_init_partition(partition_label: PChar): Tesp_err; external;
function nvs_flash_deinit: Tesp_err; external;
function nvs_flash_deinit_partition(partition_label: PChar): Tesp_err; external;
function nvs_flash_erase: Tesp_err; external;
function nvs_flash_erase_partition(part_name: PChar): Tesp_err; external;

function nvs_flash_secure_init(cfg: Pnvs_sec_cfg): Tesp_err; external;
function nvs_flash_secure_init_partition(partition_label: PChar; cfg: Pnvs_sec_cfg): Tesp_err; external;
function nvs_flash_generate_keys(partition: Pesp_partition; cfg: Pnvs_sec_cfg): Tesp_err; external;
function nvs_flash_read_security_cfg(partition: Pesp_partition; cfg: Pnvs_sec_cfg): Tesp_err; external;


implementation

end.
