script_name("cmdhelper")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Adds tooltips for commands in the style Texture Studio")
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

function sampev.onSendCommand(command)
   -- tips for those who are used to using Texture Studio syntax
   if isAbsolutePlay then
      if command:find("texture") then
         sampAddChatMessage("Для ретекстура используйте:", 0x000FF00)
         sampAddChatMessage("N - Редактировать объект - Выделить объект - Перекарсить объект", 0x000FF00)
         return false
      end
      if command:find("showtext3d") then
         sampAddChatMessage("Для ретекстура используйте:", 0x000FF00)
         sampAddChatMessage("N - Информация о объекте", 0x000FF00)
         return false
      end
      if command:find("undo") then
         sampAddChatMessage("Недоступно на данном сервере", 0x000FF00)
         return false
      end
      if command:find("flymode") then
         sampSendChat("/полет")
         return false
      end
      if command:find("team") or command:find("setteam") then
         sampSendChat("Нельзя менять тимы. Если вы хотели изменить спавн используйте:",0x000FF00)
         sampSendChat("Y - Редактор карт - Управление миром - Выбрать точку появления",0x000FF00)
         return false
      end
      if command:find("jetpack")then
         sampAddChatMessage("Джетпак можно взять в меню: N - Оружие - Выдать себе оружие", 0x000FF00)
         return false
      end
      if command:find("dobject")then
         sampAddChatMessage("Для удаления объекта используйте:", 0x000FF00)
         sampAddChatMessage("N - Редактировать объект - Выделить объект - Удалить объект", 0x000FF00)
         return false
      end
   end 
end