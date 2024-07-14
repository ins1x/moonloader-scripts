script_name("aalt")
script_author("1NS")
script_url("https://github.com/ins1x/moonloader-scripts")
script_description("On press Right ALT key, it repeats auto pressing Left ALT key")
-- Activation: Automatic. Press Right ALT key to enable or disable key repeating

local state = false
-- Change delay here. Some servers have their own delay, and the values 
-- you specify in the script may be ignored. (server-side cooldown)
local delay = 250

function main()
   while not isSampAvailable() do wait(50) end
   while true do
      wait(0)
      -- 0xA5 is Right ALT key
      if isKeyJustPressed(0xA5)
      and not sampIsChatInputActive() and not sampIsDialogActive()
      and not isPauseMenuActive() then 
         state = not state
         lua_thread.create(function()
            while state do
               wait(50)
               -- 0xA4 is Left ALT key
               setVirtualKeyDown(0xA4, true)
               wait(delay)
               setVirtualKeyDown(0xA4, false)
            end
         end)
      end
   end
end