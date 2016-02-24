
--natahne fce pro usinani
dofile("esp-rej_rtcsleep.lua")

--ted neusinat 
rtc_hold_on()
        
print("Acquiring data from sensor")
Sta = -2
Rep = 20
while (Sta ~= 0) and (Rep) do
    Sta,Temperature,Humidity=dht.read(4)
    print("Measurement: T=" ..Temperature..", H="..Humidity)
    tmr.delay(100000)
    Rep = Rep - 1
end

Vbat = adc.read(0) * 0.003436 
print("Bat voltage" .. Vbat)

-- conection to thingspeak.com
print("Forward to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 

local status = "unknown"

--callback fce
conn:on("receive", function(conn, payload) 
    print(payload) 
    tmr.alarm(2, 2000, 0, function() conn:close() end)    
end)

conn:on("disconnection", function(conn) 
    status = "disconnected" 
    print("Got disconnection...") 
    
    tmr.delay(100000)
     
    --dem chrapat
    rtc_asleep_for(0x15) 
end)

conn:on("sent", function(conn) 
    status = "sent"
    print("send")
   -- tmr.alarm(2, 2000, 0, function() conn:close() end)
end)
          
-- api.thingspeak.com 184.106.153.149
conn:connect(80, 'api.thingspeak.com') 
--conn:connect(15580, '192.168.240.104')

conn:on("connection", function(conn)
    status = "connected" 
    print("Connected, sending data...")

    http = "GET /update?api_key=27S3ML4BDYC2NE5J&field1="..Temperature.."&field2="..Humidity.."&field3="..Vbat.." HTTP/1.1\r\n"
    http = http .. "Host: api.thingspeak.com\r\n"
    http = http .. "Accept: */*\r\n"
    http = http .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
    http = http .. "\r\n"
    print(http)
    conn:send(http) 

    --conn:send("POST /update HTTP/1.1\r\nHost: api.thingspeak.com\r\nConnection: close\r\nX-THINGSPEAKAPIKEY: 27S3ML4BDYC2NE5J\r\n")
    --conn:send("Host: api.thingspeak.com\r\n")
    --conn:send("Connection: close\r\n")
    --conn:send("X-THINGSPEAKAPIKEY: 27S3ML4BDYC2NE5J\r\n")
    --conn:send("Content-Type: application/x-www-form-urlencoded\r\n")
    --conn:send("\r\n")    
    --conn:send("field1=70&field2=44\r\n")
end)



