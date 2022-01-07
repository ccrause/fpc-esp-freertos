unit esp_http_client;

{$include sdkconfig.inc}
{$linklib esp_http_client, static}
{$linklib tcp_transport, static}
{$linklib esp-tls, static}
{$linklib mbedtls, static}

interface

uses
  esp_err;

const
  DEFAULT_HTTP_BUF_SIZE = CONFIG_HTTP_BUF_SIZE;

type
  Tesp_http_client = record end;
  Pesp_http_client = ^Tesp_http_client;
  Pesp_http_client_handle = ^Tesp_http_client_handle;
  Tesp_http_client_handle = Pesp_http_client;

  Pesp_http_client_event_id = ^Tesp_http_client_event_id;
  Tesp_http_client_event_id = (HTTP_EVENT_ERROR = 0, HTTP_EVENT_ON_CONNECTED,
    HTTP_EVENT_HEADERS_SENT, HTTP_EVENT_HEADER_SENT = HTTP_EVENT_HEADERS_SENT,
    HTTP_EVENT_ON_HEADER, HTTP_EVENT_ON_DATA,
    HTTP_EVENT_ON_FINISH, HTTP_EVENT_DISCONNECTED
    );

  Pesp_http_client_event = ^Tesp_http_client_event;
  Tesp_http_client_event = record
    event_id: Tesp_http_client_event_id;
    client: Tesp_http_client_handle;
    Data: pointer;
    data_len: longint;
    user_data: pointer;
    header_key: PChar;
    header_value: PChar;
  end;
  Pesp_http_client_event_handle = ^Tesp_http_client_event_handle;
  Tesp_http_client_event_handle = Pesp_http_client_event;

  Pesp_http_client_transport = ^Tesp_http_client_transport;
  Tesp_http_client_transport = (HTTP_TRANSPORT_UNKNOWN = $0, HTTP_TRANSPORT_OVER_TCP,
    HTTP_TRANSPORT_OVER_SSL);

  Thttp_event_handle_cb = function(evt: Pesp_http_client_event): Tesp_err;

  Pesp_http_client_method = ^Tesp_http_client_method;
  Tesp_http_client_method = (HTTP_METHOD_GET = 0, HTTP_METHOD_POST,
    HTTP_METHOD_PUT, HTTP_METHOD_PATCH, HTTP_METHOD_DELETE,
    HTTP_METHOD_HEAD, HTTP_METHOD_NOTIFY, HTTP_METHOD_SUBSCRIBE,
    HTTP_METHOD_UNSUBSCRIBE, HTTP_METHOD_OPTIONS,
    HTTP_METHOD_MAX);

  Pesp_http_client_auth_type = ^Tesp_http_client_auth_type;
  Tesp_http_client_auth_type = (HTTP_AUTH_TYPE_NONE = 0, HTTP_AUTH_TYPE_BASIC,
    HTTP_AUTH_TYPE_DIGEST);

  Pesp_http_client_config = ^Tesp_http_client_config;
  Tesp_http_client_config = record
    url: PChar;
    host: PChar;
    port: longint;
    username: PChar;
    password: PChar;
    auth_type: Tesp_http_client_auth_type;
    path: PChar;
    query: PChar;
    cert_pem: PChar;
    //client_cert_pem: PChar;
    //client_key_pem: PChar;
    method: Tesp_http_client_method;
    timeout_ms: longint;
    disable_auto_redirect: longbool;
    max_redirection_count: longint;
    event_handler: Thttp_event_handle_cb;
    transport_type: Tesp_http_client_transport;
    buffer_size: longint;
    //buffer_size_tx: longint;
    user_data: pointer;
    is_async: longbool;
    //use_global_ca_store: longbool;
    //skip_cert_common_name_check: longbool;
  end;

  PHttpStatus_Code = ^THttpStatus_Code;
  THttpStatus_Code = (HttpStatus_MovedPermanently = 301, HttpStatus_Found = 302,
    HttpStatus_TemporaryRedirect = 307, HttpStatus_Unauthorized = 401
    );

