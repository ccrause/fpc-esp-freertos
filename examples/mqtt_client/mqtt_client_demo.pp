program mqtt_client_demo;

uses
  fmem, freertos,
  wificonnect2,
  esp_http_server, esp_err, http_parser,
  portable, task,
  esp_log, mqtt_client, esp_event_base,
  gpio, {$ifdef CPULX6}gpio_types,{$endif} portmacro,
  esp_system;

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
  mqttserver = 'mqtt://192.168.1.115';  // OpenHAB with mosquitto running on RPi on local netwrok

  // Input pin and mqtt topics
  InputPin = GPIO_NUM_3;  // ESP-01 RX pin
  InputCmndTopic = 'cmnd/Input/State';  //
  InputStatTopic = 'stat/Input/State';

  OutputPin = GPIO_NUM_2; // ESP-01
  OutputStatTopic = 'stat/Output/State';

  statHigh = '1';
  statLow = '0';

var
  myClient: Tesp_mqtt_client_handle;
  disconnected: boolean;
  InputState: boolean;
  OutputState: boolean;
  localControl: boolean;

function makeStationName: shortstring;
const
  nameLength = {$if defined(CPULX6)}18{$else}20{$endif};
  namePrefix = {$if defined(FPC_MCU_ESP32)}'esp32-'{$elseif defined(FPC_MCU_ESP8266)}'esp8266-'{$else}'???????-'{$endif};
var
  mac: array[0..5] of byte;
  s: string[2];
  i: integer;
begin
  SetLength(Result, namelength);
  FillChar(Result[1], namelength, #0);
  Move(namePrefix[1], Result[1], length(namePrefix));
  EspErrorCheck(esp_efuse_mac_get_default(@mac[0]), 'esp_efuse_mac_get_default');
  for i := 0 to high(mac) do
  begin
    s := HexStr(mac[i], 2);
    Move(s[1], Result[length(namePrefix) + 1 + 2*i], length(s));
  end;
end;

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
      esp_mqtt_client_subscribe(client, InputCmndTopic, 0);
      disconnected := false;

      // Update current status on mqtt server
      if InputState then
        esp_mqtt_client_publish(myClient, InputStatTopic, statHigh, 0, 0, 0)
      else
        esp_mqtt_client_publish(myClient, InputStatTopic, statLow, 0, 0, 0);

      if OutputState then
        esp_mqtt_client_publish(myClient, OutputStatTopic, statHigh, 0, 0, 0)
      else
        esp_mqtt_client_publish(myClient, OutputStatTopic, statLow, 0, 0, 0);
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

      if CompareChar(topic[1], InputCmndTopic[1], length(topic)) = 0 then
      begin
        if length(data) = 0 then
        begin
          // Empty data means return status
          if InputState then
            esp_mqtt_client_publish(myClient, InputStatTopic, statHigh, 0, 0, 0)
          else
            esp_mqtt_client_publish(myClient, InputStatTopic, statLow, 0, 0, 0);
        end
        else if (data[1] = '1') or (CompareChar(data[1], 'ON', length(data)) = 0) then
        begin
          gpio_set_level(OutputPin, 1);
          localControl := false;
          InputState := true;
          esp_mqtt_client_publish(myClient, OutputStatTopic, statHigh, 0, 0, 0);
          writeln('mqtt override: Output 1');
        end
        else if (data[1] = '0') or (CompareChar(data[1], 'OFF', length(data)) = 0) then
        begin
          gpio_set_level(OutputPin, 0);
          localControl := false;
          InputState := false;
          esp_mqtt_client_publish(myClient, OutputStatTopic, statLow, 0, 0, 0);
          writeln('mqtt override: Output 0');
        end;
      end
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
  mqtt_cfg.uri := {mqttserver; //}'mqtt://test.mosquitto.org';
  myClient := esp_mqtt_client_init(mqtt_cfg);
  // The last argument may be used to pass data to the event handler, in this example mqtt_event_handler */
  esp_mqtt_client_register_event(myClient, MQTT_EVENT_ANY, @mqtt_event_handler, nil);
  esp_mqtt_client_start(myClient);
end;

var
  cfg: Tgpio_config;
  stationName: shortstring;

begin
  esp_log_level_set('*', ESP_LOG_WARN);
  // Configure output pin
  cfg.pin_bit_mask := 1 shl ord(OutputPin);
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  // Configure input pin with internal pulldown
  cfg.pin_bit_mask := 1 shl ord(InputPin) ;
  cfg.mode := GPIO_MODE_INPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_ENABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  stationName := makeStationName();
  writeln('Station name: ', stationName);
  connectWifiAP(AP_NAME, PWD, PChar(@stationName[1]));
  disconnected := false;
  mqtt_app_start();

  InputState := false;
  OutputState := false;
  localControl := true;

  // Make inputState inverse of InputPin state so that change logic in loop triggers
  inputState := gpio_get_level(InputPin) = 0;

  repeat
    if disconnected then
    begin
      esp_mqtt_client_reconnect(myClient);
    end;

    if localControl then
    begin
      if gpio_get_level(InputPin) = 0 then
      begin
        if InputState then
        begin
          writeln('Input low');
          InputState := false;
          OutputState := false;
          gpio_set_level(OutputPin, 0);
          esp_mqtt_client_publish(myClient, OutputStatTopic, statLow, 0, 0, 0);
        end;
      end
      else
      begin
        if not InputState then
        begin
          writeln('Input high');
          InputState := true;
          OutputState := true;
          gpio_set_level(OutputPin, 1);
          esp_mqtt_client_publish(myClient, OutputStatTopic, statHigh, 0, 0, 0);
        end;
      end;
    end;

    vTaskDelay(100 div portTICK_PERIOD_MS);
  until false;
end.

