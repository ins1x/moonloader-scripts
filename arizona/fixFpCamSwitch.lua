-- Fix Halloween 2024 auto FirstPerson mode switch
script_name("fixFpCamSwitch")
script_description("Fix Halloween 2024 auto FirstPerson mode switch")
script_url("https://github.com/ins1x/moonloader-scripts")

local sampev = require 'lib.samp.events'
local firstSpawn = false
local isArizona = false

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      local servername = sampGetCurrentServerName()
      if not servername:find("Arizona") then
         isArizona = true
      end
   end
end

function sampev.onSendSpawn()
-- Press V to switch camera after spawn
   if not firstSpawn then
      lua_thread.create(function()
         wait(1000)
         setVirtualKeyDown(0x56, true) 
         wait(500) 
         setVirtualKeyDown(0x56, false)
         firstSpawn = true
         if not isArizona then
            thisScript():unload()
         end
      end)
   end
end