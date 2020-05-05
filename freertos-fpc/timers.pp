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
  TTimerHandle_t = pointer;
  PTimerHandle_t = ^TTimerHandle_t;
  TTimerCallbackFunction_t = procedure(xTimer: TTimerHandle_t); cdecl;
  TPendedFunction_t = procedure(para1: pointer; para2: uint32); cdecl;

  // Deifned in freertos/task.h
  TTaskHandle_t = pointer;

{$if defined(configSUPPORT_DYNAMIC_ALLOCATION) and (configSUPPORT_DYNAMIC_ALLOCATION = 1)}
function xTimerCreate(pcTimerName: PChar;
								const xTimerPeriodInTicks: TTickType_t;
								const uxAutoReload: TUBaseType_t;
								pvTimerID: pointer;
								pxCallbackFunction: TTimerCallbackFunction_t): TTimerCallbackFunction_t; external;
{$endif}

{$if defined(configSUPPORT_STATIC_ALLOCATION) and (configSUPPORT_STATIC_ALLOCATION = 1)}
function  xTimerCreateStatic(pcTimerName: PChar;
									const xTimerPeriodInTicks: TTickType_t,
									const uxAutoReload: TUBaseType_t;
									pvTimerID: pointer;
									pxCallbackFunction: TTimerCallbackFunction_t;
									pxTimerBuffer: PStaticTimer_t): TTimerHandle_t; external;// PRIVILEGED_FUNCTION;
{$endif}

function pvTimerGetTimerID(xTimer: TTimerHandle_t): pointer; external; // PRIVILEGED_FUNCTION;
function vTimerSetTimerID(xTimer: TTimerHandle_t; pvNewID: pointer): pointer; external; //PRIVILEGED_FUNCTION
function xTimerIsTimerActive(xTimer: TTimerHandle_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;
function xTimerGetTimerDaemonTaskHandle: TTaskHandle_t; cdecl; external;

function xTimerGetPeriod(xTimer: TTimerHandle_t): TTickType_t; external; // PRIVILEGED_FUNCTION;
function xTimerGetExpiryTime(xTimer: TTimerHandle_t ): TTickType_t; external; //PRIVILEGED_FUNCTION;

function xTimerStart(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
function xTimerStop(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
function xTimerChangePeriod(xTimer: TTimerHandle_t; xNewPeriod, xTicksToWait: TTickType_t): longint;
function xTimerDelete(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
function xTimerReset(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
function xTimerStartFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
function xTimerStopFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
function xTimerChangePeriodFromISR(xTimer: TTimerHandle_t; xNewPeriod: TTickType_t;
  pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
function xTimerResetFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;

function xTimerPendFunctionCallFromISR(xFunctionToPend: TPendedFunction_t;
  pvParameter1: pointer; ulParameter2: uint32;
  pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t; cdecl; external;

function xTimerPendFunctionCall(xFunctionToPend: TPendedFunction_t;
  pvParameter1: pointer; ulParameter2: uint32; xTicksToWait: TTickType_t): TBaseType_t;
  cdecl; external;

function pcTimerGetTimerName(xTimer: TTimerHandle_t): PChar; cdecl; external;

function xTimerCreateTimerTask: TBaseType_t; external; //PRIVILEGED_FUNCTION;

function xTimerGenericCommand(xTimer: TTimerHandle_t;
  const xCommandID: TBaseType_t; const xOptionalValue: TTickType_t;
  pxHigherPriorityTaskWoken: PBaseType_t; const xTicksToWait: TTickType_t): TBaseType_t; external; //PRIVILEGED_FUNCTION;

implementation

function xTimerStart(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
begin
  xTimerStart := xTimerGenericCommand(xTimer, tmrCOMMAND_START, xTaskGetTickCount,
    nil, xTicksToWait);
end;

function xTimerStop(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
begin
  xTimerStop := xTimerGenericCommand(xTimer, tmrCOMMAND_STOP, 0, nil, xTicksToWait);
end;

function xTimerChangePeriod(xTimer: TTimerHandle_t; xNewPeriod, xTicksToWait: TTickType_t): longint;
begin
  xTimerChangePeriod := xTimerGenericCommand(xTimer, tmrCOMMAND_CHANGE_PERIOD,
    xNewPeriod, nil, xTicksToWait);
end;

function xTimerDelete(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
begin
  xTimerDelete := xTimerGenericCommand(xTimer, tmrCOMMAND_DELETE, 0, nil, xTicksToWait);
end;

function xTimerReset(xTimer: TTimerHandle_t; xTicksToWait: TTickType_t): TBaseType_t;
begin
  xTimerReset := xTimerGenericCommand(xTimer, tmrCOMMAND_RESET, xTaskGetTickCount,
    nil, xTicksToWait);
end;

function xTimerStartFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
begin
  xTimerStartFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_START_FROM_ISR,
    xTaskGetTickCountFromISR, pxHigherPriorityTaskWoken, 0);
end;

function xTimerStopFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
begin
  xTimerStopFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_STOP_FROM_ISR, 0,
    pxHigherPriorityTaskWoken, 0);
end;

function xTimerChangePeriodFromISR(xTimer: TTimerHandle_t; xNewPeriod: TTickType_t;
  pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
begin
  xTimerChangePeriodFromISR := xTimerGenericCommand(
    xTimer, tmrCOMMAND_CHANGE_PERIOD_FROM_ISR, xNewPeriod, pxHigherPriorityTaskWoken, 0);
end;

function xTimerResetFromISR(xTimer: TTimerHandle_t; pxHigherPriorityTaskWoken: PBaseType_t): TBaseType_t;
begin
  xTimerResetFromISR := xTimerGenericCommand(xTimer, tmrCOMMAND_RESET_FROM_ISR,
    xTaskGetTickCountFromISR, pxHigherPriorityTaskWoken, 0);
end;


end.
