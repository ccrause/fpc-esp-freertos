# Real time task statistics
This example mimicks the functionality of the realtimestats example, except it uses Pascal threads, not raw tasks:
* Create and run Pascal threads.
* Create thread to collect and display runtime statistics.

## Notes:
* For this example to function properly the following configuration options
needs to be defined for FreeRTOS when building the ESP-IDF libraries:
  * Enable FreeRTOS trace facility
  * Enable FreeRTOS stats formatting functions
  * Enable FreeRTOS to collect run time stats    
  
These options can be configured by running idf.py (or make menuconfig),
enter _Component config_, then enter _FreeRTOS_.
* At the moment write/read writeln/readln only works in the main thread.
