unit hal;

interface

const
  XTHAL_RELEASE_MAJOR = 12000;
  XTHAL_RELEASE_MINOR = 9;
  XTHAL_RELEASE_NAME = '12.0.9';
  XTHAL_REL_12 = 1;
  XTHAL_REL_12_0 = 1;
  XTHAL_REL_12_0_9 = 1;
  XTHAL_MAJOR_REV = XTHAL_RELEASE_MAJOR;
  XTHAL_MINOR_REV = XTHAL_RELEASE_MINOR;
  XTHAL_MAYBE = -(1);
  XTHAL_MAX_CPS = 8;
  XTHAL_LITTLEENDIAN = 0;
  XTHAL_BIGENDIAN = 1;
  XTHAL_PREFETCH_ENABLE = -(1);
  XTHAL_PREFETCH_DISABLE = $FFFF0000;
  XTHAL_DCACHE_PREFETCH_L1_OFF = $90000000;
  XTHAL_DCACHE_PREFETCH_L1 = $90001000;
  XTHAL_ICACHE_PREFETCH_L1_OFF = $A0000000;
  XTHAL_ICACHE_PREFETCH_L1 = $A0002000;
  XTHAL_DISASM_BUFSIZE = 80;
  XTHAL_DISASM_OPT_ADDR = $0001;
  XTHAL_DISASM_OPT_OPHEX = $0002;
  XTHAL_DISASM_OPT_OPCODE = $0004;
  XTHAL_DISASM_OPT_PARMS = $0008;
  XTHAL_DISASM_OPT_ALL = $0FFF;

var
  Xthal_rev_no: uint32; cvar; external;
  Xthal_cpregs_save_fn: array[0..(XTHAL_MAX_CPS)-1] of pointer; cvar; external;
  Xthal_cpregs_restore_fn: array[0..(XTHAL_MAX_CPS)-1] of pointer; cvar; external;
  Xthal_cpregs_save_nw_fn: array[0..(XTHAL_MAX_CPS)-1] of pointer; cvar; external;
  Xthal_cpregs_restore_nw_fn: array[0..(XTHAL_MAX_CPS)-1] of pointer; cvar; external;
  Xthal_extra_size: uint32; cvar; external;
  Xthal_extra_align: uint32; cvar; external;
  Xthal_cpregs_size: array[0..(XTHAL_MAX_CPS)-1] of uint32; cvar; external;
  Xthal_cpregs_align: array[0..(XTHAL_MAX_CPS)-1] of uint32; cvar; external;
  Xthal_all_extra_size: uint32; cvar; external;
  Xthal_all_extra_align: uint32; cvar; external;
  Xthal_cp_names: array[0..(XTHAL_MAX_CPS)-1] of PChar; cvar; external;
  Xthal_num_coprocessors: uint32; cvar; external;
  Xthal_cp_num: byte; cvar; external;
  Xthal_cp_max: byte; cvar; external;
  Xthal_cp_mask: uint32; cvar; external;
  Xthal_num_aregs: uint32; cvar; external;
  Xthal_num_aregs_log2: byte; cvar; external;
  Xthal_icache_linewidth: byte; cvar; external;
  Xthal_dcache_linewidth: byte; cvar; external;
  Xthal_icache_linesize: uint16; cvar; external;
  Xthal_dcache_linesize: uint16; cvar; external;
  Xthal_icache_size: uint32; cvar; external;
  Xthal_dcache_size: uint32; cvar; external;
  Xthal_dcache_is_writeback: byte; cvar; external;
  Xthal_debug_configured: int32; cvar; external;
  Xthal_release_major_var: uint32; cvar; external;
  Xthal_release_minor_var: uint32; cvar; external;
  Xthal_release_name_var: PChar; cvar; external;
  Xthal_release_internal: PChar; cvar; external;
  Xthal_memory_order: byte; cvar; external;
  Xthal_have_windowed: byte; cvar; external;
  Xthal_have_density: byte; cvar; external;
  Xthal_have_booleans: byte; cvar; external;
  Xthal_have_loops: byte; cvar; external;
  Xthal_have_nsa: byte; cvar; external;
  Xthal_have_minmax: byte; cvar; external;
  Xthal_have_sext: byte; cvar; external;
  Xthal_have_clamps: byte; cvar; external;
  Xthal_have_mac16: byte; cvar; external;
  Xthal_have_mul16: byte; cvar; external;
  Xthal_have_fp: byte; cvar; external;
  Xthal_have_threadptr: byte; cvar; external;
  Xthal_have_pif: byte; cvar; external;
  Xthal_num_writebuffer_entries: uint16; cvar; external;
  Xthal_build_unique_id: uint32; cvar; external;
  Xthal_hw_configid0: uint32; cvar; external;
  Xthal_hw_configid1: uint32; cvar; external;
  Xthal_hw_release_major: uint32; cvar; external;
  Xthal_hw_release_minor: uint32; cvar; external;
  Xthal_hw_release_name: PChar; cvar; external;
  Xthal_hw_release_internal: PChar; cvar; external;

