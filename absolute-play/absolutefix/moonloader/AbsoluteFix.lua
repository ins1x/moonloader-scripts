script_author("1NS")
script_name("AbsoluteFix")
script_description("Set of fixes for Absolute Play servers")
script_properties("work-in-pause")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("3.5") 
-- script_moonloader(16) moonloader v.0.26

-- If your don't play on Absolute Play servers
-- recommend use more functional script GameFixer by Gorskin
-- https://vk.com/@gorskinscripts-gamefixer-obnovlenie-30
-- or MixSets https://www.mixmods.com.br/2022/03/sa-mixsets/

require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local memory = require 'memory'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

----------------- [ cfg ] -------------------
local inicfg = require 'inicfg'
local configIni = "AbsoluteFix.ini"
local ini = inicfg.load({
   settings =
   {
      antiafk = true,
      anticrash = true,
	  autoreconnect = true,
      chatfilter = true,
      dialogfix = true,
      disablenotifications = true,
	  disablerecordnotifications = true,
      fastload = true,
      hideattachesonaim = true,
	  hidehousesmapicons = true,
      houseobjectsrotfix = true,
      gamefixes = true,
      grass = false,
      infinityrun = true,
      improvedrun = true,
      improvedbike = true,
      improvedjetpack = true,
      improvedairvehheight = true,
      keybinds = true,
      noeffects = false,
      nologo = false,
	  noradio = false,
      nogametext = false,
	  noweaponpickups = true,
      menupatch = true,
      pmsoundfix = true,
	  restoreremovedobjects = false,
	  recontime = 20000,
      shadows = false,
      speedblur = false,
      sunfix = false,
      snowoff = false,
      vehvisualdmg = false
   },
}, configIni)
inicfg.save(ini, configIni)

local isAbsoluteRoleplay = false
local removed_objects = {647, 1410, 1412, 1413} 
local restored_objects = {3337, 3244, 3276, 1290, 1540} 
local worldspawnpos = {x = 0.0, y = 0.0, z = 0.0}
local attached_objects = {}
local isPlayerSpectating = false
local isWorldHoster = false
local dialogs = {}
local dialogRestoreText = false
local dialogIncoming = 0
local clickedplayerid = nil
local randomcolor = nil
local lastObjectId = nil
local lastObjectModelId = nil
local hideEditObject = false
local scaleEditObject = false
local editResponse = 0 
local editMode = 0
local lastWorldNumber = nil
local lastWorldName = nil
local lastRemovedObjectModel = nil

-- macro
function isLookingAtPlayer()
   return readMemory(0xB6F028+0x2B, 1, true) == 1
end

function doesFileExist(path)
   -- work like doesDirectoryExist(string directory)
   -- result: ans = file_exists("sample.txt")
   local f=io.open(path,"r")
   if f~=nil then io.close(f) return true else return false end
end

function getClosestPlayerId()
    local closestId = -1
    mydist = 30
    local x, y, z = getCharCoordinates(PLAYER_PED)
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

function enterEditObject()
   local bs = raknetNewBitStream()
   raknetEmulRpcReceiveBitStream(27, bs)
   raknetDeleteBitStream(bs)
end 

-- function editObjectBySampId(id, playerobj) 
   -- if isSampAvailable() then
      -- ffi.cast("void (__thiscall*)(unsigned long, short int, unsigned long)", sampGetBase() + 0x6DE40)(readMemory(sampGetBase() + 0x21A0C4, 4), id, playerobj and 1 or 0)
   -- end
