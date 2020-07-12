#!/bin/bash
# script used to extract SDK libraries and other information into a libs folder
# script should be executed from root of example folder
# script assumes folder structure created by normal make
# To generate an example, copy one from inside the SDK, run make menuconfig, then run make
componentpath=$IDF_PATH/components
basepath=$(dirname $(readlink -f $0))
buildpath=$basepath/build
destinationfolder=$basepath/libs

if [ -d "$destinationfolder" ]; then
  echo "Removing existing folder "$destinationfolder
  rm -r $destinationfolder
fi
mkdir $destinationfolder

#Copy special files across
echo "Processing " $buildpath"/*"
echo "Copy partition"
cp $buildpath/partitions_singleapp.bin $destinationfolder
echo "Copy bootloader.bin"
cp $buildpath/bootloader/bootloader.bin $destinationfolder
echo "Copy sdkconfig"
cp $buildpath/include/sdkconfig.h $destinationfolder
cp $buildpath/../sdkconfig $destinationfolder
echo "Copy linker scripts"
cp $buildpath/esp32/esp32.project.ld $destinationfolder
cp $buildpath/esp32/esp32_out.ld $destinationfolder

#Iterate over folders, skip bootloader & main, copy all .a files
echo "Copying all relevant library archives"
for f in $buildpath/*; do
  if [ -d "$f" ]; then
    case $f in
      "$buildpath/bootloader") echo "Skipping bootloader";;
      "$buildpath/esptool_py") echo "Skipping esptool_py";;
      "$buildpath/include") echo "Skipping include";;
      "$buildpath/main") echo "Skipping main";;
      "$buildpath/partition_table") echo "Skipping partition_table";;
      *) cp $f/lib$( basename $f).a $destinationfolder;;
    esac
  fi
done

# Now pull in IDF libraries
echo "Copying ESP32 HAL"
cp $componentpath/xtensa/esp32/libhal.a $destinationfolder
echo "Copying ESP32 WiFi libraries"
cp $componentpath/esp_wifi/lib/esp32/*.a $destinationfolder

