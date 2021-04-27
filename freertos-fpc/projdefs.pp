unit projdefs;

{$inline on}
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
  TTaskFunction = procedure(para1: pointer);

function pdMS_TO_TICKS(xTimeInMs: TTickType): uint32; inline;
function pdTICKS_TO_MS(xTicks: uint32): uint32; inline;

implementation

function pdMS_TO_TICKS(xTimeInMs: TTickType): uint32;
begin
   pdMS_TO_TICKS := xTimeInMs * configTICK_RATE_HZ div 1000;
end;

function pdTICKS_TO_MS(xTicks: uint32): uint32;
begin
  pdTICKS_TO_MS := xTicks  * 1000 div configTICK_RATE_HZ;
end;

end.
