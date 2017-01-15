--Function to save WiFi-parameters into file-system as wlancfg.lua
function save_wifi_param(ssid,password,mqttserver,mqttbasetopic)
	file.remove("wlancfg.lua");
	file.open("wlancfg.lua","w+");
	w = file.writeline('-- Tell the chip to connect to this access point');
	w = file.writeline('wifi.setmode(wifi.STATION)');
	w = file.writeline('wifi.sta.config("' .. ssid .. '","' .. password .. '")');
	w = file.writeline('mqttserver="' .. mqttserver ..'"');
	w = file.writeline('mqttbasetopic="' .. mqttbasetopic ..'"');
	file.close();
	ssid,password,mqttserver,mqttbasetopic=nil,nil,nil,nil
end

--main routine after wifi has been setup correctly
function logic()
	rot = 0
	gruen = 0
	blau = 0
	anaus="OFF"
	m = mqtt.Client("ESP8266", 120, "user", "pass")
	function mqttsubscribe()
		tmr.alarm(1,1000,0,function() m:subscribe(mqttbasetopic .. "_an",0, function(conn) print("subscribe an success") end) end)
		tmr.alarm(2,2000,0,function() m:subscribe(mqttbasetopic .. "_rot",0, function(conn) print("subscribe rot success") end) end)
		tmr.alarm(3,3000,0,function() m:subscribe(mqttbasetopic .. "_gruen",0, function(conn) print("subscribe gruen success") end) end)
		tmr.alarm(4,4000,0,function() m:subscribe(mqttbasetopic .. "_blau",0, function(conn) print("subscribe blau success") end) end)
	end
	ws2812.init(ws2812.MODE_SINGLE)
	m:on("connect", mqttsubscribe)
	m:on("offline", function(con) print ("offline") end)
	m:on("message", function(conn, topic, data)
		if topic== mqttbasetopic .."_an" then
			if data=="ON" then
				anaus = "ON"
				ws2812.write(string.char(gruen,rot,blau):rep(300))
				print("An!")
			else
				anaus = "OFF"
				ws2812.write(string.char(0,0,0):rep(300))
				print("Aus!")
			end
			elseif topic== mqttbasetopic .. "_rot" then
				rot=tonumber(data)
				print("rot: " .. rot)
				if anaus == "ON" then ws2812.write(string.char(gruen,rot,blau):rep(300)) end
				elseif topic== mqttbasetopic .. "_gruen" then
					gruen=tonumber(data)
					print("gruen: " .. gruen)
					if anaus == "ON" then ws2812.write(string.char(gruen,rot,blau):rep(300)) end
					elseif topic== mqttbasetopic .. "_blau" then
						blau=tonumber(data)
						print("blau: " .. blau)
						if anaus == "ON" then ws2812.write(string.char(gruen,rot,blau):rep(300)) end
					end
					end)
		m:connect(mqttserver,1883,0)
end

	--init_logic run once after successfully established network-connection 
function init_logic()

			-- start webserver
			dofile("webserver.lc")
			startWebServer()
			--set GPIO5 as output (for relais)
			gpio.mode(5,gpio.OUTPUT)
			gpio.write(5,gpio.LOW)
			logic()
end





--MAIN PROGRAM ENTRY POINT, CALLED FROM init.lua

--if unable to connect for 30 seconds, start enduser_setup-routine
--load Wifi-configuration and try to connect
dofile("wlancfg.lua")


connect_counter = 0
tmr.alarm(0, 100, 1, function()
	if wifi.sta.status() ~= 5 then
		connect_counter = connect_counter + 1
		print("Connecting to AP...")
		if(connect_counter == 300) then
			tmr.stop(0)
			print("Starting WiFi setup mode")
			enduser_setup.start(
			function()
				ssid,password,bssid_set,bssid=wifi.sta.getconfig()
				save_wifi_param(ssid,password,"192.168.0.1","/ledstrip/");
				print("Connected to wifi as:" .. wifi.sta.getip());
				print("Saved parameters in wlancfg.lua");
				init_logic();
				end,
				function(err, str)
					print("enduser_setup: Err #:" .. err .. ": " .. str);
				end
				)
			end
		else
			tmr.stop(0)
			print('IP: ',wifi.sta.getip())
			init_logic()
		end
	end
	)
      
									--at this point we should be ready to go....

