ssid = "GUEST"
pass = ""
print('\nAll About Circuits init.lua\n')
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('Chip ID: ',node.chipid())
print('Heap Size: ',node.heap(),'\n')
wifi.sta.config(ssid,pass)
--bmp180 = require("bmp180")

dofile("main.lua")
