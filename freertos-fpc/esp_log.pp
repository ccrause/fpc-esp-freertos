unit esp_log;

interface

type
  Pesp_log_level_t = ^Tesp_log_level_t;
  Tesp_log_level_t = (ESP_LOG_NONE, ESP_LOG_ERROR, ESP_LOG_WARN,
    ESP_LOG_INFO, ESP_LOG_DEBUG, ESP_LOG_VERBOSE);

  Tvprintf_like_t = function(msg: PChar): longint; cdecl; varargs;

procedure esp_log_level_set(tag: PChar; level: Tesp_log_level_t); cdecl; external;
function esp_log_set_vprintf(func: Tvprintf_like_t): Tvprintf_like_t; cdecl; external;
function esp_log_timestamp: uint32; cdecl; external;
function esp_log_system_timestamp: PChar; cdecl; external;
function esp_log_early_timestamp: uint32; cdecl; external;


// In GCC the __attribute__ ((format (printf, 3, 4))) will instruct the compiler
// to typecheck formatting against printf style.
// This check will obviously not be done in FPC
// Perhaps preformat string and pass final string as format parameter below
procedure esp_log_write(level: Tesp_log_level_t; tag: PChar; format: PChar); cdecl; varargs; external;

//procedure esp_log_writev(level: Tesp_log_level_t; tag: PChar; format: PChar;
//  args: Tva_list); cdecl; external;

{.$include "esp_log_internal.h"}
{$ifndef LOG_LOCAL_LEVEL}
{$ifndef BOOTLOADER_BUILD}
//const
//  LOG_LOCAL_LEVEL = CONFIG_LOG_DEFAULT_LEVEL;
{$else}
//const
//  LOG_LOCAL_LEVEL = CONFIG_BOOTLOADER_LOG_LEVEL;
{$endif}
{$endif}


{$ifdef CONFIG_LOG_COLORS}
const
  LOG_COLOR_BLACK = '30';
  LOG_COLOR_RED = '31';
  LOG_COLOR_GREEN = '32';
  LOG_COLOR_BROWN = '33';
  LOG_COLOR_BLUE = '34';
  LOG_COLOR_PURPLE = '35';
  LOG_COLOR_CYAN = '36';
{$endif}

implementation

end.
