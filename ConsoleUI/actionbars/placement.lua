--[[
    ConsoleUI - Spell Placement Frame
    
    Opens when picking up a spell/macro/item to allow placing on action bars
    Shows all 4 pages (40 slots) in a grid layout with controller button icons
]]

-- Create placement module namespace
ConsoleUI.placement = ConsoleUI.placement or {}
local Placement = ConsoleUI.placement

-- Constants
local NUM_BUTTONS = 10
local BUTTON_SIZE = 46
local BUTTON_SPACING = 6
local FRAME_PADDING = 14
local ICON_SIZE = 16
local HEADER_H = 62
local FOOTER_H = 54
local CARD_PAD = 12
local CARD_HEAD = 28
local LABEL_W = 72
local TOUCH_MAX = 5
local COL_HEAD_H = 22

local function GlyphPx()
    if ConsoleUI.config and ConsoleUI.config.GetGlyphSize then
        return ConsoleUI.config:GetGlyphSize("ui")
    end
    return ICON_SIZE
end

local function GlyphHeadH()
    local h = GlyphPx() + 6
    if h < COL_HEAD_H then
        return COL_HEAD_H
    end
    return h
end
local BONUS_BAR_BASE = 60

-- Calculate offset for a given bonus bar number
-- Formula: 60 + (bonusBar * 12)
local function GetStanceOffset(bonusBar)
    if not bonusBar or bonusBar == 0 then
        return 0  -- Caster form uses slots 1-10
    end
    return BONUS_BAR_BASE + (bonusBar * 12)
end


-- Modifier page offsets (always the same)
local MODIFIER_OFFSETS = {
    [1] = 10,   -- LT (Shift) - slots 11-20
    [2] = 20,   -- LB (Ctrl) - slots 21-30
    [3] = 30,   -- LT+LB (Shift+Ctrl) - slots 31-40
}

-- Get localized text (with fallback)
local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

-- Get spell texture from spellbook by spell name
-- This ensures we get the correct texture regardless of current form state
local function GetSpellTextureFromSpellbook(spellName)
    if not spellName or spellName == "" then
        return nil
    end
    
    -- Search through all spellbook tabs and slots
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for i = 1, numSpells do
            local slot = offset + i
            local spellNameInBook, spellRank = GetSpellName(slot, BOOKTYPE_SPELL)
            
            -- Check if spell name matches (ignore rank)
            if spellNameInBook and spellNameInBook == spellName then
                local texture = GetSpellTexture(slot, BOOKTYPE_SPELL)
                if texture then
                    return texture
                end
            end
        end
    end
    
    return nil
end

-- Map druid form names to their actual bonus bar numbers
-- This ensures the placement frame shows the correct slots for each form
local function GetDruidFormBonusBar(formName)
    if not formName then return nil end
    
    -- Normalize form name (handle both "Bear Form" and "Dire Bear Form", etc.)
    local nameLower = string.lower(formName)
    
    -- Map form names to bonus bar numbers (WoW 1.12 mapping)
    -- Note: In WoW 1.12, Cat Form uses bonus bar 1, Bear Form uses bonus bar 3
    -- Aquatic Form uses the regular action bar (no bonus bar)
    if string.find(nameLower, "cat") then
        return 1  -- Cat Form (uses bonus bar 1)
    elseif string.find(nameLower, "aquatic") then
        return nil  -- Aquatic Form uses regular action bar (no dedicated bar)
    elseif string.find(nameLower, "bear") then
        return 3  -- Bear Form / Dire Bear Form (uses bonus bar 3)
    elseif string.find(nameLower, "travel") then
        return 4  -- Travel Form
    elseif string.find(nameLower, "moonkin") or string.find(nameLower, "moon") then
        return 5  -- Moonkin Form
    end
    
    return nil
end

