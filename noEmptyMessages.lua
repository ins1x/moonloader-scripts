script_name("noEmptyMessages")
script_description("Ignores sending and receiving empty chat messages")
script_url("https://github.com/ins1x/moonloader-scripts")
script_author("1NS")
-- moonloader 0.26+
-- Specially for TRAINING Server

function onSendRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
   if id == 101 then -- ChatMessage (Outcoming)
   -- Parameters: UINT8 length, char[] ChatMessage
      local length = raknetBitStreamReadInt8(bitStream)
      local message = raknetBitStreamReadString(bitStream, length)
      if message:match("^  *$") then
         return false
      end
   end
   
   if id == 93 then -- SendClientMessage (Incoming)
   -- Parameters: UINT32 dColor, UINT32 dMessageLength, char[] Message
      local color = raknetBitStreamReadInt32(bitStream)
      local length = raknetBitStreamReadInt32(bitStream)
      local message = raknetBitStreamReadString(bitStream, length)
      if message:match("^ *$") or message:match("^%s%s*$") then
         return false
      end
   end
end