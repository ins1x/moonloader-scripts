script_author("1NS")
script_name("STO Helper Lite")
script_description("A helper for working at a service station")
script_dependencies("imgui")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.3 lite")
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activaton: F2 (show main menu) or command /sto

local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8

local inicfg = require 'inicfg'
local configIni = "sto-helper.ini"
local ini = inicfg.load({
   settings =
   {
      roleplayactions = false,
      license = false,
      debugmode = false,
      hotkey = "0x71", 
      sendchatdelay = 550
   },
}, configIni)
inicfg.save(ini, configIni)

local mainWindowState = imgui.ImBool(false)
local openedTab = 1
local addMessageCooldown = nil -- cooldown /vr Add

-- imgui elements
local input = {
   adtext = imgui.ImBuffer(128),
   services = imgui.ImBuffer(512)
}

local checkbox = {
   roleplayactions = imgui.ImBool(ini.settings.roleplayactions),
   license = imgui.ImBool(ini.settings.license)
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
      
      imgui.SetNextWindowSize(imgui.ImVec2(380, 340), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin("STO-helper [lite]", mainWindowState)
      
      if imgui.Button(u8"Действия",imgui.ImVec2(75, 30)) then openedTab = 1 end
      imgui.SameLine()
      if imgui.Button(u8"Услуги",imgui.ImVec2(75, 30)) then openedTab = 2 end
      imgui.SameLine()
      if imgui.Button(u8"Реклама",imgui.ImVec2(75, 30)) then openedTab = 3 end
      imgui.SameLine()
      if imgui.Button(u8"Помощь",imgui.ImVec2(75, 30)) then openedTab = 4 end
      imgui.SameLine()
      if imgui.Button(u8"( ? )",imgui.ImVec2(40, 30)) then openedTab = 0 end
      
      imgui.Spacing()
      imgui.Spacing()
      imgui.Spacing()
      
      if openedTab == 0 then
      
         imgui.Text(u8"Помошник для механиков СТО на Arizona-Roleplay.")
         imgui.Text(u8"Эксклюзивная версия для сервера Red-Rock.")
         imgui.Text(u8"Версия: "..tostring(thisScript().version))
         imgui.Spacing()
         imgui.Text(u8"Автор: 1NS (Insane_RedRock)")
         imgui.Text("Git: https://github.com/ins1x/moonloader-scripts")
         imgui.Text("YouTube: https://www.youtube.com/@1nsanemapping")
         imgui.Spacing()
         imgui.Text(u8"Скачивайте скрипт только с доверенных источников")
         imgui.Text(u8"Не скачивайте со сторонних сайтоы и соцсетей")
         imgui.Text(u8"Оригинальная версия распостраняется бесплатно")
         imgui.Text(u8"и только с открытым исходным кодом")
         
      elseif openedTab == 1 then
      
         if imgui.Checkbox(u8("Использовать отыгровки"), checkbox.roleplayactions) then
            ini.settings.roleplayactions = checkbox.roleplayactions.v
            inicfg.save(ini, configIni)
         end
         imgui.SameLine()
         if imgui.Button(u8"Помощь по работе",imgui.ImVec2(175, 25)) then
            sampSendChat("/jobhelp")
            mainWindowState.v = false
         end
         
         imgui.Text(u8"Действия:")
         imgui.Spacing()
         if imgui.Button(u8"Поприветствовать", imgui.ImVec2(175, 25)) then 
            lua_thread.create(function()
               sampSendChat("Здравствуйте, что необходимо сделать?")
               wait(ini.settings.sendchatdelay)
               if ini.settings.roleplayactions then
                  sampSendChat("/me Визуально осмотрел автомобиль")
               end
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Попрощаться",imgui.ImVec2(175, 25)) then 
            sampSendChat("Хорошего дня, заезжайте к нам")
         end
         
         if imgui.Button(u8"Застрахуйте",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Ваш транспорт незастрахован, обслуживание недоступно.")
               wait(ini.settings.sendchatdelay)
               sampSendChat("Застраховать транспорт можно в страховой компании СФ.")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Лицензия",imgui.ImVec2(175, 25)) then 
            sampSendChat("Лицензированный механик, могу выполнять все виды работ")
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
               if ini.settings.roleplayactions then
                  wait(ini.settings.sendchatdelay)
                  sampSendChat("/me Ожидает информацию с техпаспорта")
               end
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Покажите техпаспорт",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Покажите ваш техпаспорт /carpass "..id)
               if ini.settings.roleplayactions then
                  wait(ini.settings.sendchatdelay)
                  sampSendChat("/me Ожидает")
               end
            end)
         end
         
         if imgui.Button(u8"Большой транспорт в ФК",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Ваш транспорт слишком большой! Вам необходимо ехать на СТО в Форт Карсон.")
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Займите платформу",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Займите платформу, для начала обслуживания вашего транспорта")
            end)
         end
         
         if imgui.Button(u8"Поблагодарить",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Спасибо вам, счастливого пути!")
               if ini.settings.roleplayactions then
                  wait(ini.settings.sendchatdelay)
                  sampSendChat("/me Выражает почтение")
               end
            end)
         end
         imgui.SameLine()
         if imgui.Button(u8"Прогнать",imgui.ImVec2(175, 25)) then
            lua_thread.create(function()
               sampSendChat("Покиньте платформу, не занимайте рабочее место")
            end)
         end
         
      elseif openedTab == 2 then
      
         if imgui.Checkbox(u8("У меня есть лицензия механика"), checkbox.license) then
            if checkbox.license.v then
               sampAddChatMessage("Вы подтвердили наличие лицензии. Клиентам можно будет предлагать улучшения.", -1)
               sampAddChatMessage("Если у вас ее все же нет, советуем получить в Центре Лицензирования СФ", -1)
            end
            ini.settings.license = checkbox.license.v
            inicfg.save(ini, configIni)
         end
         imgui.Text(u8"Оказываемые услуги:")
         
         for key, value in pairs(servicesList) do
            imgui.Text(u8(value))
         end
         
         if imgui.Button(u8"Сообщить список услуг СТО игроку",imgui.ImVec2(350, 25)) then 
            lua_thread.create(function()
               if ini.settings.roleplayactions then
                  sampSendChat("/me Смотрит список доступных услуг")
               end
               for key, value in pairs(servicesList) do
                  sampSendChat(value)
                  wait(ini.settings.sendchatdelay)
               end
               wait(ini.settings.sendchatdelay)
               sampSendChat("Цены указаны без учета скидок для семей*")
            end)
         end
         if imgui.Button(u8"Сообщить список улучшений",imgui.ImVec2(350, 25)) then
            if checkbox.license.v then
               lua_thread.create(function()
                  if ini.settings.roleplayactions then
                     sampSendChat("/me Смотрит список доступных улучшений")
                  end
                  for key, value in pairs(servicesList) do
                     if key == 4 or key > 5 then 
                        sampSendChat(value)
                        wait(ini.settings.sendchatdelay)
                     end
                  end
                  wait(ini.settings.sendchatdelay)
                  sampSendChat("Цены указаны без учета скидок для семей*")
               end)
            else
               sampAddChatMessage("У вас нет лицензии, советуем получить в Центре Лицензирования СФ", -1)
            end
         end
      elseif openedTab == 3 then
      
         imgui.Text(u8"Введите текст рекламы в вип-чат:")
         
         imgui.PushItemWidth(350)
	     if imgui.InputText("##adtext", input.adtext) then
         end
         imgui.PopItemWidth()
         if imgui.Button(u8"Отправить",imgui.ImVec2(175, 25)) then
            if string.len(input.adtext.v) > 3 then
               if not addMessageCooldown then addMessageCooldown = 0 end
               local lastMessageCooldown = os.clock() - addMessageCooldown
               if lastMessageCooldown > 600 then
                  addMessageCooldown = os.clock()
                  lua_thread.create(function()
                     sampSendChat("/vr "..u8:decode(input.adtext.v))
                  end)
               else
                  sampAddChatMessage("Реклама в вип-чат разрешена с интервалом в 10 минут. (Доступно через "..600-math.floor(lastMessageCooldown).." сек. )",-1)
               end
            else
               sampAddChatMessage("Сперва введите текст для оптравки!",-1)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Очистить",imgui.ImVec2(175, 25)) then
            input.adtext.v = ""
         end
         
         imgui.Text(u8"Шаблоны:")
         if imgui.Button(u8"СТО на РК (Red-Country)",imgui.ImVec2(175, 25)) then
            input.adtext.v = u8"Работает СТО в Ред Кантри, только опытные механики"
         end
         imgui.SameLine()
         if imgui.Button(u8"СТО на ФК (Fort Carson)",imgui.ImVec2(175, 25)) then
            input.adtext.v = u8"Работает СТО в Форт Карсон, только опытные механики"
         end
         imgui.Text(u8"Важно! Реклама в вип-чат разрешена с интервалом в 10 минут.")
         
         imgui.Spacing()
         imgui.Spacing()
         imgui.Text(u8"Быстрая реклама услуг:")
         if imgui.Button(u8"Предложить доп.услуги игроку рядом",imgui.ImVec2(350, 25)) then
            lua_thread.create(function()
               if ini.settings.roleplayactions then
                  wait(ini.settings.sendchatdelay)
                  sampSendChat("/me Предлагает дополнительные услуги")
               end
               sampSendChat("СТО оказвает следующие дополнительные услуги:")
               --wait(ini.settings.sendchatdelay)
               --sampSendChat("Замена масла - 235 000$, ремонт - 3 600$, восстановление состояния - 150 000$")
               wait(ini.settings.sendchatdelay)
               sampSendChat("Установить AutoLock - 414 000$, скрутить пробег (на 100 км) - 600 000$")
               wait(ini.settings.sendchatdelay)
               sampSendChat("Система уменьш. расхода масла - 1 200 000$, Система уменьш. сост. двигателя - 1 100 000$")
            end)
         end
      elseif openedTab == 4 then
      
         imgui.Text(u8"Помошник для механиков СТО на Arizona-Roleplay.")
         imgui.Spacing()
         if imgui.CollapsingHeader(u8"Лицензия механика") then
            imgui.Text(u8"Лицензия механика необходима чтобы выполнять")
            imgui.Text(u8"все виды работ на СТО. Без лицензии вам")
            imgui.Text(u8"недоступна установка улучшений")
         end
         if imgui.CollapsingHeader(u8"Устройство на СТО") then
            imgui.Text(u8"Еспы вы не устроены сотрудником в СТО,")
            imgui.Text(u8"то вы будете получать на 15% меньше оплату.")
            imgui.Text(u8"Вам нужно найти владельца/заместителя СТО")
            imgui.Text(u8"и попросить взять вас на сотрудничество")
            imgui.Text(u8"Информация о владельце будет на доске рядом с СТО")
         end
         if imgui.CollapsingHeader(u8"Как начать работу") then
            imgui.Text(u8"Вам необходимо добраться на станцию тех. обслуживания")
            imgui.Text(u8"с помощью команды /gps - Важные места.")
            imgui.Text(u8"На СТО вам нужно переодеться, занять плату на клавишу H")
            imgui.Text(u8"По прибытию клиента, подойти к капоту автомобиля")
            imgui.Text(u8"и нажать ALT. Из списка услуг выбрать нужную.")
         end
         if imgui.CollapsingHeader(u8"Сколько платят") then
            imgui.Text(u8"С ремонта авто Вы получите от $800 до $3,200")
            imgui.Text(u8"за восстановление состояния авто от $50 000 до $150 000")
            imgui.Text(u8"С установки улучшений от $500 000 до $800 000")
            imgui.Text(u8"ЗП отличается в разных штатах.")
            imgui.Text(u8"Без устройства на СТО вы будете получать на 15% меньше.")
         end
         if imgui.CollapsingHeader(u8"Команды для механика на вызове") then
            imgui.Text(u8"/repair - предложить починку автомобиля")
            imgui.Text(u8"/refill - предложить заправить автомобиль")
            imgui.Text(u8"/gcontract - подписать контракт с АЗС")
         end
         if imgui.CollapsingHeader(u8"Команды для работы в автомастерской") then
            imgui.Text(u8"/tupdate - поставить заказанные компоненты на машину")
            imgui.Text(u8"/repairdvig - починить двигатель")
            imgui.Text(u8"/endtune - закончить работу с клиентом")
         end
         imgui.Spacing()
         
      end -- openedTab END
      imgui.End()
   end
end

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   
   sampAddChatMessage("{696969}STO-helper [lite]  {FFFFFF}Открыть меню: {CDCDCD}/sto", 0xFFFFFF)
   sampRegisterChatCommand("sto", function() mainWindowState.v = not mainWindowState.v end)
   
   while true do
      wait(0)
      
      if not ini.settings.debugmode then
         local servername = sampGetCurrentServerName()
         if not servername:find("Arizona") then
            thisScript():unload()
         end
      end
      
      if isKeyJustPressed(ini.settings.hotkey) then 
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