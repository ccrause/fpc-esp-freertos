# fpc-esp-freertos
This project is for creating bindings to the [ESP-IDF](https://github.com/espressif/esp-idf) project
of Espressif for [Free Pascal](https://www.freepascal.org/).  This project is targeting bindings for [version 4.1](https://github.com/espressif/esp-idf/tree/release/v4.1) of 
the ESP-IDF, the latest release candidate when the project started.  Since this is a work in progress the ESP-IDF version targeted will 
be fixed at 4.1 for now.

Support for the ESP8266_RTOS_SDK [version 3.3](https://github.com/espressif/ESP8266_RTOS_SDK/tree/release/v3.3) is also being added. At the moment there is very little shared code between the two SDK's.

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
