unit esp_heap_caps;

interface

uses
  multi_heap;

const
  MALLOC_CAP_EXEC = 1 shl 0;
  MALLOC_CAP_32BIT = 1 shl 1;
  MALLOC_CAP_8BIT = 1 shl 2;
  MALLOC_CAP_DMA = 1 shl 3;
  MALLOC_CAP_PID2 = 1 shl 4;
  MALLOC_CAP_PID3 = 1 shl 5;
  MALLOC_CAP_PID4 = 1 shl 6;
  MALLOC_CAP_PID5 = 1 shl 7;
  MALLOC_CAP_PID6 = 1 shl 8;
  MALLOC_CAP_PID7 = 1 shl 9;
  MALLOC_CAP_SPIRAM = 1 shl 10;
  MALLOC_CAP_INTERNAL = 1 shl 11;
  MALLOC_CAP_DEFAULT = 1 shl 12;
  MALLOC_CAP_INVALID = 1 shl 31;

function heap_caps_malloc(size: uint32; caps: uint32): pointer; external;
procedure heap_caps_free(ptr: pointer); external;
function heap_caps_realloc(ptr: pointer; size: uint32; caps: int32): pointer; external;
function heap_caps_aligned_alloc(alignment: uint32; size: uint32;
  caps: int32): pointer; external;
function heap_caps_aligned_calloc(alignment: uint32; n: uint32;
  size: uint32; caps: uint32): pointer; external;
procedure heap_caps_aligned_free(ptr: pointer); external;
function heap_caps_calloc(n: uint32; size: uint32; caps: uint32): pointer;
  external;
function heap_caps_get_total_size(caps: uint32): uint32; external;
function heap_caps_get_free_size(caps: uint32): uint32; external;
function heap_caps_get_minimum_free_size(caps: uint32): uint32; external;
function heap_caps_get_largest_free_block(caps: uint32): uint32; external;
procedure heap_caps_get_info(info: Pmulti_heap_info; caps: uint32); external;
procedure heap_caps_print_heap_info(caps: uint32); external;
function heap_caps_check_integrity_all(print_errors: longbool): longbool; external;
function heap_caps_check_integrity(caps: uint32; print_errors: longbool): longbool;
  external;
function heap_caps_check_integrity_addr(addr: PInt32;
  print_errors: longbool): longbool; external;
procedure heap_caps_malloc_extmem_enable(limit: uint32); external;
function heap_caps_malloc_prefer(size: uint32; num: uint32): pointer; varargs; external;
//function heap_caps_malloc_prefer(size: uint32; num: uint32): pointer; external;
function heap_caps_realloc_prefer(ptr: pointer; size: uint32; num: uint32): pointer; varargs; external;
//function heap_caps_realloc_prefer(ptr: pointer; size: uint32; num: uint32): pointer; external;
function heap_caps_calloc_prefer(n: uint32; size: uint32; num: uint32): pointer; varargs; external;
//function heap_caps_calloc_prefer(n: uint32; size: uint32; num: uint32): pointer; external;
procedure heap_caps_dump(caps: uint32); external;
procedure heap_caps_dump_all; external;
function heap_caps_get_allocated_size(ptr: pointer): uint32; external;

implementation

end.
