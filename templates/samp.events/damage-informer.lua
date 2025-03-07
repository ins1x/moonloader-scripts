script_description("damage informer demonstration")
script_dependencies('lib.samp.events')

local sampev = require 'lib.samp.events'

function sampev.onSendTakeDamage(playerID, damage, weaponID, bodypart)
   local bodyparts = {
   [3] = "Торс",
   [4] = "Пах",
   [5] = "Левая рука",
   [6] = "Правая рука",
   [7] = "Левая нога",
   [8] = "Правая нога",
   [9] = "Голова"
   }
      
   if playerID ~= 65535 then
      sampAddChatMessage(string.format("Вам нанес урон %s(%d). Оружие: %d кол-во: %.1f (%s)", 
      sampGetPlayerNickname(playerID), playerID, weaponID, damage, bodyparts[bodypart]), -1)
   end

end