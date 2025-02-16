unit ff;

{$linklib fatfs, static}

interface

uses
  ffconf;

const
  FF_DEFINED = 86604;
{ $include "ffconf.h"    /* FatFs configuration options *)}

{$if not(FF_DEFINED = FFCONF_DEF)}
  {$error Wrong configuration file (ffconf).}
{$endif}

const
  FF_INTDEF = 1;

type
  PUINT = ^TUINT;
  TUINT = dword;
  pbyte = ^TBYTE;
  TBYTE = byte;
  PWORD = ^TWORD;
  TWORD = word;
  PWCHAR = ^TWCHAR;
  TWCHAR = word;
  PDWORD = ^TDWORD;
  TDWORD = dword;

{$ifdef FF_MULTI_PARTITION    (* Multiple partition configuration *)}
type
  PPARTITION = ^TPARTITION;

  TPARTITION = record
    pd: TBYTE;
    pt: TBYTE;
  end;
var
  VolToPart : PPARTITION; cvar; external;
{$endif}

{$ifdef FF_STR_VOLUME_ID}
{$ifndef FF_VOLUME_STRS}
  VolumeStr : array[0..(FF_VOLUMES)-1] of Pchar;cvar;external;
{$endif}
{$endif}

{$if defined(FF_USE_LFN) and (FF_LFN_UNICODE = 1)   (*Unicode in UTF-16 encoding *)}
type
  PTCHAR = ^TTCHAR;
  TTCHAR = TWCHAR;
{$elseif defined(FF_USE_LFN) and (FF_LFN_UNICODE = 2)  (* Unicode in UTF-8 encoding *)}
type
  PTCHAR = ^TTCHAR;
  TTCHAR = char;
{$elseif defined(FF_USE_LFN) and (FF_LFN_UNICODE = 3)  (* Unicode in UTF-32 encoding *)}
type
  PTCHAR = ^TTCHAR;
  TTCHAR = TDWORD;
{$elseif defined(FF_USE_LFN) and ((FF_LFN_UNICODE < 0) or (FF_LFN_UNICODE > 3))}
{$error Wrong FF_LFN_UNICODE setting}
{$else}

type
  PTCHAR = ^TTCHAR;
  TTCHAR = char;

{$endif}

{$if defined(FF_FS_EXFAT)}
{$if not(FF_INTDEF = 2)}
{$error exFAT feature wants C99 or later}
{$endif}
type
  PFSIZE = ^TFSIZE;
  TFSIZE = TQWORD;
{$else}
type
  PFSIZE = ^TFSIZE;
  TFSIZE = TDWORD;
{$endif}

type
  PFATFS = ^TFATFS;
  PPFATFS = ^PFATFS;

  TFATFS = record
    fs_type: TBYTE;
    pdrv: TBYTE;
    n_fats: TBYTE;
    wflag: TBYTE;
    fsi_flag: TBYTE;
    id: TWORD;
    n_rootdir: TWORD;
    csize: TWORD;
{$if not(FF_MAX_SS = FF_MIN_SS)}
    ssize: TWORD;
{$endif}
{$if defined(FF_USE_LFN)}
    lfnbuf: PWCHAR;
{$endif}
{$if defined(FF_FS_EXFAT)}
    dirbuf: pbyte;
{$endif}
{$if defined(FF_FS_REENTRANT)}
    sobj: TFF_SYNC;
{$endif}
{$ifndef defined(FF_FS_READONLY)}
    last_clst: TDWORD;
    free_clst: TDWORD;
{$endif}
{$if defined(FF_FS_RPATH)}
    cdir: TDWORD;
{$if defined(FF_FS_EXFAT)}
    cdc_scl: TDWORD;
    cdc_size: TDWORD;
    cdc_ofs: TDWORD;
{$endif}
{$endif}
    n_fatent: TDWORD;
    fsize: TDWORD;
    volbase: TDWORD;
    fatbase: TDWORD;
    dirbase: TDWORD;
    database: TDWORD;
{$if defined(FF_FS_EXFAT)}
    bitbase: TDWORD;
{$endif}
    winsect: TDWORD;
    win: array[0..(FF_MAX_SS) - 1] of TBYTE;
  end;


type
  PFFOBJID = ^TFFOBJID;

  TFFOBJID = record
    fs: PFATFS;
    id: TWORD;
    attr: TBYTE;
    stat: TBYTE;
    sclust: TDWORD;
    objsize: TFSIZE;
{$if defined(FF_FS_EXFAT)}
    n_cont: TDWORD;
    n_frag: TDWORD;
    c_scl: TDWORD;
    c_size: TDWORD;
    c_ofs: TDWORD;
{$endif}
{$if defined(FF_FS_LOCK)}
    lockid: TUINT;
{$endif}
  end;

type
  PFIL = ^TFIL;
  TFIL = record
    obj: TFFOBJID;
    flag: TBYTE;
    err: TBYTE;
    fptr: TFSIZE;
    clust: TDWORD;
    sect: TDWORD;
{$if not defined(FF_FS_READONLY)}
    dir_sect: TDWORD;
    dir_ptr: pbyte;
{$endif}
{$if defined(FF_USE_FASTSEEK)}
    cltbl: PDWORD;
{$endif}
{$if not defined(FF_FS_TINY)}
    buf: array[0..(FF_MAX_SS) - 1] of TBYTE;
{$endif}
  end;

type
  PFF_DIR = ^TFF_DIR;
  TFF_DIR = record
    obj: TFFOBJID;
    dptr: TDWORD;
    clust: TDWORD;
    sect: TDWORD;
    dir: pbyte;
    fn: array[0..11] of TBYTE;
{$if defined(FF_USE_LFN)}
    blk_ofs: TDWORD;
{$endif}
{$if defined(FF_USE_FIND)}
    pat: PTCHAR;
{$endif}
  end;


type
  PFILINFO = ^TFILINFO;
  TFILINFO = record
    fsize: TFSIZE;
    fdate: TWORD;
    ftime: TWORD;
    fattrib: TBYTE;
{$if defined(FF_USE_LFN)}
    altname: array[0..(FF_SFN_BUF + 1) - 1] of TTCHAR;
    fname: array[0..(FF_LFN_BUF + 1) - 1] of TTCHAR;
{$else}
    fname: array[0..(12 + 1) - 1] of TTCHAR;
{$endif}
  end;


  PFRESULT = ^TFRESULT;
  TFRESULT = (FR_OK := 0, FR_DISK_ERR, FR_INT_ERR, FR_NOT_READY,
    FR_NO_FILE, FR_NO_PATH, FR_INVALID_NAME,
    FR_DENIED, FR_EXIST, FR_INVALID_OBJECT,
    FR_WRITE_PROTECTED, FR_INVALID_DRIVE,
    FR_NOT_ENABLED, FR_NO_FILESYSTEM, FR_MKFS_ABORTED,
    FR_TIMEOUT, FR_LOCKED, FR_NOT_ENOUGH_CORE,
    FR_TOO_MANY_OPEN_FILES, FR_INVALID_PARAMETER
    );

  Tforwardfunc = function(para1: pbyte; para2: TUINT): TUINT;

function f_open(fp: PFIL; path: PTCHAR; mode: TBYTE): TFRESULT; external;
function f_close(fp: PFIL): TFRESULT; external;
function f_read(fp: PFIL; buff: pointer; btr: TUINT; br: PUINT): TFRESULT; external;
function f_write(fp: PFIL; buff: pointer; btw: TUINT; bw: PUINT): TFRESULT; external;
function f_lseek(fp: PFIL; ofs: TFSIZE): TFRESULT; external;
function f_truncate(fp: PFIL): TFRESULT; external;
function f_sync(fp: PFIL): TFRESULT; external;
function f_opendir(dp: PFF_DIR; path: PTCHAR): TFRESULT; external;
function f_closedir(dp: PFF_DIR): TFRESULT; external;
function f_readdir(dp: PFF_DIR; fno: PFILINFO): TFRESULT; external;
function f_findfirst(dp: PFF_DIR; fno: PFILINFO; path: PTCHAR;
  pattern: PTCHAR): TFRESULT; external;
function f_findnext(dp: PFF_DIR; fno: PFILINFO): TFRESULT; external;
function f_mkdir(path: PTCHAR): TFRESULT; external;
function f_unlink(path: PTCHAR): TFRESULT; external;
function f_rename(path_old: PTCHAR; path_new: PTCHAR): TFRESULT; external;
function f_stat(path: PTCHAR; fno: PFILINFO): TFRESULT; external;
function f_chmod(path: PTCHAR; attr: TBYTE; mask: TBYTE): TFRESULT; external;
function f_utime(path: PTCHAR; fno: PFILINFO): TFRESULT; external;
function f_chdir(path: PTCHAR): TFRESULT; external;
function f_chdrive(path: PTCHAR): TFRESULT; external;
function f_getcwd(buff: PTCHAR; len: TUINT): TFRESULT; external;
function f_getfree(path: PTCHAR; nclst: PDWORD; fatfs: PPFATFS): TFRESULT; external;
function f_getlabel(path: PTCHAR; _label: PTCHAR; vsn: PDWORD): TFRESULT; external;
function f_setlabel(_label: PTCHAR): TFRESULT; external;
function f_forward(fp: PFIL; func: Tforwardfunc; btf: TUINT; bf: PUINT): TFRESULT; external;
function f_expand(fp: PFIL; fsz: TFSIZE; opt: TBYTE): TFRESULT; external;
function f_mount(fs: PFATFS; path: PTCHAR; opt: TBYTE): TFRESULT; external;
function f_mkfs(path: PTCHAR; opt: TBYTE; au: TDWORD; work: pointer;
  len: TUINT): TFRESULT; external;
function f_fdisk(pdrv: TBYTE; szt: PDWORD; work: pointer): TFRESULT; external;
function f_setcp(cp: TWORD): TFRESULT; external;
function f_putc(c: TTCHAR; fp: PFIL): longint; external;
function f_puts(str: PTCHAR; cp: PFIL): longint; external;
function f_printf(fp: PFIL; str: PTCHAR; args: array of const): longint; external;
function f_printf(fp: PFIL; str: PTCHAR): longint; external;
function f_gets(buff: PTCHAR; len: longint; fp: PFIL): PTCHAR; external;

function f_eof(fp: PFIL): boolean;
function f_error(fp: PFIL): longint;
function f_tell(fp: PFIL): longint;
function f_size(fp: PFIL): longint;
function f_rewind(fp: PFIL): TFRESULT;
function f_rewinddir(dp: PFF_DIR): TFRESULT;
function f_rmdir(path: PTCHAR): TFRESULT;
function f_unmount(path: PTCHAR): TFRESULT;

{$ifndef EOF}
const
  EOF = -(1);

{$endif}

{$if not defined(FF_FS_READONLY) and not defined(FF_FS_NORTC)}
function get_fattime: TDWORD; external;
{$endif}

{$if (FF_USE_LFN >= 1)}
function ff_oem2uni(oem: TWCHAR; cp: TWORD): TWCHAR; external;
function ff_uni2oem(uni: TDWORD; cp: TWORD): TWCHAR; external;
function ff_wtoupper(uni: TDWORD): TDWORD; external;
{$endif}
{$if FF_USE_LFN = 3}
function ff_memalloc(msize: TUINT): pointer; external;
procedure ff_memfree(mblock: pointer); external;
{$endif}

{$if defined(FF_FS_REENTRANT)}
function ff_cre_syncobj(vol: TBYTE; sobj: PFF_SYNC): longint; external;
function ff_req_grant(sobj: TFF_SYNC): longint; external;
procedure ff_rel_grant(sobj: TFF_SYNC); external;
function ff_del_syncobj(sobj: TFF_SYNC): longint; external;
{$endif}

const
  FA_READ = $01;
  FA_WRITE = $02;
  FA_OPEN_EXISTING = $00;
  FA_CREATE_NEW = $04;
  FA_CREATE_ALWAYS = $08;
  FA_OPEN_ALWAYS = $10;
  FA_OPEN_APPEND = $30;


const
  FM_FAT = $01;
  FM_FAT32 = $02;
  FM_EXFAT = $04;
  FM_ANY = $07;
  FM_SFD = $08;
  FS_FAT12 = 1;
  FS_FAT16 = 2;
  FS_FAT32 = 3;
  FS_EXFAT = 4;
  AM_RDO = $01;
  AM_HID = $02;
  AM_SYS = $04;
  AM_VOL = $08;
  AM_DIR = $10;
  AM_ARC = $20;

implementation

function f_eof(fp: PFIL): boolean;
begin
  f_eof := fp^.fptr = fp^.obj.objsize;
end;

function f_error(fp: PFIL): longint;
begin
  f_error := fp^.err;
end;

function f_tell(fp: PFIL): longint;
begin
  f_tell := fp^.fptr;
end;

function f_size(fp: PFIL): longint;
begin
  f_size := fp^.obj.objsize;
end;

function f_rewind(fp: PFIL): TFRESULT;
begin
  f_rewind := f_lseek(fp, 0);
end;

function f_rewinddir(dp: PFF_DIR): TFRESULT;
begin
  f_rewinddir := f_readdir(dp, nil);
end;

function f_rmdir(path: PTCHAR): TFRESULT;
begin
  f_rmdir := f_unlink(path);
end;

function f_unmount(path: PTCHAR): TFRESULT;
begin
  f_unmount := f_mount(nil, path, 0);
end;

end.
