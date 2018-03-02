local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next

--[[ Core ]]
local Aurora = private.Aurora
local Base, Scale = Aurora.Base, Aurora.Scale
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

--local OBJECTIVE_TRACKER_ITEM_WIDTH
--local OBJECTIVE_TRACKER_HEADER_HEIGHT
local OBJECTIVE_TRACKER_LINE_WIDTH
--local OBJECTIVE_TRACKER_HEADER_OFFSET_X
local OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT
local OBJECTIVE_TRACKER_DASH_WIDTH
local OBJECTIVE_TRACKER_TEXT_WIDTH

do --[[ AddOns\Blizzard_ObjectiveTracker.lua ]]
    ----====####$$$$%%%%%$$$$####====----
    -- Blizzard_ObjectiveTrackerShared --
    ----====####$$$$%%%%%$$$$####====----
    function Hook.QuestObjectiveItem_Initialize(itemButton, questLogIndex)
        if not itemButton._auroraSkinned then
            Skin.QuestObjectiveItemButtonTemplate(itemButton)
            itemButton._auroraSkinned = true
        end
    end
    function Hook.QuestObjectiveSetupBlockButton_AddRightButton(block, button, initialAnchorOffsets)
        if not button._auroraSkinned then
            Skin.QuestObjectiveFindGroupButtonTemplate(button)
            button._auroraSkinned = true
        end
    end

    ----====####$$$$$$$####====----
    -- Blizzard_ObjectiveTracker --
    ----====####$$$$$$$####====----
    local function SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
        fontString:SetHeight(0)
        fontString:SetText(text)
        local stringHeight = fontString:GetStringHeight()
        if ( stringHeight > OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT and not useFullHeight ) then
            Scale.RawSetHeight(fontString, OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT)
            stringHeight = OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT
        end
        return stringHeight
    end
    function Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_AddObjective(self, block, objectiveKey, text, lineType, useFullHeight, dashStyle, colorStyle, adjustForNoText)
        local line = block.lines[objectiveKey]
        if not line._auroraSkinned then
            local template = lineType and lineType.template or self.lineTemplate
            Skin[template](line)
            line._auroraSkinned = true
        end
        -- width
        if ( block.lineWidth ~= line.width ) then
            Scale.RawSetWidth(line.Text, block.lineWidth or self.lineWidth)
        end

        -- set the text
        local height = SetStringText(line.Text, text, useFullHeight, colorStyle, block.isHighlighted)
        if height == 0 then
            -- Not sure why this happens, but it messes up the position of progress bar lines
            return
        end
        Scale.RawSetHeight(line, height)

        local yOffset

        if ( adjustForNoText and text == "" ) then
            -- don't change the height
            -- move the line up so the next object ends up in the same position as if there had been no line
            yOffset = height
        else
            block._auroraHeight = block._auroraHeight + height + Scale.Value(block.module.lineSpacing)
            yOffset = Scale.Value(-block.module.lineSpacing)
        end
        -- anchor the line
        local point, anchor, relPoint = line:GetPoint()
        Scale.RawSetPoint(line, point, anchor, relPoint, 0, yOffset)
    end
    function Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_SetBlockHeader(self, block, text)
        block._auroraHeight = SetStringText(block.HeaderText, text, nil, _G.OBJECTIVE_TRACKER_COLOR["Header"], block.isHighlighted)
    end
    function Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_AddProgressBar(self, block, line, questID)
        local progressBar = self.usedProgressBars[block][line]
        block._auroraHeight = block._auroraHeight + progressBar.height + Scale.Value(block.module.lineSpacing)
    end

    function Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_GetBlock(self, id)
        local block = self.usedBlocks[id]
        if not block._auroraSkinned then
            if Skin[self.blockTemplate] then
                Skin[self.blockTemplate](block)
                block._auroraSkinned = true
            --else
                --print(self.blockTemplate)
            end
        end
        block._auroraHeight = 0
    end
    function Hook.ObjectiveTracker_Initialize(self)
        _G.hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_AddObjective)
        _G.hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "SetBlockHeader", Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_SetBlockHeader)
        _G.hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_AddProgressBar)
        _G.hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "GetBlock", Hook.DEFAULT_OBJECTIVE_TRACKER_MODULE_GetBlock)

        _G.hooksecurefunc(_G.QUEST_TRACKER_MODULE, "SetBlockHeader", Hook.QUEST_TRACKER_MODULE_SetBlockHeader)
        _G.hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", Hook.BONUS_OBJECTIVE_TRACKER_MODULE_AddProgressBar)
        _G.hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", Hook.BONUS_OBJECTIVE_TRACKER_MODULE_AddProgressBar)
        _G.hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "GetBlock", Hook.SCENARIO_TRACKER_MODULE_GetBlock)

        _G.hooksecurefunc(_G.QUEST_TRACKER_MODULE, "Update", Hook.QUEST_TRACKER_MODULE_Update)
        _G.hooksecurefunc(_G.ACHIEVEMENT_TRACKER_MODULE, "Update", Hook.ACHIEVEMENT_TRACKER_MODULE_Update)
        _G.hooksecurefunc(_G.AUTO_QUEST_POPUP_TRACKER_MODULE, "Update", Hook.AUTO_QUEST_POPUP_TRACKER_MODULE_Update)
        _G.hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "Update", Hook.BONUS_OBJECTIVE_TRACKER_MODULE_Update)
        _G.hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "Update", Hook.BONUS_OBJECTIVE_TRACKER_MODULE_Update)
        _G.hooksecurefunc(_G.SCENARIO_CONTENT_TRACKER_MODULE, "Update", Hook.SCENARIO_CONTENT_TRACKER_MODULE_Update)
    end
    function Hook.ObjectiveTracker_Collapse()
        local minimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
        local line, arrow = minimizeButton._auroraLine, minimizeButton._auroraArrow
        line:SetPoint("TOPLEFT", minimizeButton, "BOTTOMLEFT", 3, 4)
        line:SetPoint("BOTTOMRIGHT", -3, 3)

        arrow:SetPoint("TOPLEFT", 3, -3)
        arrow:SetPoint("BOTTOMRIGHT", line, "TOPRIGHT", 0, 2)
        Base.SetTexture(arrow, "arrowDown")
    end
    function Hook.ObjectiveTracker_Expand()
        local minimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
        local line, arrow = minimizeButton._auroraLine, minimizeButton._auroraArrow
        line:SetPoint("TOPLEFT", 3, -3)
        line:SetPoint("BOTTOMRIGHT", minimizeButton, "TOPRIGHT", -3, -4)

        arrow:SetPoint("TOPLEFT", line, 0, -2)
        arrow:SetPoint("BOTTOMRIGHT", -3, 3)
        Base.SetTexture(arrow, "arrowUp")
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_QuestObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----
    function Hook.QUEST_TRACKER_MODULE_SetBlockHeader(self, block, text)
        Scale.RawSetWidth(block.HeaderText, block.lineWidth or OBJECTIVE_TRACKER_TEXT_WIDTH)
        block._auroraHeight = SetStringText(block.HeaderText, text, nil, _G.OBJECTIVE_TRACKER_COLOR["Header"], block.isHighlighted)
    end
    function Hook.QUEST_TRACKER_MODULE_Update(self)
        for _, block in next, self.usedBlocks do
            Scale.RawSetHeight(block, block._auroraHeight)
        end
    end

    ----====####$$$$%%%%%%%%%%$$$$####====----
    -- Blizzard_AchievementObjectiveTracker --
    ----====####$$$$%%%%%%%%%%$$$$####====----
    function Hook.ACHIEVEMENT_TRACKER_MODULE_Update(self)
        for _, block in next, self.usedBlocks do
            Scale.RawSetHeight(block, block._auroraHeight)
        end
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AutoQuestPopUpTracker --
    ----====####$$$$%%%%$$$$####====----
    function Hook.AUTO_QUEST_POPUP_TRACKER_MODULE_Update(self)
        for _, block in next, self.usedBlocks do
            if not block._auroraSkinned then
                Skin.AutoQuestPopUpBlockTemplate(block)
                block._auroraSkinned = true
            end
        end
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_BonusObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----
    function Hook.BONUS_OBJECTIVE_TRACKER_MODULE_AddProgressBar(self, block, line, questID)
        local progressBar = line.ProgressBar
        if not progressBar._auroraSkinned then
            Skin.BonusTrackerProgressBarTemplate(progressBar)
            progressBar._auroraSkinned = true
        end
        block._auroraHeight = block._auroraHeight + progressBar:GetHeight() + Scale.Value(block.module.lineSpacing)
    end
    function Hook.BONUS_OBJECTIVE_TRACKER_MODULE_Update(self)
        for _, block in next, self.usedBlocks do
            Scale.RawSetHeight(block, block._auroraHeight + Scale.Value(self.blockPadding))
        end
    end

    ----====####$$$$%%%%%%%$$$$####====----
    -- Blizzard_ScenarioObjectiveTracker --
    ----====####$$$$%%%%%%%$$$$####====----
    function Hook.SCENARIO_TRACKER_MODULE_GetBlock(self)
        _G.ScenarioObjectiveBlock._auroraHeight = 0
    end
    function Hook.SCENARIO_CONTENT_TRACKER_MODULE_Update(self)
        local _, _, _, _, _, _, _, _, _, scenarioType = _G.C_Scenario.GetInfo()
        local stageBlock
        if scenarioType == _G.LE_SCENARIO_TYPE_CHALLENGE_MODE and _G.ScenarioChallengeModeBlock.timerID then
            stageBlock = _G.ScenarioChallengeModeBlock
        elseif _G.ScenarioProvingGroundsBlock.timerID then
            stageBlock = _G.ScenarioProvingGroundsBlock
        else
            stageBlock = _G.ScenarioStageBlock
        end
        Scale.RawSetHeight(_G.ScenarioObjectiveBlock, _G.ScenarioObjectiveBlock._auroraHeight)

        Scale.RawSetHeight(_G.ScenarioBlocksFrame, (_G.ScenarioObjectiveBlock._auroraHeight + stageBlock:GetHeight()) + Scale.Value(1))
    end
