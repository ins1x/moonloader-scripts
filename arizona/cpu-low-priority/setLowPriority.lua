script_name("setLowPriority")
script_description("Sets the gta_sa.exe process to low priority")
script_url("https://github.com/ins1x/moonloader-scripts")
-- Special thanks for Gorskin (https://www.blast.hk/members/157398/)
-- Description: Sets the gta_sa.exe process to "low" priority
-- Does it the same way you do it via --> Task Manager --> Set Priority.
local ffi = require("ffi")

ffi.cdef[[
    int GetPriorityClass(void* hProcess);
    int SetPriorityClass(void* hProcess, int dwPriorityClass);
    void* GetCurrentProcess();
]]

-- https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-setpriorityclass
-- ABOVE_NORMAL_PRIORITY_CLASS 0x00008000
-- BELOW_NORMAL_PRIORITY_CLASS 0x00004000
-- HIGH_PRIORITY_CLASS 0x00000080
-- IDLE_PRIORITY_CLASS 0x00000040
-- NORMAL_PRIORITY_CLASS 0x00000020
-- PROCESS_MODE_BACKGROUND_BEGIN 0x00100000
-- PROCESS_MODE_BACKGROUND_END 0x00200000
-- REALTIME_PRIORITY_CLASS 0x00000100

function setLowPriority()
   local processHandle = ffi.C.GetCurrentProcess()
   local originalPriorityClass = ffi.C.GetPriorityClass(processHandle)
   ffi.C.SetPriorityClass(processHandle, 0x00004000)
end

function main()
   setLowPriority()
end