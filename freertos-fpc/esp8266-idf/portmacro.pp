unit portmacro;

{$include freertosconfig.inc}

interface

//#include "esp_attr.h"
//#include    <xtensa/xtruntime.h>
//#include    "xtensa_rtos.h"

{$if defined(configUSE_NEWLIB_REENTRANT) and (configUSE_NEWLIB_REENTRANT = 1)}
{$ifndef CONFIG_NEWLIB_LIBRARY_CUSTOMER}
//#include "esp_newlib.h"

{$define _impure_ptr _global_impure_ptr}

//{$undef _REENT_INIT_PTR}
//{$define _REENT_INIT_PTR(p) esp_reent_init(p)
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

var
  cpu_sr : uint32; external;

procedure vPortEnterCritical(); external;
procedure vPortExitCritical(); external;

//DYC_ISR_DBG
procedure PortDisableInt_NoNest(); external;
procedure PortEnableInt_NoNest(); external;

procedure portDISABLE_INTERRUPTS; inline;
procedure portENABLE_INTERRUPTS(); inline;

procedure portENTER_CRITICAL; inline;
procedure portEXIT_CRITICAL; inline;
function xPortGetCoreID(): uint32; inline;
//function xTaskGetCurrentTaskHandleForCPU(_cpu: TTaskHandle): uint32; inline;

//{$define portTASK_FUNCTION_PROTO( vFunction, pvParameters ) void vFunction( void *pvParameters )
//{$define portTASK_FUNCTION( vFunction, pvParameters ) void vFunction( void *pvParameters )

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
function portSET_INTERRUPT_MASK_FROM_ISR: longint;
{$endif}
{$ifndef portCLEAR_INTERRUPT_MASK_FROM_ISR}
function portCLEAR_INTERRUPT_MASK_FROM_ISR(uxSavedStatusValue: longint)
  : pointer;
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

procedure portDISABLE_INTERRUPTS; inline;
begin
  asm
  //__asm__ volatile ("rsil %0, " XTSTR(XCHAL_EXCM_LEVEL) : "=a" (cpu_sr) :: "memory")
    // Fix this
    rsil a2, XCHAL_EXCM_LEVEL
  end;
end;

procedure portENABLE_INTERRUPTS;
begin
  asm
    //__asm__ volatile ("wsr %0, ps" :: "a" (cpu_sr) : "memory")
    // FIX!!
    wsr.ps a2
  end;
end;

procedure portENTER_CRITICAL;
begin
  vPortEnterCritical();
end;

procedure portEXIT_CRITICAL();
begin
  vPortExitCritical();
end;

function xPortGetCoreID(): uint32;
begin
  xPortGetCoreID := 0;
end;

//function xTaskGetCurrentTaskHandleForCPU(_cpu: TTaskHandle): uint32;
//begin
//  xTaskGetCurrentTaskHandleForCPU := xTaskGetCurrentTaskHandle(_cpu);
//end;

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

