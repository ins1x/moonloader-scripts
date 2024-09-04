script_author("1NS")
script_name("MP Helper")
script_description("Assistant for event makers")
script_dependencies('imgui', 'lib.samp.events')
script_properties("work-in-pause")
script_url("https://github.com/ins1x/moonloader-scripts/mphelper")
script_version("1.0")
-- fork of MappingToolkit project
-- script_moonloader(16) moonloader v.0.26
-- tested on sa-mp client version: 0.3.7 R1
-- activaton: ALT + E (show main menu) or command /events

local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

-------------- [ cfg ] ---------------
local inicfg = require 'inicfg'
local configIni = "mphelper.ini"
local ini = inicfg.load({
   settings = {
      menukeychanged = false,
      menukey = "0x2D", -- INS key
      disconnectreminder = false,
      playerwarnings = false,
   },
   warnings = {
      afk = true,
      armourrefill = true,
      heavyweapons = true,
      hprefill = true,
      illegalweapons = true,
      laggers = true,
      undermap = true, 
   },
   sidebar = {
      fontname = "Tahoma",
      fontsize = 7,
      maxlines = 10,
      mode = 0,
      x = 15,
      y = 400,
   },
   binds = {
      cmdbind1 = " ",
      cmdbind2 = " ",
      cmdbind3 = " ",
      cmdbind4 = " ",
      cmdbind5 = " ",
      cmdbind6 = " ",
      cmdbind7 = " ",
      cmdbind8 = " ",
      cmdbind9 = " "
   }
}, configIni)
inicfg.save(ini, configIni)
--------------------------------------
sidebarfont = renderCreateFont(ini.sidebar.fontname, ini.sidebar.fontsize, 5)
local sizeX, sizeY = getScreenResolution()
local v = nil

local isAbsolutePlay = false
local isTraining = false
local readonly = false
local chosenplayer = nil

local dialog = {
   main = imgui.ImBool(false),
   fastanswer = imgui.ImBool(false),
}

local tabmenu = {
   mp = 1,
}

local textbuffer = {
   mpname = imgui.ImBuffer(32),
   mpadd = imgui.ImBuffer(128),
   mpprize = imgui.ImBuffer(32),
   mpdonators = imgui.ImBuffer(128),
   mphp = imgui.ImBuffer(6),
   mparmour = imgui.ImBuffer(6),
   mpanswer = imgui.ImBuffer(64),
   mpquestion = imgui.ImBuffer(128),
   vehiclename = imgui.ImBuffer(64),
   pid = imgui.ImBuffer(4),
   sethp = imgui.ImBuffer(6),
   setarm = imgui.ImBuffer(6),
   setteam = imgui.ImBuffer(3),
   setreason = imgui.ImBuffer(32),
   setptime = imgui.ImBuffer(10),
   searchbar = imgui.ImBuffer(32),
   trytext = imgui.ImBuffer(64),
   -- large text
   gamesrules = imgui.ImBuffer(4096),
   rules = imgui.ImBuffer(65536),
}

local input = {
   addtime = imgui.ImInt(3),
   ammo = imgui.ImInt(1000),
}

local binds = {
   cmdbind1 = imgui.ImBuffer(256),
   cmdbind2 = imgui.ImBuffer(256),
   cmdbind3 = imgui.ImBuffer(256),
   cmdbind4 = imgui.ImBuffer(256),
   cmdbind5 = imgui.ImBuffer(256),
   cmdbind6 = imgui.ImBuffer(256),
   cmdbind7 = imgui.ImBuffer(256),
   cmdbind8 = imgui.ImBuffer(256),
   cmdbind9 = imgui.ImBuffer(256),
}

local combobox = {
   mpnames = imgui.ImInt(0),
   weaponselect = imgui.ImInt(0),
   setmoder = imgui.ImInt(1),
   chatselect = imgui.ImInt(0),
   textgames = imgui.ImInt(0),
   fastanswers = imgui.ImInt(0),
}

local checkbox = {
   disconnectreminder = imgui.ImBool(ini.settings.disconnectreminder),
   playerwarnings = imgui.ImBool(ini.settings.playerwarnings),
   
   hideanswer = imgui.ImBool(false),
   donators = imgui.ImBool(false),
   sidebarplayers = imgui.ImBool(false),
   streamermode = imgui.ImBool(false),
   logmp = imgui.ImBool(false),
   mpprize = imgui.ImBool(false),
   healthcheck = imgui.ImBool(false),
   trackanswer = imgui.ImBool(false),
   trygame = imgui.ImBool(false),
}

local MP = {
   autoAnnounce = false,
   StartedDTime = nil,
   EndedDTime = nil,
   Started = false
}

local LastData = {
   lastPmMessage = nil,
   lastWorldName = "",
}

local fastAnswers = {}
local playersTable = {}
local blacklist = {}
local legalweapons = {0, 1}

-- should be global!
playersTotal = 0

local mpNames = {
   'Custom', 'Race', 'Derby', 'Survival', 'PvP', 'Death-Roof', 'TDM',
   'Hide-n-Seek', 'Quiz', 'King', 'Hunt', 'Rodeo', 'Road Rash'
}

local textGames = {
   u8'NoRules', u8'Анаграммы', u8'Викторина', u8'Крокодил', 
   u8'Караоке', u8'Музыкальный марафон', u8'Загадки'
}

