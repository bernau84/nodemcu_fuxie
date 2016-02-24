print("Setting up WIFI...")
wifi.setmode(wifi.STATION)

--modify according your wireless router settings
wifi.sta.config("TP-LINK_BERNAU", "hepterida")
wifi.sta.connect()

tmr.alarm(1, 4000, 1, function() 

    if wifi.sta.getip() == nil then 
        print("IP unavaiable, Waiting...") 
    else 
        tmr.stop(1)
        tmr.delay(2000000) -- cekam 2s
        
        print("Config done, IP is "..wifi.sta.getip())

        --vysle dht a odesle na server
        dofile("esp-rej_dht2thinkspeek.lua")
    end 
end)