-- Get stance/form info for the player's class
-- Form index directly equals bonus bar offset (standard WoW behavior)
function Placement:GetStanceInfo()
    local _, class = UnitClass("player")
    local numForms = GetNumShapeshiftForms() or 0
    local stances = {}
    
    if class == "WARRIOR" then
        -- Warriors: form index = bonus bar offset
        for i = 1, numForms do
            local texture, name = GetShapeshiftFormInfo(i)
            -- Try to get texture from spellbook for consistency
            local spellbookTexture = GetSpellTextureFromSpellbook(name)
            table.insert(stances, {
                name = name or (L("Stance") .. " " .. i),
                texture = spellbookTexture or texture,
                bonusBar = i,
                offset = GetStanceOffset(i)
            })
        end
    elseif class == "DRUID" then
        -- Druids: Caster (no form) + learned forms
        -- Caster form uses base action bar (offset 0)
        table.insert(stances, {
            name = L("Caster"),
            texture = "Interface\\Icons\\Spell_Nature_HealingTouch",
            bonusBar = 0,
            offset = GetStanceOffset(0)
        })
        -- Map each form to its actual bonus bar number based on form name
        for i = 1, numForms do
            local texture, name = GetShapeshiftFormInfo(i)
            -- Get texture from spellbook to ensure consistency regardless of current form
            local spellbookTexture = GetSpellTextureFromSpellbook(name)
            
            -- Determine the actual bonus bar for this form
            local bonusBar = GetDruidFormBonusBar(name)
            
            -- Skip forms that don't have a dedicated bar (like Aquatic Form)
            if bonusBar == nil then
                -- This form uses the regular action bar, skip it in placement frame
            else
                -- Fallback to form index if name mapping fails (shouldn't happen for known forms)
                if not bonusBar then
                    bonusBar = i
                end
                
                table.insert(stances, {
                    name = name or (L("Form") .. " " .. i),
                    texture = spellbookTexture or texture,
                    bonusBar = bonusBar,
                    offset = GetStanceOffset(bonusBar)
                })
            end
        end
    elseif class == "ROGUE" then
        -- Rogues: Normal + Stealth
        table.insert(stances, {
            name = L("Normal"),
            texture = "Interface\\Icons\\Ability_BackStab",
            bonusBar = 0,
            offset = GetStanceOffset(0)
        })
        if numForms > 0 then
            local texture, name = GetShapeshiftFormInfo(1)
            -- Try to get texture from spellbook for consistency
            local spellbookTexture = GetSpellTextureFromSpellbook(name)
            table.insert(stances, {
                name = name or L("Stealth"),
                texture = spellbookTexture or texture,
                bonusBar = 1,
                offset = GetStanceOffset(1)
            })
        end
    else
        -- Other classes: just base page
        table.insert(stances, {
            name = "",
            texture = nil,
            bonusBar = 0,
            offset = GetStanceOffset(0)
        })
    end
    
    return stances
end

-- Build page info dynamically based on class and learned forms
function Placement:BuildPageInfo()
    local pages = {}
    local stances = self:GetStanceInfo()
    
    -- Add stance/form pages
    for i, stance in ipairs(stances) do
        table.insert(pages, {
            text = stance.name,
            texture = stance.texture,  -- Form/stance icon texture
            icons = {},
            offset = stance.offset,
            isStance = true,
            bonusBar = stance.bonusBar
        })
    end
    
    -- LT = Shift, LB = Ctrl — HouseLegend Steam layout
    table.insert(pages, { text = "LT", icons = {"lt"}, offset = MODIFIER_OFFSETS[1], isStance = false })
    table.insert(pages, { text = "LB", icons = {"lb"}, offset = MODIFIER_OFFSETS[2], isStance = false })
    table.insert(pages, { text = "LT+LB", icons = {"lt", "lb"}, offset = MODIFIER_OFFSETS[3], isStance = false })
    
    return pages
end

-- Function to get icon path based on controller type
local function GetIconPath(iconName)
    local controllerType = "xbox"  -- Default
    if ConsoleUI.config and ConsoleUI.config.Get then
        controllerType = ConsoleUI.config:Get("controllerType") or "xbox"
    elseif ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.controllerType then
        controllerType = ConsoleUIDB.config.controllerType
    end
    
    -- D-pad icons are shared, controller-specific icons are in controllers/<type>/
    local dPadIcons = {down = true, left = true, right = true, up = true}
    if dPadIcons[iconName] then
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. iconName
    else
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. controllerType .. "\\" .. iconName
    end
end

-- Button layout info (matches action bar layout)
-- Format: { id, icon, name }
Placement.BUTTON_INFO = {
    { id = 1,  icon = "a",     name = "A" },
    { id = 2,  icon = "x",     name = "X" },
    { id = 3,  icon = "y",     name = "Y" },
    { id = 4,  icon = "b",     name = "B" },
    { id = 5,  icon = "down",  name = "Down" },
    { id = 6,  icon = "left",  name = "Left" },
    { id = 7,  icon = "up",    name = "Up" },
    { id = 8,  icon = "right", name = "Right" },
    { id = 9,  icon = "rb",    name = "RB" },
    { id = 10, icon = "rt",    name = "RT" },
}

-- Page info will be built dynamically based on class
Placement.PAGE_INFO = nil

-- Helper function to get action slot for a button based on page offset
function Placement:GetActionSlotForButton(pageIndex, buttonIndex)
    if not self.PAGE_INFO then
        self.PAGE_INFO = self:BuildPageInfo()
    end
    
    local pageInfo = self.PAGE_INFO[pageIndex]
    if pageInfo then
        return pageInfo.offset + buttonIndex
    end
    
    -- Fallback to simple calculation
    return ((pageIndex - 1) * NUM_BUTTONS) + buttonIndex
end

function Placement.ClampTouchCount(n)
    if ConsoleUI.config and ConsoleUI.config.ClampTouchCount then
        return ConsoleUI.config:ClampTouchCount(n)
    end
    n = tonumber(n) or 3
    if n < 1 then n = 1 end
    if n > TOUCH_MAX then n = TOUCH_MAX end
    return math.floor(n)
end

local function Cfg()
    return ConsoleUI.config
end

local function Colors()
    local cfg = Cfg()
    if cfg and cfg.UI_COLORS then
        return cfg.UI_COLORS
    end
    return {
        gold = {1.00, 0.82, 0.18, 1.00},
        panel = {0.067, 0.071, 0.086, 0.98},
        header = {0.082, 0.086, 0.106, 0.98},
        content = {0.078, 0.082, 0.098, 0.96},
        section = {0.094, 0.102, 0.122, 0.96},
        inset = {0.078, 0.082, 0.102, 0.96},
        border = {1.00, 1.00, 1.00, 0.14},
        borderStrong = {1.00, 1.00, 1.00, 0.20},
        muted = {0.545, 0.561, 0.596, 1.00},
        text = {0.945, 0.949, 0.957, 1.00},
        active = {0.145, 0.122, 0.055, 0.96},
    }
end

local function CardBackdrop()
    local cfg = Cfg()
    if cfg and cfg.BACKDROP_CARD then
        return cfg.BACKDROP_CARD
    end
    return {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    }
end

function Placement:PaintSlot(button, filled, hovered)
    if not button then return end
    if hovered then
        button:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
        button:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
    elseif filled then
        button:SetBackdropColor(0.094, 0.102, 0.122, 0.96)
        button:SetBackdropBorderColor(1, 1, 1, 0.14)
    else
        button:SetBackdropColor(0.078, 0.082, 0.102, 0.96)
        button:SetBackdropBorderColor(1, 1, 1, 0.08)
    end
end

function Placement:CursorIsHolding()
    if CursorHasItem and CursorHasItem() then
        return true
    end
    if CursorHasSpell and CursorHasSpell() then
        return true
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.heldItemTexturePath then
        return true
    end
    return false
end

function Placement:ClearSlot(button)
    if not button or not button.actionSlot then
        return false
    end
    local slot = button.actionSlot
    if not HasAction(slot) then
        return false
    end
    if (CursorHasItem and CursorHasItem()) or (CursorHasSpell and CursorHasSpell()) then
        ClearCursor()
    end
    PickupAction(slot)
    ClearCursor()
    self:UpdateButton(button)
    if self.clearBtn and self.clearBtn.owner == button then
        self.clearBtn:Hide()
        self.clearBtn.owner = nil
    end
    if ConsoleUI.actionbars then
        if ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
        if button.side and ConsoleUI.actionbars.UpdateAllSideBarButtons then
            ConsoleUI.actionbars:UpdateAllSideBarButtons()
        end
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.ClearHeldItemTexture then
        ConsoleUI.cursor:ClearHeldItemTexture()
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
        ConsoleUI.cursor:RefreshFrame()
    end
    return true
end

function Placement:HideClearChip()
    if self.clearBtn then
        self.clearBtn:Hide()
        self.clearBtn.owner = nil
    end
end

function Placement:ShowClearFor(button)
    if not button or not button.actionSlot or not HasAction(button.actionSlot) or self:CursorIsHolding() then
        self:HideClearChip()
        return
    end
    if not self.clearBtn then
        return
    end
    local btn = self.clearBtn
    btn.owner = button
    btn:ClearAllPoints()
    btn:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
    btn:SetFrameLevel((button:GetFrameLevel() or 1) + 8)
    btn:Show()
end

function Placement:MakeCard(parent, title)
    local c = Colors()
    local card = CreateFrame("Frame", nil, parent)
    card:SetBackdrop(CardBackdrop())
    card:SetBackdropColor(unpack(c.section))
    card:SetBackdropBorderColor(unpack(c.border))

    local pip = card:CreateTexture(nil, "ARTWORK")
    pip:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    pip:SetWidth(3)
    pip:SetHeight(10)
    pip:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
    pip:SetVertexColor(unpack(c.gold))
    card.pip = pip

    local label = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", pip, "RIGHT", 7, 0)
    label:SetText(string.upper(title or ""))
    label:SetTextColor(0.78, 0.79, 0.81)
    card.title = label
    return card
end

-- ============================================================================
-- Frame Creation
-- ============================================================================

function Placement:CreateFrame()
    if self.frame then return self.frame end

    self.PAGE_INFO = self:BuildPageInfo()
    local NUM_PAGES = table.getn(self.PAGE_INFO)
    local c = Colors()
    local cfg = Cfg()

    local gridW = LABEL_W + (BUTTON_SIZE * NUM_BUTTONS) + (BUTTON_SPACING * (NUM_BUTTONS - 1))
    local frameWidth = FRAME_PADDING * 2 + CARD_PAD * 2 + gridW
    if frameWidth < 640 then frameWidth = 640 end

    local frame = CreateFrame("Frame", "ConsoleUIPlacementFrame", UIParent)
    frame:SetWidth(frameWidth)
    frame:SetHeight(400)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:Hide()

    if cfg and cfg.BACKDROP_PANEL then
        frame:SetBackdrop(cfg.BACKDROP_PANEL)
    else
        frame:SetBackdrop(CardBackdrop())
    end
    frame:SetBackdropColor(unpack(c.panel))
    frame:SetBackdropBorderColor(unpack(c.borderStrong))

    local headerFill = frame:CreateTexture(nil, "BORDER")
    headerFill:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerFill:SetVertexColor(0.082, 0.086, 0.106, 0.98)
    headerFill:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    headerFill:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    headerFill:SetHeight(HEADER_H - 6)

    local headerRule = frame:CreateTexture(nil, "OVERLAY")
    headerRule:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerRule:SetVertexColor(1, 1, 1, 0.08)
    headerRule:SetPoint("BOTTOMLEFT", headerFill, "BOTTOMLEFT", 0, 0)
    headerRule:SetPoint("BOTTOMRIGHT", headerFill, "BOTTOMRIGHT", 0, 0)
    headerRule:SetHeight(1)

    local titleRegion = CreateFrame("Frame", nil, frame)
    titleRegion:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5)
    titleRegion:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -5)
    titleRegion:SetHeight(HEADER_H - 8)
    titleRegion:EnableMouse(true)
    titleRegion:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    titleRegion:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)

    local mark = frame:CreateTexture(nil, "ARTWORK")
    mark:SetTexture((cfg and cfg.MARK) or "Interface\\AddOns\\ConsoleUI\\textures\\brand\\Mark")
    mark:SetWidth(34)
    mark:SetHeight(34)
    mark:SetPoint("LEFT", headerFill, "LEFT", 12, 0)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", mark, "RIGHT", 10, 0)
    title:SetText(L("Spell"))
    title:SetTextColor(unpack(c.text))

    local brand = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    brand:SetPoint("LEFT", title, "RIGHT", 4, 0)
    brand:SetText(L("Placement"))
    brand:SetTextColor(unpack(c.gold))

    local credit = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    credit:SetPoint("RIGHT", headerFill, "RIGHT", -16, 0)
    credit:SetText(L("Drop a spell on a slot"))
    credit:SetTextColor(unpack(c.muted))

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING, -HEADER_H)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -FRAME_PADDING, FOOTER_H)
    frame.content = content

    local pagesCard = self:MakeCard(content, L("Action pages"))
    pagesCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    pagesCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    frame.pagesCard = pagesCard

    frame.headerIcons = {}
    for btn = 1, NUM_BUTTONS do
        local btnInfo = self.BUTTON_INFO[btn]
        if btnInfo then
            local headerIcon = pagesCard:CreateTexture(nil, "OVERLAY")
            headerIcon:SetWidth(GlyphPx())
            headerIcon:SetHeight(GlyphPx())
            headerIcon:SetTexCoord(0, 1, 0, 1)
            headerIcon:SetTexture(GetIconPath(btnInfo.icon))
            frame.headerIcons[btn] = headerIcon
        end
    end

    self.buttons = {}
    self.buttonsByPage = {}
    for page = 1, NUM_PAGES do
        self.buttonsByPage[page] = {}
        local pageInfo = self.PAGE_INFO[page]
        for btn = 1, NUM_BUTTONS do
            local actionSlot = pageInfo.offset + btn
            local button = self:CreateActionButton(pagesCard, actionSlot, btn, page)
            button.pageOffset = pageInfo.offset
            if ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied and ConsoleUI.proxied:IsSlotProxied(actionSlot) then
                button:Hide()
            end
            self.buttons[actionSlot] = button
            self.buttonsByPage[page][btn] = button
        end
    end

    self.rowLabels = {}
    for page = 1, NUM_PAGES do
        local pageInfo = self.PAGE_INFO[page]
        local labelContainer = CreateFrame("Frame", "ConsoleUIPlacementRowLabel" .. page, pagesCard)
        labelContainer:SetWidth(LABEL_W - 8)
        labelContainer:SetHeight(BUTTON_SIZE)

        if pageInfo.isStance then
            if pageInfo.texture then
                local stanceIcon = labelContainer:CreateTexture(nil, "OVERLAY")
                stanceIcon:SetWidth(22)
                stanceIcon:SetHeight(22)
                stanceIcon:SetTexture(pageInfo.texture)
                stanceIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                stanceIcon:SetPoint("LEFT", labelContainer, "LEFT", 2, 0)
                labelContainer.stanceIcon = stanceIcon
                if pageInfo.text and pageInfo.text ~= "" then
                    local stanceLabel = labelContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    stanceLabel:SetPoint("LEFT", stanceIcon, "RIGHT", 4, 0)
                    stanceLabel:SetText(pageInfo.text)
                    stanceLabel:SetTextColor(unpack(c.gold))
                    stanceLabel:SetWidth(LABEL_W - 32)
                    stanceLabel:SetJustifyH("LEFT")
                    labelContainer.stanceLabel = stanceLabel
                end
            elseif pageInfo.text and pageInfo.text ~= "" then
                local stanceLabel = labelContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                stanceLabel:SetPoint("LEFT", labelContainer, "LEFT", 2, 0)
                stanceLabel:SetText(pageInfo.text)
                stanceLabel:SetTextColor(unpack(c.gold))
                labelContainer.stanceLabel = stanceLabel
            end
        end

        labelContainer.modIcons = {}
        if pageInfo.icons and table.getn(pageInfo.icons) > 0 then
                local glyph = GlyphPx()
                local xPos = 0
                for i = 1, table.getn(pageInfo.icons) do
                    local iconName = pageInfo.icons[i]
                    local modIcon = labelContainer:CreateTexture(nil, "OVERLAY")
                    modIcon:SetWidth(glyph)
                    modIcon:SetHeight(glyph)
                    modIcon:SetTexCoord(0, 1, 0, 1)
                    modIcon:SetTexture(GetIconPath(iconName))
                    modIcon:SetPoint("LEFT", labelContainer, "LEFT", xPos, 0)
                    labelContainer.modIcons[i] = modIcon
                    xPos = xPos + glyph + 2
                end
        end
        self.rowLabels[page] = labelContainer
    end

    local footerFill = frame:CreateTexture(nil, "BORDER")
    footerFill:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    footerFill:SetVertexColor(0.067, 0.071, 0.086, 0.98)
    footerFill:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
    footerFill:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    footerFill:SetHeight(FOOTER_H - 8)

    local footerRule = frame:CreateTexture(nil, "OVERLAY")
    footerRule:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    footerRule:SetVertexColor(1, 1, 1, 0.08)
    footerRule:SetPoint("TOPLEFT", footerFill, "TOPLEFT", 0, 0)
    footerRule:SetPoint("TOPRIGHT", footerFill, "TOPRIGHT", 0, 0)
    footerRule:SetHeight(1)

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("LEFT", footerFill, "LEFT", 12, 0)
    hint:SetText(L("Drag a spell or item onto a slot. X or Clear empties it. B closes. Right-click to pick up."))
    hint:SetTextColor(unpack(c.muted))
    hint:SetJustifyH("LEFT")
    frame.hint = hint

    local closeButton
    if cfg and cfg.MakePanelButton then
        closeButton = cfg:MakePanelButton(frame, "ConsoleUIPlacementCloseButton", 96, CLOSE or L("Close"))
    else
        closeButton = CreateFrame("Button", "ConsoleUIPlacementCloseButton", frame, "UIPanelCloseButton")
    end
    closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 14)
    closeButton:SetScript("OnClick", function()
        Placement:Hide()
        ClearCursor()
    end)
    frame.closeButton = closeButton

    local clearBtn = CreateFrame("Button", "ConsoleUIPlacementClear", frame)
    clearBtn:SetWidth(BUTTON_SIZE - 6)
    clearBtn:SetHeight(16)
    clearBtn:SetBackdrop(CardBackdrop())
    clearBtn:SetBackdropColor(0.16, 0.06, 0.07, 0.96)
    clearBtn:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.35)
    clearBtn:Hide()
    local clearLabel = clearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    clearLabel:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
    clearLabel:SetText(L("Clear"))
    clearLabel:SetTextColor(0.95, 0.55, 0.58)
    clearBtn:SetScript("OnClick", function()
        if this.owner then
            Placement:ClearSlot(this.owner)
        end
    end)
    clearBtn:SetScript("OnEnter", function()
        this:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.70)
        if this.owner then
            Placement:PaintSlot(this.owner, HasAction(this.owner.actionSlot), true)
        end
    end)
    clearBtn:SetScript("OnLeave", function()
        this:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.35)
    end)
    clearBtn:SetScript("OnUpdate", function()
        local owner = this.owner
        if not owner then
            this:Hide()
            return
        end
        local focus = GetMouseFocus()
        if focus ~= this and focus ~= owner then
            Placement:PaintSlot(owner, HasAction(owner.actionSlot), false)
            Placement:HideClearChip()
        end
    end)
    self.clearBtn = clearBtn

    table.insert(UISpecialFrames, "ConsoleUIPlacementFrame")
    self.frame = frame

    if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
        ConsoleUI.hooks:HookDynamicFrame(frame, "Spell Placement")
    end

    self:LayoutPages()
    return frame