local weaponNames = {
	[0] = 'Fists',
	[1] = 'Brass Knuckles',
	[2] = 'Golf Club',
	[3] = 'Nightstick',
	[4] = 'Knife',
	[5] = 'Baseball Bat	',
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
   if not ini.settings.menukeychanged then
      sampAddChatMessage("{696969}MP Helper {FFFFFF}Открыть меню: {CDCDCD}ALT + E", 0xFFFFFF)
   else
      sampAddChatMessage("{696969}MP Helper {FFFFFF}Открыть меню: {CDCDCD}/mphelper", 0xFFFFFF)
   end
      
   sampRegisterChatCommand("mphelper", function() dialog.main.v = not dialog.main.v end)
   
   if not doesDirectoryExist("moonloader/resource/mphelper") then 
      createDirectory("moonloader/resource/mphelper")
   end
   
   if doesFileExist(getGameDirectory()..'\\moonloader\\resource\\mphelper\\blacklist.txt') then
      blacklistfile = io.open("moonloader/resource/mphelper/blacklist.txt", "r")
      for name in blacklistfile:lines() do
         table.insert(blacklist, name:lower())
      end
      blacklistfile:close()
   else
      blacklistfile = io.open("moonloader/resource/mphelper/blacklist.txt", "w")
      blacklistfile:write(" ")
      blacklistfile:close()
   end
   
   if doesFileExist(getGameDirectory()..'\\moonloader\\resource\\mphelper\\fastanswers.txt') then
      file = io.open("moonloader/resource/mphelper/fastanswers.txt", "r")
      for line in file:lines() do
         table.insert(fastAnswers, line:lower())
      end
      file:close()
   else
      file = io.open("moonloader/resource/mphelper/fastanswers.txt", "w")
      file:write(u8"Мероприятие уже начато - вход на МП был закрыт\n")
      file:write(u8"Вынужден был удалить вас с МП из-за ваших лагов\n")
      file:write(u8"Не мешайте игрокам - кикну\n")
      for line in file:lines() do
         table.insert(fastAnswers, line:lower())
      end
      file:close()
   end
   
   if doesFileExist(getGameDirectory()..'\\moonloader\\resource\\mphelper\\rules.txt') then
      local file = io.open(getGameDirectory()..
      "//moonloader//resource//mphelper//rules.txt", "r")
      textbuffer.rules.v = file:read('*a')
      file:close()
   else
      local file = io.open("moonloader/resource/mphelper/rules.txt", "w")
      file:write(u8"Файл поврежден либо не найден")
      file:write(u8"Скачать стандартный можно c https://github.com/ins1x/moonloader-scripts/mphelper:")
      file:close()
   end
   
   reloadBindsFromConfig()
   
   if string.len(textbuffer.mpadd.v) < 1 then
      textbuffer.mpadd.v = u8"Введите ваш рекламный текст здесь"
   end
   
   if string.len(textbuffer.mpname.v) < 1 then
      textbuffer.mpname.v = u8"Введите название"
   end
   
   if string.len(textbuffer.rules.v) < 1 then
      textbuffer.rules.v = u8"Здесь вы можете загружать правила мероприятия и лор вашего мира"
   end
   
   if string.len(binds.cmdbind1.v) < 1 then
      binds.cmdbind1.v = u8"Здесь вы можете задать свои бинды"
   end
   
   textbuffer.mpprize.v = '1'
   textbuffer.setarm.v = '100'
   textbuffer.sethp.v = '100'
   textbuffer.setteam.v = '0'
   textbuffer.setptime.v = '20'
   textbuffer.vehiclename.v = 'bmx'
   
   --textbuffer.mpadd.v = u8'Проходит МП "<название>" '
   
   while true do
      wait(0)
      -- sampGetCurrentServerName() returns a value with a long delay
      -- unlike receiving the IP and port. Therefore, for correct operation, the code is placed here      
      local servername = sampGetCurrentServerName()
      
      if servername:find("TRAINING") then
         isTraining = true
      end
      if servername:find("Absolute") then
         isAbsolutePlay = true
      end
      if servername:find("Абсолют") then
         isAbsolutePlay = true
      end
      
      if ini.settings.menukeychanged then
         if isKeyDown(tonumber(ini.settings.menukey)) 
	     and not sampIsChatInputActive() and not isPauseMenuActive() then 
            toggleMainWindow()
            if ini.panel.showpanel then 
               checkbox.showpanel.v = true
            end
         end
      else
         -- ALT+E (Main menu activation)
         if isKeyDown(0x12) and isKeyJustPressed(0x45) 
         and not sampIsChatInputActive() and not isPauseMenuActive() then 
            toggleMainWindow()
         end
      end
      
      -- Hide dialogs on ESC
      if isKeyJustPressed(0x1B) and not sampIsChatInputActive() 
      and not sampIsDialogActive() and not isPauseMenuActive() 
      and not isSampfuncsConsoleActive() then 
         if dialog.main.v then dialog.main.v = false end
         if dialog.fastanswer.v then dialog.fastanswer.v = false end
      end 
      
      -- Imgui menu
      imgui.RenderInMenu = false
      imgui.ShowCursor = true
      imgui.LockPlayer = false
      imgui.Process = dialog.main.v
      
      -- Players list render
      if checkbox.sidebarplayers.v then
         local playersTotal = 0
         local uid = getLocalPlayerId()
         
         renderFontDrawText(sidebarfont, "Streamed players:", ini.sidebar.x, ini.sidebar.y, 0xFFFFFFFF)
         
         for k, v in ipairs(getAllChars()) do
            if playersTotal >= ini.sidebar.maxlines then 
               break
            end
            
            local res, id = sampGetPlayerIdByCharHandle(v)
            if res and id ~= uid then
               local nickname = sampGetPlayerNickname(id)
               local playerstext = ""
               if sampIsPlayerPaused(id) then
	 	          playerstext = nickname.."("..id..")".." {FF0000}[AFK]{FFFFFF}"
               else
                  playerstext = nickname.."("..id..")"
               end
               playersTotal = playersTotal + 1
               renderFontDrawText(sidebarfont, playerstext, ini.sidebar.x, ini.sidebar.y + (playersTotal*15), 0xFFFFFFFF)
            end
	     end
         --renderFontDrawText(sidebarfont, "Total: {696969}"..playersTotal, ini.sidebar.x, ini.sidebar.y + 15 + (playersTotal*15), 0xFFFFFFFF)
      end
      
   end
end

-- function imgui.BeforeDrawFrame()
-- end

function imgui.OnDrawFrame()

   if dialog.main.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.SetNextWindowSize(imgui.ImVec2(640, 450))
      imgui.Begin(".::  MP Helper  ::.", dialog.main)
      
      imgui.Columns(2)
      imgui.SetColumnWidth(-1, 500)
      
      local ip, port = sampGetCurrentServerAddress()
      local servername = sampGetCurrentServerName()
      
      -- TODO Add mpadd here
      -- imgui.Spacing()
      
      -- imgui.Text("                   ")
	  -- imgui.SameLine()
      -- if imgui.Button(u8"Свернуть", imgui.ImVec2(70, 30)) then
         -- dialog.main.v = not dialog.main.v
      -- end
      
      if tabmenu.mp == 1 then
         resetIO()
         imgui.TextColoredRGB("Сервер: {007DFF}" .. servername)
         if isTraining then
            if string.len(LastData.lastWorldName) > 1 then
               imgui.SameLine()
               imgui.TextColoredRGB("Мир: "..LastData.lastWorldName)
            end
         end
         --imgui.SameLine()
         --imgui.TextColoredRGB("IP:  {686868}" .. tostring(ip) ..":".. tostring(port))
         imgui.TextColoredRGB("Дата: {686868}" .. os.date('%d.%m.%Y %X'))
         if MP.StartedDTime ~= nil then
            imgui.SameLine()
            imgui.TextColoredRGB("Началось МП в {686868}" .. MP.StartedDTime)
         end
         
         imgui.Text(u8"Название мероприятия: ")
         imgui.PushItemWidth(220)
         if imgui.InputText("##BindMpname", textbuffer.mpname) then 
         end
         imgui.PopItemWidth()
         imgui.SameLine()
	     imgui.PushItemWidth(100)
         if imgui.Combo(u8'##ComboBoxMpNames', combobox.mpnames, mpNames, #mpNames) then
            textbuffer.mpname.v = tostring(mpNames[combobox.mpnames.v + 1])
         end
         imgui.PopItemWidth()
         
         if imgui.Checkbox(u8("Режим стримера"), checkbox.streamermode) then
            if checkbox.streamermode.v then
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Streamer mode: {00FF00}Включен", 0x0FF6600)
            else
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Streamer mode: {696969}Отключен", 0x0FF6600)
            end
         end
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Скрывает ваши личные данные, и данные игроков (IP адреса, пароли, телефоны)")
         
         -- if isTraining then
            -- imgui.SameLine()
            -- if imgui.Checkbox(u8("Логи мира"), checkbox.logmp) then
               -- --if checkbox.logmp.v then
               -- if isTraining then
                  -- dialoghook.logstoggle = true
                  -- sampSendChat("/vw")
               -- end
            -- end
            -- imgui.SameLine()
            -- imgui.TextQuestion("( ? )", u8"Включает текстдрав с логами мира")
         -- end
         
         imgui.Text(u8"Место проведения:")
         if imgui.TooltipButton(u8"Выбрать интерьер", imgui.ImVec2(135, 25), u8"Выбрать интерьер из списка доступных") then
            if isTraining then
               sampSendChat("/int")
               dialog.main.v = false
            else
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Недоступно для вашего сервера", 0x0FF6600) 
            end
         end
         imgui.SameLine()
         -- if imgui.TooltipButton(u8"Сообщить местоположение", imgui.ImVec2(195, 25), u8"Сообщить ваше текущее местоположение") then
            -- sampSetChatInputEnabled(true)
            -- local positionX, positionY, positionZ = getCharCoordinates(playerPed)
            -- zone = getZoneName(positionX, positionY, positionZ)
            -- sampSetChatInputText("Находимся в районе - "..zone)
            -- dialog.main.v = false
         -- end
          imgui.SameLine()
         if imgui.TooltipButton(u8"Настр. спавн", imgui.ImVec2(100, 25), u8"Настроить спавн игроков") then
            if isTraining then
               sampSendChat("/team")
               dialog.main.v = false
            elseif isAbsolutePlay then
               sampAddChatMessage("[SCRIPT]: {FFFFFF} Y - Редактор карт - Управление миром - Выбрать точку появления", 0x0FF6600)
            end
         end
         imgui.Text(u8"Выбор капитана:")
	     if imgui.Button(u8"Игрок с наибольшим уровнем", imgui.ImVec2(220, 25)) then
	      local maxscore = {score = 0, id = 0}
	      local playerid = getLocalPlayerId()
	      for k, v in ipairs(getAllChars()) do
	         local res, id = sampGetPlayerIdByCharHandle(v)
	    	  local score = sampGetPlayerScore(v)
	         if res and v ~= playerPed then
	    	     if score > maxscore.score then
	    	        maxscore.score = score
	    		    maxscore.id = id
	    	     end
	        end
	     end
	     if maxscore.score > 0 then
	        setClipboardText(sampGetPlayerNickname(maxscore.id).. "[" .. maxscore.id .. "]")--maxscore.id
	        sampAddChatMessage("Ид и ник игрока ".. sampGetPlayerNickname(maxscore.id) .." с наибольшим уровнем скопирован в буфер обмена", -1)
	     else
	        sampAddChatMessage("Нет других игроков рядом, кого выбирать?", -1)
	     end
	     end
	     imgui.SameLine()
	     if imgui.Button(u8"Выбрать случайного игрока", imgui.ImVec2(220, 25)) then
	        if next(playersTable) == nil then -- if playersTable is empty
	         sampAddChatMessage("Сперва обнови список игроков!", -1) 
	      else
	         local rand = math.random(playersTotal)
	         chosenplayer = playersTable[rand]                
	         sampAddChatMessage("Случайный игрок: ".. sampGetPlayerNickname(playersTable[rand]), -1)
	      end
	     end
         imgui.Text(u8"Список игроков:")
         if imgui.Button(u8"Обновить список игроков МП", imgui.ImVec2(220, 25)) then
            playersTable = {}       
            playersTotal = 0
            playersfile = io.open("moonloader/resource/mphelper/players.txt", "w")
            
            for k, v in ipairs(getAllChars()) do
               local res, id = sampGetPlayerIdByCharHandle(v)
               local nickname = sampGetPlayerNickname(id)
               if res then
                  table.insert(playersTable, id)
                  playersTotal = playersTotal + 1
                  playersfile:write(nickname .. "\n")
               end
            end
            playersfile:close()
            sampAddChatMessage("Список игроков на МП обновлен. Всего игроков "..playersTotal, -1)
         end
         imgui.SameLine()
         if imgui.Button(u8"Вывести список игроков", imgui.ImVec2(220, 25)) then
            sampAddChatMessage("Список игроков:", 0xFFFFFF)
            playersList = {}
            playersfile = io.open("moonloader/resource/mphelper/players.txt", "r")
            for name in playersfile:lines() do
               table.insert(playersList, name:lower())
            end
            playersfile:close()
            maxPlayerOnline = sampGetMaxPlayerId(false)
            s = 1
            local playerId = getLocalPlayerId()
            for i = 0, maxPlayerOnline do
               if sampIsPlayerConnected(i) then
                  name = sampGetPlayerNickname(i)
                  c = 1
                  for k,n in pairs(playersList) do
                     if(name:lower() == n:lower()) then
                        sampAddChatMessage("{FFFFFF}" .. s .. ". {34EB46}" .. name .. " (" .. i .. ")", 0xFFFFFF)
                        table.remove(playersList, c)
                        s = s + 1
                     end 
	                 c = c + 1
                  end
               end
            end
            
            for k, n in pairs(playersList) do
               name = sampGetPlayerNickname(playerId)
               if(name:lower() == n:lower()) then
                  sampAddChatMessage("{FFFFFF}" .. s .. ". {CDCDCD}" .. n .. " {FFD700}(EVENTMAKER)", 0xFFFFFF)
               else
                  sampAddChatMessage("{FFFFFF}" .. s .. ". {CDCDCD}" .. n .. " {E61920}(OFFLINE)", 0xFFFFFF)
               end
               s = s + 1
            end
         end
         imgui.Spacing()
         imgui.Spacing()
         imgui.Spacing()
         if imgui.TooltipButton(MP.Started and u8("Остановить мероприятие") or u8("Начать мероприятие"), imgui.ImVec2(220, 50), MP.Started and u8("Завершить МП") or u8("Готовы начать?")) then
            MP.Started = not MP.Started
            if MP.Started then
               MP.autoAnnounce = false
               MP.StartedDTime = os.date('%X')
               
               playersTable = {}       
               playersTotal = 0
               playersfile = io.open("moonloader/resource/mphelper/players.txt", "w")
               
               for k, v in ipairs(getAllChars()) do
                  local res, id = sampGetPlayerIdByCharHandle(v)
                  local nickname = sampGetPlayerNickname(id)
                  if res then
                     table.insert(playersTable, id)
                     playersTotal = playersTotal + 1
                     playersfile:write(nickname .. "\n")
                  end
               end
               playersfile:close()
               
               if not isTraining then 
                  sampSendChat("/time")
               end
               sampAddChatMessage("МП начато! {696969}"..MP.StartedDTime, -1)
               -- if checkbox.donators.v then 
                  -- sampSendChat("/мчат Спонсоры мероприятия: "..u8:decode(textbuffer.mpdonators.v))
               -- end 
               --sampSetChatInputEnabled(true)
               --sampSetChatInputText('* Начали! Желаю удачи всем игрокам')
            else
               MP.EndedDTime = os.date('%X')
               MP.StartedDTime = nil
               --sampSetChatInputEnabled(true)
               --sampSetChatInputText('* МП Остановлено')
               sampAddChatMessage("МП остановлено! {696969}"..MP.EndedDTime, -1)
            end
         end
	     imgui.Spacing()
      elseif tabmenu.mp == 2 then
         resetIO()
         local pid 
         local playerId = getLocalPlayerId()
         if string.len(textbuffer.pid.v) < 1 then
            textbuffer.pid.v = tostring(playerId)
         end
         
         if string.len(textbuffer.pid.v) > 1 
         and sampIsPlayerConnected(tonumber(textbuffer.pid.v))then
            pid = tonumber(textbuffer.pid.v)
         else
            pid = tostring(playerId)
         end             
         
         imgui.Text(u8"Для всех игроков в мире:")
         if imgui.Button(u8"Пополнить хп", imgui.ImVec2(150, 25)) then
            if isTraining then
               sampSendChat("/health 100")
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили хп до 100 всем игрокам в мире", 0x0FF6600)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Пополнить броню", imgui.ImVec2(150, 25)) then
            if isTraining then
               sampSendChat("/armour 100")
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили броню до 100 всем игрокам в мире", 0x0FF6600)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Ресснуть игроков", imgui.ImVec2(150, 25)) then
            if isTraining then
               sampSendChat("/ressall")
            end
         end
         
         imgui.Text(u8"Введите ID:")
         --imgui.SameLine()
         imgui.PushItemWidth(50)
         if imgui.InputText("##PlayerIDBuffer", textbuffer.pid, imgui.InputTextFlags.CharsDecimal) then
         end
         imgui.PopItemWidth()
         
         if pid then
            imgui.SameLine()
            imgui.Text(u8""..sampGetPlayerNickname(pid))
         end

         imgui.PushItemWidth(50)
         if imgui.InputText("##PlayerIdHp", textbuffer.sethp, imgui.InputTextFlags.CharsDecimal) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         if imgui.Button(u8"Установить HP", imgui.ImVec2(150, 25)) then
            sampSendChat("/sethp "..pid.." "..textbuffer.sethp.v)
            sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили хп игроку "..pid.." до "..textbuffer.sethp.v, 0x0FF6600)
         end
         imgui.SameLine()
         imgui.Text("    ")
         imgui.SameLine()
         if imgui.Button(u8"Воскресить", imgui.ImVec2(150, 25)) then
            sampSendChat("/ress "..pid)
         end

         imgui.PushItemWidth(50)
         if imgui.InputText("##PlayerIdArmour", textbuffer.setarm, imgui.InputTextFlags.CharsDecimal) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         if imgui.Button(u8"Установить броню", imgui.ImVec2(150, 25)) then
            sampSendChat("/setarm "..pid.." "..textbuffer.setarm.v)
            sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили броню игроку "..pid.." до "..textbuffer.sethp.v, 0x0FF6600)
         end
 
         imgui.PushItemWidth(50)
         if imgui.InputText("##PlayerIdTeamId", textbuffer.setteam, imgui.InputTextFlags.CharsDecimal) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         if imgui.Button(u8"Установить команду", imgui.ImVec2(150, 25)) then
            sampSendChat("/setteam "..pid.." "..textbuffer.setteam.v)
            sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы установили тиму "..textbuffer.setteam.v.."{FFFFFF} игроку {696969}"..pid, 0x0FF6600)
         end
         imgui.SameLine()
         imgui.Text("    ")
         imgui.SameLine()
         if imgui.Button(u8"Обнулить команду", imgui.ImVec2(150, 25)) then
            sampSendChat("/unteam "..pid)
         end
         
         imgui.PushItemWidth(200)
         if imgui.InputText("##PlayerIdVehicle", textbuffer.vehiclename) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Укажите ID либо имя транспорта")
         imgui.SameLine()
         if imgui.Button(u8"Выдать транспорт", imgui.ImVec2(150, 25)) then
            if string.len(textbuffer.vehiclename.v) >= 3 then
               sampSendChat("/giveveh "..pid.." "..textbuffer.vehiclename.v)
            else
               sampAddChatMessage("Вы не указали ID транспорта", -1)
            end
         end
         
         imgui.PushItemWidth(140)
         imgui.Combo('##ComboWeaponSelect', combobox.weaponselect, weaponNames)
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.PushItemWidth(54)
         imgui.InputInt("##inputAmmo", input.ammo, 0)
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Укажите количество патронов")
         imgui.SameLine()
         if imgui.Button(u8"Выдать оружие", imgui.ImVec2(150, 25)) then
            if combobox.weaponselect.v == 19 or combobox.weaponselect.v == 20
            or combobox.weaponselect.v == 1 or combobox.weaponselect.v == 21 then
               sampAddChatMessage("Некорректный выбор оружия", -1)
            else
               sampSendChat("/givegun "..pid.." "..combobox.weaponselect.v.." "..input.ammo.v)
            end
         end
         local moderitems = {
             u8"Обнулить",
             u8"1-го уровня", 
             u8"2-го уровня", 
             u8"3-го уровня", 
             u8"4-го уровня", 
             u8"5-го уровня"
         }
         imgui.PushItemWidth(200)
         imgui.Combo(u8'##ComboBoxSetModer', combobox.setmoder, moderitems, #moderitems)
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Выдать права модератора в мире")
         imgui.SameLine()
         if imgui.Button(u8"Выдать модера", imgui.ImVec2(150, 25)) then
            sampSendChat("/setmoder "..pid.." "..combobox.setmoder.v)
         end
         
         imgui.Text(u8"Выдать наказание: ")
         imgui.PushItemWidth(200)
         if imgui.InputText(u8"причина", textbuffer.setreason) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.PushItemWidth(50)
         if imgui.InputText(u8"минут", textbuffer.setptime, imgui.InputTextFlags.CharsDecimal) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Чтобы забанить навсегда укажите 0 в графу с минутами")
         
         if imgui.Button(u8"Кикнуть игрока", imgui.ImVec2(150, 25)) then
            if string.len(textbuffer.setreason.v) >= 3 then
               sampSendChat("/vkick "..pid.." "..textbuffer.setreason.v)
            else
               sampAddChatMessage("Вы не указали причину", -1)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Заглушить игрока", imgui.ImVec2(150, 25)) then
            if string.len(textbuffer.setptime.v) >= 1 then
               sampSendChat("/vmute "..pid.." "..tonumber(textbuffer.settime.v).." "..textbuffer.setreason.v)
            else
               sampAddChatMessage("Вы не указали на какое время выдать наказание", -1)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Забанить игрока", imgui.ImVec2(150, 25)) then
            if string.len(textbuffer.setptime.v) >= 1 then
               sampSendChat("/vban "..pid.." "..tonumber(textbuffer.settime.v).." "..textbuffer.setreason.v)
            else
               sampAddChatMessage("Вы не указали на какое время выдать наказание", -1)
            end
         end
         
         imgui.PopItemWidth()
         
         imgui.Spacing()
      elseif tabmenu.mp == 3 then
         --resetIO()
         local symbols = 0
         local lines = 1
         local filepath = getGameDirectory().."//moonloader//resource//mphelper//rules.txt"
         
         symbols = string.len(textbuffer.rules.v)/2
         for s in string.gmatch(textbuffer.rules.v, "\n" ) do
            lines = lines + 1
         end
            
         if imgui.TooltipButton(u8"Обновить", imgui.ImVec2(80, 25), u8:encode("Загрузить правила с файла rules.txt")) then
            local file = io.open(filepath, "r")
            textbuffer.rules.v = file:read('*a')
            file:close()
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Сохранить", imgui.ImVec2(80, 25), u8:encode("Сохранить правила с файла rules.txt")) then
            if not readonly then
               local file = io.open(filepath, "w")
               file:write(textbuffer.rules.v)
               file:close()
               sampAddChatMessage("Сохранено в файл: /moonloader/resource/mphelper/rules.txt", -1)
            else
               sampAddChatMessage("Недоступно в режмие для чтения. Снимите режим RO (Readonly)", -1)
            end
         end
         -- if imgui.TooltipButton(u8"Анонсировать правила", imgui.ImVec2(150, 25), u8:encode("Анонсировать правила в чат")) then
            -- for line in io.lines(filepath) do
               -- sampAddChatMessage(u8:decode(line), -1)
            -- end
         -- end
         imgui.SameLine()
         imgui.PushItemWidth(190)
         imgui.InputText("##search", textbuffer.searchbar)
         imgui.PopItemWidth()
         imgui.SameLine()
         if imgui.TooltipButton(u8"Поиск##Search", imgui.ImVec2(60, 25), u8:encode("Поиск по тексту")) then
            local results = 0
            local resultline = 0
            if string.len(textbuffer.searchbar.v) > 0 then
               for line in io.lines(filepath) do
                  resultline = resultline + 1
                  if line:find(textbuffer.searchbar.v, 1, true) then
                     results = results + 1
                     sampAddChatMessage("Строка "..resultline.." : "..u8:decode(line), -1)
                  end
               end
            end
            if not results then
               sampAddChatMessage("Результат поиска: Не найдено", -1)
            end
         end
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Поиск по тексту регистрозависим!")
         imgui.Spacing()
         
         imgui.PushFont(multilinetextfont)
         if readonly then
            imgui.InputTextMultiline('##rules', textbuffer.rules, imgui.ImVec2(490, 340),
            imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput + imgui.InputTextFlags.ReadOnly)
         else 
            imgui.InputTextMultiline('##rules', textbuffer.rules, imgui.ImVec2(490, 340),
            imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput)
         end
         imgui.PopFont()
         
         imgui.Text("lines: "..lines.." symbols: "..symbols)
         imgui.SameLine()
         imgui.Text("                                      ")
         imgui.SameLine()
         if imgui.Selectable(readonly and "RO" or "W", false, 0, imgui.ImVec2(50, 15)) then
            readonly = not readonly
         end
         imgui.SameLine()
         if imgui.Selectable("Unlock IO", false, 0, imgui.ImVec2(50, 15)) then
            resetIO()
         end
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"RO - Включить режим ReadOnly, Unlock IO - разблокировать инпут если курсор забагался")
         --imgui.Spacing()
      elseif tabmenu.mp == 4 then
         resetIO()
         
         local prefix = ""
         if isAbsolutePlay then             
            imgui.PushItemWidth(120)
            prefixlist = {u8'мчат', u8'глобальный', u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = "/мчат "
            elseif combobox.chatselect.v == 1 then
               prefix = "* "
            elseif combobox.chatselect.v == 2 then
               prefix = ""
            end
         elseif isTraining then  
            imgui.PushItemWidth(120)
            imgui.Text(u8"Чат:")
            imgui.SameLine()
            prefixlist = {u8'игрового мира', u8'модераторов', u8'глобальный', u8'ООС', u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = "@ "
            elseif combobox.chatselect.v == 1 then
               prefix = "$ "
            elseif combobox.chatselect.v == 2 then
               prefix = "! "
            elseif combobox.chatselect.v == 2 then
               prefix = "/b "
            elseif combobox.chatselect.v == 2 then
               prefix = ""
            end
         else
            imgui.PushItemWidth(120)
            prefixlist = {u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = ""
            end
         end
         imgui.Spacing()
         --imgui.TextColoredRGB("МП: {696969}"..profilesNames[combobox.profiles.v+1])
         -- line 1
         imgui.Text("1.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind1", binds.cmdbind1) then 
         end
         imgui.PopItemWidth()
         -- if imgui.IsItemHovered() and imgui.IsMouseDown(1) then
            -- imgui.Text('Hovered and RMB down')
         -- end
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind1", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind1.v))
         end
         -- line 2
         imgui.Text("2.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind2", binds.cmdbind2) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind2", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind2.v))
         end
         -- line 3 
         imgui.Text("3.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind3", binds.cmdbind3) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind3", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind3.v))
         end
         -- line 4
         imgui.Text("4.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind4", binds.cmdbind4) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind4", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind4.v))
         end
         -- line 5
         imgui.Text("5.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind5", binds.cmdbind5) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind5", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind5.v))
         end
         -- line 6
         imgui.Text("6.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind6", binds.cmdbind6) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind6", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind6.v))
         end
         -- line 7
         imgui.Text("7.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind7", binds.cmdbind7) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind7", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind7.v))
         end
         -- line 8
         imgui.Text("8.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind8", binds.cmdbind8) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind8", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind8.v))
         end
         -- line 8
         imgui.Text("9.")
         imgui.SameLine()
         imgui.PushItemWidth(400)
         if imgui.InputText("##cmdbind9", binds.cmdbind9) then 
         end
         imgui.PopItemWidth()
         
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>##Sendchatcmdbind9", imgui.ImVec2(25, 25), u8:encode("Отправить в чат")) then
            sampSendChat(prefix..u8:decode(binds.cmdbind9.v))
         end
         -- -- last line
         
         --imgui.SameLine()
         imgui.Spacing()
         if imgui.TooltipButton("Reload", imgui.ImVec2(60, 25), u8:encode("Перезагрузить бинды")) then 
           reloadBindsFromConfig()        
           sampAddChatMessage("Бинды были успешно презагружены из конфига", -1)
         end
         imgui.SameLine()
	     if imgui.TooltipButton("Save", imgui.ImVec2(60, 25), u8:encode("Сохранить бинды")) then 
            ini.binds.cmdbind1 = u8:decode(binds.cmdbind1.v)
            ini.binds.cmdbind2 = u8:decode(binds.cmdbind2.v)
            ini.binds.cmdbind3 = u8:decode(binds.cmdbind3.v)
            ini.binds.cmdbind4 = u8:decode(binds.cmdbind4.v)
            ini.binds.cmdbind5 = u8:decode(binds.cmdbind5.v)
            ini.binds.cmdbind6 = u8:decode(binds.cmdbind6.v)
            ini.binds.cmdbind7 = u8:decode(binds.cmdbind7.v)
            ini.binds.cmdbind8 = u8:decode(binds.cmdbind8.v)
            ini.binds.cmdbind9 = u8:decode(binds.cmdbind9.v)
            inicfg.save(ini, configIni)          
            sampAddChatMessage("Бинды были успешно сохранены", -1)
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Clean", imgui.ImVec2(60, 25), u8:encode("Очистить бинды")) then
            cleanBindsForm()
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Demo", imgui.ImVec2(60, 25), u8:encode("Установить демонстрационные значения")) then
            binds.cmdbind1.v = u8"Выдаю оружие и броню! После выдачи начинаем МП!"
            binds.cmdbind2.v = u8"Изменил спавн! Не умирайте, МП скоро начнется"
            binds.cmdbind3.v = u8"Не стоим на месте, неактивные будут удалены с МП!"
            binds.cmdbind4.v = u8"Все в строй! Кто не в строю будет удален с МП"
            binds.cmdbind5.v = u8"Скоро начнем, занимайте позиции!"
            binds.cmdbind6.v = u8"Желаем всем удачи, иии Начали!!"
            binds.cmdbind7.v = u8"Не мешаем другим игрокам, ждем начала!"
            binds.cmdbind8.v = u8"Игроки находящиеся в АФК будут удалены с МП"
            binds.cmdbind9.v = u8"Увидели нарушителя - напишите организатору!"
         end
         
	     --imgui.TextColoredRGB("* {00FF00}@ номер игрока - {bababa}заменит id на никнейм игрока.")
	     --imgui.TextColoredRGB("Цветной текст указывать через скобки (FF0000)")
         -- --imgui.Separator()
      elseif tabmenu.mp == 5 then
         resetIO()
         -- local _, playerId = sampGetPlayerIdByCharHandle(playerPed)
         -- local money = getPlayerMoney(playerPed)
         -- imgui.TextColoredRGB("{36662C}$"..money)
         if isAbsolutePlay then
            imgui.TextColoredRGB("Посмотреть свой баланс доната {696969}/donate")
            imgui.TextColoredRGB("Дать денег игроку {36662C}${FFFFFF} {696969}/giveplayermoney <id> <кол-во>")
         end
         if isTraining then
            imgui.TextColoredRGB("{FF6600}/pay <id> <money>{cdcdcd} передать деньги игроку")
         end
         
         imgui.Text(u8"Текущий приз: ")
         imgui.SameLine()
         imgui.PushItemWidth(90)
         imgui.InputText(u8"$##BindMpprize", textbuffer.mpprize, imgui.InputTextFlags.CharsDecimal)
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.TextQuestion("( ? )", u8"Выдать приз всем оставшимся в мире игрокам (в виртуальной валюте)")
         if imgui.Button(u8"Выдать приз всем оставшимся", imgui.ImVec2(220, 25)) then
            if string.len(textbuffer.mpprize.v) >= 1 
            and tonumber(textbuffer.mpprize.v) >= 1 then
               lua_thread.create(function()
                  for k, v in ipairs(getAllChars()) do
		             local res, id = sampGetPlayerIdByCharHandle(v)
                     local pid = getLocalPlayerId()
                     local nick = sampGetPlayerNickname(id)
		             if res and id ~= pid then
                        sampAddChatMessage("Выдача приза игроку "..nick.."("..id..")", -1)
                        if isTraining then
                           sampSendChat("/pay "..id.." "..tonumber(textbuffer.mpprize.v), -1)
                        elseif isAbsolutePlay then
                           sampSendChat("/giveplayermoney "..id.." "..tonumber(textbuffer.mpprize.v), -1)
                        end
                        wait(500)
                     end
                  end
               end)
            else
               sampAddChatMessage("Не указан приз, либо указан не в числовом формате", -1)
            end
         end
         
         imgui.Text(u8"Оставшиеся игроки рядом:")
         local playerscounter = 0
         for k, v in ipairs(getAllChars()) do
		    local res, id = sampGetPlayerIdByCharHandle(v)
            local pid = getLocalPlayerId()
            local nick = sampGetPlayerNickname(id)
		    if res and id ~= pid then
               playerscounter = playerscounter + 1
               if playerscounter >= 9 then
                  break
               end
               imgui.Text("  ")
               imgui.SameLine()
               imgui.Selectable(string.format("%d. %s", id, nick))
               if imgui.IsItemClicked() then
                  if isAbsolutePlay then
                     sampSendChat("/и " .. id)
                     dialog.main.v = not dialog.main.v 
                  else
                     sampAddChatMessage("Ид {696969}"..id.."{FFFFFF} игрока {696969}"..nick.." {FFFFFF}скопирован в буффер обмена", -1)
                     setClipboardText(id) 
                  end
               end
		    end
	 	 end
         imgui.Spacing()
	     if imgui.Button(u8"Получить id и ники игроков рядом", imgui.ImVec2(220, 25)) then
            copyNearestPlayersToClipboard()
	     end
         imgui.SameLine()
         if imgui.Button(u8"Всем спасибо!", imgui.ImVec2(220, 25)) then
            sampSetChatInputEnabled(true)
            if isAbsolutePlay then
               sampSetChatInputText('* Спасибо за участие в МП! ')
            elseif isTraining then
               sampSetChatInputText('@ Спасибо за участие в МП! ')
            else
               sampSetChatInputText('Спасибо за участие в МП! ')
            end
            sampAddChatMessage("Текст скопирован в строку чата", -1)
            dialog.main.v = not dialog.main.v 
	     end
         if imgui.Button(u8"Объявить победителей МП", imgui.ImVec2(220, 25)) then
	 	    local pidtable = {}
	 	    local resulstring
	 	    for k, v in ipairs(getAllChars()) do
	 	       local res, id = sampGetPlayerIdByCharHandle(v)
	 	       if res and v ~= playerPed then
	 	  	      local nickname = sampGetPlayerNickname(id)
	 	  	      table.insert(pidtable, string.format("%s[%d] ", nickname, id))
	 	  	      resulstring = table.concat(pidtable)
	 	  	      setClipboardText(resulstring)
	 	  	      sampSetChatInputEnabled(true)
	 	  	      sampSetChatInputText('* Победители МП " " '..resulstring..' .Поздравляем!')
	 	  	      sampAddChatMessage("Текст скопирован в строку чата", -1)
	 	  	      dialog.main.v = not dialog.main.v 
	 	       end
	 	    end
	     end
         imgui.SameLine()
         if imgui.Button(u8"Победители не выходите", imgui.ImVec2(220, 25)) then
            sampSetChatInputEnabled(true)
            sampSetChatInputText('* Победители не выходите! Дождитесь выдачи приза.')
            dialog.main.v = not dialog.main.v 
	     end
         imgui.Spacing()
      elseif tabmenu.mp == 6 then
         resetIO()
         imgui.Text(u8"Разрешенное оружие: ")
         if #legalweapons > 2 then
            for k, v in pairs(legalweapons) do
               if v > 1 then
                  imgui.SameLine()
                  imgui.Text(""..weaponNames[v]) 
               end
            end
         end
         imgui.PushItemWidth(150)
         imgui.Combo('##ComboWeaponSelect', combobox.weaponselect, weaponNames)
         imgui.PopItemWidth()
         imgui.SameLine()
         if imgui.TooltipButton(u8"Добавить", imgui.ImVec2(70, 25), u8"Добавить в список разрешенных на МП") then
            if combobox.weaponselect.v == 1 or combobox.weaponselect.v == 0 then
               sampAddChatMessage("Кулаки разрешены по-умолчанию", -1)
            elseif legalweapons[#legalweapons] == combobox.weaponselect.v then
               sampAddChatMessage(string.format("Это оружие %s уже было добавлено в список разрешенных на МП",
               weaponNames[combobox.weaponselect.v]),-1)
            elseif combobox.weaponselect.v == 19 or combobox.weaponselect.v == 20
            or combobox.weaponselect.v == 21 then
               sampAddChatMessage("Пустой слот не может быть добавлен", -1)
            else
              legalweapons[#legalweapons+1] = combobox.weaponselect.v
              sampAddChatMessage(string.format("Оружие %s добавлено в список разрешенных на МП",
              weaponNames[combobox.weaponselect.v]), -1)
            end
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Удалить", imgui.ImVec2(70, 25), u8"Удалить последнее выбранное оружие со списка разрешенных на МП") then
            legalweapons[#legalweapons] = nil
            sampAddChatMessage("Удалено последнее выбранное оружие со списка разрешенных", -1)
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Очистить", imgui.ImVec2(70, 25), u8"Очистить список разрешенного на МП оружия") then
            legalweapons = {0, 1}
            sampAddChatMessage("Список разрешенного на МП оружия обнулен", -1)
         end
         
         if imgui.Checkbox(u8("Проверять изменение хп и брони"), checkbox.healthcheck) then
         end
         if checkbox.healthcheck.v then
            if string.len(textbuffer.mphp.v) < 1 then 
               textbuffer.mphp.v = '100'
            end
            if string.len(textbuffer.mparmour.v) < 1 then 
               textbuffer.mparmour.v = '100'
            end
            imgui.PushItemWidth(50)
            imgui.InputText(u8"хп", textbuffer.mphp, imgui.InputTextFlags.CharsDecimal)
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.PushItemWidth(50)
            imgui.InputText(u8"броня", textbuffer.mparmour, imgui.InputTextFlags.CharsDecimal)
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.TextQuestion("( ? )", u8"По умолчанию 100. Допустимые значения от 100 до 10 000")
         end
         
         if imgui.Checkbox(u8("Уведомлять о дисконнекте игроков из списка"), checkbox.disconnectreminder) then
	   	    if checkbox.disconnectreminder.v then
	 	  	  sampAddChatMessage("При вылете игроков с сервера будет выводить уведомление", -1)
	 	    else
	 	  	  sampAddChatMessage("Отключены уведомления о вылете игроков с сервера", -1)
	 	    end
	     end
	     
         if imgui.Checkbox(u8("Предупреждения на подозрительных игроков"), checkbox.playerwarnings) then
	   	    if checkbox.playerwarnings.v then
               sampAddChatMessage("Предупреждения включены", -1)
               PlayerWarnings()
	 	    else
	 	  	  sampAddChatMessage("Предупреждения отключены", -1)
	 	    end
            ini.settings.playerwarnings = checkbox.playerwarnings.v
            inicfg.save(ini, configIni)
	     end
         
         if imgui.Checkbox(u8("Боковая панель со списком игроков в стриме"), checkbox.sidebarplayers) then
            ini.settings.mode = checkbox.sidebarplayers.v
            inicfg.save(ini, configIni)
         end

         imgui.Spacing()
         
         imgui.Text(u8"Проверить игроков:")
	     if imgui.Button(u8"Вывести список лагеров", imgui.ImVec2(220, 25)) then
	        local counter = 0
	 	    if next(playersTable) == nil then -- if playersTable is empty
	 	       sampAddChatMessage("Сперва обнови список игроков!", -1) 
	 	    else
	           for k, v in pairs(playersTable) do
                 --local res, handle = sampGetCharHandleBySampPlayerId(v)
                 local ping = sampGetPlayerPing(v)
                 local nickname = sampGetPlayerNickname(v)
	 	  	    if(ping > 70) then
	 	  	       counter = counter + 1
	 	  	       sampAddChatMessage(string.format("Лагер %s(%i) ping: %i", nickname, v, ping), 0xFF0000)
                 end
	 	      end
	 	      if counter == 0 then
	 	         sampAddChatMessage("Лагеры не найдены", -1)
	 	      end
	        end
	     end
         imgui.SameLine()
	     if imgui.Button(u8"Вывести список игроков AFK", imgui.ImVec2(220, 25)) then
	        local counter = 0
	 	    if next(playersTable) == nil then -- if playersTable is empty
	 	       sampAddChatMessage("Сперва обнови список игроков!", -1) 
	 	    else
	           for k, v in pairs(playersTable) do
                  local nickname = sampGetPlayerNickname(v)
	 	          if sampIsPlayerPaused(v) then
	 	  	        counter = counter + 1
	                 sampAddChatMessage(string.format("AFK %s(%i)", nickname, v), 0xFF0000)
	              end
	 	       end
	 	       if counter == 0 then
	 	          sampAddChatMessage("АФКашники не найдены", -1)
	 	       end
	 	    end
	     end
         
         if imgui.Button(u8"Статистика всего онлайна", imgui.ImVec2(220, 25)) then
            local totalonline = 0
	 	    local olds = 0
            local players = 0
	 	    local newbies = 0
            local bots = 0
            local afk = 0
            
	        for i = 0, sampGetMaxPlayerId(false) do
               if sampIsPlayerConnected(i) then 
	 	          totalonline = totalonline + 1
	 	          local score = sampGetPlayerScore(i)
                  local ping = sampGetPlayerPing(i)
                  local color = sampGetPlayerColor(i)
                  --print(i, color, string.format("%x", color))
                  
                  -- white clist color 16777215
                  if ping <= 30 and score < 10 and color == 16777215 then
                     bots = bots + 1
                  end
	 	          if score > 1000 then
	 	             olds = olds + 1
	 	          elseif score >= 50 and score < 1000 then 
                     players = players + 1
                  else 
                     newbies = newbies + 1
	 	          end
                  
                  if sampIsPlayerPaused(i) then 
                     afk = afk + 1
                  end
	 	       end
            end
            if isAbsolutePlay then
               sampAddChatMessage(string.format("Игроков в сети %i из них новички %i, постояльцы %i, олды %i (возможно боты %i)",
               totalonline, newbies, players, olds, bots), -1)
            else
               sampAddChatMessage(string.format("Игроков в сети %i из них AFK %i (возможно боты %i)",
               totalonline, afk, bots), -1)
            end
         end
         imgui.SameLine()
         if imgui.Button(u8"Черный список игроков", imgui.ImVec2(220, 25)) then
            sampAddChatMessage("Черный список:", -1)
            s = 1
            for k, n in pairs(blacklist) do
               sampAddChatMessage("{363636}" .. s .. ". {FF0000}" .. u8:decode(n), 0xFFFFFF)
               s = s + 1
            end
         end
         
         if imgui.Button(u8"Игроки с оружием", imgui.ImVec2(220, 25)) then
            local armedplayerscounter = 0
            for k, v in ipairs(getAllChars()) do
               local res, id = sampGetPlayerIdByCharHandle(v)
               if res then
                  local nick = sampGetPlayerNickname(id)
                  local weaponid = getCurrentCharWeapon(v)
                  if weaponid ~= 0 and weaponid ~= 1 then
                     armedplayerscounter = armedplayerscounter + 1
                     sampAddChatMessage(string.format("{FF0000}Игрок %s[%d] с оружием %s (id:%d)!", nick, id, weaponNames[weaponid], weaponid), -1)
                  end
               end
            end
            if armedplayerscounter == 0 then
               sampAddChatMessage("Не найдено игроков с оружием", -1)
            else
               sampAddChatMessage("Всего игроков с оружием: "..armedplayerscounter, -1)
            end
         end
         
         imgui.SameLine()
         if imgui.Button(u8"Игроки с малым уровнем", imgui.ImVec2(220, 25)) then
            local minscore = 5
            local noobs = 0

            for k, i in pairs(playersTable) do
               if sampIsPlayerConnected(i) then 
		          local nickname = sampGetPlayerNickname(i)
                  local score = sampGetPlayerScore(i)
                  
                  if score < minscore then
                     noobs = noobs + 1
                     sampAddChatMessage(string.format("{FF0000}Игрок %s[%d] с малым уровнем %d", nickname, i, score), -1)
                  end
               end
            end
            
            if noobs == 0 then
               sampAddChatMessage("Не найдено игроков с малым уровнем", -1)
            else
               sampAddChatMessage("Всего: "..noobs, -1)
            end
         end
       elseif tabmenu.mp == 7 then
         resetIO()
         
         imgui.Text(u8"Объявление: ")
         imgui.PushItemWidth(450)
         if imgui.InputText("##Mpadd", textbuffer.mpadd) then 
         end
         imgui.PopItemWidth()
         
         imgui.Text(u8"Дополнительно:")
         imgui.Checkbox(u8"Указать приз", checkbox.mpprize)
         
         if checkbox.mpprize.v then
            imgui.SameLine()
            imgui.Text(u8"Приз: ")
            imgui.SameLine()
            imgui.PushItemWidth(90)
            imgui.InputText(u8"$##BindMpprize", textbuffer.mpprize, imgui.InputTextFlags.CharsDecimal)
            imgui.PopItemWidth()
         end
         
         imgui.Checkbox(u8"Указать спонсоров", checkbox.donators)
         if checkbox.donators.v then
            imgui.Text(u8"Спонсоры:")
            imgui.Text(u8"Укажите ники спонсоров через запятую")
            imgui.PushItemWidth(300)
            if imgui.InputText("##BindMpdonators", textbuffer.mpdonators) then 
            end
            imgui.SameLine()
            if imgui.Button(u8"Объявить спонсоров", imgui.ImVec2(140, 25)) then
               if string.len(textbuffer.mpdonators.v) > 0 then
                  sampSetChatInputEnabled(true)
                  sampSetChatInputText("/мчат Спонсоры мероприятия: "..u8:decode(textbuffer.mpdonators.v))
               else
                  sampAddChatMessage("Сперва укажите спонсоров мероприятия!", -1)
               end                  
            end
         end
         imgui.Spacing()
         if isAbsolutePlay then
            if imgui.TooltipButton(u8"Объявить МП", imgui.ImVec2(220, 25), u8"Аннонсировать МП в объявление (/об)") then
               if string.len(textbuffer.mpadd.v) > 0 then 
                  sampSetChatInputEnabled(true)
                  if checkbox.mpprize.v then
                     sampSetChatInputText(string.format("/об %s, приз %s", u8:decode(textbuffer.mpadd.v), u8:decode(textbuffer.mpprize.v)))
                  else
                     sampSetChatInputText(string.format("/об %s, приз %s", u8:decode(textbuffer.mpadd.v)))
                  end
               else
                  sampAddChatMessage("Сперва укажите текст объявления!", -1)
               end
            end
         elseif isTraining then
            if imgui.TooltipButton(u8"Объявить МП", imgui.ImVec2(220, 25), u8"Аннонсировать МП в объявление (/ads)") then
               if string.len(textbuffer.mpadd.v) > 0 then 
                  sampSetChatInputEnabled(true)
                  if checkbox.mpprize.v then
                     sampSetChatInputText(string.format("/ads %s, приз %s", u8:decode(textbuffer.mpadd.v), u8:decode(textbuffer.mpprize.v)))
                  else
                     sampSetChatInputText(string.format("/ads %s", u8:decode(textbuffer.mpadd.v)))
                  end
               else
                  sampAddChatMessage("Сперва укажите текст объявления!", -1)
               end
            end
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"Протестировать", imgui.ImVec2(220, 25), u8:encode("Выведет сообщение только вам для теста")) then
            if checkbox.mpprize.v then
               sampAddChatMessage("В объявление будет подано: "..u8:decode(textbuffer.mpadd.v)..", приз "..u8:decode(textbuffer.mpprize.v), -1)
            else
               sampAddChatMessage("В объявление будет подано: "..u8:decode(textbuffer.mpadd.v), -1)
            end
         end
         
         imgui.Spacing()
         imgui.Text(u8"Авто-объявление:")
         if imgui.TooltipButton(MP.autoAnnounce and u8('Отключить авто-объявление') or u8('Включить авто-объявление'), imgui.ImVec2(220, 25), u8:encode("Автоматически шлет объявление о МП")) then
            if string.len(textbuffer.mpadd.v) > 0 then 
               MP.autoAnnounce = not MP.autoAnnounce
               if MP.autoAnnounce then
                  if checkbox.mpprize.v then
                     sampAddChatMessage("В объявление будет подано: "..u8:decode(textbuffer.mpadd.v)..", приз "..u8:decode(textbuffer.mpprize.v), -1)
                  else
                     sampAddChatMessage("В объявление будет подано: "..u8:decode(textbuffer.mpadd.v), -1)
                  end
               end   
               AutoAd()
            else
               MP.autoAnnounce = false
               sampAddChatMessage("Сперва укажите текст объявления!", -1)
            end
         end
         
         imgui.Text(u8"Повтор авто-объявления через: ")
         imgui.PushItemWidth(150)
         if imgui.InputInt("##MpaddTime", input.addtime) then
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.Text(u8"мин.")
      elseif tabmenu.mp == 8 then
         resetIO()
         
         imgui.PushItemWidth(200)
         if checkbox.hideanswer.v then
            imgui.InputText(u8"<- ответ", textbuffer.mpanswer, imgui.InputTextFlags.Password)
         else
            imgui.InputText(u8"<- ответ", textbuffer.mpanswer)
         end
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.Checkbox(u8("Скрыть ответ"), checkbox.hideanswer)
         imgui.PushItemWidth(315)
         imgui.SameLine()
         imgui.Text(" ")
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>", imgui.ImVec2(50, 25), u8"Отправить в чат") then
            sampSendChat(prefix..u8:decode(textbuffer.mpanswer.v))
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"<x]", imgui.ImVec2(30, 25), u8"Очистить поле ввода ответа") then
            textbuffer.mpanswer.v = ""
            resetIO()
         end
         imgui.Text(u8"Вопрос: ")
         imgui.SameLine()
         imgui.InputText(u8"", textbuffer.mpquestion)
         imgui.PopItemWidth()
         imgui.SameLine()
         imgui.Text(" ")
         imgui.SameLine()
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>", imgui.ImVec2(50, 25), u8"Отправить в чат") then
            sampSendChat(prefix..u8:decode(textbuffer.mpquestion.v))
         end
         imgui.SameLine()
         if imgui.TooltipButton(u8"<x]", imgui.ImVec2(30, 25), u8"Очистить поле ввода вопроса") then
            textbuffer.mpquestion.v = ""
            resetIO()
         end
         local prefix = ""
         if isAbsolutePlay then             
            imgui.PushItemWidth(150)
            prefixlist = {u8'мчат', u8'глобальный', u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = "/мчат "
            elseif combobox.chatselect.v == 1 then
               prefix = "* "
            elseif combobox.chatselect.v == 2 then
               prefix = ""
            end
         elseif isTraining then  
            imgui.PushItemWidth(120)
            imgui.Text(u8"Чат по-умолчанию: ")
            imgui.SameLine()
            prefixlist = {u8'игрового мира', u8'модераторов', u8'глобальный', u8'ООС', u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = "@ "
            elseif combobox.chatselect.v == 1 then
               prefix = "$ "
            elseif combobox.chatselect.v == 2 then
               prefix = "! "
            elseif combobox.chatselect.v == 2 then
               prefix = "/b "
            elseif combobox.chatselect.v == 2 then
               prefix = ""
            end
         else
            imgui.PushItemWidth(120)
            prefixlist = {u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = ""
            end
         end
         imgui.Spacing()
         imgui.Spacing()
         imgui.Checkbox(u8("Отслеживать ответ в чате и /pm"), checkbox.trackanswer)
         if checkbox.trackanswer.v then
         end
         
         imgui.Checkbox(u8("Проверить игрока через /try"), checkbox.trygame)
         if checkbox.trygame.v then
            imgui.PushItemWidth(225)
            imgui.InputText("##trybuff", textbuffer.trytext)
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.TooltipButton(u8"/try", imgui.ImVec2(100, 25), u8"Сыграть в try (Удачно/Неудачно)") then
               if string.len(textbuffer.trytext.v) > 1 then
                  sampSendChat("/try "..textbuffer.trytext.v)
               else
                  sampAddChatMessage("Введите текст сообщения", -1)
               end
            end
            imgui.SameLine()
            if imgui.TooltipButton(u8"Nick", imgui.ImVec2(100, 25), u8"Вставить ник ближайшего игрока") then
               if getClosestPlayerId() ~= -1 then
                  textbuffer.trytext.v = tostring(sampGetPlayerNickname(getClosestPlayerId()))
               end
            end
         end
         
         imgui.Spacing()
         imgui.Spacing()
         imgui.Text(u8"Порядок проведения игры:")
         imgui.SameLine()
         imgui.PushItemWidth(200)
         if imgui.Combo(u8'##ComboBoxTextGames', combobox.textgames, textGames, #textGames) then
            --textbuffer.mpname.v = tostring(mpNames[combobox.textgames.v + 1])
         end
         imgui.PopItemWidth()
         
         if combobox.textgames.v == 1 then
            textbuffer.gamesrules.v = u8"Анаграмма - слово или словосочетание, образованное путём перестановки \nбукв, составляющих другое слово (или словосочетание)"
         elseif combobox.textgames.v == 2 then
            textbuffer.gamesrules.v = u8"Организатор задает вопрос по выбранной тематике викторины.\nВаша задача первым дать ответ на вопрос из викторины организатора"
         elseif combobox.textgames.v == 3 then
            textbuffer.gamesrules.v = u8"Организатор изображает загаданное слово.\nЗадача остальных правильно назвать это слово"
         elseif combobox.textgames.v == 4 then
            textbuffer.gamesrules.v = u8"Организатор пишет одну строчку из песни.\nВаша задача ее закончить как в песне"
         elseif combobox.textgames.v == 5 then
            textbuffer.gamesrules.v = u8"Организатор пишет одну строчку из песни.\nВаша задача угадать название песни"
         elseif combobox.textgames.v == 6 then
            textbuffer.gamesrules.v = u8"Организатор задает загадки.\nВаша задача правильно на них ответить"
         end
         imgui.SameLine()
         imgui.Text("  ")
         imgui.SameLine()
         if imgui.TooltipButton(u8"|>", imgui.ImVec2(50, 25), u8"Сообщить в чат порядок проведения") then
            if string.len(textbuffer.gamesrules.v) >= 3 then
               local result = splitByLines(textbuffer.gamesrules.v, 128)
               for k, v in ipairs(result) do
                  sampAddChatMessage(u8:decode(v), -1)
               end
            end
         end
         imgui.InputTextMultiline('##gamesrules', textbuffer.gamesrules, imgui.ImVec2(480, 75),
         imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput)
         
         if imgui.Button(u8"Есть победитель!", imgui.ImVec2(155, 25)) then
            sampSetChatInputEnabled(true)
            sampSetChatInputText('Есть правильный ответ! Первым прислал игрок')
         end
         imgui.SameLine()
         if imgui.Button(u8"Нет правильного", imgui.ImVec2(155, 25)) then
            sampSendChat(prefix.."Никто не дал правильный ответ!")
         end
         imgui.SameLine()
         if imgui.Button(u8"Переигровка", imgui.ImVec2(155, 25)) then
            sampSendChat(prefix.."Переигровка! Попробуем еще раз!")
         end
      elseif tabmenu.mp == 9 then
         imgui.Text(u8"MP Helper v".. thisScript().version)
         imgui.Spacing()
         imgui.TextColoredRGB("Хелпер для организаторов мероприятий.")
         imgui.Text(u8"Скрипт распостраняется только с открытым исходным кодом.")

         imgui.Spacing()
		 
         imgui.Text("Homepage:")
		 imgui.SameLine()
		 imgui.Link("https://github.com/ins1x/moonloader-scripts/mphelper","https://github.com/ins1x/moonloader-scripts/mphelper")
         
         imgui.Spacing()
         imgui.Spacing()
         if imgui.Button(u8"Проверить обновления",imgui.ImVec2(170, 25)) then
            os.execute('explorer https://github.com/ins1x/moonloader-scripts/mphelper')
		 end
         
         if imgui.Button(u8"Сбросить настройки",imgui.ImVec2(170, 25)) then
		    os.rename(getGameDirectory().."//moonloader//config//mphelper.ini", getGameDirectory().."//moonloader//config//backup_mphelper.ini")
            sampAddChatMessage("Настройки были сброшены на стандартные. Скрипт автоматически перезагрузится.",-1)
            sampAddChatMessage("Резервную копию ваших предыдущих настроек можно найти в moonloader/config.",-1)
            reloadScripts()
		 end
         
         if imgui.Button(u8"Выгрузить скрипт", imgui.ImVec2(170, 25)) then
            sampAddChatMessage("{696969}MP Helper{FFFFFF} успешно выгружен.", -1)
            sampAddChatMessage("Для запуска используйте комбинацию клавиш {696969}CTRL + R.", -1)
            thisScript():unload()
         end
         -- if imgui.Checkbox(u8("Проверять обновления автоматически (без загрузки)"), checkbox.checkupdates) then
            -- ini.settings.checkupdates = checkbox.checkupdates.v
            -- inicfg.save(ini, configIni)
         -- end
         
         imgui.Spacing()
         imgui.Spacing()
      end -- tabmenu.mp  
      
      imgui.NextColumn()
      
      if imgui.Button(u8"Подготовка к МП",imgui.ImVec2(120, 30)) then tabmenu.mp = 1 end 
      if imgui.Button(u8"Объявление",imgui.ImVec2(120, 30)) then tabmenu.mp = 7 end 
      if isTraining then
         if imgui.Button(u8"Управление",imgui.ImVec2(120, 30)) then tabmenu.mp = 2 end 
      end
      if imgui.Button(u8"Быстрые команды",imgui.ImVec2(120, 30)) then tabmenu.mp = 4 end 
      if imgui.Button(u8"Проверка игроков",imgui.ImVec2(120, 30)) then tabmenu.mp = 6 end 
      if imgui.Button(u8"Правила МП",imgui.ImVec2(120, 30)) then tabmenu.mp = 3 end 
      if imgui.Button(u8"Игры с чатом",imgui.ImVec2(120, 30)) then tabmenu.mp = 8 end 
      if imgui.Button(u8"Финал МП",imgui.ImVec2(120, 30)) then tabmenu.mp = 5 end
      if imgui.Button(u8"О скрипте",imgui.ImVec2(120, 30)) then tabmenu.mp = 9 end 
      
      imgui.Spacing()
      imgui.Columns(1)
      imgui.Spacing()
      imgui.End()
   end
   
   -- Child dialogs
   if dialog.fastanswer.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 4, sizeY / 26),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin(u8"Сообщения", dialog.fastanswer)
      
      if not chosenplayer then
         local _, id = sampGetPlayerIdByCharHandle(playerPed)
         chosenplayer = id
      end      
      
      local nickname = sampGetPlayerNickname(chosenplayer)
      local ucolor = sampGetPlayerColor(chosenplayer)
      
      if LastData.lastPmMessage then 
         imgui.TextColoredRGB(LastData.lastPmMessage)
      end
      
      imgui.TextColoredRGB(string.format("Ответить игроку: {%0.6x} %s[%d]",
      bit.band(ucolor,0xffffff), nickname, chosenplayer))
      imgui.SameLine()
      imgui.Text("   ")
      
      imgui.SameLine()
      if imgui.TooltipButton(u8"Очистить", imgui.ImVec2(80, 24), u8:encode("Очистить и разблокировать инпут")) then
         textbuffer.sms.v = ""
         resetIO()
      end
      imgui.SameLine()
      if imgui.TooltipButton(u8"В буффер", imgui.ImVec2(80, 24), u8:encode("Скопировать в буффер обмена")) then
         setClipboardText(u8:decode(textbuffer.sms.v))
      end
      
      imgui.SameLine()
      imgui.TextColoredRGB("{696969} "..string.len(u8:decode(textbuffer.sms.v)).."/128")
      
      imgui.PushItemWidth(420)
      if imgui.InputText("##SMSBuffer", textbuffer.sms) then
         -- if string.len(u8:decode(textbuffer.sms.v) > 128 then
         -- end
      end
      imgui.PopItemWidth()
      imgui.SameLine()
      if imgui.Button(u8" > ", imgui.ImVec2(30, 25)) then
         if isTraining and isWorldHoster then
            sampSendChat("/ans "..chosenplayer.." "..u8:decode(textbuffer.sms.v))
         else
            sampSendChat("/pm "..chosenplayer.." "..u8:decode(textbuffer.sms.v))
         end
      end
      
      imgui.Text(u8"Быстрые ответы: ")
      imgui.PushItemWidth(420)
      
      if imgui.Combo(u8'##ComboBoxFastAnswers', combobox.fastanswers, fastAnswers, #fastAnswers) then
        textbuffer.sms.v = fastAnswers[combobox.fastanswers.v+1]
      end            
      imgui.PopItemWidth()
      print(fastAnswers)
      imgui.End()
   end
   
end

-- samp events
function sampev.onSendCommand(command)
   if command:find("/ответ") then
      if command:find('(.+) (.+)') then
         local cmd, arg = command:match('(.+) (.+)')
         local id = tonumber(arg)
         if sampIsPlayerConnected(id) then 
            chosenplayer = id
         else
            sampAddChatMessage("Не выбран игрок. Используйте /ответ <id>", -1)
            return false
         end
      end
      
      dialog.fastanswer.v = true
      dialog.main.v = true
      return false
   end
end  

function sampev.onServerMessage(color, text)
   if checkbox.trackanswer.v then
      if string.len(textbuffer.mpanswer.v) >= 2 then
         if text:find(u8:decode(textbuffer.mpanswer.v)) then
            sampAddChatMessage("[SCRIPT]: {FFFFFF}Похоже есть правильный ответ!", 0x0FF6600)
            sampAddChatMessage("[MP] -> {00FF00}"..text, 0x0FF6600)
         end
      end
   end
   
   if checkbox.streamermode.v then
      if newtext:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") then
         newtext = newtext:gsub("(%d+.%d+.%d+.%d+)", "***.***.***.***")
      end
   
      local phoneneumber = string.match(newtext, "%+(%d+)")
      if phoneneumber and string.len(phoneneumber) >= 10 then
         newtext = newtext:gsub("%+(%d+)", "**********")
      end
   end
   
   if isAbsolutePlay and text:find('ЛС') and text:find('от') then
      LastData.lastPmMessage = text
   end
   if isTraining and text:find('PM') and text:find('от') then
      -- blacklist check
      for k, name in pairs(blacklist) do
         if text:find(name) then
            return false
         end
      end
      LastData.lastPmMessage = text
   end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
   -- autohide passwords (style 1: DIALOG_STYLE_INPUT)
   if checkbox.streamermode.v and style == 1 then
      local newstyle = nil
      if text:find("парол") then
         newstyle = 3 -- style 3: DIALOG_STYLE_PASSWORD
      elseif isAbsolutePlay and text:find("секретное") then
         newstyle = 3 -- style 3: DIALOG_STYLE_PASSWORD
      end
      
      if newstyle then
         return {dialogId, newstyle, title, button1, button2, text}
      end
   end 
end

function sampev.onPlayerQuit(id, reason)
   if id == chosenplayer then chosenplayer = nil end
   local nick = sampGetPlayerNickname(id)
   
   if reason == 0 then reas = 'Выход'
   elseif reason == 1 then reas = 'Кик/бан'
   elseif reason == 2 then reas = 'Вышло время подключения'
   end
   
   if checkbox.disconnectreminder.v then
      for key, value in ipairs(playersTable) do
         if value == id then 
            sampAddChatMessage("Игрок " .. nick .. " вышел по причине: " .. reas, 0x00FF00)
            table.remove(playersTable, key)
         end
      end
   end
end

-- core functions block

function getClosestPlayerId()
   local closestId = -1
   mydist = 30
   local x, y, z = getCharCoordinates(playerPed)
   for i = 0, 999 do
      local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
      if streamed and getCharHealth(pedID) > 0 and not sampIsPlayerPaused(pedID) then
         local xi, yi, zi = getCharCoordinates(pedID)
         local dist = getDistanceBetweenCoords3d(x, y, z, xi, yi, zi)
         if dist <= mydist then
            mydist = dist
            closestId = i
         end
      end
   end
   return closestId
end

function getClosestCar()
   -- return 2 values: car handle and car id
   local minDist = 9999
   local closestId = -1
   local closestHandle = false
   local x, y, z = getCharCoordinates(playerPed)
   for i, k in ipairs(getAllVehicles()) do
      local streamed, carId = sampGetVehicleIdByCarHandle(k)
      if streamed then
         local xi, yi, zi = getCarCoordinates(k)
         local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
         if dist < minDist then
            minDist = dist
            closestId = carId
            closestHandle = k
         end
      end
   end
   return closestHandle, closestId
end

function getVehicleInStream()
   local stream = 0
   for i = 0, 2000 do
      local result, car = sampGetCarHandleBySampVehicleId(i)
      if result then
         stream = stream + 1
      end
   end
   return stream
end

function AutoAd()
   lua_thread.create(function()
   while MP.autoAnnounce do
      if input.addtime.v >= 2 then
         wait(input.addtime.v)
      else       
         wait(1000*60*3)-- 3 min
      end
      local prefix = ""
      if isAbsolutePlay then
         prefix = "* "
      elseif isTraining then
         prefix = "/ads "
      else
         prefix = " "
      end 
      
      if checkbox.mpprize.v then
         sampSendChat(prefix..u8:decode(textbuffer.mpadd.v)..", приз "..u8:decode(textbuffer.mpprize.v), -1)
      else
         sampSendChat(prefix..u8:decode(textbuffer.mpadd.v), -1)
      end
   end   
   end)
end

function PlayerWarnings()
   lua_thread.create(function()
   while ini.settings.playerwarnings do
      wait(1000*30)
      for k, handle in ipairs(getAllChars()) do
      --for k, v in pairs(playersTable) do
         local res, id = sampGetPlayerIdByCharHandle(handle)
        -- local res, handle = sampGetCharHandleBySampPlayerId(v)
         if res then
            local nickname = sampGetPlayerNickname(id)
            local weaponid = getCurrentCharWeapon(handle)
            local px, py, pz = getCharCoordinates(handle)
            local health = sampGetPlayerHealth(id)
            local armor = sampGetPlayerArmor(id)
            local ping = sampGetPlayerPing(id)
            local afk = sampIsPlayerPaused(id)
            
            if ini.warnings.undermap then
               if pz < 0.5 then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] возможно находится под картой",
                  nickname, id), 0xFF880000)
               elseif pz > 1000.0 then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] длит в небе (высота: %d)",
                  nickname, id, pz), 0xFF880000)
               end
            end
            
            if ini.warnings.heavyweapons then
               if weaponid == 38 or weaponid == 35 or weaponid == 36 then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] держит в руках тяжелое оружие! (%s [%d])",
                  nickname, id, weaponNames[weaponid], weaponid), 0xFF880000)
               end
            end
            
            if ini.warnings.illegalweapons then
               --print(weaponid)
               for key, value in pairs(legalweapons) do
                  if value ~= weaponid and weaponid > 1 then
                     sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] держит в руках нелегальное оружие! (%s [%d])",
                     nickname, id, weaponNames[weaponid], weaponid), 0xFF880000)
                     break
                  end
               end
            end
            
            if ini.warnings.hprefil then
               if checkbox.healthcheck.v then
                  print(health, tonumber(textbuffer.mphp.v))
                  if health > tonumber(textbuffer.mphp.v) then
                     sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] hp: %d превышает разрешенное значение! (max: %d)",
                     nickname, id, health, tonumber(textbuffer.mphp.v)), 0xFF880000)
                  end
               end
            end
            
            if ini.warnings.armourrefill then
               if checkbox.healthcheck.v then
                  if armour > tonumber(textbuffer.mparmour.v) then
                     sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] armour: %d превышает разрешенное значение! (max: %d)",
                     nickname, id, armour, tonumber(textbuffer.mparmour.v)), 0xFF880000)
                  end
               end
            end
            
            if ini.warnings.laggers then
               if ping > 50 then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] лагер! (ping %d)",
                  nickname, id, ping), 0xFF880000)
               end
            end
            
            if ini.warnings.afk then
               if afk then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] в AFK",
                  nickname, id), 0xFF880000)
               end
            end
         end
      end
   end   
   end)
