# Signal
## Fake cellular connections on WiFi-only iOS devices

Signal allows you to fake a cellular connection on your WiFi-only iPad or iPod touch.

You can either choose to fake a plain cellular connection using a custom carrier, a static signal strength and a custom connection type, or, probably for the first time ever, simulate a cellular connection using your WiFi connection.

In static mode, Signal makes your device pretend to search for a cellular network ("Searching...") and "finding" one after a few seconds. After "establishing" a connection, a custom carrier name is shown, alongside a real fake strength indicator.

If you choose to show your WiFi connection, your device is still pretending to search for a network, but uses the WiFi connection (if available) to show the details in the status bar. If you're not connected, it says "No Service", just as you would expect.

Signal also allows you to override the data connection type. Connected to a WiFi network? Make it show LTE instead. Not connected to anything? That lousy GPRS connection will do.

Additionally, you can show a fake Tethering status bar and even fake the connection count. Please keep in mind that more than int32 devices isn't supported by iOS.
