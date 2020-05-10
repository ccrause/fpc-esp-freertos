# Real time task statistics
This example demonstrates the following:
* Create and run parallel tasks.
* Create task to collect and display runtime statistics.

## Notes:
* The function _uxTaskGetSystemState_ was not included in the libfreertos.a library
copied from the hello_world example. I had to build the real_time_stats example
to get the _uxTaskGetSystemState_ function in libfreertos.a .
* Be carefull with printing/logging messages from different tasks. At the moment there
seems to be a reentrancy problem.
