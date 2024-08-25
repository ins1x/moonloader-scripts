script_name("Abike")
script_description("Pressing W on the bike or skate automatically accelerates it")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.2")

local bikeModel = {[481] = true, [509] = true, [510] = true, [15882] = true}
local accelDelay = 200

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)

      if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
         if isCharOnAnyBike(playerPed) and isKeyDown(0x57) then
            if bikeModel[getCarModel(storeCarCharIsInNoSave(playerPed))] then
               if accelDelay > 10 then 
                  accelDelay = accelDelay - 10
               end
               setGameKeyState(16, 255)
               wait(accelDelay)
               setGameKeyState(16, 0)
            end
         else
            accelDelay = 200
         end
      end
   end
end