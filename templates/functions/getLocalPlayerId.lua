function getLocalPlayerId()
   local _, id = sampGetPlayerIdByCharHandle(playerPed)
   return id
end