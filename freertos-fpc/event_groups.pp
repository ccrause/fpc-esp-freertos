unit event_groups;

{$include freertosconfig.inc}

interface

uses
  portmacro;

type
  TEventGroupDef = record end;
  PEventGroupHandle = ^TEventGroupHandle;
  TEventGroupHandle = pointer;

  PEventBits = ^TEventBits;
  TEventBits = TTickType;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
  function xEventGroupCreate: TEventGroupHandle; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
  function xEventGroupCreateStatic(pxEventGroupBuffer: PStaticEventGroup): TEventGroupHandle; external;
{$endif}

function xEventGroupWaitBits(xEventGroup: TEventGroupHandle;
  const uxBitsToWaitFor: TEventBits; const xClearOnExit: TBaseType;
  const xWaitForAllBits: TBaseType; xTicksToWait: TTickType): TEventBits; external;
function xEventGroupClearBits(xEventGroup: TEventGroupHandle;
  const uxBitsToClear: TEventBits) : TEventBits; external;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToSet: TEventBits): TBaseType; external;
{$else}
  function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToClear: TEventBits): TEventBits;
{$endif}

function xEventGroupSetBits(xEventGroup: TEventGroupHandle;
  const uxBitsToSet: TEventBits): TEventBits; external;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToSet: TEventBits; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
  external;
{$else}
  function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToSet: TEventBits; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
{$endif}

function xEventGroupSync(xEventGroup: TEventGroupHandle;
  const uxBitsToSet: TEventBits; const uxBitsToWaitFor: TEventBits;
  xTicksToWait: TTickType): TEventBits; external;

function xEventGroupGetBits(xEventGroup: TEventGroupHandle): TEventBits;

function xEventGroupGetBitsFromISR(xEventGroup: TEventGroupHandle): TEventBits;
  external;
procedure vEventGroupDelete(xEventGroup: TEventGroupHandle); external;
procedure vEventGroupSetBitsCallback(pvEventGroup: pointer;
  ulBitsToSet: uint32); external;
procedure vEventGroupClearBitsCallback(pvEventGroup: pointer;
  ulBitsToClear: uint32); external;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
  function uxEventGroupGetNumber(xEventGroup: pointer): TUBaseType; external;
	procedure vEventGroupSetNumber(xEventGroup: pointer; uxEventGroupNumber: TUBaseType); external;
{$endif}

implementation

{$if not defined(configUSE_TRACE_FACILITY) or (configUSE_TRACE_FACILITY = 0)}
function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle;
  uxBitsToClear: TEventBits): TEventBits;
begin
  xEventGroupClearBitsFromISR :=
    xTimerPendFunctionCallFromISR(@vEventGroupClearBitsCallback, pointer(
    xEventGroup), uint32(uxBitsToClear), nil);
end;
{$endif}

{$if not defined(configUSE_TRACE_FACILITY) or (configUSE_TRACE_FACILITY = 0)}
  function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle;
    uxBitsToSet: TEventBits; pxHigherPriorityTaskWoken: PBaseType
    ): TBaseType;
  begin
    xEventGroupSetBitsFromISR := xTimerPendFunctionCallFromISR(
      @vEventGroupSetBitsCallback, pointer(xEventGroup), uint32(uxBitsToSet),
      pxHigherPriorityTaskWoken);
  end;
{$endif}

function xEventGroupGetBits(xEventGroup: TEventGroupHandle): TEventBits;
begin
  xEventGroupGetBits := xEventGroupClearBits(xEventGroup, 0);
end;

end.
