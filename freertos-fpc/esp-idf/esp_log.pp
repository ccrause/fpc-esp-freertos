unit esp_log;

{$include sdkconfig.inc}

interface

type
  Pesp_log_level = ^Tesp_log_level;
  Tesp_log_level = (ESP_LOG_NONE, ESP_LOG_ERROR, ESP_LOG_WARN,
    ESP_LOG_INFO, ESP_LOG_DEBUG, ESP_LOG_VERBOSE);

  Tvprintf_like = function(msg: PChar): longint; varargs;

procedure esp_log_level_set(tag: PChar; level: Tesp_log_level); external;
function esp_log_set_vprintf(func: Tvprintf_like): Tvprintf_like; external;
function esp_log_timestamp: uint32; external;
function esp_log_system_timestamp: PChar; external;
function esp_log_early_timestamp: uint32; external;

// In GCC the __attribute__ ((format (printf, 3, 4))) will instruct the compiler
// to typecheck formatting against printf style.
// This check will obviously not be done in FPC
// Perhaps preformat string and pass final string as format parameter below
procedure esp_log_write(level: Tesp_log_level; tag: PChar; format: PChar); varargs; external;

//procedure esp_log_writev(level: Tesp_log_level_t; tag: PChar; format: PChar;
//  args: Tva_list); external;

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
