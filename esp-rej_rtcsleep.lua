
-- konstanty pro GPIO operace
-- gpionum = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[13]=7,[14]=5,[15]=8,[16]=0}

-- nastaveni hodin na 0:0:0 a podrzeni zapinacihpo pinu
function rtc_hold_on()

    print("turned-on")
    
    -- Zapnu pridrzeni napajeni, jinak by se po resetu hodin vypnul, a nastavim bezpecnostni interval na vypnuti, kdyby se to zacyklovalo
    gpio.mode(7, gpio.OUTPUT)
    gpio.write(7, gpio.HIGH)

    -- Init hodin
    i2c.setup(0, 6, 5, i2c.SLOW)
    i2c.start(0)
    i2c.address(0, 0x6F, i2c.TRANSMITTER) -- zapis ridiciho slova / write
    i2c.write(0, 00) -- zapis adresy 
    i2c.write(0, 0x80) -- zapis sekundy + start oscilatoru
    i2c.write(0, 0x00) -- zapis minuty
    i2c.write(0, 0x00) -- zapis hodiny
    i2c.write(0, 0x08) -- den v tydnu, zapisuji abych zrustil power fail bit a zapnul Vbat 
    i2c.stop(0)
end

-- nastaveni budiku na 1-59 minut
function rtc_asleep_for(minutes)

    i2c.start(0)
    i2c.address(0, 0x6F ,i2c.TRANSMITTER) -- zapis ridiciho slova / write
    i2c.write(0, 0x0A) -- zapis adresy registr casu buzeni sekundy
    i2c.write(0, 0x00) -- zapis sekundy 0
    i2c.write(0, minutes) -- zapis minuty, pozor je to BCD
    i2c.stop(0)
    
    i2c.start(0)
    i2c.address(0, 0x6F ,i2c.TRANSMITTER) -- zapis ridiciho slova / write
    i2c.write(0, 0x07) -- zapis adresy ovladani alarmu
    i2c.write(0, 0x10) -- zapis aktivace alarmu 0
    i2c.stop(0)
    
    i2c.start(0)
    i2c.address(0, 0x6F ,i2c.TRANSMITTER) -- zapis ridiciho slova / write
    i2c.write(0, 0x0D) -- zapis adresy registr nastaveni alarmu (registr dne)
    i2c.write(0, 0x10) -- alarm minutova shoda, vymazani
    i2c.stop(0)
        
    print("turned-off")
    gpio.write(7,gpio.LOW) -- timto se vypnu

    tmr.delay(500000) -- cekam 0,5s na vypnuti
    print("sleep-failure!")    
end


-- vypsani registru RTC, tech na zacatku co nas zajimaji
function rtc_readback() -- DEBUG vypis vsech hodnot z RTC, skoro vsech

    i2c.start(0)
    i2c.address(0, 0x6F ,i2c.TRANSMITTER) -- zapis ridiciho slova / write
    i2c.write(0, 00) -- zapis adresy 
    i2c.start(0)
    i2c.address(0, 0x6F ,i2c.RECEIVER) -- zapis ridiciho slova / write
    local data = i2c.read(0, 16) -- vyctu 16 dat
    i2c.stop(0)
    
    local q
    for q=1,16,1 do
        print ("rtc-reg" .. (q-1) .. " : " .. string.byte(data,q))
    end
end 