script_name("cmd-parse")
script_description("Parse arguments for /example command")
script_dependencies('lib.samp.events')

local ev = require 'lib.samp.events'

function ev.onSendCommand(command)
   -- hook /example command
   if command:find("^/example") then
      if command:find('(/%a+) (.+)') then
         local cmd, arg = command:match('(/%a+) (.+)')
         local id = tonumber(arg)
         if type(id) == "number" then
            print(id)
         end
      end
   end
end