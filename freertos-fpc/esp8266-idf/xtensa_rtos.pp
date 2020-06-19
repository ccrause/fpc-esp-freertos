unit xtensa_rtos;

interface

uses
  core_isa;

{.$include    <xtensa/config/core.h>}
{.$include    <xtensa/corebits.h>}
{.$include    <xtensa/config/system.h>}
{.$include    <xtensa/simcall.h>}

// Disable following check, this is true for FPC supported controllers
//{$if not(defined(XCHAL_HAVE_XEA2) and not(XCHAL_HAVE_XEA2))}
//{$error "FreeRTOS/Xtensa requires XEA2 (exception architecture 2)."}
//{$endif}

const
  XCHAL_EXCM_LEVEL = 3;
  XT_RTOS_NAME = 'FreeRTOS';
  XT_INTEXC_HOOK_NUM = (1 + XCHAL_NUM_INTLEVELS) + XCHAL_HAVE_NMI;

// Remapped macros, simply use aliasing to point them to the correct implementations
// Actually only required for building FreeRTOS, so not relevant for FPC
procedure XT_RTOS_INT_ENTER; cdecl; external name '_xt_int_enter';
procedure XT_RTOS_INT_EXIT; cdecl; external name '_xt_int_exit';
procedure XT_RTOS_TIMER_INT; cdecl; external name '_xt_timer_int';

// To enable interrupt/exception hooks, compile the RTOS with '-DXT_INTEXC_HOOKS'.
// Further, read the following before using these hooks (in xtensa-rtos.h):
// HOOKS TO DYNAMICALLY INSTALL INTERRUPT AND EXCEPTION HANDLERS PER LEVEL.
type
  TXT_INTEXC_HOOK = function(cause: dword): dword; cdecl;

var
  _xt_intexc_hooks: array[0..XT_INTEXC_HOOK_NUM-1] of TXT_INTEXC_HOOK; external;

implementation

end.
