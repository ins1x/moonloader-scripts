script_name("absForumChecker")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_dependencies('imgui')
script_description("Forum checker for Absolute Play")
script_properties("work-in-pause")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activation: /forum
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local mainWindow = imgui.ImBool(false)
local v = nil
local chosenplayer = nil
local combositelogsource = imgui.ImInt(0)

local textbuffer = {
   findplayer = imgui.ImBuffer(32),
   findlog = imgui.ImBuffer(128),
   ckeckplayer = imgui.ImBuffer(32)
}

local absServersNames = {
   'Deathmatch', 'Platinum', 'Titanium', 'Chromium', 'Aurum', 'Litium'
}

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("forum", toggleMainWindow)

   imgui.Process = true
   wait(-1)
end

function imgui.OnDrawFrame()
   local sizeX, sizeY = getScreenResolution()
   if mainWindow.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Absolute forum checker', mainWindow)
      
      imgui.Text(u8"Интерфейс взаимодействия с сайтом")
      imgui.SameLine()
      imgui.SameLine()
      imgui.PushItemWidth(120)
      imgui.Combo(u8'##ComboBoxSelectSiteLogSrc', combositelogsource, absServersNames, #absServersNames)
      imgui.PopItemWidth()
      
      local serverprefix = ""
      if combositelogsource.v == 0 then
         serverprefix = string.lower(absServersNames[1])
      elseif combositelogsource.v == 1 then
         serverprefix = string.lower(absServersNames[2])
      elseif combositelogsource.v == 2 then
         serverprefix = string.lower(absServersNames[3])
      elseif combositelogsource.v == 3 then
         serverprefix = string.lower(absServersNames[4])
      elseif combositelogsource.v == 4 then
         serverprefix = string.lower(absServersNames[5])
      elseif combositelogsource.v == 5 then
         serverprefix = string.lower(absServersNames[6])
      end
      
      if imgui.Button(u8"Логи действий администрации",imgui.ImVec2(230, 25)) then
         os.execute('explorer https://gta-samp.ru/adminhistory-'..serverprefix)
      end
      imgui.SameLine()
      if imgui.Button(u8"Логи смены никнеймов",imgui.ImVec2(230, 25)) then
         os.execute('explorer https://gta-samp.ru/nickchange-'..serverprefix)
      end 
      
      if imgui.Button(u8"История регистрации аккаунтов",imgui.ImVec2(230, 25)) then
         os.execute('explorer https://gta-samp.ru/reg-'..serverprefix)
      end
      imgui.SameLine()
      if combositelogsource.v == 0 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.sa-mp.ru/index.php?/topic/802952-%D0%BF%D1%80%D0%B0%D0%B2%D0%B8%D0%BB%D0%B0-dm-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0/')
         end
      elseif combositelogsource.v == 1 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.gta-samp.ru/index.php?/forum/125-%D0%B2%D0%B0%D0%B6%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C/')
         end
      elseif combositelogsource.v == 2 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.gta-samp.ru/index.php?/forum/108-%D0%B8%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F-%D0%B8-%D0%BF%D1%80%D0%B0%D0%B2%D0%B8%D0%BB%D0%B0/')
         end
      elseif combositelogsource.v == 3 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.gta-samp.ru/index.php?/forum/177-%D0%B2%D0%B0%D0%B6%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C/')
         end
      elseif combositelogsource.v == 4 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.gta-samp.ru/index.php?/forum/200-%D0%B2%D0%B0%D0%B6%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C/')
         end
      elseif combositelogsource.v == 5 then
         if imgui.Button(u8"Полный список правил",imgui.ImVec2(230, 25)) then
            os.execute('explorer https://forum.gta-samp.ru/index.php?/forum/392-%D0%B2%D0%B0%D0%B6%D0%BD%D0%BE-%D0%B7%D0%BD%D0%B0%D1%82%D1%8C/')
         end
      end
      
      if imgui.Button(u8"Администрация онлайн",imgui.ImVec2(230, 25)) then
         sampSendChat("/admin")
         dialog.main.v = not dialog.main.v 
      end
      if combositelogsource.v == 0 then
         imgui.SameLine()
         if imgui.Button(u8"Список администрации на сайте",imgui.ImVec2(230, 25)) then
            os.execute('explorer "https://forum.gta-samp.ru/index.php?/topic/655150-%D1%81%D0%BF%D0%B8%D1%81%D0%BE%D0%BA-%D0%B0%D0%B4%D0%BC%D0%B8%D0%BD%D0%BE%D0%B2/"') 
         end
      end
      
      if imgui.Button(u8"Список транспорта и хвр-ки", imgui.ImVec2(230, 25)) then
         os.execute('explorer "https://forum.sa-mp.ru/index.php?/topic/1023608-faq-%D1%81%D0%BF%D0%B8%D1%81%D0%BE%D0%BA-%D1%82%D1%80%D0%B0%D0%BD%D1%81%D0%BF%D0%BE%D1%80%D1%82%D0%B0-%D1%81%D0%BA%D0%BE%D1%80%D0%BE%D1%81%D1%82%D1%8C-%D0%BD%D0%B5%D0%BE%D0%B1%D1%85%D0%BE%D0%B4%D0%B8%D0%BC%D1%8B%D0%B9-%D1%83%D1%80%D0%BE%D0%B2%D0%B5%D0%BD%D1%8C-%D1%86%D0%B5%D0%BD%D0%B0/"') 
      end
      imgui.SameLine()
      if imgui.Button(u8"Все о SAMP Addon",imgui.ImVec2(230, 25)) then
         os.execute('explorer "https://forum.sa-mp.ru/index.php?/topic/1107880-%D0%B2%D1%81%D0%B5-%D0%BE-samp-addon/#comment-8807432"') 
      end
      
      imgui.Text("")
      imgui.Text(u8"Поиск в логе действий администрации по ключевому слову:")
      imgui.PushItemWidth(385)
      if imgui.InputText("##FindLogs", textbuffer.findlog) then
      end
      imgui.PopItemWidth()
      imgui.SameLine()
      if imgui.Button(u8"Найти",imgui.ImVec2(70, 25)) then
         if string.len(textbuffer.findlog.v) > 0 then
            local link = string.format('explorer "https://gta-samp.ru/adminhistory-'..serverprefix..'?year=%i&month=%i&searchtext=%s"',
            os.date('%Y'),os.date('%m'), u8:decode(textbuffer.findlog.v))
            os.execute(link)
         end
      end
      
      imgui.Text(u8"Узнать историю аккаунта:")
      if chosenplayer then
         local nickname = sampGetPlayerNickname(chosenplayer)
         local ucolor = sampGetPlayerColor(chosenplayer)
         
         imgui.SameLine()
         imgui.Selectable(string.format(u8"выбрать игрока %s[%d]", nickname, chosenplayer))
         if imgui.IsItemClicked() then
            if not dialog.playerstat.v then dialog.playerstat.v = true end
         end
      end
      imgui.PushItemWidth(150)
      if imgui.InputText("##CheckPlayer", textbuffer.ckeckplayer) then
         for k, v in ipairs(getAllChars()) do
            local res, id = sampGetPlayerIdByCharHandle(v)
            if res then
               local nickname = sampGetPlayerNickname(id)
               if nickname == u8:decode(textbuffer.ckeckplayer.v) then
                  chosenplayer = sampGetPlayerIdByNickname(nickname)
               end
            end
         end
      end
      imgui.PopItemWidth()
      imgui.SameLine()
      if imgui.Button(u8"по никнейму",imgui.ImVec2(150, 25)) then
         if string.len(textbuffer.ckeckplayer.v) > 0 then
            local link = 'explorer "https://gta-samp.ru/server-'..serverprefix..'?Nick='..u8:decode(textbuffer.ckeckplayer.v)..'"'
            os.execute(link)
         end
      end 
      imgui.SameLine()
      if imgui.Button(u8"по номеру аккаунта",imgui.ImVec2(150, 25)) then
         if string.len(textbuffer.ckeckplayer.v) > 0 and tonumber(textbuffer.ckeckplayer.v) then
            local link = 'explorer "https://gta-samp.ru/server-'..serverprefix..'?Accid='..u8:decode(textbuffer.ckeckplayer.v)..'"'
            os.execute(link)
         end
      end 

      imgui.Spacing()
      imgui.End()
   end
end

function toggleMainWindow()
   mainWindow.v = not mainWindow.v
end

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
   
   colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
   colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
   colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
   colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
   colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
   colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
   colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
   colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
   colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
   colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
   colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
   colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
   colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
   colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
   colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
   colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
   colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
   colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
   colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
   colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
   colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
   colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
   colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
   colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
   colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
   colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
   colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
   colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
   colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
   colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
   colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
   colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
   colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
   colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
   colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end

applyCustomStyle()