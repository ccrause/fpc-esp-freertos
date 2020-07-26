# Test exiting from qemu with an exit code
For automated testing it is useful to run a test program, exit the program and return the exit code. When using qemu to emulate a target, one has to signal this to qemu.  There are several options available in qemu, but not all of them necessarily work for the ESP32 target. The following options are tested in this example:

## Execute simcall instruction
The simcall instruction is specifically provided by the Xtensa ISA for interacting with simulation software. This gets intercepted if the _-semihosting_ option is passed when calling qemu. To exit, the first parameter (register a2 in assembly) needs to be set to 1 and the exit code should be specified in the second parameter (register a3 in assembler). There are two more parameters but they are unused when calling exit.

## Reboot
Qemu can be instructed to terminate when the target reboots by specifying the _-no-reboot_ option. In the example esp_reboot is called to reboot the target.  Unfortunately there isn't a way to specify an exit code, so 0 is always returned.

## Deep sleep
Qemu has an option to exit when the cpu(s) are shut down (-no-shutdown). The ESP32 has a function esp_deep_sleep which puts the cores in a low power sleep state.  If no wake-up source is defined and all interrupts are disabled then this results effectively in a system halt.

## Use isa-debug-exit
Qemu has an option to intercept information written to specific port addresses using the _-device isa-debug-exit_ option. This option was not enabled for the xtensa target when this testing was done. The option was enabled in qemu's configuration and it was rebuilt, but then qemu gave an error: No 'ISA' bus found for device 'isa-debug-exit'. So at the moment there isn't an obvious way to use this feature.  This option is anyway not that great, because it cannot be used to return an exit code of 0.
