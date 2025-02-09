unit ap_login;

interface

uses
  esp_http_server;

var
  tmpSSID: string[32];
  reconnect: boolean = false;
  tmpPassword: string[64];

procedure wifi_scan;
function start_APserver: Thttpd_handle;
procedure stop_APserver;

procedure attachLoginToServer(AServer: Thttpd_handle);

implementation

uses
  esp_err, http_parser,
  esp_wifi, esp_wifi_types, esp_event;

const
  APnum = 10;

type
  APdescriptor = record
    SSID: string[33];
    RSSI: integer;
  end;

var
  server: Thttpd_handle;
  APlist: array[0..APnum-1] of APdescriptor;

const
  apSelectPage1 =
  '<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1">'+
  '<style>body {font-family:Arial,Helvetica,sans-serif;}'+
  'form {border: 4px solid #f1f1f1;} select[type=ssid], input[type=password] {'+
  'width:100%; padding:12px 20px; margin:8px 0; display:inline-block;'+
  'border:1px solid #ccc; box-sizing:border-box;}'+
  'button {background-color:#04AA6D; color:white; padding:14px 20px; '+
  'margin:8px 0; border:none; cursor:pointer; width:100%;}'+
  'button:hover{opacity:0.8;} .container{padding:16px;}'+
  'span.pwd{float:right; padding-top:16px;}'+
  '@media screen and (max-width:300px) {span.pwd{display:block;float: none;}}'+
  '</style></head><body><h2>Connect to WiFi</h2>'+
  '<form action="/login" method="post" '+
  'enctype="application/x-www-form-urlencoded" accept-charset="utf8">'+
  '<div class="container">'+
  '<label for="SSID"><b>Select SSID</b></label>'+
  '<select type="ssid" name="SSID" required>';
//  '<option value="DVD">DVD</option>'+

  apSelectPage2 =
  '</select><br>'+
  '<label for="pwd"><b>Password</b></label>'+
  '<input type="password" placeholder="Enter Password" name="pwd" required>'+
  '<button type="submit">Login</button>'+
  '</div></form></body></html>';

apSelectedMsg = 'Stopping local access point and connecting to'#13#10+
                 'SSID: ';
apFinalMsg    = #13#10'It may take a short while before the new connection is available.';

procedure wifi_scan;
var
  cfg: Twifi_init_config;
  ap_info: array[0..APnum-1] of Twifi_ap_record;
  ap_info_len: uint16 = APnum;
  i: integer;
begin
  EspErrorCheck(esp_event_loop_create_default(), 'esp_event_loop_create_default');
  WIFI_INIT_CONFIG_DEFAULT(cfg);
  EspErrorCheck(esp_wifi_init(@cfg), 'esp_wifi_init');
  EspErrorCheck(esp_wifi_set_mode(WIFI_MODE_STA), 'esp_wifi_set_mode');
  EspErrorCheck(esp_wifi_start(), 'esp_wifi_start');

  // Start scan with default settings, block until done
  EspErrorCheck(esp_wifi_scan_start(nil, true), 'esp_wifi_scan_start');

  // Get collected records
  ap_info_len := length(ap_info);
  EspErrorCheck(esp_wifi_scan_get_ap_records(@ap_info_len, @ap_info[0]), 'esp_wifi_scan_get_ap_records');
  EspErrorCheck(esp_wifi_scan_get_ap_num(@ap_info_len), 'esp_wifi_scan_get_ap_num');

  // Copy SSIDs to APlist
  if ap_info_len > 0 then
  begin
    for i := 0 to ap_info_len-1 do
    begin
      APlist[i].SSID := PChar(@(ap_info[i].ssid[0]));
      APlist[i].RSSI := ap_info[i].rssi;
      writeln('AP #', i, ': ', APlist[i].SSID, ' (', APlist[i].RSSI, ' dB)');
    end;

    // Set remainder of list to empty strings
    if ap_info_len < APnum then
      for i := ap_info_len to APnum-1 do
        APlist[i].SSID := '';
  end
  else
    writeln('No AP records returned.');

  EspErrorCheck(esp_event_loop_delete_default(), 'esp_event_loop_delete_default');
  esp_wifi_stop();
  esp_wifi_deinit();
end;

function get_handler(req: Phttpd_req): Tesp_err;
var
  s: string[128];
  tmp: string[6];
  i: integer;
begin
  httpd_resp_send_chunk(req, apSelectPage1, length(apSelectPage1));

  i := 0;
  while (i < APnum) and (APlist[i].SSID <> '') do
  begin
    Str(APlist[i].RSSI, tmp);
    s := '<option value="'+APlist[i].SSID+'">'+APlist[i].SSID+
         ' ('+tmp+' dB)</option>';
    httpd_resp_send_chunk(req, @s[1], length(s));
    inc(i);
  end;

  httpd_resp_send_chunk(req, apSelectPage2, length(apSelectPage2));
  httpd_resp_send_chunk(req, nil, 0);

  result := ESP_OK;
end;

// Taken from fcl-base/src/uriparser.pp
function HexValue(c: Char): Integer;
begin
  case c of
    '0'..'9': Result := ord(c) - ord('0');
    'A'..'F': Result := ord(c) - (ord('A') - 10);
    'a'..'f': Result := ord(c) - (ord('a') - 10);
  else
    Result := 0;
  end;
