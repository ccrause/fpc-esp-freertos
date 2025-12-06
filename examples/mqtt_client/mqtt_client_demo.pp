program mqtt_client_demo;

{ Testing with mosquitto.org broker:
  1. Show changes in topic: mosquitto_sub -h test.mosquitto.org -t stat/Output/State
  2. Post requests: mosquitto_pub -h test.mosquitto.org -t stat/Output/State -m 1

  Flashing:
  /home/christo/fpc/xtensa/esp-idf-4.3.7/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 4MB 0x10000 bin/mqtt_client_demo.bin
}

uses
  fmem, freertos,
  wificonnect2,
  esp_http_server, esp_err, http_parser,
  portable, task,
  esp_log, mqtt_client, esp_event_base,
  gpio, {$ifdef CPULX6}gpio_types,{$endif} portmacro,
  esp_system, nvs {$ifdef CPULX106}, nvs_flash{$endif};

{$macro on}
{$inline on}

{ Latching input:
  Input state is reflected on output, e.g. a conventional light switch.
  For remote control one needs to enable the override option. To enable this
  behaviour define the LATCHINGINPUT macro below.

  Momentary input:
    Each press event (positive edge) changes the output state (1 -> 0 -> 1 ...).
    In this mode either a local press event or a remote command can change the
    output state. This is the behaviour if LATCHINGINPUT is not defined.
}
{$define LATCHINGINPUT}

// AP credentials not stored in shared code
// Put credentials in text file and include below
// format of entries in include file
// {$define AP_NAME := 'name of access point'}
// {$define PWD := 'password for AP'}
{$include credentials.ignore}

const
  TAG = 'MQTT_EXAMPLE';
  mqttserver = 'mqtt://test.mosquitto.org';
  //mqttserver = 'mqtt://192.168.1.115';  // OpenHAB with mosquitto running on RPi on local network

  // mqtt topic fragments
  availabilityStr = 'availability';
  statStr = 'stat';
  cmndStr = 'cmnd';
  switchTopic = '/switch/';
  {$ifdef LATCHINGINPUT}
  overrideTopic = '/override/';
  {$endif}

  // mqtt states
  statHigh = '1';
  statLow = '0';
  availOffline = 'offline';
  availOnline = 'online';
  // mqtt quality of service level
  qos = 0;
  mqttReconnectWaitCount = 100; // Main loop runs at ~10 Hz, so wait ~10 sec before reconnecting

  // Pins for ESP-01
  //InputPin = GPIO_NUM_3;  // RX pin
  //OutputPin = GPIO_NUM_2;

  // Pins for Sonoff Basic R1
  InputPin = GPIO_NUM_0;   // Onboard momentary switch, NO, connected to ground
  OutputPin = GPIO_NUM_12; // Relay pin
  LEDpin = GPIO_NUM_13;

  // Storage strings
  {$ifdef LATCHINGINPUT}
  strOverrideState = 'overrideState';
  {$endif}
  strSwitchState = 'switchState';

var
  myClient: Tesp_mqtt_client_handle;
  mqttConnected: boolean;
  mqttReconnectWait: integer;
  switchState: boolean;
  {$ifdef LATCHINGINPUT}
  overrideState: boolean;
  {$endif}

  SwitchAvailabilityTopic: shortstring; // 'esp-xxx/switch/availability';
  SwitchCmndTopic: shortstring; // = 'esp-xxx/switch/cmnd';
  SwitchStatTopic: shortstring; // = 'esp-xxx/switch/stat';
  {$ifdef LATCHINGINPUT}
  OverrideCmndTopic: shortstring; // = 'esp-xxx/override/cmnd';
  OverrideStatTopic: shortstring; // = 'esp-xxx/override/stat';
  {$endif}

  storageHandle: Tnvs_handle;

  { Input pin bias mode. Set to:
      GPIO_PULLUP_ONLY if external button is connected to ground
      GPIO_PULLDOWN_ONLY if external button is connected to Vcc
      GPIO_FLOATING if bias is provided by external circuitry
    Logic assumes that a normally open button is used for input.
  }
  inputBias: Tgpio_pull_mode = GPIO_PULLDOWN_ONLY;
  {$ifndef LATCHINGINPUT}
  prevInputState, inputState: boolean;
  idleState: boolean = true;  // Output toggle happens when input state returns to idle level
  {$endif}

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

