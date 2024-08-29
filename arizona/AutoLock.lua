script_name("AutoLock")
script_description("Auto lock vehicle")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('lib.samp.events')
script_version("0.1")
script_author("1NS")
-- encoding.default = 'CP1251'
-- script_moonloader(16) moonloader v.0.26
-- simple autolock for my own needs
local sampev = require 'lib.samp.events'

local lastVehicleId = nil

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      if isKeyDown(0x0D) or isKeyDown(0x46) then -- Enter/F
         if not sampIsChatInputActive() and not sampIsDialogActive() then
            if lastVehicleId then
               local result, car = sampGetCarHandleBySampVehicleId(lastVehicleId)
               local doorStatus = getCarDoorLockStatus(car)
               local engineState = isCarEngineOn(car)
               if doorStatus > 0 then -- if doors locked unlock them
                  sampSendChat("/lock")
               end
            end
         end
      end
      
      -- L key
      -- if isKeyJustPressed(76) and not sampIsChatInputActive() and not sampIsDialogActive() then
         --sampSendChat("/lock")
      --end
   end
end

-- function sampev.onSendEnterVehicle(vehicleId, passenger)
   -- if not passenger then
      -- local carhandle = storeCarCharIsInNoSave(PLAYER_PED)
      -- local state = isCarEngineOn(carhandle)
   -- end
-- end

function sampev.onSendExitVehicle(vehicleId)
   lastVehicleId = vehicleId
   sampSendChat("/lock")
end
