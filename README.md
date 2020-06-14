# fpc-esp-freertos
This project is for creating bindings to the [ESP-IDF](https://github.com/espressif/esp-idf) project
of Espressif for [Free Pascal](https://www.freepascal.org/).  This project is targeting bindings for [version 4.1](https://github.com/espressif/esp-idf/tree/release/v4.1) of 
the ESP-IDF, the latest release candidate when the project started.  Since this is a work in progress the ESP-IDF version targeted will 
be fixed at 4.1 for now.

Support for the ESP8266_RTOS_SDK (master branch from 29 March 2020) is also being added. At the moment there is very little shared code between the two SDK's.

## Notes
* Need to think which optional features are needed for basic functionality (FreeRTOS trace/stats etc.).
* Require reentrant support (XT_USE_THREAD_SAFE_CLIB)?
