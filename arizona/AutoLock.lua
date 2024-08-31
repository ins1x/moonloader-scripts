script_name("AutoLock")
script_description("Auto lock vehicle")
-- Automatically locks your vehicle, and automatically 
-- opens locked vehicles when you press F or ENTER
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.3")
script_author("1NS")
-- encoding.default = 'CP1251'
-- script_moonloader(16) moonloader v.0.26
-- activation: auto

local lastVehicleHandle = nil

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      if isCharInAnyCar(playerPed) then 
         lastVehicleHandle = storeCarCharIsInNoSave(playerPed)
      end
      if isKeyDown(0x0D) or isKeyDown(0x46) then -- Enter/F
         if not sampIsChatInputActive() and not sampIsDialogActive() then
            if isCharInAnyCar(playerPed) then
               local currentcarhandle = storeCarCharIsInNoSave(playerPed)
               local currentcarDoorStatus = getCarDoorLockStatus(currentcarhandle)
               if currentcarDoorStatus ~= 2 then 
                  wait(500)
                  sampSendChat("/lock")
               end
            else
               if lastVehicleHandle then
                 local doorStatus = getCarDoorLockStatus(lastVehicleHandle)
                 if doorStatus > 0 then -- if doors locked unlock them
                    wait(500)
                    sampSendChat("/lock")
                 end
               end
            end
         end
      end
      -- L key bind to /lock vehicle
      --if isKeyJustPressed(76) and not sampIsChatInputActive() and not sampIsDialogActive() then
         --sampSendChat("/lock")
      --end
   end
end