end

function cleanBindsForm()
   for k, v in pairs(binds) do
      binds[k] = imgui.ImBuffer(256)
   end
end

function reloadBindsFromConfig()
   binds.cmdbind1.v = u8(ini.binds.cmdbind1)
   binds.cmdbind2.v = u8(ini.binds.cmdbind2)
   binds.cmdbind3.v = u8(ini.binds.cmdbind3)
   binds.cmdbind4.v = u8(ini.binds.cmdbind4)
   binds.cmdbind5.v = u8(ini.binds.cmdbind5)
   binds.cmdbind6.v = u8(ini.binds.cmdbind6)
   binds.cmdbind7.v = u8(ini.binds.cmdbind7)
   binds.cmdbind8.v = u8(ini.binds.cmdbind8)
   binds.cmdbind9.v = u8(ini.binds.cmdbind9)
end

function copyNearestPlayersToClipboard()
   local tmpPlayers = {}
   local resulstring
   local totalplayers = 0
   for k, v in ipairs(getAllChars()) do
      local res, id = sampGetPlayerIdByCharHandle(v)
      local pid = getLocalPlayerId()
      if res and id ~= pid then
         totalplayers = totalplayers + 1
         local nickname = sampGetPlayerNickname(id)
         table.insert(tmpPlayers, string.format("%s[%d] ", nickname, id))
      end
   end
   if totalplayers then
      resulstring = table.concat(tmpPlayers)
      setClipboardText(resulstring)
      sampAddChatMessage("Ид и ники "..totalplayers.." игроков рядом скопированы в буфер обмена", -1)
      --return resulstring
   else 
      sampAddChatMessage("Не найдено игроков рядом", -1)
   end
