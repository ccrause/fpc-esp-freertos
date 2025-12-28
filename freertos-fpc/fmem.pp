unit fmem;
// Copied mostly from cmem.pp

interface

implementation

// {$linklib freertos} // actual implementation could reside in any library,
// such as NewLib, C, or FreeRTOS.
// Rely on inclusion of implementation mapping in portable.pp
uses
  portable{$ifdef CPUXTENSA}, esp_heap_caps{$endif};

function fGetMem(Size: ptruint): pointer;
begin
  fGetMem := pvPortMalloc(Size+sizeof(ptruint));
  if (fGetMem <> nil) then
  begin
    PPtrUInt(fGetMem)^ := size;
    inc(fGetMem, sizeof(ptruint));
  end
  else
    runerror(203);  // Heap overflow error
end;

function fFreeMem(P: pointer): ptruint;
begin
  if (p <> nil) then
    dec(p, sizeof(ptruint));
  vPortFree(P);
  fFreeMem := 0;
end;

function fFreeMemSize(p: pointer; Size: ptruint): ptruint;
begin
  if size <= 0 then
    exit;
  if (p <> nil) then
    begin
      if (size <> Pptruint(p-sizeof(ptruint))^) then
        runerror(204);
    end;
  fFreeMemSize := fFreeMem(P);
end;

function fAllocMem(Size: ptruint): pointer;
begin
  fAllocMem := pvPortMalloc(Size + sizeof(ptruint));
  if (fAllocMem <> nil) then
  begin
    FillByte(fAllocMem^, Size + sizeof(ptruint), 0);
    Pptruint(fAllocMem)^ := size;
    inc(fAllocMem, sizeof(ptruint));
  end;
end;

function fReAllocMem(var p: pointer; Size: ptruint): pointer;
begin
  if size = 0 then
  begin
    if p <> nil then
    begin
      dec(p, sizeof(ptruint));
      vPortFree(p);
      p := nil;
    end;
  end
  else
  begin
    inc(size, sizeof(ptruint));
    if p = nil then
      p := pvPortMalloc(Size)
    else
    begin
      dec(p, sizeof(ptruint));
      {$ifdef CPUXTENSA}
      heap_caps_realloc(p, size, MALLOC_CAP_8BIT);
      {$else}
      // Not provided by FreeRTOS's heap_x implementations
      // so a custom implementation is required in general
      // for now mark with error
      {$error "realloc" functionality not provided by standard FreeRTOS heap manager}
      //p := pvPortRealloc(p, size);
      {$endif}
    end;
    if (p <> nil) then
    begin
      Pptruint(p)^ := size - sizeof(ptruint);
      inc(p, sizeof(ptruint));
    end;
  end;
  fReAllocMem := p;
end;

function fMemSize(p:pointer): ptruint;
begin
  fMemSize := Pptruint(p - sizeof(ptruint))^;
end;

function fGetHeapStatus: THeapStatus;
begin
  FillChar(fGetHeapStatus, sizeof(fGetHeapStatus), 0);
end;

function fGetFPCHeapStatus: TFPCHeapStatus;
begin
  FillChar(fGetFPCHeapStatus, sizeof(fGetFPCHeapStatus), 0);
end;

const
  fMemoryManager : TMemoryManager = (
    NeedLock : false;
    GetMem : @fGetMem;
    FreeMem : @fFreeMem;
    FreememSize : @fFreeMemSize;
    AllocMem : @fAllocMem;
    ReallocMem : @fReAllocMem;
    MemSize : @fMemSize;
    InitThread : nil;
    DoneThread : nil;
    RelocateHeap : nil;
    GetHeapStatus : @fGetHeapStatus;
    GetFPCHeapStatus: @fGetFPCHeapStatus;
  );

var
  OldMemoryManager : TMemoryManager;

initialization
  GetMemoryManager(OldMemoryManager);
  SetMemoryManager(fMemoryManager);

finalization
  SetMemoryManager(OldMemoryManager);

end.
