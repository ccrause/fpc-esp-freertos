unit webserver;

interface
{$macro on}
{$inline on}

uses
  esp_http_server, esp_err;

function start_webserver: Thttpd_handle;

function register_uri_handler(uri_handler: Phttpd_uri_t): Tesp_err;

implementation

uses
  http_parser, esp_wifi, esp_wifi_types,
  dataUnit, semphr, portmacro, settingsmanager;

const
  maina = '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="60" >'+
          '<link rel="icon" href="/favicon.svg" type="image/svg+xml">'+
          '<title>Borehole pump monitor</title>'+
          '<meta name="viewport" content="width=device-width, initial-scale=1.0">'+
          '<style>* {box-sizing:border-box;}';

  menustyle  =
          '.menu{float:top; padding:2px; text-align:left; background-color:lightgrey;'+
          'border-radius:5px; margin:2px; ul li {list-style:none; margin: 0 auto;'+
          'border-left: 2px solid darkgrey; display: inline-block; padding: 0 10px;'+
          'position:relative; text-decoration:none; text-align:center;}}';

  mainb = '.left{float:left; width:49.5%; padding:20px; text-align: center; background-color:#2196F3;border-radius:5px;margin:2px 0px;}'+
          '.right{float:right; width:49.5%; padding:20px; text-align:center; background-color:#04AA6D;border-radius:5px;margin:2px 0px;}'+
          '.history{float:bottom; padding:10px; text-align:center; background-color:lightgrey; border-radius:5px;}'+
          '@media only screen and (max-width: 620px)'+
          '{.left, .right {width:100%;}}</style></head>';

  menu1 =  '<span><div class="menu"><ul><li><a href="/">Home</a></li> <li><a href="settings">Settings</a></li><span style=float:right>';
           // insert SSID and signal strength here - SSID (-90 dB)
  menu2 =  '</span></ul></div></span>';

  mainc = '<h2>Borehole pump monitor & control</h2>'+
          '<div style="overflow:auto"><div class="left">'+
          '<h3>Tank level, mm</h3><p>';
  // Insert tank level text here
  main2 = '</p></div><div class="right"><h3>Water flow, L/min</h3><p>';
  // Insert flow rate here
  main3 = '</p></div></div><p></p><svg viewBox="0 0 1440 300" class="chart">'+
          '<g class="grid y-grid"><line stroke=grey x1="0" x2="0" y1="0" y2="100%"></line>'+
          '<line stroke=grey x1="0" x2="100%" y1="0" y2="0"></line>'+
          '<line stroke=grey x1="0" x2="100%" y1="25%" y2="25%"></line>'+
          '<line stroke=grey x1="0" x2="100%" y1="50%" y2="50%"></line>'+
          '<line stroke=grey x1="0" x2="100%" y1="75%" y2="75%"></line></g>'+
          '<g class="grid x-grid"><line stroke=grey x1="0" x2="100%" y1="100%" y2="100%"></line>'+
          '<line stroke=grey x1="25%" x2="25%" y1="100%" y2="0"></line>'+
          '<line stroke=grey x1="50%" x2="50%" y1="100%" y2="0"></line>'+
          '<line stroke=grey x1="75%" x2="75%" y1="100%" y2="0"></line>'+
          '<line stroke=grey x1="100%" x2="100%" y1="100%" y2="0"></line></g>'+
          '<polyline fill="none" stroke="#2196F3" stroke-width="6" points="';
  // x,y x,y ...
  main4 = '"/><polyline fill="none" stroke="#04AA6D" stroke-width="6" points="';
  // x,y x,y ...
  main5 = '"/></svg></body></html>';

  settingsa =
  '<!DOCTYPE html><html><head><title>Borehole pump settings</title>'+
  '<meta name="viewport" content="width=device-width, initial-scale=1.0">'+
  '<style>* { box-sizing: border-box; }';

  settingsb =
  '.container{padding:2em; min-height:20vh; display:flex; justify-content:center; align-items:center;}'+
  'input[type=text], select {width:100%; padding: 12px 20px;margin: 8px 0; display:inline-block;'+
  'border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;}'+
  'input[type=submit] {width:100%; background-color:#4CAF50; color:white; padding: 14px 20px;'+
  'margin: 8px 0; border:none; border-radius: 4px; cursor: pointer;}'+
  'input[type=submit]:hover {background-color:#45a049;}'+
  '@media only screen and (max-width: 620px) { .left, .right { width: 100%; }}</style></head>';

  settings_hlstop =
  '<div class="container"><form method="post" action="save">'+
  '<label for="HLstop">High level, mm</label>'+
  '<input type="text" name="HLstop" value="';
  //500
  settings_llstart =
  '" /><label for="LLstart">Low level, mm</label>'+
  '<input type="text" name="LLstart" value="';
  //750
  settings_startdelay =
  '" /><label for="restartDelay">Restart delay, minutes</label>'+
  '<input type="text" name="restartDelay" value="';
  //15
  settings_lowflowstop =
  '" /><label for="LFstop">Low flow, L/min</label>'+
  '<input type="text" name="LFstop" value="';
  //10
  settings_startdeadtime =
  '" /><label for="startDeadTime">Dead time after restart, s</label>'+
  '<input type="text" name="startDeadTime" value="';
  // 15
  settings_end =
  '" /><input type="submit" value="Submit">'+
  '</div></form></div></body></html>';

  favicon =
  '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" '+
  'xmlns:xlink="http://www.w3.org/1999/xlink" '+
  'width="16" height="16">'+
  '<svg width="16" height="16" style="vector-effect: non-scaling-stroke;">'+
  '<g><rect id="SvgjsRect1001" height="14" width="14" y="1" x="1" stroke="grey" '+
  'fill="none"></rect>'+
  '<polyline stroke="#04aa6d" fill="none" points="2,13 7,13 7,4 13,4 13,13 15,13"></polyline>'+
  '<polyline stroke="#2196f3" fill="none" points="2,9 7,9 12,7 15,7"></polyline>'+
  '</g></svg><style>@media (prefers-color-scheme: light) { :root { filter: none; } } '+
  '@media (prefers-color-scheme: dark) { :root { filter: none; } } </style></svg>';

