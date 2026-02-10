unit bmp085_180;

// This unit interfaces with the Bosch BMP085 & BMP180 sensors over I2C.

interface

uses
  i2c_obj;

type
  TOverSampling = (os1 = 0, os2, os4, os8);

  { TBMPxxx }

  TBMPxxx = object
    public
    // Provide an already configured I2C object, then load calibration constants
    // Return false on any error
    function init(i2c_master: TI2cMaster): boolean;
    procedure setOverSampling(oversampling: TOverSampling);

    // Return temperature in decidegrees Celsius, or Celsius*10
    // and pressure in Pascal
    // This function sets the oversampling parameter to its lowest value (oss = 0)
    // to simplify the code a little bit.
    function readTP(out T: int32; out P: uint32): boolean;

    // Reads ID of sensor ($55 for BMP085/180)
    // Returns false on error
    function readID(out ID: byte): boolean;
  private
    fi2c_master: TI2CMaster;
    oss: byte;
end;

implementation

{$include freertosconfig.inc}

uses
  esp_err, task;

type
  TCalibrationConsts = record
    case boolean of
      true : (values: array[0..10] of uint16;);
      false: (AC1, AC2, AC3: int16;
              AC4, AC5, AC6: uint16;
              B1, B2, MB, MC, MD: int16;);
  end;

const
  BMPxxxAddr = $77 shl 1;  // Left adjusted address of BMP085/180 pressure sensor
  BMP_ID_Addr = $D0;       // Device identifier, $55 for BMP080/180
  BMPCalAddrStart = $AA;   // Starting address of calibration coefficients
  BMPControlAddr = $F4;    // Control register for conversion measurements
  BMPOutMsbAddr = $F6;     // Starting address of measurement value

  BMPMeasureT = $2E;       // Initiate temperature conversion
  BMPMeasureP = $34;       // Initiate pressure conversion
  BMPossShift = 6;         // Shift posisition for oss setting in BMPControlAddr register

var
  consts: TCalibrationConsts;

// Initialize I2C and load sensor specific calibration constants
function TBMPxxx.init(i2c_master: TI2cMaster): boolean;
var
  i: byte;
  buf: array[0..1] of byte;
begin
  Result := false;
  fi2c_master := i2c_master;
  i := 0;
  while i < length(consts.values) do
  begin
    if i2c_master.ReadBytesFromReg(BMPxxxAddr, byte(BMPCalAddrStart + 2*i), @buf[0], 2) <> ESP_OK then
      exit;

    consts.values[i] := (uint16(buf[0]) shl 8) or buf[1];
    inc(i);
  end;
  Result := true;
end;

procedure TBMPxxx.setOverSampling(oversampling: TOverSampling);
begin
  oss := ord(oversampling);
end;

// Return temperature in decidegrees Celsius, or Celsius*10
// and pressure in Pascal
// This function sets the oversampling parameter to its lowest value (oss = 0)
// to simplify the code a little bit.
function TBMPxxx.readTP(out T: int32; out P: uint32): boolean;
const
  ossConversionTime_ms: array[0..3] of integer = (5, 8, 14, 26);
var
  UT, UP: int32;
  buf: array[0..2] of byte;
  X1, X2, X3, B3, B5, B6: int32;
  B4, B7: uint32;
begin
  Result := false;

  // Request temperature measurement
  if fi2c_master.WriteByteToReg(BMPxxxAddr, BMPControlAddr, BMPMeasureT) <> ESP_OK then exit;
  vTaskDelay(1);
  // Read uncompensated temperature
  if fi2c_master.ReadBytesFromReg(BMPxxxAddr, BMPOutMsbAddr, @buf[0], 2) <> ESP_OK then exit;
  UT := int32((word(buf[0]) shl 8) or buf[1]);
  X1 := (int32(UT - consts.AC6)*consts.AC5) div (1024*2*16);
  X2 := (int32(consts.MC) shl 11) div (X1 + int32(consts.MD));
  B5 := X1 + X2;
  T := int32(B5 + 8) div 16;

  // Request pressure measurement
  if fi2c_master.WriteByteToReg(BMPxxxAddr, BMPControlAddr, BMPMeasureP or byte(oss shl BMPossShift)) <> ESP_OK then exit;

  vTaskDelay((ossConversionTime_ms[oss] + (1000 div CONFIG_FREERTOS_HZ) div 2) div (1000 div CONFIG_FREERTOS_HZ));
  // Note: extended bits XLSB not used when oversampling = 0
  if fi2c_master.ReadBytesFromReg(BMPxxxAddr, BMPOutMsbAddr, @buf[0], 3) <> ESP_OK then exit;
  UP := ((uint32(buf[0]) shl 16) or (uint32(buf[1]) shl 8) or buf[2]) shr (8 - oss);

  B6 := B5 - 4000;
  X1 := (consts.B2 * ((B6*B6) shr 12)) div 2048;
  X2 := int32(consts.AC2 * B6) div 2048;
  X3 := X1 + X2;
  B3 := (((int32(consts.AC1)*4 + X3) shl oss) + 2) div 4;

  X1 := int32(consts.AC3*B6) div (8*1024);
  X2 := (consts.B1 * ((B6*B6) shr 12)) div (256*256);
  X3 := (X1 + X2 + 2) div 4;
  B4 := (consts.AC4 * (uint32(X3) + 32768)) shr 15;
  B7 := uint32(int32(UP) - B3) * uint32(50000 shr oss);

  if B7 < $80000000 then
    P := (B7*2) div B4
  else
    P := (B7 div B4) * 2;

  X1 := (P shr 8) * (P shr 8);
  X1 := (X1*3038) shr 16; //div (256*256);
  X2 := (-7357 * int32(P)) div (256*256);

  P := int32(P) + ((X1 + X2 + 3791) div 16);
  Result := true;
end;

function TBMPxxx.readID(out ID: byte): boolean;
begin
  Result := fi2c_master.ReadByteFromReg(BMPxxxAddr, BMP_ID_Addr, ID) = ESP_OK;
end;

end.

