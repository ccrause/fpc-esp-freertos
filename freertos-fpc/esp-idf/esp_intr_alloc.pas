unit esp_intr_alloc;

interface

uses
  esp_err, portmacro;

const
  ESP_INTR_FLAG_LEVEL1 = 1 shl 1;
  ESP_INTR_FLAG_LEVEL2 = 1 shl 2;
  ESP_INTR_FLAG_LEVEL3 = 1 shl 3;
  ESP_INTR_FLAG_LEVEL4 = 1 shl 4;
  ESP_INTR_FLAG_LEVEL5 = 1 shl 5;
  ESP_INTR_FLAG_LEVEL6 = 1 shl 6;
  ESP_INTR_FLAG_NMI = 1 shl 7;
  ESP_INTR_FLAG_SHARED = 1 shl 8;
  ESP_INTR_FLAG_EDGE = 1 shl 9;
  ESP_INTR_FLAG_IRAM = 1 shl 10;
  ESP_INTR_FLAG_INTRDISABLED = 1 shl 11;
  ESP_INTR_FLAG_LOWMED = (ESP_INTR_FLAG_LEVEL1 or ESP_INTR_FLAG_LEVEL2) or
    ESP_INTR_FLAG_LEVEL3;
  ESP_INTR_FLAG_HIGH = ((ESP_INTR_FLAG_LEVEL4 or ESP_INTR_FLAG_LEVEL5) or
    ESP_INTR_FLAG_LEVEL6) or ESP_INTR_FLAG_NMI;
  ESP_INTR_FLAG_LEVELMASK =
    (((((ESP_INTR_FLAG_LEVEL1 or ESP_INTR_FLAG_LEVEL2) or ESP_INTR_FLAG_LEVEL3) or
    ESP_INTR_FLAG_LEVEL4) or ESP_INTR_FLAG_LEVEL5) or ESP_INTR_FLAG_LEVEL6) or
    ESP_INTR_FLAG_NMI;

  ETS_INTERNAL_TIMER0_INTR_SOURCE = -(1);
  ETS_INTERNAL_TIMER1_INTR_SOURCE = -(2);
  ETS_INTERNAL_TIMER2_INTR_SOURCE = -(3);
  ETS_INTERNAL_SW0_INTR_SOURCE = -(4);
  ETS_INTERNAL_SW1_INTR_SOURCE = -(5);
  ETS_INTERNAL_PROFILING_INTR_SOURCE = -(6);
  ETS_INTERNAL_INTR_SOURCE_OFF = -(ETS_INTERNAL_PROFILING_INTR_SOURCE);

type
  Tintr_handler = procedure(arg: pointer);
  Tintr_handle_data = record end;
  Pintr_handle_data = ^Tintr_handle_data;
  Tintr_handle = Pintr_handle_data;
  Pintr_handle = ^Tintr_handle;

function esp_intr_mark_shared(intno: longint; cpu: longint;
  is_in_iram: Tbool): Tesp_err; external;
function esp_intr_reserve(intno: longint; cpu: longint): Tesp_err; external;
function esp_intr_alloc(Source: longint; flags: longint; handler: Tintr_handler;
  arg: pointer; ret_handle: Pintr_handle): Tesp_err; external;
function esp_intr_alloc_intrstatus(Source: longint; flags: longint;
  intrstatusreg: uint32; intrstatusmask: uint32; handler: Tintr_handler;
  arg: pointer; ret_handle: Pintr_handle): Tesp_err; external;
function esp_intr_free(handle: Tintr_handle): Tesp_err; external;
function esp_intr_get_cpu(handle: Tintr_handle): longint; external;
function esp_intr_get_intno(handle: Tintr_handle): longint; external;
function esp_intr_disable(handle: Tintr_handle): Tesp_err; external;
function esp_intr_enable(handle: Tintr_handle): Tesp_err; external;
function esp_intr_set_in_iram(handle: Tintr_handle; is_in_iram: Tbool): Tesp_err;
  external;
procedure esp_intr_noniram_disable; external;
procedure esp_intr_noniram_enable; external;
procedure esp_intr_enable_source(inum: longint); external;
procedure esp_intr_disable_source(inum: longint); external;

implementation

end.
