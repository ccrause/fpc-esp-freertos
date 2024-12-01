unit rtc_wdt;

interface

{$linklib esp_hw_support, static}

uses
  esp_err, portmacro;

type
  Prtc_wdt_stage = ^Trtc_wdt_stage;
  Trtc_wdt_stage = (
    RTC_WDT_STAGE0 := 0,
    RTC_WDT_STAGE1 := 1,
    RTC_WDT_STAGE2 := 2,
    RTC_WDT_STAGE3 := 3);

  // Actual values declared in controller/soc/include/rtc_cntl_reg.h
  // Not defined for esp32s3?
  Prtc_wdt_stage_action = ^Trtc_wdt_stage_action;
  Trtc_wdt_stage_action = (
    RTC_WDT_STAGE_ACTION_OFF          := 0, // RTC_WDT_STG_SEL_OFF,
    RTC_WDT_STAGE_ACTION_INTERRUPT    := 1, // RTC_WDT_STG_SEL_INT,
    RTC_WDT_STAGE_ACTION_RESET_CPU    := 2, // RTC_WDT_STG_SEL_RESET_CPU,
    RTC_WDT_STAGE_ACTION_RESET_SYSTEM := 3, // RTC_WDT_STG_SEL_RESET_SYSTEM,
    RTC_WDT_STAGE_ACTION_RESET_RTC    := 4); // RTC_WDT_STG_SEL_RESET_RTC);

  Prtc_wdt_reset_sig = ^Trtc_wdt_reset_sig;
  Trtc_wdt_reset_sig = (
    RTC_WDT_SYS_RESET_SIG := 0,
    RTC_WDT_CPU_RESET_SIG := 1);


  Prtc_wdt_length_sig = ^Trtc_wdt_length_sig;
  Trtc_wdt_length_sig = (
    RTC_WDT_LENGTH_100ns := 0,
    RTC_WDT_LENGTH_200ns := 1,
    RTC_WDT_LENGTH_300ns := 2,
    RTC_WDT_LENGTH_400ns := 3,
    RTC_WDT_LENGTH_500ns := 4,
    RTC_WDT_LENGTH_800ns := 5,
    RTC_WDT_LENGTH_1_6us := 6,
    RTC_WDT_LENGTH_3_2us := 7);

function rtc_wdt_get_protect_status: Tbool; external;
procedure rtc_wdt_protect_on; external;
procedure rtc_wdt_protect_off; external;
procedure rtc_wdt_enable; external;
procedure rtc_wdt_flashboot_mode_enable; external;
procedure rtc_wdt_disable; external;
procedure rtc_wdt_feed; external;
function rtc_wdt_set_time(stage: Trtc_wdt_stage; timeout_ms: dword): Tesp_err; external;
function rtc_wdt_get_timeout(stage: Trtc_wdt_stage; timeout_ms: Pdword): Tesp_err; external;

function rtc_wdt_set_stage(stage: Trtc_wdt_stage;
  stage_sel: Trtc_wdt_stage_action): Tesp_err; external;

function rtc_wdt_set_length_of_reset_signal(reset_src: Trtc_wdt_reset_sig;
  reset_signal_length: Trtc_wdt_length_sig): Tesp_err; external;

function rtc_wdt_is_on: Tbool; external;

implementation

end.
