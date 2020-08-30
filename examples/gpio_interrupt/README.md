# GPIO interrupt
This example demonstrates configuring a negative edge pin interrupt on GPIO0 (on many boards this is connected to a button called BOOT or FLASH).  The interrupt handler togglges another pin which could be connected to an LED for visual indication.  The interrupt handler also writes out the state of the pin being toggled.