end

function Placement:LayoutPages()
    if not self.frame or not self.frame.pagesCard then return end
    local pagesCard = self.frame.pagesCard
    local NUM_PAGES = self.PAGE_INFO and table.getn(self.PAGE_INFO) or 0
    local gridTop = -CARD_HEAD
    local x0 = CARD_PAD + LABEL_W

    local headH = GlyphHeadH()
    local glyph = GlyphPx()
    for btn = 1, NUM_BUTTONS do
        local headerIcon = self.frame.headerIcons and self.frame.headerIcons[btn]
        if headerIcon then
            headerIcon:SetWidth(glyph)
            headerIcon:SetHeight(glyph)
            local x = x0 + ((btn - 1) * (BUTTON_SIZE + BUTTON_SPACING)) + (BUTTON_SIZE / 2)
            headerIcon:ClearAllPoints()
            headerIcon:SetPoint("TOP", pagesCard, "TOPLEFT", x, gridTop)
        end
    end

    local rowsTop = gridTop - headH
    for page = 1, NUM_PAGES do
        local y = rowsTop - ((page - 1) * (BUTTON_SIZE + BUTTON_SPACING))
        if self.rowLabels and self.rowLabels[page] then
            self.rowLabels[page]:ClearAllPoints()
            self.rowLabels[page]:SetPoint("TOPLEFT", pagesCard, "TOPLEFT", CARD_PAD, y)
        end
        if self.buttonsByPage and self.buttonsByPage[page] then
            for btn = 1, NUM_BUTTONS do
                local button = self.buttonsByPage[page][btn]
                if button then
                    local x = x0 + ((btn - 1) * (BUTTON_SIZE + BUTTON_SPACING))
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", pagesCard, "TOPLEFT", x, y)
                end
            end
        end
    end

    local pagesH = CARD_HEAD + headH + (BUTTON_SIZE * NUM_PAGES) + (BUTTON_SPACING * math.max(NUM_PAGES - 1, 0)) + CARD_PAD
    pagesCard:SetHeight(pagesH)
