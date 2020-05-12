unit xtruntime;

{$include sdkconfig.inc}

interface

uses
  xtruntime_core_state, core, core_isa;

const
  XTOS_KEEPON_MEM		      = $00000100;
  XTOS_KEEPON_MEM_SHIFT	  = 8;
  XTOS_KEEPON_DEBUG	      = $00001000;
  XTOS_KEEPON_DEBUG_SHIFT	= 12;
  XTOS_IDMA_NO_WAIT	      = $00010000;
  XTOS_IDMA_WAIT_STANDBY	= $00020000;
  XTOS_COREF_PSO		      = $00000001;
  XTOS_COREF_PSO_SHIFT	  = 0;

type
{$if defined(XTOS_MISRA)}
  T_xtos_handler_func = procedure(para: pointer);
{$else}
  T_xtos_handler_func = procedure();
{$endif}
  P_xtos_handler_func = ^T_xtos_handler_func;

//typedef _xtos_handler_func *_xtos_handler;
  T_xtos_handler = ^T_xtos_handler_func;

{$if defined(XCHAL_HAVE_INTERRUPTS) and (XCHAL_HAVE_INTERRUPTS <> 0)}
//# define XTOS_SET_INTLEVEL(intlevel)		0
//# define XTOS_SET_MIN_INTLEVEL(intlevel)	0
//# define XTOS_RESTORE_INTLEVEL(restoreval)
//# define XTOS_RESTORE_JUST_INTLEVEL(restoreval)
{$elseif defined(XCHAL_HAVE_XEA2)}
//# define XTOS_SET_INTLEVEL(intlevel)	__extension__({ unsigned __tmp; \
//			__asm__ __volatile__(	"rsil	%0, " XTSTR(intlevel) "\n" \
//						: "=a" (__tmp) : : "memory" ); \
//			__tmp;})
//# define XTOS_SET_MIN_INTLEVEL(intlevel)		({ unsigned __tmp, __tmp2, __tmp3; \
//			__asm__ __volatile__(	"rsr.ps	%0\n"		/* get old (current) PS.INTLEVEL */ \
//						"movi	%2, " XTSTR(intlevel) "\n" \
//						"extui	%1, %0, 0, 4\n"	/* keep only INTLEVEL bits of parameter */ \
//						"blt	%2, %1, 1f\n" \
//						"rsil	%0, " XTSTR(intlevel) "\n" \
//						"1:\n" \
//						: "=a" (__tmp), "=&a" (__tmp2), "=&a" (__tmp3) : : "memory" ); \
//			__tmp;})
//# define XTOS_RESTORE_INTLEVEL(restoreval)	do{ unsigned __tmp = (restoreval); \
//			__asm__ __volatile__(	"wsr.ps	%0 ; rsync\n" \
//						: : "a" (__tmp) : "memory" ); \
//			}while(0)
//# define XTOS_RESTORE_JUST_INTLEVEL(restoreval)	_xtos_set_intlevel(restoreval)
{$else}
function _xtos_set_vpri(vpri: uint32): uint32; external;
function _xtos_vpri_enabled: uint32; external;

function XTOS_SET_INTLEVEL(const intlevel: uint32): uint32;	inline;
function XTOS_SET_MIN_INTLEVEL(const intlevel: uint32): uint32;	inline;
function XTOS_RESTORE_INTLEVEL(const restoreval: uint32): uint32;	inline;
function XTOS_RESTORE_JUST_INTLEVEL(const restoreval: uint32): uint32; inline;
{$endif}

function XTOS_ENABLE_INTERRUPTS: uint32;
function XTOS_DISABLE_LOWPRI_INTERRUPTS: uint32; inline;
function XTOS_MASK_LOWPRI_INTERRUPTS: uint32; inline;
function XTOS_DISABLE_EXCM_INTERRUPTS: uint32; inline;
function XTOS_MASK_EXCM_INTERRUPTS: uint32; inline;
function XTOS_DISABLE_ALL_INTERRUPTS: uint32; inline;

function _xtos_ints_off(mask: uint32):uint32; external;
function _xtos_ints_on(mask: uint32):uint32; external;

procedure _xtos_interrupt_enable(intnum: uint32); inline;
procedure _xtos_interrupt_disable(intnum: uint32); inline;

function _xtos_set_intlevel(intlevel: int32): uint32; external;
function _xtos_set_min_intlevel(intlevel: int32): uint32; external;
function _xtos_restore_intlevel(restoreval: uint32): uint32; external;
function _xtos_restore_just_intlevel(restoreval: uint32): uint32; external;
function _xtos_set_interrupt_handler(n: int32; f: T_xtos_handler): T_xtos_handler; external;
function _xtos_set_interrupt_handler_arg(n: int32; f: T_xtos_handler; arg: pointer): T_xtos_handler; external;
function _xtos_set_exception_handler(n: int32; f: T_xtos_handler): T_xtos_handler; external;
procedure _xtos_memep_initrams; external;
procedure _xtos_memep_enable(flags: int32); external;

