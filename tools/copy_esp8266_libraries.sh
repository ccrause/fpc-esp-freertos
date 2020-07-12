#!/bin/bash
# script used to extract SDK libraries and other information into a libs folder
# script should be executed from root of example folder
# script assumes folder structure created by normal make
# To generate an example, copy one from inside the SDK, run make menuconfig, then run make
componentpath=$IDF_PATH8266/components
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
cp $buildpath/esp8266/esp8266.project.ld $destinationfolder
cp $buildpath/esp8266/esp8266_out.ld $destinationfolder

#Iterate over folders, skip bootloader & main, copy all .a files
echo "Copying all relevant library archives"
for f in $buildpath/*; do
  if [ -d "$f" ]; then
    case $f in
      "$buildpath/bootloader") echo "  skipping bootloader";;
      "$buildpath/esptool_py") echo "  skipping esptool_py";;
      "$buildpath/include") echo "  skipping include";;
      "$buildpath/main") echo "  skipping main";;
      "$buildpath/partition_table") echo "  skipping partition_table";;
      *) cp $f/lib$( basename $f).a $destinationfolder;;
    esac
  fi
done

# Now pull in IDF libraries
echo "Copying ESP8266 SDK libraries"
cp $componentpath/esp8266/lib/libgcc.a $destinationfolder
cp $componentpath/esp8266/lib/libhal.a $destinationfolder
cp $componentpath/esp8266/lib/libcore.a $destinationfolder
cp $componentpath/esp8266/lib/libnet80211.a $destinationfolder
cp $componentpath/esp8266/lib/libphy.a $destinationfolder
cp $componentpath/esp8266/lib/librtc.a $destinationfolder
cp $componentpath/esp8266/lib/libclk.a $destinationfolder
cp $componentpath/esp8266/lib/libpp.a $destinationfolder
cp $componentpath/esp8266/lib/libsmartconfig.a $destinationfolder
cp $componentpath/esp8266/lib/libssc.a $destinationfolder
cp $componentpath/esp8266/lib/libwpa.a $destinationfolder
cp $componentpath/esp8266/lib/libespnow.a $destinationfolder
cp $componentpath/esp8266/lib/libwps.a $destinationfolder
cp $componentpath/esp8266/lib/libwpa2.a $destinationfolder
echo "Copying newlib SDK libraries"
cp $componentpath/newlib/newlib/lib/libc.a $destinationfolder
cp $componentpath/newlib/newlib/lib/libc_fnano.a $destinationfolder
cp $componentpath/newlib/newlib/lib/libm.a $destinationfolder

