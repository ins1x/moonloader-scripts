script_name("fixBikeCam")
script_description("Switches the camera mode to long range and back, when getting on and off the bike")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('lib.samp.events')
script_version("0.1")
script_author("1NS")
-- encoding.default = 'CP1251'
-- script_moonloader(16) moonloader v.0.26
-- activation: auto
local sampev = require 'lib.samp.events'

function sampev.onSendEnterVehicle(vehicleId, passenger)
   if isCharOnAnyBike(playerPed) then 
      setCameraZoom(1)
   end
end

function sampev.onSendExitVehicle(vehicleId)
   if isCharOnAnyBike(playerPed) then 
      setCameraZoom(2)
      restoreCamera()
   end
end
