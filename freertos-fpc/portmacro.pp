unit portmacro;

//{ $include <xtensa/hal.h>
//{ $include <xtensa/config/core.h>
//{ $include <xtensa/config/system.h>	/* required for XSHAL_CLIB */
//{ $include <xtensa/xtruntime.h>
//{ $include "esp_private/crosscore_int}
//{ $include "esp_timer}              /* required for FreeRTOS run time stats */
//{ $include <esp_heap_caps.h>

{$include sdkconfig.inc}
{$inline on}

interface

uses
  hal, esp_heap_caps, xtruntime, crosscore_int, core_isa, portbenchmark;

type
  portCHAR		   = int8;
  portFLOAT		   = single;
  portDOUBLE		 = double;
  portLONG		   = int32;
  portSHORT		   = int16;
  portSTACK_TYPE = byte;
  portBASE_TYPE	 = int32;

{$if defined(configUSE_16_BIT_TICKS) and (configUSE_16_BIT_TICKS = 1)}
	TTickType_t = uint16;
	{$define portMAX_DELAY := $ffff}
{$else}
	TTickType_t = uint32;
  //{$define portMAX_DELAY $ffffffff}
const
  portMAX_DELAY = $ffffffff;
type
{$endif}

  TportMUX_TYPE = record
  	owner: uint32;
  	count: uint32;
  {$ifdef CONFIG_FREERTOS_PORTMUX_DEBUG}
  	lastLockedFn: PChar;
  	lastLockedLine: int32;
  {$endif}
  end;
  PportMUX_TYPE = ^TportMUX_TYPE;

const
  // Defined in FreeRTOSConfig, break cyclic dependence by redeclaring constant here
  configTICK_RATE_HZ = CONFIG_FREERTOS_HZ;

  portMUX_FREE_VAL		= $B33FFFFF;
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

procedure portASSERT_IF_IN_ISR; inline;
procedure vPortAssertIfInISR; external;

const
  portCRITICAL_NESTING_IN_TCB = 1;

procedure vPortCPUInitializeMutex(mux: PportMUX_TYPE); external;

{$ifdef CONFIG_FREERTOS_PORTMUX_DEBUG}
void vPortCPUAcquireMutex(portMUX_TYPE *mux, const char *function, int line);
bool vPortCPUAcquireMutexTimeout(portMUX_TYPE *mux, int timeout_cycles, const char *function, int line);
void vPortCPUReleaseMutex(portMUX_TYPE *mux, const char *function, int line);

void vTaskEnterCritical( portMUX_TYPE *mux, const char *function, int line );
void vTaskExitCritical( portMUX_TYPE *mux, const char *function, int line );

{$ifdef CONFIG_FREERTOS_CHECK_PORT_CRITICAL_COMPLIANCE}
/* Calling port*_CRITICAL from ISR context would cause an assert failure.
 * If the parent function is called from both ISR and Non-ISR context then call port*_CRITICAL_SAFE
 */
