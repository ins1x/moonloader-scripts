script_name("gpsoff")
script_description("Add cmd /gpsoff to disable /gps checkpoints")
script_url("https://github.com/ins1x/moonloader-scripts")
script_author("1NS")
-- moonloader 0.26+

-- Activation: type cmd /gpsoff or press key G on vehicle (only for driver)
function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   sampRegisterChatCommand("gpsoff", disableCheckpoint)
   --wait(-1)
   while true do 
      if isKeyDown(0x47) and isCharInAnyCar(PLAYER_PED) then
         if getDriverOfCar(getCarCharIsUsing(PLAYER_PED)) ~= -1 then
            disableCheckpoint()
         end
      end
      wait(0) 
   end
end

function disableCheckpoint()
   --Just send this RPC to disable the checkpoint.
   local bs = raknetNewBitStream()
   raknetEmulRpcReceiveBitStream(39, bs)
   raknetDeleteBitStream(bs)
end