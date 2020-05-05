unit portable;

{$include sdkconfig.inc}

// pull in malloc
{$linklib c, static}

interface

uses
  portmacro, esp_system, core;

const
  PS_INTLEVEL_MASK = $F;  // TODO: from xtensa/corebits.h.  Include core_bits once converted

type
  // unsure about definitions
  TStackType_t = uint32;
  PStackType_t = ^TStackType_t;
  TBaseType_t = int32;
  PBaseType_t = ^TBaseType_t;
  TUBaseType_t = uint32;
  // TODO: fromprojdefs.h
  //typedef void (*TaskFunction_t)( void * );
  TTaskFunction_t = procedure(para: pointer);
  PTaskFunction_t = ^TTaskFunction_t;

// TODO: currently these are constants defined in portmacro. Perhaps try to include macro in separate include file for portability.
//{$if (portBYTE_ALIGNMENT = 8)}
//const
//  portBYTE_ALIGNMENT_MASK = $0007;
//{$endif}
//{$if (portmacro.portBYTE_ALIGNMENT = 4)}
const
  portBYTE_ALIGNMENT_MASK = $0003;
//{$endif}
//{$if (portBYTE_ALIGNMENT = 2)}
//const
//  portBYTE_ALIGNMENT_MASK = $0001;
//{$endif}
//{$if defined(portBYTE_ALIGNMENT) and (portBYTE_ALIGNMENT = 1)}
//const
//  portBYTE_ALIGNMENT_MASK = $0000;
//{$endif}
//{$ifndef portBYTE_ALIGNMENT_MASK}
//{$error "Invalid portBYTE_ALIGNMENT definition"}
//{$endif}
{$ifndef portNUM_CONFIGURABLE_REGIONS}
const
  portNUM_CONFIGURABLE_REGIONS = 1;
{$endif}

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
function pxPortInitialiseStack(pxTopOfStack: PStackType_t; pxCode: TaskFunction_t; pvParameters: pointer; xRunPrivileged: BaseType_t): PStackType_t; external; // PRIVILEGED_FUNCTION;
{$else}
function pxPortInitialiseStack(pxTopOfStack: PStackType_t; pxCode: TTaskFunction_t; pvParameters: pointer): PStackType_t; external; //PRIVILEGED_FUNCTION; // empty define at the moment
{$endif}

function pvPortMalloc(size: uint32): pointer; inline;
procedure vPortFree(APointer: pointer); inline;
function xPortGetFreeHeapSize: uint32; inline;
function xPortGetMinimumEverFreeHeapSize: uint32; inline;

function xPortStartScheduler: TBaseType_t; external;//PRIVILEGED_FUNCTION;
procedure vPortEndScheduler; external; //PRIVILEGED_FUNCTION;
procedure vPortYieldOtherCore(coreid: TBaseType_t); external; // PRIVILEGED_FUNCTION;
procedure vPortSetStackWatchpoint(pxStackStart: pointer); cdecl; external;
function xPortInIsrContext: TBaseType_t; cdecl; external;
function xPortInterruptedFromISRContext: TBaseType_t; cdecl; external;

{$if defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1)}
type
  PxMEMORY_REGION = ^TxMEMORY_REGION;
  TxMEMORY_REGION = record
    {undefined structure}
  end;

procedure vPortStoreTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS; xRegions: PxMEMORY_REGION; pxBottomOfStack: PStackType_t; usStackDepth: uint32); external; //PRIVILEGED_FUNCTION;
procedure vPortReleaseTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS); cdecl; external;
{$endif}

function xPortGetCoreID: uint32;
function xPortCanYield: longbool;

function xPortGetTickRateHz: uint32; cdecl; external;
procedure uxPortCompareSetExtram(addr: PUint32; compare: uint32; set_: PUint32); external;

implementation

function malloc(size: uint32): pointer; external;
procedure Free(APointer: pointer); external;

function pvPortMalloc(size: uint32): pointer; inline;
begin
  pvPortMalloc := malloc(size);
end;

procedure vPortFree(APointer: pointer); inline;
begin
  Free(Apointer);
end;

function xPortGetFreeHeapSize: uint32; inline;
begin
 xPortGetFreeHeapSize := esp_get_free_heap_size;
end;

function xPortGetMinimumEverFreeHeapSize: uint32; inline;
begin
  xPortGetMinimumEverFreeHeapSize := esp_get_minimum_free_heap_size;
end;

// TODO: Activate once RSR is supported by compiler
function xPortGetCoreID: uint32; assembler; // IRAM_ATTR
asm
{$Warning Disabled assembler until compiler supports RSR instruction!}
{$if 0}
  rsr.prid a2            // Read special register Processor ID
  extui a2, a2, 13, 1    // Extract unsigned immediate
{$endif}
end;

function xPortCanYield: longbool;
var
  ps_reg: uint32 = 0;
begin
  asm
  {$Warning Disabled assembler until compiler supports RSR instruction!}
  {$if 0}
    rsr ps_reg, ps // processor state
  {$endif}
  end;

  xPortCanYield := (ps_reg and PS_INTLEVEL_MASK) = 0;
end;

end.
