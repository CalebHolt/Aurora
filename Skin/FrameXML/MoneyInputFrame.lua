local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Skin = Aurora.Skin

--do --[[ FrameXML\MoneyInputFrame.lua ]]
--end

do --[[ FrameXML\MoneyInputFrame.xml ]]
    local money = {"gold", "silver", "copper"}
    function Skin.MoneyInputFrameTemplate(frame)
        for i = 1, #money do
            local EditBox = frame[money[i]]
            Skin.FrameTypeEditBox(EditBox)
            EditBox:SetBackdropOption("offsets", {
                left = -5,
                right = 15,
                top = 0,
                bottom = 0,
            })

            local name = EditBox:GetName()
            _G[name.."Left"]:Hide()
            _G[name.."Middle"]:Hide()
            _G[name.."Right"]:Hide()

            local bg = EditBox:GetBackdropTexture("bg")
            EditBox.texture:ClearAllPoints()
            EditBox.texture:SetPoint("LEFT", bg, "RIGHT", 2, 0)

            if i > 1 then
                EditBox:SetPoint("LEFT", frame[money[i - 1]], "RIGHT", 6, 0)
                EditBox:SetSize(35, 20)
            else
                EditBox:SetSize(70, 20)
            end
        end
    end
end

--function private.FrameXML.MoneyInputFrame()
--end
