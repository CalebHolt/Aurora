local _, private = ...
if private.shouldSkip() then return end

--[[ Lua Globals ]]
-- luacheck: globals select

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

do --[[ FrameXML\ColorPickerFrame.lua ]]
    function Hook.ColorPickerFrame_UpdateDisplay(self)
        if self.hasOpacity then
            self:SetWidth(365)
        else
            self:SetWidth(309)
        end
    end
end

do --[[ FrameXML\ColorPickerFrame.xml ]]
    function Skin.OpacitySlider(Slider)
        Base.SetBackdrop(Slider, Color.frame)
        Slider:SetBackdropBorderColor(Color.button)
        Slider:SetBackdropOption("offsets", {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5,
        })

        local thumbTexture = Slider:GetThumbTexture()
        thumbTexture:SetAlpha(0)
        thumbTexture:SetSize(16, 8)

        local thumb = _G.CreateFrame("Frame", nil, Slider)
        thumb:SetPoint("TOPLEFT", thumbTexture, 0, 0)
        thumb:SetPoint("BOTTOMRIGHT", thumbTexture, 0, 0)
        Base.SetBackdrop(thumb, Color.button)
        Slider._auroraThumb = thumb
    end
end

function private.FrameXML.ColorPickerFrame()
    local ColorPickerFrame = _G.ColorPickerFrame
    _G.hooksecurefunc(ColorPickerFrame, "SetColorRGB", Hook.ColorPickerFrame_UpdateDisplay)
    ColorPickerFrame:HookScript("OnShow", Hook.ColorPickerFrame_UpdateDisplay)
    ColorPickerFrame:SetPropagateKeyboardInput(true)

    Skin.DialogBorderTemplate(ColorPickerFrame.Border)
    local bg = ColorPickerFrame.Border:GetBackdropTexture("bg")

    Skin.DialogHeaderTemplate(ColorPickerFrame.Header)

    Skin.GameMenuButtonTemplate(_G.ColorPickerCancelButton)
    Skin.GameMenuButtonTemplate(_G.ColorPickerOkayButton)
    Util.PositionRelative("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -5, 5, 1, "Left", {
        _G.ColorPickerCancelButton,
        _G.ColorPickerOkayButton,
    })

    Skin.OpacitySlider(_G.OpacitySliderFrame)

    ------------------
    -- OpacityFrame --
    ------------------
    Skin.DialogBorderTemplate(_G.OpacityFrame.Border)
    Skin.OpacitySlider(_G.OpacityFrameSlider)
end
