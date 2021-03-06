function sendWebPage(conn,answertype)
buf="HTTP/1.1 200 OK\nServer: NodeMCU\nContent-Type: text/html\n\n"
buf = buf .. "<html><body>\n"
buf = buf .. "<h1>Welcome to the WS2812-Ambi</h1>"
buf = buf.. "<h2>Configuration</h2><form action=\"\" method=\"POST\">"
buf = buf.. "<label for=\"ssid\">WIFI-SSID: <input id=\"ssid\" name=\"ssid\" value=\"" .. ssid .. "\"></label><br/>"
buf = buf.. "<label for=\"password\">Password: <input id=\"password\" name=\"password\"></label><br/>"
buf = buf.. "<label for=\"mqttserver\">MQTT Server: <input id=\"mqttserver\" name=\"mqttserver\" value=\"" .. mqttserver .. "\"></label><br/>"
buf = buf.. "<label for=\"mqttbasetopic\">MQTT Topic: <input id=\"mqttbasetopic\" name=\"mqttbasetopic\" value=\"" .. mqttbasetopic .. "\"></label><br/>"
buf = buf.. "<input type=\"submit\" value=\"Configure WS2812Ambi\"></form>"
if answertype>1 then
	buf = buf .. "<h2>New configuration saved</h2\n>"
end 
buf = buf .. "\n</body></html>"
conn:send(buf)
buf=nil
end

