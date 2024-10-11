script_author("1NS")
script_name("MP Helper")
script_description("Assistant for event makers")
script_dependencies('imgui', 'lib.samp.events')
script_properties("work-in-pause")
script_url("https://github.com/ins1x/moonloader-scripts/mphelper")
script_version("1.2.4")
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
      damageme = true,
      heavyweapons = true,
      hprefill = true,
      illegalweapons = true,
      laggers = true,
      novehicle = true,
      undermap = true,
      warndelay = 25,
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
local isWorldHoster = false
local chosenplayer = nil

local dialog = {
   main = imgui.ImBool(false),
   playerstat = imgui.ImBool(false),
   vehstat = imgui.ImBool(false),
   fastanswer = imgui.ImBool(false),
   searchbar = imgui.ImBool(false),
   setteams = imgui.ImBool(false),
}

local tabmenu = {
   mp = 1,
   header = 1,
   manage = 1,
   presets = 1,
   rules = 1,
   checker = 1,
   actions = 1,
}

local textbuffer = {
   findplayer = imgui.ImBuffer(32),
   mpname = imgui.ImBuffer(48),
   mpadd = imgui.ImBuffer(128),
   mpprize = imgui.ImBuffer(32),
   mpdonators = imgui.ImBuffer(128),
   mphp = imgui.ImBuffer(6),
   mparmour = imgui.ImBuffer(6),
   mpanswer = imgui.ImBuffer(64),
   mpquestion = imgui.ImBuffer(128),
   vehiclename = imgui.ImBuffer(64),
   vid = imgui.ImBuffer(5),
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
   warndelay = imgui.ImInt(1000),
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
   selecttable = imgui.ImInt(0),
   chatselect = imgui.ImInt(0),
   textgames = imgui.ImInt(0),
   roles = imgui.ImInt(0),
   fastanswers = imgui.ImInt(0),
   kickreasons = imgui.ImInt(0),
   kicktime = imgui.ImInt(0),
   teamA = imgui.ImInt(0),
   teamB = imgui.ImInt(0),
}

