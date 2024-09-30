script_name("ocolor")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Adds /ocolor command to apply color to an object on Absolute Play")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: auto
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'

local isAbsolutePlay = false

local LastObject = {
   id = nil,
   handle = nil,
   modelid = nil
}

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

function sampev.onSendEditObject(playerObject, objectId, response, position, rotation)
   -- response: 0 - exit edit, 1 - save, 2 - move
   local object = sampGetObjectHandleBySampId(objectId)
   local modelId = getObjectModel(object)
   LastObject.handle = object
   LastObject.id = objectId
   LastObject.modelid = modelId
end

function sampev.onSendEnterEditObject(type, objectId, model, position)
   LastObject.id = objectId
   LastObject.modelid = model
end

function sampev.onSendCommand(command)
   if isAbsolutePlay then
      if command:find("/ocolor") or command:find("/mtcolor") then
         if command:find('(.+) (.+)') then
            local cmd, arg = command:match('(.+) (.+)')
            local ocolor = tostring(arg)
            if string.len(ocolor) < 10 or not ocolor:find("0x") then
               sampAddChatMessage("Формат цвета 0xAARGBRGB", -1)
               return false
            end
         
            if LastObject.handle and doesObjectExist(LastObject.handle) then
               for index = 0, 15 do 
                  setMaterialObject(LastObject.id, 1, index, LastObject.modelid, "none", "none", arg)
               end
               sampAddChatMessage("Установлен цвет ".. ocolor .." последнему созданному объекту", 0x000FF00)
            else
               sampAddChatMessage("Последний созданный объект не найден", -1)
            end
         else
            sampAddChatMessage("Формат цвета 0xAARGBRGB", -1)
         end
         return false
      end
      
      if command:find("/untexture") then
         if LastObject.handle and doesObjectExist(LastObject.handle) then
            for index = 0, 15 do 
               setMaterialObject(LastObject.id, 1, index, LastObject.modelid, "none", "none", 0xFFFFFFFF)
            end
            sampAddChatMessage("Режим визуального просмотра индексов отключен", 0x000FF00)
         else
            sampAddChatMessage("Последний созданный объект не найден", 0x000FF00)
         end
         return false
      end
   end
end
    