end

do --[[ AddOns\Blizzard_ObjectiveTracker.xml ]]
    ----====####$$$$%%%%%$$$$####====----
    -- Blizzard_ObjectiveTrackerShared --
    ----====####$$$$%%%%%$$$$####====----
    function Skin.QuestObjectiveItemButtonTemplate(button)
        Base.CropIcon(button.icon, button)
        button:SetNormalTexture("")
        Base.CropIcon(button:GetPushedTexture())
        Base.CropIcon(button:GetHighlightTexture())
    end
    function Skin.QuestObjectiveFindGroupButtonTemplate(button)
        local bdFrame = _G.CreateFrame("Frame", nil, button)
        bdFrame:SetPoint("TOPLEFT", 4, -4)
        bdFrame:SetPoint("BOTTOMRIGHT", -4, 4)
        bdFrame:SetFrameLevel(button:GetFrameLevel())
        Base.SetBackdrop(bdFrame, Color.button:GetRGBA())

        button._auroraBDFrame = bdFrame
        Base.SetHighlight(button, "backdrop")

        button:SetNormalTexture("")
        button:SetPushedTexture("")
        button:SetDisabledTexture("")
        button:SetHighlightTexture("")

        --[[ Scale ]]--
        button:SetSize(30, 30)
        button.Icon:SetSize(13, 13)
        button.Icon:SetPoint("CENTER", 0, 0)
    end

    ----====####$$$$$$$####====----
    -- Blizzard_ObjectiveTracker --
    ----====####$$$$$$$####====----
    function Skin.ObjectiveTrackerBlockTemplate(frame)
        --[[ Scale ]]--
        frame:SetSize(232, 10)
        frame.HeaderText:SetSize(192, 0)
    end
	function Skin.ObjectiveTrackerHeaderTemplate(frame)
        frame.Background:Hide()

        local bg = frame:CreateTexture(nil, "ARTWORK")
        bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
        bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
        bg:SetVertexColor(Color.highlight.r * 0.7, Color.highlight.g * 0.7, Color.highlight.b * 0.7)
        bg:SetPoint("BOTTOMLEFT", -30, -4)
        bg:SetSize(210, 30)

        --[[ Scale ]]--
        frame:SetSize(235, 25)
        frame.Text:SetPoint("LEFT", 4, -1)
	end
    function Skin.ObjectiveTrackerLineTemplate(frame)
        --[[ Scale ]]--
        frame:SetSize(232, 16)
        frame.Dash:SetPoint("TOPLEFT", 0, 1)
        Scale.RawSetWidth(frame.Text, OBJECTIVE_TRACKER_TEXT_WIDTH)
    end
    function Skin.ObjectiveTrackerCheckLineTemplate(frame)
        --[[ Scale ]]--
        frame:SetSize(232, 16)
        Scale.RawSetWidth(frame.Text, OBJECTIVE_TRACKER_TEXT_WIDTH)
        frame.Text:SetPoint("TOPLEFT", 20, 0)
        frame.IconAnchor:SetSize(16, 16)
        frame.IconAnchor:SetPoint("TOPLEFT", 1, 2)
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_QuestObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----
    function Skin.QuestObjectiveAnimLineTemplate(frame)
        Skin.ObjectiveTrackerLineTemplate(frame)
        frame.Check:SetAtlas("worldquest-tracker-checkmark")
        frame.Check:SetSize(18, 16)

        --[[ Scale ]]--
        frame.Check:SetPoint("TOPLEFT", -10, 2)
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AutoQuestPopUpTracker --
    ----====####$$$$%%%%$$$$####====----
    function Skin.AutoQuestPopUpBlockTemplate(scrollframe)
        --[[ Scale ]]--
        scrollframe:SetSize(232, 68)

        local ScrollChild = scrollframe.ScrollChild
        ScrollChild:SetSize(227, 68)
        ScrollChild.Bg:SetPoint("TOPLEFT", 36, -4)
        ScrollChild.Bg:SetPoint("BOTTOMRIGHT", 0, 4)

        ScrollChild.BorderTopLeft:SetSize(16, 16)
        ScrollChild.BorderTopLeft:SetPoint("TOPLEFT", 32, 0)
        ScrollChild.BorderTopRight:SetSize(16, 16)
        ScrollChild.BorderTopRight:SetPoint("TOPRIGHT", 4, 0)
        ScrollChild.BorderBotLeft:SetSize(16, 16)
        ScrollChild.BorderBotLeft:SetPoint("BOTTOMLEFT", 32, 0)
        ScrollChild.BorderBotRight:SetSize(16, 16)
        ScrollChild.BorderBotRight:SetPoint("BOTTOMRIGHT", 4, 0)

        ScrollChild.BorderLeft:SetWidth(8)
        ScrollChild.BorderRight:SetWidth(8)
        ScrollChild.BorderTop:SetHeight(8)
        ScrollChild.BorderBottom:SetHeight(8)

        ScrollChild.QuestIconBg:SetSize(60, 60)
        ScrollChild.QuestIconBg:SetPoint("CENTER", ScrollChild, "LEFT", 36, 0)
        ScrollChild.QuestIconBadgeBorder:SetSize(44, 45)
        ScrollChild.QuestIconBadgeBorder:SetPoint("TOPLEFT", ScrollChild.QuestIconBg, 8, -8)

        ScrollChild.QuestName:SetPoint("LEFT", ScrollChild.QuestIconBg, "RIGHT", -6, 0)
        ScrollChild.QuestName:SetPoint("RIGHT", -8, 0)
        ScrollChild.TopText:SetPoint("LEFT", ScrollChild.QuestIconBg, "RIGHT", -6, 0)
        ScrollChild.TopText:SetPoint("RIGHT", -8, 0)
        ScrollChild.BottomText:SetPoint("BOTTOM", 0, 8)
        ScrollChild.BottomText:SetPoint("LEFT", ScrollChild.QuestIconBg, "RIGHT", -6, 0)
        ScrollChild.BottomText:SetPoint("RIGHT", -8, 0)

        ScrollChild.Shine:SetPoint("TOPLEFT", 35, -3)
        ScrollChild.Shine:SetPoint("BOTTOMRIGHT", 1, 3)
        ScrollChild.IconShine:SetSize(42, 42)
    end

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_BonusObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----
    function Skin.BonusObjectiveTrackerLineTemplate(frame)
        Skin.ObjectiveTrackerCheckLineTemplate(frame)

        --[[ Scale ]]--
        frame.Dash:SetPoint("TOPLEFT", 20, 1)

        frame.Text:ClearAllPoints()
        frame.Text:SetPoint("TOP")
        frame.Text:SetPoint("LEFT", frame.Dash, "RIGHT")

        frame.Glow:SetPoint("LEFT", frame.Dash, -2, 0)
    end
    function Skin.BonusObjectiveTrackerBlockTemplate(scrollframe)
        --[[ Scale ]]--
        scrollframe:SetSize(240, 10)
        scrollframe.TrackedQuest.Underlay:SetSize(34, 34)
    end
	function Skin.BonusObjectiveTrackerHeaderTemplate(frame)
		Skin.ObjectiveTrackerHeaderTemplate(frame)
	end
    function Skin.BonusTrackerProgressBarTemplate(frame)
        local bar = frame.Bar
        bar.BarFrame:Hide()
        bar.IconBG:SetAlpha(0)
        bar.Icon:SetMask(nil)
        bar.Icon:SetSize(26, 26)
        bar.Icon:SetPoint("RIGHT", 33, 0)
        Base.CropIcon(bar.Icon, bar)
        Base.SetTexture(bar:GetStatusBarTexture(), "gradientUp")
        bar.BarBG:Hide()

        local bd = _G.CreateFrame("Frame", nil, bar)
        bd:SetPoint("TOPLEFT", -1, 1)
        bd:SetPoint("BOTTOMRIGHT", 1, -1)
        Base.SetBackdrop(bd, Color.frame:GetRGBA())

        --[[ Scale ]]--
        frame:SetSize(192, 38)

        bar:SetSize(191, 17)
        bar:SetPoint("LEFT", 10, 0)
    end
