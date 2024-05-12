program mqtt_client_demo;

uses
  fmem, freertos,
  wificonnect,
  esp_http_server, esp_err, http_parser,
  portable, task,
  esp_log, mqtt_client, esp_event_base,
  gpio, gpio_types, portmacro;

{$macro on}
{$inline on}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

const
  TAG = 'MQTT_EXAMPLE';
  cmndTopic = 'cmnd/BinLatch/Position';
  statTopic = 'stat/BinLatch/Position';
  mqttserver = 'mqtt://192.168.1.115';  // OpenHAB with mosquitto running on RPi on local netwrok
  statClose = '1';
  statOpen = '0';

  LED = GPIO_NUM_2;  // NodeMCU LED on ESP-12E module, also ESP32 DevKit V1 from DOIT
  Button = GPIO_NUM_0; // ESP32 DevKit V1 board boot button

var
  myClient: Tesp_mqtt_client_handle;
  disconnected: boolean;
  latched: boolean;
  buttonPressed: boolean;

procedure mqtt_event_handler(handler_args: pointer; base: Tesp_event_base; event_id: int32; event_data: pointer);
var
  event: Tesp_mqtt_event_handle;
  client: Tesp_mqtt_client_handle;
  topic, data: shortstring;
begin
  event := event_data;
  client := event^.client;

  case Tesp_mqtt_event_id(event_id) of
    MQTT_EVENT_CONNECTED:
    begin
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_CONNECTED'#10);
      esp_mqtt_client_subscribe(client, cmndTopic, 0);
      disconnected := false;

      // Update current status on mqtt server
      if latched then
        esp_mqtt_client_publish(myClient, statTopic, statClose, 0, 0, 0)
      else
        esp_mqtt_client_publish(myClient, statTopic, statOpen, 0, 0, 0);
    end;

    MQTT_EVENT_DISCONNECTED:
    begin
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_DISCONNECTED'#10);
      disconnected := true;
    end;

    MQTT_EVENT_SUBSCRIBED:
    begin
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_SUBSCRIBED, msg_id=%d'#10, event^.msg_id);
    end;

    MQTT_EVENT_UNSUBSCRIBED: esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_UNSUBSCRIBED, msg_id=%d'#10, event^.msg_id);

    MQTT_EVENT_PUBLISHED: esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_PUBLISHED, msg_id=%d'#10, event^.msg_id);

    MQTT_EVENT_DATA:
    begin
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_DATA'#10);

      SetLength(topic, event^.topic_len);
      move(event^.topic[0], topic[1], length(topic));
      SetLength(data, event^.data_len);
      move(event^.data[0], data[1], length(data));

      esp_log_write(ESP_LOG_INFO, TAG, 'mqtt: %.*s [%.*s]'#10,
        length(topic), @topic[1], length(data), @data[1]); // Lazy workaround for shortstrings!

      if CompareChar(topic[1], cmndTopic[1], length(topic)) = 0 then
      begin
        if length(data) = 0 then
        begin
          // Empty data means return status
          if latched then
            esp_mqtt_client_publish(myClient, statTopic, statClose, 0, 0, 0)
          else
            esp_mqtt_client_publish(myClient, statTopic, statOpen, 0, 0, 0);
        end
        else if (data[1] = '1') or (CompareChar(data[1], 'ON', length(data)) = 0) then
        begin
          gpio_set_level(LED, 1);
          latched := true;
        end
        else if (data[1] = '0') or (CompareChar(data[1], 'OFF', length(data)) = 0) then
        begin
          gpio_set_level(LED, 0);
          latched := false;
        end;
      end;
    end;

    MQTT_EVENT_ERROR:
    begin
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT_EVENT_ERROR'#10);
    end;

    otherwise
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT unhandled event: %d'#10, event^.event_id);
  end;
end;

procedure mqtt_app_start;
var
  mqtt_cfg: Tesp_mqtt_client_config;
begin
  FillByte(mqtt_cfg, SizeOf(mqtt_cfg), 0);
  mqtt_cfg.uri := mqttserver; //'mqtt://test.mosquitto.org';
  myClient := esp_mqtt_client_init(mqtt_cfg);
  // The last argument may be used to pass data to the event handler, in this example mqtt_event_handler */
  esp_mqtt_client_register_event(myClient, MQTT_EVENT_ANY, @mqtt_event_handler, nil);
  esp_mqtt_client_start(myClient);
end;

var
  cfg: Tgpio_config;

begin
  esp_log_level_set('wifi', ESP_LOG_ERROR);
  // Configure LED pin
  cfg.pin_bit_mask := 1 shl ord(LED) ;
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);
  gpio_set_direction(LED, GPIO_MODE_OUTPUT);

  // Configure button pin
  cfg.pin_bit_mask := 1 shl ord(Button) ;
  cfg.mode := GPIO_MODE_INPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  connectWifiAP(AP_NAME, PWD);
  disconnected := false;
  mqtt_app_start();

  latched := false;
  buttonPressed := false;
  repeat
    vTaskDelay(100 div portTICK_PERIOD_MS);

    if disconnected then
    begin
      esp_mqtt_client_reconnect(myClient);
    end;

    if gpio_get_level(Button) = 0 then
    begin
      if not buttonPressed then
      begin
        buttonPressed := true;
        writeln('Button pressed');
      end;
    end
    else
    begin
      if buttonPressed then
      begin
        buttonPressed := false;
        if not latched then
        begin
          latched := true;
          gpio_set_level(LED, 1);
          writeln('LED = 1');
          esp_mqtt_client_publish(myClient, statTopic, statClose, 0, 0, 0);
        end
        else
        begin
          latched := false;
          gpio_set_level(LED, 0);
          writeln('LED = 0');
          esp_mqtt_client_publish(myClient, statTopic, statOpen, 0, 0, 0);
        end;
      end;
    end;
  until false;
end.

