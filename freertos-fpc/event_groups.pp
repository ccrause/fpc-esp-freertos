unit event_groups;

{$include freertosconfig.inc}

interface

{ $include "timers.h"}

uses
  portmacro,  // Define some base types such as TTickType_t
  portable,   // Define e.g. TBaseType_t
  timers;

type
  PEventGroupHandle_t = ^TEventGroupHandle_t;
  TEventGroupHandle_t = pointer;

  PEventBits_t = ^TEventBits_t;
  TEventBits_t = TTickType_t;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function xEventGroupCreate: TEventGroupHandle_t; external; //PRIVILEGED_FUNCTION;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
function xEventGroupCreateStatic(pxEventGroupBuffer: PStaticEventGroup_t): TEventGroupHandle_t; external;// PRIVILEGED_FUNCTION;
{$endif}

function xEventGroupWaitBits(xEventGroup: TEventGroupHandle_t;
  const uxBitsToWaitFor: TEventBits_t; const xClearOnExit: TBaseType_t;
  const xWaitForAllBits: TBaseType_t; xTicksToWait: TTickType_t): TEventBits_t; external; // PRIVILEGED_FUNCTION;

function xEventGroupClearBits(xEventGroup: TEventGroupHandle_t;
  const uxBitsToClear: TEventBits_t) : TEventBits_t; external; //PRIVILEGED_FUNCTION;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToSet: TEventBits_t): TBaseType_t; cdecl; external;
{$else}
function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToClear: TEventBits_t): TEventBits_t;
{$endif}

function xEventGroupSetBits(xEventGroup: TEventGroupHandle_t;
  const uxBitsToSet: TEventBits_t): TEventBits_t; external; //PRIVILEGED_FUNCTION;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToSet: TEventBits_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
  cdecl; external;
{$else}
function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToSet: TEventBits_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
{$endif}

function xEventGroupSync(xEventGroup: TEventGroupHandle_t;
  const uxBitsToSet: TEventBits_t; const uxBitsToWaitFor: TEventBits_t;
  xTicksToWait: TTickType_t): TEventBits_t; external; //PRIVILEGED_FUNCTION;

function xEventGroupGetBits(xEventGroup: TEventGroupHandle_t): TEventBits_t;

function xEventGroupGetBitsFromISR(xEventGroup: TEventGroupHandle_t): TEventBits_t;
  cdecl; external;

procedure vEventGroupDelete(xEventGroup: TEventGroupHandle_t); cdecl; external;

procedure vEventGroupSetBitsCallback(pvEventGroup: pointer;
  ulBitsToSet: uint32); cdecl; external;

procedure vEventGroupClearBitsCallback(pvEventGroup: pointer;
  ulBitsToClear: uint32); cdecl; external;

{$if defined(configUSE_TRACE_FACILITY) and (configUSE_TRACE_FACILITY = 1)}
function uxEventGroupGetNumber(xEventGroup: pointer): TUBaseType_t; cdecl; external;
{$endif}


implementation

function xEventGroupClearBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToClear: TEventBits_t): TEventBits_t;
begin
  xEventGroupClearBitsFromISR :=
    xTimerPendFunctionCallFromISR(@vEventGroupClearBitsCallback, pointer(
    xEventGroup), uint32(uxBitsToClear), nil);
end;

function xEventGroupSetBitsFromISR(xEventGroup: TEventGroupHandle_t;
  uxBitsToSet: TEventBits_t; pxHigherPriorityTaskWoken: PBaseType_t
  ): TBaseType_t;
begin
  xEventGroupSetBitsFromISR := xTimerPendFunctionCallFromISR(
    @vEventGroupSetBitsCallback, pointer(xEventGroup), uint32(uxBitsToSet),
    pxHigherPriorityTaskWoken);
end;

function xEventGroupGetBits(xEventGroup: TEventGroupHandle_t): TEventBits_t;
begin
  xEventGroupGetBits := xEventGroupClearBits(xEventGroup, 0);
end;

end.
