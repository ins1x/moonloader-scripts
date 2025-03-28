script_author("1NS")
script_name("Scripts")
script_description("Simple scripts manager")
script_dependencies('imgui')
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.1") 
script_dependencies('imgui')

-- script_moonloader(16) moonloader v.0.26
-- activation: /scripts

local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local mainWindow = imgui.ImBool(false)
local v = nil

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("scripts", toggleMainWindow)

   while true do
      imgui.Process = mainWindow.v
      
      -- Hide dialog on ESC
      if isKeyJustPressed(0x1B) and not sampIsChatInputActive() 
      and not sampIsDialogActive() and not isPauseMenuActive() 
      and not isSampfuncsConsoleActive() then 
         if mainWindow.v then mainWindow.v = false end
      end 
      
      wait(0)
   end
end

function imgui.OnDrawFrame()
      
   local sizeX, sizeY = getScreenResolution()
   
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Scripts', mainWindow)
      imgui.SetWindowSize(imgui.ImVec2(350, 300))
      
      local _, id = sampGetPlayerIdByCharHandle(playerPed)
      local score = sampGetPlayerScore(id)
      local ip, port = sampGetCurrentServerAddress()
      local major, minor, majorRev, minorRev, game, region, steam, cracked = getGameVersion()
      local scriptParams = thisScript()
      local sampversion = getSampVersionId()
      
      --imgui.TextColoredRGB("script: {FF6600}"..scriptParams.name.."{CDCDCD} version {FF6600}"..scriptParams.version)
      if sampversion then
         imgui.TextColoredRGB("sa-mp:")
         imgui.SameLine()
         imgui.TextColoredRGB(tostring("{FF6600}0.3.7 R"..sampversion))
      end

      if not isGameVersionOriginal() then
         imgui.TextColoredRGB(string.format("{FF0000}Not original game version %s.%s.%s.%s", major, minor, majorRev, minorRev))
      end
      if steam then
         imgui.TextColoredRGB(string.format("{FF0000}Steam game version %s.%s.%s.%s", major, minor, majorRev, minorRev))
      end
         
      if imgui.CollapsingHeader(u8"Загруженные скрипты:") then
        --local major, minor, majorRev, minorRev, game, region, steam, cracked = getGameVersion()
         imgui.TextColoredRGB("directory: {FF6600}"..scriptParams.directory)
         if imgui.IsItemClicked() then
            os.execute('explorer '..getGameDirectory().."\\moonloader")
         end
         if imgui.Button(u8"Сохранить список", imgui.ImVec2(140, 25)) then
            file = io.open(getGameDirectory() ..
            "//moonloader//resource//loadedscripts.txt", "w")
            file:write("Loaded scripts:\n")
            for _, s in pairs(script.list()) do
               if string.len(s.version) > 1 then
                  file:write(string.format("- %s v%s\n", s.name, s.version))
               else
                  file:write(string.format("- %s\n", s.name))
               end
            end
            file:close()
            sampAddChatMessage("[SCRIPT]: {FFFFFF}Список был сохранен в /moonloader/resource/loadedscripts.txt", 0x0FF6600)
         end
         imgui.SameLine()
         if imgui.Button(u8"Перезагрузить все", imgui.ImVec2(140, 25)) then
            reloadScripts()
         end
         
         -- if imgui.Button(u8"Открыть папку moonloader", imgui.ImVec2(180, 25)) then
            -- os.execute('explorer '..getGameDirectory().."\\moonloader")
         -- end
         
         imgui.Text("Loaded moonloader scripts:")
         for _, s in pairs(script.list()) do
            if string.len(s.version) > 1 then
               imgui.Selectable(string.format("- %s v%s", s.name, s.version))
               if imgui.IsItemClicked() then
                  sampAddChatMessage("Название скрипта скопировано в буффер обмена", -1)
                  setClipboardText(tostring(s.name))
               end
            else
               imgui.Selectable(string.format("- %s", s.name))
               if imgui.IsItemClicked() then
                  sampAddChatMessage("Название скрипта скопировано в буффер обмена", -1)
                  setClipboardText(tostring(s.name))
               end
            end
         end
      end
      if imgui.CollapsingHeader(u8"Плагины:") then
         imgui.TextColoredRGB("SAMPFUNCS:")
         if imgui.Button(u8"Открыть папку с SF плагинами",imgui.ImVec2(200, 25)) then
            os.execute('explorer '..getGameDirectory().."\\SAMPFUNCS")
         end
         
         if imgui.Button(u8"Открыть настройки SAMPFUNCS",imgui.ImVec2(200, 25)) then
            os.execute('explorer '..getGameDirectory().."\\SAMPFUNCS\\sampfuncs-settings.ini")
         end
      end
      
      if doesDirectoryExist("modloader") then 
         if imgui.CollapsingHeader(u8"Моды:") then
            imgui.TextColoredRGB("ModLoader:")
            if imgui.Button(u8"Открыть папку с модами",imgui.ImVec2(200, 25)) then
               os.execute('explorer '..getGameDirectory().."\\modloader")
            end
            
            if imgui.Button(u8"Открыть настройки ModLoader",imgui.ImVec2(200, 25)) then
               os.execute('explorer '..getGameDirectory().."\\modloader\\modloader.ini")
            end
         end
      end

      imgui.Spacing()
      imgui.End()
   end