end

function Placement:CreateActionButton(parent, actionSlot, buttonIndex, pageIndex)
    local buttonName = "ConsoleUIPlacementButton" .. actionSlot
    local button = CreateFrame("Button", buttonName, parent)

    button:SetWidth(BUTTON_SIZE)
    button:SetHeight(BUTTON_SIZE)
    button:SetBackdrop(CardBackdrop())
    self:PaintSlot(button, false, false)

    local iconSize = BUTTON_SIZE - 10
    local icon = button:CreateTexture(buttonName .. "Icon", "ARTWORK")
    icon:SetWidth(iconSize)
    icon:SetHeight(iconSize)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    button.actionSlot = actionSlot
    button.buttonIndex = buttonIndex
    button.pageIndex = pageIndex
    
    -- Click handler - place cursor item
    button:SetScript("OnClick", function()
        -- Use the stored action slot (fixed per stance row)
        local slot = this.actionSlot
        
        -- Check for cursor item OR fake cursor item (for macros)
        local hasCursorItem = CursorHasItem() or CursorHasSpell()
        local hasFakeCursorItem = ConsoleUI.cursor and ConsoleUI.cursor.heldItemTexturePath
        if hasCursorItem or hasFakeCursorItem then
            PlaceAction(slot)
            ConsoleUI_Debug("Placed item in action slot " .. slot)
            
            -- Update the button display
            Placement:UpdateButton(this)
            
            -- Update main action bar if on current page
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
                ConsoleUI.actionbars:UpdateAllButtons()
            end
            
            -- Clear fake cursor held item
            if ConsoleUI.cursor then
                ConsoleUI.cursor:ClearHeldItemTexture()
            end
            
            -- Don't auto-hide - allow user to continue placing items
        else
            -- No cursor item, maybe pick up from this slot
            PickupAction(slot)
            Placement:UpdateButton(this)
            
            -- Show held item on fake cursor
            local texture = GetActionTexture(slot)
            if texture and ConsoleUI.cursor and ConsoleUI.cursor.SetHeldItemTexture then
                ConsoleUI.cursor:SetHeldItemTexture(texture)
            end
        end
        Placement:ShowClearFor(this)
    end)
    
    -- Right-click to pick up
    button:SetScript("OnMouseDown", function()
        if arg1 == "RightButton" then
            local slot = this.actionSlot
            PickupAction(slot)
            Placement:UpdateButton(this)
            
            local texture = GetActionTexture(slot)
            if texture and ConsoleUI.cursor and ConsoleUI.cursor.SetHeldItemTexture then
                ConsoleUI.cursor:SetHeldItemTexture(texture)
            end
            Placement:ShowClearFor(this)
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        local slot = this.actionSlot
        Placement:PaintSlot(this, HasAction(slot), true)
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if HasAction(slot) then
            GameTooltip:SetAction(slot)
        else
            local btnInfo = Placement.BUTTON_INFO[this.buttonIndex]
            local pageInfo = Placement.PAGE_INFO and Placement.PAGE_INFO[this.pageIndex]
            local slotName = btnInfo and btnInfo.name or ("Slot " .. this.buttonIndex)
            if pageInfo and pageInfo.text and pageInfo.text ~= "" then
                slotName = pageInfo.text .. " + " .. slotName
            end
            GameTooltip:SetText(slotName)
            GameTooltip:AddLine("Empty slot", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
        Placement:ShowClearFor(this)
    end)
    
    button:SetScript("OnLeave", function()
        local focus = GetMouseFocus()
        if Placement.clearBtn and focus == Placement.clearBtn then
            GameTooltip:Hide()
            return
        end
        Placement:PaintSlot(this, HasAction(this.actionSlot), false)
        GameTooltip:Hide()
    end)
    
    -- Receive drag
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnReceiveDrag", function()
        -- Use the stored action slot (fixed per stance row)
        local slot = this.actionSlot
        
        -- Check for cursor item OR fake cursor item (for macros)
        local hasCursorItem = CursorHasItem() or CursorHasSpell()
        local hasFakeCursorItem = ConsoleUI.cursor and ConsoleUI.cursor.heldItemTexturePath
        if hasCursorItem or hasFakeCursorItem then
            PlaceAction(slot)
            Placement:UpdateButton(this)

            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
                ConsoleUI.actionbars:UpdateAllButtons()
            end

            if ConsoleUI.cursor and ConsoleUI.cursor.ClearHeldItemTexture then
                ConsoleUI.cursor:ClearHeldItemTexture()
            end
        end
        Placement:ShowClearFor(this)
    end)

    return button
