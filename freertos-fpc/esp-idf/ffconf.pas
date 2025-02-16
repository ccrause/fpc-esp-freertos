unit ffconf;

interface

{$include sdkconfig.inc}
uses
  portmacro, semphr;

const
  FFCONF_DEF = 86604;
  FF_FS_READONLY = 0;
  FF_FS_MINIMIZE = 0;
  FF_USE_STRFUNC = 0;
  FF_USE_FIND = 0;
  FF_USE_MKFS = 1;
  FF_USE_FASTSEEK = {$ifdef CONFIG_FATFS_USE_FASTSEEK}true{$else}false{$endif};
  FF_USE_EXPAND = 0;
  FF_USE_CHMOD = 1;
  FF_USE_LABEL = 0;
  FF_USE_FORWARD = 0;
  FF_CODE_PAGE = CONFIG_FATFS_CODEPAGE;

{$if defined(CONFIG_FATFS_LFN_STACK)}
const
  FF_USE_LFN = 2;
{$elseif defined(CONFIG_FATFS_LFN_HEAP)}
const
  FF_USE_LFN = 3;
{$else}
const
  FF_USE_LFN = 0;
{$endif}
{$ifdef CONFIG_FATFS_MAX_LFN}
const
  FF_MAX_LFN = CONFIG_FATFS_MAX_LFN;
{$endif}

{$ifdef CONFIG_FATFS_API_ENCODING_UTF_8}
const
  FF_LFN_UNICODE = 2;
{$elseif defined(CONFIG_FATFS_API_ENCODING_UTF_16)}
const
  FF_LFN_UNICODE = 1;
{$else}
const
  FF_LFN_UNICODE = 0;
{$endif}

const
  FF_LFN_BUF = 255;
  FF_SFN_BUF = 12;
  FF_STRF_ENCODE = 3;
  FF_FS_RPATH = 0;
  FF_VOLUMES = 2;
  FF_STR_VOLUME_ID = 0;
  FF_MULTI_PARTITION = 1;
  FF_SS_SDCARD = 512;
  FF_SS_WL = CONFIG_WL_SECTOR_SIZE;

  FF_MIN_SS = {$if (FF_SS_SDCARD <= FF_SS_WL)}FF_SS_SDCARD{$else}FF_SS_WL{$endif};
  FF_MAX_SS = {$if (FF_SS_SDCARD >= FF_SS_WL)}FF_SS_SDCARD{$else}FF_SS_WL{$endif};

const
  FF_VOLUME_STRS: array[0..7] of string = ('RAM', 'NAND', 'CF', 'SD', 'SD2', 'USB', 'USB2', 'USB3');

const
  FF_USE_TRIM = 0;
  FF_FS_NOFSINFO = 0;
  FF_FS_TINY = not (CONFIG_FATFS_PER_FILE_CACHE);
  FF_FS_EXFAT = 0;
  FF_FS_NORTC = 0;
  FF_NORTC_MON = 1;
  FF_NORTC_MDAY = 1;
  FF_NORTC_YEAR = 2018;
  FF_FS_LOCK = CONFIG_FATFS_FS_LOCK;
  FF_FS_REENTRANT = 1;
  FF_FS_TIMEOUT = CONFIG_FATFS_TIMEOUT_MS div portTICK_PERIOD_MS;

type
  TFF_SYNC = TSemaphoreHandle;

function ff_memalloc(msize: dword): pointer; cdecl; external;
procedure ff_memfree(para1: pointer); cdecl; external;


// Redefine names of disk IO functions to prevent name collisions */
//const
//  disk_initialize = ff_disk_initialize;
//  disk_status = ff_disk_status;
//  disk_read = ff_disk_read;
//  disk_write = ff_disk_write;
//  disk_ioctl = ff_disk_ioctl;

implementation

end.
