 --domoticz.lua
 sda, scl = 5, 7

avg_x = 0
avg_y = 0
avg_z = 0
report_data = 0
aggregate_counter = 0
bigger_aggregate_counter = 0
aggregate_ax_val = 0
aggregate_ay_val = 0
aggregate_az_val = 0
bigger_aggregate_ax_val = 0
bigger_aggregate_ay_val = 0
bigger_aggregate_az_val = 0
aggregate_abs_ax_val = 0
aggregate_abs_ay_val = 0
aggregate_abs_az_val = 0

function write_reg_MPU(reg,val)
  i2c.start(0)
  i2c.address(0, 0x68, i2c.TRANSMITTER)
  i2c.write(0, reg)
  i2c.write(0, val)
  i2c.stop(0)
end

function read_reg_MPU(reg)
  i2c.start(0) 
  i2c.address(0, 0x68, i2c.TRANSMITTER)
  i2c.write(0, reg)
  i2c.stop(0)
  i2c.start(0)
  i2c.address(0, 0x68, i2c.RECEIVER)
  c=i2c.read(0, 1)
  i2c.stop(0)
  --print(string.byte(c, 1))
  return c
end

function new_data_interrupt()
	-- clear interrupt
	read_reg_MPU(58)
	
	-- read acceleration data
	i2c.start(0)
	i2c.address(0, 0x68, i2c.TRANSMITTER)
	i2c.write(0, 59)
	i2c.stop(0)
	i2c.start(0)
	i2c.address(0, 0x68, i2c.RECEIVER)
	c=i2c.read(0, 8)
	i2c.stop(0)

	Ax=bit.lshift(string.byte(c, 1), 8) + string.byte(c, 2)
	Ay=bit.lshift(string.byte(c, 3), 8) + string.byte(c, 4)
	Az=bit.lshift(string.byte(c, 5), 8) + string.byte(c, 6)
	temperature=bit.lshift(string.byte(c, 7), 8) + string.byte(c, 8)

	if (Ax > 0x7FFF) then
		Ax = Ax - 0x10000;
	end
	if (Ay > 0x7FFF) then
		Ay = Ay - 0x10000;
	end
	if (Az > 0x7FFF) then
		Az = Az - 0x10000;
	end
	if (temperature > 0x7FFF) then
		temperature = temperature - 0x10000;
	end  
	temperature = (temperature*100 / 340) + 3653 -- /100
  
	-- data aggregation
	aggregate_ax_val = aggregate_ax_val + Ax
	aggregate_ay_val = aggregate_ay_val + Ay
	aggregate_az_val = aggregate_az_val + Az
	aggregate_counter = aggregate_counter + 1
	if (Az - avg_z) < 0 then
		aggregate_abs_az_val = aggregate_abs_az_val - Az + avg_z
	else
		aggregate_abs_az_val = aggregate_abs_az_val + Az - avg_z
	end
	if (Ay - avg_y) < 0 then
		aggregate_abs_ay_val = aggregate_abs_ay_val - Ay + avg_y
	else
		aggregate_abs_ay_val = aggregate_abs_ay_val + Ay - avg_y
	end	
	if (Ax - avg_x) < 0 then
		aggregate_abs_ax_val = aggregate_abs_ax_val - Ax + avg_x
	else
		aggregate_abs_ax_val = aggregate_abs_ax_val + Ax - avg_x
	end
end

function second_timer()	
	if aggregate_counter > 20 then
		report_data = (aggregate_abs_ax_val+aggregate_abs_ay_val+aggregate_abs_az_val)/(aggregate_counter)
		bigger_aggregate_az_val = bigger_aggregate_az_val + (aggregate_az_val/aggregate_counter)
		bigger_aggregate_ay_val = bigger_aggregate_ay_val + (aggregate_ay_val/aggregate_counter)
		bigger_aggregate_ax_val = bigger_aggregate_ax_val + (aggregate_ax_val/aggregate_counter)
		bigger_aggregate_counter = bigger_aggregate_counter + 1
		if avg_z ~= 0 then
			conn=net.createConnection(net.TCP, 0)
			conn:connect(8080,"YOURSERVERIP")
			conn:on("receive", function(conn, payload) end)
			conn:on("connection", function(conn, payload) 
				conn:send("GET /json.htm?type=command&param=udevice&idx=YOURSENSORIDX&nvalue=0&svalue=" .. string.format("%d",report_data)
				.." HTTP/1.1\r\n" 
				.."Host: 127.0.0.1:8080\r\n"
				.."Connection: close\r\n"
				.."Accept: */*\r\n" 
				.."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
				.."\r\n") end)
			print(string.format("%d",report_data))
		end
		if bigger_aggregate_counter == 4 then
			avg_z = bigger_aggregate_az_val/4
			avg_y = bigger_aggregate_ay_val/4
			avg_x = bigger_aggregate_ax_val/4
			bigger_aggregate_ax_val = 0
			bigger_aggregate_ay_val = 0
			bigger_aggregate_az_val = 0
			bigger_aggregate_counter = 0
		end
		aggregate_ax_val = 0
		aggregate_ay_val = 0
		aggregate_az_val = 0
		aggregate_abs_ax_val = 0
		aggregate_abs_ay_val = 0
		aggregate_abs_az_val = 0
		aggregate_counter = 0
	end
	print("d")
end

---test program
i2c.setup(0, sda, scl, i2c.SLOW)					-- init i2c
i2c.start(0)										-- start i2c
c = i2c.address(0, 0x68, i2c.TRANSMITTER)		-- see if something answers
i2c.stop(0)										-- stop i2c

if c == true then
	print("Device found at address : "..string.format("0x%X",0x68))
else 
	print("Device not found !!")
end

c = read_reg_MPU(117) 								-- Register 117 – Who Am I - 0x75
if string.byte(c, 1) == 104 then 
	print("MPU6050 Device answered OK!")
else 
	print("Check Device - MPU6050 NOT available!")
end

read_reg_MPU(107) 									-- Register 107 – Power Management 1-0x6b
if string.byte(c, 1)==64 then 
	print("MPU6050 in SLEEP Mode !")
else
	print("MPU6050 in ACTIVE Mode !")
end

write_reg_MPU(0x6B, 0)								-- Initialize MPU, use 8MHz clock
write_reg_MPU(25, 199)								-- Sample Rate = Gyroscope Output Rate / (1 + SMPLRT_DIV) >> 40Hz
write_reg_MPU(56, 0x01)								-- Enables the Data Ready interrupt, which occurs each time a write operation to all of the sensor registers has been completed.

gpio.mode(8, gpio.INT, gpio.PULLUP)					-- set gpio6 as input interrupt
gpio.trig(8, "up", new_data_interrupt)				-- new data interupt handler

--read_MPU_raw()
tmr.alarm(0, 10000, 1, second_timer)
--tmr.stop(0)
