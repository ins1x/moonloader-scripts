script_author("1NS")
script_name("header")
script_description("Hader template")
--script_dependencies('imgui', 'lib.samp.events')
script_properties("work-in-pause")
script_url("https://github.com/ins1x/moonloader-scripts")
script_version("0.1")

-- support sa-mp versions depends on SAMPFUNCS (0.3.7-R1, 0.3.7-R3-1, 0.3.7-R5, 0.3.DL)
-- script_moonloader(16) moonloader v.0.26 
-- editor options: tabsize 3, Unix (LF), encoding Windows-1251
-- in-game activaton: <HOTKEY> or command /cmd

-- encoding
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
