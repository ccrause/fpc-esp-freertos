unit esp_err;

interface

type
  Pesp_err_t = ^Tesp_err_t;
  Tesp_err_t = int32;
  Tsize_t = int32;

const
  ESP_OK = 0;
  ESP_FAIL = -(1);
  ESP_ERR_NO_MEM = $101;
  ESP_ERR_INVALID_ARG = $102;
  ESP_ERR_INVALID_STATE = $103;
  ESP_ERR_INVALID_SIZE = $104;
  ESP_ERR_NOT_FOUND = $105;
  ESP_ERR_NOT_SUPPORTED = $106;
  ESP_ERR_TIMEOUT = $107;
  ESP_ERR_INVALID_RESPONSE = $108;
  ESP_ERR_INVALID_CRC = $109;
  ESP_ERR_INVALID_VERSION = $10A;
  ESP_ERR_INVALID_MAC = $10B;
  ESP_ERR_WIFI_BASE = $3000;
  ESP_ERR_MESH_BASE = $4000;
  ESP_ERR_FLASH_BASE = $6000;

function esp_err_to_name(code: Tesp_err_t): PChar; cdecl; external;

function esp_err_to_name_r(code: Tesp_err_t; buf: PChar; buflen: Tsize_t): PChar;
  cdecl; external;

procedure _esp_error_check_failed(rc: Tesp_err_t; afile: PChar; line: integer; afunction: PChar; expression: PChar); cdecl; external; noreturn;

procedure _esp_error_check_failed_without_abort(rc: Tesp_err_t;
  afile: PChar; line: int32; _function: PChar; expression: PChar); cdecl; external;

procedure EspErrorCheck(code: longint);

implementation

// Non-aborting version, just print an error message
procedure EspErrorCheck(code: longint);
begin
  if not(code = ESP_OK) then
  begin
    writeln('Error: ', esp_err_to_name(code));
  end;
end;

end.
