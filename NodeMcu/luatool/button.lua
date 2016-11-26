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