const
  ESP_ERR_HTTP_BASE = $7000;
  ESP_ERR_HTTP_MAX_REDIRECT = ESP_ERR_HTTP_BASE + 1;
  ESP_ERR_HTTP_CONNECT = ESP_ERR_HTTP_BASE + 2;
  ESP_ERR_HTTP_WRITE_DATA = ESP_ERR_HTTP_BASE + 3;
  ESP_ERR_HTTP_FETCH_HEADER = ESP_ERR_HTTP_BASE + 4;
  ESP_ERR_HTTP_INVALID_TRANSPORT = ESP_ERR_HTTP_BASE + 5;
  ESP_ERR_HTTP_CONNECTING = ESP_ERR_HTTP_BASE + 6;
  ESP_ERR_HTTP_EAGAIN = ESP_ERR_HTTP_BASE + 7;

function esp_http_client_init(config: Pesp_http_client_config):
  Tesp_http_client_handle; external;

function esp_http_client_perform(client: Tesp_http_client_handle): Tesp_err; external;

function esp_http_client_set_url(client: Tesp_http_client_handle;
  url: PChar): Tesp_err; external;

function esp_http_client_set_post_field(client: Tesp_http_client_handle;
  Data: PChar; len: longint): Tesp_err; external;

function esp_http_client_get_post_field(client: Tesp_http_client_handle;
  Data: PPchar): longint; external;

function esp_http_client_set_header(client: Tesp_http_client_handle;
  key: PChar; Value: PChar): Tesp_err; external;

function esp_http_client_get_header(client: Tesp_http_client_handle;
  key: PChar; Value: PPchar): Tesp_err; external;

{function esp_http_client_get_username(client: Tesp_http_client_handle;
  Value: PPchar): Tesp_err; external;

function esp_http_client_set_username(client: Tesp_http_client_handle;
  username: PChar): Tesp_err; external;

function esp_http_client_get_password(client: Tesp_http_client_handle;
  Value: PPchar): Tesp_err; external;

function esp_http_client_set_password(client: Tesp_http_client_handle;
  password: PChar): Tesp_err; external;

function esp_http_client_set_authtype(client: Tesp_http_client_handle;
  auth_type: Tesp_http_client_auth_type): Tesp_err; external;
}
function esp_http_client_set_method(client: Tesp_http_client_handle;
  method: Tesp_http_client_method): Tesp_err; external;

function esp_http_client_delete_header(client: Tesp_http_client_handle;
  key: PChar): Tesp_err; external;

function esp_http_client_open(client: Tesp_http_client_handle;
  write_len: longint): Tesp_err; external;

function esp_http_client_write(client: Tesp_http_client_handle;
  buffer: PChar; len: longint): longint; external;

function esp_http_client_fetch_headers(client: Tesp_http_client_handle): longint;
  external;

function esp_http_client_is_chunked_response(client: Tesp_http_client_handle): longbool;
  external;

function esp_http_client_read(client: Tesp_http_client_handle;
  buffer: PChar; len: longint): longint; external;

function esp_http_client_get_status_code(client: Tesp_http_client_handle): longint;
  external;

function esp_http_client_get_content_length(client: Tesp_http_client_handle): longint;
  external;

function esp_http_client_close(client: Tesp_http_client_handle): Tesp_err;
  external;

function esp_http_client_cleanup(client: Tesp_http_client_handle): Tesp_err;
  external;

function esp_http_client_get_transport_type(client: Tesp_http_client_handle):
  Tesp_http_client_transport; external;

{function esp_http_client_set_redirection(client: Tesp_http_client_handle): Tesp_err;
  external;

procedure esp_http_client_add_auth(client: Tesp_http_client_handle); external;

function esp_http_client_is_complete_data_received(
  client: Tesp_http_client_handle): longbool;
  external;
}
implementation

end.
