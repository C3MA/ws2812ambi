# WS2812Ambi


This is a small application for the ESP8266 running NodeMCU to control a WS2812 LED strip via MQTT or via URL-call

##Installation
Your ESP8266-module needs to run the Nodemcu-Firmware. These skripts are working with Release 1.5.4.1
Compile NodeMCU with the following modules:
- WS2812
- NET
- MDNS
- EnduserSetup
- MQTT

Instead of compiling yourself you can search for a online-build-service, that is available for NodeMCU


Flash the following files on your ESP8266, that runs the NodeMCU-firmware:
- init.lua
- webserver.lua
- wifi_config.lua
- wlancfg.lua

Use ESPLORER or nodemcu-uploader:

nodemcu-uploader --port/dev/tty....   upload init.lua webserver.lua wifi_config.lua wlancfg.lua_

Make sure, the ESP8266 runs a NodeMCU-firmware, that was compiled with the WS2812 module, the mqtt module  ,the enduser-setup-module and the MDNS module as well
This app was tested with nodemcu-release 1.5.4.1

##Wiring

Connect your WS2812 LED strip data-pin with GPIO2 and with +5V and GND

##Usage with MQTT
/room1/ledstrip_blue
when first booting, the Nodemcu will compile the LUA files to LC files for better performance.

Then it tries to connect to the WiFi-Network with the credentials found in wlancfg.lua. If it has no success, then it will open a wifi-network "Gadget-XXX"
In this Wifi-network you can access a capture webpage asking for WiFI-SSID and password and store this information in wlancfg.lua

If it can connect to the wifi, it will disply its IP-address on UART. With a webbrowser you can access a webpage asking for SSID, password, MQTT Server name and MQTT-Basetopic

On your mqtt-server have these topics ready:

mqttbasetopic .."_on" = ON || OFF (Switch LED strip on or off)

mqttbasetopic .."_red" = 0-255 (red brightness)

mqttbasetopic .."_green" = 0-255 (green brightness)

mqttbasetopic .."_blue" = 0-255 (blue brightness)



so, if you chosse "/room1/ledstrip" as mqttbasetopic, then you need the following topis on your mqtt broker:
/room1/ledstrip_on

/room1/ledstrip_blue

/room1/ledstrip_green

/room1/ledstrip_red


##Usage with URL-functions

You can use the following convenient URL-functions:

Control LED-Strip on GPIO2

http://ip/strip=red

http://ip/strip=red

http://ip/strip=blue

http://ip/strip=green

http://ip/strip=off

http://ip/strip=rgb


http://ip/ledvalue?1=0,255,0&2=255,0,0&3=0,255,255   .... and so on.... Switch individual leds by submitting the led-index and values in the URL.

Did not try out yet, how many LEDs can be switchd in one request....


http://ip/ledrange?10=100,0,0&20=0,100,0&30=0,0,100&40=100,100,0	... and so on... switch ranges of LEDs : 1-10 in one color, LEDs 11-20 in another color and LEDs 21-30 in the third color ....


In the URL you can add "&blink={time in seconds}" to have the LEDs blinking...

Also you can add "&duration{time in seconds}" to have the LEDs blinking only for a specific duration of time


Control Relais or other on GPIO5
http://ip/switch=on

http://ip/switch=off

The controller will advertise itself as "ambilight.local" via MDNS


##Hardware-Button

You can connect a pushbotton between GPIO0 and GND. On Button press you can alternate the LED-strip between off and on (all white)

##NodeMCU CLI access

for troubleshooting you can also access the NodeMCU cli via network using netcat:

nc WS2812Ambi_IP 80

(press "." and Enter)

##Remote Upgrade
You can use the script "remoteUpgrade.sh <IP>" to update the LUA-Files remotely



