-- Example main script

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   while true do
      wait(0)
      -- do something
   end
end