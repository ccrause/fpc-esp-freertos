unit queue;

{$include freertosconfig.inc}

interface

uses
  portmacro, freertos, projdefs;

type
  PQueueHandle = ^TQueueHandle;
  TQueueHandle = pointer;

  PQueueSetHandle = ^TQueueSetHandle;
  TQueueSetHandle = pointer;

  PQueueSetMemberHandle = ^TQueueSetMemberHandle;
  TQueueSetMemberHandle = pointer;

const
  queueSEND_TO_BACK = 0;
  queueSEND_TO_FRONT = 1;
  queueOVERWRITE = 2;
  queueQUEUE_TYPE_BASE = 0;
  queueQUEUE_TYPE_SET = 0;
  queueQUEUE_TYPE_MUTEX = 1;
  queueQUEUE_TYPE_COUNTING_SEMAPHORE = 2;
  queueQUEUE_TYPE_BINARY_SEMAPHORE = 3;
  queueQUEUE_TYPE_RECURSIVE_MUTEX = 4;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xQueueCreate(uxQueueLength, uxItemSize: TUBaseType): TQueueHandle;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueCreateStatic(uxQueueLength, uxItemSize: TUBaseType;
    pucQueueStorage: PUBaseType_t; pxQueueBuffer: pointer): TQueueHandle;
{$endif}

function xQueueSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueOverwrite(xQueue: TQueueHandle; pvItemToQueue: pointer): TBaseType;
function xQueueGenericSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType; xCopyPosition: TBaseType): TBaseType;
  external;
