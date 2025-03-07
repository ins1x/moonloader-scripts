script_dependencies('imgui')
-- Template: imgui base window
-- script_moonloader(16) moonloader v.0.26
-- activation: /activate
local imgui = require 'imgui'

local mainWindow = imgui.ImBool(false)
local v = nil

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("activate", toggleMainWindow)

   while true do
      imgui.Process = mainWindow.v
      
      wait(0)
   end
end

function imgui.OnDrawFrame()
   
   local sizeX, sizeY = getScreenResolution()
   
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Main', mainWindow)

      imgui.Text("Example imgui window")
 
      imgui.Spacing()
      imgui.End()
   end
end

function toggleMainWindow()
   mainWindow.v = not mainWindow.v
end
