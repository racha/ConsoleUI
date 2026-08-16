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
local BUTTON_SIZE = 60
local BUTTON_SPACING = 8
local FRAME_PADDING = 25
local ICON_SIZE = 14

-- Bonus bar base offset (6 pages * 12 buttons = 72, minus 12 = 60)
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
    [2] = 20,   -- RT (Ctrl) - slots 21-30
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
    
    -- Add modifier pages
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

-- ============================================================================
-- Frame Creation
-- ============================================================================

function Placement:CreateFrame()
    if self.frame then return self.frame end
    
    -- Build page info based on class and learned forms
    self.PAGE_INFO = self:BuildPageInfo()
    local NUM_PAGES = table.getn(self.PAGE_INFO)
    
    -- Calculate frame size (bigger frame)
    -- Add extra width for row labels on the left
    local labelColumnWidth = 80  -- Space for stance names and modifier icons
    local frameWidth = (BUTTON_SIZE * NUM_BUTTONS) + (BUTTON_SPACING * (NUM_BUTTONS - 1)) + (FRAME_PADDING * 2) + labelColumnWidth
    local frameHeight = (BUTTON_SIZE * NUM_PAGES) + (BUTTON_SPACING * (NUM_PAGES - 1)) + (FRAME_PADDING * 2) + 80  -- +80 for title and header row
    
    -- Main frame
    local frame = CreateFrame("Frame", "ConsoleUIPlacementFrame", UIParent)
    frame:SetWidth(frameWidth)
    frame:SetHeight(frameHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetAlpha(1.0)  -- Ensure frame itself is fully opaque
    frame:Hide()
    
    -- Create completely solid opaque background
    -- Use backdrop with solid texture and multiple background layers
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    -- Set backdrop to fully opaque black (multiple times to ensure)
    frame:SetBackdropColor(0, 0, 0, 1.0)
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Additional solid background layer behind backdrop for extra opacity
    local solidBg = frame:CreateTexture(nil, "BACKGROUND")
    solidBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    solidBg:SetAllPoints(frame)
    solidBg:SetVertexColor(0, 0, 0, 1.0)  -- Fully opaque black
    frame.solidBg = solidBg
    
    -- Title bar for dragging
    local titleRegion = CreateFrame("Frame", nil, frame)
    titleRegion:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5)
    titleRegion:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -35, -5)
    titleRegion:SetHeight(25)
    titleRegion:EnableMouse(true)
    titleRegion:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    titleRegion:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
    
    -- Title text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText(L("Place Action"))
    
    -- Close button
    local closeButton = CreateFrame("Button", "ConsoleUIPlacementCloseButton", frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        Placement:Hide()
        ClearCursor()
    end)
    
    -- Create column headers with button icons
    local labelColumnWidth = 80  -- Space for stance names and modifier icons
    
    frame.headerIcons = {}  -- Store header icons for visibility control
    for btn = 1, NUM_BUTTONS do
        local btnInfo = self.BUTTON_INFO[btn]
        if btnInfo then
            local xOffset = FRAME_PADDING + labelColumnWidth + ((btn - 1) * (BUTTON_SIZE + BUTTON_SPACING)) + (BUTTON_SIZE / 2)
            
            -- Create header icon (square to prevent stretching)
            local headerIcon = frame:CreateTexture(nil, "OVERLAY")
            headerIcon:SetWidth(ICON_SIZE + 2)
            headerIcon:SetHeight(ICON_SIZE + 2)
            headerIcon:SetTexCoord(0, 1, 0, 1)  -- Ensure proper texture coordinates
            headerIcon:SetTexture(GetIconPath(btnInfo.icon))
            headerIcon:SetPoint("TOP", frame, "TOPLEFT", xOffset, -42)
            
            -- Header icon stays visible (column may have buttons on other pages)
            frame.headerIcons[btn] = headerIcon
        end
    end
    
    -- Create action buttons grid
    self.buttons = {}
    self.buttonsByPage = {}  -- Also store by page for easier updates
    local NUM_PAGES = table.getn(self.PAGE_INFO)
    
    for page = 1, NUM_PAGES do
        self.buttonsByPage[page] = {}
        local pageInfo = self.PAGE_INFO[page]
        
        for btn = 1, NUM_BUTTONS do
            local actionSlot = pageInfo.offset + btn
            local button = self:CreateActionButton(frame, actionSlot, btn, page)
            
            -- Store the page offset for later use
            button.pageOffset = pageInfo.offset
            
            -- Hide buttons that have proxied actions assigned
            if ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied then
                if ConsoleUI.proxied:IsSlotProxied(actionSlot) then
                    button:Hide()
                end
            end
            
            self.buttons[actionSlot] = button
            self.buttonsByPage[page][btn] = button
        end
    end
    
    -- Row labels (stance icons with text and modifier icons)
    -- Position them inside the frame, to the left of the buttons
    local labelColumnWidth = 80  -- Space for stance icons and modifier icons
    local NUM_PAGES = table.getn(self.PAGE_INFO)
    local STANCE_ICON_SIZE = 28  -- Size for stance/form icons
    
    for page = 1, NUM_PAGES do
        local pageInfo = self.PAGE_INFO[page]
        -- Calculate Y position to center on the row
        local buttonTopY = -70 - ((page - 1) * (BUTTON_SIZE + BUTTON_SPACING))
        local rowCenterY = buttonTopY - (BUTTON_SIZE / 2)
        
        -- Create label container for row
        local labelContainer = CreateFrame("Frame", "ConsoleUIPlacementRowLabel" .. page, frame)
        labelContainer:SetWidth(75)
        labelContainer:SetHeight(BUTTON_SIZE)
        labelContainer:SetPoint("CENTER", frame, "TOPLEFT", FRAME_PADDING + (labelColumnWidth / 2), rowCenterY)
        
        -- For stance pages, show icon with text below
        if pageInfo.isStance then
            if pageInfo.texture then
                -- Create stance icon (positioned above center)
                local stanceIcon = labelContainer:CreateTexture(nil, "OVERLAY")
                stanceIcon:SetWidth(STANCE_ICON_SIZE)
                stanceIcon:SetHeight(STANCE_ICON_SIZE)
                stanceIcon:SetTexture(pageInfo.texture)
                stanceIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- Slight inset to remove border
                stanceIcon:SetPoint("TOP", labelContainer, "TOP", 0, 0)
                labelContainer.stanceIcon = stanceIcon
                
                -- Create text label below the icon
                if pageInfo.text and pageInfo.text ~= "" then
                    local stanceLabel = labelContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    stanceLabel:SetPoint("TOP", stanceIcon, "BOTTOM", 0, -2)
                    stanceLabel:SetText(pageInfo.text)
                    stanceLabel:SetTextColor(1, 0.82, 0, 1)  -- Gold color for stance names
                    stanceLabel:SetWidth(labelColumnWidth - 5)
                    stanceLabel:SetJustifyH("CENTER")
                    labelContainer.stanceLabel = stanceLabel
                end
            elseif pageInfo.text and pageInfo.text ~= "" then
                -- Fallback to text only if no texture
                local stanceLabel = labelContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                stanceLabel:SetPoint("CENTER", labelContainer, "CENTER", 0, 0)
                stanceLabel:SetText(pageInfo.text)
                stanceLabel:SetTextColor(1, 0.82, 0, 1)  -- Gold color for stance names
                labelContainer.stanceLabel = stanceLabel
            end
        end
        
        -- For modifier pages, show icons
        labelContainer.modIcons = {}
        if pageInfo.icons and table.getn(pageInfo.icons) > 0 then
            local xPos = 0
            for i = 1, table.getn(pageInfo.icons) do
                local iconName = pageInfo.icons[i]
                local modIcon = labelContainer:CreateTexture(nil, "OVERLAY")
                modIcon:SetWidth(ICON_SIZE)
                modIcon:SetHeight(ICON_SIZE)
                modIcon:SetTexCoord(0, 1, 0, 1)
                modIcon:SetTexture(GetIconPath(iconName))
                modIcon:SetPoint("RIGHT", labelContainer, "RIGHT", -xPos, 0)
                labelContainer.modIcons[i] = modIcon
                xPos = xPos + ICON_SIZE + 2
            end
        end
    end
    
    -- Add to special frames so Escape closes it
    table.insert(UISpecialFrames, "ConsoleUIPlacementFrame")
    
    self.frame = frame
    
    -- Hook to cursor for cursor navigation
    if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
        ConsoleUI.hooks:HookDynamicFrame(frame, "Spell Placement")
    end
    
    return frame
