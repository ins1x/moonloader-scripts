script_name("autoprobiv")
script_description("Automatically ckeck stasts, time, id, F5 and more (Arizona)")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("1.0")

local sendChatMessages = true
local showSampfuncs = true

-- Read global rules on Arizona forum
-- https://forum.arizona-rp.com/threads/7682382/

function main()
   -- register command /autoprobiv 
   if not isSampfuncsLoaded() or not isSampLoaded() then return end
   while not isSampAvailable() do wait(100) end
   sampRegisterChatCommand('probiv', autoprobiv)
   wait(-1)
end

function autoprobiv(id)
   lua_thread.create(function()
   _, id = sampGetPlayerIdByCharHandle(playerPed)
   
   if sendChatMessages then
      sampAddChatMessage("Не нажимайте клавиши до окончания процесса, ожидаемое время выполнения пробива примерно секунд 20", -1)
      sampAddChatMessage("Порядок авто-пробива /time, /id, F5, TAB, /stats, /skills, /donate, /invent, /chatcmds, /threads", -1)
   end
   
   wait(2000)
   -- check server time 
   sampSendChat("/time")
   wait(100)
   -- check /id 
   sampSendChat("/id "..id.."")
   wait(1000)
   -- check TABMENU 
   setVirtualKeyDown(0x09, false)
   wait(2000)
   setVirtualKeyDown(0x09, false) 
   wait(500)
   -- check F5 network data
   setVirtualKeyDown(116, true) 
   wait(3100)
   setVirtualKeyDown(116, false)
   wait(600)
   -- check skills
   sampSendChat("/skill")
   wait(2000)
   sampSendChat("/stats")
   wait(2000)
   sendCloseDialogOnESC()
   wait(600)
   sampSendChat("/donate")
   wait(2000)
   sendCloseDialogOnESC()
   -- check inventory
   sampSendChat("/invent")
   wait(1500)
   
   -- NOTE: sampSendClickTextdraw not working after anti-bot server side updates
   -- TODO: show wepon modifications
   -- sampSendClickTextdraw(2073)
   -- wait(100)
   -- sampSendClickTextdraw(2071)
   -- wait(100) 
   
   -- sampfuncs
   if showSampfuncs then
   	  setVirtualKeyDown(0xC0, true)
      wait(10)
      setVirtualKeyDown(0xC0, false)
      wait(500)
      runSampfuncsConsoleCommand("chatcmds")
      wait(2000)
      runSampfuncsConsoleCommand("threads")
      wait(2000)
      sendCloseDialogOnESC()
   end
   sendCloseDialogOnESC()
   if sendChatMessages then
      sampAddChatMessage("Авто-пробив завершен. Не забудьте показать обвесы!!", -1)
   end
   
   end)
end

function sendCloseDialogOnESC()
  -- Send close dialog on ESC key
   setVirtualKeyDown(27, true)
   wait(10)
   setVirtualKeyDown(27, false) 
   wait(500)
end