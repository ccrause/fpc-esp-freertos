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
const
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
  function pxPortInitialiseStack(pxTopOfStack: PStackType_t; pxCode: TTaskFunction;
    pvParameters: pointer; xRunPrivileged: BaseType_t): PStackType; external;
{$else}
  function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TTaskFunction;
    pvParameters: pointer): PStackType; external;
{$endif}

// Malloc/free provided by Newlib
function pvPortMalloc(size: uint32): pointer; external name 'malloc';
procedure vPortFree(APointer: pointer); external name 'free';
function pvPortZalloc(s: longint): pointer; external name 'zalloc';
function pvPortCalloc(count, sz: Tsize): pointer; external name 'calloc';
function pvPortRealloc(memptr: pointer; sz: Tsize): pointer; external name 'realloc';
function xPortGetFreeHeapSize: uint32; external name 'esp_get_free_heap_size';
function xPortGetMinimumEverFreeHeapSize: uint32; external name 'esp_get_minimum_free_heap_size';
function xPortStartScheduler: TBaseType; external;
procedure vPortEndScheduler; external;
procedure vPortYieldOtherCore(coreid: TBaseType); external;
procedure vPortSetStackWatchpoint(pxStackStart: pointer); external;
function xPortInIsrContext: TBaseType; external;
function xPortInterruptedFromISRContext: TBaseType; external;

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
  type
    PxMEMORY_REGION = ^TxMEMORY_REGION;
    TxMEMORY_REGION = record
      {undefined structure}
    end;

  procedure vPortStoreTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS;
    xRegions: PxMEMORY_REGION; pxBottomOfStack: PStackType_t; usStackDepth: uint32); external;
  procedure vPortReleaseTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS); external;
{$endif}

procedure uxPortCompareSetExtram(addr: PUint32; compare: uint32; set_: PUint32); external;

implementation

end.
