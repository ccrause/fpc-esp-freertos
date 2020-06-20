unit esp_netif;

{$include sdkconfig.inc}
{$linklib lwip, static}

interface

uses
  esp_err;

function esp_netif_init: Tesp_err; external;
function esp_netif_deinit: Tesp_err; external;

implementation

end.
