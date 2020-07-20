unit timers;

{$include freertosconfig.inc}

interface

uses
  portable, portmacro, task;

const
   tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR 	=  -2;
   tmrCOMMAND_EXECUTE_CALLBACK				    =  -1;
   tmrCOMMAND_START_DONT_TRACE				    =  0;
   tmrCOMMAND_START					              =  1;
   tmrCOMMAND_RESET						            =  2;
   tmrCOMMAND_STOP							          =  3;
   tmrCOMMAND_CHANGE_PERIOD				        =  4;
   tmrCOMMAND_DELETE						          =  5;
   tmrFIRST_FROM_ISR_COMMAND				      =  6;
   tmrCOMMAND_START_FROM_ISR				      =  6;
   tmrCOMMAND_RESET_FROM_ISR				      =  7;
   tmrCOMMAND_STOP_FROM_ISR				        =  8;
   tmrCOMMAND_CHANGE_PERIOD_FROM_ISR		  =  9;

type
  TTimerHandle = pointer;
  PTimerHandle = ^TTimerHandle;
  TTimerCallbackFunction = procedure(xTimer: TTimerHandle);
  TPendedFunction = procedure(para1: pointer; para2: uint32);

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function xTimerCreate(pcTimerName: PChar;
								const xTimerPeriodInTicks: TTickType;
								const uxAutoReload: TUBaseType;
								pvTimerID: pointer;
								pxCallbackFunction: TTimerCallbackFunction): TTimerCallbackFunction; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
function  xTimerCreateStatic(pcTimerName: PChar;
									const xTimerPeriodInTicks: TTickType,
									const uxAutoReload: TUBaseType;
									pvTimerID: pointer;
									pxCallbackFunction: TTimerCallbackFunction;
									pxTimerBuffer: PStaticTimer): TTimerHandle; external;
{$endif}
function pvTimerGetTimerID(xTimer: TTimerHandle): pointer; external;
function vTimerSetTimerID(xTimer: TTimerHandle; pvNewID: pointer): pointer; external;
function xTimerIsTimerActive(xTimer: TTimerHandle): TBaseType; external;
function xTimerGetTimerDaemonTaskHandle: TTaskHandle; external;
function xTimerGetPeriod(xTimer: TTimerHandle): TTickType; external;
function xTimerGetExpiryTime(xTimer: TTimerHandle ): TTickType; external;

function xTimerStart(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
function xTimerStop(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
function xTimerChangePeriod(xTimer: TTimerHandle; xNewPeriod, xTicksToWait: TTickType): longint;
function xTimerDelete(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
function xTimerReset(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
function xTimerStartFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xTimerStopFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xTimerChangePeriodFromISR(xTimer: TTimerHandle; xNewPeriod: TTickType;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
function xTimerResetFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;

function xTimerPendFunctionCallFromISR(xFunctionToPend: TPendedFunction;
  pvParameter1: pointer; ulParameter2: uint32;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType; external;
function xTimerPendFunctionCall(xFunctionToPend: TPendedFunction;
  pvParameter1: pointer; ulParameter2: uint32; xTicksToWait: TTickType): TBaseType;
  external;
function pcTimerGetTimerName(xTimer: TTimerHandle): PChar; external;
function xTimerCreateTimerTask: TBaseType; external;
function xTimerGenericCommand(xTimer: TTimerHandle;
  const xCommandID: TBaseType; const xOptionalValue: TTickType;
  pxHigherPriorityTaskWoken: PBaseType; const xTicksToWait: TTickType): TBaseType; external;

implementation

function xTimerStart(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
begin
  xTimerStart := xTimerGenericCommand(xTimer, tmrCOMMAND_START, xTaskGetTickCount,
    nil, xTicksToWait);
end;

function xTimerStop(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
begin
  xTimerStop := xTimerGenericCommand(xTimer, tmrCOMMAND_STOP, 0, nil, xTicksToWait);
end;

function xTimerChangePeriod(xTimer: TTimerHandle; xNewPeriod, xTicksToWait: TTickType): longint;
begin
  xTimerChangePeriod := xTimerGenericCommand(xTimer, tmrCOMMAND_CHANGE_PERIOD,
    xNewPeriod, nil, xTicksToWait);
end;

function xTimerDelete(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
begin
  xTimerDelete := xTimerGenericCommand(xTimer, tmrCOMMAND_DELETE, 0, nil, xTicksToWait);
end;

function xTimerReset(xTimer: TTimerHandle; xTicksToWait: TTickType): TBaseType;
begin
  xTimerReset := xTimerGenericCommand(xTimer, tmrCOMMAND_RESET, xTaskGetTickCount,
    nil, xTicksToWait);
end;

function xTimerStartFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTimerStartFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_START_FROM_ISR,
    xTaskGetTickCountFromISR, pxHigherPriorityTaskWoken, 0);
end;

function xTimerStopFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTimerStopFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_STOP_FROM_ISR, 0,
    pxHigherPriorityTaskWoken, 0);
end;

function xTimerChangePeriodFromISR(xTimer: TTimerHandle; xNewPeriod: TTickType;
  pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTimerChangePeriodFromISR := xTimerGenericCommand(
    xTimer, tmrCOMMAND_CHANGE_PERIOD_FROM_ISR, xNewPeriod, pxHigherPriorityTaskWoken, 0);
end;

function xTimerResetFromISR(xTimer: TTimerHandle; pxHigherPriorityTaskWoken: PBaseType): TBaseType;
begin
  xTimerResetFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_RESET_FROM_ISR,
    xTaskGetTickCountFromISR, pxHigherPriorityTaskWoken, 0);
end;

end.
