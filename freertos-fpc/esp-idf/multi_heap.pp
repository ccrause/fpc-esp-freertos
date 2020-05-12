unit multi_heap;

interface

type
  Tmulti_heap_info_t = record
    total_free_bytes: uint32;
    total_allocated_bytes: uint32;
    largest_free_block: uint32;
    minimum_free_bytes: uint32;
    allocated_blocks: uint32;
    free_blocks: uint32;
    total_blocks: uint32;
  end;
  Tmulti_heap_handle_t = ^Tmulti_heap_info_t;
  Pmulti_heap_info_t = ^Tmulti_heap_info_t;
  //Pmulti_heap_info_t = ^multi_heap_info_t;
  //Pmulti_heap_handle_t = ^Tmulti_heap_handle_t;
  //Tmulti_heap_handle_t = Pmulti_heap_info;

function multi_heap_aligned_alloc(heap: Tmulti_heap_handle_t; size: uint32;
  alignment: uint32): pointer; cdecl; external;
function multi_heap_malloc(heap: Tmulti_heap_handle_t; size: uint32): pointer;
  cdecl; external;
procedure multi_heap_aligned_free(heap: Tmulti_heap_handle_t; p: pointer); cdecl; external;
procedure multi_heap_free(heap: Tmulti_heap_handle_t; p: pointer); cdecl; external;
function multi_heap_realloc(heap: Tmulti_heap_handle_t; p: pointer;
  size: uint32): pointer; cdecl; external;
function multi_heap_get_allocated_size(heap: Tmulti_heap_handle_t;
  p: pointer): uint32; cdecl; external;
function multi_heap_register(start: pointer; size: uint32): Tmulti_heap_handle_t;
  cdecl; external;
procedure multi_heap_set_lock(heap: Tmulti_heap_handle_t; lock: pointer); cdecl; external;
procedure multi_heap_dump(heap: Tmulti_heap_handle_t); cdecl; external;
function multi_heap_check(heap: Tmulti_heap_handle_t; print_errors: longbool): longbool;
  cdecl; external;
function multi_heap_free_size(heap: Tmulti_heap_handle_t): uint32; cdecl; external;
function multi_heap_minimum_free_size(heap: Tmulti_heap_handle_t): uint32; cdecl; external;
procedure multi_heap_get_info(heap: Tmulti_heap_handle_t;
  info: Pmulti_heap_info_t); cdecl; external;

implementation

end.
