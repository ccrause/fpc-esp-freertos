program wifisignal;

{$include sdkconfig.inc}
{$include credentials.ignore}

uses
  esp_err, esp_wifi, esp_wifi_types, esp_netif, esp_event, task, esp_log,
  gpio, wificonnect2, temputils
  {$ifdef CPULX6}, esp_wifi_default, rtc_wdt, gpio_types{$endif}
  , nvs
  {$ifdef CPULX106}, nvs_flash, esp_event_legacy{$endif};

const
  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  //LED = GPIO_NUM_13;  // Sonoff Basic

var
  cfg: Tgpio_config;
  s: shortstring;
  APinfo: Twifi_ap_record;

begin
  {$ifdef CPULX6}
  rtc_wdt_disable; // In case WDT was initialized by bootloader
  {$endif}
  esp_log_level_set('*', ESP_LOG_WARN);

  connectWifiAP(AP_NAME, PWD);

  cfg.pin_bit_mask := 1 shl ord(LED);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  repeat
    sleep(900);
    gpio_set_level(LED, 0);

    write(AP_NAME, ' RSSI: ');
    if stationConnected and
      (esp_wifi_sta_get_ap_info(@APinfo) = ESP_OK) then
        Str(APinfo.rssi, s)
    else
      s := '-200';
    writeln(s);

    sleep(100);
    gpio_set_level(LED, 1);
  until false;
end.

