
unit esp_flash_data_types;
interface

{
  Automatically converted by H2Pas 1.0.0 from /home/christo/fpc/xtensa/freertos-fpc/esp-idf/esp_flash_data_types.tmp.h
  The following command line parameters were used:
    -c
    -p
    -s
    -t
    -T
    -d
    -o
    /home/christo/fpc/xtensa/freertos-fpc/esp-idf/esp_flash_data_types.pp
    /home/christo/fpc/xtensa/freertos-fpc/esp-idf/esp_flash_data_types.tmp.h
}

{ Pointers to basic pascal types, inserted by h2pas conversion program.}
Type
  PLongint  = ^Longint;
  PSmallInt = ^SmallInt;
  PByte     = ^Byte;
  PWord     = ^Word;
  PDWord    = ^DWord;
  PDouble   = ^Double;

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


(* error 
#warning esp_flash_data_types.h has been merged into esp_flash_partitions.h, please include esp_flash_partitions.h instead
(* error 
#warning esp_flash_data_types.h has been merged into esp_flash_partitions.h, please include esp_flash_partitions.h instead
{$include "esp_flash_partitions.h"}

implementation


end.
