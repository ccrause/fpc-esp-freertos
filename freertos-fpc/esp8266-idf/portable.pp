unit portable;

interface

uses
  portmacro, projdefs, esp_heap_caps;

const
  portBYTE_ALIGNMENT_MASK = portBYTE_ALIGNMENT - 1;
{$ifndef portNUM_CONFIGURABLE_REGIONS}
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}
  pvMALLOC_DRAM = MALLOC_CAP_8BIT or MALLOC_CAP_32BIT or MALLOC_CAP_DMA;
  pvMALLOC_IRAM = MALLOC_CAP_32BIT;

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

function pvPortMalloc(size: uint32): pointer; inline;
procedure vPortFree(APointer: pointer); inline;
function pvPortZalloc(size: longint): pointer; inline;
function pvPortCalloc(count, size: Tsize): pointer; inline;
function pvPortRealloc(memptr: pointer; size: Tsize): pointer; inline;

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
procedure vPortInitContextFromOldStack(newStackTop: PStackType; oldStackTop: PStackType; stackSize: TUBaseType); external;

implementation

function pvPortMalloc(size: uint32): pointer;
begin
  Result := heap_caps_malloc(size, pvMALLOC_DRAM);
end;

procedure vPortFree(APointer: pointer);
begin
  heap_caps_free(APointer);
end;

function pvPortZalloc(size: longint): pointer;
begin
  Result := heap_caps_zalloc(size, pvMALLOC_IRAM);
end;

function pvPortCalloc(count, size: Tsize): pointer;
begin
  Result := heap_caps_calloc(count, size, pvMALLOC_IRAM);
end;

function pvPortRealloc(memptr: pointer; size: Tsize): pointer;
begin
  Result := heap_caps_realloc(memptr, size, pvMALLOC_IRAM);
end;

end.
