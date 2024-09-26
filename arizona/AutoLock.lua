script_name("AutoLock")
script_description("Auto lock vehicle")
-- Automatically locks your vehicle, and automatically 
-- opens locked vehicles when you press F or ENTER
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.5")
script_author("1NS")
-- encoding.default = 'CP1251'
-- script_moonloader(16) moonloader v.0.26
-- activation: auto

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      if isKeyJustPressed(0x0D) or isKeyJustPressed(0x46) then -- Enter/F
         if not sampIsChatInputActive() and not sampIsDialogActive() then
            if isCharInAnyCar(playerPed) then
               local currentcarhandle = storeCarCharIsInNoSave(playerPed)
               local currentcarDoorStatus = getCarDoorLockStatus(currentcarhandle)
               if currentcarDoorStatus ~= 2 then 
                  wait(500)
                  sampSendChat("/lock")
               end
            else
               -- Will work on vehicles within a radius of 3 meters
               local closestcarhandle, closestcarid = getClosestCar(3)
               if closestcarhandle then
                  wait(500) 
                  sampSendChat("/lock")   
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

function getClosestCar(minDist)
   -- TIP: return 2 values: car handle and car id
   local closestId = -1
   local closestHandle = false
   local x, y, z = getCharCoordinates(playerPed)
   for i, k in ipairs(getAllVehicles()) do
      local streamed, carId = sampGetVehicleIdByCarHandle(k)
      if streamed then
         local xi, yi, zi = getCarCoordinates(k)
         local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
         if dist < minDist then
            minDist = dist
            closestId = carId
            closestHandle = k
         end
      end
   end
   return closestHandle, closestId
end

