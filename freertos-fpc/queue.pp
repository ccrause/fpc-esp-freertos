unit queue;

{$inline on}
{$include freertosconfig.inc}

interface

uses
  portmacro, freertos, projdefs;

type
  TQueueDefinition = record end;
  PQueueHandle = ^TQueueHandle;
  TQueueHandle = ^TQueueDefinition;

  PQueueSetHandle = ^TQueueSetHandle;
  TQueueSetHandle = ^TQueueDefinition;

  PQueueSetMemberHandle = ^TQueueSetMemberHandle;
  TQueueSetMemberHandle = ^TQueueDefinition;

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
  function xQueueCreate(uxQueueLength, uxItemSize: TUBaseType): TQueueHandle; inline;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueCreateStatic(uxQueueLength, uxItemSize: TUBaseType;
    pucQueueStorage: PByte; pxQueueBuffer: pointer): TQueueHandle; inline;

  function xQueueGetStaticBuffers(xQueue: TQueueHandle; ppucQueueStorage: ppByte;
                                  ppxStaticQueue: PPStaticQueue): TBaseType; inline;
{$endif}

function xQueueSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType; inline;
function xQueueSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType; inline;
function xQueueSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType): TBaseType; inline;
function xQueueOverwrite(xQueue: TQueueHandle; pvItemToQueue: pointer): TBaseType; inline;

function xQueueGenericSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
  xTicksToWait: TTickType; xCopyPosition: TBaseType): TBaseType; external;
function xQueuePeek(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType; external;
function xQueuePeekFromISR(xQueue: TQueueHandle; pvBuffer: pointer): TBaseType;  external;
function xQueueReceive(xQueue: TQueueHandle; pvBuffer: pointer; xTicksToWait: TTickType): TBaseType; external;

// Not for external use
//function xQueueGenericReceive(xQueue: TQueueHandle; pvBuffer: pointer;
//  xTicksToWait: TTickType; xJustPeek: TBaseType): TBaseType; external;

function uxQueueMessagesWaiting(xQueue: TQueueHandle): TUBaseType; external;
function uxQueueSpacesAvailable(xQueue: TQueueHandle): TUBaseType; external;
procedure vQueueDelete(xQueue: TQueueHandle); external;
function xQueueSendToFrontFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
function xQueueSendToBackFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
function xQueueOverwriteFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
function xQueueSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; inline;
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

// Not for external use
//function xQueueAltGenericSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
//  xTicksToWait: TTickType; xCopyPosition: TBaseType): TBaseType; external;
//function xQueueAltGenericReceive(xQueue: TQueueHandle; pvBuffer: pointer;
//  xTicksToWait: TTickType; xJustPeeking: TBaseType): TBaseType; external;
//function xQueueAltSendToFront(xQueue: TQueueHandle; pvItemToQueue: pointer;
//  xTicksToWait: TTickType): TBaseType; inline;
//function xQueueAltSendToBack(xQueue: TQueueHandle; pvItemToQueue: pointer;
//  xTicksToWait: TTickType): TBaseType; inline;
//function xQueueAltReceive(xQueue: TQueueHandle; pvBuffer: pointer;
//  xTicksToWait: TTickType): TBaseType; inline;
//function xQueueAltPeek(xQueue: TQueueHandle; pvBuffer: pointer;
//  xTicksToWait: TTickType): TBaseType; inline;

// Co-routine variants - non needed?
//function xQueueCRSendFromISR(xQueue: TQueueHandle; pvItemToQueue: pointer;
//  xCoRoutinePreviouslyWoken: TBaseType): TBaseType; external;
//function xQueueCRReceiveFromISR(xQueue: TQueueHandle; pvBuffer: pointer;
//  pxTaskWoken: PBaseType): TBaseType; external;
//function xQueueCRSend(xQueue: TQueueHandle; pvItemToQueue: pointer;
//  xTicksToWait: TTickType): TBaseType; external;
//function xQueueCRReceive(xQueue: TQueueHandle; pvBuffer: pointer;
//  xTicksToWait: TTickType): TBaseType; external;

function xQueueReset(xQueue: TQueueHandle): TBaseType; inline;

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
    pucQueueStorage: PByte; pxStaticQueue: PStaticQueue;
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
  TQueueSetMemberHandle; external;

// Not for external use
//procedure vQueueWaitForMessageRestricted(xQueue: TQueueHandle;
//  xTicksToWait: TTickType); external;
//function xQueueGenericReset(xQueue: TQueueHandle; xNewQueue: TBaseType): TBaseType;
//  external;
//procedure vQueueSetQueueNumber(xQueue: TQueueHandle; uxQueueNumber: TUBaseType);
//  external;
//function uxQueueGetQueueNumber(xQueue: TQueueHandle): TUBaseType; external;
//function ucQueueGetQueueType(xQueue: TQueueHandle): byte; external;

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueGenericGetStaticBuffers(xQueue: TQueueHandle; ppucQueueStorage: ppByte;
                                         ppxStaticQueue: PPStaticQueue): TBaseType; external;
{$endif}

implementation

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xQueueCreate(uxQueueLength, uxItemSize: TUBaseType): TQueueHandle;
  begin
    xQueueCreate := xQueueGenericCreate(uxQueueLength, uxItemSize, queueQUEUE_TYPE_BASE);
  end;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xQueueCreateStatic(uxQueueLength, uxItemSize: TUBaseType;
    pucQueueStorage: PByte; pxQueueBuffer: pointer): TQueueHandle;
  begin
    xQueueCreateStatic := xQueueGenericCreateStatic(
      uxQueueLength, uxItemSize, pucQueueStorage, pxQueueBuffer, queueQUEUE_TYPE_BASE);
  end;

  function xQueueGetStaticBuffers(xQueue: TQueueHandle; ppucQueueStorage: PPByte;
                                  ppxStaticQueue: PPStaticQueue): TBaseType;
  begin
    xQueueGetStaticBuffers := xQueueGenericGetStaticBuffers(xQueue,
      ppucQueueStorage, ppxStaticQueue);
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

function xQueueGenericReset(xQueue: TQueueHandle; xNewQueue: TBaseType): TBaseType;
  external;

function xQueueReset(xQueue: TQueueHandle): TBaseType;
begin
  xQueueReset := xQueueGenericReset(xQueue, pdFALSE);
end;

end.
