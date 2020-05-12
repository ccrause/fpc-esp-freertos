unit esp_netif_lwip_ppp;

interface

uses
  esp_err, esp_netif_types, esp_netif_lwip_internal;

//type
//  Pesp_netif_netstack_config_t = ^esp_netif_netstack_config_t;
//  Pesp_netif_t = ^esp_netif_t;
//  Plwip_ppp_ctx_t = ^lwip_ppp_ctx_t;

function esp_netif_new_ppp(esp_netif: Tesp_netif_t;
  esp_netif_stack_config: Pesp_netif_netstack_config): Plwip_ppp_ctx_t; cdecl; external;

function esp_netif_start_ppp(ppp: Plwip_ppp_ctx_t): Tesp_err_t; cdecl; external;

procedure esp_netif_lwip_ppp_input(ppp: pointer; buffer: pointer;
  len: Tsize_t; eb: pointer); cdecl; external;

procedure esp_netif_destroy_ppp(ppp: Plwip_ppp_ctx_t); cdecl; external;

function esp_netif_stop_ppp(ppp: Plwip_ppp_ctx_t): Tesp_err_t; cdecl; external;

procedure esp_netif_ppp_set_default_netif(ppp_ctx: Plwip_ppp_ctx_t); cdecl; external;

implementation

end.
