script_description("Hook player exit reason demo")
script_dependencies('lib.samp.events')

local sampev = require 'lib.samp.events'

function sampev.onPlayerQuit(id, reason)
   local nick = sampGetPlayerNickname(id)
   
   if reason == 0 then desc = 'Выход'
   elseif reason == 1 then desc = 'Кик/бан'
   elseif reason == 2 then desc = 'Вышло время подключения'
   end
   
   sampAddChatMessage("Игрок " .. nick .. " вышел по причине: " .. desc, 0x00FF00)
end