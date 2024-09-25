script_author("1NS")
script_name("ModCompatibilityChecker")
script_description("Checks the mods that can cause crashes")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("1.5")
-- Activation: script run once and unloading
-- encoding.default = 'CP1251'

-- GTA SA/VC/III .asi plugin for crash/error information
-- https://github.com/JuniorDjjr/CrashInfo/tree/main

-- Do not change booleans here
local ENBSeries = false
local FastloadAsi = false
local SAMPFUNCS = false
local Modloader = false
local ModTimecyc = false
local SampAddonInstalled = false
local AZLauncher = false

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   
   local major, minor, majorRev, minorRev, game, region, steam, cracked = getGameVersion()
   local moonloaderVersion = getMoonloaderVersion()
   local cleoVersion = getCleoLibraryVersion()
   
   if not isGameVersionOriginal() then
      sampAddChatMessage(string.format("У вас установлена не оригинальная версия игры (%i.%i.%i.%i)",
      major, minor, majorRev, minorRev), 0xFF00000)
      print("ModChecker warning: You have a non-original version of the game installed (%i.%i.%i.%i)", major, minor, majorRev, minorRev)
   end
   
   if steam then
      sampAddChatMessage("Большинство модов не работает на steam версии gta_sa.exe, игра будет попросту вылетать.", 0xFF00000)
      print("ModChecker warning: Most mods do not work on the steam version of gta_sa.exe, the game will crash.")
   end
   
   if moonloaderVersion ~= 26 then
      sampAddChatMessage("Установлена неактуальная версия moonloader v"..moonloaderVersion, 0xFF00000)
      print("ModChecker warning: Outdated version of moonloader installed v"..moonloaderVersion)
   end
   
   -- init loaders and mods check
   if doesFileExist(getGameDirectory() .. "\\enbseries.asi") or 
   doesFileExist(getGameDirectory() .. "\\d3d9.dll") then
      ENBSeries = true
   end
   
   if doesFileExist(getGameDirectory() .. "\\FastLoad.asi") then
      FastloadAsi = true
   end
   
   if doesFileExist(getGameDirectory() .. "\\SAMPFUNCS.asi") then
      SAMPFUNCS = true
   end
   
   if doesFileExist(getGameDirectory() .. "\\audio.asi") then
      SampAddonInstalled = true
   end
   
   if doesFileExist(getGameDirectory() .. "\\modloader\\modloader.ini") then
      Modloader = true
   end
   
   if doesFileExist(getGameDirectory() .. "\\core.asi") or 
   doesFileExist(getGameDirectory() .. "\\_CoreGame.asi") then
      AZLauncher = true
   end
   
   if getFileSize(getGameDirectory() .. "\\data\\timecyc.dat") ~= 40037 or 
   doesFileExist(getGameDirectory() .. "\\timecycle24.asi") or
   doesFileExist(getGameDirectory() .. "\\data\\timecyc_24h.dat") then
      ModTimecyc = true
   end
   
   -- broken files checker work if samp addon not installed
   -- check old version shadows asi
   if doesFileExist(getGameDirectory() .. "\\shadows.asi") and
   getFileSize(getGameDirectory() .. "\\shadows.asi") == 52224 then
      sampAddChatMessage("У вас устаревшая версия shadows.asi которая может вызывать краши", 0xFF00000)
   end
   
   -- newopcodes
   if doesFileExist(getGameDirectory() .. "\\cleo\\newOpcodes.cleo") and
   getFileSize(getGameDirectory() .. "\\cleo\\newOpcodes.cleo") < 161280 then
      sampAddChatMessage("У вас устаревшая версия NewOpcodes которая может вызывать краши", 0xFF00000)
   end
   
   if doesFileExist(getGameDirectory() .. "\\cleo\\NewOpcodes.cleo") and
   getFileSize(getGameDirectory() .. "\\cleo\\NewOpcodes.cleo") < 161280 then
      sampAddChatMessage("У вас устаревшая версия NewOpcodes которая может вызывать краши", 0xFF00000)
   end
   
   -- streammemfix checker
   if doesFileExist(getGameDirectory() .. "\\StreamMemFix.asi") and 
   getFileSize(getGameDirectory() .. "\\StreamMemFix.asi") ~= 50600 then
      sampAddChatMessage("У вас устаревшая версия streammemfix которая может вызывать краши", 0xFF00000)
      print("ModChecker warning: this version streammemfix incompatible with windows 10+")
   end  
   
   if doesFileExist(getGameDirectory() .. "\\StreamMemFix.asi") and 
   getFileSize(getGameDirectory() .. "\\StreamMemFix.asi") == 27648 then
      print("ModChecker warning: this version streammemfix incompatible with windows 10+")
   end
   
   if doesFileExist(getGameDirectory() .. "\\FramerateVigilante.SA.asi") and
   doesFileExist(getGameDirectory() .. "\\Swim FPS Fix.asi") then
      sampAddChatMessage("FramerateVigilante и Swim FPS Fix несовместимы (удалите Swim FPS Fix)", 0xFF00000)
      print("ModChecker warning: FramerateVigilante and Swim FPS Fix are incompatible (remove Swim FPS Fix)")
   end
   
   if doesFileExist(getGameDirectory() .. "\\SAMP-GPS.asi") and 
   doesFileExist(getGameDirectory() .. "\\FramerateVigilante.SA.asi") then
      if getFileSize(getGameDirectory() .. "\\SAMP-GPS.asi") ~= 155136 then
         sampAddChatMessage("Ваша версия SAMP-GPS несовместима с FramerateVigilante (обновите SAMP-GPS)", 0xFF00000)
         print("ModChecker warning: Your SAMP-GPS version is not compatible with FramerateVigilante (update SAMP-GPS)")
      end
   end
   -- exdisp
   if doesFileExist(getGameDirectory() .. "\\exdisp.asi") then
      sampAddChatMessage("exdisp.asi может вызывать краши при снятом ограничителе фпс", 0xFF00000)
      print("ModChecker warning: exdisp.asi can cause crashes when the fps limiter is removed")
      print("ModChecker warning: install widescreen fix asi instead of exdisp.asi")
   end
   
   -- GFXHack
   if doesFileExist(getGameDirectory() .. "\\GFXHack.asi") then
      sampAddChatMessage("GFXHack устарел, используйте SilentPatch вместо него", 0xFF00000)
      print("ModChecker warning: GFXHack Outdated. (SILENT PATCH already contains this fix)")
   end
   
   -- III.VC.SA.LimitAdjuster
   if doesFileExist(getGameDirectory() .. "\\III.VC.SA.LimitAdjuster.asi") then
      sampAddChatMessage("SA.LimitAdjuster плагин может вызывать проблемы со стабильностью и производительностью", 0xFF00000)
      print("ModChecker warning: SA.LimitAdjuster plugin causes stability and performance issues")
   end
   
   if doesFileExist(getGameDirectory() .. "\\III.VC.SA.LimitAdjuster.asi") and 
   doesFileExist(getGameDirectory() .. "\\modloader\\LOD Vegetation\\LODvegetation.ide") then 
      sampAddChatMessage("LOD Vegetation установлен вместе с Project2DFX, возможны проблемы с запуском игры", 0xFF00000)
      print("ModChecker warning: LOD Vegetation installed with Project2DFX, possible problems with game launch")
   end
   
   -- SAsearchlightlimitadjuster.asi
   if doesFileExist(getGameDirectory() .. "\\SAsearchlightlimitadjuster.asi") then
      sampAddChatMessage("SAsearchlightlimitadjuster этот мод устарел и вызывает краши", 0xFF00000)
      print("ModChecker warning: SAsearchlightlimitadjuster this mod is outdated and causes crashes")
   end
   
   -- IndieVehicles.asi
   if doesFileExist(getGameDirectory() .. "\\IndieVehicles.asi") then
      sampAddChatMessage("IndieVehicles.asi этот мод устарел и несовместим с некоторыми модами! Теперь он интегрирован в VehFuncs", 0xFF00000)
      print("ModChecker warning: IndieVehicles.asi this mod is outdated and incompatible with some mods! Now it is integrated into VehFuncs")
   end
   
   -- Ryosuke's Bullet mod
   if doesFileExist(getGameDirectory() .. "\\bullet.asi") then
      sampAddChatMessage("bullet.asi вызывает краш при стрельбе в особняке  Madd Dogg's mansion", 0xFF00000)
      print("ModChecker warning: bullet.asi causes crash when shooting in Madd Dogg's mansion")
   end
   
   -- newCoronaLimit
   if doesFileExist(getGameDirectory() .. "\\newCoronaLimit.asi") then
      sampAddChatMessage("newCoronaLimit.asi приводит к сбою в отображении шейдера ENB на автомобилях.", 0xFF00000)
      print("ModChecker warning: newCoronaLimit causes the ENB shader to fail to display on cars")
   end
   
   -- SA_Lightning
   if doesFileExist(getGameDirectory() .. "\\SA_Lightning.asi") then
      sampAddChatMessage("SA_Lightning.asi устарел, не работает на WIn7/10", 0xFF00000)
      print("ModChecker warning: SA_Lightning outdated, does not work on WIn7/10")
   end
   
   -- SCMDirectDrawing
   if doesFileExist(getGameDirectory() .. "\\SCMDirectDrawing.asi") then
      sampAddChatMessage("SCMDirectDrawing Конфликтует с другими плагинами, и приводит к тому, что шрифты и информационное поле не отображаются.", 0xFF00000)
      print("ModChecker warning: SCMDirectDrawing сonflicts with other plugins, and leads to the fact that fonts and the information field are not displayed.")
   end
   
   -- Searchlights
   if doesFileExist(getGameDirectory() .. "\\Searchlights.asi") then
      sampAddChatMessage("Searchlights крашит на новых версиях клиента.", 0xFF00000)
      print("ModChecker warning: Searchlights crashes on new versions of samp client.")
   end
   
   -- SuperVars
   if doesFileExist(getGameDirectory() .. "\\SuperVars.asi") then
      sampAddChatMessage("SuperVars устарел может вызывать краши на новых версиях клиентах.", 0xFF00000)
      print("ModChecker warning: SuperVars outdated may cause crashes on new versions of clients.")
   end
   
   -- GTA.SA.WideScreen.Fix.asi
   if doesFileExist(getGameDirectory() .. "\\GTA.SA.WideScreen.Fix.asi") then
      sampAddChatMessage("GTA.SA.WideScreen.Fix Сбрасывает разрешение до разрешения рабочего стола, при нулевых параметрах ResX и ResY", 0xFF00000)
      print("ModChecker warning: GTA.SA.WideScreen.Fix Resets the resolution to desktop resolution, with zero ResX and ResY parameters.")
   end
   
   -- DwmComposition
   if doesFileExist(getGameDirectory() .. "\\DwmComposition.asi") then
      sampAddChatMessage("DwmComposition Вызывает проблемы с запуском и сворачиванием игры на Windows 10.", 0xFF00000)
      print("ModChecker warning: DwmComposition causes problems with starting and minimizing the game on Windows 10.")
   end
   
   -- LimitFPS100
   if doesFileExist(getGameDirectory() .. "\\LimitFPS100.asi") then
      if doesFileExist(getGameDirectory() .. "\\FPSUnlock.asi") or 
      doesFileExist(getGameDirectory() .. "\\cleo\\FPSUnlock.cs") then
         sampAddChatMessage("Одновременно установлен FPS Unlock и FPS Limiter.", 0xFF00000)
         print("ModChecker warning: FPS Unlock and FPS Limiter are installed at the same time.")
      end
   end
   
   -- skybox
   if doesFileExist(getGameDirectory() .. "\\cleo\\cleoskybox.cs") then
      sampAddChatMessage("cleoskybox.cs устарел и может вызывать краши и некорректное отображение текстур", 0xFF00000)
      print("ModChecker warning: cleoskybox.cs is outdated and can cause crashes and incorrect show server textures")
      print("ModChecker warning: install RealSkybox.SA.asi instead of skybox.cleo")
   end
   
   -- skygrad
   if ENBSeries and doesFileExist(getGameDirectory() .. "\\skygrad.asi") then
      print("ModChecker warning: incorrect skygrad.asi incompatible with ENB")
   end
   
    -- RealSkybox.SA and BetterSkybox
   if doesFileExist(getGameDirectory() .. "\\RealSkybox.SA.asi") and 
   doesFileExist(getGameDirectory() .. "\\moonloader\\BetterSkybox.lua") then
      sampAddChatMessage("Одновременное использование модов BetterSkybox и RealSkybox.SA вызывает глитчи", 0xFF00000)
      print("ModChecker warning: using mods BetterSkybox and RealSkybox.SA.asi simultaneously causes glitches")
   end
   
   -- timecycle24 and Real Linear Graphics
   if doesFileExist(getGameDirectory() .. "\\timecycle24.asi") and
   getFileSize(getGameDirectory() .. "\\timecycle24.asi") ~= 86016 and 
   doesFileExist(getGameDirectory() .. "\\data\\timecyc_24h.dat") then 
      sampAddChatMessage("Устаревший мод на Timecycle. Мод 24H Timecycle устанавливается без файла timecyc_24h.dat", 0xFF00000)
      print("ModChecker warning: Outdated timecycle mod. The 24H Timecycle mod shoud be installed without the timecyc_24h.dat file")
   end
   
   -- SAMPFUNCS and skygfx
   if SAMPFUNCS and doesFileExist(getGameDirectory() .. "\\SkyGfx.asi") then
      sampAddChatMessage("SkyGFX is incompatible with SAMPFUNCS", 0xFF00000)
      print("ModChecker warning: SkyGfx несовместим с SAMPFUNCS")
   end
   
   -- fixtimecyc.cs
   if doesFileExist(getGameDirectory() .. "\\cleo\\fixtimecyc.cs") 
   and doesFileExist(getGameDirectory() .. "\\LightMap.asi") then
      sampAddChatMessage("fixtimecyc.cs несовместим с LightMap.asi", 0xFF00000)
      print("ModChecker warning: fixtimecyc.cs is incompatible with LightMap.asi")
   end
   
   if doesFileExist(getGameDirectory() .. "\\cleo\\binaryipl.cs") then
      sampAddChatMessage("binaryipl.cs вызывает множество крашей (не используйте данный мод)", 0xFF00000)
      print("ModChecker warning: binaryipl.cs a causes many crashes (do not use this mod)")
   end
   
   -- FixDIST.cs
   if ModTimecyc and doesFileExist(getGameDirectory() .. "\\cleo\\FixDIST.cs") then
      sampAddChatMessage("FixDIST.cs может неккоректно работать на нестандартном таймцикле", 0xFF00000)
      print("ModChecker warning: FixDIST.cs may not work correctly on a non-standard timecycle")
   end
   
   -- language files check
   if doesFileExist(getGameDirectory() .. "\\data\\fonts\\fp_font.dat") and 
   getFileSize(getGameDirectory() .. "\\data\\fonts\\fp_font.dat") ~= 979 then
      sampAddChatMessage("Некорректный fp_font.dat может выдавать неверную ширину некоторых символов", 0xFF00000)
      print("ModChecker warning: incorrect fp_font.dat may output incorrect width of some characters")
   end
   
   -- First-Person mode
   if doesFileExist(getGameDirectory() .. "\\FirstPerson.sp") then
      if cleoVersion < 67371008 then
         sampAddChatMessage("Мод FirstPerson может неккоректно работать на вашей версии CLEO", 0xFF00000)
         print("ModChecker warning: First Person mod may not work correctly on your version of CLEO")
      end
   end
   -- LUA libs and scripts section
   -- crc32ffi
   if doesFileExist(getGameDirectory() .. "\\moonloader\\crc32ffi.lua") then
      sampAddChatMessage("crc32ffi.lua приводит к мгновенному закрытию игры без каких-либо ошибок или журнала", 0xFF00000)
      print("ModChecker warning: crc32ffi results in instant closure of the game without any errors or log")
   end
   
   -- maplimit260
   if doesFileExist(getGameDirectory() .. "\\moonloader\\maplimit260.lua") then
      sampAddChatMessage("maplimit260 Вызывает сбой после загрузки", 0xFF00000)
      print("ModChecker warning: maplimit260 Causes a crash after loading")
   end
   
   if doesFileExist(getGameDirectory() .. "\\moonloader\\chatNopFlood.lua") and 
   doesFileExist(getGameDirectory() .. "\\moonloader\\antiscrollingchat.lua") then
      sampAddChatMessage("chatNopFlood.lua и antiscrollingchat.lua несовместимы", 0xFF00000)
      print("ModChecker warning: chatNopFlood.lua and antiscrollingchat.lua are incompatible")
   end
   
   -- Lucky patcher
   if doesFileExist(getGameDirectory() .. "\\moonloader\\!SAPatcher.lua") then
      if SampAddonInstalled then
         sampAddChatMessage("Lucky patcher несовместим с Samp Addon, аддон уже содержит фиксы из патчера", 0xFF00000)
         print("ModChecker warning: !SAPatcher.lua incompatible with Samp Addon, addon already contains fixes from patcher")
      end
      if doesFileExist(getGameDirectory() .. "\\moonloader\\AbsoluteFix.lua") then
         sampAddChatMessage("Lucky patcher несовместим с AbsoluteFix. AbsoluteFix уже содержит фиксы из патчера", 0xFF00000)
         print("ModChecker warning: !SAPatcher.lua incompatible with AbsoluteFix. AbsoluteFix already contains fixes from patcher")
      end
   end
   
   if not doesFileExist(getGameDirectory() .. "\\moonloader\\lib\\samp\\events.lua") then
      sampAddChatMessage("Установлен moonloader без библиотеки lib.samp.events", 0xFF00000)
      print("ModChecker warning: Moonloader installed without lib.samp.events library")
   end
   
   if not AZLauncher then
      -- Check game resources
      -- The main.scm and script.img files are responsible for the story mode and other scenarios, this depends on the version of the game.
      if doesFileExist(getGameDirectory() .. "\\data\\script\\main.scm") and 
      getFileSize(getGameDirectory() .. "\\data\\script\\main.scm") ~= 3079599 then
         sampAddChatMessage("У вас установлен изменненый файл сценариев main.scm", 0xFF00000)
         sampAddChatMessage("Он может быть несовместим с определенной сохраненной игрой или каким-либо модом", 0xFF00000)
         print("ModChecker warning: You have a modified main.scm script file installed.")
      end
      
      if doesFileExist(getGameDirectory() .. "\\data\\script\\script.img") and 
      getFileSize(getGameDirectory() .. "\\data\\script\\script.img") ~= 581632 then
         sampAddChatMessage("У вас установлен изменненый файл сценариев script.img", 0xFF00000)
         sampAddChatMessage("Он может быть несовместим с определенной сохраненной игрой или каким-либо модом", 0xFF00000)
         print("ModChecker warning: You have a modified script.img script file installed.")
      end
   end 
   -- END MAIN
end

-- Extended filesystem functions
function doesFileExist(path)
   -- work like doesDirectoryExist(string directory)
   -- result: ans = file_exists("sample.txt")
   local f=io.open(path,"r")
   if f~=nil then io.close(f) return true else return false end
end

function getFileSize(path)
   local file=io.open(path,"r")
   local current = file:seek()      -- get current position
   local size = file:seek("end")    -- get file size
   file:seek("set", current)        -- restore position
   return size
end