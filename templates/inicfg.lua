-- inicfg
local inicfg = require 'inicfg'
local configIni = '$0'
local ini = inicfg.load(inicfg.load({
settings = {
   param = true
   },
}, configIni))
inicfg.save(ini, configIni)