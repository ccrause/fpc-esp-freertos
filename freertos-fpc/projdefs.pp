unit projdefs;

{$include sdkconfig.inc}
{$include freertosconfig.inc}

interface

uses
  portmacro;

const
  pdFALSE			    = 0;
  pdTRUE			    = 1;
  pdPASS			    = pdTRUE;
  pdFAIL			    = pdFALSE;
  errQUEUE_EMPTY	= 0;
  errQUEUE_FULL	  = 0;
  errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY	= -1;
  errQUEUE_BLOCKED= -4;
  errQUEUE_YIELD	= -5;

type
  TTaskFunction_t = procedure(para1: pointer); cdecl;

function pdMS_TO_TICKS(xTimeInMs: TTickType_t): uint32;
function pdTICKS_TO_MS(xTicks: uint32): uint32;

{$ifndef configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES}
const
  configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 0; // Should actually be a define
{$endif}

{$if (configUSE_16_BIT_TICKS = 1)}
const
  pdINTEGRITY_CHECK_VALUE = $5a5a;
{$else}
const
  pdINTEGRITY_CHECK_VALUE = $5a5a5a5a;
{$endif}

implementation

function pdMS_TO_TICKS(xTimeInMs: TTickType_t): uint32;
begin
   pdMS_TO_TICKS := xTimeInMs * configTICK_RATE_HZ div 1000;
end;

function pdTICKS_TO_MS(xTicks: uint32): uint32;
begin
  pdTICKS_TO_MS := xTicks  * 1000 div configTICK_RATE_HZ;
end;

end.
