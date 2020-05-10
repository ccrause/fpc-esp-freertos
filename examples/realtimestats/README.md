# Real time task statistics
This example demonstrates the following:
* Create and run parallel tasks.
* Create task to collect and display runtime statistics.

## Notes:
* For this example to function properly the following configuration options
needs to be defined for FreeRTOS when building the ESP-IDF libraries:
  * Enable FreeRTOS trace facility
  * Enable FreeRTOS stats formatting functions
  * Enable FreeRTOS to collect run time stats
These options can be configured by running idf.py (or make menuconfig),
enter _Component config_, then enter _FreeRTOS_.
* Be carefull with printing/logging messages from different tasks. At the moment there
seems to be a reentrancy problem with this example.