end

function Placement:CreateActionButton(parent, actionSlot, buttonIndex, pageIndex)
    local buttonName = "ConsoleUIPlacementButton" .. actionSlot
    local button = CreateFrame("Button", buttonName, parent)
    
    -- Position (accounting for header row and label column)
    local labelColumnWidth = 80  -- Space for stance names and modifier icons
    local xOffset = FRAME_PADDING + labelColumnWidth + ((buttonIndex - 1) * (BUTTON_SIZE + BUTTON_SPACING))
    local yOffset = -70 - ((pageIndex - 1) * (BUTTON_SIZE + BUTTON_SPACING))
    
    button:SetWidth(BUTTON_SIZE)
    button:SetHeight(BUTTON_SIZE)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    
    -- Background
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-Quickslot2",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        tileSize = 0,
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    button:SetBackdropColor(0.2, 0.2, 0.2, 1.0)  -- Fully opaque background
    button:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)  -- Visible border
    
    -- Icon texture (with padding for controller icons at bottom)
    -- Keep icon square to prevent stretching
    local iconSize = BUTTON_SIZE - 10  -- Padding from edges
    local icon = button:CreateTexture(buttonName .. "Icon", "ARTWORK")
    icon:SetWidth(iconSize)
    icon:SetHeight(iconSize)  -- Square to prevent stretching
    icon:SetPoint("CENTER", button, "CENTER", 0, 4)  -- Slightly above center to leave room for controller icons
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)  -- Slight padding in texture coords to prevent edge clipping
    button.icon = icon
    
    -- Controller button icons overlay
    local btnInfo = self.BUTTON_INFO[buttonIndex]
    local pageInfo = self.PAGE_INFO and self.PAGE_INFO[pageIndex]
    
    -- Create icon container (positioned at bottom-left with proper padding)
    local iconContainer = CreateFrame("Frame", nil, button)
    local numModIcons = 0
    if pageInfo and pageInfo.icons then
        numModIcons = table.getn(pageInfo.icons)
    end
    local iconContainerWidth = (numModIcons + 1) * ICON_SIZE + (numModIcons * 2)  -- Icons + spacing
    iconContainer:SetWidth(iconContainerWidth)
    iconContainer:SetHeight(ICON_SIZE)
    iconContainer:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 4, 4)  -- Proper padding from bottom-left corner
    iconContainer:SetFrameLevel(button:GetFrameLevel() + 2)
    button.iconContainer = iconContainer
    
    -- Store icons for later refresh
    button.iconContainer.modIcons = {}
    button.iconContainer.mainIcon = nil
    
    -- Add modifier icons first (LT, RT) - positioned from left
    local xPos = 0
    if pageInfo and pageInfo.icons then
        for i = 1, table.getn(pageInfo.icons) do
            local modIconName = pageInfo.icons[i]
            local modIcon = iconContainer:CreateTexture(nil, "OVERLAY")
            modIcon:SetWidth(ICON_SIZE)
            modIcon:SetHeight(ICON_SIZE)
            modIcon:SetTexCoord(0, 1, 0, 1)  -- Ensure proper texture coordinates
            modIcon:SetTexture(GetIconPath(modIconName))
            modIcon:SetPoint("LEFT", iconContainer, "LEFT", xPos, 0)
            button.iconContainer.modIcons[i] = modIcon
            xPos = xPos + ICON_SIZE + 2  -- 2px spacing between icons
        end
    end
    
    -- Add main button icon
    if btnInfo then
        local mainIcon = iconContainer:CreateTexture(nil, "OVERLAY")
        mainIcon:SetWidth(ICON_SIZE)
        mainIcon:SetHeight(ICON_SIZE)
        mainIcon:SetTexCoord(0, 1, 0, 1)  -- Ensure proper texture coordinates
        mainIcon:SetTexture(GetIconPath(btnInfo.icon))
        mainIcon:SetPoint("LEFT", iconContainer, "LEFT", xPos, 0)
        button.iconContainer.mainIcon = mainIcon
    end
    
    -- Store action slot
    button.actionSlot = actionSlot
    button.buttonIndex = buttonIndex
    button.pageIndex = pageIndex
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(button)
    
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
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        local slot = this.actionSlot
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if HasAction(slot) then
            GameTooltip:SetAction(slot)
            -- Prompts will be added automatically by tooltip system: A = Pickup/Place, B = Clear
        else
            local btnInfo = Placement.BUTTON_INFO[this.buttonIndex]
            local pageInfo = Placement.PAGE_INFO and Placement.PAGE_INFO[this.pageIndex]
            local slotName = btnInfo and btnInfo.name or ("Slot " .. this.buttonIndex)
            if pageInfo and pageInfo.text and pageInfo.text ~= "" then
                slotName = pageInfo.text .. " + " .. slotName
            end
            GameTooltip:SetText(slotName)
            GameTooltip:AddLine("Empty slot", 0.7, 0.7, 0.7)
            -- Prompts will be added automatically by tooltip system: A = Pickup/Place, B = Clear
        end
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
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
        button:SetBackdropColor(0.2, 0.2, 0.2, 1.0)  -- Fully opaque
    else
        button.icon:Hide()
        button:SetBackdropColor(0.15, 0.15, 0.15, 1.0)  -- Fully opaque
    end
