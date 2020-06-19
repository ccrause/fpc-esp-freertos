unit event_groups;

interface

type
  PEventGroupHandle_t = ^TEventGroupHandle_t;
  TEventGroupHandle_t = pointer;

  PEventBits_t = ^TEventBits_t;
  TEventBits_t = TTickType_t;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xEventGroupCreate: TEventGroupHandle; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xEventGroupCreateStatic(pxEventGroupBuffer: PStaticEventGroup): TEventGroupHandle;
{$endif}

function xEventGroupWaitBits(xEventGroup: TEventGroupHandle;
  uxBitsToWaitFor: TEventBits; xClearOnExit: TBaseType;
  xWaitForAllBits: TBaseType; xTicksToWait: TTickType): TEventBits;

function xEventGroupClearBits(xEventGroup: TEventGroupHandle; uxBitsToClear: TEventBits): TEventBits;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle; uxBitsToSet: TEventBits): TBaseType;
{$else}
function xEventGroupClearBitsFromISR(xEventGroup, uxBitsToClear: longint): longint;
{$endif}
function xEventGroupSetBits(xEventGroup: TEventGroupHandle; uxBitsToSet: TEventBits): TEventBits;
{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToSet: TEventBits, pxHigherPriorityTaskWoken: PBaseType): TBaseType;
{$else}
function xEventGroupSetBitsFromISR(xEventGroup, uxBitsToSet, pxHigherPriorityTaskWoken:
  longint): longint;
{$endif}

function xEventGroupSync(xEventGroup: TEventGroupHandle; uxBitsToSet: TEventBits;
  uxBitsToWaitFor: TEventBits; xTicksToWait: T): TEventBits;

function xEventGroupGetBits(xEventGroup: longint): longint;

function xEventGroupGetBitsFromISR(xEventGroup: TEventGroupHandle): TEventBits;

procedure vEventGroupDelete(xEventGroup: TEventGroupHandle);

procedure vEventGroupSetBitsCallback(pvEventGroup: pointer; ulBitsToSet: uint32); external;

procedure vEventGroupClearBitsCallback(pvEventGroup: pointer; ulBitsToClear: uint32); external;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function uxEventGroupGetNumber(xEventGroup: pointer): TUBaseType; external;
  procedure vEventGroupSetNumber(xEventGroup: pointer; uxEventGroupNumber: TUBaseType); external;
{$endif}


implementation

function xEventGroupClearBitsFromISR(xEventGroup, uxBitsToClear: longint): longint;
begin
  xEventGroupClearBitsFromISR :=
    xTimerPendFunctionCallFromISR(vEventGroupClearBitsCallback, pointer(
    xEventGroup), Tuint32_t(uxBitsToClear), NULL);
end;

function xEventGroupSetBitsFromISR(xEventGroup, uxBitsToSet, pxHigherPriorityTaskWoken:
  longint): longint;
begin
  xEventGroupSetBitsFromISR := xTimerPendFunctionCallFromISR(
    vEventGroupSetBitsCallback, pointer(xEventGroup), Tuint32_t(uxBitsToSet),
    pxHigherPriorityTaskWoken);
end;

function xEventGroupGetBits(xEventGroup: longint): longint;
begin
  xEventGroupGetBits := xEventGroupClearBits(xEventGroup, 0);
end;

end.
