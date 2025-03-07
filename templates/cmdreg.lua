-- Template: command registration

function main()
   if not isSampfuncsLoaded() or not isSampLoaded() then return end
   while not isSampAvailable() do wait(100) end
   sampRegisterChatCommand('test', test)
   wait(-1)
end

function test(id)
   print(id)
end