-- main.lua --

----------------------------------
-- WiFi Connection Verification --
----------------------------------
tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...\n")
   else
      ip, nm, gw=wifi.sta.getip()
      print("IP Info: \nIP Address: ",ip)
      print("Netmask: ",nm)
      print("Gateway Addr: ",gw,'\n')
      tmr.stop(0)
   end
end)


----------------------
-- Global Variables --
----------------------
led_pin = 1
sw_pin = 2
sw_state = 0
adc_id = 0 -- Not really necessary since there's only 1 ADC...
adc_value = 512

---------------------------------------------------
-- Amy from Gargantia on the Verdurous Planet
blink_open = "http://i.imgur.com/kzt3tO8.png"
blink_close = "http://i.imgur.com/KS1dPa7.png"
site_image = blink_open

----------------
-- GPIO Setup --
----------------
print("Setting Up GPIO...")
print("LED")
-- Inable PWM output
pwm.setup(led_pin, 1000, 1023) -- 2Hz, 50% duty default
pwm.start(led_pin)
gpio.mode(led_pin, gpio.OUTPUT)
print("Switch")
-- Enable input
gpio.mode(sw_pin, gpio.INPUT)

----------------
-- Web Server --
----------------
print("Starting Web Server...")
-- Create a server object with 30 second timeout
srv = net.createServer(net.TCP, 30)
button_state = gpio.read(sw_pin)
	if button_state then 
            	if sw_state == 0 then
            		sw_state = 1
            		-- Adjust freq
            		gpio.write(led_pin, gpio.HIGH)
            		print("Led button On")	
        	elseif sw_state == 1 then
        		sw_state = 0
        		-- Adjust duty cycle
        		gpio.write(led_pin, gpio.LOW)
        		print("Led button Off")	
            	end		
            end

-- server listen on 80, 
-- if data received, print data to console,
-- then serve up a sweet little website
srv:listen(80,function(conn)
	
	conn:on("receive", function(conn, payload)
		--print(payload) -- Print data from browser to serial terminal
	
		function esp_update()
            mcu_do=string.sub(payload,postparse[2]+1,#payload)
            
            if mcu_do == "Update+LED" then 
            	if sw_state == 0 then
            		sw_state = 1
            		-- Adjust freq
            		gpio.write(led_pin, gpio.HIGH)
            		print("Led On")	
        	elseif sw_state == 1 then
        		sw_state = 0
        		-- Adjust duty cycle
        		gpio.write(led_pin, gpio.LOW)
        		print("Led Off")	
            	end		
            end
            
            if mcu_do == "Read+ADC" then
            	adc_value = adc.read(adc_id)
            	-- Sanitize ADC reading for PWM
				if adc_value > 1023 then
					adc_value = 1023
				elseif adc_value < 0 then
					adc_value = 0
				end
				print("ADC: ", adc_value)
            end
        end

        --parse position POST value from header
        postparse={string.find(payload,"mcu_do=")}
        --If POST value exist, set LED power
        if postparse[2]~=nil then esp_update()end


		-- CREATE WEBSITE --
        
        -- HTML Header Stuff
        conn:send('HTTP/1.1 200 OK\n\n')
        conn:send('<!DOCTYPE HTML>\n')
        conn:send('<html>\n')
        conn:send('<head><meta  content="text/html; charset=utf-8">\n')
        conn:send('<title>ESP8266 Blinker Thing</title></head>\n')
        conn:send('<body><h1>ESP8266 Blinker Thing!</h1>\n')
       	
       
        -- Labels
        -- conn:send('<p>ADC Value: '..adc_value..'</p><br>')
        conn:send('<p>button count: '..button_count..'Hz</p>')
	conn:send('<p>or</p>')
        conn:send('<p>PWM Duty Cycle (Input Low): '..(adc_value * 100 / 1024)..'%</p><br>')

       	-- Buttons 
       	conn:send('<form action="" method="POST">\n')
        conn:send('<input type="submit" name="mcu_do" value="Read ADC">\n')
        conn:send('<input type="submit" name="mcu_do" value="Update LED">\n')
        conn:send('</body></html>\n')
        conn:on("sent", function(conn) conn:close() end)
	end)
end)
