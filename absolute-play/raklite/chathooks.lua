require "addon"
local sampev = require("samp.events")
-- server: Absolute Play Test Host 185.71.66.21:7111
-- libs: samp events https://github.com/THE-FYP/SAMP.Lua/blob/master/samp/events.lua
-- script for raksamp lite https://github.com/YashasSamaga/RakSAMP
-- more info about raksamp lite API https://www.blast.hk/threads/108052/

function onLoad()
   print("Absolute Play chathooks Loaded")
   --setRate(RATE_LUA, 100)
end

function sampev.onServerMessage(color, text)
   -- ignore connect/disconnect messages
   if text:find("подключился к серверу") then
      return false
   end
   if text:find("вышел с сервера") then
      return false
   end
   
   -- ignore some server messages
   if text:find("Громкость музыки зависит от громкости радио") then
      return false
   end
end