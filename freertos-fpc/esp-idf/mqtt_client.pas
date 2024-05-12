unit mqtt_client;

interface

{$linklib mqtt, static}
{$linklib tcp_transport, static}
{$linklib esp-tls, static}

uses
  esp_err, esp_event, portmacro;

type
  Pesp_event_loop_handle = ^Tesp_event_loop_handle;
  Tesp_event_loop_handle = pointer;

  Pesp_event_handler = ^Tesp_event_handler;
  Tesp_event_handler = pointer;

type
  esp_mqtt_client = record end;
  Pesp_mqtt_client_handle = ^Tesp_mqtt_client_handle;
  Tesp_mqtt_client_handle = ^esp_mqtt_client;

  Pesp_mqtt_event_id = ^Tesp_mqtt_event_id;
  Tesp_mqtt_event_id = (MQTT_EVENT_ANY := -(1), MQTT_EVENT_ERROR := 0,
    MQTT_EVENT_CONNECTED, MQTT_EVENT_DISCONNECTED,
    MQTT_EVENT_SUBSCRIBED, MQTT_EVENT_UNSUBSCRIBED,
    MQTT_EVENT_PUBLISHED, MQTT_EVENT_DATA,
    MQTT_EVENT_BEFORE_CONNECT, MQTT_EVENT_DELETED
    );

  Pesp_mqtt_connect_return_code = ^Tesp_mqtt_connect_return_code;
  Tesp_mqtt_connect_return_code = (MQTT_CONNECTION_ACCEPTED :=
    0, MQTT_CONNECTION_REFUSE_PROTOCOL,
    MQTT_CONNECTION_REFUSE_ID_REJECTED, MQTT_CONNECTION_REFUSE_SERVER_UNAVAILABLE,
    MQTT_CONNECTION_REFUSE_BAD_USERNAME,
    MQTT_CONNECTION_REFUSE_NOT_AUTHORIZED
    );

  Pesp_mqtt_error_type = ^Tesp_mqtt_error_type;
  Tesp_mqtt_error_type = (MQTT_ERROR_TYPE_NONE := 0, MQTT_ERROR_TYPE_TCP_TRANSPORT,
    MQTT_ERROR_TYPE_CONNECTION_REFUSED);

const
  MQTT_ERROR_TYPE_ESP_TLS = MQTT_ERROR_TYPE_TCP_TRANSPORT;

