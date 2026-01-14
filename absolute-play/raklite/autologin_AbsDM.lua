require "addon"
local sampev = require("samp.events")
-- Simple AutoLogin for raksamp lite
-- server: Absolute Play DM 185.71.66.21:7777
-- libs: samp events https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua
-- script for raksamp lite https://github.com/YashasSamaga/RakSAMP
-- more info about raksamp lite API https://www.blast.hk/threads/108052/

-- Change password here
local password = "your_passwor_here"

function sampev.onShowDialog(id, style, title, btn1, btn2, text)
   if id == 1 then -- (1 == LOGIN_DIALOG)
      local servername = getServerName()
      -- Absolute DM Play | GTA-SAMP.COM
      if servername:find("Absolute DM Play") then
         sendDialogResponse(id, 1, -1, password)
         return false
      end
   end
   -- Skip clan info dialog
   if id == 333 or title:find("Информация о клане")then
      sendDialogResponse(id, 1, 0, "")
      return false
   end
end