end

-- ============================================================================
-- Update Functions
-- ============================================================================

function Placement:UpdateButton(button)
    if not button then return end

    -- Use the stored action slot (fixed per stance row)
    local actionSlot = button.actionSlot
    local texture = GetActionTexture(actionSlot)

    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
        self:PaintSlot(button, true, false)
    else
        button.icon:Hide()
        self:PaintSlot(button, false, false)
    end
end

function Placement:UpdateAllButtons()
    if not self.buttons then return end
    
    for actionSlot, button in pairs(self.buttons) do
        self:UpdateButton(button)
    end
    
    -- Also update side bar buttons in placement frame
    for i = 1, TOUCH_MAX do
        if self.sideBarLeftButtons[i] then
            self:UpdateSideBarPlacementButton(self.sideBarLeftButtons[i])
        end
        if self.sideBarRightButtons[i] then
            self:UpdateSideBarPlacementButton(self.sideBarRightButtons[i])
        end
    end
end

function Placement:RefreshIcons()
    if not self.frame then return end
    if not self.PAGE_INFO then return end
    
    local NUM_PAGES = table.getn(self.PAGE_INFO)
    local glyph = GlyphPx()
    
    -- Update header icons (stored in frame.headerIcons table)
    if self.frame.headerIcons then
        for btn = 1, NUM_BUTTONS do
            local headerIcon = self.frame.headerIcons[btn]
            if headerIcon then
                local btnInfo = self.BUTTON_INFO[btn]
                if btnInfo then
                    headerIcon:SetTexture(GetIconPath(btnInfo.icon))
                end
                headerIcon:SetWidth(glyph)
                headerIcon:SetHeight(glyph)
            end
        end
    end
    
    for page = 1, NUM_PAGES do
        local labelContainer = self.rowLabels and self.rowLabels[page]
        if labelContainer and labelContainer.modIcons then
            local pageInfo = self.PAGE_INFO[page]
            if pageInfo and pageInfo.icons then
                local xPos = 0
                for i = 1, table.getn(pageInfo.icons) do
                    local iconName = pageInfo.icons[i]
                    local modIcon = labelContainer.modIcons[i]
                    if modIcon then
                        modIcon:SetTexture(GetIconPath(iconName))
                        modIcon:SetWidth(glyph)
                        modIcon:SetHeight(glyph)
                        modIcon:ClearAllPoints()
                        modIcon:SetPoint("LEFT", labelContainer, "LEFT", xPos, 0)
                        xPos = xPos + glyph + 2
                    end
                end
            end
        end
    end
    self:LayoutPages()
