unit xtruntime_core_state;

{$include sdkconfig.inc}

interface

uses
  core_isa, tie;

{ $include <xtensa/xtruntime-frames.h>}
{ $include <xtensa/config/core.h>}
{ $include <xtensa/config/tie.h>}
{ $if XCHAL_HAVE_IDMA}
{ $include <xtensa/idma.h>}
{ $endif}

const
  CORE_STATE_SIGNATURE = $B1C5AFED;  

type
  // TODO: check alignment requirements of the STRUCT_AFIELD_A fields in original header
  TXtosCoreState = record
    signature: int32;
    restore_label: int32;
    aftersave_label: int32;
    areg: array[0..XCHAL_NUM_AREGS-1] of int32;
  {$if defined(XCHAL_HAVE_WINDOWED)}
    caller_regs: array[0..15] of int32;	// save a max of 16 caller regs
    caller_regs_saved: int32;  // flag to show if caller regs saved
  {$endif}
  {$if defined(XCHAL_HAVE_PSO_CDM)}
    pwrctl: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_WINDOWED)}
    windowbase: int32;
    windowstart: int32;
  {$endif}
    sar: int32;
  {$if defined(XCHAL_HAVE_EXCEPTIONS)}
    epc1: int32;
    ps: int32;
    excsave1: int32;
  // ifdef XCHAL_DOUBLEEXC_VECTOR_VADDR
    depc: int32;
  // endif
  {$endif}
  {$if (XCHAL_NUM_INTLEVELS + XCHAL_HAVE_NMI) >= 2}
    epc: array[0..XCHAL_NUM_INTLEVELS + XCHAL_HAVE_NMI - 2] of int32;
    eps:  array[0..XCHAL_NUM_INTLEVELS + XCHAL_HAVE_NMI - 2] of int32;
    excsave: array[0..XCHAL_NUM_INTLEVELS + XCHAL_HAVE_NMI - 2] of int32;
  {$endif}
  {$if defined(XCHAL_HAVE_LOOPS)}
    lcount: int32;
    lbeg: int32;
    lend: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_ABSOLUTE_LITERALS)}
    litbase: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_VECBASE)}
    vecbase: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_S32C1I) and (XCHAL_HW_MIN_VERSION >= XTENSA_HWVERSION_RC_2009_0)}
    atomctl: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_PREFETCH)}
    prefctl: int32;
  {$endif}
  {$if defined(XCHAL_USE_MEMCTL)}
    memctl: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_CCOUNT)}
    ccount: int32;
    ccompare: array[0..XCHAL_NUM_TIMERS-1] of int32;
  {$endif}
  {$if defined(XCHAL_HAVE_INTERRUPTS)}
    long,4,CS_SA_,intenable)
    long,4,CS_SA_,interrupt)
  {$endif}
  {$if defined(XCHAL_HAVE_DEBUG)}
    icount: int32;
    icountlevel: int32;
    debugcause: int32;
  // DDR not saved
  // if XCHAL_NUM_DBREAK
    dbreakc: array[0..XCHAL_NUM_DBREAK-1] of int32;
    dbreaka: array[0..XCHAL_NUM_DBREAK-1] of int32;
  // endif
  // if XCHAL_NUM_IBREAK
    ibreaka: array[0..XCHAL_NUM_IBREAK-1] of int32;
    ibreakenable: int32;
  // endif
  {$endif}
  {$if defined(XCHAL_NUM_MISC_REGS)}
    misc: array[0..XCHAL_NUM_MISC_REGS-1] of int32;
  {$endif}
  {$if defined(XCHAL_HAVE_MEM_ECC_PARITY)}
    mepc: int32;
    meps: int32;
    mesave: int32;
    mesr: int32;
    mecr: int32;
    mevaddr: int32;
  {$endif}

  {$if defined(XCHAL_HAVE_CP)}
    cpenable: int32;
  {$endif}

  {$if defined(XCHAL_HAVE_MIMIC_CACHEATTR) or defined(XCHAL_HAVE_XLT_CACHEATTR)}
    tlbs: array[0..8*2-1] of int32;
  {$endif}
  {$if defined(XCHAL_HAVE_PTP_MMU)}
  //  if XCHAL_DTLB_ARF_ENTRIES_LOG2 + XCHAL_ITLB_ARF_ENTRIES_LOG2 > 4
  //   define ARF_ENTRIES	8
  //  else
  //   define ARF_ENTRIES	4
  //  endif
    ptevaddr: int32;
    rasid: int32;
    dtlbcfg: int32;
    itlbcfg: int32;
    tlbs: array[0..((4*ARF_ENTRIES+4)*2+3)*2)-1] of int32;
  // if XCHAL_HAVE_SPANNING_WAY	/* MMU v3 */
    tlbs_ways56: array[0..(4+8)*2*2-1] of int32;
  // endif
  {$endif}
  {$if defined(XCHAL_HAVE_MPU)}
    mpuentry: array[0..8*XCHAL_MPU_ENTRIES-1] of int32;
    cacheadrdis: int32;
  {$endif}
  {$if defined(XCHAL_HAVE_IDMA)}
    idmaregs: array[0..IDMA_PSO_SAVE_SIZE-1] of int32;
  {$endif}
    ncp: array[0..XCHAL_NCP_SA_SIZE-1] of char;
  {$if defined(XCHAL_HAVE_CP)}
  {$if (XCHAL_CP0_SA_SIZE > 0)}
    cp0: array[0..XCHAL_CP0_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP1_SA_SIZE > 0)}
    cp1: array[0..XCHAL_CP1_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP2_SA_SIZE > 0)}
    cp2: array[0..XCHAL_CP2_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP3_SA_SIZE > 0)}
    cp3: array[0..XCHAL_CP3_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP4_SA_SIZE > 0)}
    cp4: array[0..XCHAL_CP4_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP5_SA_SIZE > 0)}
    cp5: array[0..XCHAL_CP5_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP6_SA_SIZE > 0)}
    cp6: array[0..XCHAL_CP6_SA_SIZE-1] of char;
  {$endif}
  {$if (XCHAL_CP7_SA_SIZE > 0)}
    cp7: array[0..XCHAL_CP7_SA_SIZE-1] of char;
  {$endif}
  {$endif}
  end;

implementation

end.
