# Real time task statistics
This example demonstrates the following:
* Write tasks.
* Configure an ADC1 for channel 6 (GPIO34 on ESP32).
* Take average of 64 readings, print raw value and converted voltage.
* Preliminary support for the ESP32-S2 core is included but is untested.
* Repeat loop approximately every second.

## Notes:
* The function _uxTaskGetSystemState_ was not included in the libfreertos.a library
copied from the hello_world example. I had to build the real_time_stats example
to get the _uxTaskGetSystemState_ function in libfreertos.a
