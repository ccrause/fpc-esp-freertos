unit esp_heap_config;

{$include sdkconfig.inc}

interface

const
  HEAP_ALIGN_SIZE = 4;
{$ifdef CONFIG_HEAP_DISABLE_IRAM}
  HEAP_REGIONS_MAX = 1;
{$else}
  HEAP_REGIONS_MAX = 2;
{$endif}
  MEM_BLK_MIN = 1;

implementation

end.