{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 1)}
procedure _xtos_dispatch_level1_interrupts; external;
{$endif}
{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 2)}
procedure _xtos_dispatch_level2_interrupts; external;
{$endif}
{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 3)}
procedure _xtos_dispatch_level3_interrupts; external;
{$endif}
{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 4)}
procedure _xtos_dispatch_level4_interrupts; external;
{$endif}
{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 5)}
procedure _xtos_dispatch_level5_interrupts; external;
{$endif}
{$if defined(XCHAL_NUM_INTLEVELS) and (XCHAL_NUM_INTLEVELS >= 6)}
procedure _xtos_dispatch_level6_interrupts; external;
{$endif}

function _xtos_read_ints: uint32; external;
procedure _xtos_clear_ints(mask: uint32); external;
function _xtos_core_shutoff(flags: uint32): int32; external;
function _xtos_core_save(flags: uint32; var savearea: TXtosCoreState; code: pointer): int32; external;
procedure _xtos_core_restore(retvalue: uint32; var savearea: TXtosCoreState); external;

{$if defined(XCHAL_NUM_CONTEXTS) and (XCHAL_NUM_CONTEXTS > 1)}
function _xtos_init_context(context_num, stack_size: int32;
					     start_func: P_xtos_handler_func; arg1: int32): uint32; external;
{$endif}

//  Deprecated:
//{$if XCHAL_NUM_TIMERS > 0
//extern void		_xtos_timer_0_delta( int cycles );
//{$endif}
//{$if XCHAL_NUM_TIMERS > 1
//extern void		_xtos_timer_1_delta( int cycles );
//{$endif}
//{$if XCHAL_NUM_TIMERS > 2
//extern void		_xtos_timer_2_delta( int cycles );
//{$endif}
//{$if XCHAL_NUM_TIMERS > 3
//extern void		_xtos_timer_3_delta( int cycles );
//{$endif}

implementation

//#define _XCHAL_INTLEVEL_ANDBELOWMASK(n)	XCHAL_INTLEVEL ## n ## _ANDBELOW_MASK e.g. XCHAL_INTLEVEL0_ANDBELOW_MASK
//#define XCHAL_INTLEVEL_ANDBELOW_MASK(n)	_XCHAL_INTLEVEL_ANDBELOWMASK(n)	/* n = 0 .. 15 */

function XTOS_SET_INTLEVEL(const intlevel: uint32): uint32;	inline;
begin
  // Substitute macro expansion to const to reference to const array
  XTOS_SET_INTLEVEL := _xtos_set_vpri(not(XCHAL_INTLEVEL_ANDBELOW_MASKS[intlevel]));
end;

function XTOS_SET_MIN_INTLEVEL(const intlevel: uint32): uint32;	inline;
begin
  XTOS_SET_MIN_INTLEVEL := _xtos_set_vpri(_xtos_vpri_enabled and not (XCHAL_INTLEVEL_ANDBELOW_MASKS[intlevel]));
end;

function XTOS_RESTORE_INTLEVEL(const restoreval: uint32): uint32;	inline;
begin
  XTOS_RESTORE_INTLEVEL := _xtos_set_vpri(restoreval);
end;

function XTOS_RESTORE_JUST_INTLEVEL(const restoreval: uint32): uint32;	inline;
begin
  XTOS_RESTORE_JUST_INTLEVEL := _xtos_set_vpri(restoreval)
end;

function XTOS_ENABLE_INTERRUPTS: uint32; inline;
begin
  XTOS_ENABLE_INTERRUPTS := XTOS_SET_INTLEVEL(0);
end;

function XTOS_DISABLE_LOWPRI_INTERRUPTS: uint32; inline;
begin
  XTOS_DISABLE_LOWPRI_INTERRUPTS := XTOS_SET_INTLEVEL(XCHAL_NUM_LOWPRI_LEVELS);
end;

function XTOS_MASK_LOWPRI_INTERRUPTS: uint32; inline;
begin
  XTOS_MASK_LOWPRI_INTERRUPTS := XTOS_SET_MIN_INTLEVEL(XCHAL_NUM_LOWPRI_LEVELS);
end;

function XTOS_DISABLE_EXCM_INTERRUPTS: uint32; inline;
begin
  XTOS_DISABLE_EXCM_INTERRUPTS := XTOS_SET_INTLEVEL(XCHAL_EXCM_LEVEL);
end;

function XTOS_MASK_EXCM_INTERRUPTS: uint32; inline;
begin
  XTOS_MASK_EXCM_INTERRUPTS := XTOS_SET_MIN_INTLEVEL(XCHAL_EXCM_LEVEL);
end;

function XTOS_DISABLE_ALL_INTERRUPTS: uint32; inline;
begin
  XTOS_DISABLE_ALL_INTERRUPTS := XTOS_SET_INTLEVEL(15);
end;

procedure _xtos_interrupt_enable(intnum: uint32); inline;
begin
  _xtos_ints_on(1 shl intnum);
end;

procedure _xtos_interrupt_disable(intnum: uint32); inline;
begin
  _xtos_ints_off(1 shl intnum);
end;

end.
