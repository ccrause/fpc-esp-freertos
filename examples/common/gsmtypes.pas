unit gsmtypes;

{ Types used to indicate status of certain states or information.
  Typically returned as string values, so return result as enum type
  to save memory. }

interface

type
  TBatteryChargeMode = (bcmNotCharging, bcmCharging, bcmChargingFinished);

  TSimStatus = (ssError, ssReady, ssSimPin, ssSimPuk,
    ssPhoneSimPin, ssPhoneSimPuk, ssSimPin2, ssSimPuk2);


implementation

end.

