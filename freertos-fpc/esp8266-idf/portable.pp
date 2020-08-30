unit portable;

interface

uses
  portmacro, projdefs;

const
  portBYTE_ALIGNMENT_MASK = portBYTE_ALIGNMENT - 1;
{$ifndef portNUM_CONFIGURABLE_REGIONS}
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}

type
  PStackType = ^TStackType;

// Mapping not in SDK:
function xPortGetFreeHeapSize: Tsize; external name 'esp_get_free_heap_size';

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TaskFunction;
      pvParameters: pointer; xRunPrivileged: TBaseType_t): PStackType; external;
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

function xPortStartScheduler: TBaseType; external;
procedure vPortEndScheduler; external;

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
type
  PxMEMORY_REGION = ^TxMEMORY_REGION;
  TxMEMORY_REGION = record  end;

procedure vPortStoreTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS;
    xRegions: PxMEMORY_REGION; pxBottomOfStack: PStackType; ulStackDepth: uint32); external;
{$endif}

function xPortInIsrContext: longint; external;

implementation

end.