end;

// Adapted from fcl-base/src/uriparser.pp
// added expansion of '+' to ' '
// Perform in place decoding
procedure urlDecode(var s: shortstring);
var
  i, decodedLen: Integer;
  P: PChar;
begin
  i := 1;
  P := PChar(@s[1]);
  decodedLen := 0;
  while i <= Length(s) do
  begin
    if s[i] = '%' then
    begin
      P[decodedLen] := Chr(HexValue(s[i + 1]) shl 4 or HexValue(s[i + 2]));
      Inc(i, 3);
    end
    else if s[i] = '+' then
    begin
      P[decodedLen] := ' ';
      Inc(i);
    end
    else
    begin
      P[decodedLen] := s[i];
      Inc(i);
    end;
    Inc(decodedLen);
  end;
  SetLength(s, decodedLen);
end;

// Handler should receive content: SSID=ssid_name&pwd=password
function post_handler(req: Phttpd_req): Tesp_err;
var
  size, ret: integer;
  buf: shortstring;
  decode: boolean;
begin
  reconnect := false;
  decode := false;

  // Inspect encoding of response
  FillChar(buf[1], high(buf), #0);
  if httpd_req_get_hdr_value_str(req, 'Content-Type', @buf[1], high(buf)) = ESP_OK then
  begin
    SetLength(buf, length(PChar(@buf[1])));
    decode := pos('x-www-form-urlencoded', buf) > 0;
  end
  else
  begin
    writeln('Content-Type not found.');
    decode := false;
  end;

  FillChar(buf[1], high(buf), #0);
  size := high(buf);
  ret := httpd_req_recv(req, @buf[1], size);
  if ret <= 0 then
  begin
    if ret = HTTPD_SOCK_ERR_TIMEOUT then
    {$ifdef CPULX6}
      httpd_resp_send_err(req, HTTPD_408_REQ_TIMEOUT, nil);
    {$else}
      httpd_resp_send_408(req);
    {$endif}
    exit(ESP_FAIL);
  end
  else
    SetLength(buf, ret);

  FillChar(tmpSSID[1], high(tmpSSID), #0);
  if httpd_query_key_value(@buf[1], 'SSID'#0, @tmpSSID[1], high(tmpSSID)) = ESP_OK then
  begin
    reconnect := true;
    SetLength(tmpSSID, length(PChar(@tmpSSID[1])));
    if decode then
      urlDecode(tmpSSID);
  end
  else
    writeln('Error reading SSID');

  if reconnect then
  begin
    FillChar(tmpPassword[1], high(tmpPassword), #0);
    if httpd_query_key_value(@buf[1], 'pwd'#0, @tmpPassword[1], high(tmpPassword)) = ESP_OK then
    begin
      SetLength(tmpPassword, length(PChar(@tmpPassword[1])));
      if decode then
        urlDecode(tmpPassword);
    end
    else
    begin
      writeln('Error reading pwd');
      reconnect := false;
    end;
  end;

  Result := httpd_resp_send_chunk(req, @apSelectedMsg[1], length(apSelectedMsg));
  Result := httpd_resp_send_chunk(req, @tmpSSID[1], length(tmpSSID));
  Result := httpd_resp_send_chunk(req, @apFinalMsg[1], length(apFinalMsg));
  Result := httpd_resp_send_chunk(req, nil, 0);
end;

function start_APserver: Thttpd_handle;
var
  config: Thttpd_config;
  getUriHandlerConfig: Thttpd_uri;
  postUriHandlerConfig: Thttpd_uri;
begin
  config := HTTPD_DEFAULT_CONFIG();
  with getUriHandlerConfig do
  begin
    uri       := '/';
    method    := HTTP_GET;
    handler   := @get_handler;
    user_ctx  := nil;
  end;

  with postUriHandlerConfig do
  begin
    uri       := '/login';
    method    := HTTP_POST;
    handler   := @post_handler;
    user_ctx  := nil;
  end;

  if (httpd_start(@server, @config) = ESP_OK) then
  begin
    httpd_register_uri_handler(server, @getUriHandlerConfig);
    httpd_register_uri_handler(server, @postUriHandlerConfig);
    result := server;
  end
  else
  begin
    result := nil;
    writeln('### Failed to start httpd');
  end;
end;

procedure stop_APserver;
begin
  if Assigned(server) then
  begin
    httpd_unregister_uri(server, '/');
    httpd_unregister_uri(server, '/login');
    httpd_stop(server);
    server := nil;
  end;
end;

procedure attachLoginToServer(AServer: Thttpd_handle);
var
  config: Thttpd_config;
  postUriHandlerConfig: Thttpd_uri;
begin
  with postUriHandlerConfig do
  begin
    uri       := '/login';
    method    := HTTP_POST;
    handler   := @post_handler;
    user_ctx  := nil;
  end;

  if assigned(AServer) then
    httpd_register_uri_handler(AServer, @postUriHandlerConfig)
  else
    writeln('### Failed to attach login handlers');
end;

end.

