# fpc-esp-freertos
This project is for creating bindings to the [ESP-IDF](https://github.com/espressif/esp-idf) project
of Espressif for [Free Pascal](https://www.freepascal.org/).  This project is targeting bindings for [version 4.1](https://github.com/espressif/esp-idf/tree/release/v4.1) of 
the ESP-IDF, the latest release candidate when the project started.  Since this is a work in progress the ESP-IDF version targeted will 
be fixed at 4.1 for now.

Support for the ESP8266_RTOS_SDK [version 3.3](https://github.com/espressif/ESP8266_RTOS_SDK/tree/release/v3.3) is also being added. At the moment there is very little shared code between the two SDK's.

## Over the air updates (OTA)
OTA requires a specific partition scheme to work (at least when using the SDK supplied functionality).
The required flash map for ESP32 is as follows:
| Offset | File |
|------- |----- |
| 0x1000 | bootloader.bin |
| 0xd000 | ota_data_initial.bin |
| 0x8000 | partitions_two_ota.bin |
| 0x10000 | firmware.bin |

This setup can be flashed in one command as follows:
```
esptool.py --chip auto -p /dev/ttyUSB0 --baud 500000 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 PATH_TO_ESP32_LIBS/bootloader.bin 0xd000 PATH_TO_ESP32_LIBS/ota_data_initial.bin 0x8000 PATH_TO_ESP32_LIBS/partitions_two_ota.bin 0x10000 new-firmware.bin
```

The required flash map for ESP8266 is as follows:
| Offset | File |
|------- |----- |
| 0x0000 | bootloader.bin |
| 0xd000 | ota_data_initial.bin |
| 0x8000 | partitions_two_ota.bin |
| 0x10000 | firmware.bin |

This setup can be flashed in one command as follows:
```
esptool.py --chip auto -p /dev/ttyUSB0 --baud 500000 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x0000 PATH_TO_ESP8266_LIBS/bootloader.bin 0xd000 PATH_TO_ESP8266_LIBS/ota_data_initial.bin 0x8000 PATH_TO_ESP8266_LIBS/partitions_two_ota.bin 0x10000 new-firmware.bin
```

The first time firmware is flashed for OTA the bootloader, ota_data_initial and partitions_two_ota binary files needs to be flashed via serial
so that the correct partitions are created.  The firmware itself should also include OTA support.  If new firmware doesn't include OTA support,
subsequent serial updates are possible but will end up in the factory partition, which may not be the active partition. One way to recover is to
reflash the ota_data_initial.bin file so that the bootloader starts from the factory (or ota_0 if no factory partition is present) partition.
Another way is to reset the ota data (see [CONFIG_BOOTLOADER_FACTORY_RESET](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/kconfig.html#config-bootloader-factory-reset)
, but this is not enabled in the default bootloader).

### Revert from OTA to single app
If OTA functionalityis no longer required then the configuration can be returned to a single app partition using the following command:
```
esptool.py -p /dev/ttyUSB0 -b 500000 --before default_reset --after hard_reset --chip auto  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x8000 PATH_TO_LIBS/partitions_singleapp.bin 0x10000 blink.bin
```

## Notes
* Need to think which optional features are needed for basic functionality (FreeRTOS trace/stats etc.).
* Require reentrant support (XT_USE_THREAD_SAFE_CLIB)?
* Be very careful when setting esp_deep_sleep(0) on ESP8266, the only way out is via a reset.
In some cases it can cause problems with flashing firmware. Recover with esptool.py  --chip esp8266 --port /dev/ttyUSB0 --baud 115200 --before default_reset  erase_flash

Common functionality that is expected from config:
* CONFIG_LOG_SET_LEVEL - used to change verbosity at runtime
* CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS - used when reporting CPU usage of tasks  
 
TODO:
* CONFIG_HTTPD_MAX_REQ_HDR_LEN to be increased to 1024 bytes, else some browsers (e.g.Chrome) may exceed the default header size