#define portENTER_CRITICAL(mux)        do {                                                                                             \
                                            if(!xPortInIsrContext()) {                                                                  \
                                                vTaskEnterCritical(mux, __FUNCTION__, __LINE__);                                        \
                                            } else {                                                                                    \
                                                ets_printf("%s:%d (%s)- port*_CRITICAL called from ISR context!\n", __FILE__, __LINE__, \
                                                           __FUNCTION__);                                                               \
                                                abort();                                                                                \
                                            }                                                                                           \
                                       } while(0/*)*/

#define portEXIT_CRITICAL(mux)        do {                                                                                              \
                                            if(!xPortInIsrContext()) {                                                                  \
                                                vTaskExitCritical(mux, __FUNCTION__, __LINE__);                                         \
                                            } else {                                                                                    \
                                                ets_printf("%s:%d (%s)- port*_CRITICAL called from ISR context!\n", __FILE__, __LINE__, \
                                                           __FUNCTION__);                                                               \
                                                abort();                                                                                \
                                            }                                                                                           \
                                       } while(0/*)*/
{$else}
#define portENTER_CRITICAL(mux)        vTaskEnterCritical(mux, __FUNCTION__, __LINE__)
#define portEXIT_CRITICAL(mux)         vTaskExitCritical(mux, __FUNCTION__, __LINE__)
{$endif}
#define portENTER_CRITICAL_ISR(mux)    vTaskEnterCritical(mux, __FUNCTION__, __LINE__)
#define portEXIT_CRITICAL_ISR(mux)     vTaskExitCritical(mux, __FUNCTION__, __LINE__)
{$else}
procedure vTaskExitCritical(mux: PportMUX_TYPE); external;
procedure vTaskEnterCritical(mux: PportMUX_TYPE); external;
procedure vPortCPUAcquireMutex(mux: PportMUX_TYPE); external;
function vPortCPUAcquireMutexTimeout(mux: PportMUX_TYPE; timeout_cycles: int32): longbool; external;
procedure vPortCPUReleaseMutex(mux: PportMUX_TYPE); external;

{$ifdef CONFIG_FREERTOS_CHECK_PORT_CRITICAL_COMPLIANCE}
/* Calling port*_CRITICAL from ISR context would cause an assert failure.
 * If the parent function is called from both ISR and Non-ISR context then call port*_CRITICAL_SAFE
 */
#define portENTER_CRITICAL(mux)        do {                                                                                             \
                                            if(!xPortInIsrContext()) {                                                                  \
                                                vTaskEnterCritical(mux);                                                                \
                                            } else {                                                                                    \
                                                ets_printf("%s:%d (%s)- port*_CRITICAL called from ISR context!\n", __FILE__, __LINE__, \
                                                           __FUNCTION__);                                                               \
                                                abort();                                                                                \
                                            }                                                                                           \
                                       } while(0/*)*/

#define portEXIT_CRITICAL(mux)        do {                                                                                              \
                                            if(!xPortInIsrContext()) {                                                                  \
                                                vTaskExitCritical(mux);                                                                 \
                                            } else {                                                                                    \
                                                ets_printf("%s:%d (%s)- port*_CRITICAL called from ISR context!\n", __FILE__, __LINE__, \
                                                           __FUNCTION__);                                                               \
                                                abort();                                                                                \
                                            }                                                                                           \
                                       } while(0/*)*/
{$else}
procedure portENTER_CRITICAL(mux: PportMUX_TYPE); inline;
procedure portEXIT_CRITICAL(mux: PportMUX_TYPE); inline;
{$endif}
procedure portENTER_CRITICAL_ISR(mux: PportMUX_TYPE); inline;
procedure portEXIT_CRITICAL_ISR(mux: PportMUX_TYPE); inline;
{$endif}

{#define portENTER_CRITICAL_SAFE(mux)  do {                                             \
                                         if (xPortInIsrContext()) {                    \
                                             portENTER_CRITICAL_ISR(mux);              \
                                         } else {                                      \
                                             portENTER_CRITICAL(mux);                  \
                                         }                                             \
                                      } while(0/*)*/

#define portEXIT_CRITICAL_SAFE(mux)  do {                                              \
                                         if (xPortInIsrContext()) {                    \
                                             portEXIT_CRITICAL_ISR(mux);               \
                                         } else {                                      \
                                             portEXIT_CRITICAL(mux);                   \
                                         }                                             \
                                      } while(0/*)*/
 }

procedure portDISABLE_INTERRUPTS; inline;
procedure portENABLE_INTERRUPTS; inline;

function portENTER_CRITICAL_NESTED: uint32; inline;
procedure portEXIT_CRITICAL_NESTED(const state: uint32); inline;

procedure portSET_INTERRUPT_MASK_FROM_ISR; inline;
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
  portSTACK_GROWTH		=	-1;
  portTICK_PERIOD_MS	=	1000 div configTICK_RATE_HZ;
  portBYTE_ALIGNMENT	= 4;

procedure portNOP; inline;
procedure portGET_RUN_TIME_COUNTER_VALUE; inline;

//#define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()

{$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER}
function portALT_GET_RUN_TIME_COUNTER_VALUE: uint32; inline;    x = (uint32_t)esp_timer_get_time()
{$endif}

procedure vPortYield; external;
procedure _frxt_setup_switch; external;

procedure portYIELD; inline;
procedure portYIELD_FROM_ISR; inline;

function xPortGetCoreID: uint32; external;

procedure portYIELD_WITHIN_API; inline;

//#define portTASK_FUNCTION_PROTO( vFunction, pvParameters ) void vFunction( void *pvParameters )
//#define portTASK_FUNCTION( vFunction, pvParameters ) void vFunction( void *pvParameters )

type
  TxMPU_SETTINGS = record
    {$if defined(XCHAL_CP_NUM) and (XCHAL_CP_NUM > 0)}
    coproc_area: ^StackType_t; // Pointer to coprocessor save area; MUST BE FIRST
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

{$if ((defined(XCHAL_CP_NUM) and (XCHAL_CP_NUM > 0)) or defined(configUSE_TRACE_FACILITY_2)) and
     not(defined(portUSING_MPU_WRAPPERS) and (portUSING_MPU_WRAPPERS = 1))}
	{$undefine portUSING_MPU_WRAPPERS}
	{$define portUSING_MPU_WRAPPERS := 1}   // Enable it to allocate coproc area
	//#define MPU_WRAPPERS_H             // Override mpu_wrapper.h to disable unwanted code
	{$define PRIVILEGED_FUNCTION}
	{$define PRIVILEGED_DATA}
{$endif}

procedure esp_vApplicationIdleHook; external;
procedure esp_vApplicationTickHook; external;

{$ifndef CONFIG_FREERTOS_LEGACY_HOOKS}
//#define vApplicationIdleHook    esp_vApplicationIdleHook
//#define vApplicationTickHook    esp_vApplicationTickHook
{$endif}

procedure _xt_coproc_release(coproc_sa_base: pointer); external;
procedure vApplicationSleep(xExpectedIdleTime: TTickType_t); external;

procedure portSUPPRESS_TICKS_AND_SLEEP(idleTime: TTickType_t); inline;

// porttrace
{$ifdef configUSE_TRACE_FACILITY_2}
{ $include "porttrace}
{$endif}

// configASSERT_2 if requested
{$ifdef configASSERT_2}
{ $include <stdio.h>}
//void exit(int);
//#define configASSERT( x )   if (!(x)) { porttracePrint(-1); printf("\nAssertion failed in %s:%d\n", __FILE__, __LINE__); exit(-1); /*}*/
{$endif}

// Dummy implementation
procedure traceISR_EXIT_TO_SCHEDULER; inline;

implementation

procedure portASSERT_IF_IN_ISR; inline;
begin
  vPortAssertIfInISR;
end;

procedure portENTER_CRITICAL(mux: PportMUX_TYPE); inline;
begin
  vTaskEnterCritical(mux);
end;

procedure portEXIT_CRITICAL(mux: PportMUX_TYPE); inline;
begin
  vTaskExitCritical(mux);
end;

procedure portENTER_CRITICAL_ISR(mux: PportMUX_TYPE); inline;
begin
  vTaskEnterCritical(mux);
end;

procedure portEXIT_CRITICAL_ISR(mux: PportMUX_TYPE); inline;
begin
  vTaskExitCritical(mux);
end;

procedure portDISABLE_INTERRUPTS; inline;
begin
  XTOS_SET_INTLEVEL(XCHAL_EXCM_LEVEL);
  portbenchmarkINTERRUPT_DISABLE();
end;

//procedure portENABLE_INTERRUPTS; inline;
//begin
//  portbenchmarkINTERRUPT_RESTORE(0);
//  XTOS_SET_INTLEVEL(0);
//end;

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

procedure portSET_INTERRUPT_MASK_FROM_ISR; inline;
begin
  portENTER_CRITICAL_NESTED;
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
  //XT_NOP;
end;

procedure portGET_RUN_TIME_COUNTER_VALUE; inline;
begin
  xthal_get_ccount;
end;

{$ifdef CONFIG_FREERTOS_RUN_TIME_STATS_USING_ESP_TIMER}
function portALT_GET_RUN_TIME_COUNTER_VALUE: uint32; inline;
begin
  portALT_GET_RUN_TIME_COUNTER_VALUE := esp_timer_get_time;
end;
{$endif}

procedure portYIELD; inline;
begin
  vPortYield;
end;

procedure portYIELD_FROM_ISR; inline;
begin
  traceISR_EXIT_TO_SCHEDULER();
  _frxt_setup_switch();
end;

procedure portYIELD_WITHIN_API; inline;
begin
  esp_crosscore_int_send_yield(xPortGetCoreID());
end;

procedure portSUPPRESS_TICKS_AND_SLEEP(idleTime: TTickType_t); inline;
begin
  vApplicationSleep(idleTime);
end;

procedure traceISR_EXIT_TO_SCHEDULER;
begin

end;

end.
