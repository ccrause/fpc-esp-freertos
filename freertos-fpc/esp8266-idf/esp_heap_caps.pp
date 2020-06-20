unit esp_heap_caps;

interface

uses
  portmacro;

const
  MALLOC_CAP_32BIT = 1 shl 1;
  MALLOC_CAP_8BIT = 1 shl 2;
  MALLOC_CAP_DMA = 1 shl 3;
  MALLOC_CAP_INTERNAL = 1 shl 11;
  MALLOC_CAP_SPIRAM = 1 shl 10;

function HEAP_ALIGN(ptr: longint): longint;

function MEM_HEAD_SIZE: Tsize;
function MEM2_HEAD_SIZE: Tsize;

type
  Pmem_blk = ^Tmem_blk;
  Tmem_blk = record
    prev: Pmem_blk;
    Next: Pmem_blk;
  end;

{$ifdef CONFIG_HEAP_TRACING}
  Pmem_blk2 = ^Tmem_blk2;
  Tmem_blk2 = record
    prev: Pmem_blk2;
    Next: Pmem_blk2;
    afile: PChar;
    line: Tsize;
  end;
{$else}
  Pmem2_blk_t = ^Tmem2_blk;
  Tmem2_blk = Tmem_blk;
{$endif}

  Pheap_region = ^Theap_region;
  Theap_region = record
    start_addr: pointer;
    total_size: Tsize;
    caps: uint32;
    free_blk: pointer;
    free_bytes: Tsize;
    min_free_bytes: Tsize;
  end;

function heap_caps_get_free_size(caps: uint32): Tsize; external;
function heap_caps_get_minimum_free_size(caps: uint32): Tsize; external;
procedure esp_heap_caps_init_region(region: Pheap_region; max_num: Tsize);
  external;
function _heap_caps_malloc(size: Tsize; caps: uint32; afile: PChar;
  line: Tsize): pointer; external;
procedure _heap_caps_free(ptr: pointer; afile: PChar; line: Tsize); external;
function _heap_caps_calloc(Count: Tsize; size: Tsize; caps: uint32;
  afile: PChar; line: Tsize): pointer; external;
function _heap_caps_realloc(mem: pointer; newsize: Tsize; caps: uint32;
  afile: PChar; line: Tsize): pointer; external;
function _heap_caps_zalloc(size: Tsize; caps: uint32; afile: PChar;
  line: Tsize): pointer; external;

// Pascal functions will not give the same capability as the C macro's
// which automatically embed the call size file name and line number.
// If this is required, rather call the raw functions above and supply
// the file name and line number via the include macro:
// {$include %file%} and {$include %lineNum%}

//function heap_caps_malloc(size, caps: longint): longint;
//function heap_caps_free(ptr: longint): longint;
//function heap_caps_calloc(n, size, caps: longint): longint;
//function heap_caps_realloc(ptr, size, caps: longint): longint;
//function heap_caps_zalloc(size, caps: longint): longint;

implementation

uses
  esp_heap_config;

function HEAP_ALIGN(ptr: longint): longint;
begin
  HEAP_ALIGN := ((Tsize(ptr)) + (HEAP_ALIGN_SIZE - 1)) and (not (HEAP_ALIGN_SIZE - 1));
end;

function MEM_HEAD_SIZE: Tsize;
begin
  MEM_HEAD_SIZE := sizeof(Tmem_blk);
end;

function MEM2_HEAD_SIZE: Tsize; { return type might be wrong }
begin
  MEM2_HEAD_SIZE := sizeof(Tmem2_blk);
end;

//function heap_caps_malloc(size, caps: longint): longint;
//begin
//  heap_caps_malloc := _heap_caps_malloc(size, caps, __ESP_FILE__, __LINE__);
//end;

//function heap_caps_free(ptr: longint): longint;
//begin
//  heap_caps_free := _heap_caps_free(ptr, __ESP_FILE__, __LINE__);
//end;

//function heap_caps_calloc(n, size, caps: longint): longint;
//begin
//  heap_caps_calloc := _heap_caps_calloc(n, size, caps, __ESP_FILE__, __LINE__);
//end;

//function heap_caps_realloc(ptr, size, caps: longint): longint;
//begin
//  heap_caps_realloc := _heap_caps_realloc(ptr, size, caps, __ESP_FILE__, __LINE__);
//end;

//function heap_caps_zalloc(size, caps: longint): longint;
//begin
//  heap_caps_zalloc := _heap_caps_zalloc(size, caps, __ESP_FILE__, __LINE__);
//end;

end.
