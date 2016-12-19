print('\nAll About Circuits main.lua\n')
tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...\n")
   else
      ip, nm, gw=wifi.sta.getip()
      print("IP Info: \nIP Address: ",ip)
      print("Netmask: ",nm)
      print("Gateway Addr: ",gw,'\n')
      ssid, password, bssid_set, bssid=wifi.sta.getconfig()

	  print("\nCurrent Station configuration:\nSSID : "..ssid
	  .."\nPassword  : "..password
	  .."\nBSSID_set  : "..bssid_set
	  .."\nBSSID: "..bssid.."\n")
	  ssid, password, bssid_set, bssid=nil, nil, nil, nil
      tmr.stop(0)
      print(wifi.ap.getmac())

		function listap(t)
		    for bssid,v in pairs(t) do
				bmp180.init(6, 5)
				bmp180.read(OSS)
				t = bmp180.getTemperature()
				p = bmp180.getPressure()
		        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
		        print("CURRENT RSSI IS: "..rssi)
		        print("mac "..bssid )
		        print("Temp "..t)
				print("Pressure "..p)

		    end
		end
		ssid, tmp, bssid_set, bssid=wifi.sta.getconfig() 

		scan_cfg = {}
		scan_cfg.ssid = ssid 
		if bssid_set == 1 then scan_cfg.bssid = bssid else scan_cfg.bssid = nil end
		scan_cfg.channel = wifi.getchannel()
		scan_cfg.show_hidden = 0
		ssid, tmp, bssid_set, bssid=nil, nil, nil, nil
		wifi.sta.getap(scan_cfg, 1, listap)
		

   end
end)

led1 = 3
led2 = 4

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        buf = buf.."HTTP/1.1 200 OK\n\n"
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
            print(method)
            print(path)
            print(vars)
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        
        if(path == "/ON1")then
            	gpio.write(led1, gpio.HIGH);
            	conn:send("<h1> Hello, NodeMCU!!! </h1>")
            	conn:send('HTTP/1.1 200 OK\n\n')
        		conn:send('HELLO\n')
        		conn:send('<html>\n')
        		conn:send('<head><meta  content="text/html; charset=utf-8">\n')
        		conn:send('<title>ESP8266 Blinker Thing</title></head>\n')
        		conn:send('<body><h1>ESP8266 Blinker Thing!</h1>\n')
        		
        		local i = 1
        		flag = 3
        		client:close();
        		dofile("newap.lua")
    			
    			
    			         	


        elseif(path == "/OFF1")then
              gpio.write(led1, gpio.LOW);
                
            	conn:send('HTTP/1.1 200 OK\n\n')
        		conn:send('HELLO\n')
        		

        elseif(path == "/location")then
        		function listap(t)
				    for bssid,v in pairs(t) do
				        --local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
				        print("CURRENT RSSI IS: "..rssi)
				        print("mac "..bssid )
				        conn:send('HTTP/1.1 200 OK\n\n')
        				conn:send('mac'..bssid)
        				conn:send('rssi'..rssi)
				        
            	
				    end
				end
				ssid, tmp, bssid_set, bssid=wifi.sta.getconfig() 

				scan_cfg = {}
				scan_cfg.ssid = ssid 
				if bssid_set == 1 then scan_cfg.bssid = bssid else scan_cfg.bssid = nil end
				scan_cfg.channel = wifi.getchannel()
				scan_cfg.show_hidden = 0
				ssid, tmp, bssid_set, bssid=nil, nil, nil, nil
				wifi.sta.getap(scan_cfg, 1, listap)

        elseif(_GET.pin == "ON2")then
              gpio.write(led2, gpio.HIGH);
        elseif(_GET.pin == "OFF2")then
              gpio.write(led2, gpio.LOW);
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
print("end")
print(flag)
if flag == 3 then
    	print("ESP8266 Server")

		wifi.setmode(wifi.STATIONAP);

		wifi.ap.config({ssid="test",pwd="password"});

		print("Server IP Address:",wifi.ap.getip())

		 

		sv = net.createServer(net.TCP)

		sv:listen(80, function(conn)

		conn:on("receive", function(conn, receivedData)

		print("Received Data: " .. receivedData)

		end)

		conn:on("sent", function(conn)

		collectgarbage()

		end)

		end)
    end
