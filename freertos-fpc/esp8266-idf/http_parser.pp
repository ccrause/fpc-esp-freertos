unit http_parser;

{$linklib http_parser, static}
{$modeswitch advancedrecords}

interface

const
  HTTP_PARSER_VERSION_MAJOR = 2;
  HTTP_PARSER_VERSION_MINOR = 7;
  HTTP_PARSER_VERSION_PATCH = 1;
{$ifndef HTTP_PARSER_STRICT}
  HTTP_PARSER_STRICT = 1;
{$endif}
{$ifndef HTTP_MAX_HEADER_SIZE}
  HTTP_MAX_HEADER_SIZE = 80 * 1024;
{$endif}

type
  Thttp_method = (
    HTTP_DELETE       = 0 ,
    HTTP_GET          = 1 ,
    HTTP_HEAD         = 2 ,
    HTTP_POST         = 3 ,
    HTTP_PUT          = 4 ,
    HTTP_CONNECT      = 5 ,
    HTTP_OPTIONS      = 6 ,
    HTTP_TRACE        = 7 ,
    HTTP_COPY         = 8 ,
    HTTP_LOCK         = 9 ,
    HTTP_MKCOL        = 10,
    HTTP_MOVE         = 11,
    HTTP_PROPFIND     = 12,
    HTTP_PROPPATCH    = 13,
    HTTP_SEARCH       = 14,
    HTTP_UNLOCK       = 15,
    HTTP_BIND         = 16,
    HTTP_REBIND       = 17,
    HTTP_UNBIND       = 18,
    HTTP_ACL          = 19,
    HTTP_REPORT       = 20,
    HTTP_MKACTIVITY   = 21,
    HTTP_CHECKOUT     = 22,
    HTTP_MERGE        = 23,
    HTTP_MSEARCH      = 24,
    HTTP_NOTIFY       = 25,
    HTTP_SUBSCRIBE    = 26,
    HTTP_UNSUBSCRIBE  = 27,
    HTTP_PATCH        = 28,
    HTTP_PURGE        = 29,
    HTTP_MKCALENDAR   = 30,
    HTTP_LINK         = 31,
    HTTP_UNLINK       = 32 );

  Thttp_parser_type = (HTTP_REQUEST, HTTP_RESPONSE, HTTP_BOTH);

  Tflags = (
    F_CHUNKED = 1 shl 0,
    F_CONNECTION_KEEP_ALIVE = 1 shl 1,
    F_CONNECTION_CLOSE = 1 shl 2,
    F_CONNECTION_UPGRADE = 1 shl 3,
    F_TRAILING = 1 shl 4,
    F_UPGRADE = 1 shl 5,
    F_SKIPBODY = 1 shl 6,
    F_CONTENTLENGTH = 1 shl 7);

  Thttp_errno = (
    HPE_OK,
    HPE_CB_message_begin,
    HPE_CB_url,
    HPE_CB_header_field,
    HPE_CB_header_value,
    HPE_CB_headers_complete,
    HPE_CB_body,
    HPE_CB_message_complete,
    HPE_CB_status,
    HPE_CB_chunk_header,
    HPE_CB_chunk_complete,
    HPE_INVALID_EOF_STATE,
    HPE_HEADER_OVERFLOW,
    HPE_CLOSED_CONNECTION,
    HPE_INVALID_VERSION,
    HPE_INVALID_STATUS,
    HPE_INVALID_METHOD,
    HPE_INVALID_URL,
    HPE_INVALID_HOST,
    HPE_INVALID_PORT,
    HPE_INVALID_PATH,
    HPE_INVALID_QUERY_STRING,
    HPE_INVALID_FRAGMENT,
    HPE_LF_EXPECTED,
    HPE_INVALID_HEADER_TOKEN,
    HPE_INVALID_CONTENT_LENGTH,
    HPE_UNEXPECTED_CONTENT_LENGTH,
    HPE_INVALID_CHUNK_SIZE,
    HPE_INVALID_CONSTANT,
    HPE_INVALID_INTERNAL_STATE,
    HPE_STRICT,
    HPE_PAUSED,
    HPE_UNKNOWN );

  Phttp_parser = ^Thttp_parser;
  Thttp_data_cb = function(para1: Phttp_parser; at: PChar;
    length: uint32): longint;

  Thttp_cb = function(para1: Phttp_parser): longint;

  TBitRange1 = 0..1;
  TBitRange2 = 0..3;
  TBitRange3 = 0..7;
  TBitRange4 = 0..15;
  TBitRange5 = 0..31;
  TBitRange6 = 0..63;
  TBitRange7 = 0..127;
  TBitRange8 = 0..255;
  TBitRange16 = 0..$FFFF;

  { Thttp_parser }

  Thttp_parser = record
  private
    function Getflags: TBitRange8;
    function Getheaderstate: TBitRange7;
    function GethttpErrNo: TBitRange7;
    function Getindex: TBitRange7;
    function Getlenient: TBitRange1;
    function Getmethod: TBitRange8;
    function Getstate: TBitRange7;
    function Getstatus: TBitRange16;
    function Gettype_: TBitRange2;
    function Getupgrade: TBitRange1;
    procedure Setflags(AValue: TBitRange8);
    procedure Setheaderstate(AValue: TBitRange7);
    procedure SethttpErrNo(AValue: TBitRange7);
    procedure Setindex(AValue: TBitRange7);
    procedure Setlenient(AValue: TBitRange1);
    procedure Setmethod(AValue: TBitRange8);
    procedure Setstate(AValue: TBitRange7);
    procedure SetStatus(AValue: TBitRange16);
    procedure Settype_(AValue: TBitRange2);
    procedure Setupgrade(AValue: TBitRange1);
  public
    _flags1_: uint32;
    nread: uint32;
    content_length: uint64;
    http_major: uint16;
    http_minor: uint16;
    _flags2_: uint32;
    data: pointer;
    property type_: TBitRange2 read Gettype_ write Settype_;
    property flags: TBitRange8 read Getflags write Setflags;
    property state: TBitRange7 read Getstate write Setstate;
    property header_state: TBitRange7 read Getheaderstate write Setheaderstate;
    property index: TBitRange7 read Getindex write Setindex;
    property lenient_http_headers: TBitRange1 read Getlenient write Setlenient;
    property status_code: TBitRange16 read Getstatus write SetStatus;
    property method: TBitRange8 read Getmethod write Setmethod;
    property http_errno: TBitRange7 read GethttpErrNo write SethttpErrNo;
    property upgrade: TBitRange1 read Getupgrade write Setupgrade;
  end;

  Phttp_parser_settings = ^Thttp_parser_settings;
  Thttp_parser_settings = record
    on_message_begin: Thttp_cb;
    on_url: Thttp_data_cb;
    on_status: Thttp_data_cb;
    on_header_field: Thttp_data_cb;
    on_header_value: Thttp_data_cb;
    on_headers_complete: Thttp_cb;
    on_body: Thttp_data_cb;
    on_message_complete: Thttp_cb;
    on_chunk_header: Thttp_cb;
    on_chunk_complete: Thttp_cb;
  end;

  Thttp_parser_url_fields = (UF_SCHEMA = 0, UF_HOST = 1, UF_PORT = 2,
    UF_PATH = 3, UF_QUERY = 4, UF_FRAGMENT = 5,
    UF_USERINFO = 6, UF_MAX = 7);

  Phttp_parser_url = ^Thttp_parser_url;
  Thttp_parser_url = record
    field_set: uint16;
    port: uint16;
    field_data: array[0..(ord(UF_MAX)) - 1] of record
      off: uint16;
      len: uint16;
    end;
  end;