end

-- ============================================================================
-- Side Bar Buttons in Placement Frame
-- ============================================================================

-- Storage for side bar placement buttons
Placement.sideBarLeftButtons = {}
Placement.sideBarRightButtons = {}
Placement.sideBarLeftFrame = nil
Placement.sideBarRightFrame = nil

function Placement:CreateSideBarPlacementButton(parent, actionSlot, buttonIndex, side)
    local buttonName = "ConsoleUIPlacementButton" .. actionSlot
    local button = CreateFrame("Button", buttonName, parent)
    
    button:SetWidth(BUTTON_SIZE)
    button:SetHeight(BUTTON_SIZE)
    button:SetBackdrop(CardBackdrop())
    self:PaintSlot(button, false, false)

    local iconSize = BUTTON_SIZE - 10
    local icon = button:CreateTexture(buttonName .. "Icon", "ARTWORK")
    icon:SetWidth(iconSize)
    icon:SetHeight(iconSize)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon
    
    -- Store action slot and info
    button.actionSlot = actionSlot
    button.buttonIndex = buttonIndex
    button.pageIndex = 1  -- Side bars don't have pages, use 1 for consistency
    button.side = side
    
    -- Click handler - place cursor item
    button:SetScript("OnClick", function()
        -- Check for cursor item OR fake cursor item (for macros)
        local hasCursorItem = CursorHasItem() or CursorHasSpell()
        local hasFakeCursorItem = ConsoleUI.cursor and ConsoleUI.cursor.heldItemTexturePath
        if hasCursorItem or hasFakeCursorItem then
            PlaceAction(this.actionSlot)
            ConsoleUI_Debug("Placed item in side bar slot " .. this.actionSlot)
            
            Placement:UpdateSideBarPlacementButton(this)
            
            -- Update side bar buttons on main UI
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllSideBarButtons then
                ConsoleUI.actionbars:UpdateAllSideBarButtons()
            end
            
            if ConsoleUI.cursor then
                ConsoleUI.cursor:ClearHeldItemTexture()
            end
        else
            PickupAction(this.actionSlot)
            Placement:UpdateSideBarPlacementButton(this)
            
            local texture = GetActionTexture(this.actionSlot)
            if texture and ConsoleUI.cursor and ConsoleUI.cursor.SetHeldItemTexture then
                ConsoleUI.cursor:SetHeldItemTexture(texture)
            end
        end
        Placement:ShowClearFor(this)
    end)
    
    -- Right-click to pick up
    button:SetScript("OnMouseDown", function()
        if arg1 == "RightButton" then
            PickupAction(this.actionSlot)
            Placement:UpdateSideBarPlacementButton(this)
            
            local texture = GetActionTexture(this.actionSlot)
            if texture and ConsoleUI.cursor and ConsoleUI.cursor.SetHeldItemTexture then
                ConsoleUI.cursor:SetHeldItemTexture(texture)
            end
            Placement:ShowClearFor(this)
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        Placement:PaintSlot(this, HasAction(this.actionSlot), true)
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if HasAction(this.actionSlot) then
            GameTooltip:SetAction(this.actionSlot)
        else
            local sideName = this.side == "left" and "Left" or "Right"
            GameTooltip:SetText(sideName .. " Touch " .. this.buttonIndex)
            GameTooltip:AddLine("Empty slot (touch screen)", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
        Placement:ShowClearFor(this)
    end)
    
    button:SetScript("OnLeave", function()
        local focus = GetMouseFocus()
        if Placement.clearBtn and focus == Placement.clearBtn then
            GameTooltip:Hide()
            return
        end
        Placement:PaintSlot(this, HasAction(this.actionSlot), false)
        GameTooltip:Hide()
    end)
    
    -- Receive drag
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnReceiveDrag", function()
        -- Check for cursor item OR fake cursor item (for macros)
        local hasCursorItem = CursorHasItem() or CursorHasSpell()
        local hasFakeCursorItem = ConsoleUI.cursor and ConsoleUI.cursor.heldItemTexturePath
        if hasCursorItem or hasFakeCursorItem then
            PlaceAction(this.actionSlot)
            Placement:UpdateSideBarPlacementButton(this)
            
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllSideBarButtons then
                ConsoleUI.actionbars:UpdateAllSideBarButtons()
            end
            
            if ConsoleUI.cursor and ConsoleUI.cursor.ClearHeldItemTexture then
                ConsoleUI.cursor:ClearHeldItemTexture()
            end
        end
        Placement:ShowClearFor(this)
    end)
    
    return button
