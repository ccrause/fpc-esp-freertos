unit multi_heap;

interface

type
  Tmulti_heap_info = record
    total_free_bytes: uint32;
    total_allocated_bytes: uint32;
    largest_free_block: uint32;
    minimum_free_bytes: uint32;
    allocated_blocks: uint32;
    free_blocks: uint32;
    total_blocks: uint32;
  end;
  Tmulti_heap_handle = ^Tmulti_heap_info;
  Pmulti_heap_info = ^Tmulti_heap_info;

function multi_heap_aligned_alloc(heap: Tmulti_heap_handle; size: uint32;
  alignment: uint32): pointer; external;
function multi_heap_malloc(heap: Tmulti_heap_handle; size: uint32): pointer;
  external;
procedure multi_heap_aligned_free(heap: Tmulti_heap_handle; p: pointer); external;
procedure multi_heap_free(heap: Tmulti_heap_handle; p: pointer); external;
function multi_heap_realloc(heap: Tmulti_heap_handle; p: pointer;
  size: uint32): pointer; external;
function multi_heap_get_allocated_size(heap: Tmulti_heap_handle;
  p: pointer): uint32; external;
function multi_heap_register(start: pointer; size: uint32): Tmulti_heap_handle;
  external;
procedure multi_heap_set_lock(heap: Tmulti_heap_handle; lock: pointer); external;
procedure multi_heap_dump(heap: Tmulti_heap_handle); external;
function multi_heap_check(heap: Tmulti_heap_handle; print_errors: longbool): longbool;
  external;
function multi_heap_free_size(heap: Tmulti_heap_handle): uint32; external;
function multi_heap_minimum_free_size(heap: Tmulti_heap_handle): uint32; external;
procedure multi_heap_get_info(heap: Tmulti_heap_handle;
  info: Pmulti_heap_info); external;

implementation

end.
