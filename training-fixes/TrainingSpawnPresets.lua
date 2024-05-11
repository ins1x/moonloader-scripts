script_name("TrainingSpawnPresets")
script_author("1NS")
script_url("https://training-server.com/")
script_description("After world spawn it sets the weather and time on TRAINING")
-- encoding: windows-1251

local sampev = require 'lib.samp.events'
-- Change Server IP here
-- NOTE: samp.training-server.com:7777 not working, need IP address!!
local ipTraining = "46.174.50.168"
local firstSpawn = true

-- Default values can be changed here
local skinid = 230
local weatherid = 1
local time = 12

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- unload script if connected another server
   local ip, port = sampGetCurrentServerAddress()
   if not ip:find(ipTraining) then
	  thisScript():unload()
   end
end

function sampev.onSendSpawn()
   if firstSpawn then 
      sampSendChat("/skin "..skinid)
      firstSpawn = false
   end
end

function sampev.onServerMessage(color, text)
   if text:find("Виртуальный мир успешно создан") 
   or text:find("Вы создали пробный VIP мир") then 
      sampSendChat("/weather "..weatherid)
      lua_thread.create(function()
         wait(1000)
         sampSendChat("/time "..time)
      end)
   end
end    