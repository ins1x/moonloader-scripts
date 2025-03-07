script_dependencies('imgui')
-- Template: imgui color theme
local imgui = require 'imgui'

-- color theme
function applyCustomStyle()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2
   
   style.WindowPadding = imgui.ImVec2(8, 8)
   style.WindowRounding = 6
   style.ChildWindowRounding = 5
   style.FramePadding = imgui.ImVec2(5, 3)
   style.FrameRounding = 3.0
   style.ItemSpacing = imgui.ImVec2(5, 4)
   style.ItemInnerSpacing = imgui.ImVec2(4, 4)
   style.IndentSpacing = 21
   style.ScrollbarSize = 10.0
   style.ScrollbarRounding = 13
   style.GrabMinSize = 8
   style.GrabRounding = 1
   style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
   style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
   
   colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
   colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
   colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
   colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
   colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
   colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
   colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
   colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
   colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
   colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
   colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
   colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
   colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
   colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
   colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
   colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
   colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
   colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
   colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
   colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
   colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
   colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
   colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
   colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

applyCustomStyle()