unit esp_http_server;

{$include sdkconfig.inc}
{$linklib esp_http_server, static}

interface

{ $include <freertos/FreeRTOS.h>}
{  $include <http_parser.h>}

uses
  esp_err, task, portable, http_parser;

const
  ESP_ERR_HTTPD_BASE = $b000;
  ESP_ERR_HTTPD_HANDLERS_FULL = ESP_ERR_HTTPD_BASE + 1;
  ESP_ERR_HTTPD_HANDLER_EXISTS = ESP_ERR_HTTPD_BASE + 2;
  ESP_ERR_HTTPD_INVALID_REQ = ESP_ERR_HTTPD_BASE + 3;
  ESP_ERR_HTTPD_RESULT_TRUNC = ESP_ERR_HTTPD_BASE + 4;
  ESP_ERR_HTTPD_RESP_HDR = ESP_ERR_HTTPD_BASE + 5;
  ESP_ERR_HTTPD_RESP_SEND = ESP_ERR_HTTPD_BASE + 6;
  ESP_ERR_HTTPD_ALLOC_MEM = ESP_ERR_HTTPD_BASE + 7;
  ESP_ERR_HTTPD_TASK = ESP_ERR_HTTPD_BASE + 8;
  HTTPD_RESP_USE_STRLEN = -(1);
  HTTPD_MAX_REQ_HDR_LEN = CONFIG_HTTPD_MAX_REQ_HDR_LEN;
  HTTPD_MAX_URI_LEN = CONFIG_HTTPD_MAX_URI_LEN;
  HTTPD_SOCK_ERR_FAIL = -(1);
  HTTPD_SOCK_ERR_INVALID = -(2);
  HTTPD_SOCK_ERR_TIMEOUT = -(3);
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
  Phttpd_handle_t = ^Thttpd_handle_t;
  Thttpd_handle_t = pointer;

  Phttpd_method_t = ^Thttpd_method_t;
  {$info 'enum http_method declared in nghttp/http_parser.h'  Break dependency by reverting to uint32'}
  Thttpd_method_t = Thttp_method;

  Thttpd_free_ctx_fn_t = procedure(ctx: pointer); cdecl;

  Thttpd_open_func_t = function(hd: Thttpd_handle_t;
    sockfd: longint): Tesp_err_t; cdecl;

  Thttpd_close_func_t = procedure(hd: Thttpd_handle_t; sockfd: longint); cdecl;

  Thttpd_uri_match_func_t = function(reference_uri: PChar;
    uri_to_match: PChar; match_upto: Tsize_t): longbool; cdecl;

  Phttpd_config = ^Thttpd_config;
  Thttpd_config = record
    task_priority: dword;
    stack_size: Tsize_t;
    core_id: TBaseType_t;
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
    global_user_ctx_free_fn: Thttpd_free_ctx_fn_t;
    global_transport_ctx: pointer;
    global_transport_ctx_free_fn: Thttpd_free_ctx_fn_t;
    open_fn: Thttpd_open_func_t;
    close_fn: Thttpd_close_func_t;
    uri_match_fn: Thttpd_uri_match_func_t;
  end;
  Thttpd_config_t = Thttpd_config;
  Phttpd_config_t = ^Thttpd_config_t;

function HTTPD_DEFAULT_CONFIG: Thttpd_config_t;

function httpd_start(handle: Phttpd_handle_t; config: Phttpd_config_t): Tesp_err_t;
  cdecl; external;

function httpd_stop(handle: Thttpd_handle_t): Tesp_err_t; cdecl; external;

type
  Phttpd_req = ^Thttpd_req;
  Thttpd_req = record
    handle: Thttpd_handle_t;
    method: longint;
    uri: array[0..(HTTPD_MAX_URI_LEN + 1) - 1] of char;
    content_len: Tsize_t;
    aux: pointer;
    user_ctx: pointer;
    sess_ctx: pointer;
    free_ctx: Thttpd_free_ctx_fn_t;
    ignore_sess_ctx_changes: longbool;
  end;
  Thttpd_req_t = Thttpd_req;
  Phttpd_req_t = ^Thttpd_req_t;

  Phttpd_uri = ^Thttpd_uri;
  Thttpd_uri = record
    uri: PChar;
    method: Thttpd_method_t;
    handler: function(r: Phttpd_req_t): Tesp_err_t; cdecl;
    user_ctx: pointer;
  end;
  Thttpd_uri_t = Thttpd_uri;
  Phttpd_uri_t = ^Thttpd_uri_t;

function httpd_register_uri_handler(handle: Thttpd_handle_t;
  uri_handler: Phttpd_uri_t): Tesp_err_t; cdecl; external;

function httpd_unregister_uri_handler(handle: Thttpd_handle_t; uri: PChar;
  method: Thttpd_method_t): Tesp_err_t; cdecl; external;

function httpd_unregister_uri(handle: Thttpd_handle_t; uri: PChar): Tesp_err_t;
  cdecl; external;

type
  Phttpd_err_code_t = ^Thttpd_err_code_t;
  Thttpd_err_code_t = (HTTPD_500_INTERNAL_SERVER_ERROR = 0,
    HTTPD_501_METHOD_NOT_IMPLEMENTED, HTTPD_505_VERSION_NOT_SUPPORTED,
    HTTPD_400_BAD_REQUEST, HTTPD_404_NOT_FOUND,
    HTTPD_405_METHOD_NOT_ALLOWED, HTTPD_408_REQ_TIMEOUT,
    HTTPD_411_LENGTH_REQUIRED, HTTPD_414_URI_TOO_LONG,
    HTTPD_431_REQ_HDR_FIELDS_TOO_LARGE,
    HTTPD_ERR_CODE_MAX);

  Thttpd_err_handler_func_t = function(req: Phttpd_req_t;
    error: Thttpd_err_code_t): Tesp_err_t; cdecl;

function httpd_register_err_handler(handle: Thttpd_handle_t;
  error: Thttpd_err_code_t; handler_fn: Thttpd_err_handler_func_t): Tesp_err_t;
  cdecl; external;

type
  Thttpd_send_func_t = function(hd: Thttpd_handle_t; sockfd: longint;
    buf: PChar; buf_len: Tsize_t; flags: longint): longint; cdecl;

  Thttpd_recv_func_t = function(hd: Thttpd_handle_t; sockfd: longint;
    buf: PChar; buf_len: Tsize_t; flags: longint): longint; cdecl;

  Thttpd_pending_func_t = function(hd: Thttpd_handle_t;
    sockfd: longint): longint; cdecl;

function httpd_sess_set_recv_override(hd: Thttpd_handle_t; sockfd: longint;
  recv_func: Thttpd_recv_func_t): Tesp_err_t; cdecl; external;

function httpd_sess_set_send_override(hd: Thttpd_handle_t; sockfd: longint;
  send_func: Thttpd_send_func_t): Tesp_err_t; cdecl; external;

function httpd_sess_set_pending_override(hd: Thttpd_handle_t; sockfd: longint;
  pending_func: Thttpd_pending_func_t): Tesp_err_t; cdecl; external;

function httpd_req_to_sockfd(r: Phttpd_req_t): longint; cdecl; external;

function httpd_req_recv(r: Phttpd_req_t; buf: PChar; buf_len: Tsize_t): longint;
  cdecl; external;

function httpd_req_get_hdr_value_len(r: Phttpd_req_t; field: PChar): Tsize_t; cdecl; external;

function httpd_req_get_hdr_value_str(r: Phttpd_req_t; field: PChar;
  val: PChar; val_size: Tsize_t): Tesp_err_t; cdecl; external;

function httpd_req_get_url_query_len(r: Phttpd_req_t): Tsize_t; cdecl; external;

function httpd_req_get_url_query_str(r: Phttpd_req_t; buf: PChar;
  buf_len: Tsize_t): Tesp_err_t; cdecl; external;

function httpd_query_key_value(qry: PChar; key: PChar; val: PChar;
  val_size: Tsize_t): Tesp_err_t; cdecl; external;

function httpd_uri_match_wildcard(uri_template: PChar; uri_to_match: PChar;
  match_upto: Tsize_t): longbool; cdecl; external;

function httpd_resp_send(r: Phttpd_req_t; buf: PChar; buf_len: int32): Tesp_err_t;
  cdecl; external;

function httpd_resp_send_chunk(r: Phttpd_req_t; buf: PChar;
  buf_len: int32): Tesp_err_t; cdecl; external;

function httpd_resp_set_status(r: Phttpd_req_t; status: PChar): Tesp_err_t; cdecl; external;

function httpd_resp_set_type(r: Phttpd_req_t; _type: PChar): Tesp_err_t; cdecl; external;

function httpd_resp_set_hdr(r: Phttpd_req_t; field: PChar;
  Value: PChar): Tesp_err_t; cdecl; external;

function httpd_resp_send_err(req: Phttpd_req_t; error: Thttpd_err_code_t;
  msg: PChar): Tesp_err_t; cdecl; external;

function httpd_send(r: Phttpd_req_t; buf: PChar; buf_len: Tsize_t): longint; cdecl; external;

function httpd_sess_get_ctx(handle: Thttpd_handle_t; sockfd: longint): pointer;
  cdecl; external;

procedure httpd_sess_set_ctx(handle: Thttpd_handle_t; sockfd: longint;
  ctx: pointer; free_fn: Thttpd_free_ctx_fn_t); cdecl; external;

function httpd_sess_get_transport_ctx(handle: Thttpd_handle_t;
  sockfd: longint): pointer; cdecl; external;

procedure httpd_sess_set_transport_ctx(handle: Thttpd_handle_t;
  sockfd: longint; ctx: pointer; free_fn: Thttpd_free_ctx_fn_t); cdecl; external;

function httpd_get_global_user_ctx(handle: Thttpd_handle_t): pointer; cdecl; external;

function httpd_get_global_transport_ctx(handle: Thttpd_handle_t): pointer; cdecl; external;

function httpd_sess_trigger_close(handle: Thttpd_handle_t;
  sockfd: longint): Tesp_err_t; cdecl; external;

function httpd_sess_update_lru_counter(handle: Thttpd_handle_t;
  sockfd: longint): Tesp_err_t; cdecl; external;

type
  Thttpd_work_fn_t = procedure(arg: pointer); cdecl;

function httpd_queue_work(handle: Thttpd_handle_t; work: Thttpd_work_fn_t;
  arg: pointer): Tesp_err_t; cdecl; external;

implementation

function HTTPD_DEFAULT_CONFIG: Thttpd_config_t;
begin
  with HTTPD_DEFAULT_CONFIG do
  begin
    task_priority                := tskIDLE_PRIORITY + 5;
    stack_size                   := 4096;
    core_id                      := tskNO_AFFINITY;
    server_port                  := 80;
    ctrl_port                    := 32768;
    max_open_sockets             := 7;
    max_uri_handlers             := 8;
    max_resp_headers             := 8;
    backlog_conn                 := 5;
    lru_purge_enable             := false;
    recv_wait_timeout            := 5;
    send_wait_timeout            := 5;
    global_user_ctx              := nil;
    global_user_ctx_free_fn      := nil;
    global_transport_ctx         := nil;
    global_transport_ctx_free_fn := nil;
    open_fn                      := nil;
    close_fn                     := nil;
    uri_match_fn                 := nil;
  end;
end;

end.
