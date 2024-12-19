unit c_dirent;

{ Newlib/libc directory and file information definitions  }

interface

type
  TDIR = record
    dd_vfs_idx: uint16;
    dd_rsv: uint16;
  end;
  PDIR = ^TDIR;

  Tdirent = record
    d_ino: int32;
    d_type: byte;
    d_name: array[0..255] of char;
  end;
  Pdirent = ^Tdirent;
  PPdirent = ^Pdirent;

const
  // Constants for Tdirent.d_type
  DT_UNKNOWN = 0;
  DT_REG     = 1;
  DT_DIR     = 2;

type
  TtimeSpec = record
    tv_sec,
    tv_nsec: uint32;
  end;

  Pstat = ^Tstat;
  Tstat = record
    st_dev: int16;
    st_ino: uint16;
    st_mode: uint32;
    st_nlink: uint16;
    st_uid: uint16;
    st_gid: uint16;
    st_rdev: int16;
    st_size: uint32;
    st_atime,
    st_mtime,
    st_ctime: TTimeSpec;
    st_blksize: uint32;
    st_blocks: uint32;
    st_spare4: array[0..1] of uint32;
  end;

const
  // Constants for interpreting stat.st_mode
  S_IFMT   = &0170000; // mask for type of file
  S_IFDIR  = &0040000; // directory
  S_IFCHR  = &0020000; // character special
  S_IFBLK  = &0060000; // block special
  S_IFREG  = &0100000; // regular
  S_IFLNK  = &0120000; // symbolic link
  S_IFSOCK = &0140000; // socket
  S_IFIFO  = &0010000; // fifo

function opendir(Name: PChar): PDIR; external;
function readdir(pdir: PDIR): Pdirent; external;
function telldir(pdir: PDIR): longint; external;
procedure seekdir(pdir: PDIR; loc: longint); external;
procedure rewinddir(pdir: PDIR); external;
function closedir(pdir: PDIR): longint; external;
function readdir_r(pdir: PDIR; entry: Pdirent; out_dirent: PPdirent): longint; external;

function chmod(path: PChar; mode: uint32): integer; external;
function fchmod (fd: integer; mode: uint32): integer; external;
function fstat (fd: integer; sbuf: Pstat): integer; external;
function mkdir (path: PChar; mode: uint32): integer; external;
function mkfifo (path: PChar; mode: uint32): integer; external;
function stat (path: PChar; sbuf: Pstat): integer; external;
function umask (mask: uint32): uint32; external;

implementation

end.
