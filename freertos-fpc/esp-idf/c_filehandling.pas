unit c_filehandling;

interface

type
  TFIL = record
  end;
  PFIL = ^TFIL;

function fileno(stream: PFIL): integer; external;

implementation

uses
  portmacro;

function fopen(filename, mode: pchar): PFIL; external;
function fclose(stream: PFIL): integer; external;
function fread(ptr: pointer; size, nmemb: Tsize; stream: PFIL): Tsize; external;
function fwrite(ptr: pointer; size, nmemb: Tsize; stream: PFIL): Tsize; external;
function remove(filename: pchar): integer; external;
function rename(old_filename, new_filename: pchar): integer; external;
function ftello(stream: PFIL): longint; external;
function fseeko(stream: PFIL; offset: longint; whence: integer): integer; external;
procedure fflush(stream: pointer); external;

// ftruncate is declared in <sys/unistd.h> but is not available in esp-idf
//function ftruncate (fd: integer; len: longint): longint; external;

const
  // Constants for whence parameter of fseek*
  SEEK_SET = 0; // Set file offset to offset
  SEEK_CUR = 1; // Set file offset to current + offset
  SEEK_END = 2; // Set file offset to EOF + offset

  // From rtl/linux/errno.inc
  ESysEPERM = 1;    { Operation not permitted }
  ESysENOENT = 2;    { No such file or directory }
  ESysESRCH = 3;    { No such process }
  ESysEINTR = 4;    { Interrupted system call }
  ESysEIO = 5;    { I/O error }
  ESysENXIO = 6;    { No such device or address }
  ESysE2BIG = 7;    { Arg list too long }
  ESysENOEXEC = 8;    { Exec format error }
  ESysEBADF = 9;    { Bad file number }
  ESysECHILD = 10;   { No child processes }
  ESysEAGAIN = 11;   { Try again }
  ESysENOMEM = 12;   { Out of memory }
  ESysEACCES = 13;   { Permission denied }
  ESysEFAULT = 14;   { Bad address }
  ESysENOTBLK = 15;   { Block device required, NOT POSIX! }
  ESysEBUSY = 16;   { Device or resource busy }
  ESysEEXIST = 17;   { File exists }
  ESysEXDEV = 18;   { Cross-device link }
  ESysENODEV = 19;   { No such device }
  ESysENOTDIR = 20;   { Not a directory }
  ESysEISDIR = 21;   { Is a directory }
  ESysEINVAL = 22;   { Invalid argument }
  ESysENFILE = 23;   { File table overflow }
  ESysEMFILE = 24;   { Too many open files }
  ESysENOTTY = 25;   { Not a typewriter }
  ESysETXTBSY = 26;   { Text file busy. The new process was
                            a pure procedure (shared text) file which was
                            open for writing by another process, or file
                            which was open for writing by another process,
                            or while the pure procedure file was being
                            executed an open(2) call requested write access
                            requested write access.}
  ESysEFBIG = 27;   { File too large }
  ESysENOSPC = 28;   { No space left on device }
  ESysESPIPE = 29;   { Illegal seek }
  ESysEROFS = 30;   { Read-only file system }
  ESysEMLINK = 31;   { Too many links }
  ESysEPIPE = 32;   { Broken pipe }
  ESysEDOM = 33;   { Math argument out of domain of func }
  ESysERANGE = 34;   { Math result not representable }


  ESysEDEADLK = 35;   { Resource deadlock would occur }
  ESysENAMETOOLONG = 36;   { File name too long }
  ESysENOLCK = 37;   { No record locks available }
  ESysENOSYS = 38;   { Function not implemented }
  ESysENOTEMPTY = 39;      { Directory not empty }
  ESysELOOP = 40;   { Too many symbolic links encountered }
  ESysEWOULDBLOCK = ESysEAGAIN;   { Operation would block }
  ESysENOMSG = 42;   { No message of desired type }
  ESysEIDRM = 43;   { Identifier removed }
  ESysECHRNG = 44;   { Channel number out of range }
  ESysEL2NSYNC = 45;       { Level 2 not synchronized }
  ESysEL3HLT = 46;   { Level 3 halted }
  ESysEL3RST = 47;   { Level 3 reset }
  ESysELNRNG = 48;   { Link number out of range }
  ESysEUNATCH = 49;   { Protocol driver not attached }
  ESysENOCSI = 50;   { No CSI structure available }
  ESysEL2HLT = 51;   { Level 2 halted }
  ESysEBADE = 52;   { Invalid exchange }
  ESysEBADR = 53;   { Invalid request descriptor }
  ESysEXFULL = 54;   { Exchange full }
  ESysENOANO = 55;   { No anode }
  ESysEBADRQC = 56;   { Invalid request code }
  ESysEBADSLT = 57;   { Invalid slot }
  ESysEDEADLOCK = ESysEDEADLK; { number 58 is missing }
  ESysEBFONT = 59;   { Bad font file format }
  ESysENOSTR = 60;   { Device not a stream }
  ESysENODATA = 61;   { No data available }
  ESysETIME = 62;   { Timer expired }
  ESysENOSR = 63;   { Out of streams resources }
  ESysENONET = 64;   { Machine is not on the network }
  ESysENOPKG = 65;   { Package not installed }
  ESysEREMOTE = 66;   { Object is remote }
  ESysENOLINK = 67;   { Link has been severed }
  ESysEADV = 68;   { Advertise error }
  ESysESRMNT = 69;   { Srmount error }
  ESysECOMM = 70;   { Communication error on send }
  ESysEPROTO = 71;   { Protocol error }
  ESysEMULTIHOP = 72;      { Multihop attempted }
  ESysEDOTDOT = 73;   { RFS specific error }
  ESysEBADMSG = 74;   { Not a data message }
  ESysEOVERFLOW = 75;      { Value too large for defined data type }
  ESysENOTUNIQ = 76;       { Name not unique on network }
  ESysEBADFD = 77;   { File descriptor in bad state }
  ESysEREMCHG = 78;   { Remote address changed }
  ESysELIBACC = 79;   { Can not access a needed shared library }
  ESysELIBBAD = 80;   { Accessing a corrupted shared library }
  ESysELIBSCN = 81;   { .lib section in a.out corrupted }
  ESysELIBMAX = 82;   { Attempting to link in too many shared libraries }
  ESysELIBEXEC = 83;       { Cannot exec a shared library directly }
  ESysEILSEQ = 84;   { Illegal byte sequence }
  ESysERESTART = 85;       { Interrupted system call should be restarted }
  ESysESTRPIPE = 86;       { Streams pipe error }
  ESysEUSERS = 87;   { Too many users }
  ESysENOTSOCK = 88;       { Socket operation on non-socket }
  ESysEDESTADDRREQ = 89;   { Destination address required }
  ESysEMSGSIZE = 90;       { Message too long }
  ESysEPROTOTYPE = 91;     { Protocol wrong type for socket }
  ESysENOPROTOOPT = 92;    { Protocol not available }
  ESysEPROTONOSUPPORT = 93;        { Protocol not supported }
  ESysESOCKTNOSUPPORT = 94;        { Socket type not supported }
  ESysEOPNOTSUPP = 95;     { Operation not supported on transport endpoint }
  ESysEPFNOSUPPORT = 96;   { Protocol family not supported }
  ESysEAFNOSUPPORT = 97;   { Address family not supported by protocol }
  ESysEADDRINUSE = 98;     { Address already in use }
  ESysEADDRNOTAVAIL = 99;  { Cannot assign requested address }
  ESysENETDOWN = 100;      { Network is down }
  ESysENETUNREACH = 101;   { Network is unreachable }
  ESysENETRESET = 102;     { Network dropped connection because of reset }
  ESysECONNABORTED = 103;  { Software caused connection abort }
  ESysECONNRESET = 104;    { Connection reset by peer }
  ESysENOBUFS = 105;  { No buffer space available }
  ESysEISCONN = 106;  { Transport endpoint is already connected }
  ESysENOTCONN = 107;      { Transport endpoint is not connected }
  ESysESHUTDOWN = 108;     { Cannot send after transport endpoint shutdown }
  ESysETOOMANYREFS = 109;  { Too many references: cannot splice }
  ESysETIMEDOUT = 110;     { Connection timed out }
  ESysECONNREFUSED = 111;  { Connection refused }
  ESysEHOSTDOWN = 112;     { Host is down }
  ESysEHOSTUNREACH = 113;  { No route to host }
  ESysEALREADY = 114;      { Operation already in progress }
  ESysEINPROGRESS = 115;   { Operation now in progress }
  ESysESTALE = 116;  { Stale NFS file handle }
  ESysEUCLEAN = 117;  { Structure needs cleaning }
  ESysENOTNAM = 118;  { Not a XENIX named type file }
  ESysENAVAIL = 119;  { No XENIX semaphores available }
  ESysEISNAM = 120;  { Is a named type file }
  ESysEREMOTEIO = 121;     { Remote I/O error }
  ESysEDQUOT = 122;  { Quota exceeded }

