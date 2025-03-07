function getClosestObjectId()
   local closestId = nil
   mydist = 20
   local px, py, pz = getCharCoordinates(playerPed)
   for _, v in ipairs(getAllObjects()) do
      if isObjectOnScreen(v) then
         local _, x, y, z = getObjectCoordinates(v)
         local dist = getDistanceBetweenCoords3d(x, y, z, px, py, pz)
         if dist <= mydist and dist >= 1.0 then -- 1.0 to ignore attached objects
            mydist = dist
            closestId = v
         end
      end
   end
   return closestId
end

function getClosestPlayerId()
   local closestId = -1
   mydist = 30
   local x, y, z = getCharCoordinates(playerPed)
   for i = 0, 999 do
      local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
      if streamed and getCharHealth(pedID) > 0 and not sampIsPlayerPaused(pedID) then
         local xi, yi, zi = getCharCoordinates(pedID)
         local dist = getDistanceBetweenCoords3d(x, y, z, xi, yi, zi)
         if dist <= mydist then
            mydist = dist
            closestId = i
         end
      end
   end
   return closestId
end

function getClosestCar()
   -- return 2 values: car handle and car id
   local minDist = 9999
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