script_name("hideNewYearTXD")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Hide NewYear tree textdraw on Absolute Play")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: auto
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'

local isAbsolutePlay = false
 
function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   while true do
   wait(0)
      -- sampGetCurrentServerName() returns a value with a long delay
      -- unlike receiving the IP and port. Therefore, for correct operation, the code is placed here      
      local servername = sampGetCurrentServerName()
      if servername:find("Absolute") then
         isAbsolutePlay = true
      end
      if servername:find("Абсолют") then
         isAbsolutePlay = true
      end
   end
end

function sampev.onShowTextDraw(id, data)
   if isAbsolutePlay then
      if id >= 87 and id <= 100 then
         return false
      end
   end
end


