local _, private = ...
if private.shouldSkip() then return end

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Skin = Aurora.Skin
local Util = Aurora.Util

--[[ do AddOns\Blizzard_BindingUI.lua
end ]]

do --[[ AddOns\Blizzard_BindingUI.xml ]]
    function Skin.KeyBindingFrameBindingButtonTemplate(Button)
        Skin.UIMenuButtonStretchTemplate(Button)
    end
    function Skin.KeyBindingFrameBindingTemplate(Frame)
        Skin.KeyBindingFrameBindingButtonTemplate(Frame.Button1)
        Skin.KeyBindingFrameBindingButtonTemplate(Frame.Button2)
    end
end

function private.AddOns.Blizzard_BindingUI()
    ---------------------
    -- KeyBindingFrame --
    ---------------------
    local KeyBindingFrame = _G.KeyBindingFrame
    Skin.DialogBorderTemplate(KeyBindingFrame.BG)
    Skin.DialogHeaderTemplate(KeyBindingFrame.Header)

    Skin.UICheckButtonTemplate(KeyBindingFrame.characterSpecificButton)
    Skin.OptionsFrameListTemplate(KeyBindingFrame.categoryList)

    Skin.UIPanelButtonTemplate(KeyBindingFrame.defaultsButton)
    KeyBindingFrame.defaultsButton:SetPoint("BOTTOMLEFT", 15, 15)

    Skin.TooltipBorderBackdropTemplate(KeyBindingFrame.bindingsContainer)

    Skin.UIPanelButtonTemplate(KeyBindingFrame.cancelButton)
    Skin.UIPanelButtonTemplate(KeyBindingFrame.okayButton)
    Skin.UIPanelButtonTemplate(KeyBindingFrame.unbindButton)
    Skin.UIPanelButtonTemplate(KeyBindingFrame.clickCastingButton)
    Skin.UIPanelButtonTemplate(KeyBindingFrame.quickKeybindButton)
    Util.PositionRelative("BOTTOMRIGHT", KeyBindingFrame, "BOTTOMRIGHT", -15, 15, 5, "Left", {
        KeyBindingFrame.cancelButton,
        KeyBindingFrame.okayButton,
        KeyBindingFrame.unbindButton
    })


    Skin.FauxScrollFrameTemplate(KeyBindingFrame.scrollFrame)
    KeyBindingFrame.scrollFrame.scrollBorderTop:Hide()
    KeyBindingFrame.scrollFrame.scrollBorderBottom:Hide()
    KeyBindingFrame.scrollFrame.scrollBorderMiddle:Hide()
    KeyBindingFrame.scrollFrame.scrollFrameScrollBarBackground:Hide()


    for i = 1, _G.KEY_BINDINGS_DISPLAYED do
        Skin.KeyBindingFrameBindingTemplate(KeyBindingFrame.keyBindingRows[i])
    end


    -----------------------
    -- QuickKeybindFrame --
    -----------------------
    local QuickKeybindFrame = _G.QuickKeybindFrame
    Skin.DialogBorderTemplate(QuickKeybindFrame.BG)
    Skin.DialogHeaderTemplate(QuickKeybindFrame.Header)
    Skin.UICheckButtonTemplate(QuickKeybindFrame.characterSpecificButton)
    Skin.UIPanelButtonTemplate(QuickKeybindFrame.defaultsButton)
    Skin.UIPanelButtonTemplate(QuickKeybindFrame.cancelButton)
    Skin.UIPanelButtonTemplate(QuickKeybindFrame.okayButton)
end
