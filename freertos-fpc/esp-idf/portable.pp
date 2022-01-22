unit portable;

{$inline on}

interface

uses
  portmacro, projdefs;

const
  PS_INTLEVEL_MASK = $F;  // TODO: from xtensa/corebits.h.  Include core_bits once converted

type
  TStackType = uint32;
  PStackType = ^TStackType;
  TBaseType = int32;
  PBaseType = ^TBaseType;
  TUBaseType = uint32;

const
  portBYTE_ALIGNMENT_MASK = portBYTE_ALIGNMENT - 1;
{$ifndef portNUM_CONFIGURABLE_REGIONS}
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
  function pxPortInitialiseStack(pxTopOfStack: PStackType_t; pxCode: TTaskFunction;
    pvParameters: pointer; xRunPrivileged: BaseType_t): PStackType; external;
{$else}
  function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TTaskFunction;
    pvParameters: pointer): PStackType; external;
{$endif}

{$ifdef configUSE_FREERTOS_PROVIDED_HEAP}
type
  THeapRegion = record
    pucStartAddress: pbyte;
    xSizeInBytes: TSize;
  end;
  PHeapRegion = ^THeapRegion;

  TxHeapStats = record
    xAvailableHeapSpaceInBytes: TSize;
    xSizeOfLargestFreeBlockInBytes: TSize;
    xSizeOfSmallestFreeBlockInBytes: TSize;
    xNumberOfFreeBlocks: TSize;
    xMinimumEverFreeBytesRemaining: TSize;
    xNumberOfSuccessfulAllocations: TSize;
    xNumberOfSuccessfulFrees: TSize;
  end;

procedure vPortDefineHeapRegions(const pxHeapRegions: PHeapRegions); external;
procedure vPortGetHeapStats(pxHeapStats: PHeapStats); external;
function pvPortMalloc(xSize: TSize): pointer; external;
procedure vPortFree( void *pv ); external;
procedure vPortInitialiseBlocks( void ); external;
function xPortGetFreeHeapSize: TSize; external;
function xPortGetMinimumEverFreeHeapSize: TSize; external;
{$else}  // configUSE_FREERTOS_PROVIDED_HEAP
function pvPortMalloc(size: uint32): pointer; external name 'malloc';
procedure vPortFree(APointer: pointer); external name 'free';
function xPortGetFreeHeapSize: uint32; external name 'esp_get_free_heap_size';
function xPortGetMinimumEverFreeHeapSize: uint32; external name 'esp_get_minimum_free_heap_size';
{$endif}

function xPortStartScheduler: TBaseType; external;
procedure vPortEndScheduler; external;

{$ifdef CONFIG_SPIRAM}
procedure uxPortCompareSetExtram(addr: PUint32; compare: uint32; set_: PUint32); external name 'compare_and_set_extram';
{$endif}

implementation

end.
