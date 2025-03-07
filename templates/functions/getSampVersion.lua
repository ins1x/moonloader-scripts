function getSampVersionId()
   local versionid = 0
   sampdllHandle = getModuleHandle('samp.dll')
   sampdllHandle = sampdllHandle + 0x128
   versionData = readMemory(sampdllHandle, 4, true)
   if versionData == 0x5542F47A then
      versionid = 1 -- r1
   end
   if versionData == 0x59C30C94 then
      versionid = 2 -- r2
   end

   sampdllHandle = sampdllHandle - 8
   versionData = readMemory(sampdllHandle, 4, true)
   if versionData == 0x5C0B4243 then
      versionid = 3 -- r3
   end
   if versionData == 0x5DD606CD then
      versionid = 4 -- R4
   end
   -- if versionData == 0x6094ACAB then
       -- versionid = 42 -- R4-2
   -- end
   if versionData == 0x6372C39E then
      versionid = 5 --R5
   end
   return versionid
end