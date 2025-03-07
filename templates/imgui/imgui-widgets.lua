script_dependencies('imgui')
-- Template: imgui window default widgets
-- script_moonloader(16) moonloader v.0.26
-- activation: /activate
local imgui = require 'imgui'

local v = nil

-- widgets
local dialog = {
   main = imgui.ImBool(false),
}
   
local checkbox = {
   democheckbox = imgui.ImBool(false),
}

local input = {
   demoinput = imgui.ImInt(5000),
}

local slider = {
   demoslider = imgui.ImFloat(1.0),
}

local textbuffer = {
   demobuffer = imgui.ImBuffer(32),
}

local combobox = {
   democombo = imgui.ImInt(0),
}

local democomboboxlist = {"combo1", "combo2", "combo3"}

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("activate", toggledialog)

   while true do
      imgui.Process = dialog.main.v
      
      -- Hide dialog on ESC
      if isKeyJustPressed(0x1B) and not sampIsChatInputActive() 
      and not sampIsDialogActive() and not isPauseMenuActive() 
      and not isSampfuncsConsoleActive() then 
         if dialog.main.v then dialog.main.v = false end
      end 
      
      wait(0)
   end
end

function imgui.OnDrawFrame()
      
   local sizeX, sizeY = getScreenResolution()
   
   if dialog.main.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Main', dialog.main)

      imgui.Text("Example imgui window")
      
      if imgui.Checkbox("demo checkbox", checkbox.democheckbox) then
         if checkbox.democheckbox.v then
            print("checkbox activated")
         end
      end
      
      if imgui.Combo('##democombobox', combobox.democombo, democomboboxlist) then
         print("input value changed to:"..tostring(combobox.democombo.v))
      end
      
      if imgui.InputInt('##demoinput', input.demoinput, 0) then
         print("input value changed to:"..tostring(input.demoinput.v))
      end
      
      if imgui.SliderInt("##demoslider", slider.demoslider, 1, 100) then
         print("slider value changed to:"..tostring(slider.demoslider.v))
      end
      
      imgui.InputTextMultiline('##demobuffer', textbuffer.demobuffer, imgui.ImVec2(100, 50))
      
      imgui.Spacing()
      imgui.End()
   end
end

function toggledialog()
   dialog.main.v = not dialog.main.v
end