function initNVS: Tesp_err;
begin
  Result := nvs_flash_init();
  if (Result = ESP_ERR_NVS_NO_FREE_PAGES) {$ifdef CPULX6} or (Result = ESP_ERR_NVS_NEW_VERSION_FOUND){$endif} then
  begin
    writeln('Erasing flash');
    EspErrorCheck(nvs_flash_erase());
    Result := nvs_flash_init();
  end;
  EspErrorCheck(Result);

  if Result = ESP_OK then
    Result := nvs_open('storage', NVS_READWRITE, @storageHandle);

  if not(Result = ESP_OK) then
  begin
    storageHandle := 0;
    writeln('nvs_open failed');
  end;
end;

function loadSettings: Tesp_err;
begin
  Result := initNVS;

  {$ifdef LATCHINGINPUT}
  if Result = ESP_OK then
  begin
    Result := nvs_get_u8(storageHandle, strOverrideState, @overrideState);
    if (Result <> ESP_OK) then
    begin
      write('Error reading ', strOverrideState, ': ');
      writeln(esp_err_to_name(Result));
      Result := ESP_FAIL;
    end;

    if overrideState then {$endif}
    begin
      Result := nvs_get_u8(storageHandle, strSwitchState, @switchState);
      if (Result <> ESP_OK) then
      begin
        write('Error reading ', strSwitchState, ': ');
        writeln(esp_err_to_name(Result));
        Result := ESP_FAIL;
      end;
    end;

    nvs_close(storageHandle)
  {$ifdef LATCHINGINPUT}
  end;
  {$endif}
end;

function saveSetting(const setting: shortstring; const value: boolean): Tesp_err;
begin
  Result := initNVS;

  if Result = ESP_OK then
  begin
    Result := nvs_set_u8(storageHandle, @setting[1], uint8(value));
    if (Result <> ESP_OK) then
    begin
      write('Error writing ', setting, ': ');
      writeln(esp_err_to_name(Result));
      Result := ESP_FAIL;
    end;

    if Result = ESP_OK then
    begin
      Result := nvs_commit(storageHandle);
      nvs_close(storageHandle);
    end;
  end;

  if Result <> ESP_OK then
  begin
    write('Error saving setting: ');
    writeln(esp_err_to_name(Result));
  end;
end;

procedure subscribeTopic(client: Tesp_mqtt_client_handle; const topic: shortstring);
var
  res: integer;