var
  server: Thttpd_handle = nil;

procedure sendMenu_chunk(req: Phttpd_req);
var
  s1: string[8];
  s: shortstring;
  APinfo: Twifi_ap_record;
begin
  httpd_resp_send_chunk(req, menu1, length(menu1));
  if esp_wifi_sta_get_ap_info(@APinfo) = ESP_OK then
  begin
    Str(APinfo.rssi, s1);
    s := PChar(@APinfo.ssid[0]) + ' (' + s1 + ' dB)';
  end
  else
    s := '??? (?? dB)';
  httpd_resp_send_chunk(req, @s[1], length(s));
  httpd_resp_send_chunk(req, menu2, length(menu2));
end;

function main_get_handler(req: Phttpd_req): Tesp_err;
var
  s: shortstring;
  s1, s2: string[8];
  tmp, i, j: integer;
begin
  httpd_resp_send_chunk(req, maina, length(maina));
  httpd_resp_send_chunk(req, menustyle, length(menustyle));
  httpd_resp_send_chunk(req, mainb, length(mainb));

  sendMenu_chunk(req);

  httpd_resp_send_chunk(req, mainc, length(mainc));

  // Write current level
  tmp := currentLevel;
  Str(tmp, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, main2, length(main2));

  // Write current flow
  tmp := round(currentFlow);
  Str(tmp, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, main3, length(main3));

  // Write x,y series for level
  // y is from top of chart, so small reading will show close to top
  s := '';
  xSemaphoreTake(dataSem, portMAX_DELAY);
    for i := 0 to high(levels) do
    begin
      j := i + dataIndex;
      if j > high(levels) then
        j := j - high(levels) - 1;

      Str(i, s1);
      tmp := levels[j] div 6; // 300 * 6 = 1800 mm will be 0%
      if tmp > 300 then tmp := 300;
      Str(tmp, s2);
      s := s + ' ' + s1 + ',' + s2;
      if length(s) > 200 then
      begin
        httpd_resp_send_chunk(req, @s[1], length(s));
        s := '';
      end;
    end;
  xSemaphoreGive(dataSem);
  if length(s) > 0 then
    httpd_resp_send_chunk(req, @s[1], length(s));

  httpd_resp_send_chunk(req, main4, length(main4));

  // Write x,y series for flow
  // y is from top of chart, so subtract max value to invert y axis
  s := '';
  xSemaphoreTake(dataSem, portMAX_DELAY);
    for i := 0 to high(flows) do
    begin
      j := i + dataIndex;
      if j > high(flows) then
        j := j - high(flows) - 1;

      Str(i, s1);
      tmp := 300 - flows[j];
      if tmp < 0 then
        tmp := 0;
      Str(tmp, s2);
      s := s + ' ' + s1 + ',' + s2;

      if length(s) > 200 then
      begin
        httpd_resp_send_chunk(req, @s[1], length(s));
        s := '';
      end;
    end;
  xSemaphoreGive(dataSem);
  if length(s) > 0 then
    httpd_resp_send_chunk(req, @s[1], length(s));

  httpd_resp_send_chunk(req, main5, length(main5));
  // Signal finish of chunks
  httpd_resp_send_chunk(req, nil, 0);

  result := ESP_OK;
end;

function settings_get_handler(req: Phttpd_req): Tesp_err;
var
  s1: string[8];
begin
  httpd_resp_send_chunk(req, settingsa, length(settingsa));
  httpd_resp_send_chunk(req, menustyle, length(menustyle));
  httpd_resp_send_chunk(req, settingsb, length(settingsb));

  sendMenu_chunk(req);

  httpd_resp_send_chunk(req, settings_hlstop, length(settings_hlstop));
  Str(settings.HLstop, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, settings_llstart, length(settings_llstart));
  Str(settings.LLstart, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, settings_startdelay, length(settings_startdelay));
  Str(settings.restartDelay, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, settings_lowflowstop, length(settings_lowflowstop));
  Str(settings.LFstop, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, settings_startdeadtime, length(settings_startdeadtime));
  Str(settings.startDeadTime, s1);
  httpd_resp_send_chunk(req, @s1[1], length(s1));

  httpd_resp_send_chunk(req, settings_end, length(settings_end));
  Result := httpd_resp_send_chunk(req, nil, 0);