-- end

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
      while not isSampAvailable() do wait(100) end
	  
      -- flickr
      if not doesFileExist(getGameDirectory() .. "\\flickr.asi") then
         writeMemory(0x5B8E55, 4, 0x15F90, true)
         writeMemory(0x5B8EB0, 4, 0x15F90, true)
	  end
			
	  -- remove "open Y menu" textdraw
      sampTextdrawDelete(423)
	  -- remove server site textdraw
	  sampTextdrawDelete(418)
	  -- remove server logo
	  if ini.settings.nologo then            
         sampTextdrawDelete(2048)
         sampTextdrawDelete(420)
      end
   
	  if ini.settings.antiafk then
         -- dirty hack nop F1 and F4 keys functions
         memory.setuint8(getModuleHandle('samp.dll') + 0x67450, 0xC3, true)
         memory.write(sampGetBase()+0x797E, 0, 1, true)
	  end
      
	  -- fastload (Hide default loading screen like fastload.asi)
	  if ini.settings.fastload and not doesFileExist(getGameDirectory() .. "\\FastLoad.asi") then 
         if memory.getuint8(0x748C2B) == 0xE8 then
		    memory.fill(0x748C2B, 0x90, 5, true)
	     elseif memory.getuint8(0x748C7B) == 0xE8 then
		    memory.fill(0x748C7B, 0x90, 5, true)
	     end
	     if memory.getuint8(0x5909AA) == 0xBE then
		    memory.write(0x5909AB, 1, 1, true)
	     end
	     if memory.getuint8(0x590A1D) == 0xBE then
		    memory.write(0x590A1D, 0xE9, 1, true)
		    memory.write(0x590A1E, 0x8D, 4, true)
	     end
	     if memory.getuint8(0x748C6B) == 0xC6 then
       	    memory.fill(0x748C6B, 0x90, 7, true)
	     elseif memory.getuint8(0x748CBB) == 0xC6 then
		    memory.fill(0x748CBB, 0x90, 7, true)
	     end
	     if memory.getuint8(0x590AF0) == 0xA1 then
		    memory.write(0x590AF0, 0xE9, 1, true)
		    memory.write(0x590AF1, 0x140, 4, true)
	     end
	  end
	  
	  -- Deleting unnecessary sections in the menu in SA-MP
	  if ini.settings.menupatch then
	     memory.copy(0x8D0444, memory.strptr("\x36\x46\x45\x50\x5F\x52\x45\x53\x00\x0B\x00\x00\x40\x01\xAA\x00\x03\x00\x05\x46\x45\x48\x5F\x4D\x41\x50\x00\x0B\x05\x00\x40\x01\xC8\x00\x03\x00\x05\x46\x45\x50\x5F\x4F\x50\x54\x00\x0B\x21\x00\x40\x01\xE6\x00\x03\x00\x05\x46\x45\x50\x5F\x51\x55\x49\x00\x0B\x23\x00\x40\x01\x04\x01\x03\x00"), 72)
         memory.fill(0x8D048C, 0, 144)
         memory.write(0x8CE47B, 1, 1)
         memory.write(0x8CFD33, 2, 1)
         memory.write(0x8CFEF7, 3, 1)
	  end
	  
      if ini.settings.gamefixes then 
		 -- SADisplayResolutions(1920x1080// 16:9)
         memory.write(0x745BC9, 0x9090, 2, false) 
		 -- CJFix
         memory.fill(0x460773, 0x90, 7, false)
		 -- the helicopter doesn't explode many times
         memory.setuint32(0x736F88, 0, false) 
		 -- fix blackroads
         memory.write(8931716, 0, 4, false)
         -- enable this-blip
         memory.setuint8(0x588550, 0xEB, true)
         -- disable Replays
         writeMemory(0x460500, 1, 0xC3, true)

         -- binthesky by DK
         -- memory.fill(0x5557CF, 0x90, 7, true)
      
         memory.fill(0x748E6B, 0x90, 5, true) -- CGame::Shutdown
	     memory.fill(0x748E82, 0x90, 5, true) -- RsEventHandler rsRWTERMINATE
	     memory.fill(0x748E75, 0x90, 5, true) -- CAudioEngine::Shutdown
         
         -- Afk shift fix by FYP
		 memory.fill(0x00531155, 0x90, 5, true)
		 
         -- nop gamma 
		 --memory.hex2bin('E9D200000090', 0x0074721C, 5)
         
         -- fps fix
         memory.write(0x53E94C, 0, 1, false) --del fps delay 14 ms
         memory.setuint32(12761548, 1051965045, false) -- car speed fps fix
         writeMemory(7547174, 4, 8753112, true) -- limit lod veh
         
         -- birds on
         memory.write(5497200, 232, 1, false)
         memory.write(5497201, 1918619, 4, false)
         
         -- interior reflections
         memory.write(0x555854, 0x90909090, 4, false)
         memory.write(0x555858, 0x90, 1, false)
         
         -- fixing spawn with a bottle
         memory.fill(0x4217F4, 0x90, 21, false)
         memory.fill(0x4218D8, 0x90, 17, false)
         memory.fill(0x5F80C0, 0x90, 10, false)
         memory.fill(0x5FBA47, 0x90, 10, false)
		 
		 -- patch anim duck
		 writeMemory(0x692649+1, 1, 6, true)
         
         -- disable talking
         writeMemory(0x5EFFE7, 1, 0xEB, true)
         
         -- disable the rocking of the body of cars 
         writeMemory(0x6AC0F0, 2, 0x9090, true)
         -- windsound bugfix
         local windsoundfix = allocateMemory(4)
         writeMemory(windsoundfix, 4, 1, true)
         writeMemory(0x506667+1, 4, windsoundfix, true)
         writeMemory(0x505BEB+1, 4, windsoundfix, true)
         
         -- fixloadmap
         memory.fill(0x584C6D, 0x90, 0x19, true)
         
         -- long armfix
         memory.write(7045634, 33807, 2, true)
         memory.write(7046489, 33807, 2, true)
         
      end
      
      if ini.settings.anticrash then
		 -- AntiCrash R1
		 local base = sampGetBase() + 0x5CF2C
         writeMemory(base, 4, 0x90909090, true)
         base = base + 4
         writeMemory(base, 1, 0x90, true)
         base = base + 9
         writeMemory(base, 4, 0x90909090, true)
         base = base + 4
         writeMemory(base, 1, 0x90, true)
      end
         
      if ini.settings.infinityrun then
         -- infinity run
         memory.setint8(0xB7CEE4, 1)
      end
      
      if ini.settings.improvedrun then
         -- interior run
         memory.write(5630064, -1027591322, 4, false)
         memory.write(5630068, 4, 2, false)
      end
          
      if ini.settings.improvedjetpack then 
         -- Jetpack MaxHeight fix
         memory.write(0x67F268, 121, 1, false)
      end
	  
      if ini.settings.improvedairvehheight then 
         -- Max helicopter height
         memory.write(0x6D261D, 235, 1, false)
      end      
      
      if ini.settings.noeffects then
         -- nodust
         memory.write(7205311, 1056964608, 4, false)
         memory.write(7205316, 1065353216, 4, false)
         memory.write(7205321, 1065353216, 4, false)
         memory.write(7205389, 1056964608, 4, false)
         memory.write(7204123, 1050253722, 4, false)
         memory.write(7204128, 1065353216, 4, false)
         memory.write(7204133, 1060320051, 4, false)
         memory.write(5527777, 1036831949, 4, false)
         memory.write(4846974, 1053609165, 4, false)
         memory.write(4846757, 1053609165, 4, false)
         
		 -- no sand particle
		 memory.fill(0x6AA8CF, 0x90, 53, true)
         
		 -- noshadows
         memory.write(5497177, 233, 1, false)
         memory.write(5489067, 492560616, 4, false)
         memory.write(5489071, 0, 1, false)
         memory.write(6186889, 33807, 2, false)
         memory.write(7388587, 111379727, 4, false)
         memory.write(7388591, 0, 2, false)
         memory.write(7391066, 32081167, 4, false)
         memory.write(7391070, -1869611008, 4, false)
         
         -- disable Blue Fog
         -- memory.fill(0x575B0E, 0x90, 5, true)
         
         -- disable Haze Effect
         -- memory.write(0x72C1B7, 0xEB, 1, true)
         
         -- NoStencilShadows
         memory.write(0x70BDAC, 0x84, false);
      end
	  
	  if ini.settings.noradio then
	     memory.copy(0x4EB9A0, memory.strptr('\xC2\x04\x00'), 3, true)
	  end
      
      --- END init
      while true do
      wait(0)
      
	  -- Autoreconnect
	  -- Required use reset_remove.asi fix
	  if ini.settings.autoreconnect then
	     local chatstring = sampGetChatString(99)
         if chatstring == "Server closed the connection." 
		 or chatstring == "You are banned from this server."
		 or chatstring == "Use /quit to exit or press ESC and select Quit Game" then
	        sampDisconnectWithReason(false)
            sampAddChatMessage("Wait reconnecting...", 0xa9c4e4ff)
            wait(ini.settings.recontime)
            sampSetGamestate(1)-- GAMESTATE_WAIT_CONNECT
         end
	  end
     
      local servername = sampGetCurrentServerName()
      -- Unload script if not localhost server and not is Absolute
      if isLookingAtPlayer() then
         local ip, port = sampGetCurrentServerAddress()
         
         if not ip:find("127.0.0.1") then
            if not servername:find("Absolute") and
            not servername:find("Абсолют") then
               thisScript():unload()
            end
         end
      end
      
      if servername:find("Абсолют") then
         isAbsoluteRoleplay = true
      end
      
      -- chatfix
      if isKeyJustPressed(0x54) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
         sampSetChatInputEnabled(true)
      end
      
      -- nobike
      if ini.settings.improvedbike then
         if isCharInAnyCar(PLAYER_PED) then
            setCharCanBeKnockedOffBike(PLAYER_PED, true)
         else
            setCharCanBeKnockedOffBike(PLAYER_PED, false)
         end
         if isCharInAnyCar(PLAYER_PED) and isCarInWater(storeCarCharIsInNoSave(PLAYER_PED)) then
            setCharCanBeKnockedOffBike(PLAYER_PED, false)
         end
      end
	  
      if ini.settings.antiafk then
         writeMemory(7634870, 1, 1, 1)
         writeMemory(7635034, 1, 1, 1)
         memory.fill(7623723, 144, 8)
         memory.fill(5499528, 144, 6)
      else
         memory.setuint8(7634870, 0, false)
         memory.setuint8(7635034, 0, false)
         memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
         memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
      end
    
	  -- hide attachet object if player aiming by sniper rifle, camera, rpg
      if ini.settings.hideattachesonaim then
	     if isKeyDown(0x02) then
		    if isCurrentCharWeapon(PLAYER_PED, 34) or isCurrentCharWeapon(PLAYER_PED, 43) or 
			isCurrentCharWeapon(PLAYER_PED, 35) or isCurrentCharWeapon(PLAYER_PED, 36) then
	           for i, objid in pairs(getAllObjects()) do
			      pX, pY, pZ = getCharCoordinates(PLAYER_PED)
			      _, objX, objY, objZ = getObjectCoordinates(objid)
			      local ddist = getDistanceBetweenCoords3d(pX, pY, pZ, objX, objY, objZ)
			      if ddist < 1 and attached_objects[objid] ~= false then
			         setObjectVisible(objid, false)
				     attached_objects[objid] = false
			      end
		       end
			end
	     else
	        for i, objid in pairs(getAllObjects()) do
			   if attached_objects[objid] == false then
			      pX, pY, pZ = getCharCoordinates(PLAYER_PED)
				  _, objX, objY, objZ = getObjectCoordinates(objid)
				  local ddist = getDistanceBetweenCoords3d(pX, pY, pZ, objX, objY, objZ)
				  if attached_objects[objid] == false then
				     setObjectVisible(objid, true)
					 attached_objects[objid] = true
		     	  end
		       end
		    end
	     end
      end
      
      -- no dialogs restore (by rraggerr)
      if ini.settings.dialogfix then
         if dialogIncoming ~= 0
         and dialogs[dialogIncoming] then
            local data = dialogs[dialogIncoming]
            if data[1] and not dialogRestoreText then
               -- ignore delete option restore on edit dialog
               if dialogIncoming == 1403 and data[1] == 1 then
                  sampSetCurrentDialogListItem(0)
               else
                  sampSetCurrentDialogListItem(data[1])
               end
            end
            if data[2] then
               -- dialog random color autocomplete
               if dialogIncoming == 1496 and randomcolor ~= nil then
                  sampSetCurrentDialogEditboxText(randomcolor)
               elseif dialogIncoming == 43 and randomcolor ~= nil then
                  sampSetCurrentDialogEditboxText(randomcolor)
               else
                  sampSetCurrentDialogEditboxText(data[2])
               end
            end
            dialogIncoming = 0
         end
      end
	  
	  -- won't let you get stuck in another player's skin. 
	  for i = 0, sampGetMaxPlayerId(false) do
		 if sampIsPlayerConnected(i) then
		    local result, id = sampGetCharHandleBySampPlayerId(i)
			if result and doesCharExist(id) then
			   local x, y, z = getCharCoordinates(id)
			   local mX, mY, mZ = getCharCoordinates(playerPed)
			   if 0.4 > getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) then
				  setCharCollision(id, false)
			   end
			end
	     end
      end
	  
	  -- delete trash objects fences 
	  if ini.settings.restoreremovedobjects then
	     for _, v in pairs(getAllObjects()) do
			local model = getObjectModel(v)
			for key, value in ipairs(removed_objects) do
			   if model == value then 
			      if doesObjectExist(v) then deleteObject(v) end 
			   end 
			end
		 end
	  end
	  
	  -- disable visual damage on gm car
	  if ini.settings.vehvisualdmg then
	     if isCharInAnyCar(PLAYER_PED) then
		    local car = getCarCharIsUsing(PLAYER_PED)
			local health = getCarHealth(car)
			if health > 1000.0 then
		       setCarCanBeVisiblyDamaged(car, false)
			end
		 end
	  end
	  
      -- fixes form Graphic settings dialog (id 1770)
      if ini.settings.speedblur then
         memory.fill(0x704E8A, 0xE8, 1, true)
         memory.fill(0x704E8B, 0x11, 1, true)
         memory.fill(0x704E8C, 0xE2, 1, true)
         memory.fill(0x704E8D, 0xFF, 1, true)
         memory.fill(0x704E8E, 0xFF, 1, true)
      else
         memory.fill(0x704E8A, 0x90, 1, true)
         memory.fill(0x704E8B, 0x90, 1, true)
         memory.fill(0x704E8C, 0x90, 1, true)
         memory.fill(0x704E8D, 0x90, 1, true)
         memory.fill(0x704E8E, 0x90, 1, true)
      end
      
      if ini.settings.grass then
	     memory.hex2bin("E8420E0A00", 0x53C159, 5) 
	     memory.protect(0x53C159, 5, memory.unprotect(0x53C159, 5)) 
	  else
	     memory.fill(0x53C159, 0x90, 5, true)
      end
      
      if ini.settings.sunfix then
	     memory.hex2bin("E865041C00", 0x53C136, 5) 
		 memory.protect(0x53C136, 5, memory.unprotect(0x53C136, 5))
      else
	     memory.fill(0x53C136, 0x90, 5, true)
	  end
      
      if ini.settings.shadows then
         memory.write(5497177, 233, 1, false)
         memory.write(5489067, 492560616, 4, false)
         memory.write(5489071, 0, 1, false)
         memory.write(6186889, 33807, 2, false)
         memory.write(7388587, 111379727, 4, false)
         memory.write(7388591, 0, 2, false)
         memory.write(7391066, 32081167, 4, false)
         memory.write(7391070, -1869611008, 4, false)
      else
         memory.write(5497177, 195, 1, false)
         memory.fill(5489067, 144, 5, false)
         memory.write(6186889, 59792, 2, false)
         memory.fill(7388587, 144, 6, false)
         memory.fill(7391066, 144, 9, false)
      end
      
      -- Absolute Play Key Binds
      -- Sets hotkeys that are only available with the samp addon
      if ini.settings.keybinds then
	     -- fix Y menu call on spectate mode 
	     if isKeyJustPressed(0x59) and isPlayerSpectating and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
		    sampSendChat("/menu")
		 end
         
         -- hide edited object on hold ALT key
         if isKeyDown(0x12) and editResponse > 0 and not sampIsChatInputActive() 
         and not sampIsDialogActive() and not isPauseMenuActive() 
         and not isSampfuncsConsoleActive() then
	        hideEditObject = true
	     else
	 	    hideEditObject = false
	     end
	     
	     -- upscale edited object on hold CTRL key
	     if isKeyDown(0x11) and editResponse > 0 and not sampIsChatInputActive() 
         and not sampIsDialogActive() and not isPauseMenuActive() 
         and not isSampfuncsConsoleActive() then
	        scaleEditObject = true
	     else
	 	    scaleEditObject = false
	     end
         
		 -- When switching the language Alt+Shift Shift is no longer triggered and the player does not jump
		 if isKeyDown(0xA0) and isKeyJustPressed(0xA4) and sampIsChatInputActive() and not isPauseMenuActive() and not isCharInAnyCar(PLAYER_PED) then
		    clearCharTasksImmediately(PLAYER_PED)
			setPlayerControl(playerHandle, 1)
			freezeCharPosition(PLAYER_PED, false)
         end		 
		 
		 -- The Tab key does not trigger a shot when aiming
		 if isKeyDown(0x02) and isKeyDown(0x09) and not isCharInAnyCar(PLAYER_PED) then
		    clearCharTasksImmediately(PLAYER_PED)
		 end 
		 
		 -- Open last chosen player dialog on B key (only if samp addon not installed)
	     if isKeyJustPressed(0x42) and not sampIsChatInputActive() and not isPauseMenuActive()
	     and not sampIsDialogActive() and not isSampfuncsConsoleActive() then 
		    if clickedplayerid then
		       if sampIsPlayerConnected(clickedplayerid) then 
			      sampSendChat("/и " .. clickedplayerid)
			   end
		    end
	     end 
		 
		 -- ALT + RMB show player stats
		 if isKeyDown(0x02) and isKeyJustPressed(0x12) and not sampIsChatInputActive() and not isPauseMenuActive() and isCharInAnyCar(PLAYER_PED) then
		    if(getClosestPlayerId() ~= -1) then
			   sampSendChat(string.format("/cnfn %i", getClosestPlayerId()))
			end
         end	
		 
		 if isAbsoluteRoleplay then
            if isKeyJustPressed(0x4B) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/gps") end
		 else
		    if isKeyJustPressed(0x4B) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye2") end
		 end	
         
		 if isAbsoluteRoleplay then
            if isKeyJustPressed(0x50) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/phone") end
		 
            if isKeyJustPressed(0x49) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/inv") end
		 end
		 
         if isPlayerSpectating then
            if isKeyJustPressed(0x4E) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then 
               --if lastObjectId ~= nil then
                  --editObjectBySampId(lastObjectId, false)
               --end
               enterEditObject()
            end
         end
         
         if isKeyJustPressed(0x4D) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/vfibye") end
         
         if isKeyJustPressed(0x55) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/anim") end
      
         if isKeyJustPressed(0x4A) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/gjktn") end
	     
		 -- if Player in Vehicle
	     if isCharInAnyCar(PLAYER_PED) then
	        if isKeyJustPressed(0x4C) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/lock") end
	        
            if not isAbsoluteRoleplay then
               if isKeyJustPressed(0x48) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then  sampSendChat("/f") end
               
			   if isKeyJustPressed(0x5A) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendChat("/xbybnm") end
            end   
		 end
		 
		 -- Switching textdraws with arrow buttons, mouse buttons, pgup-pgdown keys
	     if isKeyJustPressed(0x25) or isKeyJustPressed(0x05) or isKeyJustPressed(0x21) and sampIsCursorActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendClickTextdraw(36) end
	  
	     if isKeyJustPressed(0x27) or isKeyJustPressed(0x06) or isKeyJustPressed(0x22) and sampIsCursorActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then sampSendClickTextdraw(37) end
      end 
	  
      -- END main
   end