begin
  write('Subscribing to ', topic, ': ');
  res := esp_mqtt_client_subscribe(client, @topic[1], 0);
  if res > 0 then
    writeln(res)
  else
    writeln('ERROR ', res);
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
    MQTT_EVENT_ERROR: esp_log_write(ESP_LOG_ERROR, TAG, 'MQTT_EVENT_ERROR'#10);

    MQTT_EVENT_CONNECTED:
    begin
      mqttConnected := true;
      writeln('MQTT_EVENT_CONNECTED'#10);

      subscribeTopic(client, SwitchCmndTopic);
      {$ifdef LATCHINGINPUT}
      subscribeTopic(client, OverrideCmndTopic);
      {$endif}

      // Update current status on mqtt server
      esp_mqtt_client_publish(myClient, @SwitchAvailabilityTopic[1], availOnline, 0, qos, 1);
      if switchState then
        esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1)
      else
        esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);

      {$ifdef LATCHINGINPUT}
      if overrideState then
        esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statHigh, 0, qos, 1)
      else
        esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statLow, 0, qos, 1);
      {$endif}
    end;

    MQTT_EVENT_DISCONNECTED:
    begin
      //writeln('MQTT_EVENT_DISCONNECTED');
      mqttConnected := false;
      mqttReconnectWait := mqttReconnectWaitCount;
    end;

    MQTT_EVENT_SUBSCRIBED: writeln('MQTT_EVENT_SUBSCRIBED, msg_id=', event^.msg_id);

    MQTT_EVENT_UNSUBSCRIBED: writeln('MQTT_EVENT_UNSUBSCRIBED, msg_id=', event^.msg_id);

    MQTT_EVENT_PUBLISHED: ; // Do nothing

    MQTT_EVENT_DATA:
    begin
      FillChar(topic[1], high(topic), #0);
      SetLength(topic, event^.topic_len);
      move(event^.topic[0], topic[1], length(topic));

      FillChar(data[1], high(data), #0);
      SetLength(data, event^.data_len);
      move(event^.data[0], data[1], length(data));

      if CompareChar(topic[1], SwitchCmndTopic[1], length(topic)) = 0 then
      begin
        if length(data) = 0 then
        begin
          // Empty data means return status
          if switchState then
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1)
          else
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);
        end
        else {$ifdef LATCHINGINPUT} if overrideState then{$endif}
        begin
          if (data[1] = '1') or (CompareChar(data[1], 'ON', length(data)) = 0) then
          begin
            gpio_set_level(OutputPin, 1);
            switchState := true;
            {$if declared(LEDpin)}gpio_set_level(LEDpin, ord(switchState));{$endif}
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1);
            writeln('Output (mqtt): 1');
            saveSetting(strSwitchState, switchState);
          end
          else if (data[1] = '0') or (CompareChar(data[1], 'OFF', length(data)) = 0) then
          begin
            gpio_set_level(OutputPin, 0);
            switchState := false;
            {$if declared(LEDpin)}gpio_set_level(LEDpin, ord(switchState));{$endif}
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);
            writeln('Output (mqtt): 0');
            saveSetting(strSwitchState, switchState);
          end
          else
            writeln('Unknown data: ', topic, ' [', data, ']');
        end
        {$ifdef LATCHINGINPUT}
        else
        begin
          writeln('Cannot force input state if inputOverride is not enabled');
          // Send status message to show the state has not changed
          if switchState then
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1)
          else
            esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);
        end
        {$endif}
      end
      {$ifdef LATCHINGINPUT}
      else if CompareChar(topic[1], OverrideCmndTopic[1], length(topic)) = 0 then
      begin
        if length(data) = 0 then
        begin
          // Empty data means return status
          if overrideState then
            esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statHigh, 0, qos, 1)
          else
            esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statLow, 0, qos, 1);
        end
        else if (data[1] = '1') or (CompareChar(data[1], 'ON', length(data)) = 0) then
        begin
          writeln('Override on');
          esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statHigh, 0, qos, 1);
          overrideState := true;
          saveSetting(strOverrideState, overrideState);
          saveSetting(strSwitchState, switchState);
        end
        else if (data[1] = '0') or (CompareChar(data[1], 'OFF', length(data)) = 0) then
        begin
          writeln('Override off');
          esp_mqtt_client_publish(myClient, @OverrideStatTopic[1], statLow, 0, qos, 1);
          overrideState := false;
          saveSetting(strOverrideState, overrideState);
        end
        else
          writeln('Unknown data: ', topic, ' [', data, ']');
      end
      {$endif}
      else
        writeln('Unknown topic: ', topic, ' [', data, ']');
    end;

    MQTT_EVENT_BEFORE_CONNECT: ;  // Do nothing

    {$ifdef CPULX6}
    MQTT_EVENT_DELETED: ; // Do nothing;
    {$endif}

    otherwise
      esp_log_write(ESP_LOG_INFO, TAG, 'MQTT unhandled event: %d'#10, event^.event_id);
  end;
end;

procedure mqtt_app_start(const LWTtopic, LWTmessage: shortstring);
var
  mqtt_cfg: Tesp_mqtt_client_config;
begin
  FillByte(mqtt_cfg, SizeOf(mqtt_cfg), 0);
  mqtt_cfg.uri := mqttserver;
  mqtt_cfg.username := '';
  mqtt_cfg.password := '';
  //mqtt_cfg.username := 'openhabian';
  //mqtt_cfg.password := 'openhabian';

  mqtt_cfg.lwt_topic := @LWTtopic[1];
  mqtt_cfg.lwt_msg := @LWTmessage[1];
  mqtt_cfg.lwt_msg_len := Length(LWTmessage);
  mqtt_cfg.lwt_retain := 1;
  mqtt_cfg.lwt_qos := 1;

  myClient := esp_mqtt_client_init(mqtt_cfg);
  esp_mqtt_client_register_event(myClient, MQTT_EVENT_ANY, @mqtt_event_handler, nil);
  esp_mqtt_client_start(myClient);
end;

var
  cfg: Tgpio_config;
  stationName: shortstring;

begin
  {$ifdef CPULX6}
  esp_log_level_set('*', ESP_LOG_WARN);
  {$endif}
  stationName := makeStationName();
  writeln('Station name: ', stationName);
  connectWifiAP(AP_NAME, PWD, PChar(@stationName[1]));
  mqttConnected := false;

  if loadSettings <> ESP_OK then
  begin
    switchState := false;
    {$ifdef LATCHINGINPUT}
    overrideState := false;
    {$endif}
  end
  else
  begin
    writeln('Loaded ', strSwitchState, ': ', switchState);
    {$ifdef LATCHINGINPUT}
    writeln('Loaded ', strOverrideState, ': ', overrideState);
    {$endif}
  end;

  writeln('mqtt topics:');
  SwitchAvailabilityTopic := stationName + switchTopic + availabilityStr;
  writeln(SwitchAvailabilityTopic);
  SwitchCmndTopic := stationName + switchTopic + cmndStr;
  writeln(SwitchCmndTopic);
  SwitchStatTopic := stationName + switchTopic + statStr;
  writeln(SwitchStatTopic);
  {$ifdef LATCHINGINPUT}
  OverrideCmndTopic := stationName + overrideTopic + cmndStr;
  writeln(OverrideCmndTopic);
  OverrideStatTopic := stationName + overrideTopic + statStr;
  writeln(OverrideStatTopic);
  {$endif}

  mqtt_app_start(SwitchAvailabilityTopic, availOffline);

  // Configure input pin
  cfg.pin_bit_mask := 1 shl ord(InputPin) ;
  cfg.mode := GPIO_MODE_INPUT;
  if inputBias = GPIO_PULLDOWN_ONLY then
  begin
    cfg.pull_up_en := GPIO_PULLUP_DISABLE;
    cfg.pull_down_en := GPIO_PULLDOWN_ENABLE;
  end
  else if inputBias = GPIO_PULLUP_ONLY then
  begin
    cfg.pull_up_en := GPIO_PULLUP_ENABLE;
    cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  end
  else
  begin
    cfg.pull_up_en := GPIO_PULLUP_DISABLE;
    cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  end;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  // Configure output pin
  cfg.pin_bit_mask := (1 shl ord(OutputPin)) {$if declared(LEDpin)} or (1 shl ord(LEDpin)){$endif};
  cfg.mode := GPIO_MODE_OUTPUT;
  cfg.pull_up_en := GPIO_PULLUP_DISABLE;
  cfg.pull_down_en := GPIO_PULLDOWN_DISABLE;
  cfg.intr_type := GPIO_INTR_DISABLE;
  gpio_config(cfg);

  {$ifdef LATCHINGINPUT}
  // Make inputState inverse of InputPin state to trigger change logic in loop
  if not overrideState then
    switchState := gpio_get_level(InputPin) = 0;
  {$else}
  inputState := boolean(gpio_get_level(InputPin)) = idleState;
  prevInputState := inputState;
  {$endif}

  repeat
    {$ifdef LATCHINGINPUT}
    if not overrideState then
    begin
      if gpio_get_level(InputPin) = 0 then
      begin
        if switchState then
        begin
          writeln('Switch ', statLow);
          switchState := false;
          gpio_set_level(OutputPin, 0);
          {$if declared(LEDpin)}gpio_set_level(LEDpin, 0);{$endif}
          esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);
        end;
      end
      else
      begin
        if not switchState then
        begin
          writeln('Switch ', statHigh);
          switchState := true;
          gpio_set_level(OutputPin, 1);
          {$if declared(LEDpin)}gpio_set_level(LEDpin, 1);{$endif}

          esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1);
        end;
      end;
    end;
    {$else}
    inputState := boolean(gpio_get_level(InputPin)) = idleState;
    if (inputState <> prevInputState) then
    begin
      prevInputState := inputState;
      if inputState = idleState then
      begin
        switchState := not(switchState);
        gpio_set_level(OutputPin, ord(switchState));
        {$if declared(LEDpin)}gpio_set_level(LEDpin, ord(switchState));{$endif}

        if switchState then
        begin
          esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statHigh, 0, qos, 1);
          writeln('Output: ', statHigh);
        end
        else
        begin
          esp_mqtt_client_publish(myClient, @SwitchStatTopic[1], statLow, 0, qos, 1);
          writeln('Output: ', statLow);
        end;
      end;
    end;
    {$endif}

    if not mqttConnected then
    begin
      if mqttReconnectWait > 0 then
        dec(mqttReconnectWait)
      else
      begin
        esp_mqtt_client_reconnect(myClient);
        mqttReconnectWait := mqttReconnectWaitCount;
      end;
    end;

    vTaskDelay(100 div portTICK_PERIOD_MS);
  until false;
end.