{ List of missing system error numbers
  added using check_errno.sh script }
  ESysENOMEDIUM = 123;
  ESysEMEDIUMTYPE = 124;
  ESysECANCELED = 125;
  ESysENOKEY = 126;
  ESysEKEYEXPIRED = 127;
  ESysEKEYREVOKED = 128;
  ESysEKEYREJECTED = 129;
  ESysEOWNERDEAD = 130;
  ESysENOTRECOVERABLE = 131;
  ESysERFKILL = 132;

var
  errno: integer; external Name '__errno';

function PosixToRunError(PosixErrno: longint): word;
var
  r: word;
begin
  case PosixErrNo of
    ESysENFILE,
    ESysEMFILE: r := 4;
    ESysENOENT: r := 2;
    ESysEBADF: r := 6;
    ESysENOMEM,
    ESysEFAULT: r := 217;
    ESysEINVAL: r := 218;
    ESysEPIPE,
    ESysEINTR,
    ESysEIO,
    ESysEAGAIN,
    ESysENOSPC: r := 101;
    ESysENAMETOOLONG: r := 3;
    ESysEROFS,
    ESysEEXIST,
    ESysENOTEMPTY,
    ESysEACCES: r := 5;
    ESysEBusy,
    ESysENOTDIR,        // busy, enotdir, mantis #25931
    ESysEISDIR: r := 5;
    else
      r := PosixErrno;
  end;
  inoutres := r;
  PosixToRunError := r;
