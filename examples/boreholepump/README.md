# Borehole pump controller
A controller to control a borehole pump filling a water tank. Features:
* Check tank level to stop pump when tank level is high or start pump when tank level is low.
* Check pump flow rate and stop pump when flow rate drops below setpoint.
* Additionally output pin to signal when tank is below low level.
* Web interface to display status and settings.

##Sensors
###Level sensor
A AJ-SR04M ultrasonic distance sensor is used to detect the tank level. It is configured to be triggered by a serial pulse and return the measured distance via serial.

###Flow sensor
A YF-B6 flow sensor with pulse output is used to detect water flow.  The pulses are counted using the ESP32's pulse counter peripheral.
