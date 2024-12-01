unit dataunit;

interface

uses
  semphr;

var
  dataSem: TSemaphoreHandle;
  dataIndex: integer;
  currentLevel: integer;
  currentFlow: single;
  // History saved every minute
  // Buffers sized for 1440 points = 24 hours
  // Scale 6016 - 198 mm
  levels: array[0..1439] of uint32;
  // Scale 0 - 300 dL/min
  flows: array[0..1439] of uint32;

implementation

end.

