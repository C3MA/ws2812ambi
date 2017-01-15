# WS2812Ambi


This is a small application for the ESP8266 running NodeMCU to control a WS2812 LED strip via MQTT or via URL-call

##Installation

Flash the following files on your ESP8266, that runs the NodeMCU-firmware:
- init.lua
- webserver.lua
- wifi_config.lua
- wlancfg.lua


Make sure, the ESP8266 runs a NodeMCU-firmware, that was compiled with the WS2812 module, the mqtt module and the ws2812 module as well
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

mqttbasetopic .."_an" = ON || OFF (Switch LED strip on or off)

mqttbasetopic .."_rot" = 0-255 (red brightness)

mqttbasetopic .."_gruen" = 0-255 (green brightness)

mqttbasetopic .."_blau" = 0-255 (blue brightness)



so, if you chosse "/room1/ledstrip" as mqttbasetopic, then you need the following topis on your mqtt broker:
/room1/ledstrip_an

/room1/ledstrip_blue

/room1/ledstrip_green

/room1/ledstrip_red


##Usage with URL-functions

You can use the following convenient URL-functions:

Control LED-Strip on GPIO2
http://ip/strip=red

http://ip/strip=blue

http://ip/strip=green

http://ip/strip=off

http://ip/strip=rgb


Control Relais or other on GPIO5
http://ip/switch=on

http://ip/switch=off


##NodeMCU CLI access

for troubleshooting you can also access the NodeMCU cli via network using netcat:

nc WS2812Ambi_IP 80

(press "." and Enter)