end;

function Errno2InoutRes: word;
begin
  Errno2InoutRes := PosixToRunError(errno);
  InoutRes := Errno2InoutRes;
end;

procedure doClose(handle: longint);
begin
  if fclose(PFIL(handle)) <> 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

procedure doErase(p: pansichar);
begin
  if remove(p) <> 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

procedure doRename(p1, p2: pansichar);
begin
  if rename(p1, p2) <> 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

function doWrite(h: longint; addr: pointer; len: longint): longint;
begin
  doWrite := fwrite(addr, 1, len, PFIL(h));
  if doWrite <> len then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

function doRead(h: longint; addr: pointer; len: longint): longint;
begin
  doRead := fread(addr, 1, len, PFIL(h));
  if doRead <> len then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

function doFilePos(handle: longint): longint;
begin
  doFilePos := ftello(PFIL(handle));
  if doFilePos < 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

procedure doSeek(handle, pos: longint);
begin
  if fseeko(PFIL(handle), pos, SEEK_SET) <> 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

function doSeekEnd(handle: longint): longint;
begin
  doSeekEnd := fseeko(PFIL(handle), 0, SEEK_END);
  if doSeekEnd < 0 then
    Errno2InOutRes
  else
    InOutRes := 0;
end;

function doFileSize(handle: longint): longint;
var
  curpos: int64;
begin
  curpos := doFilepos(handle);
  doSeekend(handle);
  doFileSize := ftello(PFIL(handle));
  if doFileSize < 0 then
  begin
    doFileSize := 0;
    Errno2InOutRes;
  end
  else
    InOutRes := 0;
  doSeek(handle, curpos);
end;

// ftruncate/truncate not provided by esp-idf
//procedure doTruncate(handle, pos: longint);
//begin
//  if ftruncate(fileno(PFIL(handle)), pos) <> 0 then
//   Errno2Inoutres
//  else
//   InOutRes := 0;
//end;

procedure doOpen(var f; p: pansichar; flags: longint);
{
  FileRec and textrec have both Handle and mode as the first items so
  they could use the same routine for opening/creating.
  when (flags and $100)   the file will be append
  when (flags and $1000)  the file will be truncate/rewritten
  when (flags and $10000) there is no check for close (needed for textfiles)
}
var
  mode: shortstring;
begin
  { close first if opened }
  if ((flags and $10000) = 0) then
  begin
    case FileRec(f).mode of
      fminput, fmoutput, fminout: doClose(FileRec(f).Handle);
      fmclosed: ;
      else
      begin
        inoutres := 102; {not assigned}
        exit;
      end;
    end;
  end;
  { reset file Handle }
  FileRec(f).Handle := UnusedHandle;
  { Convert from FPC flags to internal modes and libc mode }
  case (flags and 3) of
    0: begin
      mode := 'r';
      FileRec(f).mode := fminput;
    end;
    1: begin
      if flags and $100 = $100 then // Append
        mode := 'a'
      else
        mode := 'w';
      FileRec(f).mode := fmoutput;
    end;
    2: begin
      if flags and $100 = $100 then // Append
        mode := 'a+'
      else if flags and $1000 = $1000 then // Truncate
        mode := 'w+'
      else
        mode := 'r+';
      FileRec(f).mode := fminout;
    end;
  end;

  { empty name is special }
  if p[0] = #0 then
  begin
    case FileRec(f).mode of
      fminput:
        FileRec(f).Handle := StdInputHandle;
      fminout, { this is set by rewrite }
      fmoutput:
        FileRec(f).Handle := StdOutputHandle;
      fmappend:
      begin
        FileRec(f).Handle := StdOutputHandle;
        FileRec(f).mode := fmoutput; {fool fmappend}
      end;
    end;
    exit;
  end;

  FileRec(f).Handle := longint(fopen(p, @mode[1]));

  if Filerec(f).Handle < 0 then
  begin
    Errno2Inoutres;
    FileRec(f).mode := fmclosed;
  end
  else
    InOutRes := 0;
end;

//function doIsDevice(handle: longint): boolean;
//begin

//end;

initialization
  rtl_do_close := @doClose;
  rtl_do_erase := @doErase;
  rtl_do_rename := @doRename;
  rtl_do_write := @doWrite;
  rtl_do_read := @doRead;
  rtl_do_filepos := @doFilePos;
  rtl_do_seek := @doSeek;
  rtl_do_seekend := @doSeekEnd;
  rtl_do_filesize := @doFileSize;
  //rtl_do_truncate := @doTruncate;
  rtl_do_open := @doOpen;
  //rtl_do_isdevice := @doIsDevice;

end.