end

-- Hooks
function sampev.onServerMessage(color, text)
   -- Some functions are prohibited on Arizona
   if text:find('Добро пожаловать на Arizona Role Play!') then
      thisScript():unload()
   end
   
   if ini.settings.chatfilter then 
      if text:find("подключился к серверу") or text:find("вышел с сервера") then
         chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
         chatlog:write(os.date("[%H:%M:%S] ")..text)
         chatlog:write("\n")
         chatlog:close()
         return false
      end
   end
   
   if ini.settings.disablenotifications then
	  -- ignore various server flood mesages
	  if text:find("не засчитан") then
         return false
      end
	  
      if text:find("выхода из читмира") then
         return false
      end
      
      if text:find("выпустить могут только админы") then
         return false
      end
   
      if text:find("Ни 1 клан не создан") then
         return false
      end
      
      if text:find("Громкость музыки зависит от громкости радио") then
         return false
      end
      
      if text:find("Рекорд игроков на сервере") then
         return false
      end
      
      if text:find("Ты слишком далеко от транспорта") then
         return false
      end
      
      if text:find("Вконтакте") then
         return false
      end

      if text:find("У тебя устаревшая версия клиента") then
         return false
      end
      
      if text:find("Рекомендуется скачать последнюю версию с нашего сайта") then
         return false
      end
      
      if text:find("Никто не смог решить вопрос терминала загадок") then
         return false
      end
      
      if text:find("В мире можно телепортироваться к объектам или на карте") then
         return false
      end
      
      if text:find("Необходим установленный SA") then
         return false
      end
      
      if text:find("Клавиша Y") then
         if text:find("Основное меню") then
            return false
         end
      end
      
      if text:find("Последнего созданного объекта не существует") then
         lua_thread.create(function()
            wait(500)
            if lastObjectModelId then
               sampAddChatMessage("Последний использованный объект: {696969}"..lastObjectModelId, -1)
	        end
         end)
      end
      
      if text:find("Управляющим мира смертельный урон не наносится") then
         sampAddChatMessage("N - Оружие - Отключить сужающуюся зону урона", -1)
      end
      
      if text:find("Установи 0.3DL чтобы включать полёт в этом месте") then
         sampAddChatMessage("Необходимо уходить в полет с другой точки, где мало объектов рядом (выйти из зоны стрима)", 0x00FF00)
      end
      
      if text:find("Ты уже находишься в редакторе миров") then
         sampSendChat("/exit")
      end
      
      if text:find("В этой области создано слишком много объектов") then
         sampAddChatMessage("Вы создали много объектов в одной области.", 0x00FF00)
         sampAddChatMessage("В радиусе 150 метров нельзя создавать больше 200 объектов.", 0x00FF00)
         return false
      end
      
      if text:find("Это не твой мир, редактировать его ты не можешь") then
         return false
      end
      
      if text:find("использовал телепорт") and isWorldHoster then
         return false
      end
   end
   
   if ini.settings.disablerecordnotifications then
      -- ignore record flood mesages
   	  if text:find("рекорд дрифта") then
         return false
      end
	  
	  if text:find("рекорд в безумном трюке") then
         return false
      end
	  
	  if text:find("рекорд в трюке") then
         return false
      end
   end
   
   if ini.settings.pmsoundfix then
      if text:find("{00FF00}ЛС") then
	     addOneOffSound(0.0, 0.0, 0.0, 1138) -- CHECKPOINT_GREEN
         return true
	  end
   end