function startWebServer()
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
	conn:on("receive", function(conn,payload)
		ssid, password, bssid_set, bssid = wifi.sta.getconfig()
		if (payload:find("GET /switch=on") ~= nil) then
			--here is code for handling http request from a web-browser
			gpio.write(1,gpio.HIGH)
			sendWebPage(conn,1)
			conn:on("sent", function(conn) conn:close() end)
			elseif (payload:find("GET /switch=off") ~= nil) then
				gpio.write(1,gpio.LOW)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)	
				elseif (payload:find("GET /strip=red") ~= nil) then
					--here is code for handling http request from a web-browser
					ledbuffer:fill(0,255,0)
					ws2812.write(ledbuffer)
					sendWebPage(conn,1)
					conn:on("sent", function(conn) conn:close() end)
					tmr.stop(1)
					tmr.unregister(1)
					if (payload:find("blink=%d+") ~= nil) then
						for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
					end
					if (payload:find("duration=%d+") ~= nil) then
						for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
					end
					elseif (payload:find("GET /strip=blue") ~= nil) then
						--here is code for handling http request from a web-browser
						ledbuffer:fill(0,0,255)
						ws2812.write(ledbuffer)
						sendWebPage(conn,1)
						conn:on("sent", function(conn) conn:close() end)
						tmr.stop(1)
						tmr.unregister(1)
						if (payload:find("blink=%d+") ~= nil) then
							for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
						end
						if (payload:find("duration=%d+") ~= nil) then
							for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
						end
						elseif (payload:find("GET /strip=green") ~= nil) then
							--here is code for handling http request from a web-browser
							ledbuffer:fill(255,0,0)
							ws2812.write(ledbuffer)
							sendWebPage(conn,1)
							conn:on("sent", function(conn) conn:close() end)
							tmr.stop(1)
							tmr.unregister(1)
							if (payload:find("blink=%d+") ~= nil) then
								for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
							end
							if (payload:find("duration=%d+") ~= nil) then
								for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
							end
							elseif (payload:find("GET /strip=white") ~= nil) then
								--here is code for handling http request from a web-browser
								ledbuffer:fill(255,255,255)
								ws2812.write(ledbuffer)
								sendWebPage(conn,1)
								conn:on("sent", function(conn) conn:close() end)
								tmr.stop(1)
								tmr.unregister(1)
								if (payload:find("blink=%d+") ~= nil) then
									for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
								end
								if (payload:find("duration=%d+") ~= nil) then
									for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
								end
								elseif (payload:find("GET /strip=rgb") ~= nil) then
									--here is code for handling http request from a web-browser
									ledbuffer:replace(string.char(255,0,0,255,0,0,255,0,0,0,255,0,0,255,0,0,255,0,0,0,255,0,0,255,0,0,255):rep(33))
									ws2812.write(ledbuffer)
									sendWebPage(conn,1)
									conn:on("sent", function(conn) conn:close() end)
									tmr.stop(1)
									tmr.unregister(1)
									if (payload:find("blink=%d+") ~= nil) then
										for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
									end
									if (payload:find("duration=%d+") ~= nil) then
										for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
									end
									elseif (payload:find("GET /strip=off") ~= nil) then
										--here is code for handling http request from a web-browser
										ledbuffer:fill(0,0,0)
										ws2812.write(ledbuffer)
										sendWebPage(conn,1)
										conn:on("sent", function(conn) conn:close() end)
										blinkblink(0)
										tmr.stop(1)
										tmr.unregister(1)
										elseif (payload:find("GET /ledvalue?") ~= nil) then
											_, datastart = payload:find("ledvalue?")
											local _GET = {}
											for i,gruen,rot,blau in string.gmatch(payload, "(%d+)=(%d+),(%d+),(%d+)") do
												ledbuffer:set(tonumber(i),tonumber(gruen),tonumber(rot),tonumber(blau))
												ws2812.write(ledbuffer)
											end
											sendWebPage(conn,1)
											conn:on("sent", function(conn) conn:close() end)
											tmr.stop(1)
											tmr.unregister(1)
											if (payload:find("blink=%d+") ~= nil) then
												for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
											end
											if (payload:find("duration=%d+") ~= nil) then
												for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
											end
											elseif (payload:find("GET /ledrange?") ~= nil) then
												_, datastart = payload:find("ledrange?")
												ledbuffer:fill(0,0,0)
												local _GET = {}
												pointer = 1;
												for i,gruen,rot,blau in string.gmatch(payload, "(%d+)=(%d+),(%d+),(%d+)") do
													for j=pointer,tonumber(i),1 do
														ledbuffer:set(j,tonumber(gruen),tonumber(rot),tonumber(blau))
													end
													pointer=tonumber(i)+1
													ws2812.write(ledbuffer)
												end
												sendWebPage(conn,1)
												conn:on("sent", function(conn) conn:close() end)
												tmr.stop(1)
												tmr.unregister(1)
												if (payload:find("blink=%d+") ~= nil) then
													for i in string.gmatch(payload, "blink=(%d+)") do blinkblink(tonumber(i)) end
												end
												if (payload:find("duration=%d+") ~= nil) then
													for i in string.gmatch(payload, "duration=(%d+)") do blink(tonumber(i)) end
												end
												elseif (payload:find("GET /") ~= nil) then
													sendWebPage(conn,1)
													conn:on("sent", function(conn) conn:close() end)
													else if (payload:find("POST /") ~=nil) then
														--code for handling the POST-request (updating settings)
														_, postdatastart = payload:find("\r\n\r\n")
														--Next lines catches POST-requests without POST-data....
														if postdatastart==nil then postdatastart = 1 end
														postRequestData=string.sub(payload,postdatastart+1)
														local _POST = {}
														for i, j in string.gmatch(postRequestData, "(%w+)=([^&]+)&*") do
															_POST[i] = j
														end
														postRequestData=nil
														if ((_POST.ssid~=nil) and (_POST.password~=nil) and (_POST.mqttserver~=nil) and (_POST.mqttbasetopic~=nil)) then
															tmr.stop(1)
															mqtttopic,l=string.gsub(_POST.mqttbasetopic,"%%2F","/")
															save_wifi_param(_POST.ssid,_POST.password,_POST.mqttserver,mqtttopic)
															sendWebPage(conn,2)
														else
															ssid, password, bssid_set, bssid = wifi.sta.getconfig()
															sendWebPage(conn,1)
															conn:on("sent", function(conn) conn:close() end)
														end
													else
														--here is code, if the connection is not from a webbrowser, i.e. telnet or nc
														global_c=conn
														function s_output(str)
															if(global_c~=nil)
															then global_c:send(str)
														end
													end
													node.output(s_output, 0)
													global_c:on("receive",function(c,l)
														node.input(l)
														end)
														global_c:on("disconnection",function(c)
															node.output(nil)
															global_c=nil
															end)
															print("Welcome to WS2812Ambi CLI")
     
														end
													end
													end)
    
													conn:on("disconnection", function(c)
														node.output(nil)        -- un-register the redirect output function, output goes to serial
															end)
															end)

														end
