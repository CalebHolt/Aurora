local _, private = ...
if private.shouldSkip() then return end

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

--do --[[ FrameXML\VoiceToggleButton.lua ]]
--end

do --[[ FrameXML\VoiceToggleButton.xml ]]
    function Skin.VoiceToggleButtonTemplate(Button)
        Skin.PropertyButtonTemplate(Button)

        Button:SetSize(23, 23)
        Button:ClearNormalTexture()
        Button:ClearPushedTexture()
        Button:ClearHighlightTexture()
        local disabled = Button:GetDisabledTexture()
        if disabled then
            disabled:SetColorTexture(0, 0, 0, .4)
            disabled:SetDrawLayer("OVERLAY")
            disabled:SetAllPoints()
        end

        Button.Icon:SetPoint("CENTER", 0, 1)

        Base.SetBackdrop(Button, Color.button, 0.3)
        Base.SetHighlight(Button)
    end
    function Skin.ToggleVoiceDeafenButtonTemplate(Button)
        Skin.VoiceToggleButtonTemplate(Button)
    end
    function Skin.ToggleVoiceMuteButtonTemplate(Button)
        Skin.VoiceToggleButtonTemplate(Button)
    end
end

--function private.FrameXML.VoiceToggleButton()
--end
