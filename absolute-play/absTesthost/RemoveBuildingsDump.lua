script_name("removedBuildingsDump")
script_description("Save all server removed buildings to file and unload")
script_dependencies('lib.samp.events')
script_url("https://github.com/ins1x/moonloader-scripts")
-- script_moonloader(16) moonloader v.0.26

local sampev = require 'lib.samp.events'

local removedBuildings = 0
local filepath = getGameDirectory().."//moonloader//resource//RemovedBuildingsDump.txt"

-- [warning] function RemoveBuildingForPlayer
-- There appears to be a limit of around 1000 lines/objects. There is no workaround.
-- When removing the same object for a player, they will crash. Commonly, players crash when reconnecting to the server because the server removes buildings on OnPlayerConnect.
-- https://www.open.mp/docs/scripting/functions/RemoveBuildingForPlayer

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   local ip, port = sampGetCurrentServerAddress()
   
   local file = io.open(filepath, "a")
   file:write(("\n // Removed buildings dump for %s server: %s ip: %s\n"):format(tostring(os.date("%d.%m.%Y %H:%M")), sampGetCurrentServerName(), ip))
   file:write("\n\n")
   file:close()
   
end

function sampev.onRemoveBuilding(modelId, position, radius)
   removedBuildings = removedBuildings + 1;
      
   local file = io.open(filepath, "a")
   file:write(("RemoveBuildingForPlayer(playerid, %i, %.2f, %.2f, %.2f, %.2f);\n"):format(modelId, position.x, position.y, position.z, radius))
   file:close()
end

function sampev.onSendRequestSpawn()
   local file = io.open(filepath, "a")
   file:write("\nTotal removed buildings: \n"..removedBuildings)
   file:close()
   thisScript():unload()
end