end


-- FYP color utils
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
	
function intToHex(int)
   return '{'..string.sub(bit.tohex(int), 3, 8)..'}'
end

-- imgui fuctions
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

function imgui.Link(link, text)
   text = text or link
   local tSize = imgui.CalcTextSize(text)
   local p = imgui.GetCursorScreenPos()
   local DL = imgui.GetWindowDrawList()
   local col = { 0xFFFF7700, 0xFFFF9900 }
   if imgui.InvisibleButton("##" .. link, tSize) then os.execute('explorer "' .. link ..'"');print(link) end
   local color = imgui.IsItemHovered() and col[1] or col[2]
   DL:AddText(p, color, text)
   DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)

   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(500)
      imgui.TextUnformatted(link)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
end

function imgui.TextQuestion(label, description)
   imgui.TextDisabled(label)

   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
         imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
         imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
end

function resetIO()
   -- Bug fix with focus in inputText (imgui)
   for i = 1, 512 do
      imgui:GetIO().KeysDown[i] = false
   end
   for i = 1, 5 do
      imgui:GetIO().MouseDown[i] = false
   end
   imgui:GetIO().KeyCtrl = false
   imgui:GetIO().KeyShift = false
   imgui:GetIO().KeyAlt = false
   imgui:GetIO().KeySuper = false     
end

-- etc tools

function toggleMainWindow()
   dialog.main.v = not dialog.main.v
end

function getLocalPlayerId()
   local _, id = sampGetPlayerIdByCharHandle(playerPed)
   return id
end

function sampGetPlayerIdByNickname(nick)
   local id = getLocalPlayerId()
   if nick == sampGetPlayerNickname(id) then return id end
   for i = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then return i end
   end
end

function applyCustomStyle()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4

   style.WindowPadding = imgui.ImVec2(15, 15)
   style.WindowRounding = 1.5
   style.FramePadding = imgui.ImVec2(5, 5)
   style.FrameRounding = 4.0
   style.ItemSpacing = imgui.ImVec2(6, 6)
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

applyCustomStyle()