unit esp_wifi_default;

interface

uses
  esp_err, esp_netif_types;

type
  Pesp_netif_t = Pesp_netif_obj;
  PPesp_netif_t = ^Pesp_netif_t;

function esp_netif_attach_wifi_station(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_netif_attach_wifi_ap(esp_netif: Pesp_netif_t): Tesp_err_t; cdecl; external;

function esp_wifi_set_default_wifi_sta_handlers: Tesp_err_t; cdecl; external;

function esp_wifi_set_default_wifi_ap_handlers: Tesp_err_t; cdecl; external;

function esp_wifi_clear_default_wifi_driver_and_handlers(esp_netif: pointer): Tesp_err_t;
  cdecl; external;

function esp_netif_create_default_wifi_ap: Pesp_netif_t; cdecl; external;

function esp_netif_create_default_wifi_sta: Pesp_netif_t; cdecl; external;

function esp_netif_create_default_wifi_mesh_netifs(p_netif_sta: PPesp_netif_t;
  p_netif_ap: PPesp_netif_t): Tesp_err_t; cdecl; external;

implementation

end.
