script_name("training-autologin")
script_description("TRAINING-SANDBOX autologin")
script_authors("xWivar", "1NS")
script_dependencies('lib.samp.events')
script_url("https://forum.training-server.com/d/17909-lua-autologin-v1")
script_version_number(4)
script_version("4.1")
-- Require CLEO 4.0+, SAMPFUNCS 5.4.0+, Moonloader 0.26+ (lib SAMP.Lua)
-- editor options: tabsize 3, Windows (CR LF), encoding Windows-1251

local ev = require 'lib.samp.events'
local ini = require 'inicfg'
local cfg = ini.load({Hashtable = {}}, "training-autologin")
local ffi = require("ffi")
ffi.cdef[[
int __stdcall GetVolumeInformationA(
    const char* lpRootPathName,
    char* lpVolumeNameBuffer,
    uint32_t nVolumeNameSize,
    uint32_t* lpVolumeSerialNumber,
    uint32_t* lpMaximumComponentLength,
    uint32_t* lpFileSystemFlags,
    char* lpFileSystemNameBuffer,
    uint32_t nFileSystemNameSize
);
]]
local eax = nil
local ebx = ffi.new("unsigned long[1]", 0)
ffi.C.GetVolumeInformationA(eax, eax, 0, ebx, eax, eax, eax, 0)
local ecx = ebx[0]
-- Flag to intercept the input dialog
local hookdialogpassw = false
local skiprulesdialog = true

function main()
   sampRegisterChatCommand("newpass", function(arg)
      sampSendChat("/newpass "..arg)
      if 6 <= #arg and #arg <= 24 then 
         local _, id = sampGetPlayerIdByCharHandle(playerPed)      
         local nickname = sampGetPlayerNickname(id)
         cfg.Hashtable[nickname] = toHash(("%s%s"):format(tostring(arg), ecx))
         ini.save(cfg, "training-autologin") 
      end
   end)
end

function ev.onPlayerJoin(playerid, color, isNpc, nickname)
   hookdialogpassw = false
end

function ev.onShowDialog(dialogId, style, title, button1, button2, text)
   if dialogId == 32700 then
      -- Hook login dialog
      if text:find('Вы подключились к') and button1 == 'Войти' and button2 == 'Уйти' then
         local _, id = sampGetPlayerIdByCharHandle(playerPed)      
         local nickname = sampGetPlayerNickname(id)
         
         if cfg.Hashtable[nickname] ~= nil then
            local hash = fromHash(cfg.Hashtable[nickname])
            local val = hash:gsub(tostring(ecx),"")
            sampSendDialogResponse(dialogId, 1, nil, val)
            return false
         else
            hookdialogpassw = true
         end
      end
   
      if skiprulesdialog then 
         if text:find('1. Общие правила') and style == 0 and button1 == "Принимаю" then
            sampSendDialogResponse(32700, 1, nil)
            sampCloseCurrentDialogWithButton(1)
         end
      end
   end
end

function ev.onSendDialogResponse(dialogId, button, listboxId, input)
   -- Hook login dialog
   if dialogId == 32700 and button == 1 and hookdialogpassw then
      local _, id = sampGetPlayerIdByCharHandle(playerPed)
      local nickname = sampGetPlayerNickname(id)
      hookdialogpassw = false
      cfg.Hashtable[nickname] = toHash(("%s%s"):format(input, ecx))
      ini.save(cfg, "training-autologin")      
   end
end


function ev.onServerMessage(color, text)
   -- If the password is entered incorrectly, the auto-complete field will be reset
   if text:find("Неверно введен пароль! .+1/3") and color == -872414977 then
      local _, id = sampGetPlayerIdByCharHandle(playerPed)
      local nickname = sampGetPlayerNickname(id)
      hookdialogpassw = true
      cfg.Hashtable[nickname] = nil
   end
end

function toHash(data)
   local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
   return ((data:gsub('.', function(x) 
      local r,b='',x:byte()
      for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
      return r;
   end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
      if (#x < 6) then return '' end
      local c=0
      for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
      return b:sub(c+1,c+1)
   end)..({ '', '==', '=' })[#data%3+1])
end
 
function fromHash(data)
   local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
   data = string.gsub(data, '[^'..b..'=]', '')
   return (data:gsub('.', function(x)
      if (x == '=') then return '' end
      local r,f='',(b:find(x)-1)
      for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
      return r;
   end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
      if (#x ~= 8) then return '' end
      local c=0
      for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
      return string.char(c)
   end))
end