function xQueuePeek(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType;
function xQueuePeekFromISR(xQueue: TQueueHandle; pvBuffer: pointer): TBaseType;
  external;
function xQueueReceive(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType;
function xQueueGenericReceive(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType; xJustPeek: TBaseType): TBaseType; external;
function uxQueueMessagesWaiting(xQueue: TQueueHandle): TUBaseType; external;
function uxQueueSpacesAvailable(xQueue: TQueueHandle): TUBaseType; external;
procedure vQueueDelete(xQueue: TQueueHandle); external;
function xQueueSendToFrontFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xQueueSendToBackFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xQueueOverwriteFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xQueueSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xQueueGenericSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType; xCopyPosition: TBaseType): TBaseType;
  external;
function xQueueGiveFromISR(xQueue: TQueueHandle;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;
function xQueueReceiveFromISR(xQueue: TQueueHandle; pvBuffer: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;
function xQueueIsQueueEmptyFromISR(xQueue: TQueueHandle): TBaseType; external;
function xQueueIsQueueFullFromISR(xQueue: TQueueHandle): TBaseType; external;
function uxQueueMessagesWaitingFromISR(xQueue: TQueueHandle): TUBaseType;
  external;
function xQueueAltGenericSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType; xCopyPosition: TBaseType): TBaseType; external;
function xQueueAltGenericReceive(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType; xJustPeeking: TBaseType): TBaseType; external;
function xQueueAltSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueAltSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueAltReceive(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueAltPeek(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType): TBaseType;
function xQueueCRSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xCoRoutinePreviouslyWoken: TBaseType): TBaseType; external;
function xQueueCRReceiveFromISR(xQueue: TQueueHandle; pvBuffer: pointer;
  pxTaskWoken: PBaseType): TBaseType; external;
function xQueueCRSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType; external;
function xQueueCRReceive(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType): TBaseType; external;
function xQueueCreateMutex(ucQueueType: byte): TQueueHandle; external;
function xQueueCreateMutexStatic(ucQueueType: byte;
  pxStaticQueue: PStaticQueue): TQueueHandle; external;
function xQueueCreateCountingSemaphore(uxMaxCount: TUBaseType;
  uxInitialCount: TUBaseType): TQueueHandle; external;
function xQueueCreateCountingSemaphoreStatic(uxMaxCount, uxInitialCount: TUBaseType;
  pxStaticQueue: PStaticQueue): TQueueHandle; external;
function xQueueGetMutexHolder(xSemaphore: TQueueHandle): pointer; external;
function xQueueTakeMutexRecursive(xMutex: TQueueHandle;
  xTicksToWait: TTickType): TBaseType; external;
function xQueueGiveMutexRecursive(pxMutex: TQueueHandle): TBaseType; external;
function xQueueReset(xQueue: TQueueHandle): TBaseType;

{$if defined(configQUEUE_REGISTRY_SIZE) and (configQUEUE_REGISTRY_SIZE > 0)}
  procedure vQueueAddToRegistry(xQueue: TQueueHandle; pcName: PChar); external;
{$endif}

{$if defined(configQUEUE_REGISTRY_SIZE) and (configQUEUE_REGISTRY_SIZE > 0)}
  procedure vQueueUnregisterQueue(xQueue: TQueueHandle); external;
{$endif}

{$if defined(configQUEUE_REGISTRY_SIZE) and (configQUEUE_REGISTRY_SIZE > 0)}
  function pcQueueGetName(xQueue: TQueueHandle): PChar;
{$endif}

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xQueueGenericCreate(uxQueueLength, uxItemSize: TUBaseType;
    ucQueueType: byte): TQueueHandle; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueGenericCreateStatic(uxQueueLength, uxItemSize: TUBaseType;
    pucQueueStorage: PChar; pxStaticQueue: PStaticQueue;
    ucQueueType: byte): TQueueHandle; external;
{$endif}

function xQueueCreateSet(uxEventQueueLength: TUBaseType): TQueueSetHandle;
  external;
function xQueueAddToSet(xQueueOrSemaphore: TQueueSetMemberHandle;
  xQueueSet: TQueueSetHandle): TBaseType; external;
function xQueueRemoveFromSet(xQueueOrSemaphore: TQueueSetMemberHandle;
  xQueueSet: TQueueSetHandle): TBaseType; external;
function xQueueSelectFromSet(xQueueSet: TQueueSetHandle;
  xTicksToWait: TTickType): TQueueSetMemberHandle; external;
function xQueueSelectFromSetFromISR(xQueueSet: TQueueSetHandle):
  TQueueSetMemberHandle;
  external;
procedure vQueueWaitForMessageRestricted(xQueue: TQueueHandle;
  xTicksToWait: TTickType); external;
function xQueueGenericReset(xQueue: TQueueHandle; xNewQueue: TBaseType): TBaseType;
  external;
procedure vQueueSetQueueNumber(xQueue: TQueueHandle; uxQueueNumber: TUBaseType);
  external;
function uxQueueGetQueueNumber(xQueue: TQueueHandle): TUBaseType; external;
function ucQueueGetQueueType(xQueue: TQueueHandle): byte; external;

implementation

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xQueueCreate(uxQueueLength, uxItemSize: TUBaseType): TQueueHandle;
  begin
    xQueueCreate := xQueueGenericCreate(uxQueueLength, uxItemSize, queueQUEUE_TYPE_BASE);
  end;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueCreateStatic(uxQueueLength, uxItemSize: TUBaseType;
    pucQueueStorage: PUBaseType_t; pxQueueBuffer: pointer): TQueueHandle;
  begin
    xQueueCreateStatic := xQueueGenericCreateStatic(
      uxQueueLength, uxItemSize, pucQueueStorage, pxQueueBuffer, queueQUEUE_TYPE_BASE);
  end;
{$endif}

function xQueueSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueSendToFront := xQueueGenericSend(xQueue, pvItemToQueue, xTicksToWait,
    queueSEND_TO_FRONT);
end;

function xQueueSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueSendToBack := xQueueGenericSend(xQueue, pvItemToQueue, xTicksToWait,
    queueSEND_TO_BACK);
end;

function xQueueSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueSend := xQueueGenericSend(xQueue, pvItemToQueue, xTicksToWait, queueSEND_TO_BACK);
end;

function xQueueOverwrite(xQueue: TQueueHandle; pvItemToQueue: pointer): TBaseType;
begin
  xQueueOverwrite := xQueueGenericSend(xQueue, pvItemToQueue, 0, queueOVERWRITE);
end;

function xQueuePeek(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType;
begin
  xQueuePeek := xQueueGenericReceive(xQueue, pvBuffer, xTicksToWait, pdTRUE);
end;

function xQueueReceive(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType;
begin
  xQueueReceive := xQueueGenericReceive(xQueue, pvBuffer, xTicksToWait, pdFALSE);
end;

function xQueueSendToFrontFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xQueueSendToFrontFromISR := xQueueGenericSendFromISR(
    xQueue, pvItemToQueue, pxHigherPriorityTaskWoken, queueSEND_TO_FRONT);
end;

function xQueueSendToBackFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xQueueSendToBackFromISR := xQueueGenericSendFromISR(
    xQueue, pvItemToQueue, pxHigherPriorityTaskWoken, queueSEND_TO_BACK);
end;

function xQueueOverwriteFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xQueueOverwriteFromISR := xQueueGenericSendFromISR(
    xQueue, pvItemToQueue, pxHigherPriorityTaskWoken, queueOVERWRITE);
end;

function xQueueSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xQueueSendFromISR := xQueueGenericSendFromISR(xQueue, pvItemToQueue,
    pxHigherPriorityTaskWoken, queueSEND_TO_BACK);
end;

function xQueueAltSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueAltSendToFront := xQueueAltGenericSend(xQueue, pvItemToQueue,
    xTicksToWait, queueSEND_TO_FRONT);
end;

function xQueueAltSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueAltSendToBack := xQueueAltGenericSend(xQueue, pvItemToQueue,
    xTicksToWait, queueSEND_TO_BACK);
end;

function xQueueAltReceive(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueAltReceive := xQueueAltGenericReceive(xQueue, pvBuffer, xTicksToWait, pdFALSE);
end;

function xQueueAltPeek(xQueue: TQueueHandle; pvBuffer: pointer;
  xTicksToWait: TTickType): TBaseType;
begin
  xQueueAltPeek := xQueueAltGenericReceive(xQueue, pvBuffer, xTicksToWait, pdTRUE);
end;

function xQueueReset(xQueue: TQueueHandle): TBaseType;
begin
  xQueueReset := xQueueGenericReset(xQueue, pdFALSE);
end;

end.
