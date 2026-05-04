script_name("training-txtmacro")
script_description("Adds text macros at CB-like format")
script_authors("1NS")
script_dependencies('lib.samp.events')
script_url("https://github.com/ins1x/moonloader-scripts")
-- forked from MappingToolkit
-- Require: CLEO 4.0+, SAMPFUNCS 5.4.0+, Moonloader 0.26+ (lib SAMP.Lua)
-- Editor options: tabsize 3, Windows (CR LF), encoding Windows-1251
-- Server: Created for TRAINING-SANDBOX SERVER https://training-server.com
-- Activation: Auto

local sampev = require 'lib.samp.events'

function sampev.onSendChat(message)
   -- Text macros in TRAINING style format
   -- https://forum.training-server.com/d/10021-tekstovye-komandy-funktsii-kb
   local text = message
   local formatted = false
   local posX, posY, posZ = getCharCoordinates(playerPed)
   
   if message:match("#skin#") then
      formatted = true
      text = text:gsub("#skin#", tostring(getCharModel(playerPed)))
   end
   
   if message:match("#playerid#") then
      formatted = true
      text = text:gsub("#playerid#", tostring(getLocalPlayerId()))
   end
   
   if message:match("#nickname#") then
      formatted = true
      text = text:gsub("#nickname#", tostring(sampGetPlayerNickname(getLocalPlayerId())))
   end
   
   if message:match("#name#") then
      formatted = true
      text = text:gsub("#name#", tostring(sampGetPlayerNickname(getLocalPlayerId())))
   end
   
   if message:match("#x#") then
      formatted = true
      text = text:gsub("#x#", string.format("%.2f", posX))
   end
   
   if message:match("#y#") then
      formatted = true
      text = text:gsub("#y#", string.format("%.2f", posY))
   end
   
   if message:match("#z#") then
      formatted = true
      text = text:gsub("#z#", string.format("%.2f", posZ))
   end
   
   if message:match("#xyz#") then
      formatted = true
      text = text:gsub("#xyz#", string.format("%.2f %.2f %.2f", posX, posY, posZ))
   end
   
   if message:match("#fa#") then
      formatted = true
      local angle = math.ceil(getCharHeading(playerPed))
      text = text:gsub("#fa#", string.format("%.2f", angle))
   end
   
   if message:match("#speed#") then
      formatted = true
      if isCharInAnyCar(playerPed) then
         local vehicle = storeCarCharIsInNoSave(playerPed)
         local speed = getCarSpeed(vehicle)
         text = text:gsub("#speed#", tostring(speed))
      else
         local speed = getCharSpeed(playerPed)
         text = text:gsub("#speed#", string.format("%.1f", speed))
      end
   end
   
   if message:match("#gun#") then
      formatted = true
      text = text:gsub("#gun#", tostring(getCurrentCharWeapon(playerPed)))
   end
   
   if message:match("#health#") then
      formatted = true
      text = text:gsub("#health#", tostring(sampGetPlayerHealth(playerPed)))
   end
   
   if message:match("#armor#") then
      formatted = true
      text = text:gsub("#armor#", tostring(sampGetPlayerArmor(playerPed)))
   end
   
   if message:match("#ping#") then
      formatted = true
      text = text:gsub("#ping#", tostring(sampGetPlayerPing(playerPed)))
   end
   
   if message:match("#score#") then
      formatted = true
      text = text:gsub("#score#", tostring(sampGetPlayerScore(playerPed)))
   end
   
   if message:match("#time#") then
      formatted = true
      local hours, mins = getTimeOfDay()
      text = text:gsub("#time#", string.format("%d", hours))
   end
   
   if message:match("#weather#") then
      formatted = true
      text = text:gsub("#weather#", string.format("%d", LastData.lastWeather))
   end
   
   if message:match("#wanted#") then
      formatted = true
      local result, level = storeWantedLevel(playerPed)
      text = text:gsub("#wanted#", tostring(level))
   end
   
   if message:match("#vehicle#") then
      formatted = true
      if isCharInAnyCar(playerPed) then
         local carhandle = storeCarCharIsInNoSave(playerPed)
         local streamed, carId = sampGetVehicleIdByCarHandle(carhandle)
         text = text:gsub("#vehicle#", tostring(carId))
      end
   end
   
   if message:match("#vehModel#") then
      formatted = true
      if isCharInAnyCar(playerPed) then
         local carhandle = storeCarCharIsInNoSave(playerPed)
         text = text:gsub("#vehModel#", tostring(getCarModel(carhandle)))
      end
   end
   
   if message:match("#vehName#") then
      formatted = true
      if isCharInAnyCar(playerPed) then
         local carhandle = storeCarCharIsInNoSave(playerPed)
         text = text:gsub("#vehName#", 
         tostring(VehicleNames[getCarModel(carhandle)-399]))
      end
   end
   
   if message:match("#vehHealth#") then
      formatted = true
      if isCharInAnyCar(playerPed) then
         local carhandle = storeCarCharIsInNoSave(playerPed)
         text = text:gsub("#vehHealth#", tostring(getCarHealth(carhandle)))
      end
   end
   
   if message:match("#zone#") then
      formatted = true
      zone = getZoneName(posX, posY, posZ)
      text = text:gsub("#zone#", tostring(zone))
   end
   
   if message:match("#timestamp#") then
      formatted = true
      text = text:gsub("#timestamp#", tostring(os.time(os.date("!*t"))))
   end
   
   if message:match("#date#") then
      formatted = true
      text = text:gsub("#date#", tostring(os.date("%d.%m.%Y")))
   end
   
   if message:match("#hour#") then
      formatted = true
      text = text:gsub("#hour#", tostring(os.date("%H")))
   end
   
   if message:match("#min#") then
      formatted = true
      text = text:gsub("#min#", tostring(os.date("%M")))
   end
   
   if message:match("#sec#") then
      formatted = true
      text = text:gsub("#sec#", tostring(os.date("%S")))
   end
   
   if message:match("#online#") then
      formatted = true
      local tmpplayers = {}
      for i = 0, sampGetMaxPlayerId(false) do
         if sampIsPlayerConnected(i) then
            table.insert(tmpplayers, i)
         end
      end
      local online = tonumber(#tmpplayers)
      text = text:gsub("#online#", tostring(online))
   end
   
   if message:match("#randomPlayer#") then
      formatted = true
      local tmpplayers = {}
      for i = 0, sampGetMaxPlayerId(false) do
         if sampIsPlayerConnected(i) then
            table.insert(tmpplayers, i)
         end
      end
      local rand = math.random(tonumber(#tmpplayers))
      local player = tmpplayers[rand]
      text = text:gsub("#randomPlayer#", tostring(player))
   end
   
   if message:match("#random.(%d.*).#") then
      formatted = true
      local result = message:match("#random.(%d.*).#")
      local tmp = {}
      for token in string.gmatch(result, "[%d]+") do
         table.insert(tmp, token)
      end
      local randomnum = math.random(tmp[1], tmp[2])
      text = text:gsub("#random.(.*).#", tostring(randomnum))
   end
   
    if message:match("#gunName#") then
      formatted = true
      local weapon = getCurrentCharWeapon(playerPed)
      text = text:gsub("#gunName#", tostring(weaponNames[weapon]))
   end
   
   if message:match("#getGunName.(%d.*).#") then
      formatted = true
      local result = message:match("#getGunName.(%d.*).#")
      text = text:gsub("#getGunName.(%d.*).#", 
      tostring(weaponNames[tonumber(result)]))
   end
   
   if message:match("#getVehName.(%d.*).#") then
      formatted = true
      local result = message:match("#getVehName.(%d.*).#")
      local res, carhandle = sampGetCarHandleBySampVehicleId(tonumber(result))
      text = text:gsub("#getVehName.(%d.*).#", 
      tostring(VehicleNames[getCarModel(carhandle)-399]))
   end
   
   if message:match("#getPlayerName.(%d.*).#") then
      formatted = true
      local result = message:match("#getPlayerName.(%d.*).#")
      text = text:gsub("#getPlayerName.(%d.*).#", 
      tostring(sampGetPlayerNickname(result)))
   end
   
   if ini.settings.chatprefix > 0 then
      formatted = true
      text = chatPrefixList[combobox.chatprefix.v+1].." "..text
      if ini.settings.chatprefix >= 4 then
         sampSendChat(text)
         formatted = false
         return false
      end
   end
   
   if formatted then
      return {text}
   end
   formatted = false
      
end