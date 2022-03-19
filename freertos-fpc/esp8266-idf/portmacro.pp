unit portmacro;

{$include freertosconfig.inc}
{$inline on}

interface

{$if defined(configUSE_NEWLIB_REENTRANT) and (configUSE_NEWLIB_REENTRANT = 1)}
  {$ifndef CONFIG_NEWLIB_LIBRARY_CUSTOMER}
uses
  esp_newlib;
  {$endif}
{$endif}

type
  portCHAR        = char;
  portFLOAT       = single;
  portDOUBLE      = double;
  portLONG        = int32;
  portSHORT       = int16;
  portSTACK_TYPE  = uint8;
  portBASE_TYPE   = SizeInt;
  TStackType      = portSTACK_TYPE;
  PStackType      = ^TStackType;
  TBaseType       = portBASE_TYPE;
  PBaseType       = ^TBaseType;
  TUBaseType      = SizeUInt;
  PUBaseType      = ^TUBaseType;
  Tsize           = SizeUInt;
  Psize           = ^Tsize;
  Tbool           = longbool;
  Pbool           = ^Tbool;

  // Defined in freertos, but that creates circular dependencies
  configSTACK_DEPTH_TYPE = uint16;

// Also in task, but need to break dependency cycle
  PTaskHandle = ^TTaskHandle;
  TTaskHandle = pointer;
  PTickType   = ^TTickType;

{$if defined(configUSE_16_BIT_TICKS) and (configUSE_16_BIT_TICKS = 1)}
  TTickType = uint16;;
const
  portMAX_DELAY = $ffff;
{$else}
  TTickType = uint32;
const
  portMAX_DELAY = $ffffffff;
{$endif}

  portSTACK_GROWTH			= -1;
  portTICK_PERIOD_MS		=	1000 div configTICK_RATE_HZ;
  portBYTE_ALIGNMENT		=	4;

procedure PendSV(req: int32); external;
procedure portYIELD; inline;

procedure vTaskSwitchContext;	external;
procedure portEND_SWITCHING_ISR(xSwitchRequired: boolean);

procedure portYIELD_FROM_ISR(); external;

procedure vPortEnterCritical(); external;
procedure vPortExitCritical(); external;

//DYC_ISR_DBG
procedure PortDisableInt_NoNest(); external;
procedure PortEnableInt_NoNest(); external;

procedure portDISABLE_INTERRUPTS; inline;
procedure portENABLE_INTERRUPTS; inline;

procedure portENTER_CRITICAL; external name 'vPortEnterCritical';//inline;
procedure portEXIT_CRITICAL; external name 'vPortExitCritical'; //inline;
function xPortGetCoreID(): uint32; inline;

procedure _xt_user_exit; external;
procedure _xt_tick_timer_init; external;
procedure _xt_isr_unmask(unmask: uint32); external;
procedure _xt_isr_mask(mask: uint32); external;

type
  T_xt_isr = function (arg: pointer): pointer;

procedure _xt_isr_attach(i: byte; func: T_xt_isr; arg: pointer);  external;

type
  T_xt_isr_entry = record
    handler: T_xt_isr;
    arg: pointer;
  end;

procedure show_critical_info; external;

procedure esp_mem_trace(ptr: pointer; trace: PChar; no: int32); external;

//{$define esp_mem_mark_file(ptr) esp_mem_trace((ptr), __ESP_FILE__, LINE__)

function interrupt_is_disable(): longbool; external;
function xPortGetTickRateHz: uint32; external;
procedure _xt_enter_first_task; external;
procedure esp_increase_tick_cnt(ticks: TTickType); external;

// Move to Task, similar to esp-idf
//procedure xTaskCreatePinnedToCore(pvTaskCode, pcName, usStackDepth, pvParameters, uxPriority, pvCreatedTask, tskNO_AFFINITY);

//extern void esp_vApplicationIdleHook( void );
//extern void esp_vApplicationTickHook( void );
function g_esp_ticks_per_us: uint32; external;
function prvGetExpectedIdleTime(): TTickType; external;

// Moved from freertos
{$ifndef portSET_INTERRUPT_MASK_FROM_ISR}
function portSET_INTERRUPT_MASK_FROM_ISR: longint; inline;
{$endif}
{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint)
  : pointer; inline;
{$endif}

implementation

uses
  xtensa_rtos;

procedure portYIELD;
begin
  PendSV(1);
end;

procedure portEND_SWITCHING_ISR(xSwitchRequired: boolean);
begin
	if xSwitchRequired then
		vTaskSwitchContext();
end;

// TODO: Check if port(DIS/EN)ABLE_INTERRUPTS can be simplified
var
  cpu_sr : uint32; cvar; external;

procedure portDISABLE_INTERRUPTS; assembler; nostackframe;
label
  Lcpu_sr, dest;
asm
  j dest
  .balign 4                  // Ensure label Lcpu_sr is aligned
  Lcpu_sr:
  .long cpu_sr               // Store a local copy of the address to cpu_sr
  dest:
  rsil a2, XCHAL_EXCM_LEVEL  // store PS into a2 and write XCHAL_EXCM_LEVEL into PS.INTLEVEL
  l32r a3, Lcpu_sr           // Load address of cpu_sr into a3
  s32i  a2, a3, 0            // Store a2 in cpu_sr
end ['a2', 'a3'];

procedure portENABLE_INTERRUPTS; assembler; nostackframe;
label
  Lcpu_sr, dest;
asm
  j dest
  .balign 4
  Lcpu_sr:
  .long cpu_sr               // Linker complain about label address out of range (4294967291, $FFFFFFFB or -5)
  dest:                      // at l32r a3, Lcpu_sr below
  .balign 4
  l32r a3, Lcpu_sr           // Load address of cpu_sr into a3
  l32i  a2, a3, 0            // Load contents of cpu_sr into a2
  wsr.ps a2                  // Restore PS from a2
end ['a2', 'a3'];

function xPortGetCoreID(): uint32;
begin
  xPortGetCoreID := 0;
end;

{$ifndef portSET_INTERRUPT_MASK_FROM_ISR}
function portSET_INTERRUPT_MASK_FROM_ISR: longint;
begin
  portSET_INTERRUPT_MASK_FROM_ISR := 0;
end;
{$endif}

{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint): pointer;
begin
  portCLEAR_INTERRUPT_MASK_FROM_ISR := pointer(uxSavedStatusValue);
end;
{$endif}

end.

