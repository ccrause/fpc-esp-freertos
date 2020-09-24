unit esp_sleep;

interface

uses
  esp_err, gpio_types;

type
  Pesp_sleep_ext1_wakeup_mode = ^Tesp_sleep_ext1_wakeup_mode;
  Tesp_sleep_ext1_wakeup_mode = (ESP_EXT1_WAKEUP_ALL_LOW =
    0, ESP_EXT1_WAKEUP_ANY_HIGH = 1);

  Pesp_sleep_pd_domain = ^Tesp_sleep_pd_domain;
  Tesp_sleep_pd_domain = (ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_DOMAIN_RTC_SLOW_MEM,
    ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_DOMAIN_XTAL,
    ESP_PD_DOMAIN_MAX);

  Pesp_sleep_pd_option = ^Tesp_sleep_pd_option;
  Tesp_sleep_pd_option = (ESP_PD_OPTION_OFF, ESP_PD_OPTION_ON, ESP_PD_OPTION_AUTO);

  Pesp_sleep_source = ^Tesp_sleep_source;
  Tesp_sleep_source = (ESP_SLEEP_WAKEUP_UNDEFINED, ESP_SLEEP_WAKEUP_ALL,
    ESP_SLEEP_WAKEUP_EXT0, ESP_SLEEP_WAKEUP_EXT1,
    ESP_SLEEP_WAKEUP_TIMER, ESP_SLEEP_WAKEUP_TOUCHPAD,
    ESP_SLEEP_WAKEUP_ULP, ESP_SLEEP_WAKEUP_GPIO,
    ESP_SLEEP_WAKEUP_UART);

  Pesp_sleep_wakeup_cause = ^Tesp_sleep_wakeup_cause;
  Tesp_sleep_wakeup_cause = Tesp_sleep_source;

function esp_sleep_disable_wakeup_source(Source: Tesp_sleep_source): Tesp_err; external;
function esp_sleep_enable_ulp_wakeup: Tesp_err; external;
function esp_sleep_enable_timer_wakeup(time_in_us: uint64): Tesp_err; external;
function esp_sleep_enable_touchpad_wakeup: Tesp_err; external;
function esp_sleep_get_touchpad_wakeup_status: int32; external; // touch_pad_t is an enum with pad numbers defined in driver/touch_pad.h
function esp_sleep_enable_ext0_wakeup(gpio_num: Tgpio_num;
  level: longint): Tesp_err; external;
function esp_sleep_enable_ext1_wakeup(mask: uint64;
  mode: Tesp_sleep_ext1_wakeup_mode): Tesp_err; external;
function esp_sleep_enable_gpio_wakeup: Tesp_err; external;
function esp_sleep_enable_uart_wakeup(uart_num: longint): Tesp_err; external;
function esp_sleep_get_ext1_wakeup_status: uint64; external;
function esp_sleep_pd_config(domain: Tesp_sleep_pd_domain;
  option: Tesp_sleep_pd_option): Tesp_err; external;
procedure esp_deep_sleep_start; external; noreturn;
function esp_light_sleep_start: Tesp_err; external;
procedure esp_deep_sleep(time_in_us: uint64); external; noreturn;
function esp_sleep_get_wakeup_cause: Tesp_sleep_wakeup_cause; external;
procedure esp_wake_deep_sleep; external;

type
  Tesp_deep_sleep_wake_stub_fn = procedure(para1: pointer);

procedure esp_set_deep_sleep_wake_stub(new_stub: Tesp_deep_sleep_wake_stub_fn);  external;
function esp_get_deep_sleep_wake_stub: Tesp_deep_sleep_wake_stub_fn; external;
procedure esp_default_wake_deep_sleep; external;
procedure esp_deep_sleep_disable_rom_logging; external;

implementation

end.
