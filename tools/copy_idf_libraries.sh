#!/bin/bash
# script used to extract SDK libraries and other information into a libs folder
#
# Run from a terminal where the necessary source command was executed so tht IDF_PATH and path to tools is configured ($ . path_to_esp-idf/export.sh)
# This script should be executed from the root of the example folder (copy the hello_world example from the esp-idf/examples/get-started/hello_world).
# Pass the controller name as parameter to the script (e.g. $ sh copy_idf_libraries.sh esp32c3)
# This script assumes the folder structure as created by $ idf.py build
# 
# To build the example, run idf.py set-target esp32c3 to select a controller, then run idf.py menuconfig, then run idf.py build

controller=$1

if [ -z ${controller} ]; then
  echo "Please specify a controller name"
  exit
fi 

if [ -z ${IDF_PATH+x} ]; then
  echo "IDF_PATH not set, please run $ . path_to_esp-idf/export.sh to configure build environment"
  exit
fi

componentpath=$IDF_PATH/components
basepath=$(pwd)
buildpath=$basepath/build
destinationpath=$basepath/esp-idf-v5.5

scriptpath=$(dirname "$0")

if [ -d "$destinationpath" ]; then
  echo "Removing existing folder "$destinationpath
  rm -r $destinationpath
fi
mkdir $destinationpath
mkdir $destinationpath/libs
mkdir $destinationpath/libs/$controller
mkdir $destinationpath/components
mkdir $destinationpath/tools

#Copy special files across
echo "Processing " $buildpath"/*"
echo "Copy partition"
cp $buildpath/partition_table/partition*.bin $destinationpath/libs/
echo "Copy bootloader.bin"
cp $buildpath/bootloader/bootloader.bin $destinationpath/libs/$controller
echo "Copy sdkconfig"
cp $basepath/sdkconfig $destinationpath/libs/$controller
cp $buildpath/config/sdkconfig.h $destinationpath/libs/$controller
echo "Copy linker scripts"
cp $buildpath/esp-idf/esp_system/ld/memory.ld $destinationpath/libs/$controller
cp $buildpath/esp-idf/esp_system/ld/sections.ld $destinationpath/libs/$controller

#Iterate over folders, skip bootloader & main, copy all .a files
echo "Copying all relevant library archives"
for f in $buildpath/esp-idf/*; do
  if [ -d "$f" ]; then
    case $f in
      "$buildpath/esp-idf/bootloader") echo "Skipping bootloader";;
      "$buildpath/esp-idf/CMakeFiles") echo "Skipping CMakeFiles";;
      "$buildpath/esp-idf/$controller") echo "Skipping $controller";;
      "$buildpath/esp-idf/esptool_py") echo "Skipping esptool_py";;
      "$buildpath/esp-idf/idf_test") echo "Skipping idf_test";;
      "$buildpath/esp-idf/ieee802154") echo "Skipping ieee802154";;
      "$buildpath/esp-idf/include") echo "Skipping include";;
      "$buildpath/esp-idf/main") echo "Skipping main";;
      "$buildpath/esp-idf/mbedtls") echo "Skipping mbedtls";;
      "$buildpath/esp-idf/partition_table") echo "Skipping partition_table";;
      *) cp $f/lib$( basename $f).a $destinationpath/libs/$controller;;
    esac
  fi
done

echo "Copying mbedtls libraries"
cp $buildpath/esp-idf/mbedtls/mbedtls/library/*.a $destinationpath/libs/$controller/
cp $buildpath/esp-idf/mbedtls/mbedtls/3rdparty/*/*.a $destinationpath/libs/$controller/

echo "Copying xtensa HAL library"
cp $componentpath/xtensa/$controller/libxt_hal.a $destinationpath/libs/$controller
echo "Copying $controller WiFi libraries"
cp $componentpath/esp_wifi/lib/$controller/*.a $destinationpath/libs/$controller
echo "Copying esp_phy libraries"
cp $componentpath/esp_phy/lib/$controller/*.a $destinationpath/libs/$controller

echo "Copy config details"
cd $componentpath
for pattern in '[kK]config*' '*.lf' '*.info' '*.ld' '*.in' ; do
  find . -type f -name "$pattern" | while read file ; do
    mkdir -p  $destinationpath/components/$(dirname $file) #2>/dev/null
    cp $file $destinationpath/components/$file
  done
done

echo "Copying ld.common"
cp $componentpath/esp_system/ld/ld.common  $destinationpath/components/esp_system/ld/

echo "Copying esptool.py"
cp -r $componentpath/esptool_py  $destinationpath/components/

echo "Copying tools"
cd $IDF_PATH/tools
cp -r .  $destinationpath/tools/

echo "Copying root"
cd $IDF_PATH
cp  Kconfig $destinationpath/

echo "Creating sdkconfig.inc"
cd $destinationpath/libs/$controller
sh $scriptpath/conf2inc.sh

cd $basepath
echo "Done"

