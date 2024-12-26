# Simple HTTP server with fallback to softAP mode
This example connects to a wifi AP using stored credentials. If that fails, it creates a softAP with a login page
where one can select an SSID and enter a password to a wifi AP. It will then attempt to log into the new SSID.
Should that fail the code will fall back to the softAP with login page.

## Notes
* Example adapted for both ESP32 and ESP8266.
* [FPC running logo](https://wiki.lazarus.freepascal.org/images/4/4f/fpc_running_logo.gif) complements of user Jwdietrich.
* Gif file converted to inline array of char using FPC's data2inc tool.
* To re-use the HTTP server port 80 between the different stages requires the SO_REUSEADDR capability. This is not applied in ESP8266_RTOS_SDK
v3.4. If required, use the development (master) version of the SDK.
