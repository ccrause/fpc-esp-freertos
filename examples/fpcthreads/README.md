# FPC threads demo
This example demonstrates the following:
* Start a thread using ThreadBegin or the custom fBeginThreadNamed.
* Start a blink thread, with blocking/unblocking of thread using critical sections.
* Start a few spin loops, each one waiting for an RTLEvent. Release each spin thread from main thread using RTLEventSetEvent.
* Print runtime statistics, adapted from FreeRTOS Real Time Stats demo.

