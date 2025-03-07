script_dependencies('imgui')
-- TEmplate: imgui window default widgets
-- script_moonloader(16) moonloader v.0.26
-- activation: /activate
local imgui = require 'imgui'

-- widgets
local v = nil

local dialog = {
   main = imgui.ImBool(false),
}
   
local checkbox = {
   democheckbox = imgui.ImBool(false),
}

local input = {
   demoinput = imgui.ImInt(5000),
}

local slider = {
   demoslider = imgui.ImInt(1),
}

local textbuffer = {
   demobuffer = imgui.ImBuffer(32),
}

local combobox = {
   democombo = imgui.ImInt(0),
}

local democomboboxlist = {"combo1", "combo2", "combo3"}

function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   while not isSampAvailable() do wait(100) end
   -- Change default activation command here
   sampRegisterChatCommand("activate", toggledialog)

   while true do
      imgui.Process = dialog.main.v
      
      -- Hide dialog on ESC
      if isKeyJustPressed(0x1B) and not sampIsChatInputActive() 
      and not sampIsDialogActive() and not isPauseMenuActive() 
      and not isSampfuncsConsoleActive() then 
         if dialog.main.v then dialog.main.v = false end
      end 
      
      wait(0)
   end
end

function imgui.OnDrawFrame()
      
   local sizeX, sizeY = getScreenResolution()
   
   if dialog.main.v then
      imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
      imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      imgui.Begin('Main', dialog.main)

      imgui.Text("Example imgui window")
      imgui.TextColoredRGB("{FF0000}R{008000}G{0000FF}B {FFFFF}Text")
      if imgui.Checkbox("demo checkbox", checkbox.democheckbox) then
         if checkbox.democheckbox.v then
            print("checkbox activated")
         end
      end
      
      if imgui.Combo('##democombobox', combobox.democombo, democomboboxlist) then
         print("input value changed to:"..tostring(combobox.democombo.v))
      end
      
      if imgui.InputInt('##demoinput', input.demoinput, 0) then
         print("input value changed to:"..tostring(input.demoinput.v))
      end
      
      if imgui.SliderInt("##demoslider", slider.demoslider, 1, 100) then
         print("slider value changed to:"..tostring(slider.demoslider.v))
      end
      
      imgui.InputTextMultiline('##demobuffer', textbuffer.demobuffer, imgui.ImVec2(100, 50))
      
      imgui.Spacing()
      imgui.End()
   end
end

function toggledialog()
   dialog.main.v = not dialog.main.v
end

-- imgui widgets
function explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
end

-- imgui fuctions
function imgui.ToggleButton(str_id, bool)
   -- this function is not same imgui_addons lib ToggleButton
   local rBool = false

   if LastActiveTime == nil then
      LastActiveTime = {}
   end
   if LastActive == nil then
      LastActive = {}
   end

   local function ImSaturate(f)
      return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
   end
 
   local p = imgui.GetCursorScreenPos()
   local draw_list = imgui.GetWindowDrawList()

   local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
   local width = height * 1.55
   local radius = height * 0.50
   local ANIM_SPEED = 0.15

   if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
      bool.v = not bool.v
      rBool = true
      LastActiveTime[tostring(str_id)] = os.clock()
      LastActive[str_id] = true
   end

   local t = bool.v and 1.0 or 0.0

   if LastActive[str_id] then
      local time = os.clock() - LastActiveTime[tostring(str_id)]
      if time <= ANIM_SPEED then
         local t_anim = ImSaturate(time / ANIM_SPEED)
         t = bool.v and t_anim or 1.0 - t_anim
      else
         LastActive[str_id] = false
      end
   end

   local col_bg
   if imgui.IsItemHovered() then
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
   else
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
   end

   draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
   draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))
   
   imgui.SameLine()
   imgui.AlignTextToFramePadding()
   imgui.Text(tostring(str_id))
   
   return rBool
end

function imgui.TextColoredRGB(text)
   local style = imgui.GetStyle()
   local colors = style.Colors
   local ImVec4 = imgui.ImVec4

   local getcolor = function(color)
      if color:sub(1, 6):upper() == 'SSSSSS' then
         local r, g, b = colors[1].x, colors[1].y, colors[1].z
         local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
         return ImVec4(r, g, b, a / 255)
      end
      local color = type(color) == 'string' and tonumber(color, 16) or color
      if type(color) ~= 'number' then return end
      local r, g, b, a = explode_argb(color)
      return imgui.ImColor(r, g, b, a):GetVec4()
   end

   local render_text = function(text_)
      for w in text_:gmatch('[^\r\n]+') do
         local text, colors_, m = {}, {}, 1
         w = w:gsub('{(......)}', '{%1FF}')
         while w:find('{........}') do
            local n, k = w:find('{........}')
            local color = getcolor(w:sub(n + 1, k - 1))
            if color then
               text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
               colors_[#colors_ + 1] = color
               m = n
            end
            w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
         end
         if text[0] then
            for i = 0, #text do
               imgui.TextColored(colors_[i] or colors[1], text[i])
               imgui.SameLine(nil, 0)
            end
            imgui.NewLine()
         else imgui.Text(w) end
      end
   end

   render_text(text)
end

function imgui.TooltipButton(label, size, description)
   local result = imgui.Button(label, size, description)
   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(600)
      imgui.TextUnformatted(description)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
   return result
end

function imgui.Link(link, text)
   text = text or link
   local tSize = imgui.CalcTextSize(text)
   local p = imgui.GetCursorScreenPos()
   local DL = imgui.GetWindowDrawList()
   local col = { 0xFFFF7700, 0xFFFF9900 }
   if imgui.InvisibleButton("##" .. link, tSize) then os.execute('explorer "' .. link ..'"') end
   local color = imgui.IsItemHovered() and col[1] or col[2]
   DL:AddText(p, color, text)
   DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)

   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(500)
      imgui.TextUnformatted(link)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
end

function imgui.TextNotify(label, description)
   imgui.TextColoredRGB(label)
   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
         imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
         imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
end

function imgui.TextQuestion(label, description)
   imgui.TextDisabled(label)
   if imgui.IsItemHovered() then
      imgui.BeginTooltip()
         imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
         imgui.PopTextWrapPos()
      imgui.EndTooltip()
   end
end

function imgui.resetIO()
   -- Bug fix with focus in inputText (imgui)
   for i = 1, 512 do
      imgui:GetIO().KeysDown[i] = false
   end
   for i = 1, 5 do
      imgui:GetIO().MouseDown[i] = false
   end
   imgui:GetIO().KeyCtrl = false
   imgui:GetIO().KeyShift = false
   imgui:GetIO().KeyAlt = false
   imgui:GetIO().KeySuper = false
end