function http_parser_version: dword; external;
procedure http_parser_init(parser: Phttp_parser; _type: Thttp_parser_type); external;
procedure http_parser_settings_init(settings: Phttp_parser_settings); external;
function http_parser_execute(parser: Phttp_parser; settings: Phttp_parser_settings;
  Data: PChar; len: uint32): uint32; external;
function http_should_keep_alive(parser: Phttp_parser): longint; external;
function http_method_str(m: Thttp_method): PChar; external;
function http_errno_name(err: Thttp_errno): PChar; external;
function http_errno_description(err: Thttp_errno): PChar; external;
procedure http_parser_url_init(u: Phttp_parser_url); external;
function http_parser_parse_url(buf: PChar; buflen: uint32; is_connect: longint;
  u: Phttp_parser_url): longint; external;
procedure http_parser_pause(parser: Phttp_parser; paused: longint); external;
function http_body_is_final(parser: Phttp_parser): longint; external;

function HTTP_PARSER_ERRNO(p: Thttp_parser): Thttp_errno;

implementation

function HTTP_PARSER_ERRNO(p: Thttp_parser): Thttp_errno;
begin
  HTTP_PARSER_ERRNO := Thttp_errno(p.http_errno);
end;

{ Thttp_parser }

function Thttp_parser.Getflags: TBitRange8;
begin
  Getflags := (_flags1_ shr 2) and 255;
