script_name("sindex")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('samp-events')
script_description("Adds /sindex and /rindex command for the map editor on Absolute Play")
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
   if command:find("/sindex") and isAbsolutePlay then
      if LastObject.handle and doesObjectExist(LastObject.handle) then
         setMaterialObject(LastObject.id, 1, 0, 18646, "MatColours", "red", 0xFFFFFFFF) 
         setMaterialObject(LastObject.id, 1, 1, 18646, "MatColours", "green", 0xFFFFFFFF)         
         setMaterialObject(LastObject.id, 1, 2, 18646, "MatColours", "blue", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 3, 18646, "MatColours", "yellow", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 4, 18646, "MatColours", "lightblue", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 5, 18646, "MatColours", "orange", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 6, 18646, "MatColours", "redlaser", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 7, 18646, "MatColours", "grey", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 8, 18646, "MatColours", "white", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 9, 7910, "vgnusedcar", "lightpurple2_32", 0xFFFFFFFF)
         setMaterialObject(LastObject.id, 1, 10, 19271, "MapMarkers", "green-2", 0xFFFFFFFF) -- dark green
         --setMaterialObjectText(LastObject.id, 2, 0, 100, "Arial", 255, 0, 0xFFFFFF00, 0xFF00FF00, 1, "0")
         sampAddChatMessage("Режим визуального просмотра индексов включен. Каждый индекс соответсвует цвету с таблицы.", 0x000FF00)
         sampAddChatMessage("{FF0000}0 {008000}1 {0000FF}2 {FFFF00}3 {00FFFF}4 {FF4FF0}5 {dc143c}6 {808080}7 {FFFFFF}8 {800080}9 {006400}10", -1)
      else
         sampAddChatMessage("Последний созданный объект не найден", 0x000FF00)
      end
      return false
   end
   
   if command:find("/rindex") then
      if isAbsolutePlay then
         if LastObject.handle and doesObjectExist(LastObject.handle) then
            for index = 0, 15 do 
               setMaterialObject(LastObject.id, 1, index, LastObject.modelid, "none", "none", 0xFFFFFFFF)
            end
            sampAddChatMessage("Режим визуального просмотра индексов отключен", 0x000FF00)
         else
            sampAddChatMessage("Последний созданный объект не найден", 0x000FF00)
         end
      end
      return false
   end
end
    
