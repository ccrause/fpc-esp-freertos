unit readadc;

interface

uses
  adc, adc_types, esp_adc_cal, task;

const
  ADC1InputChannels: array[0..5] of integer = (0, 3, 6, 7, 4, 5);
  ADC2InputChannels: array[0..3] of integer = (8, 9, 7, 6);
  totalADCChannels = length(ADC1InputChannels) + length(ADC2InputChannels);

var
  //InputsCriticalSection: TRTLCriticalSection;
  // ADC input values in mV
  inputs: array[0..length(ADC1InputChannels)+length(ADC2InputChannels)-1] of integer;

procedure startAdcThread;

implementation

uses
  portmacro, shared;

const
  // Offset into inputs array where ADC2 channels start
  ADC2InputOffset = length(ADC1InputChannels);
  // Default reference voltage to use if no calibration values stored in EFUSE
  DEFAULT_VREF   = 1100;        // Used in case no calibration values are stored in EFUSE
  MAX_ATTENUATION  = ADC_ATTEN_DB_11; // Input is 200 - ~2500 mV, 11dB gives max input of 2600 mV
  SampleBitWidth = ADC_WIDTH_BIT_12;
var
  adc1_chars, adc2_chars: Tesp_adc_cal_characteristics;

procedure initADC;
var
  i: integer;
begin
  adc1_config_width(SampleBitWidth);
  for i := 0 to length(ADC1InputChannels)-1 do
    adc1_config_channel_atten(Tadc1_channel(ADC1InputChannels[i]), MAX_ATTENUATION);
  esp_adc_cal_characterize(ADC_UNIT_1, MAX_ATTENUATION, SampleBitWidth, DEFAULT_VREF, @adc1_chars);

  for i := 0 to length(ADC2InputChannels)-1 do
    adc2_config_channel_atten(Tadc2_channel(ADC2InputChannels[i]), MAX_ATTENUATION);
  esp_adc_cal_characterize(ADC_UNIT_2, MAX_ATTENUATION, SampleBitWidth, DEFAULT_VREF, @adc2_chars);
end;

function ADCThread(parameter : pointer) : ptrint; noreturn;
const
  avgCount = 16;
var
  i, j, chan, val, tmp: integer;
begin
  initADC;

  repeat
    for i := 0 to length(ADC1InputChannels)-1 do
    begin
      chan := ADC1InputChannels[i];
      val := 0;
      for j := 1 to avgCount do
        val := val + adc1_get_raw(Tadc1_channel(chan));
      val := val div avgCount;

      tmp := esp_adc_cal_raw_to_voltage(val, @adc1_chars);
      inputs[i] := (inputs[i] + tmp) div 2;
      //inputs[i] := tmp;
      // Give other tasks some breathing room
      vTaskDelay(1);
    end;

    for i := 0 to length(ADC2InputChannels)-1 do
    begin
      chan := ADC2InputChannels[i];
      val := 0;
      for j := 1 to avgCount do
      begin
        adc2_get_raw(Tadc2_channel(chan), SampleBitWidth, @tmp);
        val := val + tmp;
      end;
      val := val div avgCount;

      tmp := esp_adc_cal_raw_to_voltage(val, @adc2_chars);
      inputs[i+ADC2InputOffset] := (inputs[i+ADC2InputOffset] + tmp) div 2;
      //inputs[i+ADC2InputOffset] := tmp;
      // Give other tasks some breathing room
      vTaskDelay(1);
    end;

    Sleep(100);
  until false;
end;

procedure startAdcThread;
var
  threadID: TThreadID;
begin
  BeginThread(@ADCThread,      // thread to launch
             nil,              // pointer parameter to be passed to thread function
             threadID,         // new thread ID, not used further
             1024);            // stacksize
end;

end.