type
  Pesp_mqtt_transport = ^Tesp_mqtt_transport;
  Tesp_mqtt_transport = (MQTT_TRANSPORT_UNKNOWN := $0, MQTT_TRANSPORT_OVER_TCP,
    MQTT_TRANSPORT_OVER_SSL, MQTT_TRANSPORT_OVER_WS,
    MQTT_TRANSPORT_OVER_WSS);

  Pesp_mqtt_protocol_ver = ^Tesp_mqtt_protocol_ver;
  Tesp_mqtt_protocol_ver = (MQTT_PROTOCOL_UNDEFINED := 0, MQTT_PROTOCOL_V_3_1,
    MQTT_PROTOCOL_V_3_1_1);

  Tesp_mqtt_error_codes = record
    esp_tls_last_esp_err: Tesp_err;
    esp_tls_stack_err: longint;
    esp_tls_cert_verify_flags: longint;
    error_type: Tesp_mqtt_error_type;
    connect_return_code: Tesp_mqtt_connect_return_code;
    esp_transport_sock_errno: longint;
  end;
  Pesp_mqtt_error_codes = ^Tesp_mqtt_error_codes;

  Tesp_mqtt_event = record
    event_id: Tesp_mqtt_event_id;
    client: Tesp_mqtt_client_handle;
    user_context: pointer;
    Data: PChar;
    data_len: longint;
    total_data_len: longint;
    current_data_offset: longint;
    topic: PChar;
    topic_len: longint;
    msg_id: longint;
    session_present: longint;
    error_handle: Pesp_mqtt_error_codes;
    retain: Tbool;
  end;
  Pesp_mqtt_event = ^Tesp_mqtt_event;
  Pesp_mqtt_event_handle = ^Tesp_mqtt_event_handle;
  Tesp_mqtt_event_handle = Pesp_mqtt_event;

  Tmqtt_event_callback = function(event: Tesp_mqtt_event_handle): Tesp_err; cdecl;

  Pesp_mqtt_client_config_t = ^Tesp_mqtt_client_config;
  Tesp_mqtt_client_config = record
    event_handle: Tmqtt_event_callback;
    event_loop_handle: Tesp_event_loop_handle;
    host: PChar;
    uri: PChar;
    port: uint32;
    client_id: PChar;
    username: PChar;
    password: PChar;
    lwt_topic: PChar;
    lwt_msg: PChar;
    lwt_qos: longint;
    lwt_retain: longint;
    lwt_msg_len: longint;
    disable_clean_session: longint;
    keepalive: longint;
    disable_auto_reconnect: Tbool;
    user_context: pointer;
    task_prio: longint;
    task_stack: longint;
    buffer_size: longint;
    cert_pem: PChar;
    cert_len: Tsize;
    client_cert_pem: PChar;
    client_cert_len: Tsize;
    client_key_pem: PChar;
    client_key_len: Tsize;
    transport: Tesp_mqtt_transport;
    refresh_connection_after_ms: longint;
    psk_hint_key: pointer; //Ppsk_key_hint;
    use_global_ca_store: Tbool;
    crt_bundle_attach:
    function(conf: pointer): Tesp_err; cdecl;
    reconnect_timeout_ms: longint;
    alpn_protos: ^PChar;
    clientkey_password: PChar;
    clientkey_password_len: longint;
    protocol_ver: Tesp_mqtt_protocol_ver;
    out_buffer_size: longint;
    skip_cert_common_name_check: Tbool;
    use_secure_element: Tbool;
    ds_data: pointer;
    network_timeout_ms: longint;
    disable_keepalive: Tbool;
    path: PChar;
    message_retransmit_timeout: longint;
  end;

function esp_mqtt_client_init(
  var config: Tesp_mqtt_client_config): Tesp_mqtt_client_handle; external;

function esp_mqtt_client_set_uri(client: Tesp_mqtt_client_handle;
  uri: PChar): Tesp_err; external;

function esp_mqtt_client_start(client: Tesp_mqtt_client_handle): Tesp_err;
  external;

function esp_mqtt_client_reconnect(client: Tesp_mqtt_client_handle): Tesp_err;
  external;

function esp_mqtt_client_disconnect(client: Tesp_mqtt_client_handle): Tesp_err;
  external;

function esp_mqtt_client_stop(client: Tesp_mqtt_client_handle): Tesp_err;
  external;

function esp_mqtt_client_subscribe(client: Tesp_mqtt_client_handle;
  topic: PChar; qos: longint): longint;
  external;

function esp_mqtt_client_unsubscribe(client: Tesp_mqtt_client_handle;
  topic: PChar): longint; external;

function esp_mqtt_client_publish(client: Tesp_mqtt_client_handle;
  topic: PChar; Data: PChar; len: longint; qos: longint; retain: longint): longint;
  external;

function esp_mqtt_client_enqueue(client: Tesp_mqtt_client_handle;
  topic: PChar; Data: PChar; len: longint; qos: longint; retain: longint;
  store: Tbool): longint; external;

function esp_mqtt_client_destroy(client: Tesp_mqtt_client_handle): Tesp_err;
  external;

function esp_mqtt_set_config(client: Tesp_mqtt_client_handle;
  var config: Tesp_mqtt_client_config): Tesp_err; external;

function esp_mqtt_client_register_event(client: Tesp_mqtt_client_handle;
  event: Tesp_mqtt_event_id; event_handler: Tesp_event_handler;
  event_handler_arg: pointer): Tesp_err; external;

function esp_mqtt_client_get_outbox_size(client: Tesp_mqtt_client_handle): longint;
  external;

implementation

end.
