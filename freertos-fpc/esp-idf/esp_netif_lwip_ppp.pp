unit esp_netif_lwip_ppp;

interface

uses
  esp_err, esp_netif_types, esp_netif_lwip_internal;

function esp_netif_new_ppp(esp_netif: Tesp_netif;
  esp_netif_stack_config: Pesp_netif_netstack_config): Plwip_ppp_ctx; external;
function esp_netif_start_ppp(ppp: Plwip_ppp_ctx_t): Tesp_err; external;
procedure esp_netif_lwip_ppp_input(ppp: pointer; buffer: pointer;
  len: Tsize; eb: pointer); external;
procedure esp_netif_destroy_ppp(ppp: Plwip_ppp_ctx); external;
function esp_netif_stop_ppp(ppp: Plwip_ppp_ctx): Tesp_err_t; external;
procedure esp_netif_ppp_set_default_netif(ppp_ctx: Plwip_ppp_ctx); external;

implementation

end.
