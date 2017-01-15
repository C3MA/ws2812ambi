-- Tell the chip to connect to this access point
wifi.setmode(wifi.STATION)
wifi.sta.config("XXX","XXXXXXXXXX")
mqttserver="192.168.23.3"
mqttbasetopic="/room1/ledstrip"
