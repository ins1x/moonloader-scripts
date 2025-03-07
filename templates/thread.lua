local threads = {
   demothread = nil,
}

local dealy = 1000

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      -- If you want terminate thread 
      -- if threads.demothread then
         -- threads.demothread:terminate()
         -- threads.demothread = nil
      -- else
         -- demothread(delay)
      -- end
      demothread(delay)
   end
end
               
function demoFunction(delay)
   lua_thread.create(function()
      wait(delay)
      print("demo thread triggered every "..delay.." ms.")
   end)
end