procedure xthal_save_extra(base: pointer); cdecl; external;
procedure xthal_restore_extra(base: pointer); cdecl; external;
procedure xthal_save_cpregs(base: pointer; para2: int32); cdecl; external;
procedure xthal_restore_cpregs(base: pointer; para2: int32); cdecl; external;
procedure xthal_save_cp0(base: pointer); cdecl; external;
procedure xthal_save_cp1(base: pointer); cdecl; external;
procedure xthal_save_cp2(base: pointer); cdecl; external;
procedure xthal_save_cp3(base: pointer); cdecl; external;
procedure xthal_save_cp4(base: pointer); cdecl; external;
procedure xthal_save_cp5(base: pointer); cdecl; external;
procedure xthal_save_cp6(base: pointer); cdecl; external;
procedure xthal_save_cp7(base: pointer); cdecl; external;
procedure xthal_restore_cp0(base: pointer); cdecl; external;
procedure xthal_restore_cp1(base: pointer); cdecl; external;
procedure xthal_restore_cp2(base: pointer); cdecl; external;
procedure xthal_restore_cp3(base: pointer); cdecl; external;
procedure xthal_restore_cp4(base: pointer); cdecl; external;
procedure xthal_restore_cp5(base: pointer); cdecl; external;
procedure xthal_restore_cp6(base: pointer); cdecl; external;
procedure xthal_restore_cp7(base: pointer); cdecl; external;
procedure xthal_init_mem_extra(para1: pointer); cdecl; external;
procedure xthal_init_mem_cp(para1: pointer; para2: int32); cdecl; external;
procedure xthal_icache_region_invalidate(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_region_invalidate(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_region_writeback(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_region_writeback_inv(addr: pointer; size: uint32);
  cdecl; external;
{$ifndef XTHAL_USE_CACHE_MACROS}
procedure xthal_icache_line_invalidate(addr: pointer); cdecl; external;
procedure xthal_dcache_line_invalidate(addr: pointer); cdecl; external;
procedure xthal_dcache_line_writeback(addr: pointer); cdecl; external;
procedure xthal_dcache_line_writeback_inv(addr: pointer); cdecl; external;
procedure xthal_icache_sync; cdecl; external;
procedure xthal_dcache_sync; cdecl; external;
{$endif}
function xthal_icache_get_ways: uint32; cdecl; external;
procedure xthal_icache_set_ways(ways: uint32); cdecl; external;
function xthal_dcache_get_ways: uint32; cdecl; external;
procedure xthal_dcache_set_ways(ways: uint32); cdecl; external;
procedure xthal_cache_coherence_on; cdecl; external;
procedure xthal_cache_coherence_off; cdecl; external;
procedure xthal_cache_coherence_optin; cdecl; external;
procedure xthal_cache_coherence_optout; cdecl; external;

function XTHAL_DCACHE_PREFETCH(n: longint): longint;
function XTHAL_DCACHE_PREFETCH_OFF: longint;
function XTHAL_DCACHE_PREFETCH_LOW: longint;
function XTHAL_DCACHE_PREFETCH_MEDIUM: longint;
function XTHAL_DCACHE_PREFETCH_HIGH: longint;
function XTHAL_ICACHE_PREFETCH(n: longint): longint;
function XTHAL_ICACHE_PREFETCH_OFF: longint;
function XTHAL_ICACHE_PREFETCH_LOW: longint;
function XTHAL_ICACHE_PREFETCH_MEDIUM: longint;
function XTHAL_ICACHE_PREFETCH_HIGH: longint;
function _XTHAL_PREFETCH_BLOCKS(n: longint): longint;
function XTHAL_PREFETCH_BLOCKS(n: longint): qword;

// Should use the _long variant.
function xthal_get_cache_prefetch: int32; cdecl; external;
function xthal_set_cache_prefetch(para1: int32): int32; cdecl; external;
function xthal_set_cache_prefetch_long(para1: uint64): int32; cdecl; external;
function xthal_set_soft_break(addr: pointer): uint32; cdecl; external;
procedure xthal_remove_soft_break(addr: pointer; para2: uint32); cdecl; external;
function xthal_disassemble(instr_buf: PByte; tgt_addr: pointer;
  buffer: PChar; buflen: uint32; options: uint32): int32; cdecl; external;
function xthal_disassemble_size(instr_buf: PByte): int32; cdecl; external;
function xthal_memcpy(dst: pointer; src: pointer; len: uint32): pointer; cdecl; external;
function xthal_bcopy(src: pointer; dst: pointer; len: uint32): pointer; cdecl; external;
function xthal_compare_and_set(addr: PInt32; test_val: int32;
  compare_val: int32): int32; cdecl; external;
procedure xthal_clear_regcached_code; cdecl; external;

{$ifndef XTENSA_HAL_NON_PRIVILEGED_ONLY}
const
  XTHAL_MAX_INTERRUPTS = 32;
  XTHAL_MAX_INTLEVELS = 16;
  XTHAL_MAX_TIMERS = 4;
  XTHAL_INTTYPE_UNCONFIGURED = 0;
  XTHAL_INTTYPE_SOFTWARE = 1;
  XTHAL_INTTYPE_EXTERN_EDGE = 2;
  XTHAL_INTTYPE_EXTERN_LEVEL = 3;
  XTHAL_INTTYPE_TIMER = 4;
  XTHAL_INTTYPE_NMI = 5;
  XTHAL_INTTYPE_WRITE_ERROR = 6;
  XTHAL_INTTYPE_PROFILING = 7;
  XTHAL_INTTYPE_IDMA_DONE = 8;
  XTHAL_INTTYPE_IDMA_ERR = 9;
  XTHAL_INTTYPE_GS_ERR = 10;
  XTHAL_INTTYPE_SG_ERR = 10;
  XTHAL_MAX_INTTYPES = 11;
  XTHAL_TIMER_UNCONFIGURED = -(1);
  XTHAL_TIMER_UNASSIGNED = XTHAL_TIMER_UNCONFIGURED;
  XTHAL_MEMEP_PARITY = 1;
  XTHAL_MEMEP_ECC = 2;
  XTHAL_MEMEP_F_LOCAL = 0;
  XTHAL_MEMEP_F_DCACHE_DATA = 4;
  XTHAL_MEMEP_F_DCACHE_TAG = 5;
  XTHAL_MEMEP_F_ICACHE_DATA = 6;
  XTHAL_MEMEP_F_ICACHE_TAG = 7;
  XTHAL_MEMEP_F_CORRECTABLE = 16;
  XTHAL_AMB_EXCEPTION = 0;
  XTHAL_AMB_HITCACHE = 1;
  XTHAL_AMB_ALLOCATE = 2;
  XTHAL_AMB_WRITETHRU = 3;
  XTHAL_AMB_ISOLATE = 4;
  XTHAL_AMB_GUARD = 5;
  XTHAL_AMB_COHERENT = 6;
  XTHAL_AM_EXCEPTION = 1 shl XTHAL_AMB_EXCEPTION;
  XTHAL_AM_HITCACHE = 1 shl XTHAL_AMB_HITCACHE;
  XTHAL_AM_ALLOCATE = 1 shl XTHAL_AMB_ALLOCATE;
  XTHAL_AM_WRITETHRU = 1 shl XTHAL_AMB_WRITETHRU;
  XTHAL_AM_ISOLATE = 1 shl XTHAL_AMB_ISOLATE;
  XTHAL_AM_GUARD = 1 shl XTHAL_AMB_GUARD;
  XTHAL_AM_COHERENT = 1 shl XTHAL_AMB_COHERENT;
  XTHAL_FAM_EXCEPTION = $001;
  XTHAL_FAM_BYPASS = $000;
  XTHAL_FAM_CACHED = $006;
  XTHAL_LAM_EXCEPTION = $001;
  XTHAL_LAM_ISOLATE = $012;
  XTHAL_LAM_BYPASS = $000;
  XTHAL_LAM_BYPASSG = $020;
  XTHAL_LAM_CACHED_NOALLOC = $002;
  XTHAL_LAM_NACACHED = XTHAL_LAM_CACHED_NOALLOC;
  XTHAL_LAM_NACACHEDG = $022;
  XTHAL_LAM_CACHED = $006;
  XTHAL_LAM_COHCACHED = $046;
  XTHAL_SAM_EXCEPTION = $001;
  XTHAL_SAM_ISOLATE = $032;
  XTHAL_SAM_BYPASS = $028;
  XTHAL_SAM_WRITETHRU = $02A;
  XTHAL_SAM_WRITEBACK = $026;
  XTHAL_SAM_WRITEBACK_NOALLOC = $022;
  XTHAL_SAM_COHWRITEBACK = $066;
  XTHAL_PAM_BYPASS = $000;
  XTHAL_PAM_BYPASS_BUF = $010;
  XTHAL_PAM_CACHED_NOALLOC = $030;
  XTHAL_PAM_WRITETHRU = $0B0;
  XTHAL_PAM_WRITEBACK_NOALLOC = $0F0;
  XTHAL_PAM_WRITEBACK = $1F0;
  XTHAL_CAFLAG_EXPAND = $000100;
  XTHAL_CAFLAG_EXACT = $000200;
  XTHAL_CAFLAG_NO_PARTIAL = $000400;
  XTHAL_CAFLAG_NO_AUTO_WB = $000800;
  XTHAL_CAFLAG_NO_AUTO_INV = $001000;
  XTHAL_SUCCESS = 0;
  XTHAL_NO_REGIONS_COVERED = -(1);
  XTHAL_INEXACT = -(2);
  XTHAL_INVALID_ADDRESS = -(3);
  XTHAL_UNSUPPORTED = -(4);
  XTHAL_ADDRESS_MISALIGNED = -(5);
  XTHAL_NO_MAPPING = -(6);
  XTHAL_BAD_ACCESS_RIGHTS = -(7);
  XTHAL_BAD_MEMORY_TYPE = -(8);
  XTHAL_MAP_NOT_ALIGNED = -(9);
  XTHAL_OUT_OF_ENTRIES = -(10);
  XTHAL_OUT_OF_ORDER_MAP = -(11);
  XTHAL_INVALID = -(12);
  XTHAL_ZERO_SIZED_REGION = -(13);
  XTHAL_INVALID_ADDRESS_RANGE = -(14);
  XCHAL_SUCCESS = XTHAL_SUCCESS;
  XCHAL_ADDRESS_MISALIGNED = XTHAL_ADDRESS_MISALIGNED;
  XCHAL_INEXACT = XTHAL_INEXACT;
  XCHAL_INVALID_ADDRESS = XTHAL_INVALID_ADDRESS;
  XCHAL_UNSUPPORTED_ON_THIS_ARCH = XTHAL_UNSUPPORTED;
  XCHAL_NO_PAGES_MAPPED = XTHAL_NO_REGIONS_COVERED;
  XTHAL_AR_NONE = 0;
  XTHAL_AR_R = 4;
  XTHAL_AR_RX = 5;
  XTHAL_AR_RW = 6;
  XTHAL_AR_RWX = 7;
  XTHAL_AR_Ww = 8;
  XTHAL_AR_RWrwx = 9;
  XTHAL_AR_RWr = 10;
  XTHAL_AR_RWXrx = 11;
  XTHAL_AR_Rr = 12;
  XTHAL_AR_RXrx = 13;
  XTHAL_AR_RWrw = 14;
  XTHAL_AR_RWXrwx = 15;
  XTHAL_AR_WIDTH = 4;
  XTHAL_MPU_USE_EXISTING_ACCESS_RIGHTS = $00002000;
  XTHAL_MPU_USE_EXISTING_MEMORY_TYPE = $00004000;
  XTHAL_MEM_DEVICE = $00008000;
  XTHAL_MEM_NON_CACHEABLE = $00090000;
  XTHAL_MEM_WRITETHRU_NOALLOC = $00080000;
  XTHAL_MEM_WRITETHRU = $00040000;
  XTHAL_MEM_WRITETHRU_WRITEALLOC = $00060000;
  XTHAL_MEM_WRITEBACK_NOALLOC = $00050000;
  XTHAL_MEM_WRITEBACK = $00070000;
  XTHAL_MEM_INTERRUPTIBLE = $08000000;
  XTHAL_MEM_BUFFERABLE = $01000000;
  XTHAL_MEM_NON_SHAREABLE = $00000000;
  XTHAL_MEM_INNER_SHAREABLE = $02000000;
  XTHAL_MEM_OUTER_SHAREABLE = $04000000;
  XTHAL_MEM_SYSTEM_SHAREABLE = $06000000;
  _XTHAL_SYSTEM_CACHE_BITS = $000f0000;
  _XTHAL_LOCAL_CACHE_BITS = $00f00000;
  _XTHAL_MEM_SYSTEM_RWC_MASK = $00070000;
  _XTHAL_MEM_LOCAL_RWC_MASK = $00700000;
  _XTHAL_SHIFT_RWC = 16;
  XTHAL_MEM_NON_CACHED = XTHAL_MEM_NON_CACHEABLE;
  XTHAL_MEM_NON_SHARED = XTHAL_MEM_NON_SHAREABLE;
  XTHAL_MEM_INNER_SHARED = XTHAL_MEM_INNER_SHAREABLE;
  XTHAL_MEM_OUTER_SHARED = XTHAL_MEM_OUTER_SHAREABLE;
  XTHAL_MEM_SYSTEM_SHARED = XTHAL_MEM_SYSTEM_SHAREABLE;
  XTHAL_MEM_SW_SHAREABLE = 0;

type
  XtHalVoidFunc = procedure();
  PXtHalVoidFunc = ^XtHalVoidFunc;

  Pxthal_MPU_entry = ^Txthal_MPU_entry;
  Txthal_MPU_entry = record
    as_: uint32;
    at: uint32;
  end;

var
  Xthal_num_intlevels: byte; cvar; external;
  Xthal_num_interrupts: byte; cvar; external;
  Xthal_excm_level: byte; cvar; external;
  Xthal_intlevel_mask: array[0..(XTHAL_MAX_INTLEVELS)-1] of uint32; cvar; external;
  Xthal_intlevel_andbelow_mask: array[0..(XTHAL_MAX_INTLEVELS)-1] of uint32; cvar; external;
  Xthal_intlevel: array[0..(XTHAL_MAX_INTERRUPTS)-1] of byte; cvar; external;
  Xthal_inttype: array[0..(XTHAL_MAX_INTERRUPTS)-1] of byte; cvar; external;
  Xthal_inttype_mask: array[0..(XTHAL_MAX_INTTYPES)-1] of uint32; cvar; external;
  Xthal_timer_interrupt: array[0..(XTHAL_MAX_TIMERS)-1] of int32; cvar; external;
  Xthal_num_ibreak: int32; cvar; external;
  Xthal_num_dbreak: int32; cvar; external;
  Xthal_have_ccount: byte; cvar; external;
  Xthal_num_ccompare: byte; cvar; external;
  Xthal_have_prid: byte; cvar; external;
  Xthal_have_exceptions: byte; cvar; external;
  Xthal_xea_version: byte; cvar; external;
  Xthal_have_interrupts: byte; cvar; external;
  Xthal_have_highlevel_interrupts: byte; cvar; external;
  Xthal_have_nmi: byte; cvar; external;
  Xthal_tram_pending: uint32; cvar; external;
  Xthal_tram_enabled: uint32; cvar; external;
  Xthal_tram_sync: uint32; cvar; external;
  Xthal_num_instrom: byte; cvar; external;
  Xthal_num_instram: byte; cvar; external;
  Xthal_num_datarom: byte; cvar; external;
  Xthal_num_dataram: byte; cvar; external;
  Xthal_num_xlmi: byte; cvar; external;
  Xthal_instrom_vaddr: PUint32; cvar; external;
  Xthal_instrom_paddr: PUint32; cvar; external;
  Xthal_instrom_size: PUint32; cvar; external;
  Xthal_instram_vaddr: PUint32; cvar; external;
  Xthal_instram_paddr: PUint32; cvar; external;
  Xthal_instram_size: PUint32; cvar; external;
  Xthal_datarom_vaddr: PUint32; cvar; external;
  Xthal_datarom_paddr: PUint32; cvar; external;
  Xthal_datarom_size: PUint32; cvar; external;
  Xthal_dataram_vaddr: PUint32; cvar; external;
  Xthal_dataram_paddr: PUint32; cvar; external;
  Xthal_dataram_size: PUint32; cvar; external;
  Xthal_xlmi_vaddr: PUint32; cvar; external;
  Xthal_xlmi_paddr: PUint32; cvar; external;
  Xthal_xlmi_size: PUint32; cvar; external;
  Xthal_icache_setwidth: byte; cvar; external;
  Xthal_dcache_setwidth: byte; cvar; external;
  Xthal_icache_ways: uint32; cvar; external;
  Xthal_dcache_ways: uint32; cvar; external;
  Xthal_icache_line_lockable: byte; cvar; external;
  Xthal_dcache_line_lockable: byte; cvar; external;
  Xthal_have_spanning_way: byte; cvar; external;
  Xthal_have_identity_map: byte; cvar; external;
  Xthal_have_mimic_cacheattr: byte; cvar; external;
  Xthal_have_xlt_cacheattr: byte; cvar; external;
  Xthal_have_cacheattr: byte; cvar; external;
  Xthal_have_tlbs: byte; cvar; external;
  Xthal_mmu_asid_bits: byte; cvar; external;
  Xthal_mmu_asid_kernel: byte; cvar; external;
  Xthal_mmu_rings: byte; cvar; external;
  Xthal_mmu_ring_bits: byte; cvar; external;
  Xthal_mmu_sr_bits: byte; cvar; external;
  Xthal_mmu_ca_bits: byte; cvar; external;
  Xthal_mmu_max_pte_page_size: uint32; cvar; external;
  Xthal_mmu_min_pte_page_size: uint32; cvar; external;
  Xthal_itlb_way_bits: byte; cvar; external;
  Xthal_itlb_ways: byte; cvar; external;
  Xthal_itlb_arf_ways: byte; cvar; external;
  Xthal_dtlb_way_bits: byte; cvar; external;
  Xthal_dtlb_ways: byte; cvar; external;
  Xthal_dtlb_arf_ways: byte; cvar; external;
  Xthal_mpu_bgmap: Pxthal_MPU_entry; cvar; external;

procedure xthal_window_spill; cdecl; external;
procedure xthal_validate_cp(para1: int32); cdecl; external;
procedure xthal_invalidate_cp(para1: int32); cdecl; external;
procedure xthal_set_cpenable(para1: uint32); cdecl; external;
function xthal_get_cpenable: uint32; cdecl; external;
function xthal_get_intenable: uint32; cdecl; external;
procedure xthal_set_intenable(para1: uint32); cdecl; external;
function xthal_get_interrupt: uint32; cdecl; external;
procedure xthal_set_intset(para1: uint32); cdecl; external;
procedure xthal_set_intclear(para1: uint32); cdecl; external;
function xthal_get_ccount: uint32; cdecl; external;
procedure xthal_set_ccompare(para1: int32; para2: uint32); cdecl; external;
function xthal_get_ccompare(para1: int32): uint32; cdecl; external;
function xthal_get_prid: uint32; cdecl; external;
function xthal_vpri_to_intlevel(vpri: uint32): uint32; cdecl; external;
function xthal_intlevel_to_vpri(intlevel: uint32): uint32; cdecl; external;
function xthal_int_enable(para1: uint32): uint32; cdecl; external;
function xthal_int_disable(para1: uint32): uint32; cdecl; external;
function xthal_set_int_vpri(intnum: int32; vpri: int32): int32; cdecl; external;
function xthal_get_int_vpri(intnum: int32): int32; cdecl; external;
procedure xthal_set_vpri_locklevel(intlevel: uint32); cdecl; external;
function xthal_get_vpri_locklevel: uint32; cdecl; external;
function xthal_set_vpri(vpri: uint32): uint32; cdecl; external;
function xthal_get_vpri: uint32; cdecl; external;
function xthal_set_vpri_intlevel(intlevel: uint32): uint32; cdecl; external;
function xthal_set_vpri_lock: uint32; cdecl; external;
function xthal_tram_pending_to_service: uint32; cdecl; external;
procedure xthal_tram_done(serviced_mask: uint32); cdecl; external;
function xthal_tram_set_sync(intnum: int32; sync: int32): int32; cdecl; external;
function xthal_set_tram_trigger_func(trigger_fn: PXtHalVoidFunc): PXtHalVoidFunc;
  cdecl; external;
function xthal_get_cacheattr: uint32; cdecl; external;
function xthal_get_icacheattr: uint32; cdecl; external;
function xthal_get_dcacheattr: uint32; cdecl; external;
procedure xthal_set_cacheattr(para1: uint32); cdecl; external;
procedure xthal_set_icacheattr(para1: uint32); cdecl; external;
procedure xthal_set_dcacheattr(para1: uint32); cdecl; external;
function xthal_set_region_attribute(addr: pointer; size: uint32;
  cattr: uint32; flags: uint32): int32; cdecl; external;
procedure xthal_icache_enable; cdecl; external;
procedure xthal_dcache_enable; cdecl; external;
procedure xthal_icache_disable; cdecl; external;
procedure xthal_dcache_disable; cdecl; external;
procedure xthal_icache_all_invalidate; cdecl; external;
procedure xthal_dcache_all_invalidate; cdecl; external;
procedure xthal_dcache_all_writeback; cdecl; external;
procedure xthal_dcache_all_writeback_inv; cdecl; external;
procedure xthal_icache_all_unlock; cdecl; external;
procedure xthal_dcache_all_unlock; cdecl; external;
procedure xthal_icache_region_lock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_region_lock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_icache_region_unlock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_region_unlock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_icache_hugerange_invalidate(addr: pointer; size: uint32);
  cdecl; external;
procedure xthal_icache_hugerange_unlock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_hugerange_invalidate(addr: pointer; size: uint32);
  cdecl; external;
procedure xthal_dcache_hugerange_unlock(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_hugerange_writeback(addr: pointer; size: uint32); cdecl; external;
procedure xthal_dcache_hugerange_writeback_inv(addr: pointer;
  size: uint32); cdecl; external;
{$ifndef XTHAL_USE_CACHE_MACROS}
procedure xthal_icache_line_lock(addr: pointer); cdecl; external;
procedure xthal_dcache_line_lock(addr: pointer); cdecl; external;
procedure xthal_icache_line_unlock(addr: pointer); cdecl; external;
procedure xthal_dcache_line_unlock(addr: pointer); cdecl; external;
{$endif}
procedure xthal_memep_inject_error(addr: pointer; size: int32; flags: int32); cdecl; external;
function xthal_static_v2p(vaddr: uint32; paddrp: PUint32): int32; cdecl; external;
function xthal_static_p2v(paddr: uint32; vaddrp: PUint32;
  cached: uint32): int32; cdecl; external;
function xthal_set_region_translation(vaddr: pointer; paddr: pointer;
  size: uint32; cache_atr: uint32; flags: uint32): int32; cdecl; external;
function xthal_v2p(para1: pointer; para2: Ppointer; para3: PUint32;
  para4: PUint32): int32; cdecl; external;
function xthal_invalidate_region(addr: pointer): int32; cdecl; external;
function xthal_set_region_translation_raw(vaddr: pointer; paddr: pointer;
  cattr: uint32): int32; cdecl; external;
function XTHAL_MEM_PROC_CACHE(system, processor: longint): longint;
//function XTHAL_ENCODE_MEMORY_TYPE(x: longint): longint;
function XTHAL_MPU_ENTRY_GET_VSTARTADDR(x: Txthal_MPU_entry): longint;
function XTHAL_MPU_ENTRY_GET_VALID(x: Txthal_MPU_entry): longint;
function XTHAL_MPU_ENTRY_GET_ACCESS(x: Txthal_MPU_entry): longint;
procedure XTHAL_MPU_ENTRY_SET_ACCESS(var x: Txthal_MPU_entry; accessRights: longint);
function XTHAL_MPU_ENTRY_GET_MEMORY_TYPE(x: Txthal_MPU_entry): longint;
procedure XTHAL_MPU_ENTRY_SET_MEMORY_TYPE(var x: Txthal_MPU_entry; memtype: longint);

function xthal_is_kernel_readable(accessRights: uint32): int32; cdecl; external;
function xthal_is_kernel_writeable(accessRights: uint32): int32; cdecl; external;
function xthal_is_kernel_executable(accessRights: uint32): int32; cdecl; external;
function xthal_is_user_readable(accessRights: uint32): int32; cdecl; external;
function xthal_is_user_writeable(accessRights: uint32): int32; cdecl; external;
function xthal_is_user_executable(accessRights: uint32): int32; cdecl; external;
function xthal_encode_memory_type(x: uint32): int32; cdecl; external;
function xthal_is_cacheable(memoryType: uint32): int32; cdecl; external;
function xthal_is_writeback(memoryType: uint32): int32; cdecl; external;
function xthal_is_device(memoryType: uint32): int32; cdecl; external;
function xthal_read_map(entries: Pxthal_MPU_entry): int32; cdecl; external;
procedure xthal_write_map(entries: Pxthal_MPU_entry; n: uint32); cdecl; external;
function xthal_check_map(entries: Pxthal_MPU_entry; n: uint32): int32; cdecl; external;
function xthal_get_entry_for_address(vaddr: pointer;
  infgmap: Pint32): Txthal_MPU_entry; cdecl; external;
function xthal_calc_cacheadrdis(e: Pxthal_MPU_entry; n: uint32): uint32;
  cdecl; external;
function xthal_mpu_set_region_attribute(vaddr: pointer; size: uint32;
  accessRights: int32; memoryType: int32; flags: uint32): int32; cdecl; external;

function _XTHAL_MEM_ANY_SHAREABLE(x: longint): boolean;
function _XTHAL_MEM_INNER_SHAREABLE(x: longint): boolean;
function _XTHAL_MEM_IS_BUFFERABLE(x: longint): boolean;
function _XTHAL_MEM_IS_DEVICE(x: longint): boolean;
function _XTHAL_NON_CACHEABLE_DOMAIN(x: longint): longint;
function _XTHAL_CACHEABLE_DOMAIN(x: longint): longint;
function _XTHAL_MEM_CACHE_MASK(x: longint): longint;
function _XTHAL_IS_SYSTEM_NONCACHEABLE(x: longint): boolean;
function _XTHAL_ENCODE_DEVICE(x: longint): longint;
function _XTHAL_ENCODE_SYSTEM_NONCACHEABLE(x: longint): longint;
function _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE(x: longint): longint;
function xthal_is_cached(memoryType: longint): longint;

function xthal_read_background_map(entries: Pxthal_MPU_entry): int32; cdecl; external;
{$endif}

implementation

function XTHAL_DCACHE_PREFETCH(n: longint): longint;
begin
  XTHAL_DCACHE_PREFETCH := $800F0000 + (n and $F);
end;

function XTHAL_DCACHE_PREFETCH_OFF: longint;
begin
  XTHAL_DCACHE_PREFETCH_OFF := XTHAL_DCACHE_PREFETCH(0);
end;

function XTHAL_DCACHE_PREFETCH_LOW: longint;
begin
  XTHAL_DCACHE_PREFETCH_LOW := XTHAL_DCACHE_PREFETCH(4);
end;

function XTHAL_DCACHE_PREFETCH_MEDIUM: longint;
begin
  XTHAL_DCACHE_PREFETCH_MEDIUM := XTHAL_DCACHE_PREFETCH(5);
end;

function XTHAL_DCACHE_PREFETCH_HIGH: longint;
begin
  XTHAL_DCACHE_PREFETCH_HIGH := XTHAL_DCACHE_PREFETCH(8);
end;

function XTHAL_ICACHE_PREFETCH(n: longint): longint;
begin
  XTHAL_ICACHE_PREFETCH := $80F00000 + ((n and $F) shl 4);
end;

function XTHAL_ICACHE_PREFETCH_OFF: longint;
begin
  XTHAL_ICACHE_PREFETCH_OFF := XTHAL_ICACHE_PREFETCH(0);
end;

function XTHAL_ICACHE_PREFETCH_LOW: longint;
begin
  XTHAL_ICACHE_PREFETCH_LOW := XTHAL_ICACHE_PREFETCH(4);
end;

function XTHAL_ICACHE_PREFETCH_MEDIUM: longint;
begin
  XTHAL_ICACHE_PREFETCH_MEDIUM := XTHAL_ICACHE_PREFETCH(5);
end;

function XTHAL_ICACHE_PREFETCH_HIGH: longint;
begin
  XTHAL_ICACHE_PREFETCH_HIGH := XTHAL_ICACHE_PREFETCH(8);
end;

// (n < 0 ? 0: [n<5 ? n: n < 15 ? (n>>1)+2: 9])
function _XTHAL_PREFETCH_BLOCKS(n: longint): longint;
begin
  if n < 0 then
    _XTHAL_PREFETCH_BLOCKS := 0
  else if n < 5 then
    _XTHAL_PREFETCH_BLOCKS := n
  else if n < 15 then
    _XTHAL_PREFETCH_BLOCKS := (n shr 1) + 2
  else
  _XTHAL_PREFETCH_BLOCKS := 9;
end;

function XTHAL_PREFETCH_BLOCKS(n: longint): qword;
begin
  XTHAL_PREFETCH_BLOCKS := $0F80000000 + (_XTHAL_PREFETCH_BLOCKS(n) shl 48);
end;

//#define XTHAL_MEM_PROC_CACHE(system, processor) \
//    ((system & 0x000f0000) | ((processor & 0x000f0000 ) << 4) | \
//    ((system & XTHAL_MEM_DEVICE) | (processor & XTHAL_MEM_DEVICE)))
function XTHAL_MEM_PROC_CACHE(system, processor: longint): longint;
begin
  XTHAL_MEM_PROC_CACHE:=
    ((system and $000f0000) or ((processor and $000f0000) shl 4) or
    ((system and XTHAL_MEM_DEVICE) or (processor and XTHAL_MEM_DEVICE)));
end;

// rather call external function
//function XTHAL_ENCODE_MEMORY_TYPE(x: longint): longint;
//var
//  if_local1, if_local2, if_local3: longint;
//  (* result types are not known *)
//begin
//  if _XTHAL_IS_SYSTEM_NONCACHEABLE(x) then
//    if_local1 := _XTHAL_ENCODE_SYSTEM_NONCACHEABLE(x)
//  else
//    if_local1 := _XTHAL_ENCODE_SYSTEM_CACHEABLE(x);
//  if _XTHAL_MEM_IS_DEVICE(x) then
//    if_local2 := _XTHAL_ENCODE_DEVICE(x)
//  else
//    if_local2 := if_local1;
//  if Tx(@($ffffe000)) then
//    if_local3 := if_local2
//  else
//    if_local3 := x;
//  XTHAL_ENCODE_MEMORY_TYPE := if_local3;
//end;


function XTHAL_MPU_ENTRY_GET_VSTARTADDR(x: Txthal_MPU_entry): longint;
begin
  XTHAL_MPU_ENTRY_GET_VSTARTADDR := x.as_ and $ffffffe0;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }

function XTHAL_MPU_ENTRY_GET_VALID(x: Txthal_MPU_entry): longint;
begin
  XTHAL_MPU_ENTRY_GET_VALID := x.as_ and $1;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }

function XTHAL_MPU_ENTRY_GET_ACCESS(x: Txthal_MPU_entry): longint;
begin
  XTHAL_MPU_ENTRY_GET_ACCESS := (x.at shr 8) and $f;
end;

//#define XTHAL_MPU_ENTRY_SET_ACCESS(x, accessRights) ((x).at = \
//        ((x).at & 0xfffff0ff) | (((accessRights) & 0xf) << 8))
procedure XTHAL_MPU_ENTRY_SET_ACCESS(var x: Txthal_MPU_entry; accessRights: longint);
begin
  x.at := (x.at and $fffff0ff) or ((accessRights and $f) shl 8);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }

function XTHAL_MPU_ENTRY_GET_MEMORY_TYPE(x: Txthal_MPU_entry): longint;
begin
  XTHAL_MPU_ENTRY_GET_MEMORY_TYPE := (x.at shr 12) and $1ff;
end;

//#define XTHAL_MPU_ENTRY_SET_MEMORY_TYPE(x, memtype) ((x).at = \
//        ((x).at & 0xffe00fff) | (((XTHAL_ENCODE_MEMORY_TYPE(memtype)) & 0x1ff) << 12))
procedure XTHAL_MPU_ENTRY_SET_MEMORY_TYPE(var x: Txthal_MPU_entry; memtype: longint);
begin
  x.at := (x.at and $ffe00fff) or ((XTHAL_ENCODE_MEMORY_TYPE(memtype) and $1ff) shl 12);
end;

//#define _XTHAL_MEM_ANY_SHAREABLE(x) (((x) & XTHAL_MEM_SYSTEM_SHAREABLE) ? 1: 0)
function _XTHAL_MEM_ANY_SHAREABLE(x: longint): boolean;
begin
  if (x and XTHAL_MEM_SYSTEM_SHAREABLE) = 0 then
    _XTHAL_MEM_ANY_SHAREABLE := false
  else
    _XTHAL_MEM_ANY_SHAREABLE := true;
end;

//#define _XTHAL_MEM_INNER_SHAREABLE(x) ((((x) & XTHAL_MEM_SYSTEM_SHAREABLE) \
//        == XTHAL_MEM_INNER_SHAREABLE) ? 1: 0)
function _XTHAL_MEM_INNER_SHAREABLE(x: longint): boolean;
begin
  if (x and XTHAL_MEM_SYSTEM_SHAREABLE) = XTHAL_MEM_INNER_SHAREABLE then
    _XTHAL_MEM_INNER_SHAREABLE := true
  else
    _XTHAL_MEM_INNER_SHAREABLE := false;
end;

function _XTHAL_MEM_IS_BUFFERABLE(x: longint): boolean;
begin
  if x and XTHAL_MEM_BUFFERABLE = 0 then
    _XTHAL_MEM_IS_BUFFERABLE := false
  else
    _XTHAL_MEM_IS_BUFFERABLE := true;
end;

function _XTHAL_MEM_IS_DEVICE(x: longint): boolean;
begin
  if x and XTHAL_MEM_DEVICE = 0 then
    _XTHAL_MEM_IS_DEVICE := false
  else
  _XTHAL_MEM_IS_DEVICE := true;
end;

//#define _XTHAL_NON_CACHEABLE_DOMAIN(x) \
//    (_XTHAL_MEM_IS_DEVICE(x) || _XTHAL_MEM_ANY_SHAREABLE(x)? 0x3: 0)
function _XTHAL_NON_CACHEABLE_DOMAIN(x: longint): longint;
begin
  if (_XTHAL_MEM_IS_DEVICE(x) or _XTHAL_MEM_ANY_SHAREABLE(x)) then
    _XTHAL_NON_CACHEABLE_DOMAIN := $3
  else
    _XTHAL_NON_CACHEABLE_DOMAIN := 0;
end;

function _XTHAL_CACHEABLE_DOMAIN(x: longint): longint;
begin
  if _XTHAL_MEM_ANY_SHAREABLE(x) then
    _XTHAL_CACHEABLE_DOMAIN := $3
  else
    _XTHAL_CACHEABLE_DOMAIN := $1;
end;

function _XTHAL_MEM_CACHE_MASK(x: longint): longint;
begin
  _XTHAL_MEM_CACHE_MASK := x and _XTHAL_SYSTEM_CACHE_BITS;
end;

//#define _XTHAL_IS_SYSTEM_NONCACHEABLE(x) \
//        (((_XTHAL_MEM_CACHE_MASK(x) & XTHAL_MEM_NON_CACHEABLE) == \
//                XTHAL_MEM_NON_CACHEABLE) ? 1: 0)
function _XTHAL_IS_SYSTEM_NONCACHEABLE(x: longint): boolean;
begin
  if (_XTHAL_MEM_CACHE_MASK(x) and XTHAL_MEM_NON_CACHEABLE) =
    XTHAL_MEM_NON_CACHEABLE then
    _XTHAL_IS_SYSTEM_NONCACHEABLE := true
  else
    _XTHAL_IS_SYSTEM_NONCACHEABLE := false;
end;

//#define _XTHAL_ENCODE_DEVICE(x) \
//         (((((x) & XTHAL_MEM_INTERRUPTIBLE) ? 1: 0) << 3) | \
//         (_XTHAL_NON_CACHEABLE_DOMAIN(x) << 1) | _XTHAL_MEM_IS_BUFFERABLE(x))
function _XTHAL_ENCODE_DEVICE(x: longint): longint;
begin
  if (x and XTHAL_MEM_INTERRUPTIBLE) = 1 then
    _XTHAL_ENCODE_DEVICE := 1
  else
    _XTHAL_ENCODE_DEVICE := 0;

  _XTHAL_ENCODE_DEVICE := (_XTHAL_ENCODE_DEVICE shl 3) or
    (_XTHAL_NON_CACHEABLE_DOMAIN(x) shl 1) or ord(_XTHAL_MEM_IS_BUFFERABLE(x));
end;

function _XTHAL_ENCODE_SYSTEM_NONCACHEABLE(x: longint): longint;
begin
  _XTHAL_ENCODE_SYSTEM_NONCACHEABLE:=
    ($18 or ((_XTHAL_NON_CACHEABLE_DOMAIN(x)) shl 1)) or ord(_XTHAL_MEM_IS_BUFFERABLE(x));
end;

//#define _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE(x) \
//        (_XTHAL_CACHEABLE_DOMAIN(x) << 7) | ((((x & _XTHAL_LOCAL_CACHE_BITS) ? \
//                (x & _XTHAL_LOCAL_CACHE_BITS): \
//                (_XTHAL_MEM_CACHE_MASK(x) << 4)) \
//        & (_XTHAL_MEM_LOCAL_RWC_MASK)) >> _XTHAL_SHIFT_RWC )
function _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE(x: longint): longint;
begin
  if x and _XTHAL_LOCAL_CACHE_BITS = 0 then
    _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE := _XTHAL_MEM_CACHE_MASK(x) shl 4
  else
    _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE := x and _XTHAL_LOCAL_CACHE_BITS;

  _XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE:=
    (_XTHAL_CACHEABLE_DOMAIN(x) shl 7) or
    ((_XTHAL_ENCODE_SYSTEM_CACHEABLE_LOCAL_CACHEABLE and
     _XTHAL_MEM_LOCAL_RWC_MASK) shr _XTHAL_SHIFT_RWC);
end;

function xthal_is_cached(memoryType: longint): longint;
begin
  xthal_is_cached := xthal_is_cacheable(memoryType);
end;

end.
