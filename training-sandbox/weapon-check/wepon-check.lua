script_name("Weapon-checker")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('imgui')
script_description("Weapon-checker for TRAINING")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: /wc
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local mainWindow = imgui.ImBool(false)
local v = nil
local isTrainingSanbox = false
local input_ammo = imgui.ImInt(1000)
local combobox_weaponselect = imgui.ImInt(0)

local weaponNames = {
    [0] = 'Fists',
    [1] = 'Brass Knuckles',
    [2] = 'Golf Club',
    [3] = 'Nightstick',
    [4] = 'Knife',
    [5] = 'Baseball Bat ',
    [6] = 'Shovel',
    [7] = 'Pool Cue',
    [8] = 'Katana',
    [9] = 'Chainsaw',
    [10] = 'Purple Dildo',
    [11] = 'Dildo',
    [12] = 'Vibrator',
    [13] = 'Silver Vibrator',
    [14] = 'Flowers',
    [15] = 'Cane',
    [16] = 'Grenade',
    [17] = 'Tear Gas',
    [18] = 'Molotov Cocktail',
    [19] = '##',
    [20] = '##',
    [21] = '##',
    [22] = 'Pistol',
    [23] = 'Silent Pistol',
    [24] = 'Desert Eagle',
    [25] = 'Shotgun',
    [26] = 'Sawnoff Shotgun',
    [27] = 'Combat Shotgun',
    [28] = 'Micro SMG/Uzi',
    [29] = 'MP5',
    [30] = 'AK-47',
    [31] = 'M4',
    [32] = 'Tec-9',
    [33] = 'Contry Riffle',
    [34] = 'Sniper Riffle',
    [35] = 'RPG',
    [36] = 'HS Rocket',
    [37] = 'Flame Thrower',
    [38] = 'Minigun',
    [39] = 'Satchel charge',
    [40] = 'Detonator',
    [41] = 'Spraycan',
    [42] = 'Fire Extiguisher',
    [43] = 'Camera',
    [44] = 'Nigh Vision Goggles',
    [45] = 'Thermal Goggles',
    [46] = 'Parachute'
}

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("wc", toggleMainWindow)

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
   -- sampGetCurrentServerName() returns a value with a long delay
   -- unlike receiving the IP and port. Therefore, for correct operation, the code is placed here      
   local servername = sampGetCurrentServerName()
   
   if servername:find("TRAINING") then
      isTrainingSanbox = true
   end
      
   local sizeX, sizeY = getScreenResolution()
   
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('WC', mainWindow)
      
      imgui.TextColoredRGB("{FF0000}Использование данных функций триггерит античит!")
      imgui.TextColoredRGB("{FF0000}НЕ ИСПОЛЬЗУЙТЕ их на публичных серверах")
      
      local weapon = getCurrentCharWeapon(playerPed)
      local ammo = getAmmoInCharWeapon(playerPed, weapon)
      local slot = getWeapontypeSlot(weapon)
      if weapon == 0 then 
         imgui.Text(u8"Нет оружия на руках")
      else
         if ammo then 
            imgui.TextColoredRGB(string.format("Оружие: %s (slot: %d id: %d) ", 
            weaponNames[weapon], slot, weapon))
            if weapon > 15 and weapon < 44 then
               imgui.SameLine()
               imgui.TextColoredRGB(string.format(" Патроны: %d", ammo)) 
            end
         end
      end
      imgui.Text(tostring(combobox_weaponselect.v))
      imgui.SameLine()
      imgui.PushItemWidth(185)
      imgui.Combo(u8'##weapons', combobox_weaponselect, weaponNames)
      imgui.SameLine()
      
      imgui.SameLine()
      imgui.Text(u8"кол-во")
      imgui.SameLine()
      imgui.PushItemWidth(54)
      imgui.InputInt("##inputAmmo", input_ammo, 0)
      imgui.PopItemWidth()
      

      if imgui.TooltipButton(u8"Забрать оружие", imgui.ImVec2(150, 25), u8"Забрать текущее оружие для себя (/delgun)") then
         removeWeaponFromChar(playerPed, combobox_weaponselect.v)
      end
      imgui.SameLine()
      if imgui.TooltipButton(u8"Забрать ВСЕ оружие", imgui.ImVec2(150, 25), u8"Забрать ВСЕ оружие для себя (/delguns)") then
         for i = 1, 46 do
            removeWeaponFromChar(playerPed, i)
         end
      end
      imgui.SameLine()
      if imgui.TooltipButton(u8'Выдать оружие', imgui.ImVec2(120, 25), u8"Выдать себе оружие (читерский метод)") then
         if combobox_weaponselect.v == 1 or combobox_weaponselect.v == 0 then
            sampAddChatMessage("Сперва выберите оружие которое хотите получить", -1)
         elseif combobox_weaponselect.v == 19 or combobox_weaponselect.v == 20
         or combobox_weaponselect.v == 21 then
            sampAddChatMessage("Пустой слот не может быть добавлен", -1)
         else
            local model = getWeapontypeModel(combobox_weaponselect.v)
            requestModel(model)
            loadAllModelsNow()
            giveWeaponToChar(playerPed, combobox_weaponselect.v, input_ammo.v)
         end
      end
      if isTrainingSanbox then
         if imgui.TooltipButton(u8"Обнулить оружие", imgui.ImVec2(150, 25), u8"Системно обнулить оружие себе (/rw)") then
            sampSendChat("/rw")
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Взять тазер", imgui.ImVec2(150, 25), u8"Системно обнулить оружие себе (/taser)") then
            sampSendChat("/taser")
         end
         imgui.SameLine()
      
         if imgui.TooltipButton(u8'Взять легально', imgui.ImVec2(120, 25), u8"Выдать себе оружие (серверной командой)") then
            if combobox_weaponselect.v == 1 or combobox_weaponselect.v == 0 then
               sampAddChatMessage("Сперва выберите оружие которое хотите получить", -1)
            elseif combobox_weaponselect.v == 19 or combobox_weaponselect.v == 20
            or combobox_weaponselect.v == 21 then
               sampAddChatMessage("Пустой слот не может быть добавлен", -1)
            else
               sampSendChat(("/givegun %i %i %i"):format(getLocalPlayerId(), combobox_weaponselect.v, input_ammo.v))
            end
         end
      end
      
      if imgui.TooltipButton(u8'Таблица всех характеристик оружия', imgui.ImVec2(250, 25), u8"Открыть таблицу всех характеристик оружия онлайн") then
         os.execute('explorer ""https://github.com/Southclaws/samp-weapon-data/blob/master/weapon-data.inc')
      end
      
      imgui.Spacing()
      imgui.End()
   end
end

function toggleMainWindow()
   mainWindow.v = not mainWindow.v
end

-- imgui widgets
function explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
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