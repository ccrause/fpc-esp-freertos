unit esp_interface;

interface

type
  Pesp_interface = ^Tesp_interface;
  Tesp_interface = (ESP_IF_WIFI_STA = 0, ESP_IF_WIFI_AP, ESP_IF_ETH,
    ESP_IF_MAX);

implementation

end.
