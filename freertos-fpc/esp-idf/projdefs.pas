unit projdefs;

{$inline on}
{$include freertosconfig.inc}

interface

uses
  portmacro;

type
  TTaskFunction = procedure (arg:pointer);

{$ifndef pdMS_TO_TICKS}
  function pdMS_TO_TICKS(xTimeInMs : longint) : TTickType;
{$endif}

{$ifndef pdTICKS_TO_MS}
  function pdTICKS_TO_MS(xTimeInTicks : longint) : TTickType;
{$endif}

const
  errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY = -(1);  
  errQUEUE_BLOCKED = -4;
  errQUEUE_YIELD = -5;

  pdFALSE = 0;
  pdTRUE = 1;

{$ifndef configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES}
  configUSE_LIST_DATA_INTEGRITY_CHECK_BYTES = 0;  
{$endif}
{$if configTICK_TYPE_WIDTH_IN_BITS = TICK_TYPE_WIDTH_16_BITS}
  pdINTEGRITY_CHECK_VALUE = $5a5a;  
{$elseif configTICK_TYPE_WIDTH_IN_BITS = TICK_TYPE_WIDTH_32_BITS}
  pdINTEGRITY_CHECK_VALUE = $5a5a5a5a;  
{$elseif configTICK_TYPE_WIDTH_IN_BITS = TICK_TYPE_WIDTH_64_BITS )}
  pdINTEGRITY_CHECK_VALUE = $5a5a5a5a5a5a5a5a;  
{$else}
  {$error configTICK_TYPE_WIDTH_IN_BITS set to unsupported tick type width.}
{$endif}

  pdFREERTOS_ERRNO_NONE = 0;
  pdFREERTOS_ERRNO_ENOENT = 2;  
  pdFREERTOS_ERRNO_EINTR = 4;  
  pdFREERTOS_ERRNO_EIO = 5;  
  pdFREERTOS_ERRNO_ENXIO = 6;  
  pdFREERTOS_ERRNO_EBADF = 9;  
  pdFREERTOS_ERRNO_EAGAIN = 11;  
  pdFREERTOS_ERRNO_EWOULDBLOCK = 11;  
  pdFREERTOS_ERRNO_ENOMEM = 12;  
  pdFREERTOS_ERRNO_EACCES = 13;  
  pdFREERTOS_ERRNO_EFAULT = 14;  
  pdFREERTOS_ERRNO_EBUSY = 16;  
  pdFREERTOS_ERRNO_EEXIST = 17;  
  pdFREERTOS_ERRNO_EXDEV = 18;  
  pdFREERTOS_ERRNO_ENODEV = 19;  
  pdFREERTOS_ERRNO_ENOTDIR = 20;  
  pdFREERTOS_ERRNO_EISDIR = 21;  
  pdFREERTOS_ERRNO_EINVAL = 22;  
  pdFREERTOS_ERRNO_ENOSPC = 28;  
  pdFREERTOS_ERRNO_ESPIPE = 29;  
  pdFREERTOS_ERRNO_EROFS = 30;  
  pdFREERTOS_ERRNO_EUNATCH = 42;  
  pdFREERTOS_ERRNO_EBADE = 50;  
  pdFREERTOS_ERRNO_EFTYPE = 79;  
  pdFREERTOS_ERRNO_ENMFILE = 89;  
  pdFREERTOS_ERRNO_ENOTEMPTY = 90;  
  pdFREERTOS_ERRNO_ENAMETOOLONG = 91;  
  pdFREERTOS_ERRNO_EOPNOTSUPP = 95;  
  pdFREERTOS_ERRNO_EAFNOSUPPORT = 97;  
  pdFREERTOS_ERRNO_ENOBUFS = 105;  
  pdFREERTOS_ERRNO_ENOPROTOOPT = 109;  
  pdFREERTOS_ERRNO_EADDRINUSE = 112;  
  pdFREERTOS_ERRNO_ETIMEDOUT = 116;  
  pdFREERTOS_ERRNO_EINPROGRESS = 119;  
  pdFREERTOS_ERRNO_EALREADY = 120;  
  pdFREERTOS_ERRNO_EADDRNOTAVAIL = 125;  
  pdFREERTOS_ERRNO_EISCONN = 127;  
  pdFREERTOS_ERRNO_ENOTCONN = 128;  
  pdFREERTOS_ERRNO_ENOMEDIUM = 135;  
  pdFREERTOS_ERRNO_EILSEQ = 138;  
  pdFREERTOS_ERRNO_ECANCELED = 140;  
  pdFREERTOS_LITTLE_ENDIAN = 0;
  pdFREERTOS_BIG_ENDIAN = 1;  
  pdLITTLE_ENDIAN = pdFREERTOS_LITTLE_ENDIAN;  
  pdBIG_ENDIAN = pdFREERTOS_BIG_ENDIAN;  

implementation

function pdMS_TO_TICKS(xTimeInMs : longint) : TTickType;
begin
  pdMS_TO_TICKS := (uint64(xTimeInMs) * uint64(configTICK_RATE_HZ)) div 1000;
end;

function pdTICKS_TO_MS(xTimeInTicks : longint) : TTickType;
begin
  pdTICKS_TO_MS := (uint64(xTimeInTicks) * 1000) div uint64(configTICK_RATE_HZ);
end;

//function pdFALSE : TBaseType_t;
//  begin
//    pdFALSE:=TBaseType_t(&);
//  end;
//
//function pdTRUE : TBaseType_t;
//  begin
//    pdTRUE:=TBaseType_t(1);
//  end;
//
//function pdFALSE_SIGNED : TBaseType_t;
//  begin
//    pdFALSE_SIGNED:=TBaseType_t(&);
//  end;
//
//function pdTRUE_SIGNED : TBaseType_t;
//  begin
//    pdTRUE_SIGNED:=TBaseType_t(1);
//  end;
//
//function pdFALSE_UNSIGNED : TUBaseType_t;
//  begin
//    pdFALSE_UNSIGNED:=TUBaseType_t(&);
//  end;
//
//function pdTRUE_UNSIGNED : TUBaseType_t;
//  begin
//    pdTRUE_UNSIGNED:=TUBaseType_t(1);
//  end;
//
//function errQUEUE_EMPTY : TBaseType_t;
//  begin
//    errQUEUE_EMPTY:=TBaseType_t(&);
//  end;
//
//function errQUEUE_FULL : TBaseType_t;
//  begin
//    errQUEUE_FULL:=TBaseType_t(&);
//  end;

end.
