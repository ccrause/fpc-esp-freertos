unit semphr;

{$include freertosconfig.inc}

interface

uses
  queue, portmacro, projdefs, freertos;

type
  PSemaphoreHandle = ^TSemaphoreHandle;
  TSemaphoreHandle = TQueueHandle;

const
  semBINARY_SEMAPHORE_QUEUE_LENGTH = 1;
  semSEMAPHORE_QUEUE_ITEM_LENGTH = 0;
  semGIVE_BLOCK_TIME = 0;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function vSemaphoreCreateBinary: TSemaphoreHandle;
function xSemaphoreCreateBinary: TSemaphoreHandle;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1 )}
function xSemaphoreCreateBinaryStatic(pxStaticSemaphore: PStaticQueue): TQueueHandle;
{$endif}

function xSemaphoreTake(xSemaphore: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
function xSemaphoreTakeRecursive(xMutex: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
function xSemaphoreAltTake(xSemaphore: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
function xSemaphoreGive(xSemaphore: TSemaphoreHandle): TBaseType;
function xSemaphoreGiveRecursive(xMutex: TSemaphoreHandle): TBaseType;
function xSemaphoreAltGive(xSemaphore: TSemaphoreHandle): TBaseType;
function xSemaphoreGiveFromISR(xSemaphore: TSemaphoreHandle; pxHigherPriorityTaskWoken: PBaseType)
  : TBaseType;
function xSemaphoreTakeFromISR(xSemaphore: TSemaphoreHandle; pxHigherPriorityTaskWoken: PBaseType)
  : TBaseType;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xSemaphoreCreateMutex: TSemaphoreHandle;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xSemaphoreCreateMutexStatic(pxMutexBuffer: PStaticQueue): TSemaphoreHandle_t;
{$endif}

{$if (configSUPPORT_DYNAMIC_ALLOCATION = 1) and (configUSE_RECURSIVE_MUTEXES = 1)}
  function xSemaphoreCreateRecursiveMutex: TSemaphoreHandle;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and defined(configUSE_RECURSIVE_MUTEXES) and
      (configSUPPORT_STATIC_ALLOCATION = 1 ) and ( configUSE_RECURSIVE_MUTEXES = 1)}
  function xSemaphoreCreateRecursiveMutexStatic(pxStaticSemaphore: PStaticQueue): TSemaphoreHandle_t;
{$endif}

{$if( configSUPPORT_DYNAMIC_ALLOCATION = 1 )}
  function xSemaphoreCreateCounting(uxMaxCount, uxInitialCount: longint): TSemaphoreHandle;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xSemaphoreCreateCountingStatic(uxMaxCount, uxInitialCount: TUBaseType;
    pxSemaphoreBuffer: PStaticQueue): TSemaphoreHandle_t;
{$endif}

procedure vSemaphoreDelete(xSemaphore: TSemaphoreHandle);
function xSemaphoreGetMutexHolder(xSemaphore: TSemaphoreHandle): pointer;
function uxSemaphoreGetCount(xSemaphore: TSemaphoreHandle): longint;

implementation

function xQueueGenericCreate(uxQueueLength, uxItemSize: TUBaseType;
  ucQueueType: byte): TQueueHandle; external;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function vSemaphoreCreateBinary: TSemaphoreHandle;
begin
  vSemaphoreCreateBinary := xQueueGenericCreate(1, semSEMAPHORE_QUEUE_ITEM_LENGTH,
    queueQUEUE_TYPE_BINARY_SEMAPHORE);
  if not (vSemaphoreCreateBinary = nil) then
    xSemaphoreGive(vSemaphoreCreateBinary);
end;

function xSemaphoreCreateBinary: TSemaphoreHandle;
begin
  xSemaphoreCreateBinary := xQueueGenericCreate(1, semSEMAPHORE_QUEUE_ITEM_LENGTH,
    queueQUEUE_TYPE_BINARY_SEMAPHORE);
end;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1 )}
function xSemaphoreCreateBinaryStatic(pxStaticSemaphore: PStaticQueue): TQueueHandle;
begin
  xSemaphoreCreateBinaryStatic :=
    xQueueGenericCreateStatic(TUBaseType(1), semSEMAPHORE_QUEUE_ITEM_LENGTH,
    nil, pxStaticSemaphore, queueQUEUE_TYPE_BINARY_SEMAPHORE);
end;
{$endif}