end

function Placement:UpdateSideBarPlacementButton(button)
    if not button then return end
    
    local actionSlot = button.actionSlot
    local texture = GetActionTexture(actionSlot)
    
    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
        self:PaintSlot(button, true, false)
    else
        button.icon:Hide()
        self:PaintSlot(button, false, false)
    end
end

function Placement:LayoutTouchCard(card, buttons, side, count, offset)
    count = self.ClampTouchCount(count)
    local innerH = CARD_HEAD + BUTTON_SIZE + CARD_PAD
    card:SetHeight(innerH)
    for i = 1, TOUCH_MAX do
        if i <= count then
            local actionSlot = offset + i
            if not buttons[i] then
                buttons[i] = self:CreateSideBarPlacementButton(card, actionSlot, i, side)
            end
            local button = buttons[i]
            button.actionSlot = actionSlot
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", card, "TOPLEFT", CARD_PAD + ((i - 1) * (BUTTON_SIZE + BUTTON_SPACING)), -CARD_HEAD)
            button:Show()
            self:UpdateSideBarPlacementButton(button)
        elseif buttons[i] then
            buttons[i]:Hide()
        end
    end
end

function Placement:UpdateSideBarButtons()
    if not self.frame or not self.frame.content then return end

    local config = ConsoleUI.config
    if not config then return end

    local leftEnabled = config:Get("sideBarLeftEnabled")
    local rightEnabled = config:Get("sideBarRightEnabled")
    local leftCount = self.ClampTouchCount(config:Get("sideBarLeftButtons") or 3)
    local rightCount = self.ClampTouchCount(config:Get("sideBarRightButtons") or 3)

    local LEFT_OFFSET = 40
    local RIGHT_OFFSET = 45
    local content = self.frame.content

    if not self.sideBarLeftFrame then
        self.sideBarLeftFrame = self:MakeCard(content, L("Left touch"))
    end
    if not self.sideBarRightFrame then
        self.sideBarRightFrame = self:MakeCard(content, L("Right touch"))
    end

    self:LayoutPages()
    local pagesCard = self.frame.pagesCard
    local gap = 10
    local touchH = 0

    if leftEnabled or rightEnabled then
        touchH = CARD_HEAD + BUTTON_SIZE + CARD_PAD
        if leftEnabled then
            self.sideBarLeftFrame:ClearAllPoints()
            self.sideBarLeftFrame:SetPoint("TOPLEFT", pagesCard, "BOTTOMLEFT", 0, -gap)
            if rightEnabled then
                self.sideBarLeftFrame:SetPoint("RIGHT", content, "CENTER", -5, 0)
            else
                self.sideBarLeftFrame:SetPoint("TOPRIGHT", pagesCard, "BOTTOMRIGHT", 0, -gap)
            end
            self.sideBarLeftFrame:Show()
            self:LayoutTouchCard(self.sideBarLeftFrame, self.sideBarLeftButtons, "left", leftCount, LEFT_OFFSET)
        else
            self.sideBarLeftFrame:Hide()
            for i = 1, TOUCH_MAX do
                if self.sideBarLeftButtons[i] then self.sideBarLeftButtons[i]:Hide() end
            end
        end
        if rightEnabled then
            self.sideBarRightFrame:ClearAllPoints()
            self.sideBarRightFrame:SetPoint("TOPRIGHT", pagesCard, "BOTTOMRIGHT", 0, -gap)
            if leftEnabled then
                self.sideBarRightFrame:SetPoint("LEFT", content, "CENTER", 5, 0)
            else
                self.sideBarRightFrame:SetPoint("TOPLEFT", pagesCard, "BOTTOMLEFT", 0, -gap)
            end
            self.sideBarRightFrame:Show()
            self:LayoutTouchCard(self.sideBarRightFrame, self.sideBarRightButtons, "right", rightCount, RIGHT_OFFSET)
        else
            self.sideBarRightFrame:Hide()
            for i = 1, TOUCH_MAX do
                if self.sideBarRightButtons[i] then self.sideBarRightButtons[i]:Hide() end
            end
        end
    else
        self.sideBarLeftFrame:Hide()
        self.sideBarRightFrame:Hide()
        for i = 1, TOUCH_MAX do
            if self.sideBarLeftButtons[i] then self.sideBarLeftButtons[i]:Hide() end
            if self.sideBarRightButtons[i] then self.sideBarRightButtons[i]:Hide() end
        end
    end

    local pagesH = pagesCard:GetHeight() or 200
    local extra = 0
    if touchH > 0 then extra = gap + touchH end
    self.frame:SetHeight(HEADER_H + FOOTER_H + FRAME_PADDING + pagesH + extra + 8)
