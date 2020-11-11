unit esp_http_server;

{$include freertosconfig.inc}
{$linklib esp_http_server, static}

interface

uses
  http_parser, esp_err, task;

const
  ESP_ERR_HTTPD_BASE = $8000;
  ESP_ERR_HTTPD_HANDLERS_FULL = ESP_ERR_HTTPD_BASE + 1;
  ESP_ERR_HTTPD_HANDLER_EXISTS = ESP_ERR_HTTPD_BASE + 2;
  ESP_ERR_HTTPD_INVALID_REQ = ESP_ERR_HTTPD_BASE + 3;
  ESP_ERR_HTTPD_RESULT_TRUNC = ESP_ERR_HTTPD_BASE + 4;
  ESP_ERR_HTTPD_RESP_HDR = ESP_ERR_HTTPD_BASE + 5;
  ESP_ERR_HTTPD_RESP_SEND = ESP_ERR_HTTPD_BASE + 6;
  ESP_ERR_HTTPD_ALLOC_MEM = ESP_ERR_HTTPD_BASE + 7;
  ESP_ERR_HTTPD_TASK = ESP_ERR_HTTPD_BASE + 8;
  HTTPD_SOCK_ERR_FAIL = -(1);
  HTTPD_SOCK_ERR_INVALID = -(2);
  HTTPD_SOCK_ERR_TIMEOUT = -(3);
  HTTPD_MAX_REQ_HDR_LEN = CONFIG_HTTPD_MAX_REQ_HDR_LEN;
  HTTPD_MAX_URI_LEN = CONFIG_HTTPD_MAX_URI_LEN;
  HTTPD_200 = '200 OK';
  HTTPD_204 = '204 No Content';
  HTTPD_207 = '207 Multi-Status';
  HTTPD_400 = '400 Bad Request';
  HTTPD_404 = '404 Not Found';
  HTTPD_408 = '408 Request Timeout';
  HTTPD_500 = '500 Internal Server Error';
  HTTPD_TYPE_JSON = 'application/json';
  HTTPD_TYPE_TEXT = 'text/html';
  HTTPD_TYPE_OCTET = 'application/octet-stream';

type
  Phttpd_handle = ^Thttpd_handle;
  Thttpd_handle = pointer;

  Phttpd_method = ^Thttpd_method;
  Thttpd_method = Thttp_method;

  Thttpd_free_ctx_fn = procedure(ctx: pointer);

  Thttpd_open_func = function(hd: Thttpd_handle;
    sockfd: longint): Tesp_err;

  Thttpd_close_func = procedure(hd: Thttpd_handle; sockfd: longint);

  Phttpd_config = ^Thttpd_config;
  Thttpd_config = record
    task_priority: dword;
    stack_size: Tsize;
    server_port: uint16;
    ctrl_port: uint16;
    max_open_sockets: uint16;
    max_uri_handlers: uint16;
    max_resp_headers: uint16;
    backlog_conn: uint16;
    lru_purge_enable: longbool;
    recv_wait_timeout: uint16;
    send_wait_timeout: uint16;
    global_user_ctx: pointer;
    global_user_ctx_free_fn: Thttpd_free_ctx_fn;
    global_transport_ctx: pointer;
    global_transport_ctx_free_fn: Thttpd_free_ctx_fn;
    open_fn: Thttpd_open_func;
    close_fn: Thttpd_close_func;
  end;

  Phttpd_req = ^Thttpd_req;
  Thttpd_req = record
    handle: Thttpd_handle;
    method: longint;
    uri: array[0..(HTTPD_MAX_URI_LEN + 1) - 1] of char;
    content_len: Tsize;
    aux: pointer;
    user_ctx: pointer;
    sess_ctx: pointer;
    free_ctx: Thttpd_free_ctx_fn;
  end;

  Phttpd_uri = ^Thttpd_uri;
  Thttpd_uri = record
    uri: PChar;
    method: Thttpd_method;
    handler: function(r: Phttpd_req): Tesp_err;
    user_ctx: pointer;
  end;

  Thttpd_send_func = function(hd: Thttpd_handle; sockfd: longint;
    buf: PChar; buf_len: Tsize; flags: longint): longint;

  Thttpd_recv_func = function(hd: Thttpd_handle; sockfd: longint;
    buf: PChar; buf_len: Tsize; flags: longint): longint;

  Thttpd_pending_func = function(hd: Thttpd_handle;
    sockfd: longint): longint;

  Thttpd_work_fn_t = procedure(arg: pointer);

function httpd_start(handle: Phttpd_handle; config: Phttpd_config): Tesp_err;
  external;