end;

function favicon_get_handler(req: Phttpd_req): Tesp_err;
begin
  httpd_resp_set_type(req, 'image/svg+xml');
  Result := httpd_resp_send(req, favicon, length(favicon));
end;

function save_post_handler(req: Phttpd_req): Tesp_err;
const
  s1len = 8;
var
  size, tmp, ret: integer;
  buf: array[0..180] of char;
  s1: string[s1len];
begin
  FillChar(buf, SizeOf(buf), #0);
  size := length(buf);
  ret := httpd_req_recv(req, @buf, size);
  if ret <= 0 then
  begin
    if ret = HTTPD_SOCK_ERR_TIMEOUT then
      httpd_resp_send_err(req, HTTPD_408_REQ_TIMEOUT, nil);
    exit(ESP_FAIL);
  end;

  writeln('Received: "', buf, '"');

  FillChar(s1[1], s1len, #0);
  if httpd_query_key_value(@buf, 'HLstop'#0, @s1[1], s1len) = ESP_OK then
  begin
    Val(s1, tmp, ret);
    if ret = 0 then
      settings.HLstop := tmp
    else
      writeln('Error converting value HLstop: ', s1);
  end
  else
    writeln('Error finding value HLstop');

  FillChar(s1[1], s1len, #0);
  if httpd_query_key_value(@buf, 'LLstart'#0, @s1[1], s1len) = ESP_OK then
  begin
    Val(s1, tmp, ret);
    if ret = 0 then
      settings.LLstart := tmp
    else
      writeln('Error converting value LLstart: ', s1);
  end
  else
    writeln('Error finding value LLstart');

  FillChar(s1[1], s1len, #0);
  if httpd_query_key_value(@buf, 'restartDelay'#0, @s1[1], s1len) = ESP_OK then
  begin
    Val(s1, tmp, ret);
    if ret = 0 then
      settings.restartDelay := tmp
    else
      writeln('Error converting value restartDelay: ', s1);
  end
  else
    writeln('Error finding value restartDelay');

  FillChar(s1[1], s1len, #0);
  if httpd_query_key_value(@buf, 'LFstop'#0, @s1[1], s1len) = ESP_OK then
  begin
    Val(s1, tmp, ret);
    if ret = 0 then
      settings.LFstop := tmp
    else
      writeln('Error converting value LFstop: ', s1);
  end
  else
    writeln('Error finding value LFstop');

  FillChar(s1[1], s1len, #0);
  if httpd_query_key_value(@buf, 'startDeadTime'#0, @s1[1], s1len) = ESP_OK then
  begin
    Val(s1, tmp, ret);
    if ret = 0 then
      settings.startDeadTime := tmp
    else
      writeln('Error converting value startDeadTime: ', s1);
  end
  else
    writeln('Error finding value startDeadTime');

  saveSettings();

  httpd_resp_set_type(req, 'text/html');
  httpd_resp_set_status(req, '303 See Other');
  httpd_resp_set_hdr(req, 'Location', '/');
  Result := httpd_resp_send(req, nil, 0);
end;

function start_webserver: Thttpd_handle;
var
  config: Thttpd_config;
  mainUriHandlerConfig: Thttpd_uri;
  settingsUriHandlerConfig: Thttpd_uri;
  saveUriHandlerConfig: Thttpd_uri;
  faviconUriHandlerConfig: Thttpd_uri;
begin
  server := nil;
  config := HTTPD_DEFAULT_CONFIG();

  with mainUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @main_get_handler;
    user_ctx  := nil;
  end;

  with settingsUriHandlerConfig do
  begin
    uri       := '/settings';
    method    := HTTP_GET;
    handler   := @settings_get_handler;
    user_ctx  := nil;
  end;

  with saveUriHandlerConfig do
  begin
    uri       := '/save';
    method    := HTTP_POST;
    handler   := @save_post_handler;
    user_ctx  := nil;
  end;

  with faviconUriHandlerConfig do
  begin
    uri       := '/favicon.svg';
    method    := HTTP_GET;
    handler   := @favicon_get_handler;
    user_ctx  := nil;
  end;

  writeln('Starting server on port: ', config.server_port);
  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    // Set URI handlers
    writeln('Registering URI handler');
    httpd_register_uri_handler(server, @mainUriHandlerConfig);
    httpd_register_uri_handler(server, @settingsUriHandlerConfig);
    httpd_register_uri_handler(server, @saveUriHandlerConfig);
    httpd_register_uri_handler(server, @faviconUriHandlerConfig);
    result := server;
  end
  else
  begin
    result := nil;
    writeln('### Failed to start httpd');
  end;
end;

function register_uri_handler(uri_handler: Phttpd_uri_t): Tesp_err;
begin
  if assigned(server) then
    Result := httpd_register_uri_handler(server, uri_handler)
  else
    Result := ESP_FAIL;
end;

end.