end

function toggleMainWindow()
   mainWindow.v = not mainWindow.v
end

function join_argb(a, r, g, b)
   local argb = b  -- b
   argb = bit.bor(argb, bit.lshift(g, 8))  -- g
   argb = bit.bor(argb, bit.lshift(r, 16)) -- r
   argb = bit.bor(argb, bit.lshift(a, 24)) -- a
   return argb
end

function explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
end
function imgui.TooltipButton(label, size, description)
   local result = imgui.Button(label, size, description)
   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(600)
      imgui.TextUnformatted(description)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
   return result
end

function imgui.TextColoredRGB(text)
   local style = imgui.GetStyle()
   local colors = style.Colors
   local ImVec4 = imgui.ImVec4

   local getcolor = function(color)
      if color:sub(1, 6):upper() == 'SSSSSS' then
         local r, g, b = colors[1].x, colors[1].y, colors[1].z
         local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
         return ImVec4(r, g, b, a / 255)
      end
      local color = type(color) == 'string' and tonumber(color, 16) or color
      if type(color) ~= 'number' then return end
      local r, g, b, a = explode_argb(color)
      return imgui.ImColor(r, g, b, a):GetVec4()
   end

   local render_text = function(text_)
      for w in text_:gmatch('[^\r\n]+') do
         local text, colors_, m = {}, {}, 1
         w = w:gsub('{(......)}', '{%1FF}')
         while w:find('{........}') do
            local n, k = w:find('{........}')
            local color = getcolor(w:sub(n + 1, k - 1))
            if color then
               text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
               colors_[#colors_ + 1] = color
               m = n
            end
            w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
         end
         if text[0] then
            for i = 0, #text do
               imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
               imgui.SameLine(nil, 0)
            end
            imgui.NewLine()
         else imgui.Text(u8(w)) end
      end
   end

   render_text(text)
end

function getSampVersionId()
   local versionid = 0
   sampdllHandle = getModuleHandle('samp.dll')
   sampdllHandle = sampdllHandle + 0x128
   versionData = readMemory(sampdllHandle, 4, true)
   if versionData == 0x5542F47A then
      versionid = 1 -- r1
   end
   if versionData == 0x59C30C94 then
      versionid = 2 -- r2
   end

   sampdllHandle = sampdllHandle - 8
   versionData = readMemory(sampdllHandle, 4, true)
   if versionData == 0x5C0B4243 then
      versionid = 3 -- r3
   end
   if versionData == 0x5DD606CD then
      versionid = 4 -- R4
   end
   -- if versionData == 0x6094ACAB then
       -- versionid = 42 -- R4-2
   -- end
   if versionData == 0x6372C39E then
      versionid = 5 --R5
   end
   return versionid
end

function apply_custom_style()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4

   style.WindowPadding = imgui.ImVec2(15, 15)
   style.WindowRounding = 1.5
   style.FramePadding = imgui.ImVec2(5, 5)
   style.FrameRounding = 4.0
   style.ItemSpacing = imgui.ImVec2(6, 4)
   style.ItemInnerSpacing = imgui.ImVec2(8, 6)
   style.IndentSpacing = 20.0
   style.ScrollbarSize = 12.0
   style.ScrollbarRounding = 9.0
   style.GrabMinSize = 5.0
   style.GrabRounding = 3.0
   
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
apply_custom_style()