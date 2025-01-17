local _, private = ...
if private.shouldSkip() then return end

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Hook = Aurora.Hook

function private.FrameXML.UIOptions()
    _G.hooksecurefunc("VideoOptionsDropDownMenu_AddButton", Hook.UIDropDownMenu_AddButton)
    _G.hooksecurefunc("VideoOptionsDropDownMenu_DisableDropDown", Hook.UIDropDownMenu_DisableDropDown)
    _G.hooksecurefunc("VideoOptionsDropDownMenu_EnableDropDown", Hook.UIDropDownMenu_EnableDropDown)
end
