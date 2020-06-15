unit nvs_flash;

interface

uses
  esp_err, nvs;

function nvs_flash_init: Tesp_err; cdecl; external;
function nvs_flash_init_partition(partition_label: PChar): Tesp_err; cdecl; external;
function nvs_flash_deinit: Tesp_err; cdecl; external;
function nvs_flash_deinit_partition(partition_label: PChar): Tesp_err; cdecl; external;
function nvs_flash_erase: Tesp_err; cdecl; external;
function nvs_flash_erase_partition(part_name: PChar): Tesp_err; cdecl; external;

implementation


end.