end

function private.AddOns.Blizzard_ObjectiveTracker()
    ----====####$$$$%%%%%$$$$####====----
    -- Blizzard_ObjectiveTrackerShared --
    ----====####$$$$%%%%%$$$$####====----
    _G.hooksecurefunc("QuestObjectiveItem_Initialize", Hook.QuestObjectiveItem_Initialize)
    _G.hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", Hook.QuestObjectiveSetupBlockButton_AddRightButton)

    ----====####$$$$$$$####====----
    -- Blizzard_ObjectiveTracker --
    ----====####$$$$$$$####====----
    _G.hooksecurefunc("ObjectiveTracker_Initialize", Hook.ObjectiveTracker_Initialize)
    _G.hooksecurefunc("ObjectiveTracker_Collapse", Hook.ObjectiveTracker_Collapse)
    _G.hooksecurefunc("ObjectiveTracker_Expand", Hook.ObjectiveTracker_Expand)

    --OBJECTIVE_TRACKER_ITEM_WIDTH = Scale.Value(33)
    --OBJECTIVE_TRACKER_HEADER_HEIGHT = Scale.Value(25)
    OBJECTIVE_TRACKER_LINE_WIDTH = Scale.Value(248)
    --OBJECTIVE_TRACKER_HEADER_OFFSET_X = Scale.Value(-10)

    OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT = _G.OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT
    OBJECTIVE_TRACKER_DASH_WIDTH = _G.OBJECTIVE_TRACKER_DASH_WIDTH
    OBJECTIVE_TRACKER_TEXT_WIDTH = OBJECTIVE_TRACKER_LINE_WIDTH - OBJECTIVE_TRACKER_DASH_WIDTH - Scale.Value(12)

    local minimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
    minimizeButton:SetNormalTexture("")
    minimizeButton:SetHighlightTexture("")
    minimizeButton:SetPushedTexture("")
    minimizeButton:SetSize(12, 12)
    minimizeButton:SetPoint("TOPRIGHT", -2, -6)

    Base.SetBackdrop(minimizeButton, Color.button:GetRGBA())

    local line = minimizeButton:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(1, 1, 1)
    minimizeButton._auroraLine = line
    local arrow = minimizeButton:CreateTexture(nil, "OVERLAY")
    minimizeButton._auroraArrow = arrow
    if _G.ObjectiveTrackerFrame.collapsed then
        Hook.ObjectiveTracker_Collapse()
    else
        Hook.ObjectiveTracker_Expand()
    end

    minimizeButton._auroraHighlight = {line, arrow}
    Base.SetHighlight(minimizeButton, "texture")

    for _, headerName in next, {"QuestHeader", "AchievementHeader", "ScenarioHeader"} do
        Skin.ObjectiveTrackerHeaderTemplate(_G.ObjectiveTrackerFrame.BlocksFrame[headerName])
    end

    --[[ Scale ]]--
    _G.ObjectiveTrackerFrame:SetSize(235, 140)
    _G.ObjectiveTrackerFrame.HeaderMenu:SetSize(10, 10)

    ----====####$$$$%$$$$####====----
    -- Blizzard_QuestSuperTracking --
    ----====####$$$$%$$$$####====----

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_QuestObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----

    ----====####$$$$%%%%%%%%%%$$$$####====----
    -- Blizzard_AchievementObjectiveTracker --
    ----====####$$$$%%%%%%%%%%$$$$####====----

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AutoQuestPopUpTracker --
    ----====####$$$$%%%%$$$$####====----

    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_BonusObjectiveTracker --
    ----====####$$$$%%%%$$$$####====----
    local _, _, _, bonusObj, worldQuests = _G.ObjectiveTrackerFrame.BlocksFrame:GetChildren()
    Skin.BonusObjectiveTrackerHeaderTemplate(bonusObj)
    Skin.BonusObjectiveTrackerHeaderTemplate(worldQuests)

    ----====####$$$$%%%%%%%$$$$####====----
    -- Blizzard_ScenarioObjectiveTracker --
    ----====####$$$$%%%%%%%$$$$####====----
    _G.ScenarioObjectiveBlock._auroraHeight = 0

    --[[ Scale ]]--
    _G.ScenarioStageBlock:SetSize(201, 83)
end