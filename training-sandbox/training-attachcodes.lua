script_name("training-attachcodes")
script_description("TRAINING-SANDBOX ui for attach codes")
script_dependencies('imgui, lib.samp.events')
script_url("https://github.com/ins1x/moonloader-scripts")
script_authors("1NS")
-- Require CLEO 4.0+, SAMPFUNCS 5.4.0+, Moonloader 0.26+ (lib SAMP.Lua)
-- editor options: tabsize 3, Windows (CR LF), encoding Windows-1251
-- script_moonloader(16) moonloader v.0.26
-- activation: /attcodes
-- NOTICE: Attachment export is suspended due to irrelevance, use Common sets
local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local attCodes = {
   "CC49-45A5-1EC8-4A50", -- пикачу
   "21A4-748E-6B0B-4000", -- хедкраб
   "CFB5-5106-DEC3-4F74", -- день рождения
   "2E5A-3E8C-2D9F-4055", -- деловой ананимас
   "7773-50CB-370A-48C9", -- пингвин
   "1A4B-E5ED-6A03-41FA", -- немец
   "31F0-321B-86E3-4A4F", -- самурай
   "8286-DCEB-1BC4-4322", -- бабочка
   "D52-818A-E71D-4B89", -- енот
}

local attCodeNames = {
   u8"пикачу", u8"хедкраб", u8"день рождения", u8"деловой ананимас",
   u8"пингвин", u8"немец", u8"самурай", u8"бабочка", u8"енот"
}

-- imgui elements
local mainWindow = imgui.ImBool(false)
local v = nil
local comboboxattname = imgui.ImInt(0)
local attachcode = imgui.ImBuffer(32)

local dialoghook = {
   attachcode = false,
   autoattach = false,
}
   
function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   -- sampRegisterChatCommand("/attcodes", toggleMainWindow)
   attachcode.v = tostring(attCodes[comboboxattname.v+1])
   while true do
      -- Imgui menu
      imgui.RenderInMenu = false
      imgui.ShowCursor = true
      imgui.LockPlayer = false
      imgui.Process = mainWindow.v
      wait(0)
   end
end

function imgui.OnDrawFrame()
   local sizeX, sizeY = getScreenResolution()
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Att codes', mainWindow)

      imgui.Spacing()
      imgui.Text(u8"Применить сет аттачей по коду:")
      imgui.PushItemWidth(170)
      imgui.InputText("##TxtBufferAttachcode", attachcode)
      imgui.PopItemWidth()
      imgui.PushItemWidth(125)
      imgui.SameLine()
      if imgui.Combo(u8'##Attname', comboboxattname, attCodeNames) then
         attachcode.v = attCodes[comboboxattname.v+1]
      end
      
      if imgui.Button(u8"Сбросить",imgui.ImVec2(150, 25)) then
         attachcode.v = attCodes[comboboxattname.v+1]
         sampSendChat("/mn")
         lua_thread.create(function()
            wait(50)
            sampSendChat("/mn")
            wait(200)
            sampSendDialogResponse(32700, 1, 3, "Наборы аттачей")
            wait(5)
            sampSendDialogResponse(32700, 1, 1, "Очистить надетые аттачи")
         end)
      end
      imgui.SameLine()
      if imgui.Button(u8"Протестировать",imgui.ImVec2(150, 25)) then
         dialoghook.attachcode = true
         dialoghook.autoattach = true
         sampSendChat("/code")
         sampAddChatMessage("[SCRIPT]: {FFFFFF}Демонстрация сета - "..u8:decode(attCodeNames[comboboxattname.v+1]), 0x0FF6600)
      end

      imgui.Spacing()
      imgui.End()
   end
end

function toggleMainWindow()
   sampAddChatMessage("test", -1)
   mainWindow.v = not mainWindow.v
end

function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
   if dialogId == 32700 then
      if button == 0 then 
         dialoghook.attachcode = false
      end
      
      if button == 1 and dialoghook.attachcode then
         dialoghook.attachcode = false
      end
   end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
   if dialogId == 32700 then
      if text:find('Введите код') then
         if dialoghook.autoattach and dialoghook.attachcode then
            lua_thread.create(function()
               wait(200)
               sampSetCurrentDialogEditboxText(attachcode.v)
               wait(50)
               sampCloseCurrentDialogWithButton(1)
            end)
         else
            dialoghook.attachcode = true
            --LastData.lastTextBuffer = "CC49-45A5-1EC8-4A50"
            local newtext = "\
            Например: сет аттачей - Пикачу {cdcdcd}CC49-45A5-1EC8-4A50\
            Нажмите CTRL + SHIFT + V чтобы вставить этот пример."
            return {dialogId, style, title, button1, button2, text..newtext}
         end
      end
   end
end

function sampev.onSendCommand(command) 
   if command:find("^/attcodes") then
      mainWindow.v = not mainWindow.v
      return false
   end
end