function xSemaphoreTake(xSemaphore: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
begin
  xSemaphoreTake := xQueueGenericReceive(xSemaphore, nil, xBlockTime, pdFALSE);
end;

function xSemaphoreTakeRecursive(xMutex: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
begin
  xSemaphoreTakeRecursive := xQueueTakeMutexRecursive(xMutex, xBlockTime);
end;

function xSemaphoreAltTake(xSemaphore: TSemaphoreHandle; xBlockTime: TTickType): TBaseType;
begin
  xSemaphoreAltTake := xQueueAltGenericReceive(xSemaphore, nil, xBlockTime, pdFALSE);
end;

function xSemaphoreGive(xSemaphore: TSemaphoreHandle): longint;
begin
  xSemaphoreGive := xQueueGenericSend(xSemaphore,
    nil, semGIVE_BLOCK_TIME, queueSEND_TO_BACK);
end;

function xSemaphoreGiveRecursive(xMutex: TSemaphoreHandle): longint;
begin
  xSemaphoreGiveRecursive := xQueueGiveMutexRecursive(xMutex);
end;

function xSemaphoreAltGive(xSemaphore: TSemaphoreHandle): longint;
begin
  xSemaphoreAltGive := xQueueAltGenericSend(xSemaphore,
    nil, semGIVE_BLOCK_TIME, queueSEND_TO_BACK);
end;

function xSemaphoreGiveFromISR(xSemaphore: TSemaphoreHandle; pxHigherPriorityTaskWoken: PBaseType): longint;
begin
  xSemaphoreGiveFromISR := xQueueGiveFromISR(xSemaphore,
    pxHigherPriorityTaskWoken);
end;

function xSemaphoreTakeFromISR(xSemaphore: TSemaphoreHandle; pxHigherPriorityTaskWoken: PBaseType): longint;
begin
  xSemaphoreTakeFromISR := xQueueReceiveFromISR(xSemaphore, nil,
    pxHigherPriorityTaskWoken);
end;

function xSemaphoreCreateMutex: TSemaphoreHandle;
begin
  xSemaphoreCreateMutex := xQueueCreateMutex(queueQUEUE_TYPE_MUTEX);
end;

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
function xSemaphoreCreateMutexStatic(pxMutexBuffer: PStaticQueue): longint;
begin
  xSemaphoreCreateMutexStatic :=
    xQueueCreateMutexStatic(queueQUEUE_TYPE_MUTEX, pxMutexBuffer);
end;
{$endif}

function xSemaphoreCreateRecursiveMutex: TSemaphoreHandle;
begin
  xSemaphoreCreateRecursiveMutex := xQueueCreateMutex(queueQUEUE_TYPE_RECURSIVE_MUTEX);
end;

{$if defined(configSUPPORT_STATIC_ALLOCATION) and defined(configUSE_RECURSIVE_MUTEXES) and
      (configSUPPORT_STATIC_ALLOCATION = 1 ) and ( configUSE_RECURSIVE_MUTEXES = 1)}
function xSemaphoreCreateRecursiveMutexStatic(pxStaticSemaphore: PStaticQueue): TSemaphoreHandle_t;
begin
  xSemaphoreCreateRecursiveMutexStatic :=
    xQueueCreateMutexStatic(queueQUEUE_TYPE_RECURSIVE_MUTEX, pxStaticSemaphore);
end;
{$endif}

function xSemaphoreCreateCounting(uxMaxCount, uxInitialCount: longint): TSemaphoreHandle;
begin
  xSemaphoreCreateCounting := xQueueCreateCountingSemaphore(uxMaxCount, uxInitialCount);
end;

function xSemaphoreCreateCountingStatic(uxMaxCount, uxInitialCount: TUBaseType;
  pxSemaphoreBuffer: PStaticQueue): TSemaphoreHandle;
begin
  xSemaphoreCreateCountingStatic :=
    xQueueCreateCountingSemaphoreStatic(uxMaxCount, uxInitialCount, pxSemaphoreBuffer);
end;

procedure vSemaphoreDelete(xSemaphore: TSemaphoreHandle);
begin
  vQueueDelete(xSemaphore);
end;

function xSemaphoreGetMutexHolder(xSemaphore: TSemaphoreHandle): pointer;
begin
  xSemaphoreGetMutexHolder := xQueueGetMutexHolder(xSemaphore);
end;

function uxSemaphoreGetCount(xSemaphore: TSemaphoreHandle): longint;
begin
  uxSemaphoreGetCount := uxQueueMessagesWaiting(xSemaphore);
end;

end.
