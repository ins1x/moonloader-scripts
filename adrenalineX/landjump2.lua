script_name("landjump2")
script_description("visually places a landjump in front of the vehicle")
-- Activation: Key <P> (on vehilce)

function main()
   while true do wait(0)
      if isKeyJustPressed(0x50) and isCharInAnyCar(PLAYER_PED) 
      and not sampIsCursorActive() then -- 0x50 (VK_P)
         lua_thread.create(function() 
            local car = storeCarCharIsInNoSave(PLAYER_PED)
            local q1, q2, q3 = getOffsetFromCarInWorldCoords(car, 0, 14.5, -1.3)
            local obj = createObject(1634, q1, q2, q3) -- landjump2
            setObjectHeading(obj, getCarHeading(car))
            wait(4500)
            deleteObject(obj)
         end)
      end
   end
end