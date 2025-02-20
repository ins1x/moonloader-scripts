script_name("mini-calc")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('imgui')
script_description("mini-calc")
-- demo version

-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: /calc

local imgui = require 'imgui'
-- imgui settings
local mainWindow = imgui.ImBool(false)
local v = nil
local buffer = imgui.ImBuffer(32)
local input = imgui.ImBuffer(16)
local buttonSizeX = 30
local buttonSizeY = 30
-- calc variables
local numberOne = nil
local numberTwo = nil
local isFloat = false
-- operations divide, summ etc
local operation = nil

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("calc", toggleMainWindow)

   while true do
      imgui.Process = mainWindow.v
      
      -- Hide dialog on ESC or TAB
      if isKeyJustPressed(0x1B) or isKeyJustPressed(0x09) 
      or isKeyJustPressed(0x51) and isInputAllowed() then 
         if mainWindow.v then mainWindow.v = false end
      end 
      -- Hook input numbers
      if isInputAllowed() and mainWindow.v then
         -- Backspace
         if isKeyJustPressed(0x08)then 
            buffer.v = string.sub(buffer.v, 0, string.len(buffer.v)-1);
            input.v = string.sub(input.v, 0, string.len(input.v)-1);
         end
         
         -- Hook input numbers
         if isKeyJustPressed(0x30) or isKeyJustPressed(0x60) then 
            addSymbolToBuffer("0")
         end
         if isKeyJustPressed(0x31) or isKeyJustPressed(0x61) then 
            addSymbolToBuffer("1")
         end
         if isKeyJustPressed(0x32) or isKeyJustPressed(0x62) then 
            addSymbolToBuffer("2")
         end
         if isKeyJustPressed(0x33) or isKeyJustPressed(0x63) then 
            addSymbolToBuffer("3")
         end
         if isKeyJustPressed(0x34) or isKeyJustPressed(0x64) then 
            addSymbolToBuffer("4")
         end
         if isKeyJustPressed(0x35) or isKeyJustPressed(0x65) then 
            addSymbolToBuffer("5")
         end
         if isKeyJustPressed(0x36) or isKeyJustPressed(0x66) then 
            addSymbolToBuffer("6")
         end
         if isKeyJustPressed(0x37) or isKeyJustPressed(0x67) then 
            addSymbolToBuffer("7")
         end
         if isKeyJustPressed(0x38) or isKeyJustPressed(0x68) then 
            addSymbolToBuffer("8")
         end
         if isKeyJustPressed(0x39) or isKeyJustPressed(0x69) then 
            addSymbolToBuffer("9")
         end
         
         if isKeyJustPressed(0x6A) then --Multiply key
            local result = string.match(buffer.v, ".*[^%d]$")
            if not result then
               operation = "*"
               calc(operation)
            end
         end
         
         if isKeyJustPressed(0x6B) then --Add key
            local result = string.match(buffer.v, ".*[^%d]$")
            if not result then
               operation = "+"
               calc(operation)
            end
         end
         
         if isKeyJustPressed(0x6D) then --Substract key
            local result = string.match(buffer.v, ".*[^%d]$")
            if not result then
               operation = "-"
               calc(operation)
            end
         end
         
         if isKeyJustPressed(0x6E) then --Decimal key
            addSymbolToBuffer(".")
         end
         
         if isKeyJustPressed(0x6F) then --Divide key
            local result = string.match(buffer.v, ".*[^%d]$")
            if not result then
               operation = "/"
               calc(operation)
            end
         end
         
         if isKeyJustPressed(0x0D) or isKeyJustPressed(0xBB) then --Enter key
            calc(operation)
         end  
         
      end      
      wait(0)
   end
end