function httpd_stop(handle: Thttpd_handle): Tesp_err; external;
function httpd_register_uri_handler(handle: Thttpd_handle;
  uri_handler: Phttpd_uri): Tesp_err; external;
function httpd_unregister_uri_handler(handle: Thttpd_handle; uri: PChar;
  method: Thttpd_method): Tesp_err; external;
function httpd_unregister_uri(handle: Thttpd_handle; uri: PChar): Tesp_err;
  external;
function httpd_sess_set_recv_override(hd: Thttpd_handle; sockfd: longint;
  recv_func: Thttpd_recv_func): Tesp_err; external;
function httpd_sess_set_send_override(hd: Thttpd_handle; sockfd: longint;
  send_func: Thttpd_send_func): Tesp_err; external;
function httpd_sess_set_pending_override(hd: Thttpd_handle; sockfd: longint;
  pending_func: Thttpd_pending_func): Tesp_err; external;
function httpd_req_to_sockfd(r: Phttpd_req): longint; external;
function httpd_req_recv(r: Phttpd_req; buf: PChar; buf_len: Tsize): longint;
  external;
function httpd_req_get_hdr_value_len(r: Phttpd_req; field: PChar): Tsize; external;
function httpd_req_get_hdr_value_str(r: Phttpd_req; field: PChar;
  val: PChar; val_size: Tsize): Tesp_err; external;
function httpd_req_get_url_query_len(r: Phttpd_req): Tsize; external;
function httpd_req_get_url_query_str(r: Phttpd_req; buf: PChar;
  buf_len: Tsize): Tesp_err; external;
function httpd_query_key_value(qry: PChar; key: PChar; val: PChar;
  val_size: Tsize): Tesp_err; external;
function httpd_resp_send(r: Phttpd_req; buf: PChar; buf_len: Tsize): Tesp_err;
  external;
function httpd_resp_send_chunk(r: Phttpd_req; buf: PChar;
  buf_len: Tsize): Tesp_err; external;
function httpd_resp_set_status(r: Phttpd_req; status: PChar): Tesp_err; external;
function httpd_resp_set_type(r: Phttpd_req; _type: PChar): Tesp_err; external;
function httpd_resp_set_hdr(r: Phttpd_req; field: PChar;
  Value: PChar): Tesp_err; external;
function httpd_resp_send_404(r: Phttpd_req): Tesp_err; external;
function httpd_resp_send_408(r: Phttpd_req): Tesp_err; external;
function httpd_resp_send_500(r: Phttpd_req): Tesp_err; external;
function httpd_send(r: Phttpd_req; buf: PChar; buf_len: Tsize): longint; external;
function httpd_sess_get_ctx(handle: Thttpd_handle; sockfd: longint): pointer;
  external;
procedure httpd_sess_set_ctx(handle: Thttpd_handle; sockfd: longint;
  ctx: pointer; free_fn: Thttpd_free_ctx_fn); external;
function httpd_sess_get_transport_ctx(handle: Thttpd_handle;
  sockfd: longint): pointer; external;
procedure httpd_sess_set_transport_ctx(handle: Thttpd_handle;
  sockfd: longint; ctx: pointer; free_fn: Thttpd_free_ctx_fn); external;
function httpd_get_global_user_ctx(handle: Thttpd_handle): pointer; external;
function httpd_get_global_transport_ctx(handle: Thttpd_handle): pointer; external;
function httpd_sess_trigger_close(handle: Thttpd_handle;
  sockfd: longint): Tesp_err; external;
function httpd_sess_update_lru_counter(handle: Thttpd_handle;
  sockfd: longint): Tesp_err; external;
function httpd_queue_work(handle: Thttpd_handle; work: Thttpd_work_fn_t;
  arg: pointer): Tesp_err; external;

function HTTPD_DEFAULT_CONFIG: Thttpd_config;

implementation

function HTTPD_DEFAULT_CONFIG: Thttpd_config;
begin
  with Result do
  begin
    task_priority      := tskIDLE_PRIORITY+5;
    stack_size         := 4096;
    server_port        := 80;
    ctrl_port          := 32768;
    max_open_sockets   := 7;
    max_uri_handlers   := 8;
    max_resp_headers   := 8;
    backlog_conn       := 5;
    lru_purge_enable   := false;
    recv_wait_timeout  := 5;
    send_wait_timeout  := 5;
    global_user_ctx := nil;
    global_user_ctx_free_fn := nil;
    global_transport_ctx := nil;
    global_transport_ctx_free_fn := nil;
    open_fn := nil;
    close_fn := nil;
  end;
end;

end.