end

-- ============================================================================
-- Show/Hide
-- ============================================================================

function Placement:UpdateButtonVisibility()
    if not self.frame then return end
    
    -- Hide/show buttons based on proxied action assignments
    if self.buttons then
        for actionSlot, button in pairs(self.buttons) do
            if ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied then
                if ConsoleUI.proxied:IsSlotProxied(actionSlot) then
                    button:Hide()
                else
                    button:Show()
                end
            else
                button:Show()
            end
        end
    end
end

function Placement:Show()
    -- Check if we need to rebuild (number of forms may have changed)
    local currentNumForms = GetNumShapeshiftForms() or 0
    
    if self.frame and self.lastNumForms ~= currentNumForms then
        -- Number of forms changed, need to rebuild
        self.frame:Hide()
        self.frame = nil
        self.PAGE_INFO = nil
        self.buttons = nil
        self.buttonsByPage = nil
        self.rowLabels = nil
        self.sideBarLeftButtons = {}
        self.sideBarRightButtons = {}
        self.sideBarLeftFrame = nil
        self.sideBarRightFrame = nil
        self.clearBtn = nil
        ConsoleUI_Debug("Placement: Rebuilding due to form count change")
    end
    
    self.lastNumForms = currentNumForms
    
    if not self.frame then
        self:CreateFrame()
    end

    -- Update button visibility based on config
    self:UpdateButtonVisibility()

    -- Create/update side bar buttons in placement frame
    self:UpdateSideBarButtons()

    self:UpdateAllButtons()
    self.frame:Show()

    ConsoleUI_Debug("Placement frame shown")
end

function Placement:Hide()
    self:HideClearChip()
    if self.frame then
        self.frame:Hide()
    end
    
    -- Clear fake cursor held item texture
    if ConsoleUI.cursor then
        ConsoleUI.cursor:ClearHeldItemTexture()
    end
    
    ConsoleUI_Debug("Placement frame hidden")
end

function Placement:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function Placement:IsShown()
    return self.frame and self.frame:IsShown()
end

-- ============================================================================
-- Auto-show when picking up items
-- ============================================================================

-- Hook into cursor pickup to auto-show
function Placement:OnItemPickedUp()
    -- Small delay to ensure cursor state is updated
    self:Show()
end

-- ============================================================================
-- Event Handling for Auto-Show
-- ============================================================================

function Placement:Initialize()
    -- Create event frame to detect when forms change (e.g., learning new forms)
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame", "ConsoleUIPlacementEventFrame", UIParent)
        self.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
        self.eventFrame:SetScript("OnEvent", function()
            -- Force rebuild on next show if number of forms changed
            if Placement.frame and Placement.lastNumForms then
                Placement.lastNumForms = -1
            end
        end)
    end
    
    ConsoleUI_Debug("Placement module initialized")
end

-- Removed OnCursorUpdate() - placement frame no longer auto-shows on item pickup
-- Frame must be manually opened from config menu

-- Module loaded
ConsoleUI_Debug("Placement module loaded")
