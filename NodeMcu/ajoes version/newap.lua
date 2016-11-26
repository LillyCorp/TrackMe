print("ESP8266 Server")

wifi.setmode(wifi.STATIONAP);

wifi.ap.config({ssid="test",pwd="password"});

print("Server IP Address:",wifi.ap.getip())

 
if srv~=nil then
	srv:close()
end

sv = net.createServer(net.TCP)

sv:listen(80, function(conn)

conn:on("receive", function(conn, receivedData)

print("Received Data: " .. receivedData)

end)

conn:on("sent", function(conn)

collectgarbage()

end)

end)
