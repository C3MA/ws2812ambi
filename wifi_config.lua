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

function debounce (func)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function buttonGPIO0()
	if (onoff=="ON") then
		onoff="OFF"
		blinkblink(0)
		ledbuffer:fill(0,0,0)
		ws2812.write(ledbuffer)
	else
		onoff="ON"
		blinkblink(0)
		ledbuffer:fill(255,255,255)
		ws2812.write(ledbuffer)
	end
end

--function to enable blinking in one sec
function blinkblink(time)
	if (time > 0) then
		dark=1
		tmr.alarm(0,time * 1000,1, function ()
			if (dark==1) then
				tempbuffer = ledbuffer:sub(1)
				ledbuffer:fill(0,0,0)
				ws2812.write(ledbuffer)
				dark=0
			else
				ledbuffer:replace(tempbuffer)
				ws2812.write(ledbuffer)
				dark=1
			end
		end)
	else
		tmr.stop(0)
		tmr.unregister(0)
	end		
end
	
function blink(duration)
	dark=1
	count=0
	tmr.alarm(1,500,1, function ()
		if (count<duration) then
			if (dark==1) then
				tempbuffer = ledbuffer:sub(1)
				ledbuffer:fill(0,0,0)
				ws2812.write(ledbuffer)
				dark=0			
			else
				ledbuffer:replace(tempbuffer)
				ws2812.write(ledbuffer)
				dark=1
				count=count+1
			end
		else
			tmr.stop(1)
			tmr.unregister(1)
			ledbuffer:fill(0,0,0)
			ws2812.write(ledbuffer)
		end
	end)	
end



--main routine after wifi has been setup correctly
function logic()
	red = 0
	green = 0
	blue = 0
	onoff="OFF"
	m = mqtt.Client("ESP8266", 120, "user", "pass")
	function mqttsubscribe()
		tmr.alarm(1,1000,0,function() m:subscribe(mqttbasetopic .. "_on",0, function(conn) print("subscribe on success") tmr.unregister(1) end) end)
		tmr.alarm(2,2000,0,function() m:subscribe(mqttbasetopic .. "_red",0, function(conn) print("subscribe red success") tmr.unregister(2) end) end)
		tmr.alarm(3,3000,0,function() m:subscribe(mqttbasetopic .. "_green",0, function(conn) print("subscribe green success") tmr.unregister(3) end) end)
		tmr.alarm(4,4000,0,function() m:subscribe(mqttbasetopic .. "_blue",0, function(conn) print("subscribe blue success") tmr.unregister(4) end) end)
	end
	ws2812.init(ws2812.MODE_SINGLE)
	m:on("connect", mqttsubscribe)
   m:on("offline", function(con) 
       print ("offline") 
       connected=false
       tmr.alarm(4, 5000, 1, function()
           if (connected == true) then
               print("Reconnect successful")
           else

               print("Reconnecting to " .. mqttserver .. "...")
               m:connect(mqttserver, 1883, 0)
           end
       end)
   end)
	m:on("message", function(conn, topic, data)
		if topic== mqttbasetopic .."_on" then
			if data=="ON" then
				onoff = "ON"
				blinkblink(0)
				ledbuffer:fill(green,red,blue)
				ws2812.write(ledbuffer)
				print("On!")
			else
				onoff = "OFF"
				blinkblink(0)
				ledbuffer:fill(0,0,0)
				ws2812.write(ledbuffer)
				print("Off!")
			end
			elseif topic== mqttbasetopic .. "_red" then
				red=tonumber(data)
				print("red: " .. red)
				if onoff == "ON" then
					ledbuffer:fill(green,red,blue)
					ws2812.write(ledbuffer)
				end
				elseif topic== mqttbasetopic .. "_green" then
					green=tonumber(data)
					print("green: " .. green)
					if onoff == "ON" then
						ledbuffer:fill(green,red,blue)
						ws2812.write(ledbuffer)
					end
					elseif topic== mqttbasetopic .. "_blue" then
						blue=tonumber(data)
						print("blue: " .. blue)
						if onoff == "ON" then
							ledbuffer:fill(green,red,blue)
							ws2812.write(ledbuffer)
						end
					end
					end)
		m:connect(mqttserver,1883,0)
		
		--Button
		gpio.mode(3,gpio.INT,gpio.PULLUP)
		gpio.trig(3, "down", debounce(buttonGPIO0))
end

	--init_logic run once after successfully established network-connection 


function init_logic()
	--unregister Timer0
	tmr.unregister(0)
	-- start webserver
	dofile("webserver.lc")
	startWebServer()
	--register MDNS
	mdns.register("ambilightsz", { description="WS2812 Ambilight Schlafzimmer", service="http", port="80" })
	--set GPIO5 as output (for relais)
	gpio.mode(5,gpio.OUTPUT)
	gpio.write(5,gpio.LOW)
	logic()
end

ws2812.init()
--initialize WS2812-Buffer for 300 LEDs
ledbuffer=ws2812.newBuffer(300,3);

--MAIN PROGRAM ENTRY POINT, CALLED FROM init.lua

--if unable to connect for 30 seconds, start enduser_setup-routine
--load Wifi-configuration and try to connect
dofile("wlancfg.lua")

print("Connecting to AP for 30 seconds")
connect_counter = 0
tmr.alarm(0, 100, 1, function()
	if wifi.sta.status() ~= 5 then
		connect_counter = connect_counter + 1
		print(tostring(connect_counter) .. "/300 Connecting to AP...")
        -- Green moving dot during connecting
        ledbuffer:set(connect_counter% ledbuffer:size() + 1, 64, 0, 0)
        -- clear the last LED
        ledbuffer:set((connect_counter - 1) % ledbuffer:size() + 1, 0, 0, 0)
        
        ws2812.write(ledbuffer)
		if(connect_counter == 300) then
			tmr.stop(0)
            ledbuffer:fill(0,64,0)
            ws2812.write(ledbuffer)
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
            ledbuffer:fill(0,0,0)
            ws2812.write(ledbuffer)
			print('IP: ',wifi.sta.getip())
			init_logic()
		end
	end
	)
--at this point we should be ready to go....
