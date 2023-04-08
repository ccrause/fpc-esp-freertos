unit esp_heap_caps;

interface

uses
  portmacro;

const
  MALLOC_CAP_EXEC = 1;
  MALLOC_CAP_32BIT = 1 shl 1;
  MALLOC_CAP_8BIT = 1 shl 2;
  MALLOC_CAP_DMA = 1 shl 3;
  MALLOC_CAP_INTERNAL = 1 shl 11;
  MALLOC_CAP_SPIRAM = 1 shl 10;

function HEAP_ALIGN(ptr: longint): longint;

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

const
  MEM_HEAD_SIZE = sizeof(Tmem_blk);
  MEM2_HEAD_SIZE = sizeof(Tmem2_blk);

function heap_caps_get_free_size(caps: uint32): Tsize; external;
function heap_caps_get_minimum_free_size(caps: uint32): Tsize; external;
procedure esp_heap_caps_init_region(region: Pheap_region; max_num: Tsize);
  external;

function heap_caps_malloc(size: Tsize; caps: uint32; afile: PChar = nil;
  line: Tsize = 0): pointer; external name '_heap_caps_malloc';
procedure heap_caps_free(ptr: pointer; afile: PChar = nil; line: Tsize = 0); external name '_heap_caps_free';
function heap_caps_calloc(Count: Tsize; size: Tsize; caps: uint32;
  afile: PChar = nil; line: Tsize = 0): pointer; external name '_heap_caps_calloc';
function heap_caps_realloc(mem: pointer; newsize: Tsize; caps: uint32;
  afile: PChar = nil; line: Tsize = 0): pointer; external name '_heap_caps_realloc';
function heap_caps_zalloc(size: Tsize; caps: uint32; afile: PChar = nil;
  line: Tsize = 0): pointer; external name '_heap_caps_zalloc';

implementation

uses
  esp_heap_config;

function HEAP_ALIGN(ptr: longint): longint;
begin
  HEAP_ALIGN := ((Tsize(ptr)) + (HEAP_ALIGN_SIZE - 1)) and (not (HEAP_ALIGN_SIZE - 1));
end;

end.
