script_author("1NS")
script_name("absRemoveDupObjects")
script_description("Remove duplicate objects for Absolute Play servers")
script_url("https://github.com/ins1x/moonloader-scripts")
-- script_moonloader(16) moonloader v.0.26

-- It's actual only for Absolute Play servers
-- Script remove duplicated trees, props and other map objects
-- SAMP Addon already have this fixes

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local isAbsoluteRoleplay = false
local removed_objects = {647, 1410, 1412, 1413} 
local restored_objects = {3337, 3244, 3276, 1290, 1540} 

-- options
local mapfixes = true
local restoreremovedobjects = false
local debugmode = false

-- macros
function isLookingAtPlayer()
   return readMemory(0xB6F028+0x2B, 1, true) == 1
end

function round(num, idp)
   local mult = 10^(idp or 0)
   return math.floor(num * mult + 0.5) / mult
end

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
      while not isSampAvailable() do wait(100) end
	  
      -- MapFix
      if mapfixes then
         -- restore statue on spawn LS
         local tmpobjid = createObject(2744, 423.1, -1558.3, 26.3)
         setObjectHeading(tmpobjid, 202.8)
         
         -- replacing invisible roadsign by tree
         createObject(700, 724.05, 1842.88, 4.9)
      end
      
      --- END init
      while true do
      wait(0)
      
      local servername = sampGetCurrentServerName()
      -- Unload script if not localhost server and not is Absolute
      if isLookingAtPlayer() then
         local ip, port = sampGetCurrentServerAddress()
         
         if not ip:find("127.0.0.1") then
            if not servername:find("Absolute") and
            not servername:find("Абсолют") then
               thisScript():unload()
            end
         end
      end
      
      if servername:find("Абсолют") then
         isAbsoluteRoleplay = true
      end
	  
	  -- delete trash objects fences 
	  if restoreremovedobjects then
	     for _, v in pairs(getAllObjects()) do
			local model = getObjectModel(v)
			for key, value in ipairs(removed_objects) do
			   if model == value then 
			      if doesObjectExist(v) then deleteObject(v) end 
			   end 
			end
		 end
	  end
	  
      -- END main
   end
end

-- SAMP EVENTS HOOKS
function sampev.onCreateObject(objectId, data)
   -- Fix Crash the game when creating a crane object 1382
   if data.modelId == 1382 then return false end
   
   if mapfixes then 
      -- Fix double created objects 
      if data.modelId == 16563 and round(data.position.x, 3) == -222.195 then 
         return false
      end
      
      if data.modelId == 6431 and round(data.position.x, 4) == -233.8828 then 
         return false
      end
       
      if data.modelId == 6421 and round(data.position.x, 4) == 137.3984 then
         return false
      end
      
      if data.modelId == 8849 and round(data.position.x, 4) == 2764.1797 then
         return false
      end
      
      if data.modelId == 1344 and round(data.position.x, 4) == 2764.9766 then
         return false
      end
      
      if data.modelId == 6399 and round(data.position.x, 4) == 552.4297 then
         return false
      end
      
      if data.modelId == 7510 and round(data.position.x, 4) == 1370.3594 then
         return false
      end
      
      if data.modelId == 640 then
         if round(data.position.x, 4) == 1335.8281
         or round(data.position.x, 4) == 1302.2266 then
            return false
         end
      end
      
      -- LS1 Tramps trees
      if data.modelId == 672 then
         print(objectId, data.position.x)
         if round(data.position.x, 3) == -149.336 then
            return false
         end
         if round(data.position.x, 1) == -140.6 then
            return false
         end
         if round(data.position.x, 3) == -112.477 then
            return false
         end
         if round(data.position.x, 2) == -15.21 then
            return false
         end
         if round(data.position.x, 2) == -35.71 then
            return false
         end
      end
      
      -- Debug
      if debugmode then
         if data.modelId == 672 then -- change model here
            local px, py, pz = getCharCoordinates(PLAYER_PED)
            local distance = string.format("%.0f", 
            getDistanceBetweenCoords3d(data.position.x, data.position.y, data.position.z, px, py, pz))
            print(("id: %i, model: %i, dist: %.0f, oPosX: %f, oRoundPosX: %.3f")
            :format(objectId, data.modelId, distance, data.position.x, round(data.position.x, 4)))
         end
      end
   end
end

function sampev.onRemoveBuilding(modelId, position, radius)
   if restoreremovedobjects then
	  return false
   else 
      for key, value in ipairs(restored_objects) do
         if modelId == value then 
            return false
         end
      end   
   end
end
-- END hooks
