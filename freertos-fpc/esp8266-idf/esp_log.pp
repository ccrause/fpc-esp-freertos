unit esp_log;

interface

type
  Pesp_log_level = ^Tesp_log_level;
  Tesp_log_level = (ESP_LOG_NONE, ESP_LOG_ERROR, ESP_LOG_WARN,
    ESP_LOG_INFO, ESP_LOG_DEBUG, ESP_LOG_VERBOSE, ESP_LOG_MAX);

  Tputchar_like = function(ch: int32): int32; cdecl;

procedure esp_log_level_set(tag: PChar; level: Tesp_log_level); external;
function esp_log_set_putchar(func: Tputchar_like): Tputchar_like; external;

function esp_log_timestamp: uint32; external;
function esp_log_early_timestamp: uint32; external;

// In GCC the __attribute__ ((format (printf, 3, 4))) will instruct the compiler
// to typecheck formatting against printf style.
// This check will obviously not be done in FPC
// Perhaps preformat string and pass final string as format parameter below
procedure esp_log_write(level: Tesp_log_level; tag: PChar; format: PChar); cdecl; varargs; external;
procedure esp_early_log_write(level: Tesp_log_level; tag: PChar; format: PChar); cdecl; varargs; external;

implementation

end.