function imgui.OnDrawFrame()

   local sizeX, sizeY = getScreenResolution()
   
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('mini-calc', mainWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
      
      imgui.Text(tostring(buffer.v))
      
      imgui.PushItemWidth(buttonSizeX * 4.5)
      if imgui.InputText("##Display", input, imgui.InputTextFlags.CharsDecimal) then
         --result = tonumber(buffer)
      end
      imgui.PopItemWidth()
      
      if imgui.Button(" C ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         isFloat = false
         input.v = ""
         numberOne = nil
         numberTwo = nil
         operation = nil
         --operation = none
      end
      imgui.SameLine()
      if imgui.Button(" CE ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         isFloat = false
         buffer.v = ""
         input.v = ""
         numberOne = nil
         numberTwo = nil
         operation = nil
      end
      imgui.SameLine()
      if imgui.Button(" <X ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         --buffer.v = string.format("%s9", buffer.v)
         --buffer.v = string.sub(buffer.v, 0, string.len(buffer.v)-1);
         input.v = string.sub(input.v, 0, string.len(input.v)-1);
      end
      imgui.SameLine()
      if imgui.Button(" / ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         local result = string.match(buffer.v, ".*[^%d]$")
         if not result then
            operation = "/"
            calc(operation)
         end
      end
      
      if imgui.Button(" 7 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("7")
      end
      imgui.SameLine()
      if imgui.Button(" 8 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("8")
      end
      imgui.SameLine()
      if imgui.Button(" 9 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("9")
      end
      imgui.SameLine()
      if imgui.Button(" x ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         local result = string.match(buffer.v, ".*[^%d]$")
         if not result then
            operation = "*"
            calc(operation)
         end
      end
      
      if imgui.Button(" 4 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("4")
      end
      imgui.SameLine()
      if imgui.Button(" 5 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("5")
      end
      imgui.SameLine()
      if imgui.Button(" 6 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("6")
      end
      imgui.SameLine()
      if imgui.Button(" - ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         local result = string.match(buffer.v, ".*[^%d]$")
         if not result then
            operation = "-"
            calc(operation)
         end
      end
      
      if imgui.Button(" 1 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("1")
      end
      imgui.SameLine()
      if imgui.Button(" 2 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("2")
      end
      imgui.SameLine()
      if imgui.Button(" 3 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("3")
      end
      imgui.SameLine()
      if imgui.Button(" + ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         local result = string.match(buffer.v, ".*[^%d]$")
         if not result then
            operation = "+"
            calc(operation)
         end
      end
      
      if imgui.Button(" +- ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         if string.match(buffer.v, "^-.*$") then
            buffer.v = string.sub(buffer.v, 1, string.len(buffer.v));
            input.v = string.sub(input.v, 1, string.len(input.v));
         else
            buffer.v = string.format("-%s", buffer.v)
            input.v = string.format("-%s", input.v)
         end
      end
      imgui.SameLine()
      if imgui.Button(" 0 ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         addSymbolToBuffer("0")
      end
      imgui.SameLine()
      if imgui.Button(" , ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
        if not isFloat then
           addSymbolToBuffer(",")
           isFloat = true
        end
      end
      imgui.SameLine()
      if imgui.Button(" = ", imgui.ImVec2(buttonSizeX, buttonSizeY)) then
         calc(operation)
      end
      
      imgui.Spacing()
      imgui.End()
   end
end

function calc(operation)
   local numbers = string.match(buffer.v, "%d")
   if numbers and operation then
      if numberOne then
         numberTwo = tonumber(input.v)
         --local result = string.match(buffer.v, "%d.*%d$")
         
         if numberTwo then
            addSymbolToBuffer("=")
            if operation == "+" then
               input.v = tostring(numberOne + numberTwo)
            elseif operation == "-" then
               input.v = tostring(numberOne - numberTwo)
            elseif operation == "/" then
               input.v = tostring(numberOne / numberTwo)
            elseif operation == "*" then
               input.v = tostring(numberOne * numberTwo)
            end
            buffer.v = string.format("%s"..tostring(input.v), buffer.v)
         end
         numberOne = nil
         numberTwo = nil
      else
         numberOne = tonumber(input.v)
         -- local result = string.match(input.v, ".*[^%d]$")
         -- if not result then
         addSymbolToBuffer(operation)
      end
   end
end

function addSymbolToInput(symbol)
   if string.match(symbol, "%d") then
      input.v = string.format("%s"..symbol, input.v)
   else
      input.v = ""
   end
end

function addSymbolToBuffer(symbol)
   buffer.v = string.format("%s"..symbol, buffer.v)
   if string.match(symbol, "%d") then
      input.v = string.format("%s"..symbol, input.v)
   else
      input.v = ""
   end
end

function isInputAllowed()
   if not sampIsChatInputActive() 
   and not sampIsDialogActive() and not isPauseMenuActive() 
   and not isSampfuncsConsoleActive() then 
      return true
   else
      return false
   end
end

function toggleMainWindow()
   mainWindow.v = not mainWindow.v
end

-- color theme
function applyCustomStyle()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2
   
   style.WindowPadding = imgui.ImVec2(8, 8)
   style.WindowRounding = 6
   style.ChildWindowRounding = 5
   style.FramePadding = imgui.ImVec2(5, 3)
   style.FrameRounding = 3.0
   style.ItemSpacing = imgui.ImVec2(5, 4)
   style.ItemInnerSpacing = imgui.ImVec2(4, 4)
   style.IndentSpacing = 21
   style.ScrollbarSize = 10.0
   style.ScrollbarRounding = 13
   style.GrabMinSize = 8
   style.GrabRounding = 1
   style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
   style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
   
   colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
   colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
   colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
   colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
   colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
   colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
   colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
   colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
   colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
   colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
   colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
   colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
   colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
   colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
   colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
   colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
   colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
   colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
   colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
   colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
   colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
   colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

applyCustomStyle()