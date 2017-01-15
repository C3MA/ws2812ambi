--compile lua scripts if there are new luas...

--timecore.lua
files= file.list()

if (files["webserver.lua"]) then
  print("Compiling webserver.lua to webserver.lc")
  file.remove("webserver.lc")
  node.compile("webserver.lua")
  file.remove("webserver.lua")
  node.restart()
else if (files["wifi_config.lua"]) then
  print("Compiling wifi_config.lua to wifi_config.lc")
  file.remove("wifi_config.lc")
  node.compile("wifi_config.lua")
  file.remove("wifi_config.lua")
  node.restart()
else
--start logic out of wifi_config.lua
dofile("wifi_config.lc")
end
end
