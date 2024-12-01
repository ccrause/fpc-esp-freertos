unit pinsconfig;

interface

uses
  pcnt;

{ Take note of following GPIO pins that impacts bootup and debugging on ESP32:
   0 - Bootstrap (pullup): 1 = SPI boot, 0 = download boot (if GPIO2 = 0)
   1 - Default serial over USB TX (idle high)
   2 - Bootstrap (pulldown): 0 = download boot (if GPIO0 = 0)
   3 - Default serial over USB RX (idle high)
   5 - Bootstrap (pullup): SDIO signal config
  12 - MTDI / Bootstrap (pulldown): 0 = 3.3V flash, 1 = 1.8V flash
  13 - MTCK
  14 - MTMS
  15 - MTDO / Bootstrap (pullup): SDIO signal config
  34-39 - Only input or RTC/analog functionality, no digital output
}

const
  levelSensorUart = 2;
  levelSensorTxPin = 26;
  levelSensorRxPin = 27;

  flowSensorCounterUnit = PCNT_UNIT_0;
  flowSensorPulsePin = 13;  // Interferes with JTAG debugging

  pumpOutputPin = 2;  // Also onboard LED, high when pump should be on
  lowLevelPin = 17;   // Pin is high when level is low

implementation

end.

