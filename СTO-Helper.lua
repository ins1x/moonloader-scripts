script_author("1NS")
script_name("CTO Helper Lite")
script_description("A helper for working at a service station")
script_dependencies("imgui")
script_url('https://github.com/ins1x/')
script_version("0.1 beta")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activaton: (show main menu) or command /sto

local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8

local mainWindowState = imgui.ImBool(false)
local sendChatDelay = 550
local openedTab = 1

local input = {
   adtext = imgui.ImBuffer(128),
   services = imgui.ImBuffer(512)
}

local servicesList = {
   "1. Замена масла - 235 000$",
   "2. Отремонтировать - 3 600$",
   "3. Восстановить состояние - 150 000$",
   "4. Установить AutoLock - 414 000$",
   "5. Удалить AutoLock - 225 000$",
   "6. Скрутить пробег (на 100 км) - 600 000$",
   "7. Система уменьш. расхода масла - 1 200 000$",
   "8. Система уменьш. сост. двигателя - 1 100 000$"
}

function imgui.OnDrawFrame()
   if mainWindowState.v then
      local sizeX, sizeY = getScreenResolution()
      local _, id = sampGetPlayerIdByCharHandle(playerPed)
      
      imgui.SetNextWindowSize(imgui.ImVec2(400, 350), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin("CTO-Helper", mainWindowState)
      
      if imgui.Button(u8"Действия",imgui.ImVec2(75, 30)) then openedTab = 1 end
      imgui.SameLine()
      if imgui.Button(u8"Услуги",imgui.ImVec2(75, 30)) then openedTab = 2 end
      imgui.SameLine()
      if imgui.Button(u8"Реклама",imgui.ImVec2(75, 30)) then openedTab = 3 end
      imgui.SameLine()
      if imgui.Button(u8"Помощь",imgui.ImVec2(75, 30)) then openedTab = 4 end
      
      imgui.Spacing()
      
      if openedTab == 1 then
         imgui.Text(u8"Действия:")
         imgui.Spacing()
         if imgui.Button(u8"Поприветствовать", imgui.ImVec2(175, 25)) then 
            lua_thread.create(function()
               sampSendChat("Здравствуйте, что необходимо сделать?")
               wait(sendChatDelay)
               sampSendChat("/me Визуально осмотрел автомобиль")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Попрощаться",imgui.ImVec2(175, 25)) then 
            sampSendChat("Хорошего дня, заезжайте к нам")
         end
         
         if imgui.Button(u8"Застрахуйте",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Ваш транспорт незастрахован, обслуживание недоступно.")
               wait(sendChatDelay)
               sampSendChat("Застраховать транспорт можно в страховой компании СФ.")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Лицензия",imgui.ImVec2(175, 25)) then 
            sampSendChat("Лиценизия имеется, улучшения поставить можем")
         end
         
         if imgui.Button(u8"Не заправляем",imgui.ImVec2(175, 25)) then 
            sampSendChat("Не заправляем. Заправка находится рядом посмотрите в /gps")
         end
         imgui.SameLine()
         if imgui.Button(u8"Нет таких услуг",imgui.ImVec2(175, 25)) then 
            sampSendChat("Такие услуги не оказываем")
         end
         
         if imgui.Button(u8"Посмотрите техпаспорт",imgui.ImVec2(175, 25)) then 
            lua_thread.create(function()
               sampSendChat("Посмотрите информацию в техпаспорте /carpass")
               wait(sendChatDelay)
               sampSendChat("/me Ожидает информацию с техпаспорта")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Покажите техпаспорт",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Покажите ваш техпаспорт /carpass "..id)
               wait(sendChatDelay)
               sampSendChat("/me Ожидает техпаспорта")
            end)
         end
         
         if imgui.Button(u8"Поблагодарить",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Спасибо вам, счастливого пути!")
               wait(sendChatDelay)
               sampSendChat("/me Выражает почтение")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Прогнать",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Покиньте платформу, не занимайте рабочее место")
            end)
         end
      elseif openedTab == 2 then
         imgui.Text(u8"Оказываемые услуги:")
         
         -- imgui.InputTextMultiline('##services', input.services, imgui.ImVec2(350, 170),
         -- imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput + imgui.InputTextFlags.ReadOnly)
         
         for key, value in pairs(servicesList) do
            imgui.Text(u8(value))
         end
         
         if imgui.Button(u8"Сообщить список услуг СТО игроку",imgui.ImVec2(350, 25)) then 
            lua_thread.create(function()
               sampSendChat("/me Смотрит список доступных услуг")
               for key, value in pairs(servicesList) do
                  sampSendChat(value)
                  wait(sendChatDelay)
               end
               wait(sendChatDelay)
               sampSendChat("Цены указаны без учета скидок для семей*")
            end)
         end
         if imgui.Button(u8"Сообщить список улучшений",imgui.ImVec2(350, 25)) then
            lua_thread.create(function()
               sampSendChat("/me Смотрит список доступных улучшений")
               for key, value in pairs(servicesList) do
                  if key == 4 or key > 5 then 
                     sampSendChat(value)
                     wait(sendChatDelay)
                  end
               end
               wait(sendChatDelay)
               sampSendChat("Цены указаны без учета скидок для семей*")
            end)
         end
      elseif openedTab == 3 then
         imgui.Text(u8"Реклама в вип-чат:")
         imgui.Text(u8"Введите текст рекламы:")
         imgui.PushItemWidth(200)
	     if imgui.InputText("##adtext", input.adtext) then
         end
         imgui.PopItemWidth()
         if imgui.Button(u8"СТО на РК (Red-Country)",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("/vr Работает СТО в Ред Кантри, только проф. механики")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"СТО на ФК (Fort Carson)",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("/vr Работает СТО в Форт Карсон, только проф. механики")
            end)
         end
      elseif openedTab == 4 then
         imgui.Text(u8"Помошник для механиков СТО на Arizona-Roleplay.")
         imgui.Text(u8"Все функции в помошнике легиты")
         imgui.Text(u8"Вы можете использовать его не опасаясь првоерки")
         imgui.Text(u8"Скачивайте скрипт только с доверенных источников")
         imgui.Text(u8"Не скачивайте из групп и соцсетей")
         imgui.Text(u8"Оригинальная версия с исходным кодом")
         imgui.Text(u8"Публикуется только на github.com и blast.hk")
         imgui.Spacing()
         if imgui.Button(u8"Оффициальная страница",imgui.ImVec2(175, 30)) then
         end
         if imgui.Button(u8"Помощь по работе",imgui.ImVec2(175, 30)) then
            sampSendChat("/jobhelp")
            mainWindowState.v = false
         end
      end -- openedTab END
      imgui.End()
   end
end

function main()
   while true do
      wait(0)
      if isKeyJustPressed(0x71) then 
         mainWindowState.v = not mainWindowState.v
      end
      imgui.Process = mainWindowState.v
   end
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
   style.ItemSpacing = imgui.ImVec2(4, 4)
   style.ItemInnerSpacing = imgui.ImVec2(8, 6)
   style.IndentSpacing = 25.0
   style.ScrollbarSize = 15.0
   style.ScrollbarRounding = 9.0
   style.GrabMinSize = 5.0
   style.GrabRounding = 3.0

   colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
   colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
   colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
   colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
   colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
   colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
   colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
   colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()