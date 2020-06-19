unit esp_netif_ppp;

interface

uses
  esp_event_base;

const
  NETIF_PP_PHASE_OFFSET = $100;

type
  Pesp_netif_ppp_config = ^Tesp_netif_ppp_config;
  Tesp_netif_ppp_config = record
    ppp_phase_event_enabled: longbool;
    ppp_error_event_enabled: longbool;
  end;

  Pesp_netif_ppp_status_event = ^Tesp_netif_ppp_status_event;
  Tesp_netif_ppp_status_event = (NETIF_PPP_ERRORNONE = 0, NETIF_PPP_ERRORPARAM = 1,
    NETIF_PPP_ERROROPEN = 2, NETIF_PPP_ERRORDEVICE = 3,
    NETIF_PPP_ERRORALLOC = 4, NETIF_PPP_ERRORUSER = 5,
    NETIF_PPP_ERRORCONNECT = 6, NETIF_PPP_ERRORAUTHFAIL = 7,
    NETIF_PPP_ERRORPROTOCOL = 8, NETIF_PPP_ERRORPEERDEAD = 9,
    NETIF_PPP_ERRORIDLETIMEOUT = 10, NETIF_PPP_ERRORCONNECTTIME = 11,
    NETIF_PPP_ERRORLOOPBACK = 12, NETIF_PPP_PHASE_DEAD = NETIF_PP_PHASE_OFFSET + 0,
    NETIF_PPP_PHASE_MASTER = NETIF_PP_PHASE_OFFSET + 1, NETIF_PPP_PHASE_HOLDOFF =
    NETIF_PP_PHASE_OFFSET + 2,
    NETIF_PPP_PHASE_INITIALIZE = NETIF_PP_PHASE_OFFSET + 3, NETIF_PPP_PHASE_SERIALCONN =
    NETIF_PP_PHASE_OFFSET + 4,
    NETIF_PPP_PHASE_DORMANT = NETIF_PP_PHASE_OFFSET + 5, NETIF_PPP_PHASE_ESTABLISH =
    NETIF_PP_PHASE_OFFSET + 6,
    NETIF_PPP_PHASE_AUTHENTICATE = NETIF_PP_PHASE_OFFSET + 7, NETIF_PPP_PHASE_CALLBACK =
    NETIF_PP_PHASE_OFFSET + 8,
    NETIF_PPP_PHASE_NETWORK = NETIF_PP_PHASE_OFFSET + 9, NETIF_PPP_PHASE_RUNNING =
    NETIF_PP_PHASE_OFFSET + 10,
    NETIF_PPP_PHASE_TERMINATE = NETIF_PP_PHASE_OFFSET + 11, NETIF_PPP_PHASE_DISCONNECT =
    NETIF_PP_PHASE_OFFSET + 12
    );

  Pesp_netif_auth_type = ^Tesp_netif_auth_type;
  Tesp_netif_auth_type = (NETIF_PPP_AUTHTYPE_NONE = $00, NETIF_PPP_AUTHTYPE_PAP = $01,
    NETIF_PPP_AUTHTYPE_CHAP = $02, NETIF_PPP_AUTHTYPE_MSCHAP = $04,
    NETIF_PPP_AUTHTYPE_MSCHAP_V2 = $08, NETIF_PPP_AUTHTYPE_EAP = $10
    );

// Move functions up to esp_netif to break circular unit dependency
//function esp_netif_ppp_set_auth(netif: Pesp_netif_t; authtype: Tesp_netif_auth_type_t;
//  user: pchar; passwd: pchar): Tesp_err_t; cdecl; external;
//
//function esp_netif_ppp_set_params(netif: Pesp_netif_t;
//  config: Pesp_netif_ppp_config_t): Tesp_err_t; cdecl; external;

var
  NETIF_PPP_STATUS : Tesp_event_base; cvar; external;

implementation

end.