end

function Placement:UpdateAllButtons()
    if not self.buttons then return end
    
    for actionSlot, button in pairs(self.buttons) do
        self:UpdateButton(button)
    end
    
    -- Also update side bar buttons in placement frame
    for i = 1, 5 do
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
    
    -- Update header icons (stored in frame.headerIcons table)
    if self.frame.headerIcons then
        for btn = 1, NUM_BUTTONS do
            local headerIcon = self.frame.headerIcons[btn]
            if headerIcon then
                local btnInfo = self.BUTTON_INFO[btn]
                if btnInfo then
                    headerIcon:SetTexture(GetIconPath(btnInfo.icon))
                end
            end
        end
    end
    
    -- Update page modifier icons in labels
    for page = 1, NUM_PAGES do
        local labelContainer = getglobal("ConsoleUIPlacementRowLabel" .. page)
        if labelContainer and labelContainer.modIcons then
            local pageInfo = self.PAGE_INFO[page]
            if pageInfo and pageInfo.icons then
                for i = 1, table.getn(pageInfo.icons) do
                    local iconName = pageInfo.icons[i]
                    if labelContainer.modIcons[i] then
                        labelContainer.modIcons[i]:SetTexture(GetIconPath(iconName))
                    end
                end
            end
        end
    end
    
    -- Update button icons
    if self.buttons then
        for actionSlot, button in pairs(self.buttons) do
            if button.iconContainer then
                local pageIndex = button.pageIndex
                local pageInfo = self.PAGE_INFO[pageIndex]
                
                -- Update modifier icons
                if pageInfo and pageInfo.icons and button.iconContainer.modIcons then
                    for i = 1, table.getn(pageInfo.icons) do
                        local modIconName = pageInfo.icons[i]
                        if button.iconContainer.modIcons[i] then
                            button.iconContainer.modIcons[i]:SetTexture(GetIconPath(modIconName))
                        end
                    end
                end
                
                -- Update main button icon
                local buttonIndex = button.buttonIndex
                local btnInfo = self.BUTTON_INFO[buttonIndex]
                if btnInfo and button.iconContainer.mainIcon then
                    button.iconContainer.mainIcon:SetTexture(GetIconPath(btnInfo.icon))
                end
            end
        end
    end
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
    
    -- Background
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-Quickslot2",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        tileSize = 0,
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    button:SetBackdropColor(0.2, 0.2, 0.2, 1.0)
    button:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    -- Icon texture
    local iconSize = BUTTON_SIZE - 10
    local icon = button:CreateTexture(buttonName .. "Icon", "ARTWORK")
    icon:SetWidth(iconSize)
    icon:SetHeight(iconSize)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    button.icon = icon
    
    -- Store action slot and info
    button.actionSlot = actionSlot
    button.buttonIndex = buttonIndex
    button.pageIndex = 1  -- Side bars don't have pages, use 1 for consistency
    button.side = side
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(button)
    
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
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if HasAction(this.actionSlot) then
            GameTooltip:SetAction(this.actionSlot)
        else
            local sideName = this.side == "left" and "Left" or "Right"
            GameTooltip:SetText(sideName .. " Side Bar " .. this.buttonIndex)
            GameTooltip:AddLine("Empty slot (touch screen)", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
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
        button:SetBackdropColor(0.2, 0.2, 0.2, 1.0)
    else
        button.icon:Hide()
        button:SetBackdropColor(0.15, 0.15, 0.15, 1.0)
    end
end

function Placement:UpdateSideBarButtons()
    if not self.frame then return end
    
    local config = ConsoleUI.config
    if not config then return end
    
    local leftEnabled = config:Get("sideBarLeftEnabled")
    local rightEnabled = config:Get("sideBarRightEnabled")
    local leftCount = config:Get("sideBarLeftButtons") or 3
    local rightCount = config:Get("sideBarRightButtons") or 3
    
    -- Clamp counts
    if leftCount < 1 then leftCount = 1 end
    if leftCount > 5 then leftCount = 5 end
    if rightCount < 1 then rightCount = 1 end
    if rightCount > 5 then rightCount = 5 end
    
    -- Side bar action slot offsets
    local LEFT_OFFSET = 40   -- Slots 41-45
    local RIGHT_OFFSET = 45  -- Slots 46-50
    
    -- Create/update left side bar container in placement frame
    if not self.sideBarLeftFrame then
        self.sideBarLeftFrame = CreateFrame("Frame", "ConsoleUIPlacementSideBarLeft", self.frame)
        self.sideBarLeftFrame:SetFrameLevel(self.frame:GetFrameLevel() + 1)
        
        -- Label for left side bar
        local label = self.sideBarLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", self.sideBarLeftFrame, "TOP", 0, 15)
        label:SetText("Left Touch")
        self.sideBarLeftFrame.label = label
    end
    
    if not self.sideBarRightFrame then
        self.sideBarRightFrame = CreateFrame("Frame", "ConsoleUIPlacementSideBarRight", self.frame)
        self.sideBarRightFrame:SetFrameLevel(self.frame:GetFrameLevel() + 1)
        
        -- Label for right side bar
        local label = self.sideBarRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", self.sideBarRightFrame, "TOP", 0, 15)
        label:SetText("Right Touch")
        self.sideBarRightFrame.label = label
    end
    
    -- Position side bar frames below the main grid
    local NUM_PAGES = self.PAGE_INFO and table.getn(self.PAGE_INFO) or 4
    local mainGridBottom = -70 - ((NUM_PAGES - 1) * (BUTTON_SIZE + BUTTON_SPACING)) - BUTTON_SIZE - 20
    
    -- Left side bar
    if leftEnabled then
        local totalWidth = (BUTTON_SIZE * leftCount) + (BUTTON_SPACING * (leftCount - 1))
        self.sideBarLeftFrame:SetWidth(totalWidth)
        self.sideBarLeftFrame:SetHeight(BUTTON_SIZE + 20)
        self.sideBarLeftFrame:ClearAllPoints()
        self.sideBarLeftFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", FRAME_PADDING + 50, mainGridBottom)
        self.sideBarLeftFrame:Show()
        
        -- Create/update buttons horizontally
        for i = 1, 5 do
            if i <= leftCount then
                local actionSlot = LEFT_OFFSET + i
                if not self.sideBarLeftButtons[i] then
                    self.sideBarLeftButtons[i] = self:CreateSideBarPlacementButton(self.sideBarLeftFrame, actionSlot, i, "left")
                end
                local button = self.sideBarLeftButtons[i]
                button.actionSlot = actionSlot
                button:ClearAllPoints()
                local xOffset = (i - 1) * (BUTTON_SIZE + BUTTON_SPACING)
                button:SetPoint("TOPLEFT", self.sideBarLeftFrame, "TOPLEFT", xOffset, 0)
                button:Show()
                self:UpdateSideBarPlacementButton(button)
            else
                if self.sideBarLeftButtons[i] then
                    self.sideBarLeftButtons[i]:Hide()
                end
            end
        end
    else
        if self.sideBarLeftFrame then
            self.sideBarLeftFrame:Hide()
        end
        for i = 1, 5 do
            if self.sideBarLeftButtons[i] then
                self.sideBarLeftButtons[i]:Hide()
            end
        end
    end
    
    -- Right side bar
    if rightEnabled then
        local totalWidth = (BUTTON_SIZE * rightCount) + (BUTTON_SPACING * (rightCount - 1))
        self.sideBarRightFrame:SetWidth(totalWidth)
        self.sideBarRightFrame:SetHeight(BUTTON_SIZE + 20)
        self.sideBarRightFrame:ClearAllPoints()
        self.sideBarRightFrame:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -FRAME_PADDING, mainGridBottom)
        self.sideBarRightFrame:Show()
        
        -- Create/update buttons horizontally
        for i = 1, 5 do
            if i <= rightCount then
                local actionSlot = RIGHT_OFFSET + i
                if not self.sideBarRightButtons[i] then
                    self.sideBarRightButtons[i] = self:CreateSideBarPlacementButton(self.sideBarRightFrame, actionSlot, i, "right")
                end
                local button = self.sideBarRightButtons[i]
                button.actionSlot = actionSlot
                button:ClearAllPoints()
                local xOffset = -((rightCount - i) * (BUTTON_SIZE + BUTTON_SPACING))
                button:SetPoint("TOPRIGHT", self.sideBarRightFrame, "TOPRIGHT", xOffset, 0)
                button:Show()
                self:UpdateSideBarPlacementButton(button)
            else
                if self.sideBarRightButtons[i] then
                    self.sideBarRightButtons[i]:Hide()
                end
            end
        end
    else
        if self.sideBarRightFrame then
            self.sideBarRightFrame:Hide()
        end
        for i = 1, 5 do
            if self.sideBarRightButtons[i] then
                self.sideBarRightButtons[i]:Hide()
            end
        end
    end
    
    -- Adjust main frame height if side bars are enabled
    local NUM_PAGES = self.PAGE_INFO and table.getn(self.PAGE_INFO) or 4
    if leftEnabled or rightEnabled then
        local baseHeight = (BUTTON_SIZE * NUM_PAGES) + (BUTTON_SPACING * (NUM_PAGES - 1)) + (FRAME_PADDING * 2) + 80
        self.frame:SetHeight(baseHeight + BUTTON_SIZE + 40)  -- Extra space for side bar row
    else
        local baseHeight = (BUTTON_SIZE * NUM_PAGES) + (BUTTON_SPACING * (NUM_PAGES - 1)) + (FRAME_PADDING * 2) + 80
        self.frame:SetHeight(baseHeight)
    end
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
