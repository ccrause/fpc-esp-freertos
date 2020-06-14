unit portable;

interface

uses
  portmacro, projdefs, esp_heap_caps;
{.$include "mpu_wrappers.h"}
{.$include "esp_heap_caps.h"}

type
  //PxMEMORY_REGION = ^xMEMORY_REGION;
  PStackType = ^TStackType;

const
  portBYTE_ALIGNMENT_MASK = portBYTE_ALIGNMENT - 1;

{$ifndef portNUM_CONFIGURABLE_REGIONS}
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TaskFunction;
      pvParameters: pointer; xRunPrivileged: TBaseType_t): PStackType; external;
{$else}
function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TTaskFunction;
    pvParameters: pointer): PStackType; external;
{$endif}

const
  pvMALLOC_DRAM = (MALLOC_CAP_8BIT or MALLOC_CAP_32BIT) or MALLOC_CAP_DMA;
  pvMALLOC_IRAM = MALLOC_CAP_32BIT;

function pvPortMalloc(s: longint): pointer;
function pvPortZalloc(s: longint): pointer;
function pvPortCalloc(count, sz: Tsize): pointer;
function pvPortRealloc(memptr: pointer; sz: Tsize): pointer;
procedure vPortFree(ptr: pointer);

function xPortStartScheduler: TBaseType; external;
procedure vPortEndScheduler; external;

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
type
  PxMEMORY_REGION = ^TxMEMORY_REGION;
  TxMEMORY_REGION = record  end;

procedure vPortStoreTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS;
    xRegions: PxMEMORY_REGION; pxBottomOfStack: PStackType; ulStackDepth: uint32); external;
{$endif}

function xPortInIsrContext: longint; cdecl; external;

implementation

function pvPortMalloc(s: longint): pointer;
begin
  // Would give this file name and line number, not the call site to this function
  pvPortMalloc := _heap_caps_malloc(s, pvMALLOC_DRAM, {$include %file%}, {$include %lineNum%});
end;

function pvPortZalloc(s: longint): pointer;
begin
  // Would give this file name and line number, not the call site to this function
  pvPortZalloc := _heap_caps_zalloc(s, pvMALLOC_IRAM, {$include %file%}, {$include %lineNum%});
end;

function pvPortCalloc(count, sz: Tsize): pointer;
begin
  // Would give this file name and line number, not the call site to this function
  pvPortCalloc := _heap_caps_calloc(count, sz, pvMALLOC_IRAM, {$include %file%}, {$include %lineNum%});
end;

function pvPortRealloc(memptr: pointer; sz: Tsize): pointer;
begin
  // Would give this file name and line number, not the call site to this function
  pvPortRealloc := _heap_caps_realloc(memptr, sz, pvMALLOC_IRAM, {$include %file%}, {$include %lineNum%});
end;

procedure vPortFree(ptr: pointer);
begin
  // Would give this file name and line number, not the call site to this function
  _heap_caps_free(ptr, {$include %file%}, {$include %lineNum%});
end;

end.
