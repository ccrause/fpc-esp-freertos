unit fmem;
// Copied mostly from cmem.pp

interface

implementation

// {$linklib freertos} // actual implementation could reside in any library,
// such as NewLib, C, or FreeRTOS.
// Rely on inclusion of implementation mapping in portable.pp
uses
  portable;

function fGetMem(Size: ptruint): pointer;
begin
  fGetMem := pvPortMalloc(Size+sizeof(ptruint));
  if (fGetMem <> nil) then
  begin
    PPtrUInt(fGetMem)^ := size;
    inc(fGetMem, sizeof(ptruint));
  end;
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
  fAllocMem := pvPortCalloc(Size + sizeof(ptruint), 1);
  if (fAllocMem <> nil) then
  begin
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
      p := pvPortRealloc(p, size);
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
var
  res: THeapStatus;
begin
  FillChar(res, sizeof(res), 0);
  fGetHeapStatus := res;
end;

function fGetFPCHeapStatus: TFPCHeapStatus;
begin
  FillChar(fGetFPCHeapStatus, sizeof(fGetFPCHeapStatus), 0);
end;

const
 fMemoryManager : TMemoryManager =
    (
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

  // TODO: Temporary testing code below can be removed
  if OldMemoryManager.Getmem <> nil then
    writeln('Replacing previous memory manager with fmem');

  SetMemoryManager(fMemoryManager);

finalization
  SetMemoryManager(OldMemoryManager);

end.