local checkbox = {
   disconnectreminder = imgui.ImBool(ini.settings.disconnectreminder),
   playerwarnings = imgui.ImBool(ini.settings.playerwarnings),
   -- warnings
   damageinformer = imgui.ImBool(ini.warnings.damageme),
   healthcheck = imgui.ImBool(ini.warnings.hprefill),
   novehcheck = imgui.ImBool(ini.warnings.novehicle),
   undermap = imgui.ImBool(ini.warnings.undermap),
   illegalweapons = imgui.ImBool(ini.warnings.illegalweapons),
   
   hideanswer = imgui.ImBool(false),
   donators = imgui.ImBool(false),
   sidebarplayers = imgui.ImBool(false),
   streamermode = imgui.ImBool(false),
   logmp = imgui.ImBool(false),
   mpprize = imgui.ImBool(false),
   trackanswer = imgui.ImBool(false),
   trygame = imgui.ImBool(false),
   copcar = imgui.ImBool(false),
   testrules = imgui.ImBool(false),
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
local teamA = {}
local teamB = {}
local blacklist = {}
local legalweapons = {0, 1}

-- should be global!
playersTotal = 0

local mpNames = {
   u8'Не указано', u8'Гонки', u8'Дерби', u8'Выживание', u8'PvP',
   u8'Смертельная крыша', u8'TDM', u8'Прятки', u8'Викторина',
   u8'Король', u8'Охота', u8'Родео', u8'Road Rash', u8'Рыбалка',
   u8'Копчейз', u8'Защита груза', u8'Поиск предмета'
}

local textGames = {
   u8'NoRules', u8'Анаграммы', u8'Викторина', u8'Крокодил', 
   u8'Караоке', u8'Музыкальный марафон', u8'Загадки'
}

local kickreasons = {
   u8"Чит", u8"AFK", u8"Помеха", u8"High Ping", u8"DM", u8"ДБ", u8"Сбив",
   u8"Teamkill", u8"Spawnkill", u8"CBUG", u8"Flood", u8"PG", u8"nonRP", 
   u8"Rapid", u8"Damager", u8"AirBreak", u8"Speed Hack", u8"Unfreeze", 
   u8"Fakekill", u8"Lag", u8"Invis", u8"Ghost", u8"Fly", u8"Health Hack", 
   u8"Weapon Hack", u8"GodMode", u8"NOP", u8"Crasher", u8"Bypass",
   u8"Texture bug", u8"Engine Hack", u8"Vehicle Hack",
}

local kicktime = {
   "10", "20", "30", "60", "120", "300", "600", "2000"
}

local VehicleNames = {
   "Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper",
   "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo", "Pony",
   "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi",
   "Washington", "Bobcat", "Mr Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
   "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer",
   "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit","Romero",
   "Packer", "Monster Truck", "Admiral", "Squalo", "Seasparrow","Pizzaboy",
   "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic","Flatbed", "Yankee",
   "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway",
   "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot",
   "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
   "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer",
   "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax",
   "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville",
   "Benson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer", "Bloodring Banger",
   "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle",
   "Cropdust", "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer",
   "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
   "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine",
   "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex",
   "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
   "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
   "Yosemite", "Windsor", "Monster Truck", "Monster Truck", "Uranus", "Jester",
   "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma",
   "Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower", "Duneride",
   "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford","BF-400",
   "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
   "Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Lnaunch", "Police Car (LS)",
   "Police Car (SF)", "Police Car (LV)", "Police Ranger", "Picador", "S.W.A.T. Van",
   "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer", "Luggage Trailer",
   "Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
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
      local file = io.open("moonloader/resource/mphelper/fastanswers.txt", "r")
      for line in file:lines() do
         table.insert(fastAnswers, line:lower())
      end
      file:close()
   else
      local file = io.open("moonloader/resource/mphelper/fastanswers.txt", "w")
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
      file:write(u8"Скачать стандартный можно c https://github.com/ins1x/moonloader-scripts/mphelper")
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
   
   input.warndelay.v = tostring(ini.warnings.warndelay)
   textbuffer.mpprize.v = '1'
   textbuffer.setarm.v = '100'
   textbuffer.sethp.v = '100'
   textbuffer.setteam.v = '0'
   textbuffer.setptime.v = '20'
   textbuffer.vehiclename.v = 'bmx'
    
   if ini.settings.playerwarnings then 
      PlayerWarnings()
   end
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
      
      -- CTRL+F (Call search dialog)
      if isKeyDown(0x12) and isKeyJustPressed(0x46) 
      and not sampIsChatInputActive() and not isPauseMenuActive() then 
         if dialog.main.v then
            dialog.searchbar.v = not dialog.searchbar.v
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
      imgui.SetNextWindowSize(imgui.ImVec2(435, 440))
      imgui.Begin(".::  MP Helper  ::.", dialog.main)
      
      local ip, port = sampGetCurrentServerAddress()
      local servername = sampGetCurrentServerName()
      
      imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(5, 2))
      if tabmenu.header == 1 then
         imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
         if imgui.Button(u8"Основное", imgui.ImVec2(120, 30)) then tabmenu.header = 1 end
         imgui.PopStyleColor()
      else
         if imgui.Button(u8"Основное", imgui.ImVec2(120, 30)) then tabmenu.header = 1 end
      end
      
      imgui.SameLine()
      if tabmenu.header == 2 then
         imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
         if imgui.Button(u8"Управление", imgui.ImVec2(120, 30)) then tabmenu.header = 2 end
         imgui.PopStyleColor()
      else
         if imgui.Button(u8"Управление", imgui.ImVec2(120, 30)) then tabmenu.header = 2 end
      end
      
      imgui.SameLine()
      if tabmenu.header == 3 then
         imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
         if imgui.Button(u8"Бинды", imgui.ImVec2(120, 30)) then tabmenu.header = 3 end
         imgui.PopStyleColor()
      else
         if imgui.Button(u8"Бинды", imgui.ImVec2(120, 30)) then tabmenu.header = 3 end
      end
      
      imgui.SameLine()
      if tabmenu.header == 4 then
         imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
         if imgui.Button(u8" ? ", imgui.ImVec2(30, 30)) then tabmenu.header = 4 end
         imgui.PopStyleColor()
      else
         if imgui.Button(u8" ? ", imgui.ImVec2(30, 30)) then tabmenu.header = 4 end
      end
      
      imgui.PopStyleVar()
      imgui.Spacing()
      imgui.Spacing()
         
      if tabmenu.header == 1 then
         resetIO()

         imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 2))
         if tabmenu.mp == 1 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Подготовка", imgui.ImVec2(80, 30)) then tabmenu.mp = 1 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Подготовка", imgui.ImVec2(80, 30)) then tabmenu.mp = 1 end
         end
         
         imgui.SameLine()
         if tabmenu.mp == 2 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Место", imgui.ImVec2(80, 30)) then tabmenu.mp = 2 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Место", imgui.ImVec2(80, 30)) then tabmenu.mp = 2 end
         end
         
         imgui.SameLine()
         if tabmenu.mp == 3 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Команды", imgui.ImVec2(80, 30)) then tabmenu.mp = 3 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Команды", imgui.ImVec2(80, 30)) then tabmenu.mp = 3 end
         end
         
         imgui.SameLine()
         if tabmenu.mp == 4 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Объявление", imgui.ImVec2(80, 30)) then tabmenu.mp = 4 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Объявление", imgui.ImVec2(80, 30)) then tabmenu.mp = 4 end
         end
         
         imgui.SameLine()
         if tabmenu.mp == 5 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Финал МП", imgui.ImVec2(80, 30)) then tabmenu.mp = 5 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Финал МП", imgui.ImVec2(80, 30)) then tabmenu.mp = 5 end
         end
         imgui.PopStyleVar()
         imgui.Spacing()
         
         
         if tabmenu.mp == 1 then
         
            imgui.TextColoredRGB("Сервер: {F0AD00}" .. servername)
            if MP.Started then
               if string.len(textbuffer.mpname.v) > 1 
               and textbuffer.mpname.v ~= u8"Введите название" then
                  imgui.SameLine()
                  imgui.TextColoredRGB("МП: {F0AD00}" .. tostring(u8:decode(textbuffer.mpname.v)))
               end
            end
            
            if isTraining then
               if string.len(LastData.lastWorldName) > 1 then
                  imgui.SameLine()
                  imgui.TextColoredRGB("Мир: "..LastData.lastWorldName)
               end
            end
            
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
	        imgui.PushItemWidth(170)
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
            
            
            imgui.Text(u8"Список игроков:")
            if imgui.Button(u8"Обновить список игроков МП", imgui.ImVec2(200, 25)) then
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
            if imgui.Button(u8"Вывести список игроков", imgui.ImVec2(200, 25)) then
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
            imgui.SameLine()
            if imgui.Button(u8"Перейти к выдаче призов",imgui.ImVec2(170, 30)) then tabmenu.mp = 5 end
	        imgui.Spacing()
         
         elseif tabmenu.mp == 2 then   
            
            local citiesList = {'Los-Santos', 'San-Fierro', 'Las-Venturas'}
		    local city = getCityPlayerIsIn(PLAYER_HANDLE)
		    if city > 0 then 
               playerCity = citiesList[city] 
               imgui.TextColoredRGB(string.format("Город: {F0AD00}%s", playerCity))
            end
        
            local positionX, positionY, positionZ = getCharCoordinates(playerPed)
            local zone = getZoneName(positionX, positionY, positionZ)
            if zone then 
               imgui.TextColoredRGB(string.format("Вы находитесь в районе: {F0AD00}%s", zone))
            end
            
            local positionX, positionY, positionZ = getCharCoordinates(playerPed)
            local id = getLocalPlayerId()
            local score = sampGetPlayerScore(id)
            
            imgui.TextColoredRGB(string.format("Ваша позиция на карте {696969}x: %.1f, y: %.1f, z: %.1f",
            positionX, positionY, positionZ))
            if imgui.IsItemClicked() then
               setClipboardText(string.format(u8"%.1f, %.1f, %.1f", positionX, positionY, positionZ))
               sampAddChatMessage("[SCRIPT]: {FFFFFF}Позиция скопирована в буфер обмена", 0x0FF6600)
            end
            
            local bTargetResult, bX, bY, bZ = getTargetBlipCoordinates()
            if bTargetResult then
               imgui.Text(string.format(u8"Позиция метки на карте x: %.1f, y: %.1f, z: %.1f",
               bX, bY, bZ))
               if imgui.IsItemClicked() then
                  setClipboardText(string.format(u8"%.1f, %.1f, %.1f", bX, bY, bZ))
                  sampAddChatMessage("[SCRIPT]: {FFFFFF}Позиция скопирована в буфер обмена", 0x0FF6600)
               end
            
               imgui.SameLine()
               imgui.Text(string.format(u8"dist. %.1f m.",
               getDistanceBetweenCoords3d(positionX, positionY, positionZ, bX, bY, bZ)))
            end 
            
            imgui.Spacing()
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
            if imgui.TooltipButton(u8"Настр. спавн", imgui.ImVec2(100, 25), u8"Настроить спавн игроков") then
               if isTraining then
                  sampSendChat("/team")
                  dialog.main.v = false
               elseif isAbsolutePlay then
                  sampAddChatMessage("[SCRIPT]: {FFFFFF} Y - Редактор карт - Управление миром - Выбрать точку появления", 0x0FF6600)
                  sampSendChat("/tplist")
               end
            end
            
            --imgui.SameLine()
            if imgui.TooltipButton(u8"Сообщить местоположение в чат", imgui.ImVec2(240, 25), u8"Сообщить ваше текущее местоположение") then
               sampSetChatInputEnabled(true)
               local positionX, positionY, positionZ = getCharCoordinates(playerPed)
               zone = getZoneName(positionX, positionY, positionZ)
               sampSetChatInputText("Находимся в районе - "..zone)
               dialog.main.v = false
            end
            
            
         elseif tabmenu.mp == 3 then
         
            local roles = {
                u8"Не выбрана",
                u8"Капитаном", 
                u8"Летчиком", 
                u8"Стрелком",
                u8"Охотником",
                u8"Водителем",
                u8"Похитителем",
                u8"Саппортом", 
                u8"Модератором", 
            }
            
            imgui.Text(u8"Поиск участников:")
            if imgui.Button(u8"Нужен один игрок на МП фастом", imgui.ImVec2(220, 25)) then
               sampSetChatInputEnabled(true)
               sampSetChatInputText('Нужен один игрок на МП фастом. Кто желает?')
            end
            imgui.SameLine()
            imgui.TextColoredRGB("{696969}Всего участников: "..playersTotal)
            
            if imgui.Button(u8"Желает кто быть", imgui.ImVec2(220, 25)) then
               sampSetChatInputEnabled(true)
               if combobox.roles.v ~= 0 then
                  sampSetChatInputText('Желает кто быть '..u8:decode(roles[combobox.roles.v+1])..' на МП?')
               else
                  sampSetChatInputText('Желает кто быть ')
               end
            end
 
            imgui.PushItemWidth(150)
            imgui.SameLine()
            imgui.Combo(u8'##ComboBoxRoles', combobox.roles, roles, #roles)
            imgui.SameLine()
            imgui.TextQuestion("( ? )", u8"Выдать права модератора в мире")
            
            imgui.Text(u8"Выбор капитана:")
	        if imgui.Button(u8"Игрок с наибольшим уровнем", imgui.ImVec2(200, 25)) then
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
	        if imgui.Button(u8"Выбрать случайного игрока", imgui.ImVec2(200, 25)) then
	           if next(playersTable) == nil then -- if playersTable is empty
	              sampAddChatMessage("Сперва обнови список игроков!", -1) 
	           else
	              local rand = math.random(playersTotal)
	              chosenplayer = playersTable[rand]                
	              sampAddChatMessage("Случайный игрок: ".. sampGetPlayerNickname(playersTable[rand]), -1)
	           end
	        end
            
            if imgui.Button(u8"Настройки тимы", imgui.ImVec2(300, 25)) then
               dialog.setteams.v = not dialog.setteams.v
            end
            
         elseif tabmenu.mp == 4 then
         
            resetIO()
         
            imgui.Text(u8"Объявление: ")
            imgui.PushItemWidth(400)
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
            if imgui.TooltipButton(u8"Подать объявление", imgui.ImVec2(200, 25), u8"Аннонсировать в объявление") then
               if string.len(textbuffer.mpadd.v) > 0 then 
                  sampSetChatInputEnabled(true)
                  if checkbox.mpprize.v then
                     if isAbsolutePlay then
                        sampSetChatInputText(string.format("/об %s, приз %s", u8:decode(textbuffer.mpadd.v), u8:decode(textbuffer.mpprize.v)))
                     elseif isTraining then 
                        sampSetChatInputText(string.format("/ads %s, приз %s", u8:decode(textbuffer.mpadd.v), u8:decode(textbuffer.mpprize.v)))
                     else
                        sampSetChatInputText(string.format("/ad %s, приз %s", u8:decode(textbuffer.mpadd.v), u8:decode(textbuffer.mpprize.v)))
                     end
                  else
                     if isAbsolutePlay then
                        sampSetChatInputText(string.format("/об %s", u8:decode(textbuffer.mpadd.v)))
                     elseif isTraining then 
                        sampSetChatInputText(string.format("/ads %s", u8:decode(textbuffer.mpadd.v)))
                     else
                        sampSetChatInputText(string.format("/ad %s", u8:decode(textbuffer.mpadd.v)))
                     end
                  end
               else
                  sampAddChatMessage("Сперва укажите текст объявления!", -1)
               end
            end
 
            imgui.SameLine()
            if imgui.TooltipButton(u8"Протестировать", imgui.ImVec2(200, 25), u8:encode("Выведет сообщение только вам для теста")) then
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
            
            imgui.SameLine()
            imgui.Text(u8"   ")
            imgui.SameLine()
            if imgui.TooltipButton(u8"screens", imgui.ImVec2(60, 25), u8"Открыть каталог скриншотов") then
               local path = getFolderPath(5)..'\\GTA San Andreas User Files\\SAMP\\screens\\'
               os.execute('explorer '.. path)
            end
            imgui.SameLine()
            if imgui.TooltipButton(u8"chatlog", imgui.ImVec2(60, 25), u8"Открыть чатлог") then
               local path = getFolderPath(5)..'\\GTA San Andreas User Files\\SAMP\\chatlog.txt'
               os.execute('explorer '.. path)
            end
            -- imgui.SameLine()
            -- if imgui.TooltipButton(u8"video", imgui.ImVec2(60, 25), u8"Открыть каталог видеозаписей") then
               -- local path = getFolderPath(5)..'\\Bandicam\\'
               -- os.execute('explorer '.. path)
            -- end
            
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
               
		       if res and id ~= pid then
                  playerscounter = playerscounter + 1
                  if playerscounter >= 9 then
                     break
                  end
                  imgui.Text("  ")
                  imgui.SameLine()
                  local nick = sampGetPlayerNickname(id)
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
	        if imgui.Button(u8"Id и ники игроков рядом", imgui.ImVec2(200, 25)) then
               copyNearestPlayersToClipboard()
	        end
            imgui.SameLine()
            if imgui.Button(u8"Всем спасибо!", imgui.ImVec2(200, 25)) then
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
            if imgui.Button(u8"Объявить победителей МП", imgui.ImVec2(200, 25)) then
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
            if imgui.Button(u8"Победители не выходите", imgui.ImVec2(200, 25)) then
               sampSetChatInputEnabled(true)
               sampSetChatInputText('* Победители не выходите! Дождитесь выдачи приза.')
               dialog.main.v = not dialog.main.v 
	        end
            imgui.Spacing()         
         end --end tabmenu.mp
         
      elseif tabmenu.header == 2 then
         resetIO()
         local pid -- selected player id
         local playerId = getLocalPlayerId()
         if string.len(textbuffer.pid.v) < 1 then
            textbuffer.pid.v = tostring(playerId)
         end
         
         if string.len(textbuffer.pid.v) >= 1 
         and sampIsPlayerConnected(tonumber(textbuffer.pid.v))then
            pid = tonumber(textbuffer.pid.v)
         else
            pid = tostring(playerId)
         end             
         
         local vid = 0
         
         imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 2))

         if tabmenu.manage == 1 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Действия", imgui.ImVec2(95, 30)) then tabmenu.manage = 1 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Действия", imgui.ImVec2(95, 30)) then tabmenu.manage = 1 end
         end
         imgui.SameLine()
         if tabmenu.manage == 2 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Проверка", imgui.ImVec2(95, 30)) then tabmenu.manage = 2 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Проверка", imgui.ImVec2(95, 30)) then tabmenu.manage = 2 end
         end
         imgui.SameLine()
         if tabmenu.manage == 3 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Наказания", imgui.ImVec2(95, 30)) then tabmenu.manage = 3 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Наказания", imgui.ImVec2(95, 30)) then tabmenu.manage = 3 end
         end
         imgui.SameLine()
         if tabmenu.manage == 4 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Зона стрима", imgui.ImVec2(95, 30)) then tabmenu.manage = 4 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Зона стрима", imgui.ImVec2(95, 30)) then tabmenu.manage = 4 end
         end
         imgui.PopStyleVar()
         imgui.Spacing()
         
         if tabmenu.manage == 1 then
         
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 2))
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Игрок").x) / 2.8)
            if tabmenu.actions == 1 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Игрок", imgui.ImVec2(80, 25)) then tabmenu.actions = 1 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Игрок", imgui.ImVec2(80, 25)) then tabmenu.actions = 1 end
            end
            imgui.SameLine()
            if tabmenu.actions == 2 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Транспорт", imgui.ImVec2(80, 25)) then tabmenu.actions = 2 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Транспорт", imgui.ImVec2(80, 25)) then tabmenu.actions = 2 end
            end
            imgui.SameLine()
            if tabmenu.actions == 3 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Для всех", imgui.ImVec2(80, 25)) then tabmenu.actions = 3 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Для всех", imgui.ImVec2(80, 25)) then tabmenu.actions = 3 end
            end
            imgui.PopStyleVar()
            imgui.Spacing()
            
            
            if tabmenu.actions == 1 then 
               if imgui.TooltipButton(u8"spec", imgui.ImVec2(50, 25), u8"Уйти в наблюдение за игроком") then
                  if isTraining then
                     sampSendChat("/sp "..pid)
                  else
                     sampSendChat("/spec "..pid)
                  end
               end
               imgui.SameLine()
               imgui.Text(u8"Введите ID:")
               imgui.SameLine()
               imgui.PushItemWidth(50)
               if imgui.InputText("##PlayerIDBuffer", textbuffer.pid, imgui.InputTextFlags.CharsDecimal) then
               end
               imgui.PopItemWidth()
               
               if pid then
                  imgui.SameLine()
                  imgui.Text(u8""..sampGetPlayerNickname(pid))
               end
               
               if getClosestPlayerId() ~= -1 then
                  imgui.SameLine()
                  imgui.Text(u8"  ")
                  imgui.SameLine()
                  imgui.TextColoredRGB("{424242}[s]")
                  if imgui.IsItemHovered() then
                     imgui.BeginTooltip()
                     imgui.PushTextWrapPos(350)
                     imgui.TextUnformatted(tostring(u8"Ближайший игрок: "..sampGetPlayerNickname(getClosestPlayerId())).."["..getClosestPlayerId().."]")
                     imgui.PopTextWrapPos()
                     imgui.EndTooltip()
                  end
                  if imgui.IsItemClicked() then
                     setClipboardText(getClosestPlayerId())
                     textbuffer.pid.v = tostring(getClosestPlayerId())
                  end
               end
               
               if isAbsolutePlay then
                  imgui.TextColoredRGB("{FF0000}Для Absolute Play данный раздел без админки не работает")
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
               if isTraining then
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
               end
               
            elseif tabmenu.actions == 2 then
            
               local closestcarhandle, closestcarid = getClosestCar()
               if closestcarhandle then
                  local closestcarmodel = getCarModel(closestcarhandle)
                  imgui.Text(string.format(u8"Ближайший т/с: %s [model: %i] (id:%i)",
                  VehicleNames[closestcarmodel-399], closestcarmodel, closestcarid))
                  if imgui.IsItemClicked() then
                     setClipboardText(closestcarid)
                     textbuffer.vid.v = tostring(closestcarid)
                  end
                  imgui.SameLine()
                  imgui.TextQuestion("( ? )", u8"В скобках указан внутренний ID (/dl)")
               end
                  
               if isCharInAnyCar(playerPed) then 
                  local carhandle = storeCarCharIsInNoSave(playerPed)
                  local carmodel = getCarModel(carhandle)
                  imgui.Text(string.format(u8"Вы в транспорте: %s [model: %i]",
                  VehicleNames[carmodel-399], carmodel))
                  if imgui.IsItemClicked() then
                     local result, id = sampGetVehicleIdByCarHandle(carhandle)
                     if result then
                        setClipboardText(id)
                        textbuffer.vid.v = tostring(id)
                     end
                  end
               end
               
               imgui.Spacing()
               imgui.Text(u8"Введите ID:")
               imgui.SameLine()
               imgui.PushItemWidth(50)
               if imgui.InputText("##VehicleIDBuffer", textbuffer.vid, imgui.InputTextFlags.CharsDecimal) then
               end
               imgui.PopItemWidth()
               
               if textbuffer.vid.v then
                  --imgui.Text(u8""..sampGetPlayerNickname(pid))
                  vid = tonumber(textbuffer.vid.v)
                  if vid then
                     local result, car = sampGetCarHandleBySampVehicleId(id)
                     if result then
                        local carmodel = getCarModel(car)
                        imgui.SameLine()
                        imgui.Text(string.format(u8"Вы в транспорте: %s(%i)",
                        VehicleNames[carmodel-399], carmodel))
                     end
                  end
               end
               
               imgui.PushItemWidth(200)
               if imgui.InputText("##PlayerIdVehicle", textbuffer.vehiclename) then
               end
               imgui.PopItemWidth()
               imgui.SameLine()
               imgui.TextQuestion("( ? )", u8"Укажите ID либо имя транспорта")
               
               if imgui.Button(u8"Создать транспорт", imgui.ImVec2(150, 25)) then
                  if string.len(textbuffer.vehiclename.v) >= 3 then
                     if isTraining then
                        if checkbox.copcar.v then
                           sampSendChat("/veh "..textbuffer.vehiclename.v)
                        else
                           sampSendChat("/veh "..textbuffer.vehiclename.v)
                        end
                     elseif isAbsolutePlay then
                        sampSendChat("/машину2 "..textbuffer.vehiclename.v)
                     end
                  else
                     sampAddChatMessage("Вы не указали ID транспорта", -1)
                  end
               end
               imgui.SameLine()
               imgui.Checkbox(u8"Мигалка", checkbox.copcar)
               
               imgui.Spacing()
               if imgui.Button(u8"Открыть меню управления", imgui.ImVec2(250, 25)) then
                  if vid then
                     sampSendChat("/vmenu "..vid)
                  else
                     sampAddChatMessage("Вы не указали ID транспорта", -1)
                  end
                  toggleMainWindow()
               end
               if imgui.Button(u8"ТП к себе", imgui.ImVec2(125, 25)) then
                  if vid then
                     if isAbsolutePlay then
                        sampAddChatMessage("[SCRIPT]: {FFFFFF}Недоступно для вашего сервера", 0x0FF6600) 
                     else
                        sampSendChat("/vgethere "..vid)
                     end
                  else
                     sampAddChatMessage("Вы не указали ID транспорта", -1)
                  end
               end
               imgui.SameLine()
               if imgui.Button(u8"ТП к транспорту", imgui.ImVec2(125, 25)) then
                  if vid then
                     if isTraining then
                        sampSendChat("/tpveh "..vid)
                     elseif isAbsolutePlay then
                        sampSendChat("/gotocar "..vid)
                     end
                  else
                     sampAddChatMessage("Вы не указали ID транспорта", -1)
                  end
               end
               imgui.Spacing()
               if imgui.Button(u8"Удалить", imgui.ImVec2(120, 25)) then
                  if vid then
                     sampSendChat("/delveh "..vid)
                  else
                     sampAddChatMessage("Вы не указали ID транспорта", -1)
                  end
               end
            
            elseif tabmenu.actions == 3 then
               imgui.Text(u8"Для всех игроков в мире:")
               if imgui.Button(u8"Пополнить хп", imgui.ImVec2(150, 25)) then
                  if isTraining then
                     sampSendChat("/health 100")
                     sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили хп до 100 всем игрокам в мире", 0x0FF6600)
                  else
                     sampSendChat("/hpall 100")
                  end
               end
               imgui.SameLine()
               if imgui.Button(u8"Пополнить броню", imgui.ImVec2(150, 25)) then
                  if isTraining then
                     sampSendChat("/armour 100")
                     sampAddChatMessage("[SCRIPT]: {FFFFFF}Вы пополнили броню до 100 всем игрокам в мире", 0x0FF6600)
                  else
                     sampSendChat("/armall 100")
                  end
               end
               if imgui.Button(u8"Ресснуть игроков", imgui.ImVec2(150, 25)) then
                  if isTraining then
                     sampSendChat("/ressall")
                  else
                     sampSendChat("/refillall")
                  end
               end
               imgui.SameLine()
               if imgui.Button(u8"Заморозить игроков", imgui.ImVec2(150, 25)) then
                  if isTraining then
                     sampAddChatMessage("Недоступно для вашего сервера.", -1)
                  elseif isAbsolutePlay then
                     sampSendChat("/tazerall")
                  else
                     sampSendChat("/freezeall")
                  end
               end
               
               imgui.Text(u8"Транспорт:")
               if imgui.Button(u8"Починить весь транспорт рядом", imgui.ImVec2(250, 25)) then
                  if isAbsolutePlay then
                     sampSendChat("/fixvehs")
                  else
                     sampAddChatMessage("Недоступно для вашего сервера.", -1)
                  end
               end
               if imgui.Button(u8"Зареспавить весь транспорт рядом", imgui.ImVec2(250, 25)) then
                  if isAbsolutePlay then
                     sampSendChat("/spcars")
                  else
                     sampAddChatMessage("Недоступно для вашего сервера.", -1)
                  end
               end
            end
            
         elseif tabmenu.manage == 2 then
            resetIO()
            
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 0))
            
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Списки").x) / 2.0)
            if tabmenu.checker == 2 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Списки", imgui.ImVec2(100, 25)) then tabmenu.checker = 2 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Списки", imgui.ImVec2(100, 25)) then tabmenu.checker = 2 end
            end
            imgui.SameLine()
            if tabmenu.checker == 1 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Варнинги", imgui.ImVec2(100, 25)) then tabmenu.checker = 1 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Варнинги", imgui.ImVec2(100, 25)) then tabmenu.checker = 1 end
            end

            imgui.PopStyleVar()
            
            if tabmenu.checker == 1 then
            
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
               
               imgui.Text(u8"Проверять каждые ")
               imgui.SameLine()
               imgui.PushItemWidth(150)
               if imgui.InputInt("##warndelay", input.warndelay) then
                  if input.warndelay.v > 1 and input.warndelay.v < 1000 then
                     ini.warnings.warndelay = input.warndelay.v
                     inicfg.save(ini, configIni)
                  else
                     input.warndelay.v = 30
                     sampAddChatMessage("Неверный параметр. Введите время в секундах", -1)
                  end
               end
               imgui.PopItemWidth()
               imgui.SameLine()
               imgui.Text(u8" секунд")
               
               if imgui.Checkbox(u8("Проверять изменение хп и брони"), checkbox.healthcheck) then
                  ini.warnings.hprefil = checkbox.healthcheck.v
                  ini.warnings.armourrefill = checkbox.healthcheck.v
                  inicfg.save(ini, configIni)
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
               
               if imgui.Checkbox(u8("Уведомлять при нанесении по вам урона"), checkbox.damageinformer) then
                  ini.warnings.damageme = checkbox.damageinformer.v
                  inicfg.save(ini, configIni)
               end
               
               if imgui.Checkbox(u8("Уведомлять если игрок не в транспорте"), checkbox.novehcheck) then
                  ini.warnings.novehicle = checkbox.novehcheck.v
                  inicfg.save(ini, configIni)
               end
               
               if imgui.Checkbox(u8("Проверять на нахождение под картой(или в воде)"), checkbox.undermap) then
                  ini.warnings.undermap = checkbox.undermap.v
                  inicfg.save(ini, configIni)
               end
               
               if imgui.Checkbox(u8("Проверять на нелегальное оружие"), checkbox.illegalweapons) then
                  ini.warnings.illegalweapons = checkbox.illegalweapons.v
                  inicfg.save(ini, configIni)
               end
               
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
               
               imgui.Spacing()
            elseif tabmenu.checker == 2 then
            
               if imgui.Checkbox(u8("Уведомлять о дисконнекте игроков из списка"), checkbox.disconnectreminder) then
	   	          if checkbox.disconnectreminder.v then
	 	        	 sampAddChatMessage("При вылете игроков с сервера будет выводить уведомление", -1)
	 	          else
	 	             sampAddChatMessage("Отключены уведомления о вылете игроков с сервера", -1)
	 	          end
	           end
               
               if imgui.Checkbox(u8("Боковая панель со списком игроков в стриме"), checkbox.sidebarplayers) then
                  ini.settings.mode = checkbox.sidebarplayers.v
                  inicfg.save(ini, configIni)
               end
               
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
            end
         elseif tabmenu.manage == 3 then
            
            if isAbsolutePlay then
               imgui.TextColoredRGB("{FF0000}Для Absolute Play данный раздел без админки не работает")
            end
            
            if tonumber(pid) == tonumber(getLocalPlayerId()) then
               imgui.TextColoredRGB("{FF0000}Измените id чтобы не выдать наказание самому себе!")
            end
            
            -- if imgui.TooltipButton(u8" << ", imgui.ImVec2(50, 25), u8"Открыть статистику выбранного игрока") then
               -- for k, v in pairs(getAllChars()) do
                  -- --print(k, v)
                  -- local res, id = sampGetPlayerIdByCharHandle(v)
                  -- if res then
                     -- if id == tonumber(pid) then 
                        -- chosenplayer = v
                        -- break
                     -- end
                  -- end
               -- end
               -- if not dialog.playerstat.v then dialog.playerstat.v = true end
            -- end
            -- imgui.SameLine()
            if imgui.TooltipButton(u8"spec", imgui.ImVec2(50, 25), u8"Уйти в наблюдение за игроком") then
               if isTraining then
                  sampSendChat("/sp "..pid)
               else
                  sampSendChat("/spec "..pid)
               end
            end
            imgui.SameLine()
            imgui.Text(u8"Введите ID:")
            imgui.SameLine()
            imgui.PushItemWidth(50)
            if imgui.InputText("##PlayerIDBuffer", textbuffer.pid, imgui.InputTextFlags.CharsDecimal) then
            end
            imgui.PopItemWidth()
            
            if pid then
               imgui.SameLine()
               imgui.Text(u8""..sampGetPlayerNickname(pid))
            end
            
            if getClosestPlayerId() ~= -1 then
               imgui.SameLine()
               imgui.Text(u8"  ")
               imgui.SameLine()
               imgui.TextColoredRGB("{424242}[s]")
               if imgui.IsItemHovered() then
                  imgui.BeginTooltip()
                  imgui.PushTextWrapPos(350)
                  imgui.TextUnformatted(tostring(u8"Ближайший игрок: "..sampGetPlayerNickname(getClosestPlayerId())).."["..getClosestPlayerId().."]")
                  imgui.PopTextWrapPos()
                  imgui.EndTooltip()
               end
               if imgui.IsItemClicked() then
                  setClipboardText(getClosestPlayerId())
                  textbuffer.pid.v = tostring(getClosestPlayerId())
               end
            end
               
            imgui.Text(u8"Причина: ")
            imgui.PushItemWidth(100)
            if imgui.Combo(u8'##ComboBoxKickreasons', combobox.kickreasons, 
            kickreasons, #kickreasons) then
               textbuffer.setreason.v = tostring(kickreasons[combobox.kickreasons.v+1])
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.PushItemWidth(240)
            if imgui.InputText(u8"##kickreasonbuff", textbuffer.setreason) then
            end
            imgui.PopItemWidth()
            
            imgui.PushItemWidth(70)
            if imgui.Combo(u8'##ComboBoxKicktime', combobox.kicktime, 
            kicktime, #kicktime) then
               textbuffer.setptime.v = tostring(kicktime[combobox.kicktime.v+1])
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.PushItemWidth(50)
            if imgui.InputText(u8"минут", textbuffer.setptime, imgui.InputTextFlags.CharsDecimal) then
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.TextQuestion("( ? )", u8"Чтобы забанить навсегда укажите 0 в графу с минутами")
            imgui.Spacing()
            
            imgui.Text(u8"Действие: ")
            if imgui.Button(u8"Кикнуть", imgui.ImVec2(100, 25)) then
               if string.len(textbuffer.setreason.v) >= 3 then
                  if isTraining then
                     sampSendChat("/vkick "..pid.." "..textbuffer.setreason.v)
                  else
                     sampSendChat("/kick "..pid.." "..textbuffer.setreason.v)
                  end
               else
                  sampAddChatMessage("Вы не указали причину", -1)
               end
            end
            imgui.SameLine()
            if imgui.Button(u8"Забанить", imgui.ImVec2(100, 25)) then
               if string.len(textbuffer.setptime.v) >= 1 then
                  if string.len(textbuffer.setreason.v) >= 3 then
                     if isTraining then
                        sampSendChat("/vban "..pid.." "..tonumber(textbuffer.setptime.v).." "..textbuffer.setreason.v)
                     else
                        sampSendChat("/ban "..pid.." "..tonumber(textbuffer.setptime.v).." "..textbuffer.setreason.v)
                     end
                  else
                     sampAddChatMessage("Вы не указали причину", -1)
                  end
               else
                  sampAddChatMessage("Вы не указали на какое время выдать наказание", -1)
               end
            end
            imgui.SameLine()
            if imgui.Button(u8"Заглушить", imgui.ImVec2(100, 25)) then
               if string.len(textbuffer.setptime.v) >= 1 then
                  if string.len(textbuffer.setreason.v) >= 3 then
                     if isTraining then
                        sampSendChat("/vmute "..pid.." "..tonumber(textbuffer.setptime.v).." "..textbuffer.setreason.v)
                     else
                        sampSendChat("/mute "..pid.." "..tonumber(textbuffer.setptime.v).." "..textbuffer.setreason.v)
                     end
                  else
                     sampAddChatMessage("Вы не указали причину", -1)
                  end
               else
                  sampAddChatMessage("Вы не указали на какое время выдать наказание", -1)
               end
            end
            imgui.Spacing()
            if imgui.Button(u8"Заковать в наручники", imgui.ImVec2(150, 25)) then
               sampSendChat("/cuff "..pid)
               sampAddChatMessage("Вы заковали в наручники игрока "..sampGetPlayerNickname(pid).."("..pid.."). Введите /uncuff id для снятия.", -1)
            end
            imgui.SameLine()
            if imgui.Button(u8"Выкинуть с команды", imgui.ImVec2(150, 25)) then
               sampSendChat("/unteam "..pid)
            end
            
            if imgui.Button(u8"Обнулить хп", imgui.ImVec2(150, 25)) then
               sampSendChat("/sethp "..pid.." 0")
               sampAddChatMessage("Вы обнулили хп игроку "..sampGetPlayerNickname(pid).."("..pid..")", -1)
            end
            
         elseif tabmenu.manage == 4 then   
            
            --imgui.Text(u8"Выберите сущность:")
            --imgui.SameLine()
            imgui.PushItemWidth(120)
            local selecttableitems = {u8'Игроки', u8'Транспорт'}
            imgui.Combo(u8'##ComboBoxSelecttable', combobox.selecttable, 
            selecttableitems, #selecttableitems)
            imgui.PopItemWidth()
       
            if combobox.selecttable.v == 0 then          
                playersTable = {}       
                playersTotal = 0
            
                for k, v in ipairs(getAllChars()) do
                   local res, id = sampGetPlayerIdByCharHandle(v)
                   if res then
                       table.insert(playersTable, id)
                       playersTotal = playersTotal + 1
                    end
                 end
                
                -- imgui.SameLine()
                -- if imgui.TooltipButton(u8"Очистить", imgui.ImVec2(100, 25), u8:encode("Очистить таблицу")) then
                   -- playersTable = {}       
                   -- playersTotal = 0
                   -- if dialog.playerstat.v then dialog.playerstat.v = false end
                   -- chosenplayer = nil
                -- end
                imgui.SameLine()
                imgui.Text(u8"Найти в таблице:")
             
                imgui.SameLine()
                imgui.PushItemWidth(170)
                if imgui.InputText("##FindPlayer", textbuffer.findplayer) then 
                   for k, v in pairs(playersTable) do
                      local nickname = sampGetPlayerNickname(v)
                      if nickname == u8:decode(textbuffer.findplayer.v) then
                         printStringNow("finded", 1000)
                         chosenplayer = sampGetPlayerIdByNickname(nickname)
                      end
                   end
                end
                imgui.PopItemWidth()
             
                if chosenplayer then
                   local nickname = sampGetPlayerNickname(chosenplayer)
                   local ucolor = sampGetPlayerColor(chosenplayer)
                   imgui.TextColoredRGB(string.format("Выбран игрок: {%0.6x} %s[%d]",
                   bit.band(ucolor,0xffffff), nickname, chosenplayer))
                else
                   imgui.TextColoredRGB("{FF0000}Красным{CDCDCD} в таблице отмечены подозрительные игроки")
                end
                
                if getClosestPlayerId() ~= -1 then
                   imgui.Text(u8"Ближайший игрок: ")
                   imgui.SameLine()
                   if imgui.Selectable(tostring(sampGetPlayerNickname(getClosestPlayerId())).."["..getClosestPlayerId().."]", false, 0, imgui.ImVec2(200, 15)) then
                      setClipboardText(getClosestPlayerId())
                      sampAddChatMessage("ID скопирован в буфер обмена", -1)
                   end
                end
                --imgui.Spacing()
                
                imgui.Separator()
                imgui.Columns(5)
                imgui.TextQuestion("[ID]", u8"Нажмите на id чтобы скопировать в буфер id игрока")
                imgui.NextColumn()
                imgui.TextQuestion("Nickname", u8"Нажмите на никнейм чтобы открыть меню игрока")
                imgui.NextColumn()
                imgui.Text("Score")
                imgui.NextColumn()
                imgui.Text("HP (Armour)")
                imgui.NextColumn()
                imgui.Text("Ping")
                imgui.Columns(1)
                imgui.Separator()
             
                for k, v in pairs(playersTable) do
                   local health = sampGetPlayerHealth(v)
                   local armor = sampGetPlayerArmor(v)
                   local ping = sampGetPlayerPing(v)
                   local nickname = sampGetPlayerNickname(v)
                   local score = sampGetPlayerScore(v)
                   local ucolor = sampGetPlayerColor(v)
                
                   imgui.Columns(5)
                   imgui.TextColoredRGB(string.format("[%d]", v ))
                   if imgui.IsItemClicked() then
                      setClipboardText(v)
                      sampAddChatMessage("Скопирован в буфер обмена", -1)
                   end
                   imgui.SetColumnWidth(-1, 40)
                   imgui.NextColumn()
                   if sampIsPlayerPaused(v) then
                      imgui.TextColoredRGB("{FF0000}[AFK]")
                      imgui.SameLine()
                   end
                   --imgui.TextColoredRGB(string.format("{%0.6x} %s", bit.band(ucolor,0xffffff), nickname))
                   imgui.Selectable(u8(nickname))
                   if imgui.IsItemClicked() then
                      chosenplayer = v
                      if not dialog.playerstat.v then dialog.playerstat.v = true end
                   end
                   imgui.SetColumnWidth(-1, 200)
                   imgui.NextColumn()
            
                   imgui.TextColoredRGB(string.format("%i", score))
            
                   imgui.SetColumnWidth(-1, 60)
                   imgui.NextColumn()
                   if health >= 5000 then
                      imgui.TextColoredRGB("{FF0000}Бессмертный")
                   elseif health <= 100 then
                      imgui.TextColoredRGB(string.format("%i (%i)", health, armor))
                   else
                      imgui.TextColoredRGB(string.format("{FF0000}%i (%i)", health, armor))
                   end
                   imgui.SetColumnWidth(-1, 80)
                   imgui.NextColumn()
                   if (ping > 90) then
                      imgui.TextColoredRGB(string.format("{FF0000}%i", ping))
                   else
                      imgui.TextColoredRGB(string.format("%i", ping))
                   end
                   imgui.NextColumn()
                   imgui.Columns(1)
                   imgui.Separator()
                end
                
                imgui.Text(u8"Всего игроков в таблице: ".. playersTotal)
            
            elseif combobox.selecttable.v == 1 then
               resetIO()
               imgui.Columns(2, "vehtableheader", false)
               imgui.SetColumnWidth(-1, 320)
               
               local closestcarhandle, closestcarid = getClosestCar()
               if closestcarhandle then
                  local closestcarmodel = getCarModel(closestcarhandle)
                  imgui.Text(string.format(u8"Ближайший т/с: %s [model: %i] (id:%i)",
                  VehicleNames[closestcarmodel-399], closestcarmodel, closestcarid))
                  imgui.SameLine()
                  imgui.TextQuestion("( ? )", u8"В скобках указан внутренний ID (/dl)")
               end
                  
               if isCharInAnyCar(playerPed) then 
                  local carhandle = storeCarCharIsInNoSave(playerPed)
                  local carmodel = getCarModel(carhandle)
                  imgui.Text(string.format(u8"Вы в транспорте: %s(%i)",
                  VehicleNames[carmodel-399], carmodel))
               end
             
               imgui.NextColumn()
               imgui.Columns(1)
                  
               vehiclesTable = {}
               vehiclesTotal = 0
               
               for k, v in ipairs(getAllVehicles()) do
                  local streamed, id = sampGetVehicleIdByCarHandle(v)
                  if streamed then
                     table.insert(vehiclesTable, v)
                     vehiclesTotal = vehiclesTotal + 1
                  end
               end
               
               imgui.Separator()
               imgui.Columns(4)
               imgui.SetColumnWidth(-1, 50)
               imgui.TextQuestion("ID", u8"Внутренний ID (/dl)")
               imgui.NextColumn()
               imgui.Text("Vehicle")
               imgui.NextColumn()
               imgui.SetColumnWidth(-1, 190)
               imgui.Text("Driver")
               imgui.NextColumn()
               imgui.Text("Health")
               imgui.NextColumn()
               imgui.Columns(1)
               imgui.Separator()
             
               for k, v in ipairs(getAllVehicles()) do
                  local health = getCarHealth(v)
                  local carmodel = getCarModel(v)
                  local streamed, id = sampGetVehicleIdByCarHandle(v)
                  local ped = getDriverOfCar(v)
                  local res, pid = sampGetPlayerIdByCharHandle(ped)
                  local vehmodelname = string.format("%s", VehicleNames[carmodel-399])
                  
                  imgui.Columns(4)
                  imgui.TextColoredRGB(string.format("%i", id))
                  imgui.SetColumnWidth(-1, 50)
                  imgui.NextColumn()
                  imgui.Selectable(vehmodelname)
                  if imgui.IsItemClicked() then
                     chosenvehicle = v
                     vehinfomodelid = carmodel
                     if not dialog.vehstat.v then dialog.vehstat.v = true end
                  end
                         
                  imgui.NextColumn()
                  if res then 
                     imgui.Selectable(string.format(u8"%s", sampGetPlayerNickname(pid)))
                     if imgui.IsItemClicked() then
                        chosenplayer = pid
                        printStringNow("You have chosen a player ".. sampGetPlayerNickname(pid), 1000)
                        if not dialog.playerstat.v then dialog.playerstat.v = true end
                     end
                  else
                     imgui.Text(u8"пустой")
                  end
                  imgui.NextColumn()
                  if health > 10000 then
                     imgui.TextColoredRGB("{ff0000}GM")
                  elseif health > 1000 then
                     imgui.TextColoredRGB(string.format("{ff0000}%i", health))
                  elseif health < 450 then
                     imgui.TextColoredRGB(string.format("{ff8c00}%i", health))
                  else 
                     imgui.TextColoredRGB(string.format("%i", health))
                  end
                  imgui.Columns(1)
                  imgui.Separator()
               end
               
               imgui.Text(u8"Всего транспорта в таблице: ".. vehiclesTotal)
            end --combobox.selecttable.v
            
         end --tabmenu.manage
         
         imgui.Spacing()

      elseif tabmenu.header == 3 then
         resetIO()
         
         imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 2))
         if tabmenu.presets == 1 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Бинд-лист", imgui.ImVec2(80, 30)) then tabmenu.presets = 1 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Бинд-лист", imgui.ImVec2(80, 30)) then tabmenu.presets = 1 end
         end
         imgui.SameLine()
         if tabmenu.presets == 2 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Чат-игры", imgui.ImVec2(80, 30)) then tabmenu.presets = 2 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Чат-игры", imgui.ImVec2(80, 30)) then tabmenu.presets = 2 end
         end
         imgui.SameLine()
         if tabmenu.presets == 3 then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
            if imgui.Button(u8"Правила", imgui.ImVec2(80, 30)) then tabmenu.presets = 3 end
            imgui.PopStyleColor()
         else
            if imgui.Button(u8"Правила", imgui.ImVec2(80, 30)) then tabmenu.presets = 3 end
         end
         
         local prefix = ""
         imgui.SameLine()
         imgui.Text(u8" Чат:")
         imgui.SameLine()
         if isAbsolutePlay then             
            imgui.PushItemWidth(110)
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
            imgui.PushItemWidth(110)
            prefixlist = {u8'игрового мира', u8'глобальный', u8'модераторов', u8'ООС', u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = "@ "
            elseif combobox.chatselect.v == 1 then
               prefix = "! "
            elseif combobox.chatselect.v == 2 then
               prefix = "$ "
            elseif combobox.chatselect.v == 2 then
               prefix = "/b "
            elseif combobox.chatselect.v == 2 then
               prefix = ""
            end
         else
            imgui.PushItemWidth(110)
            prefixlist = {u8"без префикса"}
            imgui.Combo('##ComboChatSelect', combobox.chatselect, prefixlist, #prefixlist)
            imgui.PopItemWidth()
            
            if combobox.chatselect.v == 0 then
               prefix = ""
            end
         end
         
         if isTraining then
            imgui.SameLine()
            imgui.TextQuestion("( ? )", u8"\
            !text{FFFFFF} - глобальный чат (оранжевый)\
            @ | ;text{FFFFFF} - чат игрового мира (зеленый)\
            /v | $ | ;text{FFFFFF} - чат модераторов мира\
            /low | /l <text>{FFFFFF} - сказать шепотом\
            /whisper | /w <text>{FFFFFF} - сказать шепотом игроку\
            /try <text>{FFFFFF} - случайная вероятность действия\
            /todo <text>{FFFFFF} - совмещение действия /me и публичного чата\
            /shout | /s <text>{FFFFFF} - крикнуть\
            /me <text>{FFFFFF} - отыграть действие\
            /ame <text>{FFFFFF} - отыграть действие (текст над персонажем)\
            /do <text>{FFFFFF} - описать событие\
            /b <text>{FFFFFF} - OOC чат\
            /m <text>{FFFFFF} - сказать что то в мегафон\
            /channel <0-500>{FFFFFF} - установить радио канал\
            /setchannel <0-500>{FFFFFF} - установить радио канал по умолчанию в мире\
            /r <text>{FFFFFF} - отправить сообщение в рацию\
            /f <text>{FFFFFF} - отправить сообщение в чат команды /team\
            /pm <id> <text>{FFFFFF} - отправить игроку приватное сообщение\
            /reply | /rep <text>{FFFFFF} - ответить на последнее приватное сообщение\
            /c <text>{FFFFFF} - отправить сообщение в персональный чат")
         elseif isAbsolutePlay then
            imgui.SameLine()
            imgui.TextQuestion("( ? )", u8"\
            Информация о тулките\
            * - *текст - сказать игрокам поблизости, радиусный чат (50м)\
            ! - !текст - в клановый чат выведется сообщение текст\
            @[номер игрока] - @0 - заменяет текст на имя игрока, @я - на свой\
            /мчат <текст> - сказать игрокам в мире\
            /об <текст> - дать объявление\
            /me <текст> - сказать от 3-го лица\
            /try <текст> - удачно-неудачно\
            /w /ш <текст> - сказать шепотом\
            /к <текст> - крикнуть\
            /лс[ид игрока] <текст> - дать объявление")
         end
            
         imgui.PopStyleVar()
         imgui.Spacing()
         
         if tabmenu.presets == 1 then
            
            --imgui.TextColoredRGB("МП: {696969}"..profilesNames[combobox.profiles.v+1])
            -- line 1
            imgui.Text("1.")
            imgui.SameLine()
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
            imgui.PushItemWidth(350)
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
         elseif tabmenu.presets == 2 then
            
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
            imgui.PushItemWidth(280)
            imgui.SameLine()
            imgui.Text(" ")
            imgui.SameLine()
            if imgui.TooltipButton(u8"|>", imgui.ImVec2(30, 25), u8"Отправить в чат") then
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
            if imgui.TooltipButton(u8"|>", imgui.ImVec2(30, 25), u8"Отправить в чат") then
               sampSendChat(prefix..u8:decode(textbuffer.mpquestion.v))
            end
            imgui.SameLine()
            if imgui.TooltipButton(u8"<x]", imgui.ImVec2(30, 25), u8"Очистить поле ввода вопроса") then
               textbuffer.mpquestion.v = ""
               resetIO()
            end
            
            imgui.Spacing()
            imgui.Spacing()
            imgui.Checkbox(u8("Отслеживать ответ в чате и /pm"), checkbox.trackanswer)
            if checkbox.trackanswer.v then
            end
            
            imgui.Checkbox(u8("Проверить игрока через /try"), checkbox.trygame)
            if checkbox.trygame.v then
               imgui.PushItemWidth(200)
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
            imgui.PushItemWidth(180)
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
            
            if imgui.Button(u8"Есть победитель!", imgui.ImVec2(140, 25)) then
               sampSetChatInputEnabled(true)
               sampSetChatInputText('Есть правильный ответ! Первым прислал игрок')
            end
            imgui.SameLine()
            if imgui.Button(u8"Нет правильного", imgui.ImVec2(140, 25)) then
               sampSendChat(prefix.."Никто не дал правильный ответ!")
            end
            imgui.SameLine()
            if imgui.Button(u8"Переигровка", imgui.ImVec2(140, 25)) then
               sampSendChat(prefix.."Переигровка! Попробуем еще раз!")
            end
            
         elseif tabmenu.presets == 3 then    
            
            if tabmenu.rules == 1 then
               if combobox.mpnames.v == 0 then
                  imgui.TextColoredRGB("{696969}не выбран профиль")
                  if imgui.IsItemClicked() then
                     tabmenu.header = 1
                     tabmenu.mp = 1
                  end
                  textbuffer.rules.v = ""
                  imgui.SameLine()
               else
                  imgui.TextColoredRGB("Профиль: "..tostring(u8:decode(mpNames[combobox.mpnames.v + 1])))
                  imgui.SameLine()
                  textbuffer.rules.v = ""
               end
            end
            
            imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 0))
            
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Правила МП").x) / 2.3)
            if tabmenu.rules == 1 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Правила МП", imgui.ImVec2(100, 25)) then tabmenu.rules = 1 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Правила МП", imgui.ImVec2(100, 25)) then tabmenu.rules = 1 end
            end
            imgui.SameLine()
            if tabmenu.rules == 2 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Глобальные", imgui.ImVec2(100, 25)) then tabmenu.rules = 2 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Глобальные", imgui.ImVec2(100, 25)) then tabmenu.rules = 2 end
            end
            imgui.SameLine()
            if tabmenu.rules == 3 then
               imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
               if imgui.Button(u8"Все", imgui.ImVec2(50, 25)) then tabmenu.rules = 3 end
               imgui.PopStyleColor()
            else
               if imgui.Button(u8"Все", imgui.ImVec2(50, 25)) then tabmenu.rules = 3 end
            end

            imgui.PopStyleVar()
            
            imgui.PushFont(multilinetextfont)
            
            local filepath = getGameDirectory().."//moonloader//resource//mphelper//rules.txt"
            
            if tabmenu.rules == 1 then
               local finded = false
               local mpname = tostring(mpNames[combobox.mpnames.v + 1])

               for line in io.lines(filepath) do
                  if finded then
                     textbuffer.rules.v = tostring(textbuffer.rules.v).."\n"..tostring(line)
                     if line:len() <= 1 then
                        finded = false
                        break
                     end
                  end
                  if line:find(mpname) then
                     finded = true
                  end
               end
            
            elseif tabmenu.rules == 2 then
               local finded = false
               textbuffer.rules.v = ""
               for line in io.lines(filepath) do
                  if finded then
                     textbuffer.rules.v = tostring(textbuffer.rules.v).."\n"..tostring(line)
                     if line:len() <= 1 then
                        finded = false
                        break
                     end
                  end
                  if line:find(u8"Глобальные") then
                     finded = true
                  end
               end
               
            elseif tabmenu.rules == 3 then
               local file = io.open(filepath, "r")
               textbuffer.rules.v = file:read('*a')
               file:close() 
            end
            imgui.PopFont()
            
            if tabmenu.rules ~= 3 then
               imgui.InputTextMultiline('##rules', textbuffer.rules, imgui.ImVec2(400, 160),
               imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput + imgui.InputTextFlags.ReadOnly)
            else
               imgui.InputTextMultiline('##rules', textbuffer.rules, imgui.ImVec2(400, 260),
               imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.AllowTabInput + imgui.InputTextFlags.ReadOnly)
            end
            
            -- TODO: refactoring this code
            if tabmenu.rules ~= 3 and combobox.chatselect.v ~= 1 then -- ignore global chat and all rules tab
               if imgui.TooltipButton(u8"Анонсировать правила", imgui.ImVec2(150, 25), u8:encode("Анонсировать правила в чат")) then
                 
                  local filepath = getGameDirectory().."//moonloader//resource//mphelper//rules.txt"
                  if tabmenu.rules == 1 then
                     local finded = false
                     local mpname = tostring(mpNames[combobox.mpnames.v + 1])
                  
                     for line in io.lines(filepath) do
                        if finded then
                           if checkbox.testrules.v then
                              sampAddChatMessage(tostring(u8:decode(line)), -1)
                           end
                           if line:len() <= 1 then
                              finded = false
                              break
                           end
                        end
                        if line:find(mpname) then
                           finded = true
                        end
                     end
                  
                  elseif tabmenu.rules == 2 then
                     local finded = false
                     textbuffer.rules.v = ""
                     for line in io.lines(filepath) do
                        if finded then
                           if checkbox.testrules.v then
                              sampAddChatMessage(tostring(u8:decode(line)), -1)
                           end
                           if line:len() <= 1 then
                              finded = false
                              break
                           end
                        end
                        if line:find(u8"Глобальные") then
                           finded = true
                        end
                     end
                  end
               end
               imgui.SameLine()
               imgui.Checkbox(u8"##testrules", checkbox.testrules)
               imgui.SameLine()
               imgui.TextQuestion("( ? )", u8"Протестировать перед отправкой в чат (Выведет сообщения только для вас)")
            end
            
            if imgui.Button("  v  ", imgui.ImVec2(400, 15)) then
               dialog.searchbar.v = not dialog.searchbar.v
            end
         end -- tabmenu.presets
         
      elseif tabmenu.header == 4 then
         imgui.TextColoredRGB("{F0AD00}MP Helper v".. thisScript().version)
         imgui.Spacing()
         imgui.TextColoredRGB("Хелпер для организаторов мероприятий.")
         imgui.Text(u8"Содержит множество функций для проведения мероприятий")
         imgui.Text(u8"Скрипт предназанчен для TRAINING SANDBOX и Absolute Play.")
         imgui.Spacing()
         imgui.Text("TRAINING SANDBOX:")
		 imgui.SameLine()
         imgui.Link("https://training-server.com/","https://training-server.com/")
         
         imgui.Text("Absolute Play:")
		 imgui.SameLine()
         imgui.Link("https://sa-mp.ru/","https://sa-mp.ru/")

         imgui.Text(u8"Скрипт распостраняется только с открытым исходным кодом.")

         imgui.Spacing()
		 
         imgui.Text("Homepage:")
		 imgui.SameLine()
		 imgui.Link("https://github.com/ins1x/moonloader-scripts/mphelper","https://github.com/ins1x/moonloader-scripts/mphelper")
         
         imgui.Spacing()
         imgui.Spacing()
         -- if imgui.Button(u8"Проверить обновления",imgui.ImVec2(170, 25)) then
            -- os.execute('explorer https://github.com/ins1x/moonloader-scripts/mphelper')
		 -- end
         
         if imgui.Button(u8"Сбросить настройки",imgui.ImVec2(170, 25)) then
		    os.rename(getGameDirectory().."//moonloader//config//mphelper.ini", getGameDirectory().."//moonloader//config//backup_mphelper.ini")
            sampAddChatMessage("Настройки были сброшены на стандартные. Скрипт автоматически перезагрузится.",-1)
            sampAddChatMessage("Резервную копию ваших предыдущих настроек можно найти в moonloader/config.",-1)
            reloadScripts()
		 end
         imgui.SameLine()
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
      end -- tabmenu.header  
      
      imgui.Spacing()
      imgui.End()
   end
   
   -- Child dialogs
   if dialog.playerstat.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 1.25, sizeY / 4),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin(u8"Статистика игрока", dialog.playerstat)
      
      local nickname = sampGetPlayerNickname(chosenplayer)
      local ucolor = sampGetPlayerColor(chosenplayer)
      local health = sampGetPlayerHealth(chosenplayer)
      local armor = sampGetPlayerArmor(chosenplayer)
      local ping = sampGetPlayerPing(chosenplayer)
      local animid = sampGetPlayerAnimationId(chosenplayer)
      local weapon, ammo, skin
      local pX, pY, pZ, distance
      local zone = nil
      
      for k, handle in ipairs(getAllChars()) do
         local res, id = sampGetPlayerIdByCharHandle(handle)
         if res then
            if id == chosenplayer then
               pX, pY, pZ = getCharCoordinates(handle)
               skinid = getCharModel(handle)
               weapon = getCurrentCharWeapon(handle)
               ammo = getAmmoInCharWeapon(handle, weapon)
               zone = getZoneName(pX, pY, pZ)
            end
         end
      end
      
      if sampIsPlayerPaused(chosenplayer) then
         imgui.TextColoredRGB("{FF0000}[AFK]")
         imgui.SameLine()
      end
      
      imgui.TextColoredRGB(string.format("Ник: {%0.6x}%s",
      bit.band(ucolor,0xffffff), nickname))
      if imgui.IsItemClicked() then
         setClipboardText(nickname)
         sampAddChatMessage("Ник скопирован в буфер обмена", -1)
      end
      imgui.SameLine()
      imgui.Text(string.format("id: [%d]",chosenplayer))
      if imgui.IsItemClicked() then
         setClipboardText(chosenplayer)
         sampAddChatMessage("ID скопирован в буфер обмена", -1)
      end
      
      imgui.TextColoredRGB(string.format("Хп: %.1f  броня: %.1f", 
      health, armor))
      
      imgui.Text(u8"Score: ".. sampGetPlayerScore(chosenplayer))
      
      if (ping > 90) then
         imgui.TextColoredRGB(string.format("Пинг: {FF0000}%i", ping))
      else
         imgui.TextColoredRGB(string.format("Пинг: %i", ping))
      end
      
      imgui.Text(u8("Скин: ".. skinid))
      imgui.Text(u8("Анимация: ".. animid))
      
      if weapon == 0 then 
         imgui.Text(u8"Нет оружия на руках")
      else
         if ammo then 
            imgui.TextColoredRGB(string.format("Оружие: %s (id: %d)", 
            weaponNames[weapon], weapon))
            if weapon > 15 and weapon < 44 then
               imgui.TextColoredRGB(string.format("Патроны: %d", ammo)) 
            end
         end
      end
      
      local posX, posY, posZ = getCharCoordinates(playerPed)
      distance = getDistanceBetweenCoords3d(posX, posY, posZ, pX, pY, pZ)
      imgui.TextColoredRGB(string.format("Дистанция: %.1f m.", distance))
      
      if zone then 
         imgui.TextColoredRGB(string.format("Район: {696969}%s", zone))
      end
      
      if imgui.TooltipButton(u8"Статистика", imgui.ImVec2(220, 25), u8"Открыть серверную статистику игрока") then
         if isTraining then
            sampSendChat("/stats " .. chosenplayer)
         elseif isAbsolutePlay then
            sampSendChat("/стат " .. chosenplayer)
         else
            sampSendChat("/stat " .. chosenplayer)
         end
         dialog.main.v = false
      end
      

      if imgui.TooltipButton(u8"Наблюдать", imgui.ImVec2(220, 25), u8"Наблюдать за игроком") then      
         if isTraining then
            sampSendChat("/sp " .. chosenplayer)
         else
            sampSendChat("/spec " .. chosenplayer)
         end
      end
          
      if imgui.TooltipButton(u8"Меню игрока", imgui.ImVec2(220, 25), u8"Открыть серверное меню взаимодействия с игроком") then
         if isTraining then
            sampSendChat("/data " .. chosenplayer)
         elseif isAbsolutePlay then
            sampSendChat("/и " .. chosenplayer)
         end
         dialog.main.v = false
      end
      
      if imgui.TooltipButton(u8"ТП к Игроку", imgui.ImVec2(220, 25), u8"Телепортироваться к игроку") then
         for k, v in ipairs(getAllChars()) do
            local res, id = sampGetPlayerIdByCharHandle(v)
            if res then
               if id == chosenplayer then
                  local pposX, pposY, pposZ = getCharCoordinates(v)
                  if isTraining then
                     sampSendChat(string.format("/xyz %f %f %f",
                     pposX+0.5, pposY+0.5, pposZ), -1)
                  else
                     setCharCoordinates(playerPed, posX+0.5, posY+0.5, posZ)
                  end
                end
            else
               sampAddChatMessage("Доступно только в редакторе карт", -1)
            end
          end
       end
       
       if imgui.TooltipButton(u8(chosenplayerMarker and 'Снять' or 'Установить')..u8" метку", imgui.ImVec2(220, 25), u8"Установить/Снять метку с игрока") then
          if chosenplayerMarker ~= nil then
             removeBlip(chosenplayerMarker)
             chosenplayerMarker = nil
             sampAddChatMessage("Метка удалена с игрока",-1)
          else
             for k, v in ipairs(getAllChars()) do
                local res, id = sampGetPlayerIdByCharHandle(v)
                if res then
                   if id == chosenplayer then
                      chosenplayerMarker = addBlipForChar(v)
                      sampAddChatMessage("Метка установлена на игрока",-1)
                   end
                end
             end
          end
       end
       
       imgui.End()
   end
   
   if dialog.vehstat.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 1.25, sizeY / 4),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin(u8"Меню транспорта", dialog.vehstat)
      
      if chosenvehicle and doesVehicleExist(chosenvehicle) then
         local health = getCarHealth(chosenvehicle)
         local carmodel = getCarModel(chosenvehicle)
         local streamed, id = sampGetVehicleIdByCarHandle(chosenvehicle)
         local ped = getDriverOfCar(chosenvehicle)
         local res, pid = sampGetPlayerIdByCharHandle(ped)
         local passengers, valPassengers = getNumberOfPassengers(chosenvehicle)
         local maxPassengers = getMaximumNumberOfPassengers(chosenvehicle)
         local engineon = isCarEngineOn(chosenvehicle)
         local primaryColor, secondaryColor = getCarColours(chosenvehicle)
         local paintjob = getCurrentVehiclePaintjob(chosenvehicle)
         local availablePaintjobs = getNumAvailablePaintjobs(chosenvehicle)
         local siren = isCarSirenOn(chosenvehicle)
         --local onscreen = isCarOnScreen(chosenvehicle)
         
         if carmodel == 447 or carmodel == 425 or carmodel == 432 or carmodel == 520 then
            vehmodelname = string.format("{FF0000}%s (id:%d)", VehicleNames[carmodel-399], carmodel)
         elseif carmodel == 476 or carmodel == 430 or carmodel == 406 or carmodel == 592 then
            vehmodelname = string.format("{FF8C00}%s (id:%d)", VehicleNames[carmodel-399], carmodel)
         elseif carmodel == 601 or carmodel == 407 then
            vehmodelname = string.format("{1E90FF}%s (id:%d)", VehicleNames[carmodel-399], carmodel)
         else
            vehmodelname = string.format("%s (id:%d)", VehicleNames[carmodel-399], carmodel)
         end
       
         imgui.TextColoredRGB(vehmodelname)
         if imgui.IsItemClicked() then 
            textbuffer.vehiclename.v = tostring(VehicleNames[carmodel-399])
            vehinfomodelid = carmodel
         end
         
         imgui.TextColoredRGB(string.format("Хп: %i", health))
         
         imgui.Text(u8"Водитель:")
         imgui.SameLine()
         if res then 
            imgui.Selectable(string.format(u8"%s", sampGetPlayerNickname(pid)))
            if imgui.IsItemClicked() then
               chosenplayer = pid
               printStringNow("You have chosen a player ".. sampGetPlayerNickname(pid), 1000)
               if not dialog.playerstat.v then dialog.playerstat.v = true end
            end
         else
            imgui.Text(u8"Нет")
         end
         
         imgui.Text(string.format(u8"Скорость: %.0f", getCarSpeed(chosenvehicle)))
         
         if passengers then
            imgui.Text(string.format(u8"Пассажиров в транспорте: %i (max %i)", valPassengers, maxPassengers))
         else
            imgui.Text(string.format(u8"Пассажиров в транспорте: нет (max %i)", maxPassengers))
         end
         
         imgui.Text(engineon and u8('Двигатель: Работает') or u8('Двигатель: Заглушен'))
         imgui.Text(siren and u8('Сигнализация: Работает') or u8('Сигнализация: Отключена'))
         
         imgui.Text(string.format(u8"Цвет 1: %i  Цвет 2: %i", primaryColor, secondaryColor))
         
         imgui.Text(string.format(u8"Покраска: %i/%i", paintjob, availablePaintjobs))
          
         if imgui.Button(u8"Открыть меню управления", imgui.ImVec2(250, 25)) then
            if id then
               sampSendChat("/vmenu "..id)
            else
               sampAddChatMessage("Вы не указали ID транспорта", -1)
            end
            --toggleMainWindow()
         end
         if imgui.Button(u8"Информация о модели (онлайн)", imgui.ImVec2(250, 25)) then
            if vehinfomodelid then
               if vehinfomodelid > 400 and vehinfomodelid < 611 then 
                  os.execute(string.format('explorer "https://gtaundergroundmod.com/pages/ug-mp/documentation/vehicle/%d/details"', vehinfomodelid))
               else
                  sampAddChatMessage("Некорректный ид транспорта", -1)
               end
            end
         end

         if imgui.Button(u8"Предпросмотр 3D модели (онлайн)", imgui.ImVec2(250, 25)) then
            if vehinfomodelid then
               if vehinfomodelid > 400 and vehinfomodelid < 611 then 
                  os.execute(string.format('explorer "http://gta.rockstarvision.com/vehicleviewer/#sa/%d"', vehinfomodelid))
               else
                  sampAddChatMessage("Некорректный ид транспорта", -1)
               end
            end
         end
         
         if imgui.Button(u8"Таблица цветов транспорта (онлайн)", imgui.ImVec2(250, 25)) then
            os.execute(string.format('explorer "https://www.open.mp/docs/scripting/resources/vehiclecolorid"'))
         end
      else
         dialog.vehstat.v = false
         sampAddChatMessage("Транспорт несуществует либо был отправлен на спавн", -1)
      end
      
      imgui.End()
   end
   
   if dialog.setteams.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 6, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.SetNextWindowSize(imgui.ImVec2(300, 350))
      imgui.Begin(u8"Выбор команды", dialog.setteams)
      
      local pid -- selected player id
      local playerId = getLocalPlayerId()
      if string.len(textbuffer.pid.v) < 1 then
         textbuffer.pid.v = tostring(playerId)
      end
      
      if string.len(textbuffer.pid.v) >= 1 
      and sampIsPlayerConnected(tonumber(textbuffer.pid.v))then
         pid = tonumber(textbuffer.pid.v)
      else
         pid = tostring(playerId)
      end
 
      imgui.Text(u8"Введите ID:")
      imgui.SameLine()
      imgui.PushItemWidth(50)
      if imgui.InputText("##PlayerIDBuffer", textbuffer.pid, imgui.InputTextFlags.CharsDecimal) then
      end
      imgui.PopItemWidth()
      
      if pid then
         imgui.SameLine()
         imgui.Text(u8""..sampGetPlayerNickname(pid))
      end
      
      if getClosestPlayerId() ~= -1 then
         imgui.SameLine()
         imgui.Text(u8"  ")
         imgui.SameLine()
         imgui.TextColoredRGB("{424242}[s]")
         if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(350)
            imgui.TextUnformatted(tostring(u8"Ближайший игрок: "..sampGetPlayerNickname(getClosestPlayerId())).."["..getClosestPlayerId().."]")
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
         end
         if imgui.IsItemClicked() then
            setClipboardText(getClosestPlayerId())
            textbuffer.pid.v = tostring(getClosestPlayerId())
         end
      end
      
      imgui.Columns(2)
      if imgui.Button(u8"Добавить по ID##TeamAButton", imgui.ImVec2(95, 25)) then
         if pid then
            if isPlayerInAnyTeam(pid) then
               sampAddChatMessage("Этот игрок уже в другой команде", -1)
            else
               table.insert(teamA, tostring(sampGetPlayerNickname(pid)))
            end
         end
      end
      imgui.NextColumn() 
      if imgui.Button(u8"Добавить по ID##TeamBButton", imgui.ImVec2(95, 25)) then
         if pid then
            if isPlayerInAnyTeam(pid) then
               sampAddChatMessage("Этот игрок уже в другой команде", -1)
            else
               table.insert(teamB, tostring(sampGetPlayerNickname(pid)))
            end
         end
      end
      imgui.Columns(1)
      
      imgui.Separator()
      imgui.Columns(2)
      imgui.Text(u8"TEAM A")
      imgui.NextColumn() 
      imgui.Text(u8"TEAM B")
      imgui.Columns(1)
      
      imgui.Columns(2)
      imgui.PushItemWidth(120)
      if imgui.ListBox('##ListBoxTeamA', combobox.teamA, teamA, 10) then
      end
      imgui.PopItemWidth()
      imgui.NextColumn()
      imgui.PushItemWidth(120)
      if imgui.ListBox('##ListBoxTeamB', combobox.teamB, teamB, 10) then
      end
      imgui.PopItemWidth()
      imgui.Columns(1)
      imgui.Separator()

      
      imgui.End()
   end
   
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
      
      imgui.PushItemWidth(400)
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
      imgui.PushItemWidth(400)
      
      if imgui.Combo(u8'##ComboBoxFastAnswers', combobox.fastanswers, fastAnswers, #fastAnswers) then
        textbuffer.sms.v = fastAnswers[combobox.fastanswers.v+1]
      end            
      imgui.PopItemWidth()
      imgui.End()
   end
   
   if dialog.searchbar.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY-150),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.SetNextWindowSize(imgui.ImVec2(435, 70))
      imgui.Begin(u8"search", dialog.searchbar)
      
      local symbols = 0
      local lines = 1
      local filepath = getGameDirectory().."//moonloader//resource//mphelper//rules.txt"
      
      symbols = string.len(textbuffer.rules.v)/2
      for s in string.gmatch(textbuffer.rules.v, "\n" ) do
         lines = lines + 1
      end
         
      -- if imgui.TooltipButton(u8"Обновить", imgui.ImVec2(80, 25), u8:encode("Загрузить правила с файла rules.txt")) then
         -- local file = io.open(filepath, "r")
         -- textbuffer.rules.v = file:read('*a')
         -- file:close()
      -- end
      -- imgui.SameLine()
      -- if imgui.TooltipButton(u8"Сохранить", imgui.ImVec2(80, 25), u8:encode("Сохранить правила с файла rules.txt")) then
         -- if not readonly then
            -- local file = io.open(filepath, "w")
            -- file:write(textbuffer.rules.v)
            -- file:close()
            -- sampAddChatMessage("Сохранено в файл: /moonloader/resource/mphelper/rules.txt", -1)
         -- else
            -- sampAddChatMessage("Недоступно в режмие для чтения. Снимите режим RO (Readonly)", -1)
         -- end
      -- end
      
      imgui.Text("lines: "..lines.." symbols: "..symbols)
      -- imgui.SameLine()
      -- imgui.Text("              ")
      -- imgui.SameLine()
      -- if imgui.Selectable("Unlock IO", false, 0, imgui.ImVec2(50, 15)) then
         -- resetIO()
      -- end
      -- imgui.SameLine()
      -- imgui.TextQuestion("( ? )", u8"RO - Включить режим ReadOnly, Unlock IO - разблокировать инпут если курсор забагался")
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
   
   if command:find("/exit") or command:find("/выход") then
      isWorldHoster = false
      LastData.lastWorldName = ""
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
   
   if isTraining then
      if text:find('Вы присоеденились к миру') then
         LastData.lastWorldName = string.match(text, "Вы присоеденились к миру: (.+)")
      end
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

