script_name("Abike")
script_description("Pressing W on the bike automatically accelerates it")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.1")

local bikeModel = {[481] = true, [509] = true, [510] = true}

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)

      if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
         if isCharOnAnyBike(playerPed) and isKeyDown(0x57) then
            if bikeModel[getCarModel(storeCarCharIsInNoSave(playerPed))] then
               setGameKeyState(16, 255)
               wait(10)
               setGameKeyState(16, 0)
            end
         end
      end
   end
end