end;

function Thttp_parser.Getheaderstate: TBitRange7;
begin
  Getheaderstate := (_flags1_ shr 17) and 127;
end;

function Thttp_parser.GethttpErrNo: TBitRange7;
begin
  GethttpErrNo := (_flags2_ shr 24) and 127;
end;

function Thttp_parser.Getindex: TBitRange7;
begin
  Getindex := (_flags1_ shr 24) and 127;
end;

function Thttp_parser.Getlenient: TBitRange1;
begin
  Getlenient := (_flags1_ shr 31) and 1;
end;

function Thttp_parser.Getmethod: TBitRange8;
begin
  Getmethod := (_flags2_ shr 16) and 255;
end;

function Thttp_parser.Getstate: TBitRange7;
begin
  Getstate := (_flags1_ shr 10) and 127;
end;

function Thttp_parser.Getstatus: TBitRange16;
begin
  Getstatus := _flags2_ and $00FF;
end;

function Thttp_parser.Gettype_: TBitRange2;
begin
  Gettype_ := _flags1_ and 3;
end;

function Thttp_parser.Getupgrade: TBitRange1;
begin
  Getupgrade := (_flags2_ shr 31);
end;

procedure Thttp_parser.Setflags(AValue: TBitRange8);
begin
  _flags1_ := (_flags1_ and $FFFFFC03) or (AValue shl 2);
end;

procedure Thttp_parser.Setheaderstate(AValue: TBitRange7);
begin
  _flags1_ := (_flags1_ and $FF01FFFF) or (AValue shl 17);
end;

procedure Thttp_parser.SethttpErrNo(AValue: TBitRange7);
begin
  _flags2_ := (_flags2_ and $80FFFFFF) or (AValue shl 24);
end;

procedure Thttp_parser.Setindex(AValue: TBitRange7);
begin
  _flags1_ := (_flags1_ and $80FFFFFF) or (AValue shl 24);
end;

procedure Thttp_parser.Setlenient(AValue: TBitRange1);
begin
  _flags1_ := (_flags1_ and $7FFFFFFF) or (AValue shl 31);
end;

procedure Thttp_parser.Setmethod(AValue: TBitRange8);
begin
  _flags2_ := (_flags2_ and $FF00FFFF) or (AValue shl 16);
end;

procedure Thttp_parser.Setstate(AValue: TBitRange7);
begin
  _flags1_ := (_flags1_ and $FFFE03FF) or (AValue shl 10);
end;

procedure Thttp_parser.SetStatus(AValue: TBitRange16);
begin
  _flags2_ := (_flags2_ and $FFFF0000) or AValue;
end;

procedure Thttp_parser.Settype_(AValue: TBitRange2);
begin
  _flags1_ := (_flags1_ and $FFFFFFFC) or AValue;
end;

procedure Thttp_parser.Setupgrade(AValue: TBitRange1);
begin
  _flags2_ := (_flags2_ and $7FFFFFFF) or (AValue shl 31);
end;

end.
