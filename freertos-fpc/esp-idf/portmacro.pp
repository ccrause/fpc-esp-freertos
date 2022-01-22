unit portmacro;

{$include freertosconfig.inc}
{$inline on}

interface

uses
  hal, esp_heap_caps, xtruntime, crosscore_int, core_isa, portbenchmark;

type
  portCHAR        = int8;
  portFLOAT       = single;
  portDOUBLE      = double;
  portLONG        = int32;
  portSHORT       = int16;
  portSTACK_TYPE  = byte;
  portBASE_TYPE	  = int32;
  // Relocate, it is easier to start with type defs in this unit...
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
  TTickType = uint16;
const
  portMAX_DELAY := $ffff;
{$else}
  TTickType = uint32;
const
  portMAX_DELAY = $ffffffff;
{$endif}

type
  // Definition taken from esp_hw_support/include/soc/spinlock.h
  TSpinlock = record
    owner: uint32;
    count: uint32;
  {$if defined(CONFIG_FREERTOS_PORTMUX_DEBUG)}
    lastLockedFn: pchar;
    lastLockedLine: integer;
  {$endif}
  end;
  PportMUX_TYPE = ^TportMUX_TYPE;
  TportMUX_TYPE = TSpinlock;

const
  portMUX_FREE_VAL    = $B33FFFFF;
  portMUX_NO_TIMEOUT  = (-1);
  portMUX_TRY_LOCK    = 0;

// Keep this in sync with the portMUX_TYPE struct definition please.
  portMUX_INITIALIZER_UNLOCKED: TportMUX_TYPE =
    (owner: portMUX_FREE_VAL; count: 0
  {$ifdef CONFIG_FREERTOS_PORTMUX_DEBUG}
    ; lastLockedFn: '(never locked)'
    ; lastLockedLine: -1
  {$endif}
    );

procedure portASSERT_IF_IN_ISR; external name 'vPortAssertIfInISR';
procedure vPortAssertIfInISR; external;

const
  portCRITICAL_NESTING_IN_TCB = 1;

procedure vPortCPUInitializeMutex(mux: PportMUX_TYPE); external;
procedure vPortEnterCritical(mux: PportMUX_TYPE); external;
procedure vPortExitCritical(mux: PportMUX_TYPE); external;
procedure vPortCPUAcquireMutex(mux: PportMUX_TYPE); external;
function vPortCPUAcquireMutexTimeout(mux: PportMUX_TYPE; timeout_cycles: int32): longbool; external;
procedure vPortCPUReleaseMutex(mux: PportMUX_TYPE); external;

procedure portENTER_CRITICAL(mux: PportMUX_TYPE); external name 'vPortEnterCritical';
procedure portEXIT_CRITICAL(mux: PportMUX_TYPE); external name 'vPortExitCritical';

procedure portENTER_CRITICAL; inline;
procedure portEXIT_CRITICAL; inline;

procedure portENTER_CRITICAL_ISR(mux: PportMUX_TYPE); external name 'vPortEnterCritical';
procedure portEXIT_CRITICAL_ISR(mux: PportMUX_TYPE); external name 'vPortExitCritical';

function portENTER_CRITICAL_NESTED: uint32; inline;
procedure portEXIT_CRITICAL_NESTED(const state: uint32); inline;

procedure portDISABLE_INTERRUPTS; inline;
procedure portENABLE_INTERRUPTS; inline;
function portSET_INTERRUPT_MASK_FROM_ISR: uint32; inline;
procedure portCLEAR_INTERRUPT_MASK_FROM_ISR(const state: uint32); inline;

//Because the ROM routines don't necessarily handle a stack in external RAM correctly, we force
//the stack memory to always be internal.
const
  portTcbMemoryCaps = MALLOC_CAP_INTERNAL or MALLOC_CAP_8BIT;
  portStackMemoryCaps = MALLOC_CAP_INTERNAL or MALLOC_CAP_8BIT;

function pvPortMallocTcbMem(size: uint32): pointer; inline;
function pvPortMallocStackMem(size: uint32): pointer; inline;


//static inline void uxPortCompareSet(volatile uint32_t *addr, uint32_t compare, uint32_t *set) {
//{$if XCHAL_HAVE_S32C1I}
//    __asm__ __volatile__ (
//        "WSR 	    %2,SCOMPARE1 \n"
//        "S32C1I     %0, %1, 0	 \n"
//        :"=r"(*set)
//        :"r"(addr), "r"(compare), "0"(*set)
//        );
//{$else}
//    // No S32C1I, so do this by disabling and re-enabling interrupts (slower)
//    uint32_t intlevel, old_value;
//    __asm__ __volatile__ ("rsil %0, " XTSTR(XCHAL_EXCM_LEVEL) "\n"
//                          : "=r"(intlevel));
//
//    old_value = *addr;
//    if (old_value = compare) {
//        *addr = *set;
//    }
//
//    __asm__ __volatile__ ("memw \n"
//                          "wsr %0, ps\n"
//                          :: "r"(intlevel));
//
//    *set = old_value;
//{$endif}


const
  portSTACK_GROWTH   = -1;
  portTICK_PERIOD_MS = 1000 div configTICK_RATE_HZ;
  portBYTE_ALIGNMENT = 4;

//procedure portNOP; inline;
procedure portGET_RUN_TIME_COUNTER_VALUE; external name 'xthal_get_ccount';