function sampev.onSendTakeDamage(playerID, damage, weaponID, bodypart)
   if checkbox.damageinformer.v then
      if playerID ~= 65535 then
         sampAddChatMessage("Вам нанес урон "..sampGetPlayerNickname(playerID).."("..playerID..")", -1)
         sampAddChatMessage(string.format("Оружие: %d кол-во: %.1f", weaponID, damage), -1)
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
      wait(1000*ini.warnings.warndelay)
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
               if isCharInWater(handle) then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] в воде",
                  nickname, id), 0xFF880000)
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
               if ping > 120 then
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
            
             if ini.warnings.afk then
               if afk then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] в AFK",
                  nickname, id), 0xFF880000)
               end
            end
            
            if ini.warnings.novehicle then
               if not isCharSittingInAnyCar(handle) then
                  sampAddChatMessage(string.format("[WARNING]: {FFFFFF}Игрок %s[%d] без транспорта",
                  nickname, id), 0xFF880000)
               end
            end
         end
      end
      -- for res, handle in ipairs(getAllVehicles()) do
         -- local streamed, carId = sampGetVehicleIdByCarHandle(k)
         -- if streamed then
            -- local ped = getDriverOfCar(Vehicle car)
            ---local inwater = isCarInWater(Vehicle car)
         -- end
      -- end
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

