# Examples
Some elementary examples demonstrating aspects of FreeRTOS + ESP-IDF. Refer to each folder for details.  These examples are mostly adapted from ESP-IDF examples.

# Flashing example project to board
## ESP8266
The first time flashing a project from this library to a board, update the bootloader and partition table:
~/fpcupdeluxe/working/cross/bin/xtensa-freertos/esp-rtos-3.4/components/esptool_py/esptool/esptool.py --chip esp8266 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 1MB 0x0 ~/fpcupdeluxe/working/cross/lib/xtensa-freertos/lx106/bootloader.bin 0x8000 ~/fpcupdeluxe/working/cross/lib/xtensa-freertos/lx106/partitions_singleapp.bin 

Subsequently the binary image for the project can be flashed:
~/fpcupdeluxe/working/cross/bin/xtensa-freertos/esp-rtos-3.4/components/esptool_py/esptool/esptool.py --chip esp8266 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 1MB 0x10000 blink.bin 

## ESP32
The first time flashing a project from this library to a board, update the bootloader and partition table:
~/fpcupdeluxe/working/cross/bin/xtensa-freertos/esp-idf-4.3.2/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 4MB 0x0 ~/fpcupdeluxe/working/cross/lib/xtensa-freertos/lx6/bootloader.bin 0x8000 ~/fpcupdeluxe/working/cross/lib/xtensa-freertos/lx6/partitions_singleapp.bin 

Subsequently the binary image for the project can be flashed:
~/fpcupdeluxe/working/cross/bin/xtensa-freertos/esp-idf-4.3.2/components/esptool_py/esptool/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dout --flash_freq 40m --flash_size 4MB 0x10000 blink.bin  

In some cases the serial upload speed can be increased to a baud rate of 921600 or possibly even higher.

