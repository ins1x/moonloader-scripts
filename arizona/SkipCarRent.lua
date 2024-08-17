script_name("SkipCarRent")
script_description("Skip car rent dialog on Arizona-Roleplay server")
script_url("https://github.com/ins1x/moonloader-scripts")
script_author("1NS")
script_dependencies('lib.samp.events')
-- script_moonloader(16) moonloader v.0.26
local sampev = require 'lib.samp.events'

-- If you need to skip the dialogues for paid rentals, set the value to false
local skipOnlyFreeRent = true

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
   if dialogId == 26013 then
      if skipOnlyFreeRent then
         if text:find("$0") then 
            lua_thread.create(function()
               wait(10)
               sampCloseCurrentDialogWithButton(0)
            end)
         end
      else -- skips anyway
         lua_thread.create(function()
            wait(10)
            sampCloseCurrentDialogWithButton(0)
         end)
      end
   end
end