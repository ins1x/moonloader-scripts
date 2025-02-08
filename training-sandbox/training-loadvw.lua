script_name("training-loadvw")
script_description("Adds arguments to the /loadvw command")
script_authors("1NS")
script_dependencies('lib.samp.events')
script_url("https://forum.training-server.com/d/17909-lua-autologin-v1")

-- Require: 
-- CLEO 4.0+, SAMPFUNCS 5.4.0+, Moonloader 0.26+ (lib SAMP.Lua)
-- Editor options: 
-- tabsize 3, Windows (CR LF), encoding Windows-1251
-- Server:
-- Created for TRAINING-SANDBOX SERVER https://training-server.com
-- Forum topic: https://forum.training-server.com/d/20601-predlozheniya-loadvw
-- Activation: Auto

local ev = require 'lib.samp.events'

local worldNumber = nil
local hookLoadWorldDialog = false

function ev.onShowDialog(dialogId, style, title, button1, button2, text)
   if dialogId == 32700 then
      if title:find("Загрузка мира") then
         if worldNumber then
            lua_thread.create(function()
               sampSendDialogResponse(32700, 1, worldNumber)
               sampCloseCurrentDialogWithButton(1)
               hookLoadWorldDialog = false
            end)
         end
      end
   end
end

function ev.onServerMessage(color, text)
   if text:find("Мир успешно загружен") 
   or text:find("Не используйте данную функцию часто") then
      hookLoadWorldDialog = false
      worldNumber = nil
   end
end

function ev.onSendCommand(command)
   -- hook /loadvw command
   if command:find("^/loadvw") then
      if command:find('(/%a+) (.+)') then
         local cmd, arg = command:match('(/%a+) (.+)')
         local id = tonumber(arg)
         if type(id) == "number" then
            worldNumber = id
            hookLoadWorldDialog = true
         end
      end
   end
end