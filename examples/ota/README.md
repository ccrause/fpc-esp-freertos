# OTA
This example demonstrates over the air firmware updating and uses a push mechanism
to update the firmware, in contrast to the SDK examples which uses a pull mechanism.
A webserver is created which serves up a simple file upload interface, with JavaScript
to upload the selected file from a browser to an upload POST handler.  

This example can be used by either connecting to an existing access point (AP) or 
by running the controller in AP mode by calling connectWifiAP or createWifiAP respectively.  

## Notes
The default header size used in the SDK is 512 bytes. Chrome headers exceeds this size (at least on my test machine)
and leads to an error. To fix this increase the CONFIG_HTTPD_MAX_REQ_HDR_LEN configuration
option and rebuild an SDK example and all libraries. This example was tested with Firefox 82.0.