function isPlayerInAnyTeam(playerid)
   -- Check loacl teamA and 
   -- is not same GetPlayerTeam !!
   for key, value in ipairs(teamA) do
      if value == sampGetPlayerNickname(playerid) then
         return true
      end
   end
   for key, value in ipairs(teamB) do
      if value == sampGetPlayerNickname(playerid) then
         return true
      end
   end
   return false
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

function getZoneName(x, y, z)
   local streets = {
      {"Загородный клуб «Ависпа»", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
      {"Международный аэропорт Истер-Бэй", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
      {"Загородный клуб «Ависпа»", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
      {"Международный аэропорт Истер-Бэй", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
      {"Гарсия", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
      {"Шейди-Кэбин", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
      {"Восточный Лос-Сантос", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
      {"Грузовое депо Лас-Вентураса", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
      {"Пересечение Блэкфилд", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
      {"Загородный клуб «Ависпа»", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
      {"Темпл", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
      {"Станция «Юнити»", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
      {"Грузовое депо Лас-Вентураса", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
      {"Лос-Флорес", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
      {"Казино «Морская звезда»", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
      {"Химзавод Истер-Бэй", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
      {"Деловой район", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
      {"Восточная Эспаланда", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
      {"Станция «Маркет»", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
      {"Станция «Линден»", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
      {"Пересечение Монтгомери", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
      {"Мост «Фредерик»", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
      {"Станция «Йеллоу-Белл»", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
      {"Деловой район", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
      {"Джефферсон", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
      {"Малхолланд", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
      {"Загородный клуб «Ависпа»", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
      {"Джефферсон", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
      {"Западаная автострада Джулиус", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
      {"Джефферсон", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
      {"Северная автострада Джулиус", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
      {"Родео", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
      {"Станция «Крэнберри»", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
      {"Деловой район", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
      {"Западный Рэдсэндс", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
      {"Маленькая Мексика", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
      {"Пересечение Блэкфилд", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
      {"Международный аэропорт Лос-Сантос", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
      {"Бекон-Хилл", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
      {"Родео", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
      {"Ричман", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
      {"Деловой район", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
      {"Лас-Вентурас Стрип", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
      {"Деловой район", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
      {"Пересечение Блэкфилд", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
      {"Конференц Центр", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
      {"Монтгомери", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
      {"Долина Фостер", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
      {"Часовня Блэкфилд", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
      {"Международный аэропорт Лос-Сантос", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
      {"Малхолланд", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
      {"Поле для гольфа «Йеллоу-Белл»", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
      {"Лас-Вентурас Стрип", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
      {"Джефферсон", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
      {"Малхолланд", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
      {"Альдеа-Мальвада", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
      {"Лас-Колинас", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
      {"Лас-Колинас", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
      {"Ричман", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
      {"Грузовое депо Лас-Вентураса", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
      {"Северная автострада Джулиус", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
      {"Уиллоуфилд", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
      {"Северная автострада Джулиус", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
      {"Темпл", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
      {"Маленькая Мексика", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
      {"Квинс", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
      {"Аэропорт Лас-Вентурас", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
      {"Ричман", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
      {"Темпл", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
      {"Восточный Лос-Сантос", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
      {"Восточная автострада Джулиус", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
      {"Уиллоуфилд", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
      {"Лас-Колинас", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
      {"Восточная автострада Джулиус", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
      {"Родео", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
      {"Лас-Брухас", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
      {"Восточная автострада Джулиус", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
      {"Родео", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
      {"Вайнвуд", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
      {"Родео", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
      {"Северная автострада Джулиус", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
      {"Деловой район", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
      {"Родео", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
      {"Джефферсон", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
      {"Хэмптон-Барнс", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
      {"Темпл", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
      {"Мост «Кинкейд»", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
      {"Пляж «Верона»", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
      {"Коммерческий район", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
      {"Малхолланд", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
      {"Родео", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
      {"Малхолланд", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
      {"Малхолланд", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
      {"Южная автострада Джулиус", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
      {"Айдлвуд", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
      {"Океанские доки", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
      {"Коммерческий район", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
      {"Северная автострада Джулиус", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
      {"Темпл", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
      {"Глен Парк", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
      {"Международный аэропорт Истер-Бэй", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
      {"Мост «Мартин»", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
      {"Лас-Вентурас Стрип", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
      {"Уиллоуфилд", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
      {"Марина", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
      {"Аэропорт Лас-Вентурас", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
      {"Айдлвуд", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
      {"Восточная Эспаланда", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
      {"Деловой район", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
      {"Мост «Мако»", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
      {"Родео", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
      {"Площадь «Першинг»", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
      {"Малхолланд", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
      {"Мост «Гант»", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
      {"Лас-Колинас", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
      {"Малхолланд", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
      {"Северная автострада Джулиус", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
      {"Коммерческий район", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
      {"Родео", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
      {"Рока-Эскаланте", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
      {"Родео", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
      {"Маркет", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
      {"Лас-Колинас", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
      {"Малхолланд", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
      {"Кингс", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
      {"Восточный Рэдсэндс", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
      {"Деловой район", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
      {"Конференц Центр", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
      {"Ричман", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
      {"Оушен-Флэтс", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
      {"Колледж Грингласс", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
      {"Глен Парк", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
      {"Грузовое депо Лас-Вентураса", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
      {"Регьюлар-Том", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
      {"Пляж «Верона»", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
      {"Восточный Лос-Сантос", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
      {"Дворец Калигулы", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
      {"Айдлвуд", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
      {"Пилигрим", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
      {"Айдлвуд", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
      {"Квинс", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
      {"Деловой район", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
      {"Коммерческий район", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
      {"Восточный Лос-Сантос", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
      {"Марина", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
      {"Ричман", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
      {"Вайнвуд", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
      {"Восточный Лос-Сантос", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
      {"Родео", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
      {"Истерский Тоннель", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
      {"Родео", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
      {"Восточный Рэдсэндс", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
      {"Казино «Карман клоуна»", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
      {"Айдлвуд", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
      {"Пересечение Монтгомери", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
      {"Уиллоуфилд", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
      {"Темпл", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
      {"Прикл-Пайн", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
      {"Международный аэропорт Лос-Сантос", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
      {"Мост «Гарвер»", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
      {"Мост «Гарвер»", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
      {"Мост «Кинкейд»", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
      {"Мост «Кинкейд»", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
      {"Пляж «Верона»", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
      {"Обсерватория «Зелёный утёс»", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
      {"Вайнвуд", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
      {"Вайнвуд", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
      {"Коммерческий район", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
      {"Маркет", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
      {"Западный Рокшор", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
      {"Северная автострада Джулиус", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
      {"Восточный пляж", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
      {"Мост «Фаллоу»", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
      {"Уиллоуфилд", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
      {"Чайнатаун", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
      {"Эль-Кастильо-дель-Дьябло", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
      {"Океанские доки", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
      {"Химзавод Истер-Бэй", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
      {"Казино «Визаж»", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
      {"Оушен-Флэтс", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
      {"Ричман", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
      {"Нефтяной комплекс «Зеленый оазис»", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
      {"Ричман", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
      {"Казино «Морская звезда»", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
      {"Восточный пляж", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
      {"Джефферсон", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
      {"Деловой район", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
      {"Деловой район", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
      {"Мост «Гарвер»", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
      {"Южная автострада Джулиус", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
      {"Восточный Лос-Сантос", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
      {"Колледж «Грингласс»", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
      {"Лас-Колинас", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
      {"Малхолланд", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
      {"Океанские доки", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
      {"Восточный Лос-Сантос", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
      {"Гантон", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
      {"Загородный клуб «Ависпа»", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
      {"Уиллоуфилд", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
      {"Северная Эспланада", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
      {"Казино «Хай-Роллер»", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
      {"Океанские доки", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
      {"Мотель «Последний цент»", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
      {"Бэйсайнд-Марина", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
      {"Кингс", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
      {"Эль-Корона", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
      {"Часовня Блэкфилд", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
      {"«Розовый лебедь»", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
      {"Западаная автострада Джулиус", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
      {"Лос-Флорес", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
      {"Казино «Визаж»", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
      {"Прикл-Пайн", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
      {"Пляж «Верона»", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
      {"Пересечение Робада", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
      {"Линден-Сайд", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
      {"Океанские доки", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
      {"Уиллоуфилд", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
      {"Кингс", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
      {"Коммерческий район", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
      {"Малхолланд", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
      {"Марина", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
      {"Бэттери-Пойнт", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
      {"Казино «4 Дракона»", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
      {"Блэкфилд", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
      {"Северная автострада Джулиус", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
      {"Поле для гольфа «Йеллоу-Белл»", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
      {"Айдлвуд", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
      {"Западный Рэдсэндс", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
      {"Доэрти", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
      {"Ферма Хиллтоп", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
      {"Лас-Барранкас", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
      {"Казино «Пираты в мужских штанах»", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
      {"Сити Холл", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
      {"Загородный клуб «Ависпа»", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
      {"Казино «4 Дракона»", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
      {"Хашбери", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
      {"Международный аэропорт Лос-Сантос", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
      {"Уайтвуд-Истейтс", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
      {"Водохранилище Шермана", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
      {"Эль-Корона", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
      {"Деловой район", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
      {"Долина Фостер", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
      {"Лас-Паясадас", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
      {"Долина Окультадо", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
      {"Пересечение Блэкфилд", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
      {"Гантон", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
      {"Международный аэропорт Истер-Бэй", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
      {"Восточный Рэдсэндс", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
      {"Восточная Эспаланда", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
      {"Дворец Калигулы", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
      {"Казино «Рояль»", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
      {"Ричман", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
      {"Казино «Морская звезда»", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
      {"Малхолланд", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
      {"Деловой район", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
      {"Ханки-Панки-Пойнт", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
      {"Военный склад топлива К.А.С.С.", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
      {"Автострада «Гарри-Голд»", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
      {"Тоннель Бэйсайд", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
      {"Океанские доки", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
      {"Ричман", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
      {"Промсклад имени Рэндольфа", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
      {"Восточный пляж", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
      {"Флинт-Уотер", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
      {"Блуберри", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
      {"Станция «Линден»", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
      {"Глен Парк", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
      {"Деловой район", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
      {"Западный Рэдсэндс", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
      {"Ричман", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
      {"Мост «Гант»", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
      {"Бар «Probe Inn»", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
      {"Пересечение Флинт", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
      {"Лас-Колинас", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
      {"Собелл-Рейл-Ярдс", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
      {"Изумрудный остров", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
      {"Эль-Кастильо-дель-Дьябло", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
      {"Санта-Флора", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
      {"Плайя-дель-Севиль", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
      {"Маркет", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
      {"Квинс", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
      {"Пересечение Пилсон", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
      {"Спинибед", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
      {"Пилигрим", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
      {"Блэкфилд", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
      {"«Большое ухо»", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
      {"Диллимор", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
      {"Эль-Кебрадос", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
      {"Северная Эспланада", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
      {"Международный аэропорт Истер-Бэй", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
      {"Рыбацкая лагуна", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
      {"Малхолланд", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
      {"Восточный пляж", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
      {"Сан-Андреас Саунд", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
      {"Тенистые ручьи", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
      {"Маркет", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
      {"Западный Рокшор", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
      {"Прикл-Пайн", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
      {"«Бухта Пасхи»", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
      {"Лифи-Холлоу", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
      {"Грузовое депо Лас-Вентураса", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
      {"Прикл-Пайн", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
      {"Блуберри", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
      {"Эль-Кастильо-дель-Дьябло", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
      {"Деловой район", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
      {"Восточный Рокшор", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
      {"Залив Сан-Фиерро", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
      {"Парадизо", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
      {"Казино «Носок верблюда»", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
      {"Олд-Вентурас-Стрип", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
      {"Джанипер-Хилл", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
      {"Джанипер-Холлоу", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
      {"Рока-Эскаланте", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
      {"Восточная автострада Джулиус", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
      {"Пляж «Верона»", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
      {"Долина Фостер", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
      {"Арко-дель-Оэсте", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
      {"«Упавшее дерево»", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
      {"Ферма", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
      {"Дамба Шермана", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
      {"Северная Эспланада", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
      {"Финансовый район", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
      {"Гарсия", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
      {"Монтгомери", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
      {"Крик", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
      {"Международный аэропорт Лос-Сантос", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
      {"Пляж «Санта-Мария»", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
      {"Пересечение Малхолланд", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
      {"Эйнджел-Пайн", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
      {"Вёрдант-Медоус", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
      {"Октан-Спрингс", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
      {"Казино Кам-э-Лот", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
      {"Западный Рэдсэндс", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
      {"Пляж «Санта-Мария»", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
      {"Обсерватория «Зелёный утёс»", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
      {"Аэропорт Лас-Вентурас", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
      {"Округ Флинт", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
      {"Обсерватория «Зелёный утёс»", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
      {"Паломино Крик", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
      {"Океанские доки", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
      {"Международный аэропорт Истер-Бэй", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
      {"Уайтвуд-Истейтс", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
      {"Калтон-Хайтс", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
      {"«Бухта Пасхи»", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
      {"Залив Лос-Сантос", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
      {"Доэрти", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
      {"Гора Чилиад", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
      {"Форт-Карсон", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
      {"Долина Фостер", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
      {"Оушен-Флэтс", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
      {"Ферн-Ридж", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
      {"Бэйсайд", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
      {"Аэропорт Лас-Вентурас", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
      {"Поместье Блуберри", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
      {"Пэлисейдс", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
      {"Норт-Рок", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
      {"Карьер «Хантер»", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
      {"Международный аэропорт Лос-Сантос", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
      {"Миссионер-Хилл", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
      {"Залив Сан-Фиерро", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
      {"Запретная Зона", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
      {"Гора «Чилиад»", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
      {"Гора «Чилиад»", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
      {"Международный аэропорт Истер-Бэй", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
      {"Паноптикум", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
      {"Тенистые ручьи", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
      {"Бэк-о-Бейонд", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
      {"Гора «Чилиад»", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
      {"Тьерра Робада", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
      {"Округ Флинт", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
      {"Уэтстоун", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
      {"Пустынный округ", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
      {"Тьерра Робада", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
      {"Сан Фиерро", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
      {"Лас Вентурас", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
      {"Туманный округ", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
      {"Лос Сантос", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}
   }
   for i, v in ipairs(streets) do
       if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
           return v[1]
       end
   end
   -- If unknown location
   if getActiveInterior() ~= 0 then 
      return "Interior "..getActiveInterior()
   else
      return "Uncharted lands"
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
   style.ItemSpacing = imgui.ImVec2(5, 5)
   style.ItemInnerSpacing = imgui.ImVec2(6, 4)
   style.IndentSpacing = 25.0
   style.ScrollbarSize = 10.0
   style.ScrollbarRounding = 9.0
   style.GrabMinSize = 5.0
   style.GrabRounding = 3.0
   -- TRAINING Colors theme
   colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
   colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
   colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
   colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
   colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
   colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.FrameBgHovered] = ImVec4(0.56, 0.56, 0.58, 1.0)
   colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
   colors[clr.TitleBgActive] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
   colors[clr.CheckMark] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
   colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
   colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.ButtonHovered] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
   colors[clr.HeaderHovered] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)   
   colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.CloseButton] = ImVec4(0.06, 0.05, 0.07, 0.25)
   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
   colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotLinesHovered] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
   colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
   colors[clr.TextSelectedBg] = ImVec4(0.56, 0.42, 0.01, 1.00)
   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

applyCustomStyle()