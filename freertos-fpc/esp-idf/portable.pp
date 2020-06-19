unit portable;

{$include sdkconfig.inc}
{$inline on}

// pull in malloc
{$linklib c, static}

interface

uses
  portmacro, esp_system, core;

const
  PS_INTLEVEL_MASK = $F;  // TODO: from xtensa/corebits.h.  Include core_bits once converted

type
  // unsure about definitions
  TStackType = uint32;
  PStackType = ^TStackType;
  TBaseType = int32;
  PBaseType = ^TBaseType;
  TUBaseType = uint32;
  // TODO: fromprojdefs.h
  //typedef void (*TaskFunction_t)( void * );
  TTaskFunction = procedure(para: pointer);
  PTaskFunction = ^TTaskFunction;

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
function pxPortInitialiseStack(pxTopOfStack: PStackType_t; pxCode: TaskFunction_t; pvParameters: pointer; xRunPrivileged: BaseType_t): PStackType_t; external;
{$else}
function pxPortInitialiseStack(pxTopOfStack: PStackType; pxCode: TTaskFunction; pvParameters: pointer): PStackType; external;
{$endif}

function pvPortMalloc(size: uint32): pointer; inline;
procedure vPortFree(APointer: pointer); inline;
function xPortGetFreeHeapSize: uint32; inline;
function xPortGetMinimumEverFreeHeapSize: uint32; inline;

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

procedure vPortStoreTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS; xRegions: PxMEMORY_REGION; pxBottomOfStack: PStackType_t; usStackDepth: uint32); external;
procedure vPortReleaseTaskMPUSettings(xMPUSettings: PxMPU_SETTINGS); external;
{$endif}

{$ifdef FPC_MCU_ESP8266}
const
  xPortGetCoreID = 0;
{$else}
function xPortGetCoreID: uint32;
function xPortCanYield: longbool;
{$endif}

function xPortGetTickRateHz: uint32; external;
procedure uxPortCompareSetExtram(addr: PUint32; compare: uint32; set_: PUint32); external;

implementation

function malloc(size: uint32): pointer; external;

procedure free(APointer: pointer); external;

function pvPortMalloc(size: uint32): pointer; inline;
begin
  pvPortMalloc := malloc(size);
end;

procedure vPortFree(APointer: pointer); inline;
begin
  free(Apointer);
end;

function xPortGetFreeHeapSize: uint32; inline;
begin
 xPortGetFreeHeapSize := esp_get_free_heap_size;
end;

function xPortGetMinimumEverFreeHeapSize: uint32; inline;
begin
  xPortGetMinimumEverFreeHeapSize := esp_get_minimum_free_heap_size;
end;

{$ifndef FPC_MCU_ESP8266} // not really necessary at the moment
function xPortGetCoreID: uint32; assembler; // IRAM_ATTR
asm
  rsr.prid a2            // Read special register Processor ID. PRID = 235
  extui a2, a2, 13, 1    // Extract only bit 13
end;

function xPortCanYield: longbool;
label
  trueLabel, endLabel;
begin
  asm
    rsr.ps a2
    extui a2, a2, 0, 4  // Extract INTLEVEL
    beqz a2, trueLabel  // If INTLEVEL = 0 then return true
    movi a2, 0
    j endLabel
  trueLabel:
    movi a2, -1
  endLabel:
  end;
end;
{$endif}

end.
