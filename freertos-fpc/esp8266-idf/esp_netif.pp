unit esp_netif;

{$include sdkconfig.inc}
{$linklib lwip, static}

interface

uses
  esp_err;

{.$include "esp_wifi_types.h"}
{.$include "tcpip_adapter.h"}

function esp_netif_init: Tesp_err; cdecl; external;
function esp_netif_deinit: Tesp_err; cdecl; external;

implementation

end.
