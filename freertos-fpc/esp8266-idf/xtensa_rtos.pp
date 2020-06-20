unit xtensa_rtos;

interface

uses
  core_isa;

const
  XCHAL_EXCM_LEVEL = 3;
  XT_RTOS_NAME = 'FreeRTOS';
  XT_INTEXC_HOOK_NUM = (1 + XCHAL_NUM_INTLEVELS) + XCHAL_HAVE_NMI;

// Remapped macros, simply use aliasing to point them to the correct implementations
// Actually only required for building FreeRTOS, so not relevant for FPC
procedure XT_RTOS_INT_ENTER; external name '_xt_int_enter';
procedure XT_RTOS_INT_EXIT; external name '_xt_int_exit';
procedure XT_RTOS_TIMER_INT; external name '_xt_timer_int';

// To enable interrupt/exception hooks, compile the RTOS with '-DXT_INTEXC_HOOKS'.
// Further, read the following before using these hooks (in xtensa-rtos.h):
// HOOKS TO DYNAMICALLY INSTALL INTERRUPT AND EXCEPTION HANDLERS PER LEVEL.
type
  TXT_INTEXC_HOOK = function(cause: dword): dword;

var
  _xt_intexc_hooks: array[0..XT_INTEXC_HOOK_NUM-1] of TXT_INTEXC_HOOK; cvar; external;

implementation

end.