{$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER}
function portALT_GET_RUN_TIME_COUNTER_VALUE: uint32; external name 'esp_timer_get_time';
{$endif}

procedure vPortYield; external;
procedure _frxt_setup_switch; external;

procedure portYIELD; external name 'vPortYield';
// portYIELD_FROM_ISR is a simplified version with no parameters
// so it will always call _frxt_setup_switch.
// Also no tracing macro is called
procedure portYIELD_FROM_ISR; external name '_frxt_setup_switch';

procedure portYIELD_WITHIN_API; inline;

type
  TxMPU_SETTINGS = record
    {$if defined(XCHAL_CP_NUM) and (XCHAL_CP_NUM > 0)}
      coproc_area: PStackType; // Pointer to coprocessor save area; MUST BE FIRST
    {$endif}
    {$ifdef portUSING_MPU_WRAPPERS}
      mpu_setting: int32; // Just a dummy example here; MPU not ported to Xtensa yet
    {$endif}
    {$ifdef configUSE_TRACE_FACILITY_2}
      porttrace: record
    	  // Cf. porttraceStamp()
    	  taskstamp: int32;
    	  taskstampcount: int32;
      end;
    {$endif}
  end;

procedure esp_vApplicationIdleHook; external;
procedure esp_vApplicationTickHook; external;

procedure _xt_coproc_release(coproc_sa_base: pointer); external;
procedure vApplicationSleep(xExpectedIdleTime: TTickType); external;
procedure portSUPPRESS_TICKS_AND_SLEEP(idleTime: TTickType); external name 'vApplicationSleep';
procedure vPortYieldOtherCore(coreid: TBaseType); external;
procedure vPortSetStackWatchpoint(pxStackStart: pointer); external;
function xPortInIsrContext: TBaseType; external;
function xPortInterruptedFromISRContext: TBaseType; external;

function xPortGetCoreID: TBaseType;
function xPortGetTickRateHz: uint32; external;

function xPortCanYield: longbool;

{$ifdef CONFIG_SPIRAM}
procedure uxPortCompareSetExtram(addr: PUint32; compare: uint32; set_: PUint32); external name 'compare_and_set_extram';
{$endif}

implementation

// ESP32 requires a mux parameter for vTaskEnter/ExitCritical
// To create a normal FreeRTOS compatible port(ENTER/EXIT)_CRITICAL functionality
// without a parameter, use a hidden global mux as parameter.
var
  mux: TportMUX_TYPE = (owner: portMUX_FREE_VAL; count: 0
  {$ifdef CONFIG_FREERTOS_PORTMUX_DEBUG}
    ; lastLockedFn: '(never locked)'
    ; lastLockedLine: -1
  {$endif}
    );

procedure portENTER_CRITICAL; inline;
begin
  vPortEnterCritical(@mux);
end;

procedure portEXIT_CRITICAL; inline;
begin
  vPortExitCritical(@mux)
end;

procedure portDISABLE_INTERRUPTS; inline;
begin
  XTOS_SET_INTLEVEL(XCHAL_EXCM_LEVEL);
  portbenchmarkINTERRUPT_DISABLE();
end;

procedure portEXIT_CRITICAL_NESTED(const state: uint32); inline;
begin
  portbenchmarkINTERRUPT_RESTORE(state);
  XTOS_RESTORE_JUST_INTLEVEL(state);
end;

procedure portENABLE_INTERRUPTS;
begin
  portbenchmarkINTERRUPT_RESTORE(0);
  XTOS_SET_INTLEVEL(0);
end;

function portENTER_CRITICAL_NESTED: uint32;
begin
  portENTER_CRITICAL_NESTED := XTOS_SET_INTLEVEL(XCHAL_EXCM_LEVEL);
  portbenchmarkINTERRUPT_DISABLE();
end;

function portSET_INTERRUPT_MASK_FROM_ISR: uint32; inline;
begin
  portSET_INTERRUPT_MASK_FROM_ISR := portENTER_CRITICAL_NESTED;
end;

procedure portCLEAR_INTERRUPT_MASK_FROM_ISR(const state: uint32); inline;
begin
  portEXIT_CRITICAL_NESTED(state);
end;

function pvPortMallocTcbMem(size: uint32): pointer; inline;
begin
  pvPortMallocTcbMem := heap_caps_malloc(size, portTcbMemoryCaps);
end;

function pvPortMallocStackMem(size: uint32): pointer; inline;
begin
  pvPortMallocStackMem := heap_caps_malloc(size, portStackMemoryCaps);
end;

procedure portNOP; inline;
begin
  asm nop end;
end;

procedure portYIELD_WITHIN_API; inline;
begin
  esp_crosscore_int_send_yield(xPortGetCoreID());
end;

function xPortGetCoreID: TBaseType; assembler; // IRAM_ATTR
asm
  rsr.prid a2            // Read special register Processor ID.
  extui a2, a2, 13, 1    // Extract and return bit 13
end ['a2'];

function xPortCanYield: longbool; assembler;
label
  trueLabel, endLabel;
asm
  rsr.ps a2
  extui a2, a2, 0, 4  // Extract INTLEVEL
  beqz a2, trueLabel  // If INTLEVEL = 0 then return true
  movi a2, 0
  j endLabel
trueLabel:
  movi a2, -1
endLabel:
end ['a2'];

end.