end

function sampev.onTogglePlayerSpectating(state)
   isPlayerSpectating = state
end

function sampev.onDisplayGameText(style, time, text)
   -- hide /dv message (Транспорт восстановлен 1000$)
   if style == 3 and text:find("1000$") then
      return false
   end
   if ini.settings.nogametext then 
      return false
   end
end

function sampev.onCreatePickup(id, model, pickupType, position)
   -- disable weapon pickups (exclude jetpack, armour, parachute)
   if ini.settings.noweaponpickups and model >= 325 and model <= 373 then
      if model ~= 370 and model ~= 371 and model ~= 373 then 
	     return false
	  end
   end
end 

function sampev.onSetMapIcon(iconId, position, type, color, style)
   if ini.settings.hidehousesmapicons then
	-- hide free houses mapicons
	  if(style == 0 and type == 31) then 
	     return false
	  end
   end
   
   if ini.settings.anticrash then
      local MAX_SAMP_MARKERS = 63
      if type > MAX_SAMP_MARKERS then
         return false
      end
   end
end

function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
   
   if ini.settings.gamefixes then
      dialogs[dialogId] = {listboxId, input}
   end
   
   -- Accessories dialog
   if dialogId == 100 and listboxId == 2 and button == 1 then
      sampAddChatMessage("Примечание: Стоимость 500$ за любой", -1)
   end
   
   -- Corrects the placement of objects near the house. Sets the correct angle.
   if dialogId == 100 and listboxId == 4 and button == 1 then
      sampAddChatMessage("Примечание: Стоимость 1000$ за любой", -1)
      if ini.settings.houseobjectsrotfix then
         local angle = math.ceil(getCharHeading(PLAYER_PED))
         local fixangle = 360/8 * math.floor(angle/45)
         setCharHeading(PLAYER_PED, fixangle)
         --print("src angle"..angle.."fixed angle: "..getCharHeading(PLAYER_PED))
      end
   end
      
   -- Graphics settings dialog
   if dialogId == 1770 and button == 1 then
      if listboxId == 0 then ini.settings.speedblur = not ini.settings.speedblur end
      if listboxId == 1 then ini.settings.shadows = not ini.settings.shadows end
      if listboxId == 2 then ini.settings.sunfix = not ini.settings.sunfix end
      if listboxId == 3 then 
         ini.settings.grass = not ini.settings.grass 
         return false
      end
      inicfg.save(ini, configIni)
   end
   
   -- Fix donate bug 
   -- (filters only for numeric values in order to avoid incorrect transfer)
   if dialogId == 1012 then
      if not tonumber(input) then
         sampAddChatMessage("Вы неправильно указали сумму перевода", 0xFFFF0000)
         return false --(dialogId, button, listboxId, 0)
      end
   end
   
   -- fix incorrect weapon ammo input
   if dialogId == 1431 and button == 1 then
      if tonumber(input) > 10000 then
         sampSendDialogResponse(1431, 1, 1, 1000)
      end
   end
      
   -- if player wxit from world without command drop lastWorldNumber var 
   if dialogId == 1405 and listboxId == 5 and button == 1 then
      if input:find("Войти в свой мир") then
         isWorldHoster = true
         worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
      else
         lastWorldNumber = 0
         lastWorldName = ""
         isWorldHoster = false
      end
   end
    
   -- Get current world number from server dialogs
   if dialogId == 1426 and listboxId == 65535 and button == 1 then
      if tonumber(input) then
         if tonumber(input) > 0 and tonumber(input) < 500 then
            lastWorldNumber = tonumber(input)
            worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
         end
      end
   end
   
   if dialogId == 1406 and button == 1 then
      local world = tonumber(string.sub(input, 0, 3))
      if world then
         lastWorldNumber = world
         local rawworldname = string.match(input, "- (.+) ")
         lastWorldName = string.gsub(rawworldname, "-", " ")
         worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
      end
   end
   
   if dialogId == 1412 and listboxId == 2 and button == 1 then
      sampAddChatMessage("Вы изменили разрешение на редактирование мира для всех игроков!", 0xFF0000)
   end
   
   if dialogId == 1419 and button == 1 then
      worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
   end
   
   if dialogId == 1429 and button == 1 then
      local startpos = input:find("№")
      local endpos = startpos + 3
      local world = tonumber(string.sub(input, startpos+1, endpos))
      local rawname = string.sub(input, startpos+4, string.len(input))
      if world then
         lastWorldNumber = world
         lastWorldName = rawname
         worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
      end
   end
   
   -- hook editmodes
   if dialogId == 1400 and button == 1 then
      if listboxId == 0 and input:find("Редактировать") then editMode = 1 end
      if listboxId == 2 and input:find("Переместить") then editMode = 1 end
      if listboxId == 4 and input:find("Перекрасить") then editMode = 4 end
      if listboxId == 5 and input:find("Копировать") then editMode = 2 end
      if listboxId == 17 and input:find("Информация") then editMode = 1 end
   end 
   
   if dialogId == 1422 and listboxId == 0 and button == 1 then
      editMode = 1
   end
   
   if dialogId == 1403 and button == 1 then
      if listboxId == 0 then editMode = 1 end
      if listboxId == 1 then 
         editMode = 3
         if lastObjectModelId then
            lastRemovedObjectModel = lastObjectModelId
         end
      end
      if listboxId == 2 then editMode = 4 end
      if listboxId == 4 then editMode = 2 end
   end
   if dialogId == 1411 and button == 1 then
      if listboxId == 0 or listboxId == 2 then
         editMode = 3
         if lastObjectModelId then
            lastRemovedObjectModel = lastObjectModelId
         end
      end
   end
   if dialogId == 1409 and button == 1 then
      editMode = 1
   end
   
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
   if ini.settings.dialogfix then
      dialogIncoming = dialogId
   end
   
   if dialogId == 1496 then
      randomcolor = string.sub(text, string.len(text)-6, #text-1)
	  setClipboardText(randomcolor)
   end

   if dialogId == 43 then
      randomcolor = string.sub(text, string.len(text)-36, #text-30)
	  setClipboardText(randomcolor)
   end
   
   if ini.settings.dialogfix then
      -- hide buy a house dialog 
      if dialogId == 118 then
	     sampSendDialogResponse(118, 0, 1)
		 sampCloseCurrentDialogWithButton(0)
         return false
      end
      
      -- hide aftercrash dialog
      if dialogId == 931 then
         sampSendDialogResponse(931, 0, 1)
         sampCloseCurrentDialogWithButton(0)
         return false
      end
   end
   
   -- hide change nickname dialog after login with non-RP nickname
   if isAbsoluteRoleplay and ini.settings.dialogfix then
      if dialogId == 20153 then
         sampSendDialogResponse(20153, 0, 1)
         sampCloseCurrentDialogWithButton(0)
         return false
      end
   end
   
   -- Hide clan dialog
   -- if not isAbsoluteRoleplay and ini.settings.dialogfix then
      -- if dialogId == 50 then
         -- sampSendDialogResponse(50, 0, 1)
         -- sampCloseCurrentDialogWithButton(0)
         -- return false
      -- end
   -- end
   
   if dialogId == 14 then
      local newtext = 
      "Оружие при появлении\t\n"..
      "Цвет\t\n"..
      "Регенерация здоровья\t\n"..
      "Ремонт авто 'На ходу'\t\n"..
      "Слежка за игроком\t\n"..
      "Заказ транспорта\t\n"..
      "Регенерация брони\t\n"..
      "Прикрепление транспорта\t\n"..
      "Улучшение Дома - Бизнеса\t\n"..
      "Бесконечный бег\t"..(ini.settings.infinityrun and '{00FF00}(Включено)' or '{555555}Отключено').."{00FF00}\n"..
      "Стрельба с JetPack\t{555555}(SA-MP Addon не установлен){00FF00}\n"..
      "Уровень бизнеса\t\n"..
      "Улучшенный бег\t"..(ini.settings.improvedrun and '{00FF00}(Включено)' or '{555555}Отключено').."{00FF00}\n"..
      "Вождение 2-х колёсного транспорта\t"..(ini.settings.improvedbike and '{00FF00}(Включено)' or '{555555}Отключено').."{00FF00}\n"..
      "Вождение воздушного транспорта\t"..(ini.settings.improvedairvehheight and '{00FF00}(Включено)' or '{555555}Отключено').."{00FF00}\n"..
      "Улучшенный JetPack\t"..(ini.settings.improvedjetpack and '{00FF00}(Включено)' or '{555555}Отключено').."{00FF00}\n"
      return {dialogId, 4, title, button1, button2, newtext}
   end
   
   if dialogId == 24 then 
      return {dialogId, style, title, button1, button2, text.."\nДля того чтобы быстро отцепить транспорт войди в наблюдение (/набл 0)"}
   end
   
   -- if dialogId == 1700 then
      -- local newtext = "Интерфейс\nЦвет интерфейса\nЗвук\nГрафика\nInternet радио\nЧат\nАккаунт\nДругое"
      -- return {dialogId, style, title, button1, button2, newtext}
   -- end
   
   if dialogId == 1770 then
      local newtext = 
      "Эффект SpeedBlur\t"..(ini.settings.speedblur and '{00FF00}[Включен]' or '{FFFF00}[Отключен]').."\n"..
      "Тени мира\t"..(ini.settings.shadows and '{00FF00}[Включены]' or '{FFFF00}[Отключены]').."\n"..
      "Эффект солнца\t"..(ini.settings.sunfix and '{00FF00}[Включен]' or '{FFFF00}[Отключены]').."\n"..
      "Трава\t"..(ini.settings.grass and '{00FF00}[Включена]' or '{FFFF00}[Отключена]').."\n"
      return {dialogId, style, title, button1, button2, newtext}
   end
   
   if dialogId == 1400 and title:find("Управление мира") then
      isWorldHoster = true
   end
   
   if dialogId == 1407 then
      local newtext = 
      "{FFFFFF}Внутриигровой редактор карт позволяет любому игроку создать уникальный мир.\n"..
      "Каждый игрок от 20 уровня может создать свой мир, или редактировать открытый мир.\n"..
      "По умолчанию в мире можно строить только 50 объектов, и расширить до 300 объектов.\n"..
      "Любого игрока можно пригласить в открытый мир, или позволить ему редактировать ваш мир.\n"..
      "В радиусе 150 метров нельзя создавать более 200 объектов.\n"..
      "\nВозможности редактора карт:\n"..
      "- Удобное меню редактора на диалогах. Вам не нужно запоминать десятки команд для управления, все доступно через единое меню.\n"..
      "- Визуальный выбор объектов в меню. Вы видите объекты через предпросмотр, вам не нужно искать номера объектов на сторонних ресурсах.\n".. 
      "- Создание пикапов. Создавайте пикапы оружия, здоровья, брони и другие предметы. Включая выпадение пикапов после убийства противника.\n"..
      "- Оружие и здоровье по умолчанию. Настройка изначальных характеристик, с которыми игрок войдёт в редактор карт.\n"..
      "- Создание транспорта. Создавайте любой транспорт в мире, включая уникальный и военную технику.\n"..
      "- Создание гонок. Использование разных машин, мотоциклов, лодок и воздушной техники для проведения соревнований с возможностью выбора маршрутов.\n"..
      "- Возможность совместного редактирования. Приглашайте друзей на помощь.\n"..
      "- Организаторские опции управления. Возможность гибкой настройки параметров мира для проведения различного рода мероприятий.\n"..
      "- Управление камерой. Вы можете работать в режиме полета свободной камерой, либо зафиксировать камеру над собой.\n"..
      "- Смена текстур. Применяйте ретекстур к различным объектам чтобы преобразить их до неузнаваемости.\n"..
      "- Настройка доступа. Ваш мир может быть открыт для всех игроков 24/7. Либо же вы можете задать пароль на вход, или вовсе сделать мир персональным.\n"..
      "\n{FFD700}VIP игроки{FFFFFF} могут:\n"..
      "- телепортироваться по метке на карте в ESC\n"..
      "- расширять мир до 2000 объектов\n"..
      "- выбирать шрифт и цвет текста\n"..
      "- выбирать точку появления в мире\n"
     
      sampAddChatMessage("Подробнее на https://forum.sa-mp.ru/index.php?/topic/1016832-миры-описание-работы-редактора-карт", -1)
      return {dialogId, style, title, button1, button2, newtext}
   end
   
   if dialogId == 1498 then
      return {dialogId, style, title, button1, button2,
      "Введи размер шрифта от 1 до 255"}
   end
   
   if dialogId == 1401 then

      
      local newtext = 
      "{FFD700}615-18300       {FFFFFF}GTA-SA \n{FFD700}18632-19521{FFFFFF}   SA-MP\n"..
      (lastObjectModelId and "\n{FFFFFF}Последний {FFFF00}использованный объект: "..lastObjectModelId.." ("..tostring(sampObjectModelNames[lastObjectModelId])..") " or " ")..
      (lastRemovedObjectModel and "\n{FFFFFF}Последний {FF0000}удаленный объект: "..lastRemovedObjectModel.." ("..tostring(sampObjectModelNames[lastRemovedObjectModel])..") " or " ")..
      "\n{FFFFFF}Введи номер объекта: \n"
      return {dialogId, style, title, button1, button2, newtext}
   end
   
   if dialogId == 1410 then
      return {dialogId, style, title, button1, button2, 
      "Выбери радиус в котором необходимо удалить объекты (Рекомендуется не больше 50)"}
   end
   
   if dialogId == 1413 then
      local newtext = 
      "Для создания мира необходимо:\n"..
      "20 LvL, $1.000.000, 100 ОА\n\n"..
      "Ты уверен что хочешь создать мир для строительства?\n"
      return {dialogId, style, title, button1, button2, newtext}
   end
   
   if dialogId == 1414 then
      return {dialogId, style, title, button1, button2, 
      "{FF0000}Это действие необратимо!!!\nТы уверен что хочешь удалить мир?"}
   end
   
   if dialogId == 1426 then
      if lastWorldNumber and lastWorldNumber > 0 then
         local newtext = 
         "Если вы хотите попробовать редактор карт\n"..
         "Посетите мир 10, он всегда открыт для редактирования\n\n"..
         "Последний мир в котором вы были: "..lastWorldNumber.."\n"..
         "Введите номер мира в который хотите войти:\n"
         return {dialogId, style, title, button1, button2, newtext}
      else
         local newtext = 
         "Если вы хотите попробовать редактор карт\n"..
         "Посетите мир 10, он всегда открыт для редактирования\n\n"..
         "Введите номер мира в который хотите войти:\n"
         return {dialogId, style, title, button1, button2, newtext}
      end
   end
end

function sampev.onSendClickPlayer(playerId, source)
   clickedplayerid = playerId
end

function sampev.onCreateObject(objectId, data)
   -- Fix Crash the game when creating a crane object 1382
   if data.modelId == 1382 then return false end
   
   -- Disable snowflakes
   if ini.settings.snowoff then
      if data.modelId == 18864 or data.modelId == 18863 then
         return false
      end
   end
end

function sampev.onSendCommand(command)
   
   if command:find("/exit") or command:find("/выход") then
      isWorldHoster = false
   end
   
   if isAbsolutePlay and command:find("/spec") then
	  if not isPlayerSpectating then 
	     -- if chosenplayer and sampIsPlayerConnected(chosenplayer) then
	        -- sampSendChat("/набл "..chosenplayer)
	     -- else
	        if getClosestPlayerId() ~= -1 then
	           sampSendChat("/набл "..getClosestPlayerId())
	        else
	  	       sampSendChat("/полет")
	        end
	     --end
      end
   end
   
   if command:find("/vbh") or command:find("/мир") then
      if command:find('(.+) (.+)') then
         local cmd, arg = command:match('(.+) (.+)')
         local id = tonumber(arg)
         if id then 
            if id > 0 and id <= 500 then 
               LastData.lastWorldNumber = id
               worldspawnpos.x, worldspawnpos.y, worldspawnpos.z = getCharCoordinates(playerPed)
            end
         end
      end
   end
   
   -- teleport fix
   if command:find("/тпк") or command:find("/ngr") then
      if not command:find('(.+) (.+)') then
         local bTargetResult, bX, bY, bZ = getTargetBlipCoordinates()
         if bTargetResult then
            sampSendChat(string.format("/ngr %.2f %.2f %.2f", bX, bY, bZ+1.5))
         end
      end
   end
   
   if command:find("/nologo$") then
      -- remove server logo
	  sampAddChatMessage("Логотипы сервера были удалены (Чтобы появились снова потребуется релог)", 0x00FF00)
      sampTextdrawDelete(2048)
      sampTextdrawDelete(420)
      return false
   end
end

function sampev.onSendEditObject(playerObject, objectId, response, position, rotation)
   lastObjectId = objectId
   local object = sampGetObjectHandleBySampId(objectId)
   local modelId = getObjectModel(object)
   
   editResponse = response
   
   if response > 0 then
      if hideEditObject then
	     setObjectVisible(object, false)
      else
	     setObjectVisible(object, true)
	  end
	  
	  if scaleEditObject then
	     setObjectScale(object, 1.35)
	  else
	     setObjectScale(object, 1.0)
	  end
   else 
      setObjectVisible(object, true)
	  setObjectScale(object, 1.0)
   end
end
 
function sampev.onRemoveBuilding(modelId, position, radius)
   if ini.settings.restoreremovedobjects then
	  return false
   else 
      for key, value in ipairs(restored_objects) do
         if modelId == value then 
            return false
         end
      end   
   end
end
-- END hooks

function onSendRpc(id, bs, priority, reliability, channel, shiftTimestamp)
   -- Fix ClickMap height detection when setting a placemark on the game map
   if id == 119 then
      local posX, posY, posZ = raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs)
      requestCollision(posX, posY)
      loadScene(posX, posY, posZ)
      local res, x, y, z = getTargetBlipCoordinates()
      if res then
           local new_bs = raknetNewBitStream()
           raknetBitStreamWriteFloat(new_bs, x)
           raknetBitStreamWriteFloat(new_bs, y)
           raknetBitStreamWriteFloat(new_bs, z + 0.5)
        raknetSendRpcEx(119, new_bs, priority, reliability, channel, shiftTimestamp)
        raknetDeleteBitStream(new_bs)
      end
      return false
   end
end