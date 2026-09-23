--[[
    ConsoleUI - Configuration Module

    Settings window. Gold/charcoal chrome. WoW 1.12 frames only.
]]

-- Create the config module namespace
ConsoleUI.config = ConsoleUI.config or {}
local Config = ConsoleUI.config

-- ============================================================================
-- Default Configuration Values
-- ============================================================================

Config.DEFAULTS = {
    debugEnabled = false,
    -- Interface settings
    crosshairEnabled = true,
    crosshairX = 0,
    crosshairY = 50,
    crosshairSize = 24,
    crosshairType = "cross",  -- "cross" or "dot"
    crosshairColorR = 1.0,    -- Red component (0-1)
    crosshairColorG = 1.0,    -- Green component (0-1)
    crosshairColorB = 1.0,    -- Blue component (0-1)
    crosshairColorA = 0.8,    -- Alpha component (0-1)
    controllerType = "xbox",  -- "xbox" or "ps"
    controllerGlyphSize = "small",  -- "small" | "medium" | "large"
    healerMode = false,  -- Healer mode (affects targeting and gameplay)
    -- Mouse Look engine, lock policy, camera settings, and unlock policy.
    mouseLookEnabled = true,
    mouseLookLockOnMovement = true,
    mouseLookLockOnActions = true,
    mouseLookInvertX = false,
    mouseLookInvertY = false,
    mouseLookMouseSpeed = 1,
    -- Right-click is the only automatic unlock enabled by default.
    mouseLookUnlockRightClick = true,
    mouseLookUnlockModifierDoubleTap = false,
    mouseLookUnlockGameMenu = false,
    mouseLookUnlockBags = false,
    mouseLookUnlockWorldMap = false,
    mouseLookUnlockCharacter = false,
    mouseLookUnlockSpellbook = false,
    mouseLookUnlockTalents = false,
    mouseLookUnlockQuests = false,
    mouseLookUnlockSocial = false,
    mouseLookUnlockCommerce = false,
    mouseLookUnlockProfessions = false,
    mouseLookUnlockOtherWindows = false,
    -- Action Bar settings
    barButtonSize = 82,
    barXOffset = 0,
    barYOffset = 70,
    barPadding = 65,
    barStarPadding = 600,  -- Screen px between left/right cluster centers. Not scaled.
    barScale = 1.0,
    -- Sidebars only. Main 1-10 are diamonds.
    barAppearance = "classic",
    -- controller = diamonds. flat = one row of squares. full = three diamond controller sets.
    barLayout = "controller",
    barActionGlyphs = true,
    barGoldBorder = false,
    barGoldColorR = 1.00,
    barGoldColorG = 0.82,
    barGoldColorB = 0.18,
    barFlankGap = 50,
    autoRankEnabled = true,  -- Automatically update spells to highest rank
    druidStealth = false,  -- Use travel form bar when prowl/stealth is active in cat form
    -- Side Action Bars (touch screen)
    sideBarLeftEnabled = false,  -- Left side bar disabled by default
    sideBarRightEnabled = false,  -- Right side bar disabled by default
    sideBarLeftButtons = 3,  -- Number of buttons on left bar (1-5)
    sideBarRightButtons = 3,  -- Number of buttons on right bar (1-5)
    sideBarLeftOffset = 5,  -- Safe-area distance from the left edge
    sideBarRightOffset = 5, -- Safe-area distance from the right edge
    sideBarLeftYOffset = 0, -- Vertical offset from screen middle (left touch bar)
    sideBarRightYOffset = 0,-- Vertical offset from screen middle (right touch bar)
    sideBarLeftScale = 1.0, -- Scales the complete left touch-bar cluster
    sideBarRightScale = 1.0,-- Scales the complete right touch-bar cluster
    -- XP/Rep Bar settings
    xpBarWidth = nil,  -- nil = default 400
    xpBarHeight = 16,  -- HTML inner track. Do not change without bars-plan.html.
    xpBarDisplay = "XP",  -- "XP", "PETXP", "REP", "FLEX", "XPFLEX"
    xpBarAlways = true,  -- XP bar visible by default
    xpBarTimeout = 5.0,  -- Seconds before bar fades out
    xpBarTextShow = true,
    xpBarTextMouse = false,
    xpBarTextOffsetY = 0,
    xpBarOffsetX = 0,
    xpBarOffsetY = 16,     -- Lift off the screen edge.
    xpBarColor = "0.0,1.0,0.0,1.0",  -- WoW default green for XP
    xpBarRestColor = "0.0,0.5,1.0,1.0",  -- WoW default blue for rested
    xpBarDontOverlap = false,
    repBarWidth = nil,  -- nil = default 400
    repBarHeight = 16,
    repBarDisplay = "REP",  -- "REP", "FLEX"
    repBarAlways = false,  -- Rep bar hidden by default
    repBarTimeout = 5.0,  -- Seconds before bar fades out
    repBarTextShow = true,
    repBarTextMouse = false,
    repBarTextOffsetY = 0,
    repBarOffsetX = 0,
    repBarOffsetY = 16,
    -- Castbar settings
    castbarEnabled = true,  -- Castbar enabled by default
    castbarHeight = 6,      -- Thin strip. Text sits under it.
    castbarOffsetX = 0,
    castbarOffsetY = 16,    -- Extra gap above the XP stack.
    castbarColorR = 1.00,   -- Gold, same as CP screenshot
    castbarColorG = 0.82,
    castbarColorB = 0.18,
    castbarChannelColorR = 1.0,    -- Gold by default (for channeling)
    castbarChannelColorG = 0.75,
    castbarChannelColorB = 0.25,
    -- Swing timer settings
    swingBarEnabled = true,
    swingBarWidth = 400,
    swingBarHeight = 4,
    swingBarGap = 8,
    swingBarOffsetX = 0,
    swingBarOffsetY = 0,
    swingBarShowMainLabel = true,
    swingBarShowOffLabel = true,
    swingBarShowRangedLabel = true,
    swingBarShowTimer = true,
    swingBarShowSpark = true,
    swingBarCombatOnly = true,
    swingBarFadeDuration = 0.25,
    swingBarColorR = 1.00,
    swingBarColorG = 0.82,
    swingBarColorB = 0.18,
    -- Keybinding settings (proxied actions are now managed by config/proxied.lua)
    -- Locale settings
    language = nil,  -- nil = use game locale, otherwise "enUS", "deDE", etc.
    -- Bag settings
    alwaysOpenAllBags = true,
    openAllBagsAtVendor = true,  -- Open all bags when interacting with merchants/auction house
    -- Dropdown navigation settings
    dropdownNavEnabled = true,  -- Enable cursor navigation in dropdown menus
    hideBlizzardBars = true,  -- Hide Blizzard action/micro bars; uncheck to restore
    stanceBarOffsetX = 0,
    stanceBarOffsetY = -180,
    stanceBarScale = 1.0,
    petBarOffsetX = 0,
    petBarOffsetY = 40,
    petBarScale = 1.0,
    petBarGrow = "right",
    extraBarsUnlocked = false,
    lootFrameEnabled = true,
    lootRollEnabled = true,
    hintBarEnabled = true,
    tooltipActionHints = true,
    hintBarPosition = "top",
    hintBarOffsetX = 0,
    hintBarOffsetY = 0,
    hintBarScale = 1.0,
}

-- ============================================================================
-- Configuration Get/Set Functions
-- ============================================================================

function Config:InitializeDB()
    -- Ensure ConsoleUIDB exists
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    -- Empty saved vars = first run. Existing config/profiles skip the guide.
    local fresh = ConsoleUIDB.config == nil and ConsoleUIDB.profiles == nil
    
    -- Initialize profiles system first (handles migration from legacy config)
    if ConsoleUI.profiles and ConsoleUI.profiles.Initialize then
        ConsoleUI.profiles:Initialize()
    end
    
    -- Initialize config section if it doesn't exist (profiles migration should have done this, but be safe)
    if not ConsoleUIDB.config then
        ConsoleUIDB.config = {}
    end
    
    -- Set defaults for any missing values (generic - automatically adds new defaults)
    for key, defaultValue in pairs(self.DEFAULTS) do
        if ConsoleUIDB.config[key] == nil then
            ConsoleUIDB.config[key] = defaultValue
            ConsoleUI_Debug("Config: Added missing default '" .. key .. "' = " .. tostring(defaultValue))
        end
    end
    if ConsoleUIDB.config.onboardingSeen == nil then
        ConsoleUIDB.config.onboardingSeen = not fresh
    end
    if fresh and ConsoleUI.changelog and ConsoleUI.changelog.StampIfEmpty then
        ConsoleUI.changelog:StampIfEmpty()
    end

    if not ConsoleUIDB.config.barSizeV2 then
        if ConsoleUIDB.config.barButtonSize == 60 then
            ConsoleUIDB.config.barButtonSize = 82
        end
        ConsoleUIDB.config.barSizeV2 = true
    end
    if not ConsoleUIDB.config.watchBarV2 then
        -- Old min was 20 for 9-slice. CP watch art is 16.
        if ConsoleUIDB.config.xpBarHeight == 20 then
            ConsoleUIDB.config.xpBarHeight = 16
        end
        if ConsoleUIDB.config.repBarHeight == 20 then
            ConsoleUIDB.config.repBarHeight = 16
        end
        ConsoleUIDB.config.watchBarV2 = true
    end
    if not ConsoleUIDB.config.castBarThinV1 then
        if ConsoleUIDB.config.castbarHeight == 14 then
            ConsoleUIDB.config.castbarHeight = 8
        end
        ConsoleUIDB.config.castBarThinV1 = true
    end
    if not ConsoleUIDB.config.castBarCPV1 then
        if ConsoleUIDB.config.castbarHeight == 8 then
            ConsoleUIDB.config.castbarHeight = 14
        end
        if ConsoleUIDB.config.castbarColorR == 0 and ConsoleUIDB.config.castbarColorG == 0.5 then
            ConsoleUIDB.config.castbarColorR = 1.00
            ConsoleUIDB.config.castbarColorG = 0.82
            ConsoleUIDB.config.castbarColorB = 0.18
        end
        ConsoleUIDB.config.castBarCPV1 = true
    end
    if not ConsoleUIDB.config.castBarSlimV1 then
        if ConsoleUIDB.config.castbarHeight == 14 or ConsoleUIDB.config.castbarHeight == 8 then
            ConsoleUIDB.config.castbarHeight = 6
        end
        ConsoleUIDB.config.castBarSlimV1 = true
    end
    if ConsoleUIDB.config.extraBarScaleV1 and not ConsoleUIDB.config.extraBarScaleV2 then
        if ConsoleUIDB.config.stanceBarScale == 0.8 then
            ConsoleUIDB.config.stanceBarScale = 1.0
        end
        if ConsoleUIDB.config.petBarScale == 0.6 then
            ConsoleUIDB.config.petBarScale = 1.0
        end
        ConsoleUIDB.config.extraBarScaleV2 = true
    end
    
    -- Initialize locale if available
    if ConsoleUI.locale then
        ConsoleUI.locale:Initialize()
    end
    
    -- Apply debug setting to global variable
    ConsoleUI_DEBUG_KEYS = ConsoleUIDB.config.debugEnabled
    
    -- Apply crosshair setting
    self:UpdateCrosshair()
    
    -- Apply action bar layout
    self:UpdateActionBarLayout()
    
    -- Apply XP/Rep bar layout
    if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
        ConsoleUI.xpbar:UpdateAllBars()
    end
    
    -- Apply castbar layout
    if ConsoleUI.castbar and ConsoleUI.castbar.ReloadConfig then
        ConsoleUI.castbar:ReloadConfig()
    end
    if ConsoleUI.swingbar and ConsoleUI.swingbar.ReloadConfig then
        ConsoleUI.swingbar:ReloadConfig()
    end
    if ConsoleUI.mouselook and ConsoleUI.mouselook.ApplySettings then
        ConsoleUI.mouselook:ApplySettings()
    end

    if self.InitializeUnitFrameScales then
        self:InitializeUnitFrameScales()
    end
    if ConsoleUI.actionbars and ConsoleUI.actionbars.extra and ConsoleUI.actionbars.extra.Update then
        ConsoleUI.actionbars.extra:Update()
    end
    if ConsoleUI.loot and ConsoleUI.loot.ApplyEnabled then
        ConsoleUI.loot:ApplyEnabled()
    end
    if ConsoleUI.profiles and ConsoleUI.profiles.SaveCurrentProfile then
        -- Persist defaults and one-time config migrations into the new account
        -- character profile without doing another 120-slot action-bar scan.
        ConsoleUI.profiles:SaveCurrentProfile(false)
    end
    
end

function Config:ClampTouchCount(value)
    local n = tonumber(value) or 3
    if n < 1 then n = 1 end
    if n > 5 then n = 5 end
    return math.floor(n)
end

function Config:Get(key)
    local value
    if ConsoleUIDB and ConsoleUIDB.config then
        if ConsoleUIDB.config[key] ~= nil then
            value = ConsoleUIDB.config[key]
        end
    end
    if value == nil then
        value = self.DEFAULTS[key]
    end
    if key == "sideBarLeftButtons" or key == "sideBarRightButtons" then
        return self:ClampTouchCount(value)
    end
    return value
end

function Config:HudOffset(key, fallback)
    local n = tonumber(self:Get(key))
    if not n then
        n = fallback or 0
    end
    if n < -500 then
        return -500
    end
    if n > 500 then
        return 500
    end
    return n
end

function Config:RefreshExtraOffsetBoxes()
    local boxes = self.extraOffsetBoxes
    if not boxes then
        return
    end
    if boxes.stanceX then
        boxes.stanceX:SetText(tostring(tonumber(self:Get("stanceBarOffsetX")) or 0))
    end
    if boxes.stanceY then
        boxes.stanceY:SetText(tostring(tonumber(self:Get("stanceBarOffsetY")) or -180))
    end
    if boxes.petX then
        boxes.petX:SetText(tostring(tonumber(self:Get("petBarOffsetX")) or 0))
    end
    if boxes.petY then
        boxes.petY:SetText(tostring(tonumber(self:Get("petBarOffsetY")) or 40))
    end
end

function Config:HudOffsetFromText(value)
    local n = tonumber(value) or 0
    if n < -500 then
        return -500
    end
    if n > 500 then
        return 500
    end
    return n
end

function Config:AddOffsetRow(box, anchor, xKey, yKey, onChange, limit, rowY)
    local function clip(value)
        local n = tonumber(value) or 0
        if limit == false then
            return n
        end
        local cap = tonumber(limit) or 500
        if n < -cap then
            return -cap
        end
        if n > cap then
            return cap
        end
        return n
    end
    local xTip = "Horizontal offset in pixels."
    local yTip = "Vertical offset in pixels. Positive is up."
    if limit ~= false then
        local cap = tonumber(limit) or 500
        xTip = xTip .. " Range: -" .. cap .. " to " .. cap .. "."
        yTip = yTip .. " Range: -" .. cap .. " to " .. cap .. "."
    end
    local xLabel = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if rowY then
        xLabel:SetPoint("TOPLEFT", box, "TOPLEFT", box.contentLeft, rowY)
    else
        xLabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
    end
    xLabel:SetWidth(14)
    xLabel:SetHeight(20)
    xLabel:SetJustifyH("LEFT")
    xLabel:SetText("X:")
    local xBox = self:CreateEditBox(box, 42,
        function() return tostring(clip(self:Get(xKey))) end,
        function(value)
            self:Set(xKey, clip(value))
            if onChange then
                onChange()
            end
        end,
        "X Offset",
        xTip,
        self.NUDGE_MOVE)
    xBox:SetPoint("TOPLEFT", xLabel, "TOPRIGHT", 5, 0)
    local yLabel = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", xBox, "TOPRIGHT", 12, 0)
    yLabel:SetWidth(14)
    yLabel:SetHeight(20)
    yLabel:SetJustifyH("LEFT")
    yLabel:SetText("Y:")
    local yBox = self:CreateEditBox(box, 42,
        function() return tostring(clip(self:Get(yKey))) end,
        function(value)
            self:Set(yKey, clip(value))
            if onChange then
                onChange()
            end
        end,
        "Y Offset",
        yTip,
        self.NUDGE_MOVE)
    yBox:SetPoint("TOPLEFT", yLabel, "TOPRIGHT", 5, 0)
    return xBox, yBox
end

function Config:Set(key, value)
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.config then
        ConsoleUIDB.config = {}
    end
    if key == "sideBarLeftButtons" or key == "sideBarRightButtons" then
        value = self:ClampTouchCount(value)
    end
    ConsoleUIDB.config[key] = value
    
    -- Apply certain settings immediately
    if key == "debugEnabled" then
        ConsoleUI_DEBUG_KEYS = value
    end
    if string.find(key, "^mouseLook")
        and ConsoleUI.mouselook and ConsoleUI.mouselook.ApplySettings then
        ConsoleUI.mouselook:ApplySettings(key)
    end
    if ConsoleUI.profiles and ConsoleUI.profiles.MarkDirty then
        ConsoleUI.profiles:MarkDirty(false)
    end
end

-- ============================================================================
-- Constants
-- ============================================================================

Config.FRAME_WIDTH = 900
Config.FRAME_HEIGHT = 650
Config.SIDEBAR_WIDTH = 184
Config.EDIT_BOX_WIDTH = 56
Config.NUDGE_MOVE = 5
Config.NUDGE_SCALE = 0.1
Config.BUTTON_HEIGHT = 40
Config.PADDING = 8
Config.HEADER_HEIGHT = 62
Config.FOOTER_HEIGHT = 54
Config.MARK = "Interface\\AddOns\\ConsoleUI\\textures\\brand\\Mark"

-- Gold/charcoal. Matches settings-plan.html. Gold token matches ring spec.
Config.UI_COLORS = {
    gold = {1.00, 0.82, 0.18, 1.00},
    panel = {0.067, 0.071, 0.086, 0.98},
    header = {0.082, 0.086, 0.106, 0.98},
    content = {0.078, 0.082, 0.098, 0.96},
    section = {0.094, 0.102, 0.122, 0.96},
    inset = {0.078, 0.082, 0.102, 0.96},
    button = {0.125, 0.129, 0.153, 0.98},
    border = {1.00, 1.00, 1.00, 0.14},
    borderStrong = {1.00, 1.00, 1.00, 0.20},
    idle = {0.04, 0.04, 0.05, 0.0},
    hover = {0.125, 0.129, 0.145, 0.92},
    active = {0.145, 0.122, 0.055, 0.96},
    accent = {1.00, 0.82, 0.18, 1.00},
    muted = {0.545, 0.561, 0.596, 1.00},
    text = {0.945, 0.949, 0.957, 1.00},
    danger = {0.835, 0.302, 0.361, 1.00},
}

Config.BACKDROP_PANEL = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

Config.BACKDROP_CARD = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

Config.BACKDROP_FLAT = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true, tileSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

-- Xbox/PS/D-pad glyphs. small = current 22px HUD pip.
Config.GLYPH_PX = {
    small = { hud = 22, ui = 18, tip = 16 },
    medium = { hud = 32, ui = 24, tip = 22 },
    large = { hud = 44, ui = 28, tip = 28 },
}

function Config:GetGlyphSize(kind)
    kind = kind or "hud"
    local key = "small"
    if self.Get then
        key = self:Get("controllerGlyphSize") or "small"
    end
    local row = self.GLYPH_PX[key] or self.GLYPH_PX.small
    return row[kind] or row.hud
end

function Config:RefreshGlyphControls()
    if not UIDropDownMenu_SetSelectedValue or not UIDropDownMenu_SetText then
        return
    end
    local style = self:Get("controllerType") or "xbox"
    local styleText = style == "ps" and "PlayStation" or "Xbox"
    local styleNames = {
        "ConsoleUIConfigControllerTypeDropdown",
        "ConsoleUIConfigGlyphStyleDropdown",
    }
    local i
    for i = 1, table.getn(styleNames) do
        local frame = getglobal and getglobal(styleNames[i]) or nil
        if frame then
            UIDropDownMenu_SetSelectedValue(frame, style)
            UIDropDownMenu_SetText(styleText, frame)
        end
    end

    local size = self:Get("controllerGlyphSize") or "small"
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    local sizeText = T("Small")
    if size == "medium" then sizeText = T("Medium") end
    if size == "large" then sizeText = T("Large") end
    local sizeNames = {
        "ConsoleUIConfigGlyphSizeDropdown",
        "ConsoleUIConfigGlyphSizePageDropdown",
    }
    for i = 1, table.getn(sizeNames) do
        local frame = getglobal and getglobal(sizeNames[i]) or nil
        if frame then
            UIDropDownMenu_SetSelectedValue(frame, size)
            UIDropDownMenu_SetText(sizeText, frame)
        end
    end
end

function Config:ApplyControllerGlyphs()
    self:RefreshGlyphControls()
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
        ConsoleUI.actionbars:UpdateAllButtons()
    end
    if self.UpdateActionBarLayout then
        self:UpdateActionBarLayout()
    end
    if ConsoleUI.placement and ConsoleUI.placement.RefreshIcons then
        ConsoleUI.placement:RefreshIcons()
    end
    if self.RefreshBindingIcons then
        self:RefreshBindingIcons()
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.tooltip then
        if ConsoleUI.cursor.tooltip.ApplyControllerStyle then
            ConsoleUI.cursor.tooltip:ApplyControllerStyle()
        elseif ConsoleUI.cursor.tooltip.ApplyGlyphSize then
            ConsoleUI.cursor.tooltip:ApplyGlyphSize()
        end
    end
    if ConsoleUI.loot and ConsoleUI.loot.PaintChrome then
        ConsoleUI.loot:PaintChrome()
    elseif ConsoleUI.loot and ConsoleUI.loot.PaintHints then
        ConsoleUI.loot:PaintHints()
    end
    if ConsoleUI.unit and ConsoleUI.unit.PaintHints then
        ConsoleUI.unit:PaintHints()
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
        ConsoleUI.cursor.hintbar:Refresh()
    end
end

function Config:Paint(parent, layer, r, g, b, a)
    local tex = parent:CreateTexture(nil, layer)
    tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    tex:SetVertexColor(r, g, b, a)
    return tex
end

function Config:GetHudBorderColor()
    local function clamp(v, fallback)
        v = tonumber(v)
        if not v then
            return fallback
        end
        if v < 0 then
            return 0
        end
        if v > 1 then
            return 1
        end
        return v
    end
    return clamp(self:Get("barGoldColorR"), 1.00),
           clamp(self:Get("barGoldColorG"), 0.82),
           clamp(self:Get("barGoldColorB"), 0.18)
end

-- bars-plan.html Proposed: 400x16 inner trap, cut 14, 4px black rim, gray ticks.
-- White.tga is a solid texel. Tooltip-Background is dark — gold * dark = beige.
-- Do not use ConsolePort XPBar.tga. Square backdrop hides the cut — no backdrop.
Config.STATUS_BAR_FLAT = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
Config.STATUS_BAR_WHITE = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
Config.STATUS_BAR_WATCH_BACK = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\WatchRim"
Config.STATUS_BAR_WATCH_FILL = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\WatchFillShade"
Config.WATCH_FILL_DIM = 0.78
Config.STATUS_BAR_TRACK = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
Config.STATUS_BAR_INSET = 0
Config.WATCH_BORDER_PAD = 4
Config.WATCH_GAP_COUNT = 9
Config.WATCH_TICK_WIDTH = 1
Config.WATCH_TICK_R = 0.2
Config.WATCH_TICK_G = 0.2
Config.WATCH_TICK_B = 0.2

function Config:EnsureStatusBarChrome(frame)
    if not frame or frame.cuiChrome then
        return
    end
    -- No square backdrop. It fills the TGA's transparent corners.
    if frame.SetBackdrop then
        frame:SetBackdrop(nil)
    end
    local chrome = CreateFrame("Frame", nil, frame)
    chrome:SetAllPoints(frame)
    self:StackAbove(chrome, frame)
    frame.cuiChrome = chrome
end

function Config:HideWatchTicks(frame)
    if not frame then
        return
    end
    if frame.cuiNotch then
        frame.cuiNotch:Hide()
    end
    if frame.cuiTicks then
        local i
        for i = 1, table.getn(frame.cuiTicks) do
            if frame.cuiTicks[i] then
                frame.cuiTicks[i]:Hide()
            end
        end
    end
    if frame.cuiPips then
        local i
        for i = 1, table.getn(frame.cuiPips) do
            if frame.cuiPips[i] then
                frame.cuiPips[i]:Hide()
            end
        end
    end
end

function Config:WatchWideBottom(frame)
    -- XP: wide bottom (CP). Rep: flipped, wide top, so the pair kisses.
    if frame and frame.barType == "REP" then
        return false
    end
    return true
end

function Config:WatchTexV(frame)
    if self:WatchWideBottom(frame) then
        return 1, 0
    end
    return 0, 1
end

function Config:EnsureWatchOverlay(frame)
    if not frame or not frame.cuiChrome then
        return
    end
    self:HideWatchTicks(frame)
    if not frame.cuiWatchBack then
        local back = frame:CreateTexture(nil, "BACKGROUND")
        back:SetTexture(self.STATUS_BAR_WATCH_BACK)
        frame.cuiWatchBack = back
    end
    if not frame.cuiGapGold then
        frame.cuiGapGold = {}
        local i
        for i = 1, self.WATCH_GAP_COUNT do
            local line = frame:CreateTexture(nil, "OVERLAY")
            line:SetTexture(self.STATUS_BAR_WHITE)
            line:SetWidth(self.WATCH_TICK_WIDTH or 1)
            frame.cuiGapGold[i] = line
        end
    end
    if frame.cuiWatchGaps then
        frame.cuiWatchGaps:Hide()
    end
    if frame.cuiWatchBody then
        frame.cuiWatchBody:Hide()
    end
    if not frame.cuiText then
        local textFrame = CreateFrame("Frame", nil, frame)
        textFrame:SetAllPoints(frame)
        self:StackAbove(textFrame, frame.cuiChrome)
        frame.cuiText = textFrame
    end
end

function Config:StackAbove(frame, parent)
    if not frame or not frame.SetFrameLevel or not parent then
        return
    end
    local base = 1
    if parent.GetFrameLevel then
        base = parent:GetFrameLevel() or 1
    end
    -- 1.12 errors if a child jumps many levels past its parent.
    frame:SetFrameLevel(base + 1)
end

function Config:HideStockFill(statusBar)
    if not statusBar then
        return
    end
    -- 1.12 StatusBar redraws this on SetValue. It is a rectangle and
    -- paints over XPBar.tga's cut corners. Kill it every sync.
    local stock = statusBar.GetStatusBarTexture and statusBar:GetStatusBarTexture()
    if stock then
        if stock.SetAlpha then
            stock:SetAlpha(0)
        end
        if stock.Hide then
            stock:Hide()
        end
    end
end

function Config:EnsureWatchFill(statusBar)
    if not statusBar then
        return
    end
    self:HideStockFill(statusBar)
    local host = statusBar
    if statusBar.GetParent then
        host = statusBar:GetParent() or statusBar
    end
    local layer = "ARTWORK"
    if host.restedbar == statusBar then
        layer = "BORDER"
    end
    if statusBar.cuiWatchFill then
        local fill = statusBar.cuiWatchFill
        if fill.cuiTexture ~= self.STATUS_BAR_WATCH_FILL then
            fill:SetTexture(self.STATUS_BAR_WATCH_FILL)
            fill.cuiTexture = self.STATUS_BAR_WATCH_FILL
        end
        if fill.SetDrawLayer and fill.cuiLayer ~= layer then
            fill:SetDrawLayer(layer)
            fill.cuiLayer = layer
        end
        if fill.cuiAnchorHost ~= host then
            fill:ClearAllPoints()
            fill:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
            fill:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
            fill.cuiAnchorHost = host
        end
        return
    end
    local fill = host:CreateTexture(nil, layer)
    fill:SetTexture(self.STATUS_BAR_WATCH_FILL)
    fill:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
    fill:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
    fill.cuiTexture, fill.cuiLayer, fill.cuiAnchorHost = self.STATUS_BAR_WATCH_FILL, layer, host
    statusBar.cuiWatchFill = fill
    if statusBar.SetStatusBarTexture then
        statusBar:SetStatusBarTexture(self.STATUS_BAR_WHITE)
        -- Assigning a stock texture can show it again on the first sync.
        self:HideStockFill(statusBar)
    end
end

function Config:SyncWatchFill(statusBar)
    if not statusBar then
        return
    end
    self:EnsureWatchFill(statusBar)
    local fill = statusBar.cuiWatchFill
    if not fill then
        return
    end
    -- The custom fill belongs to the host, not the status bar. Hiding the
    -- rested status bar alone therefore does not hide its visible texture.
    if statusBar.IsShown and not statusBar:IsShown() then
        if fill:IsShown() then fill:Hide() end
        return
    end
    local minv, maxv = 0, 1
    if statusBar.GetMinMaxValues then
        minv, maxv = statusBar:GetMinMaxValues()
    end
    local v = 0
    if statusBar.GetValue then
        v = statusBar:GetValue() or 0
    end
    local span = (maxv or 0) - (minv or 0)
    local pct = 0
    if span > 0 then
        pct = (v - minv) / span
    end
    if pct < 0 then
        pct = 0
    end
    if pct > 1 then
        pct = 1
    end
    local host = fill.GetParent and fill:GetParent() or statusBar
    local full = 0
    if host and host.GetWidth then
        full = host:GetWidth() or 0
    end
    local width = full * pct
    if width < 1 then
        if fill:IsShown() then fill:Hide() end
        return
    end
    local top, bot = 0, 1
    if host then
        top, bot = self:WatchTexV(host)
    end
    -- Crop the trap, do not stretch it. Stretch would squash the cut.
    if fill.cuiPct ~= pct or fill.cuiTop ~= top or fill.cuiBot ~= bot then
        fill:SetTexCoord(0, pct, top, bot)
        fill.cuiPct, fill.cuiTop, fill.cuiBot = pct, top, bot
    end
    if fill.cuiWidth ~= width then
        fill:SetWidth(width)
        fill.cuiWidth = width
    end
    local r, g, b, a = 1, 1, 1, 1
    if statusBar.GetStatusBarColor then
        r, g, b, a = statusBar:GetStatusBarColor()
    end
    local dim = self.WATCH_FILL_DIM or 0.78
    r, g, b = (r or 1) * dim, (g or 1) * dim, (b or 1) * dim
    if fill.cuiR ~= r or fill.cuiG ~= g or fill.cuiB ~= b then
        fill:SetVertexColor(r, g, b, 1)
        fill.cuiR, fill.cuiG, fill.cuiB = r, g, b
    end
    if not fill:IsShown() then fill:Show() end
end

function Config:PaintStatusBarFill(bar)
    if not bar then
        return
    end
    self:SyncWatchFill(bar)
end

function Config:PaintCastFill(bar)
    if not bar then
        return
    end
    if bar.cuiWatchFill then
        bar.cuiWatchFill:Hide()
    end
    -- Do not SetStatusBarTexture for cast. 1.12 StatusBar + custom TGA
    -- updates in chunks. CastBar:SyncFill stretches a Texture instead.
    self:HideStockFill(bar)
end

function Config:PaintStatusBarChrome(frame)
    if not frame then
        return
    end
    self:EnsureStatusBarChrome(frame)
    self:EnsureWatchOverlay(frame)
    -- Square fill hides the TGA's transparent corners (the CP cut).
    if frame.SetBackdrop then
        frame:SetBackdrop(nil)
    end
    if frame.cuiTrack then
        frame.cuiTrack:Hide()
    end
    local top, bot = self:WatchTexV(frame)
    local pad = self.WATCH_BORDER_PAD or 4
    if frame.cuiWatchBack then
        frame.cuiWatchBack:SetTexture(self.STATUS_BAR_WATCH_BACK)
        frame.cuiWatchBack:ClearAllPoints()
        frame.cuiWatchBack:SetPoint("TOPLEFT", frame, "TOPLEFT", -pad, pad)
        frame.cuiWatchBack:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", pad, -pad)
        frame.cuiWatchBack:SetTexCoord(0, 1, top, bot)
        frame.cuiWatchBack:SetVertexColor(0, 0, 0, 1)
        frame.cuiWatchBack:Show()
    end
    if frame.cuiWatchGaps then
        frame.cuiWatchGaps:Hide()
    end
    if frame.cuiWatchBody then
        frame.cuiWatchBody:Hide()
    end
    local w = 0
    if frame.GetWidth then
        w = frame:GetWidth() or 0
    end
    if frame.cuiGapGold then
        local i
        local tw = self.WATCH_TICK_WIDTH or 1
        for i = 1, self.WATCH_GAP_COUNT do
            local line = frame.cuiGapGold[i]
            if line then
                local x = 0
                if w > 0 then
                    x = w * i / 10
                end
                line:SetTexture(self.STATUS_BAR_WHITE)
                line:ClearAllPoints()
                line:SetPoint("TOPLEFT", frame, "TOPLEFT", x, 0)
                line:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", x, 0)
                line:SetWidth(tw)
                line:SetVertexColor(
                    self.WATCH_TICK_R or 0.2,
                    self.WATCH_TICK_G or 0.2,
                    self.WATCH_TICK_B or 0.2,
                    1
                )
                line:Show()
            end
        end
    end
    self:PaintStatusBarFill(frame.bar)
    self:PaintStatusBarFill(frame.restedbar)
end

function Config:ApplyHudBorderChrome()
    local bars = ConsoleUI.actionbars
    if bars and bars.PaintDiamond then
        local i
        for i = 1, bars.NUM_BUTTONS or 10 do
            local button = getglobal("ConsoleActionButton" .. i)
            if button then
                bars:PaintDiamond(button)
            end
        end
        local function paintSide(list)
            if not list then
                return
            end
            local n
            for n = 1, table.getn(list) do
                if list[n] then
                    bars:PaintDiamond(list[n])
                end
            end
        end
        paintSide(bars.sideBarLeftButtons)
        paintSide(bars.sideBarRightButtons)
        paintSide(bars.fullLeft)
        paintSide(bars.fullRight)
        if bars.PaintModifierStates then
            bars:PaintModifierStates()
        end
        if bars.extra and bars.extra.Update then
            bars.extra:Update()
        end
    end
    if ConsoleUI.xpbar then
        if ConsoleUI.xpbar.PaintChrome then
            ConsoleUI.xpbar:PaintChrome(ConsoleUI.xpbar.xpBar)
            ConsoleUI.xpbar:PaintChrome(ConsoleUI.xpbar.repBar)
        else
            self:PaintStatusBarChrome(ConsoleUI.xpbar.xpBar)
            self:PaintStatusBarChrome(ConsoleUI.xpbar.repBar)
        end
    end
    if ConsoleUI.castbar and ConsoleUI.castbar.PaintLook then
        ConsoleUI.castbar:PaintLook(ConsoleUI.castbar.castBar)
    end
    if ConsoleUI.loot and ConsoleUI.loot.PaintChrome then
        ConsoleUI.loot:PaintChrome()
    end
    if self.RefreshRingsEditor then
        self:RefreshRingsEditor()
    end
end

function Config:PaintButton(button, kind, hovered)
    local c = self.UI_COLORS
    kind = kind or button.kind or "default"
    local function tint(r, g, b, a)
        local label = button.label
        if label and label.SetTextColor then
            label:SetTextColor(r, g, b, a)
        end
    end
    if kind == "primary" then
        button:SetBackdropColor(1.00, 0.82, 0.18, hovered and 1 or 0.96)
        button:SetBackdropBorderColor(1.00, 0.82, 0.18, 1)
        tint(0.09, 0.08, 0.04)
    elseif kind == "danger" then
        button:SetBackdropColor(0.16, 0.06, 0.07, hovered and 0.96 or 0.88)
        button:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.35)
        tint(unpack(c.danger))
    elseif kind == "ghost" then
        button:SetBackdropColor(0, 0, 0, 0)
        button:SetBackdropBorderColor(unpack(c.border))
        tint(unpack(c.muted))
    elseif kind == "on" then
        button:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
        button:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
        tint(unpack(c.gold))
    else
        if hovered then
            button:SetBackdropColor(0.16, 0.17, 0.20, 1)
            button:SetBackdropBorderColor(1, 1, 1, 0.22)
            tint(1, 1, 1)
        else
            button:SetBackdropColor(unpack(c.button))
            button:SetBackdropBorderColor(unpack(c.borderStrong))
            tint(0.87, 0.88, 0.90)
        end
    end
end

function Config:MakePanelButton(parent, name, width, text, kind)
    local button = CreateFrame("Button", name, parent)
    button:SetWidth(width)
    button:SetHeight(26)
    button:SetBackdrop(self.BACKDROP_CARD)
    button.kind = kind or "default"
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetText(text)
    button.label = label
    self:PaintButton(button, button.kind, false)
    button:SetScript("OnEnter", function()
        Config:PaintButton(this, this.kind, true)
    end)
    button:SetScript("OnLeave", function()
        Config:PaintButton(this, this.kind, false)
    end)
    button.pfUISkinned = true
    return button
end

function Config:SetNavState(button, state)
    if not button then return end
    if button.accent then
        if state == "active" then button.accent:Show() else button.accent:Hide() end
    end
    if button.text then
        if state == "active" then
            button.text:SetTextColor(unpack(self.UI_COLORS.gold))
        elseif state == "hover" then
            button.text:SetTextColor(unpack(self.UI_COLORS.text))
        else
            button.text:SetTextColor(unpack(self.UI_COLORS.muted))
        end
    end
    if state == "active" then
        button:SetBackdropColor(unpack(self.UI_COLORS.active))
        button:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.18)
    elseif state == "hover" then
        button:SetBackdropColor(unpack(self.UI_COLORS.hover))
        button:SetBackdropBorderColor(1, 1, 1, 0.08)
    else
        button:SetBackdropColor(unpack(self.UI_COLORS.idle))
        button:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

-- Section definitions
Config.SECTIONS = {
    { id = "interface", name = "General" },
    { id = "mouse", name = "Mouse" },
    { id = "bars", name = "Action Bars" },
    { id = "hud", name = "HUD" },
    { id = "bindings", name = "Bindings" },
    { id = "rings", name = "Rings" },
    { id = "unitframes", name = "Frames" },
    { id = "profiles", name = "Profiles" },
    { id = "about", name = "About" },
}

-- ============================================================================
-- Main Config Frame
-- ============================================================================

function Config:CreateMainFrame()
    if self.frame then return self.frame end
    
    -- Main frame
    local frame = CreateFrame("Frame", "ConsoleUIConfigFrame", UIParent)
    frame:SetWidth(self.FRAME_WIDTH)
    frame:SetHeight(self.FRAME_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    frame:SetBackdrop(self.BACKDROP_PANEL)
    frame:SetBackdropColor(unpack(self.UI_COLORS.panel))
    frame:SetBackdropBorderColor(unpack(self.UI_COLORS.borderStrong))
    
    local headerH = self.HEADER_HEIGHT
    local footerH = self.FOOTER_HEIGHT

    local headerFill = self:Paint(frame, "BORDER", 0.082, 0.086, 0.106, 0.98)
    headerFill:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    headerFill:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    headerFill:SetHeight(headerH - 6)

    local headerRule = self:Paint(frame, "OVERLAY", 1, 1, 1, 0.08)
    headerRule:SetPoint("BOTTOMLEFT", headerFill, "BOTTOMLEFT", 0, 0)
    headerRule:SetPoint("BOTTOMRIGHT", headerFill, "BOTTOMRIGHT", 0, 0)
    headerRule:SetHeight(1)
    
    local titleRegion = CreateFrame("Frame", nil, frame)
    titleRegion:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5)
    titleRegion:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -5)
    titleRegion:SetHeight(headerH - 8)
    titleRegion:EnableMouse(true)
    titleRegion:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    titleRegion:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)

    local mark = frame:CreateTexture(nil, "ARTWORK")
    mark:SetTexture(self.MARK)
    mark:SetWidth(34)
    mark:SetHeight(34)
    mark:SetPoint("LEFT", headerFill, "LEFT", 12, 0)
    frame.mark = mark
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", mark, "RIGHT", 10, 0)
    title:SetText("Console")
    title:SetTextColor(unpack(self.UI_COLORS.text))
    frame.titleText = title

    local brand = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    brand:SetPoint("LEFT", title, "RIGHT", 0, 0)
    brand:SetText("UI")
    brand:SetTextColor(unpack(self.UI_COLORS.gold))
    frame.brandText = brand

    local credit = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    credit:SetPoint("RIGHT", headerFill, "RIGHT", -16, 0)
    credit:SetText("by HouseLegend")
    credit:SetTextColor(unpack(self.UI_COLORS.muted))
    frame.creditText = credit
    
    local sidebar = CreateFrame("Frame", nil, frame)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -headerH)
    sidebar:SetWidth(self.SIDEBAR_WIDTH)
    sidebar:SetHeight(self.FRAME_HEIGHT - headerH - footerH - 2)
    sidebar:SetBackdrop(self.BACKDROP_FLAT)
    sidebar:SetBackdropColor(0.063, 0.067, 0.082, 0.96)
    frame.sidebar = sidebar

    local rail = self:Paint(frame, "ARTWORK", 1, 1, 1, 0.08)
    rail:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)
    rail:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMRIGHT", 0, 0)
    rail:SetWidth(1)
    
    local contentHost = CreateFrame("Frame", nil, frame)
    contentHost:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
    contentHost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, footerH)
    contentHost:SetBackdrop(self.BACKDROP_FLAT)
    contentHost:SetBackdropColor(unpack(self.UI_COLORS.content))

    local scroll = CreateFrame("ScrollFrame", "ConsoleUIConfigContentScroll", contentHost, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", contentHost, "TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", contentHost, "BOTTOMRIGHT", -26, 4)
    self:HookScrollWheel(scroll, 40)

    local childW = self.FRAME_WIDTH - self.SIDEBAR_WIDTH - 46
    local child = CreateFrame("Frame", "ConsoleUIConfigContentChild", scroll)
    child:SetWidth(childW)
    child:SetHeight(400)
    scroll:SetScrollChild(child)

    frame.contentHost = contentHost
    frame.contentScroll = scroll
    frame.content = child

    local footerFill = self:Paint(frame, "BORDER", 0.067, 0.071, 0.086, 0.98)
    footerFill:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
    footerFill:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    footerFill:SetHeight(footerH - 8)

    local footerRule = self:Paint(frame, "OVERLAY", 1, 1, 1, 0.08)
    footerRule:SetPoint("TOPLEFT", footerFill, "TOPLEFT", 0, 0)
    footerRule:SetPoint("TOPRIGHT", footerFill, "TOPRIGHT", 0, 0)
    footerRule:SetHeight(1)
    
    local closeButton = self:MakePanelButton(frame, "ConsoleUIConfigCloseButton", 96, CLOSE or "Close")
    closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 14)
    closeButton:SetScript("OnClick", function()
        PlaySound("gsTitleOptionExit")
        if ConsoleUI.profiles and ConsoleUI.profiles.SaveCurrentProfile then
            ConsoleUI.profiles:SaveCurrentProfile()
        end
        ConsoleUI.config.frame:Hide()
    end)
    frame.closeButton = closeButton
    
    local debugButton = self:MakePanelButton(frame, "ConsoleUIConfigDebugButton", 104, "Debug: OFF", "ghost")
    debugButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 14)
    debugButton:Hide()
    
    local function UpdateDebugButtonText()
        local debugEnabled = Config:Get("debugEnabled")
        local label = debugEnabled and "Debug: ON" or "Debug: OFF"
        debugButton.kind = debugEnabled and "on" or "ghost"
        if debugButton.SetText then
            debugButton:SetText(label)
        end
        if debugButton.label then
            debugButton.label:SetText(label)
        end
        Config:PaintButton(debugButton, debugButton.kind, false)
    end
    UpdateDebugButtonText()
    frame.UpdateDebugButtonText = UpdateDebugButtonText
    
    debugButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        local debugEnabled = Config:Get("debugEnabled")
        Config:Set("debugEnabled", not debugEnabled)
        UpdateDebugButtonText()
        if not debugEnabled then
            ConsoleUI_Debug("Debug output ENABLED")
        else
            ConsoleUI_Debug("Debug output DISABLED")
        end
    end)
    frame.debugButton = debugButton
    
    self.frame = frame
    
    -- Add to special frames so Escape closes it
    table.insert(UISpecialFrames, "ConsoleUIConfigFrame")
    
    -- Create sidebar buttons
    self:CreateSidebarButtons()
    
    -- Create content sections
    self:CreateContentSections()
    
    -- Show first section by default
    self:ShowSection("interface")
    
    -- Hook frame for cursor navigation
    if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
        ConsoleUI.hooks:HookDynamicFrame(frame, "ConsoleUI Config")
    end
    
    -- Apply pfUI styling will be done via the periodic check
    
    return frame
end

-- ============================================================================
-- Sidebar Buttons
-- ============================================================================

function Config:CreateSidebarButtons()
    local sidebar = self.frame.sidebar
    self.sidebarButtons = {}
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    
    for i, section in ipairs(self.SECTIONS) do
        local buttonName = "ConsoleUIConfigSidebar" .. section.id
        local button = CreateFrame("Button", buttonName, sidebar)
        button:SetWidth(self.SIDEBAR_WIDTH - 16)
        button:SetHeight(self.BUTTON_HEIGHT)
        button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 8, -10 - (i-1) * (self.BUTTON_HEIGHT + 5))
        button:SetBackdrop(self.BACKDROP_CARD)
        button:SetBackdropColor(unpack(self.UI_COLORS.idle))
        button:SetBackdropBorderColor(0, 0, 0, 0)

        local accent = button:CreateTexture(nil, "ARTWORK")
        accent:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        accent:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -6)
        accent:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 3, 6)
        accent:SetWidth(3)
        accent:SetVertexColor(unpack(self.UI_COLORS.gold))
        accent:Hide()
        button.accent = accent
        
        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", 14, 0)
        text:SetText(T(section.name))
        button.text = text
        
        button.sectionId = section.id
        Config:SetNavState(button, "idle")
        
        button:SetScript("OnClick", function()
            Config:ShowSection(this.sectionId)
        end)
        
        button:SetScript("OnEnter", function()
            if Config.currentSection ~= this.sectionId then
                Config:SetNavState(this, "hover")
            end
        end)
        button:SetScript("OnLeave", function()
            if Config.currentSection ~= this.sectionId then
                Config:SetNavState(this, "idle")
            end
        end)
        
        self.sidebarButtons[section.id] = button
    end
end

-- ============================================================================
-- Content Sections
-- ============================================================================

function Config:CreateContentSections()
    self.contentSections = {}
    
    -- Create Interface section
    self:CreateInterfaceSection()

    if self.CreateMouseSection then
        self:CreateMouseSection()
    end

    if self.CreateUnitFramesSection then
        self:CreateUnitFramesSection()
    end
    
    -- Create Bars section
    self:CreateBarsSection()
    
    -- Create Bindings section
    self:CreateBindingsSection()

    self:CreateRingsSection()
    
    -- Create Profiles section
    self:CreateProfilesSection()

    self:CreateAboutSection()

    -- Debug remains available through /cui debug and /cui test, but is not a
    -- normal end-user settings category.
    self:CreateDebugSection()
end

function Config:CreateInterfaceSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    
    -- Main section container (attached to content)
    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    -- ==================== General Settings Box ====================
    local generalBox = self:CreateSectionBox(section, T("General"))
    generalBox:SetPoint("TOP", section, "TOP", 0, -6)
    generalBox:SetHeight(142)
    generalBox.heightCalculated = true
    
    local healerModeCheck = self:CreateCheckbox(generalBox, T("Healer Mode"),
        function() return Config:Get("healerMode") end,
        function(checked)
            Config:Set("healerMode", checked)
            ConsoleUI_Debug("Healer mode " .. (checked and "enabled" or "disabled"))
            if ConsoleUI.hooks and ConsoleUI.hooks.HookPartyRaidFrames then
                ConsoleUI.hooks:HookPartyRaidFrames()
            end
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
                ConsoleUI.actionbars:UpdateAllButtons()
            end
        end)
    healerModeCheck:SetPoint("TOPLEFT", generalBox, "TOP", 8, generalBox.contentTop)

    local alwaysBagsCheck = self:CreateCheckbox(generalBox, T("Always open all bags"),
        function() return Config:Get("alwaysOpenAllBags") ~= false end,
        function(checked)
            Config:Set("alwaysOpenAllBags", checked)
            ConsoleUI_Debug("Always open all bags " .. (checked and "ENABLED" or "DISABLED"))
        end,
        T("Opening any bag opens every bag."))
    alwaysBagsCheck:SetPoint("TOPLEFT", healerModeCheck, "BOTTOMLEFT", 0, 2)

    local openBagsCheck = self:CreateCheckbox(generalBox, T("Open all bags at vendor"),
        function() return Config:Get("openAllBagsAtVendor") end,
        function(checked)
            Config:Set("openAllBagsAtVendor", checked)
            ConsoleUI_Debug("Open all bags at vendor " .. (checked and "ENABLED" or "DISABLED"))
        end)
    openBagsCheck:SetPoint("TOPLEFT", alwaysBagsCheck, "BOTTOMLEFT", 0, 2)

    local dropdownNavCheck = self:CreateCheckbox(generalBox, T("Dropdown Navigation"),
        function() return Config:Get("dropdownNavEnabled") end,
        function(checked)
            Config:Set("dropdownNavEnabled", checked)
            ConsoleUI_Debug("Dropdown navigation " .. (checked and "enabled" or "disabled"))
        end)
    dropdownNavCheck:SetPoint("TOPLEFT", openBagsCheck, "BOTTOMLEFT", 0, 2)

    local langLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    langLabel:SetPoint("TOPLEFT", generalBox, "TOPLEFT", generalBox.contentLeft, generalBox.contentTop)
    langLabel:SetText(T("Language"))
    langLabel:SetTextColor(unpack(self.UI_COLORS.muted))
    
    local langDropdown = CreateFrame("Frame", "ConsoleUIConfigLanguageDropdown", generalBox, "UIDropDownMenuTemplate")
    langDropdown:SetPoint("TOPLEFT", langLabel, "BOTTOMLEFT", -16, -2)
    
    -- Initialize function for language dropdown
    local function InitializeLanguageDropdown()
        if not Locale then 
            ConsoleUI_Debug("Language dropdown: Locale module not found")
            return 
        end
        
        local available = Locale:GetAvailableLanguages()
        
        if table.getn(available) == 0 then 
            local info = {}
            info.text = "English"
            info.value = "enUS"
            info.func = function()
                UIDropDownMenu_SetSelectedValue(langDropdown, "enUS")
                UIDropDownMenu_SetText("English", langDropdown)
                Locale:SetLanguage("enUS")
                StaticPopup_Show("ConsoleUI_RELOAD_UI")
            end
            info.checked = 1
            UIDropDownMenu_AddButton(info)
            return
        end
        
        local selectedValue = UIDropDownMenu_GetSelectedValue(langDropdown) or (Config:Get("language") or GetLocale() or "enUS")
        local info
        
        for _, lang in ipairs(available) do
            info = {}
            info.text = Locale:GetLanguageName(lang)
            info.value = lang
            info.func = function()
                UIDropDownMenu_SetSelectedValue(langDropdown, lang)
                UIDropDownMenu_SetText(Locale:GetLanguageName(lang), langDropdown)
                Locale:SetLanguage(lang)
                StaticPopup_Show("ConsoleUI_RELOAD_UI")
            end
            if info.value == selectedValue then
                info.checked = 1
            end
            UIDropDownMenu_AddButton(info)
        end
    end
    
    langDropdown.initialize = InitializeLanguageDropdown
    UIDropDownMenu_Initialize(langDropdown, InitializeLanguageDropdown)
    UIDropDownMenu_SetWidth(120, langDropdown)
    local currentLang = Config:Get("language") or GetLocale() or "enUS"
    UIDropDownMenu_SetSelectedValue(langDropdown, currentLang)
    local langName = Locale and Locale:GetLanguageName(currentLang) or currentLang
    UIDropDownMenu_SetText(langName, langDropdown)
    
    -- Ensure dropdown buttons are navigable and have tooltips
    local generalDelayFrame = CreateFrame("Frame")
    generalDelayFrame:SetScript("OnUpdate", function()
        generalDelayFrame:Hide()
        local langBtn = getglobal("ConsoleUIConfigLanguageDropdownButton")
        if langBtn then 
            langBtn:Enable()
            langBtn:Show()
            langBtn.label = T("Language")
            langBtn.tooltipText = T("Select the language for the addon interface. Requires a UI reload to take effect.")
        end
        if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
            ConsoleUI.cursor:RefreshFrame()
        end
    end)
    generalDelayFrame:Show()

    self:AddSectionReset(generalBox, function()
        Config:Set("healerMode", Config.DEFAULTS.healerMode)
        Config:Set("alwaysOpenAllBags", Config.DEFAULTS.alwaysOpenAllBags)
        Config:Set("openAllBagsAtVendor", Config.DEFAULTS.openAllBagsAtVendor)
        Config:Set("dropdownNavEnabled", Config.DEFAULTS.dropdownNavEnabled)
        healerModeCheck:SetChecked(Config.DEFAULTS.healerMode and 1 or 0)
        alwaysBagsCheck:SetChecked(Config.DEFAULTS.alwaysOpenAllBags ~= false and 1 or 0)
        openBagsCheck:SetChecked(Config.DEFAULTS.openAllBagsAtVendor and 1 or 0)
        dropdownNavCheck:SetChecked(Config.DEFAULTS.dropdownNavEnabled and 1 or 0)
        if ConsoleUI.hooks and ConsoleUI.hooks.HookPartyRaidFrames then
            ConsoleUI.hooks:HookPartyRaidFrames()
        end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.ApplyDefaultBarVisibility then
            ConsoleUI.actionbars:ApplyDefaultBarVisibility()
        end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
    end)

    local glyphBox = self:CreateGlyphsBox(section, generalBox)
    local keyboardAnchor = glyphBox
    if ConsoleUIKeyboard then
        local keyboardBox = self:CreateSectionBox(section, T("Keyboard"))
        keyboardBox:ClearAllPoints()
        keyboardBox:SetPoint("TOPLEFT", glyphBox, "BOTTOMLEFT", 0, -10)
        keyboardBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
        keyboardBox:SetHeight(78)
        keyboardBox.heightCalculated = true

        local showLabel = keyboardBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        showLabel:SetPoint("TOPLEFT", keyboardBox, "TOPLEFT", keyboardBox.contentLeft, keyboardBox.contentTop)
        showLabel:SetText(T("Show Keyboard for") .. ":")
        showLabel:SetTextColor(unpack(self.UI_COLORS.muted))

        local showDrop = CreateFrame("Frame", "ConsoleUIConfigKeyboardShowDropdown", keyboardBox, "UIDropDownMenuTemplate")
        showDrop:SetPoint("LEFT", showLabel, "RIGHT", -12, -2)

        local function ShowForLabel(value)
            if value == "chat" then
                return T("Chat Only")
            end
            return T("Everything")
        end

        local function CurrentShowFor()
            if ConsoleUIKeyboard.ShowFor then
                return ConsoleUIKeyboard:ShowFor()
            end
            return "everything"
        end

        local function InitShowFor()
            local selected = UIDropDownMenu_GetSelectedValue(showDrop) or CurrentShowFor()
            local info = {}
            info.text = T("Everything")
            info.value = "everything"
            info.func = function()
                UIDropDownMenu_SetSelectedValue(showDrop, "everything")
                UIDropDownMenu_SetText(T("Everything"), showDrop)
                if ConsoleUIKeyboard.SetShowFor then
                    ConsoleUIKeyboard:SetShowFor("everything")
                end
            end
            if info.value == selected then info.checked = 1 end
            UIDropDownMenu_AddButton(info)
            info = {}
            info.text = T("Chat Only")
            info.value = "chat"
            info.func = function()
                UIDropDownMenu_SetSelectedValue(showDrop, "chat")
                UIDropDownMenu_SetText(T("Chat Only"), showDrop)
                if ConsoleUIKeyboard.SetShowFor then
                    ConsoleUIKeyboard:SetShowFor("chat")
                end
            end
            if info.value == selected then info.checked = 1 end
            UIDropDownMenu_AddButton(info)
        end
        UIDropDownMenu_Initialize(showDrop, InitShowFor)
        UIDropDownMenu_SetWidth(140, showDrop)
        local currentShow = CurrentShowFor()
        UIDropDownMenu_SetSelectedValue(showDrop, currentShow)
        UIDropDownMenu_SetText(ShowForLabel(currentShow), showDrop)

        self:AddSectionReset(keyboardBox, function()
            if ConsoleUIKeyboard.SetShowFor then
                ConsoleUIKeyboard:SetShowFor("everything")
            end
            UIDropDownMenu_SetSelectedValue(showDrop, "everything")
            UIDropDownMenu_SetText(T("Everything"), showDrop)
        end)
        keyboardAnchor = keyboardBox
    end
    
    -- ==================== Crosshair Settings Box ====================
    local crosshairBox = self:CreateSectionBox(section, T("Crosshair"))
    crosshairBox:SetPoint("TOP", keyboardAnchor, "BOTTOM", 0, -10)
    crosshairBox:SetHeight(118)
    crosshairBox.heightCalculated = true

    local COL1 = crosshairBox.contentLeft
    local COL2 = 240
    local COL3 = 470
    local XHAIR_ROW1 = crosshairBox.contentTop
    local XHAIR_ROW2 = crosshairBox.contentTop - 42
    
    local crosshairCheck = self:CreateCheckbox(crosshairBox, T("Enable"),  
        function() return Config:Get("crosshairEnabled") end,
        function(checked)
            Config:Set("crosshairEnabled", checked)
            Config:UpdateCrosshair()
            if checked then
                ConsoleUI_Debug("Crosshair ENABLED")
            else
                ConsoleUI_Debug("Crosshair DISABLED")
            end
        end,
        T("Show a crosshair overlay in the center of the screen for easier targeting."))
    crosshairCheck:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL1, XHAIR_ROW1)
    
    local typeLabel = crosshairBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    typeLabel:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL2, XHAIR_ROW1)
    typeLabel:SetText(T("Type") .. ":")
    
    local typeDropdown = CreateFrame("Frame", "ConsoleUIConfigCrosshairTypeDropdown", crosshairBox, "UIDropDownMenuTemplate")
    typeDropdown:SetPoint("LEFT", typeLabel, "RIGHT", -12, -3)
    
    local function InitializeTypeDropdown()
        local selectedValue = UIDropDownMenu_GetSelectedValue(typeDropdown) or (Config:Get("crosshairType") or "cross")
        local info
        
        info = {}
        info.text = T("Cross")
        info.value = "cross"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(typeDropdown, "cross")
            UIDropDownMenu_SetText(T("Cross"), typeDropdown)
            Config:Set("crosshairType", "cross")
            Config:UpdateCrosshair()
        end
        if info.value == selectedValue then
            info.checked = 1
        end
        UIDropDownMenu_AddButton(info)
        
        info = {}
        info.text = T("Dot")
        info.value = "dot"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(typeDropdown, "dot")
            UIDropDownMenu_SetText(T("Dot"), typeDropdown)
            Config:Set("crosshairType", "dot")
            Config:UpdateCrosshair()
        end
        if info.value == selectedValue then
            info.checked = 1
        end
        UIDropDownMenu_AddButton(info)
    end
    
    UIDropDownMenu_Initialize(typeDropdown, InitializeTypeDropdown)
    UIDropDownMenu_SetWidth(90, typeDropdown)
    local currentType = Config:Get("crosshairType") or "cross"
    UIDropDownMenu_SetSelectedValue(typeDropdown, currentType)
    UIDropDownMenu_SetText(currentType == "cross" and T("Cross") or T("Dot"), typeDropdown)
    
    local colorLabel = crosshairBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    colorLabel:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL3, XHAIR_ROW1)
    colorLabel:SetText(T("Color") .. ":")
    
    local colorButton = CreateFrame("Button", "ConsoleUIConfigCrosshairColor", crosshairBox)
    colorButton:SetWidth(60)
    colorButton:SetHeight(20)
    colorButton:SetPoint("LEFT", colorLabel, "RIGHT", 8, 0)
    colorButton.label = T("Crosshair Color")
    colorButton.tooltipText = T("Click to open the color picker and choose the crosshair color and opacity.")
    
    colorButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    local colorPreview = colorButton:CreateTexture(nil, "OVERLAY")
    colorPreview:SetPoint("TOPLEFT", colorButton, "TOPLEFT", 2, -2)
    colorPreview:SetPoint("BOTTOMRIGHT", colorButton, "BOTTOMRIGHT", -2, 2)
    colorButton.colorPreview = colorPreview
    
    local function UpdateColorPreview()
        local r = Config:Get("crosshairColorR") or 1.0
        local g = Config:Get("crosshairColorG") or 1.0
        local b = Config:Get("crosshairColorB") or 1.0
        local a = Config:Get("crosshairColorA") or 0.8
        colorPreview:SetTexture(r, g, b, a)
        colorButton:SetBackdropColor(r, g, b, 1)
    end
    
    colorButton:SetScript("OnClick", function()
        local r = Config:Get("crosshairColorR") or 1.0
        local g = Config:Get("crosshairColorG") or 1.0
        local b = Config:Get("crosshairColorB") or 1.0
        local a = Config:Get("crosshairColorA") or 0.8
        
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(2000)
        if ColorPickerOkayButton then
            ColorPickerOkayButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerOkayButton:SetFrameLevel(2001)
        end
        if ColorPickerCancelButton then
            ColorPickerCancelButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerCancelButton:SetFrameLevel(2001)
        end
        
        ColorPickerFrame.func = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = 1 - OpacitySliderFrame:GetValue()
            Config:Set("crosshairColorR", newR)
            Config:Set("crosshairColorG", newG)
            Config:Set("crosshairColorB", newB)
            Config:Set("crosshairColorA", newA)
            UpdateColorPreview()
            Config:UpdateCrosshair()
        end
        
        ColorPickerFrame.opacityFunc = function()
            local newA = 1 - OpacitySliderFrame:GetValue()
            Config:Set("crosshairColorA", newA)
            UpdateColorPreview()
            Config:UpdateCrosshair()
        end
        
        ColorPickerFrame:SetColorRGB(r, g, b)
        OpacitySliderFrame:SetValue(1 - a)
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = 1 - a
        
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            ColorPickerFrame:Show()
        end)
        delayFrame:Show()
    end)
    UpdateColorPreview()
    
    local xLabel = crosshairBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL1, XHAIR_ROW2)
    xLabel:SetText(T("X Offset") .. ":")
    
    local xEditBox = self:CreateEditBox(crosshairBox, 50, 
        function() return tostring(Config:Get("crosshairX")) end,
        function(value)
            local num = tonumber(value) or 0
            Config:Set("crosshairX", num)
            Config:UpdateCrosshair()
        end,
        T("X Offset"),
        T("Horizontal offset from screen center. Negative values move left, positive values move right."),
        self.NUDGE_MOVE)
    xEditBox:SetPoint("LEFT", xLabel, "RIGHT", 5, 0)
    xEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 0
        Config:Set("crosshairX", num)
        Config:UpdateCrosshair()
    end)
    
    local yLabel = crosshairBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL2, XHAIR_ROW2)
    yLabel:SetText(T("Y Offset") .. ":")
    
    local yEditBox = self:CreateEditBox(crosshairBox, 50, 
        function() return tostring(Config:Get("crosshairY")) end,
        function(value)
            local num = tonumber(value) or 0
            Config:Set("crosshairY", num)
            Config:UpdateCrosshair()
        end,
        T("Y Offset"),
        T("Vertical offset from screen center. Negative values move down, positive values move up."),
        self.NUDGE_MOVE)
    yEditBox:SetPoint("LEFT", yLabel, "RIGHT", 5, 0)
    yEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 0
        Config:Set("crosshairY", num)
        Config:UpdateCrosshair()
    end)
    
    local sizeLabel = crosshairBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sizeLabel:SetPoint("TOPLEFT", crosshairBox, "TOPLEFT", COL3, XHAIR_ROW2)
    sizeLabel:SetText(T("Size") .. ":")
    
    local sizeEditBox = self:CreateEditBox(crosshairBox, 50, 
        function() return tostring(Config:Get("crosshairSize")) end,
        function(value)
            local num = tonumber(value) or 24
            if num < 4 then num = 4 end
            if num > 100 then num = 100 end
            Config:Set("crosshairSize", num)
            Config:UpdateCrosshair()
        end,
        T("Crosshair Size"),
        T("Size of the crosshair in pixels. Range: 4-100 pixels."))
    sizeEditBox:SetPoint("LEFT", sizeLabel, "RIGHT", 5, 0)
    sizeEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 24
        if num < 4 then num = 4 end
        if num > 100 then num = 100 end
        Config:Set("crosshairSize", num)
        Config:UpdateCrosshair()
    end)
    
    
    -- Ensure dropdown button is navigable and has tooltip
    local crosshairDelayFrame = CreateFrame("Frame")
    crosshairDelayFrame:SetScript("OnUpdate", function()
        crosshairDelayFrame:Hide()
        local dropdownButton = getglobal("ConsoleUIConfigCrosshairTypeDropdownButton")
        if dropdownButton then
            dropdownButton:Enable()
            dropdownButton:Show()
            dropdownButton.label = T("Crosshair Type")
            dropdownButton.tooltipText = T("Choose the crosshair style: Cross shows a traditional + shape, Dot shows a single circular dot.")
        end
        if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
            ConsoleUI.cursor:RefreshFrame()
        end
    end)
    crosshairDelayFrame:Show()

    self:AddSectionReset(crosshairBox, function()
        Config:Set("crosshairEnabled", Config.DEFAULTS.crosshairEnabled)
        Config:Set("crosshairX", Config.DEFAULTS.crosshairX)
        Config:Set("crosshairY", Config.DEFAULTS.crosshairY)
        Config:Set("crosshairSize", Config.DEFAULTS.crosshairSize)
        Config:Set("crosshairType", Config.DEFAULTS.crosshairType)
        Config:Set("crosshairColorR", Config.DEFAULTS.crosshairColorR)
        Config:Set("crosshairColorG", Config.DEFAULTS.crosshairColorG)
        Config:Set("crosshairColorB", Config.DEFAULTS.crosshairColorB)
        Config:Set("crosshairColorA", Config.DEFAULTS.crosshairColorA)
        crosshairCheck:SetChecked(Config.DEFAULTS.crosshairEnabled and 1 or 0)
        xEditBox:SetText(tostring(Config.DEFAULTS.crosshairX))
        yEditBox:SetText(tostring(Config.DEFAULTS.crosshairY))
        sizeEditBox:SetText(tostring(Config.DEFAULTS.crosshairSize))
        local defType = Config.DEFAULTS.crosshairType or "cross"
        UIDropDownMenu_SetSelectedValue(typeDropdown, defType)
        UIDropDownMenu_SetText(defType == "cross" and T("Cross") or T("Dot"), typeDropdown)
        UpdateColorPreview()
        Config:UpdateCrosshair()
    end)
    
    self.contentSections["interface"] = section
end

function Config:CreateGlyphsBox(section, anchor)
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local glyphBox = self:CreateSectionBox(section, T("Glyphs"))
    glyphBox:ClearAllPoints()
    glyphBox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
    glyphBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    glyphBox:SetHeight(118)
    glyphBox.heightCalculated = true

    local styleLabel = glyphBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    styleLabel:SetPoint("TOPLEFT", glyphBox, "TOPLEFT", glyphBox.contentLeft, glyphBox.contentTop)
    styleLabel:SetText(T("Style") .. ":")
    styleLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local styleDrop = CreateFrame("Frame", "ConsoleUIConfigControllerTypeDropdown", glyphBox, "UIDropDownMenuTemplate")
    styleDrop:SetPoint("LEFT", styleLabel, "RIGHT", -10, -2)

    local function SetStyle(value)
        Config:Set("controllerType", value)
        Config:ApplyControllerGlyphs()
    end

    local function InitStyle()
        local selected = UIDropDownMenu_GetSelectedValue(styleDrop) or (Config:Get("controllerType") or "xbox")
        local values = {
            { value = "xbox", text = "Xbox" },
            { value = "ps", text = "PlayStation" },
        }
        local i
        for i = 1, table.getn(values) do
            local row = values[i]
            local info = {}
            info.text = row.text
            info.value = row.value
            local captured = row.value
            info.func = function() SetStyle(captured) end
            if row.value == selected then info.checked = 1 end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(styleDrop, InitStyle)
    UIDropDownMenu_SetWidth(130, styleDrop)

    local sizeLabel = glyphBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sizeLabel:SetPoint("TOPLEFT", glyphBox, "TOPLEFT", glyphBox.contentLeft + 330, glyphBox.contentTop)
    sizeLabel:SetText(T("Glyph size") .. ":")
    sizeLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local sizeDrop = CreateFrame("Frame", "ConsoleUIConfigGlyphSizeDropdown", glyphBox, "UIDropDownMenuTemplate")
    sizeDrop:SetPoint("LEFT", sizeLabel, "RIGHT", -10, -2)

    local function GlyphSizeLabel(value)
        if value == "medium" then return T("Medium") end
        if value == "large" then return T("Large") end
        return T("Small")
    end

    local function SetSize(value)
        Config:Set("controllerGlyphSize", value)
        Config:ApplyControllerGlyphs()
    end

    local function InitSize()
        local selected = UIDropDownMenu_GetSelectedValue(sizeDrop) or (Config:Get("controllerGlyphSize") or "small")
        local values = { "small", "medium", "large" }
        local i
        for i = 1, table.getn(values) do
            local value = values[i]
            local info = {}
            info.text = GlyphSizeLabel(value)
            info.value = value
            local captured = value
            info.func = function() SetSize(captured) end
            if value == selected then info.checked = 1 end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(sizeDrop, InitSize)
    UIDropDownMenu_SetWidth(130, sizeDrop)

    local actionCheck = self:CreateCheckbox(glyphBox, T("Glyphs on action bars"),
        function() return Config:Get("barActionGlyphs") ~= false end,
        function(checked)
            Config:Set("barActionGlyphs", checked)
            Config:UpdateActionBarLayout()
        end,
        T("Show ABXY and D-pad glyphs on action buttons. LB, LT, RB, and RT stay visible."))
    actionCheck:SetPoint("TOPLEFT", glyphBox, "TOPLEFT", glyphBox.contentLeft, glyphBox.contentTop - 42)

    local tooltipCheck = self:CreateCheckbox(glyphBox, T("Glyphs in tooltips"),
        function() return Config:Get("tooltipActionHints") ~= false end,
        function(checked)
            Config:Set("tooltipActionHints", checked)
            if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ApplyPromptVisibility then
                ConsoleUI.cursor.tooltip:ApplyPromptVisibility()
            end
            if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
                ConsoleUI.cursor.hintbar:Refresh()
            end
        end,
        T("Show controller glyphs and action prompts inside tooltips. Disable to use only the Hint Bar."))
    tooltipCheck:SetPoint("TOPLEFT", glyphBox, "TOPLEFT", glyphBox.contentLeft + 330, glyphBox.contentTop - 42)

    self:AddSectionReset(glyphBox, function()
        Config:Set("controllerType", Config.DEFAULTS.controllerType)
        Config:Set("controllerGlyphSize", Config.DEFAULTS.controllerGlyphSize)
        Config:Set("barActionGlyphs", Config.DEFAULTS.barActionGlyphs)
        Config:Set("tooltipActionHints", Config.DEFAULTS.tooltipActionHints)
        actionCheck:SetChecked(Config.DEFAULTS.barActionGlyphs and 1 or 0)
        tooltipCheck:SetChecked(Config.DEFAULTS.tooltipActionHints and 1 or 0)
        Config:ApplyControllerGlyphs()
        Config:UpdateActionBarLayout()
        if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ApplyPromptVisibility then
            ConsoleUI.cursor.tooltip:ApplyPromptVisibility()
        end
    end)

    local glyphDelay = CreateFrame("Frame")
    glyphDelay:SetScript("OnUpdate", function()
        glyphDelay:Hide()
        local styleButton = getglobal("ConsoleUIConfigControllerTypeDropdownButton")
        if styleButton then
            styleButton.label = T("Glyph style")
            styleButton.tooltipText = T("Select which controller button icons to display (Xbox or PlayStation style).")
        end
        local sizeButton = getglobal("ConsoleUIConfigGlyphSizeDropdownButton")
        if sizeButton then
            sizeButton.label = T("Glyph size")
            sizeButton.tooltipText = T("Size of Xbox and PlayStation button icons on action bars, Spell Placement, bindings, and tooltips.")
        end
        if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then ConsoleUI.cursor:RefreshFrame() end
    end)
    glyphDelay:Show()

    self:RefreshGlyphControls()
    return glyphBox
end

function Config:CreateBarsSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    
    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    local hudSection = CreateFrame("Frame", nil, content)
    hudSection:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    hudSection:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    hudSection:Hide()

    local function CreateContextScaleField(parent, key, applyFunc)
        local box = self:CreateEditBox(parent, 42,
            function() return string.format("%.1f", Config:Get(key) or 1.0) end,
            function(value)
                local num = tonumber(value) or 1.0
                if num < 0.5 then num = 0.5 end
                if num > 2.0 then num = 2.0 end
                Config:Set(key, num)
                applyFunc()
            end,
            T("Scale"),
            T("Scale of this bar. Range: 0.5-2.0."),
            self.NUDGE_SCALE)
        box:SetScript("OnTextChanged", function()
            local num = tonumber(this:GetText()) or 1.0
            if num >= 0.5 and num <= 2.0 then
                Config:Set(key, num)
                applyFunc()
            end
        end)
        return box
    end

    local function ApplyMainScale()
        Config:UpdateActionBarLayout()
    end
    local function ApplySideScale()
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
            ConsoleUI.actionbars:UpdateSideBars()
        end
    end
    local function ApplyExtraScale()
        if ConsoleUI.actionbars and ConsoleUI.actionbars.extra and ConsoleUI.actionbars.extra.Update then
            ConsoleUI.actionbars.extra:Update()
        end
    end

    self.scaleEditBoxes = {}
    
    -- ==================== General Action Bars Box ====================
    local generalBox = self:CreateSectionBox(section, T("Action bars"))
    generalBox:SetPoint("TOP", section, "TOP", 0, -6)
    generalBox:SetHeight(122)
    generalBox.heightCalculated = true
    
    -- Row 1: Layout + Style
    local layoutLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    layoutLabel:SetPoint("TOPLEFT", generalBox, "TOPLEFT", generalBox.contentLeft, generalBox.contentTop)
    layoutLabel:SetText(T("Layout") .. ":")
    
    local layoutDropdown = CreateFrame("Frame", "ConsoleUIConfigBarLayoutDropdown", generalBox, "UIDropDownMenuTemplate")
    layoutDropdown:SetPoint("LEFT", layoutLabel, "RIGHT", -15, -3)
    
    local function LayoutLabel(value)
        if value == "flat" then
            return T("Flat")
        end
        if value == "full" then
            return T("Full")
        end
        return T("Controller Style")
    end

    local function InitializeLayoutDropdown()
        local selectedValue = UIDropDownMenu_GetSelectedValue(layoutDropdown) or (Config:Get("barLayout") or "controller")
        local info
        info = {}
        info.text = T("Controller Style")
        info.value = "controller"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(layoutDropdown, "controller")
            UIDropDownMenu_SetText(T("Controller Style"), layoutDropdown)
            Config:Set("barLayout", "controller")
            Config:UpdateActionBarLayout()
        end
        if info.value == selectedValue then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
        info = {}
        info.text = T("Flat")
        info.value = "flat"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(layoutDropdown, "flat")
            UIDropDownMenu_SetText(T("Flat"), layoutDropdown)
            Config:Set("barLayout", "flat")
            Config:UpdateActionBarLayout()
        end
        if info.value == selectedValue then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
        info = {}
        info.text = T("Full")
        info.value = "full"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(layoutDropdown, "full")
            UIDropDownMenu_SetText(T("Full"), layoutDropdown)
            Config:Set("barLayout", "full")
            Config:UpdateActionBarLayout()
        end
        if info.value == selectedValue then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
    end
    
    UIDropDownMenu_Initialize(layoutDropdown, InitializeLayoutDropdown)
    UIDropDownMenu_SetWidth(130, layoutDropdown)
    local currentLayout = Config:Get("barLayout") or "controller"
    UIDropDownMenu_SetSelectedValue(layoutDropdown, currentLayout)
    UIDropDownMenu_SetText(LayoutLabel(currentLayout), layoutDropdown)

    local goldLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    goldLabel:SetPoint("TOP", layoutLabel, "TOP", 0, 0)
    goldLabel:SetPoint("LEFT", layoutDropdown, "RIGHT", 8, 3)
    goldLabel:SetText(T("HUD border"))
    
    local goldCheck = CreateFrame("CheckButton", self:GetNextElementName("Check"), generalBox, "UICheckButtonTemplate")
    goldCheck:SetWidth(24)
    goldCheck:SetHeight(24)
    goldCheck:SetPoint("LEFT", goldLabel, "RIGHT", 5, 0)
    goldCheck.label = T("HUD border")
    goldCheck.tooltipText = T("Show a colored outline on action-bar diamonds, XP, cast bars, and loot.")
    goldCheck:SetChecked(Config:Get("barGoldBorder") and 1 or 0)
    goldCheck:SetScript("OnClick", function()
        Config:Set("barGoldBorder", this:GetChecked() == 1)
        Config:ApplyHudBorderChrome()
    end)

    local goldColorBtn = CreateFrame("Button", self:GetNextElementName("ColorBtn"), generalBox)
    goldColorBtn:SetWidth(24)
    goldColorBtn:SetHeight(20)
    goldColorBtn:SetPoint("LEFT", goldCheck, "RIGHT", 6, 0)
    goldColorBtn.label = T("HUD border color")
    goldColorBtn.tooltipText = T("Outline color for action-bar diamonds, XP, cast bars, and loot. Default is gold.")

    local goldColorPreview = goldColorBtn:CreateTexture(nil, "BACKGROUND")
    goldColorPreview:SetAllPoints()

    local function UpdateGoldColorPreview()
        local r, g, b = Config:GetHudBorderColor()
        goldColorPreview:SetTexture(r, g, b)
    end
    UpdateGoldColorPreview()

    goldColorBtn:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    goldColorBtn:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    goldColorBtn:SetScript("OnClick", function()
        local r, g, b = Config:GetHudBorderColor()
        local prevR, prevG, prevB = r, g, b

        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(2000)
        if ColorPickerOkayButton then
            ColorPickerOkayButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerOkayButton:SetFrameLevel(2001)
        end
        if ColorPickerCancelButton then
            ColorPickerCancelButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerCancelButton:SetFrameLevel(2001)
        end

        ColorPickerFrame.func = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            Config:Set("barGoldColorR", newR)
            Config:Set("barGoldColorG", newG)
            Config:Set("barGoldColorB", newB)
            UpdateGoldColorPreview()
            Config:ApplyHudBorderChrome()
        end
        ColorPickerFrame.cancelFunc = function()
            Config:Set("barGoldColorR", prevR)
            Config:Set("barGoldColorG", prevG)
            Config:Set("barGoldColorB", prevB)
            UpdateGoldColorPreview()
            Config:ApplyHudBorderChrome()
        end

        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false

        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            ColorPickerFrame:Show()
        end)
        delayFrame:Show()
    end)
    
    -- Druid stealth option (middle of row 1, only visible to druids)
    local _, playerClass = UnitClass("player")
    local isDruid = (playerClass == "DRUID")
    
    local druidStealthLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    druidStealthLabel:SetText(T("Use travel form bar in prowl"))
    
    local druidStealthCheck = CreateFrame("CheckButton", self:GetNextElementName("Check"), generalBox, "UICheckButtonTemplate")
    druidStealthCheck:SetWidth(24)
    druidStealthCheck:SetHeight(24)
    druidStealthCheck.label = T("Use travel form bar in prowl")
    druidStealthCheck.tooltipText = T("When enabled, druids in cat form will use the travel form action bar when prowl/stealth is active.")
    druidStealthCheck:SetChecked(Config:Get("druidStealth"))
    druidStealthCheck:SetScript("OnClick", function()
        if not isDruid then return end  -- Prevent clicking if not druid
        local checked = this:GetChecked() == 1
        Config:Set("druidStealth", checked)
        -- Update buttons immediately when toggled
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
    end)
    
    -- Show/hide based on class
    if not isDruid then
        druidStealthLabel:Hide()
        druidStealthCheck:Hide()
    end
    
    local autoRankCheck = CreateFrame("CheckButton", self:GetNextElementName("Check"), generalBox, "UICheckButtonTemplate")
    autoRankCheck:SetWidth(24)
    autoRankCheck:SetHeight(24)
    autoRankCheck:SetPoint("LEFT", goldColorBtn, "RIGHT", 16, 0)
    local autoRankLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    autoRankLabel:SetPoint("LEFT", autoRankCheck, "RIGHT", 4, 0)
    autoRankLabel:SetText(T("Auto-update spell ranks"))
    autoRankCheck.label = T("Auto-update spell ranks")
    autoRankCheck.tooltipText = T("When enabled, spells on action bars will automatically be updated to the highest rank when you learn a new spell rank.")
    autoRankCheck:SetChecked(Config:Get("autoRankEnabled"))
    autoRankCheck:SetScript("OnClick", function()
        local checked = this:GetChecked() == 1
        Config:Set("autoRankEnabled", checked)
    end)
    
    -- Row 2: Positioning options (Size, Pad, X, Y, Star, Scale) + Reset button
    local sizeLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sizeLabel:SetPoint("TOPLEFT", generalBox, "TOPLEFT", generalBox.contentLeft, generalBox.contentTop - 32)
    sizeLabel:SetText(T("Size") .. ":")
    
    local sizeEditBox = self:CreateEditBox(generalBox, 35,
        function() return tostring(Config:Get("barButtonSize")) end,
        function(value)
            local num = tonumber(value) or 40
            if num < 20 then num = 20 end
            if num > 110 then num = 110 end
            Config:Set("barButtonSize", num)
            Config:UpdateActionBarLayout()
        end,
        T("Button Size"),
        T("Size of action bar buttons in pixels. Range: 20-110."))
    sizeEditBox:SetPoint("LEFT", sizeLabel, "RIGHT", 5, 0)
    sizeEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 40
        if num >= 20 and num <= 110 then
            Config:Set("barButtonSize", num)
            Config:UpdateActionBarLayout()
        end
    end)
    
    local padLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    padLabel:SetPoint("LEFT", sizeEditBox, "RIGHT", 14, 0)
    padLabel:SetText(T("Pad") .. ":")
    
    local paddingEditBox = self:CreateEditBox(generalBox, 35,
        function() return tostring(Config:Get("barPadding")) end,
        function(value)
            local num = tonumber(value) or 4
            if num < 0 then num = 0 end
            if num > 100 then num = 100 end
            Config:Set("barPadding", num)
            Config:UpdateActionBarLayout()
        end,
        T("Button Padding"),
        T("Space between buttons in Flat layout. Range: 0-100."))
    paddingEditBox:SetPoint("LEFT", padLabel, "RIGHT", 5, 0)
    paddingEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 4
        if num >= 0 and num <= 100 then
            Config:Set("barPadding", num)
            Config:UpdateActionBarLayout()
        end
    end)
    
    local xLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xLabel:SetPoint("LEFT", paddingEditBox, "RIGHT", 14, 0)
    xLabel:SetText("X:")
    
    local xEditBox = self:CreateEditBox(generalBox, 35,
        function() return tostring(Config:Get("barXOffset")) end,
        function(value)
            local num = tonumber(value) or 0
            Config:Set("barXOffset", num)
            Config:UpdateActionBarLayout()
        end,
        T("X Offset"),
        T("Horizontal offset from screen center."),
        self.NUDGE_MOVE)
    xEditBox:SetPoint("LEFT", xLabel, "RIGHT", 5, 0)
    xEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 0
        Config:Set("barXOffset", num)
        Config:UpdateActionBarLayout()
    end)
    
    local yLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("LEFT", xEditBox, "RIGHT", 14, 0)
    yLabel:SetText("Y:")
    
    local yEditBox = self:CreateEditBox(generalBox, 35,
        function() return tostring(Config:Get("barYOffset")) end,
        function(value)
            local num = tonumber(value) or 70
            Config:Set("barYOffset", num)
            Config:UpdateActionBarLayout()
        end,
        T("Y Offset"),
        T("Vertical offset from screen bottom."),
        self.NUDGE_MOVE)
    yEditBox:SetPoint("LEFT", yLabel, "RIGHT", 5, 0)
    yEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 70
        Config:Set("barYOffset", num)
        Config:UpdateActionBarLayout()
    end)
    
    local starLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    starLabel:SetPoint("LEFT", yEditBox, "RIGHT", 14, 0)
    starLabel:SetText(T("Gap") .. ":")
    
    local starPaddingEditBox = self:CreateEditBox(generalBox, 50,
        function() return tostring(Config:Get("barStarPadding")) end,
        function(value)
            local num = tonumber(value) or 600
            if num < 0 then num = 0 end
            if num > 2000 then num = 2000 end
            Config:Set("barStarPadding", num)
            Config:UpdateActionBarLayout()
        end,
        T("Center Gap"),
        T("Space between left and right button groups. Range: 50-1000."),
        20)
    starPaddingEditBox:SetPoint("LEFT", starLabel, "RIGHT", 5, 0)
    starPaddingEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 600
        if num >= 0 and num <= 2000 then
            Config:Set("barStarPadding", num)
            Config:UpdateActionBarLayout()
        end
    end)

    local mainScaleLabel = generalBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mainScaleLabel:SetPoint("LEFT", starPaddingEditBox, "RIGHT", 14, 0)
    mainScaleLabel:SetText(T("Scale") .. ":")
    local mainScaleBox = CreateContextScaleField(generalBox, "barScale", ApplyMainScale)
    mainScaleBox:SetPoint("LEFT", mainScaleLabel, "RIGHT", 5, 0)
    self.scaleEditBoxes.main = mainScaleBox

    local actionGlyphCheck = self:CreateCheckbox(generalBox, T("Action glyphs"),
        function() return Config:Get("barActionGlyphs") ~= false end,
        function(checked)
            Config:Set("barActionGlyphs", checked)
            Config:UpdateActionBarLayout()
        end,
        T("Show ABXY and D-pad glyphs on action buttons. LB, LT, RB, and RT stay visible."))
    actionGlyphCheck:SetPoint("TOPLEFT", generalBox, "TOPLEFT", generalBox.contentLeft + 520, generalBox.contentTop - 61)

    local hideBarsCheck = self:CreateCheckbox(generalBox, T("Hide Default Bars"),
        function() return Config:Get("hideBlizzardBars") ~= false end,
        function(checked)
            Config:Set("hideBlizzardBars", checked)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.ApplyDefaultBarVisibility then
                ConsoleUI.actionbars:ApplyDefaultBarVisibility()
            end
        end,
        T("Hide Blizzard action and micro bars while ConsoleUI action bars are enabled."))
    hideBarsCheck:SetPoint("TOPLEFT", generalBox, "TOPLEFT", generalBox.contentLeft + 360, generalBox.contentTop - 61)
    
    self:AddSectionReset(generalBox, function()
        Config:Set("barButtonSize", Config.DEFAULTS.barButtonSize)
        Config:Set("barScale", Config.DEFAULTS.barScale)
        Config:Set("barPadding", Config.DEFAULTS.barPadding)
        Config:Set("barStarPadding", Config.DEFAULTS.barStarPadding)
        Config:Set("barXOffset", Config.DEFAULTS.barXOffset)
        Config:Set("barYOffset", Config.DEFAULTS.barYOffset)
        Config:Set("barAppearance", Config.DEFAULTS.barAppearance)
        Config:Set("barLayout", Config.DEFAULTS.barLayout)
        Config:Set("barActionGlyphs", Config.DEFAULTS.barActionGlyphs)
        Config:Set("barGoldBorder", Config.DEFAULTS.barGoldBorder)
        Config:Set("barGoldColorR", Config.DEFAULTS.barGoldColorR)
        Config:Set("barGoldColorG", Config.DEFAULTS.barGoldColorG)
        Config:Set("barGoldColorB", Config.DEFAULTS.barGoldColorB)
        Config:Set("barFlankGap", Config.DEFAULTS.barFlankGap)
        Config:Set("autoRankEnabled", Config.DEFAULTS.autoRankEnabled)
        Config:Set("druidStealth", Config.DEFAULTS.druidStealth)
        Config:Set("hideBlizzardBars", Config.DEFAULTS.hideBlizzardBars)
        Config:UpdateActionBarLayout()
        Config:ApplyHudBorderChrome()
        sizeEditBox:SetText(tostring(Config.DEFAULTS.barButtonSize))
        mainScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.barScale))
        paddingEditBox:SetText(tostring(Config.DEFAULTS.barPadding))
        starPaddingEditBox:SetText(tostring(Config.DEFAULTS.barStarPadding))
        xEditBox:SetText(tostring(Config.DEFAULTS.barXOffset))
        yEditBox:SetText(tostring(Config.DEFAULTS.barYOffset))
        goldCheck:SetChecked(Config.DEFAULTS.barGoldBorder and 1 or 0)
        autoRankCheck:SetChecked(Config.DEFAULTS.autoRankEnabled and 1 or 0)
        druidStealthCheck:SetChecked(Config.DEFAULTS.druidStealth and 1 or 0)
        actionGlyphCheck:SetChecked(Config.DEFAULTS.barActionGlyphs and 1 or 0)
        hideBarsCheck:SetChecked(Config.DEFAULTS.hideBlizzardBars ~= false and 1 or 0)
        UpdateGoldColorPreview()
        local defLayout = Config.DEFAULTS.barLayout or "controller"
        UIDropDownMenu_SetSelectedValue(layoutDropdown, defLayout)
        UIDropDownMenu_SetText(LayoutLabel(defLayout), layoutDropdown)
        if ConsoleUI.actionbars and ConsoleUI.actionbars.ApplyDefaultBarVisibility then
            ConsoleUI.actionbars:ApplyDefaultBarVisibility()
        end
    end)

    local updateRanksButton = self:MakePanelButton(generalBox, "ConsoleUIConfigUpdateRanks", 110, T("Update ranks"), "ghost")
    updateRanksButton:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -12)
    druidStealthCheck:SetPoint("LEFT", updateRanksButton, "RIGHT", 16, 0)
    druidStealthLabel:SetPoint("LEFT", druidStealthCheck, "RIGHT", 4, 0)
    updateRanksButton:SetScript("OnClick", function()
        if ConsoleUI.autorank and ConsoleUI.autorank.ManualUpdate then
            ConsoleUI.autorank:ManualUpdate()
        end
    end)
    
    -- Ensure dropdown button is navigable
    local barsDelayFrame = CreateFrame("Frame")
    barsDelayFrame:SetScript("OnUpdate", function()
        barsDelayFrame:Hide()
        local layoutBtn = getglobal("ConsoleUIConfigBarLayoutDropdownButton")
        if layoutBtn then
            layoutBtn:Enable()
            layoutBtn:Show()
            layoutBtn.label = T("Layout")
            layoutBtn.tooltipText = T("Controller Style is diamonds. Flat is one row of squares. Full shows three controller sets at once (LB, default, LT).")
        end
        if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
            ConsoleUI.cursor:RefreshFrame()
        end
    end)
    barsDelayFrame:Show()

    -- ==================== Left Side Bar Box ====================
    local leftSideBox = self:CreateSectionBox(section, "Left touch bar")
    leftSideBox:ClearAllPoints()
    leftSideBox:SetPoint("TOPLEFT", generalBox, "BOTTOMLEFT", 0, -6)
    leftSideBox:SetPoint("RIGHT", section, "CENTER", -6, 0)
    leftSideBox:SetHeight(88)
    leftSideBox.heightCalculated = true  -- Don't auto-calculate
    
    local leftBarCheck = self:CreateCheckbox(leftSideBox, T("Enable"),
        function() return Config:Get("sideBarLeftEnabled") end,
        function(checked)
            Config:Set("sideBarLeftEnabled", checked)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end,
        T("Enable vertical action bar on the left edge of the screen for touch input."))
    leftBarCheck:SetPoint("TOPLEFT", leftSideBox, "TOPLEFT", leftSideBox.contentLeft, leftSideBox.contentTop)
    
    local leftCountLabel = leftSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftCountLabel:SetPoint("LEFT", leftBarCheck, "RIGHT", 60, 0)
    leftCountLabel:SetText(T("Buttons") .. ":")
    
    local leftCountEditBox = self:CreateEditBox(leftSideBox, 30,
        function() return tostring(Config:Get("sideBarLeftButtons") or 3) end,
        function(value)
            local num = tonumber(value) or 3
            if num < 1 then num = 1 end
            if num > 5 then num = 5 end
            Config:Set("sideBarLeftButtons", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end,
        T("Left Bar Buttons"),
        T("Number of buttons on the left side bar. Range: 1-5."))
    leftCountEditBox:SetPoint("LEFT", leftCountLabel, "RIGHT", 5, 0)
    leftCountEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 3
        if num >= 1 and num <= 5 then
            Config:Set("sideBarLeftButtons", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end
    end)

    local leftOffsetLabel = leftSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftOffsetLabel:SetPoint("TOPLEFT", leftBarCheck, "BOTTOMLEFT", 0, -10)
    leftOffsetLabel:SetText("X:")
    leftOffsetLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local leftOffsetEditBox = self:CreateEditBox(leftSideBox, 42,
        function() return tostring(Config:Get("sideBarLeftOffset") or 5) end,
        function(value)
            local num = tonumber(value) or 5
            if num < 0 then num = 0 end
            if num > 500 then num = 500 end
            Config:Set("sideBarLeftOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end,
        T("Left Edge Offset"),
        T("Distance in pixels from the left screen edge. Increase this to clear a display cutout or touch-safe area."),
        self.NUDGE_MOVE)
    leftOffsetEditBox:SetPoint("LEFT", leftOffsetLabel, "RIGHT", 6, 0)
    leftOffsetEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 5
        if num >= 0 and num <= 500 then
            Config:Set("sideBarLeftOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end
    end)

    local leftYLabel = leftSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftYLabel:SetPoint("LEFT", leftOffsetEditBox, "RIGHT", 12, 0)
    leftYLabel:SetText("Y:")
    leftYLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local leftYEditBox = self:CreateEditBox(leftSideBox, 42,
        function() return tostring(Config:Get("sideBarLeftYOffset") or 0) end,
        function(value)
            local num = tonumber(value) or 0
            if num < -500 then num = -500 end
            if num > 500 then num = 500 end
            Config:Set("sideBarLeftYOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end,
        T("Left Y Offset"),
        T("Vertical offset from screen middle. Positive is up, negative is down. Range: -500 to 500."),
        self.NUDGE_MOVE)
    leftYEditBox:SetPoint("LEFT", leftYLabel, "RIGHT", 6, 0)
    leftYEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 0
        if num >= -500 and num <= 500 then
            Config:Set("sideBarLeftYOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end
    end)

    local leftScaleLabel = leftSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftScaleLabel:SetPoint("LEFT", leftYEditBox, "RIGHT", 12, 0)
    leftScaleLabel:SetText(T("Scale") .. ":")
    leftScaleLabel:SetTextColor(unpack(self.UI_COLORS.muted))
    local leftScaleBox = CreateContextScaleField(leftSideBox, "sideBarLeftScale", ApplySideScale)
    leftScaleBox:SetPoint("LEFT", leftScaleLabel, "RIGHT", 5, 0)
    self.scaleEditBoxes.left = leftScaleBox

    self:AddSectionReset(leftSideBox, function()
        Config:Set("sideBarLeftEnabled", Config.DEFAULTS.sideBarLeftEnabled)
        Config:Set("sideBarLeftButtons", Config.DEFAULTS.sideBarLeftButtons)
        Config:Set("sideBarLeftOffset", Config.DEFAULTS.sideBarLeftOffset)
        Config:Set("sideBarLeftYOffset", Config.DEFAULTS.sideBarLeftYOffset)
        Config:Set("sideBarLeftScale", Config.DEFAULTS.sideBarLeftScale)
        leftBarCheck:SetChecked(Config.DEFAULTS.sideBarLeftEnabled and 1 or 0)
        leftCountEditBox:SetText(tostring(Config.DEFAULTS.sideBarLeftButtons))
        leftOffsetEditBox:SetText(tostring(Config.DEFAULTS.sideBarLeftOffset))
        leftYEditBox:SetText(tostring(Config.DEFAULTS.sideBarLeftYOffset))
        leftScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.sideBarLeftScale))
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
            ConsoleUI.actionbars:UpdateSideBars()
        end
        if Config.UpdateSidebarBindingVisibility then
            Config:UpdateSidebarBindingVisibility()
        end
    end)

    -- ==================== Right Side Bar Box ====================
    local rightSideBox = self:CreateSectionBox(section, "Right touch bar")
    rightSideBox:ClearAllPoints()
    rightSideBox:SetPoint("TOPRIGHT", generalBox, "BOTTOMRIGHT", 0, -6)
    rightSideBox:SetPoint("LEFT", section, "CENTER", 6, 0)
    rightSideBox:SetHeight(88)
    rightSideBox.heightCalculated = true  -- Don't auto-calculate
    
    local rightBarCheck = self:CreateCheckbox(rightSideBox, T("Enable"),
        function() return Config:Get("sideBarRightEnabled") end,
        function(checked)
            Config:Set("sideBarRightEnabled", checked)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end,
        T("Enable vertical action bar on the right edge of the screen for touch input."))
    rightBarCheck:SetPoint("TOPLEFT", rightSideBox, "TOPLEFT", rightSideBox.contentLeft, rightSideBox.contentTop)
    
    local rightCountLabel = rightSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightCountLabel:SetPoint("LEFT", rightBarCheck, "RIGHT", 60, 0)
    rightCountLabel:SetText(T("Buttons") .. ":")
    
    local rightCountEditBox = self:CreateEditBox(rightSideBox, 30,
        function() return tostring(Config:Get("sideBarRightButtons") or 3) end,
        function(value)
            local num = tonumber(value) or 3
            if num < 1 then num = 1 end
            if num > 5 then num = 5 end
            Config:Set("sideBarRightButtons", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end,
        T("Right Bar Buttons"),
        T("Number of buttons on the right side bar. Range: 1-5."))
    rightCountEditBox:SetPoint("LEFT", rightCountLabel, "RIGHT", 5, 0)
    rightCountEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 3
        if num >= 1 and num <= 5 then
            Config:Set("sideBarRightButtons", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
            -- Update sidebar binding visibility in config panel
            if Config.UpdateSidebarBindingVisibility then
                Config:UpdateSidebarBindingVisibility()
            end
        end
    end)

    local rightOffsetLabel = rightSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightOffsetLabel:SetPoint("TOPLEFT", rightBarCheck, "BOTTOMLEFT", 0, -10)
    rightOffsetLabel:SetText("X:")
    rightOffsetLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local rightOffsetEditBox = self:CreateEditBox(rightSideBox, 42,
        function() return tostring(Config:Get("sideBarRightOffset") or 5) end,
        function(value)
            local num = tonumber(value) or 5
            if num < 0 then num = 0 end
            if num > 500 then num = 500 end
            Config:Set("sideBarRightOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end,
        T("Right Edge Offset"),
        T("Distance in pixels from the right screen edge. Increase this to clear a display cutout or touch-safe area."),
        self.NUDGE_MOVE)
    rightOffsetEditBox:SetPoint("LEFT", rightOffsetLabel, "RIGHT", 6, 0)
    rightOffsetEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 5
        if num >= 0 and num <= 500 then
            Config:Set("sideBarRightOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end
    end)

    local rightYLabel = rightSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightYLabel:SetPoint("LEFT", rightOffsetEditBox, "RIGHT", 12, 0)
    rightYLabel:SetText("Y:")
    rightYLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local rightYEditBox = self:CreateEditBox(rightSideBox, 42,
        function() return tostring(Config:Get("sideBarRightYOffset") or 0) end,
        function(value)
            local num = tonumber(value) or 0
            if num < -500 then num = -500 end
            if num > 500 then num = 500 end
            Config:Set("sideBarRightYOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end,
        T("Right Y Offset"),
        T("Vertical offset from screen middle. Positive is up, negative is down. Range: -500 to 500."),
        self.NUDGE_MOVE)
    rightYEditBox:SetPoint("LEFT", rightYLabel, "RIGHT", 6, 0)
    rightYEditBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText()) or 0
        if num >= -500 and num <= 500 then
            Config:Set("sideBarRightYOffset", num)
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
                ConsoleUI.actionbars:UpdateSideBars()
            end
        end
    end)

    local rightScaleLabel = rightSideBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightScaleLabel:SetPoint("LEFT", rightYEditBox, "RIGHT", 12, 0)
    rightScaleLabel:SetText(T("Scale") .. ":")
    rightScaleLabel:SetTextColor(unpack(self.UI_COLORS.muted))
    local rightScaleBox = CreateContextScaleField(rightSideBox, "sideBarRightScale", ApplySideScale)
    rightScaleBox:SetPoint("LEFT", rightScaleLabel, "RIGHT", 5, 0)
    self.scaleEditBoxes.right = rightScaleBox

    self:AddSectionReset(rightSideBox, function()
        Config:Set("sideBarRightEnabled", Config.DEFAULTS.sideBarRightEnabled)
        Config:Set("sideBarRightButtons", Config.DEFAULTS.sideBarRightButtons)
        Config:Set("sideBarRightOffset", Config.DEFAULTS.sideBarRightOffset)
        Config:Set("sideBarRightYOffset", Config.DEFAULTS.sideBarRightYOffset)
        Config:Set("sideBarRightScale", Config.DEFAULTS.sideBarRightScale)
        rightBarCheck:SetChecked(Config.DEFAULTS.sideBarRightEnabled and 1 or 0)
        rightCountEditBox:SetText(tostring(Config.DEFAULTS.sideBarRightButtons))
        rightOffsetEditBox:SetText(tostring(Config.DEFAULTS.sideBarRightOffset))
        rightYEditBox:SetText(tostring(Config.DEFAULTS.sideBarRightYOffset))
        rightScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.sideBarRightScale))
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
            ConsoleUI.actionbars:UpdateSideBars()
        end
        if Config.UpdateSidebarBindingVisibility then
            Config:UpdateSidebarBindingVisibility()
        end
    end)

    local function ApplyExtraBars()
        if ConsoleUI.actionbars and ConsoleUI.actionbars.extra and ConsoleUI.actionbars.extra.Update then
            ConsoleUI.actionbars.extra:Update()
        end
    end

    local stanceBox = self:CreateSectionBox(section, T("Stance bar"))
    stanceBox:ClearAllPoints()
    stanceBox:SetPoint("TOPLEFT", leftSideBox, "BOTTOMLEFT", 0, -6)
    stanceBox:SetPoint("RIGHT", section, "CENTER", -6, 0)
    stanceBox:SetHeight(88)
    stanceBox.heightCalculated = true

    local stanceUnlock = self:CreateCheckbox(stanceBox, T("Unlock move"),
        function() return Config:Get("extraBarsUnlocked") end,
        function(checked)
            Config:Set("extraBarsUnlocked", checked)
            if Config.extraUnlockPet then
                Config.extraUnlockPet:SetChecked(checked and 1 or 0)
            end
            ApplyExtraBars()
        end,
        T("Drag the bar. Locked in combat."))
    stanceUnlock:SetPoint("TOPLEFT", stanceBox, "TOPLEFT", stanceBox.contentLeft, stanceBox.contentTop)
    self.extraUnlockStance = stanceUnlock

    local stanceXBox, stanceYBox = self:AddOffsetRow(stanceBox, stanceUnlock, "stanceBarOffsetX", "stanceBarOffsetY", ApplyExtraBars, false)

    local stanceScaleLabel = stanceBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    stanceScaleLabel:SetPoint("LEFT", stanceYBox, "RIGHT", 12, 0)
    stanceScaleLabel:SetText(T("Scale") .. ":")
    stanceScaleLabel:SetTextColor(unpack(self.UI_COLORS.muted))
    local stanceScaleBox = CreateContextScaleField(stanceBox, "stanceBarScale", ApplyExtraScale)
    stanceScaleBox:SetPoint("LEFT", stanceScaleLabel, "RIGHT", 5, 0)
    self.scaleEditBoxes.stance = stanceScaleBox

    self:AddSectionReset(stanceBox, function()
        Config:Set("stanceBarOffsetX", Config.DEFAULTS.stanceBarOffsetX)
        Config:Set("stanceBarOffsetY", Config.DEFAULTS.stanceBarOffsetY)
        Config:Set("stanceBarScale", Config.DEFAULTS.stanceBarScale)
        stanceXBox:SetText(tostring(Config.DEFAULTS.stanceBarOffsetX))
        stanceYBox:SetText(tostring(Config.DEFAULTS.stanceBarOffsetY))
        stanceScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.stanceBarScale))
        ApplyExtraBars()
    end)

    local petBox = self:CreateSectionBox(section, T("Pet bar"))
    petBox:ClearAllPoints()
    petBox:SetPoint("TOPRIGHT", rightSideBox, "BOTTOMRIGHT", 0, -6)
    petBox:SetPoint("LEFT", section, "CENTER", 6, 0)
    petBox:SetHeight(110)
    petBox.heightCalculated = true

    local petUnlock = self:CreateCheckbox(petBox, T("Unlock move"),
        function() return Config:Get("extraBarsUnlocked") end,
        function(checked)
            Config:Set("extraBarsUnlocked", checked)
            if Config.extraUnlockStance then
                Config.extraUnlockStance:SetChecked(checked and 1 or 0)
            end
            ApplyExtraBars()
        end,
        T("Drag the bar. Locked in combat."))
    petUnlock:SetPoint("TOPLEFT", petBox, "TOPLEFT", petBox.contentLeft, petBox.contentTop)
    self.extraUnlockPet = petUnlock

    local growLabel = petBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    growLabel:SetPoint("LEFT", petUnlock, "RIGHT", 80, 0)
    growLabel:SetText(T("Grow") .. ":")
    growLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local growDrop = CreateFrame("Frame", "ConsoleUIConfigPetBarGrowDropdown", petBox, "UIDropDownMenuTemplate")
    growDrop:SetPoint("LEFT", growLabel, "RIGHT", -16, -2)

    local function GrowLabel(value)
        if value == "left" then
            return T("Left")
        end
        return T("Right")
    end

    local function InitPetGrow()
        local selected = UIDropDownMenu_GetSelectedValue(growDrop) or (Config:Get("petBarGrow") or "right")
        local info = {}
        info.text = T("Right")
        info.value = "right"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(growDrop, "right")
            UIDropDownMenu_SetText(T("Right"), growDrop)
            Config:Set("petBarGrow", "right")
            ApplyExtraBars()
        end
        if info.value == selected then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
        info = {}
        info.text = T("Left")
        info.value = "left"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(growDrop, "left")
            UIDropDownMenu_SetText(T("Left"), growDrop)
            Config:Set("petBarGrow", "left")
            ApplyExtraBars()
        end
        if info.value == selected then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
    end
    UIDropDownMenu_Initialize(growDrop, InitPetGrow)
    UIDropDownMenu_SetWidth(100, growDrop)
    local currentGrow = Config:Get("petBarGrow") or "right"
    UIDropDownMenu_SetSelectedValue(growDrop, currentGrow)
    UIDropDownMenu_SetText(GrowLabel(currentGrow), growDrop)

    local petXBox, petYBox = self:AddOffsetRow(petBox, petUnlock, "petBarOffsetX", "petBarOffsetY", ApplyExtraBars, false)

    local petScaleLabel = petBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    petScaleLabel:SetPoint("LEFT", petYBox, "RIGHT", 12, 0)
    petScaleLabel:SetText(T("Scale") .. ":")
    petScaleLabel:SetTextColor(unpack(self.UI_COLORS.muted))
    local petScaleBox = CreateContextScaleField(petBox, "petBarScale", ApplyExtraScale)
    petScaleBox:SetPoint("LEFT", petScaleLabel, "RIGHT", 5, 0)
    self.scaleEditBoxes.pet = petScaleBox

    self:AddSectionReset(petBox, function()
        Config:Set("petBarOffsetX", Config.DEFAULTS.petBarOffsetX)
        Config:Set("petBarOffsetY", Config.DEFAULTS.petBarOffsetY)
        Config:Set("petBarGrow", Config.DEFAULTS.petBarGrow)
        Config:Set("petBarScale", Config.DEFAULTS.petBarScale)
        petXBox:SetText(tostring(Config.DEFAULTS.petBarOffsetX))
        petYBox:SetText(tostring(Config.DEFAULTS.petBarOffsetY))
        petScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.petBarScale))
        UIDropDownMenu_SetSelectedValue(growDrop, Config.DEFAULTS.petBarGrow)
        UIDropDownMenu_SetText(GrowLabel(Config.DEFAULTS.petBarGrow), growDrop)
        ApplyExtraBars()
    end)

    self.extraOffsetBoxes = { stanceX = stanceXBox, stanceY = stanceYBox, petX = petXBox, petY = petYBox }

    -- ==================== XP Bar Box ====================
    local xpBox = self:CreateSectionBox(hudSection, T("XP Bar"))
    xpBox:ClearAllPoints()
    xpBox:SetPoint("TOPLEFT", hudSection, "TOPLEFT", 0, -6)
    xpBox:SetPoint("RIGHT", hudSection, "CENTER", -6, 0)
    xpBox:SetHeight(144)
    xpBox.heightCalculated = true  -- Don't auto-calculate
    
    -- Row 1: Always Visible and Text checkboxes
    local xpAlwaysCheck = self:CreateCheckbox(xpBox, T("Always Visible"),
        function() return Config:Get("xpBarAlways") or false end,
        function(checked)
            Config:Set("xpBarAlways", checked)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.xpBar then
                ConsoleUI.xpbar.xpBar.always = checked
                if checked then
                    ConsoleUI.xpbar.xpBar:SetAlpha(1)
                    ConsoleUI.xpbar.xpBar:Show()
                end
            end
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("When enabled, the XP bar is always visible instead of fading out."))
    xpAlwaysCheck:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft, xpBox.contentTop)
    
    local xpTextShowCheck = CreateFrame("CheckButton", self:GetNextElementName("Check"), xpBox, "UICheckButtonTemplate")
    xpTextShowCheck:SetWidth(24)
    xpTextShowCheck:SetHeight(24)
    xpTextShowCheck:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft + 285, xpBox.contentTop)
    local xpTextLabel = xpBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xpTextLabel:SetPoint("RIGHT", xpTextShowCheck, "LEFT", -2, 0)
    xpTextLabel:SetText(T("Text"))
    xpTextShowCheck.label = T("XP Text")
    xpTextShowCheck.tooltipText = T("Show XP text on the bar.")
    local xpTextValue = Config:Get("xpBarTextShow")
    xpTextShowCheck:SetChecked(xpTextValue == nil and true or xpTextValue)
    xpTextShowCheck:SetScript("OnClick", function()
        local checked = this:GetChecked() == 1
        Config:Set("xpBarTextShow", checked)
        if ConsoleUI.xpbar and ConsoleUI.xpbar.xpBar then
            ConsoleUI.xpbar:ReloadBarConfig(ConsoleUI.xpbar.xpBar, "XP")
            if ConsoleUI.xpbar.xpBar.always and ConsoleUI.xpbar.Fire then
                ConsoleUI.xpbar:Fire(ConsoleUI.xpbar.xpBar, "PLAYER_XP_UPDATE")
            end
            if ConsoleUI.xpbar.xpBar.bar and ConsoleUI.xpbar.xpBar.bar.text then
                if checked then
                    ConsoleUI.xpbar.xpBar.bar.text:Show()
                else
                    ConsoleUI.xpbar.xpBar.bar.text:Hide()
                end
            end
        end
    end)
    
    -- Row 2: Width and Height. Timeout shares the offset row below so the
    -- spinner controls never collide with the next label at narrow UI scales.
    local xpWidthLabel = xpBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xpWidthLabel:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft, xpBox.contentTop - 38)
    xpWidthLabel:SetHeight(20)
    xpWidthLabel:SetText(T("Width") .. ":")
    
    local xpWidthEditBox = self:CreateEditBox(xpBox, 40,
        function()
            return tostring(Config:Get("xpBarWidth") or 400)
        end,
        function(value)
            local num = tonumber(value) or 400
            if num < 50 then num = 50 end
            if num > 2000 then num = 2000 end
            Config:Set("xpBarWidth", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("XP Bar Width"),
        T("Width of XP bar in pixels. Range: 50-2000."))
    xpWidthEditBox:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft + 44, xpBox.contentTop - 38)
    
    local xpHeightLabel = xpBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xpHeightLabel:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft + 125, xpBox.contentTop - 38)
    xpHeightLabel:SetHeight(20)
    xpHeightLabel:SetText(T("Height") .. ":")
    
    local xpHeightEditBox = self:CreateEditBox(xpBox, 30,
        function() return tostring(Config:Get("xpBarHeight") or 16) end,
        function(value)
            local num = tonumber(value) or 16
            if num < 16 then num = 16 end
            if num > 100 then num = 100 end
            Config:Set("xpBarHeight", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("XP Bar Height"),
        T("Height of XP bar in pixels. Range: 16-100."))
    xpHeightEditBox:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft + 181, xpBox.contentTop - 38)
    
    local xpTimeoutLabel = xpBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xpTimeoutLabel:SetText(T("Timeout") .. ":")
    
    local xpTimeoutEditBox = self:CreateEditBox(xpBox, 30,
        function() return tostring(Config:Get("xpBarTimeout") or 5.0) end,
        function(value)
            local num = tonumber(value) or 5.0
            if num < 0 then num = 0 end
            if num > 60 then num = 60 end
            Config:Set("xpBarTimeout", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.xpBar then
                ConsoleUI.xpbar.xpBar.timeout = num
            end
        end,
        T("XP Bar Timeout"),
        T("Seconds before the bar fades out. Range: 0-60."))
    local xpXEditBox, xpYEditBox = self:AddOffsetRow(xpBox, xpWidthLabel, "xpBarOffsetX", "xpBarOffsetY", function()
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    end, nil, xpBox.contentTop - 74)
    xpTimeoutLabel:SetPoint("TOPLEFT", xpBox, "TOPLEFT", xpBox.contentLeft + 174, xpBox.contentTop - 74)
    xpTimeoutLabel:SetHeight(20)
    xpTimeoutLabel:SetWidth(54)
    xpTimeoutLabel:SetJustifyH("LEFT")
    xpTimeoutEditBox:SetPoint("TOPLEFT", xpTimeoutLabel, "TOPRIGHT", 5, 0)

    self:AddSectionReset(xpBox, function()
        Config:Set("xpBarAlways", Config.DEFAULTS.xpBarAlways)
        Config:Set("xpBarTextShow", Config.DEFAULTS.xpBarTextShow)
        Config:Set("xpBarWidth", Config.DEFAULTS.xpBarWidth)
        Config:Set("xpBarHeight", Config.DEFAULTS.xpBarHeight)
        Config:Set("xpBarTimeout", Config.DEFAULTS.xpBarTimeout)
        Config:Set("xpBarOffsetX", Config.DEFAULTS.xpBarOffsetX)
        Config:Set("xpBarOffsetY", Config.DEFAULTS.xpBarOffsetY)
        xpAlwaysCheck:SetChecked(Config.DEFAULTS.xpBarAlways and 1 or 0)
        xpTextShowCheck:SetChecked(Config.DEFAULTS.xpBarTextShow and 1 or 0)
        xpWidthEditBox:SetText(tostring(Config.DEFAULTS.xpBarWidth or 400))
        xpHeightEditBox:SetText(tostring(Config.DEFAULTS.xpBarHeight))
        xpTimeoutEditBox:SetText(tostring(Config.DEFAULTS.xpBarTimeout))
        xpXEditBox:SetText(tostring(Config.DEFAULTS.xpBarOffsetX))
        xpYEditBox:SetText(tostring(Config.DEFAULTS.xpBarOffsetY))
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    end)
    
    -- ==================== Rep Bar Box ====================
    local repBox = self:CreateSectionBox(hudSection, T("Rep Bar"))
    repBox:ClearAllPoints()
    repBox:SetPoint("TOPRIGHT", hudSection, "TOPRIGHT", 0, -6)
    repBox:SetPoint("LEFT", hudSection, "CENTER", 6, 0)
    repBox:SetHeight(144)
    repBox.heightCalculated = true  -- Don't auto-calculate
    
    -- Row 1: Always Visible and Text checkboxes
    local repAlwaysCheck = self:CreateCheckbox(repBox, T("Always Visible"),
        function() return Config:Get("repBarAlways") or false end,
        function(checked)
            Config:Set("repBarAlways", checked)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.repBar then
                ConsoleUI.xpbar.repBar.always = checked
                if checked then
                    ConsoleUI.xpbar.repBar:SetAlpha(1)
                    ConsoleUI.xpbar.repBar:Show()
                end
            end
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("When enabled, the Reputation bar is always visible instead of fading out."))
    repAlwaysCheck:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft, repBox.contentTop)
    
    local repTextShowCheck = CreateFrame("CheckButton", self:GetNextElementName("Check"), repBox, "UICheckButtonTemplate")
    repTextShowCheck:SetWidth(24)
    repTextShowCheck:SetHeight(24)
    repTextShowCheck:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft + 285, repBox.contentTop)
    local repTextLabel = repBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    repTextLabel:SetPoint("RIGHT", repTextShowCheck, "LEFT", -2, 0)
    repTextLabel:SetText(T("Text"))
    repTextShowCheck.label = T("Rep Text")
    repTextShowCheck.tooltipText = T("Show Reputation text on the bar.")
    local repTextValue = Config:Get("repBarTextShow")
    repTextShowCheck:SetChecked(repTextValue == nil and true or repTextValue)
    repTextShowCheck:SetScript("OnClick", function()
        local checked = this:GetChecked() == 1
        Config:Set("repBarTextShow", checked)
        if ConsoleUI.xpbar and ConsoleUI.xpbar.repBar then
            ConsoleUI.xpbar.repBar.text_show = checked
            ConsoleUI.xpbar:ReloadBarConfig(ConsoleUI.xpbar.repBar, "REP")
            if ConsoleUI.xpbar.repBar.always and ConsoleUI.xpbar.Fire then
                ConsoleUI.xpbar:Fire(ConsoleUI.xpbar.repBar, "UPDATE_FACTION")
            end
            if ConsoleUI.xpbar.repBar.bar and ConsoleUI.xpbar.repBar.bar.text then
                if checked then
                    ConsoleUI.xpbar.repBar.bar.text:Show()
                else
                    ConsoleUI.xpbar.repBar.bar.text:Hide()
                end
            end
        end
    end)
    
    -- Row 2: Width and Height. Timeout shares the offset row below so the
    -- spinner controls never collide with the next label at narrow UI scales.
    local repWidthLabel = repBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    repWidthLabel:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft, repBox.contentTop - 38)
    repWidthLabel:SetHeight(20)
    repWidthLabel:SetText(T("Width") .. ":")
    
    local repWidthEditBox = self:CreateEditBox(repBox, 40,
        function()
            return tostring(Config:Get("repBarWidth") or 400)
        end,
        function(value)
            local num = tonumber(value) or 400
            if num < 50 then num = 50 end
            if num > 2000 then num = 2000 end
            Config:Set("repBarWidth", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("Rep Bar Width"),
        T("Width of Reputation bar in pixels. Range: 50-2000."))
    repWidthEditBox:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft + 44, repBox.contentTop - 38)
    
    local repHeightLabel = repBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    repHeightLabel:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft + 125, repBox.contentTop - 38)
    repHeightLabel:SetHeight(20)
    repHeightLabel:SetText(T("Height") .. ":")
    
    local repHeightEditBox = self:CreateEditBox(repBox, 30,
        function() return tostring(Config:Get("repBarHeight") or 16) end,
        function(value)
            local num = tonumber(value) or 16
            if num < 16 then num = 16 end
            if num > 100 then num = 100 end
            Config:Set("repBarHeight", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
                ConsoleUI.xpbar:UpdateAllBars()
            end
        end,
        T("Rep Bar Height"),
        T("Height of Reputation bar in pixels. Range: 16-100."))
    repHeightEditBox:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft + 181, repBox.contentTop - 38)
    
    local repTimeoutLabel = repBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    repTimeoutLabel:SetText(T("Timeout") .. ":")
    
    local repTimeoutEditBox = self:CreateEditBox(repBox, 30,
        function() return tostring(Config:Get("repBarTimeout") or 5.0) end,
        function(value)
            local num = tonumber(value) or 5.0
            if num < 0 then num = 0 end
            if num > 60 then num = 60 end
            Config:Set("repBarTimeout", num)
            if ConsoleUI.xpbar and ConsoleUI.xpbar.repBar then
                ConsoleUI.xpbar.repBar.timeout = num
            end
        end,
        T("Rep Bar Timeout"),
        T("Seconds before the bar fades out. Range: 0-60."))
    local repXEditBox, repYEditBox = self:AddOffsetRow(repBox, repWidthLabel, "repBarOffsetX", "repBarOffsetY", function()
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    end, nil, repBox.contentTop - 74)
    repTimeoutLabel:SetPoint("TOPLEFT", repBox, "TOPLEFT", repBox.contentLeft + 174, repBox.contentTop - 74)
    repTimeoutLabel:SetHeight(20)
    repTimeoutLabel:SetWidth(54)
    repTimeoutLabel:SetJustifyH("LEFT")
    repTimeoutEditBox:SetPoint("TOPLEFT", repTimeoutLabel, "TOPRIGHT", 5, 0)

    self:AddSectionReset(repBox, function()
        Config:Set("repBarAlways", Config.DEFAULTS.repBarAlways)
        Config:Set("repBarTextShow", Config.DEFAULTS.repBarTextShow)
        Config:Set("repBarWidth", Config.DEFAULTS.repBarWidth)
        Config:Set("repBarHeight", Config.DEFAULTS.repBarHeight)
        Config:Set("repBarTimeout", Config.DEFAULTS.repBarTimeout)
        Config:Set("repBarOffsetX", Config.DEFAULTS.repBarOffsetX)
        Config:Set("repBarOffsetY", Config.DEFAULTS.repBarOffsetY)
        repAlwaysCheck:SetChecked(Config.DEFAULTS.repBarAlways and 1 or 0)
        repTextShowCheck:SetChecked(Config.DEFAULTS.repBarTextShow and 1 or 0)
        repWidthEditBox:SetText(tostring(Config.DEFAULTS.repBarWidth or 400))
        repHeightEditBox:SetText(tostring(Config.DEFAULTS.repBarHeight))
        repTimeoutEditBox:SetText(tostring(Config.DEFAULTS.repBarTimeout))
        repXEditBox:SetText(tostring(Config.DEFAULTS.repBarOffsetX))
        repYEditBox:SetText(tostring(Config.DEFAULTS.repBarOffsetY))
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    end)
    
    -- ==================== Cast Bar Box ====================
    local castBox = self:CreateSectionBox(hudSection, T("Cast Bar"))
    castBox:ClearAllPoints()
    castBox:SetPoint("TOPLEFT", xpBox, "BOTTOMLEFT", 0, -6)
    castBox:SetPoint("RIGHT", hudSection, "RIGHT", -5, 0)
    castBox:SetHeight(110)
    castBox.heightCalculated = true
    
    -- Row 1: Enable checkbox, Height, Color button
    local castEnabledCheck = self:CreateCheckbox(castBox, T("Enable"),
        function() return Config:Get("castbarEnabled") end,
        function(checked)
            Config:Set("castbarEnabled", checked)
            if ConsoleUI.castbar and ConsoleUI.castbar.ReloadConfig then
                ConsoleUI.castbar:ReloadConfig()
            end
        end,
        T("Enable the custom cast bar that appears above the XP and reputation bars."))
    castEnabledCheck:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft, castBox.contentTop)
    
    local castHeightLabel = castBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    castHeightLabel:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 145, castBox.contentTop)
    castHeightLabel:SetText(T("Height") .. ":")
    
    local castHeightEditBox = self:CreateEditBox(castBox, 35,
        function() return tostring(Config:Get("castbarHeight") or 6) end,
        function(value)
            local num = tonumber(value) or 6
            if num < 6 then num = 6 end
            if num > 100 then num = 100 end
            Config:Set("castbarHeight", num)
            if ConsoleUI.castbar and ConsoleUI.castbar.UpdatePosition then
                ConsoleUI.castbar:UpdatePosition()
            end
        end,
        T("Cast Bar Height"),
        T("Height of the cast strip in pixels. Range: 6-100."))
    castHeightEditBox:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 200, castBox.contentTop - 2)

    local castXEditBox, castYEditBox = self:AddOffsetRow(castBox, castEnabledCheck, "castbarOffsetX", "castbarOffsetY", function()
        if ConsoleUI.castbar and ConsoleUI.castbar.UpdatePosition then
            ConsoleUI.castbar:UpdatePosition()
        end
    end)
    
    local castColorLabel = castBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    castColorLabel:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 290, castBox.contentTop)
    castColorLabel:SetText(T("Color") .. ":")
    
    local castColorBtn = CreateFrame("Button", self:GetNextElementName("ColorBtn"), castBox)
    castColorBtn:SetWidth(40)
    castColorBtn:SetHeight(20)
    castColorBtn:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 340, castBox.contentTop - 1)
    castColorBtn.label = T("Cast Bar Color")
    castColorBtn.tooltipText = T("Click to choose the cast bar fill color.")
    
    local castColorPreview = castColorBtn:CreateTexture(nil, "BACKGROUND")
    castColorPreview:SetAllPoints()
    
    local function UpdateCastColorPreview()
        local r = Config:Get("castbarColorR") or 0.0
        local g = Config:Get("castbarColorG") or 0.5
        local b = Config:Get("castbarColorB") or 1.0
        castColorPreview:SetTexture(r, g, b)
    end
    UpdateCastColorPreview()
    
    castColorBtn:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    castColorBtn:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    castColorBtn:SetScript("OnClick", function()
        local r = Config:Get("castbarColorR") or 0.0
        local g = Config:Get("castbarColorG") or 0.5
        local b = Config:Get("castbarColorB") or 1.0
        
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(2000)
        
        if ColorPickerOkayButton then
            ColorPickerOkayButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerOkayButton:SetFrameLevel(2001)
        end
        if ColorPickerCancelButton then
            ColorPickerCancelButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerCancelButton:SetFrameLevel(2001)
        end
        
        ColorPickerFrame.func = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            Config:Set("castbarColorR", newR)
            Config:Set("castbarColorG", newG)
            Config:Set("castbarColorB", newB)
            UpdateCastColorPreview()
            if ConsoleUI.castbar and ConsoleUI.castbar.UpdateColor then
                ConsoleUI.castbar:UpdateColor()
            end
        end
        
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false
        
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            ColorPickerFrame:Show()
        end)
        delayFrame:Show()
    end)
    
    -- Channel color picker
    local channelColorLabel = castBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    channelColorLabel:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 440, castBox.contentTop)
    channelColorLabel:SetText(T("Channel") .. ":")
    
    local channelColorBtn = CreateFrame("Button", self:GetNextElementName("ColorBtn"), castBox)
    channelColorBtn:SetWidth(40)
    channelColorBtn:SetHeight(20)
    channelColorBtn:SetPoint("TOPLEFT", castBox, "TOPLEFT", castBox.contentLeft + 500, castBox.contentTop - 1)
    channelColorBtn.label = T("Channel Color")
    channelColorBtn.tooltipText = T("Click to choose the color for channeling spells (bandages, etc).")
    
    local channelColorPreview = channelColorBtn:CreateTexture(nil, "BACKGROUND")
    channelColorPreview:SetAllPoints()
    
    local function UpdateChannelColorPreview()
        local r = Config:Get("castbarChannelColorR") or 1.0
        local g = Config:Get("castbarChannelColorG") or 0.75
        local b = Config:Get("castbarChannelColorB") or 0.25
        channelColorPreview:SetTexture(r, g, b)
    end
    UpdateChannelColorPreview()
    
    channelColorBtn:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    channelColorBtn:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    channelColorBtn:SetScript("OnClick", function()
        local r = Config:Get("castbarChannelColorR") or 1.0
        local g = Config:Get("castbarChannelColorG") or 0.75
        local b = Config:Get("castbarChannelColorB") or 0.25
        
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(2000)
        
        if ColorPickerOkayButton then
            ColorPickerOkayButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerOkayButton:SetFrameLevel(2001)
        end
        if ColorPickerCancelButton then
            ColorPickerCancelButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerCancelButton:SetFrameLevel(2001)
        end
        
        ColorPickerFrame.func = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            Config:Set("castbarChannelColorR", newR)
            Config:Set("castbarChannelColorG", newG)
            Config:Set("castbarChannelColorB", newB)
            UpdateChannelColorPreview()
        end
        
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false
        
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            ColorPickerFrame:Show()
        end)
        delayFrame:Show()
    end)

    self:AddSectionReset(castBox, function()
        Config:Set("castbarEnabled", Config.DEFAULTS.castbarEnabled)
        Config:Set("castbarHeight", Config.DEFAULTS.castbarHeight)
        Config:Set("castbarOffsetX", Config.DEFAULTS.castbarOffsetX)
        Config:Set("castbarOffsetY", Config.DEFAULTS.castbarOffsetY)
        Config:Set("castbarColorR", Config.DEFAULTS.castbarColorR)
        Config:Set("castbarColorG", Config.DEFAULTS.castbarColorG)
        Config:Set("castbarColorB", Config.DEFAULTS.castbarColorB)
        Config:Set("castbarChannelColorR", Config.DEFAULTS.castbarChannelColorR)
        Config:Set("castbarChannelColorG", Config.DEFAULTS.castbarChannelColorG)
        Config:Set("castbarChannelColorB", Config.DEFAULTS.castbarChannelColorB)
        castEnabledCheck:SetChecked(Config.DEFAULTS.castbarEnabled and 1 or 0)
        castHeightEditBox:SetText(tostring(Config.DEFAULTS.castbarHeight))
        castXEditBox:SetText(tostring(Config.DEFAULTS.castbarOffsetX))
        castYEditBox:SetText(tostring(Config.DEFAULTS.castbarOffsetY))
        UpdateCastColorPreview()
        UpdateChannelColorPreview()
        if ConsoleUI.castbar and ConsoleUI.castbar.ReloadConfig then
            ConsoleUI.castbar:ReloadConfig()
        end
    end)

    -- ==================== Swing Timer Box ====================
    local swingBox = self:CreateSectionBox(hudSection, T("Swing Timer"))
    swingBox:ClearAllPoints()
    swingBox:SetPoint("TOPLEFT", castBox, "BOTTOMLEFT", 0, -6)
    swingBox:SetPoint("RIGHT", hudSection, "RIGHT", -5, 0)
    swingBox:SetHeight(168)
    swingBox.heightCalculated = true

    local function ApplySwingTimer()
        if ConsoleUI.swingbar and ConsoleUI.swingbar.ReloadConfig then
            ConsoleUI.swingbar:ReloadConfig()
        end
    end

    local swingEnabledCheck = self:CreateCheckbox(swingBox, T("Enable"),
        function() return Config:Get("swingBarEnabled") ~= false end,
        function(checked) Config:Set("swingBarEnabled", checked); ApplySwingTimer() end,
        T("Show melee, dual-wield, and ranged auto-attack timers."))
    swingEnabledCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft, swingBox.contentTop)

    local combatOnlyCheck = self:CreateCheckbox(swingBox, T("Only during combat"),
        function() return Config:Get("swingBarCombatOnly") ~= false end,
        function(checked) Config:Set("swingBarCombatOnly", checked); ApplySwingTimer() end,
        T("Fade the swing timer out when the character leaves combat."))
    combatOnlyCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 130, swingBox.contentTop)

    local sparkCheck = self:CreateCheckbox(swingBox, T("Spark"),
        function() return Config:Get("swingBarShowSpark") ~= false end,
        function(checked) Config:Set("swingBarShowSpark", checked); ApplySwingTimer() end,
        T("Show the moving spark at the current swing position."))
    sparkCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 345, swingBox.contentTop)

    local linkedNote = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    linkedNote:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 455, swingBox.contentTop - 4)
    linkedNote:SetText(T("Main/off-hand layout is linked"))
    linkedNote:SetTextColor(unpack(self.UI_COLORS.muted))

    local swingWidthLabel = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    swingWidthLabel:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft, swingBox.contentTop - 37)
    swingWidthLabel:SetHeight(20)
    swingWidthLabel:SetText(T("Width") .. ":")
    local swingWidthBox = self:CreateEditBox(swingBox, 42,
        function() return tostring(Config:Get("swingBarWidth") or 400) end,
        function(value)
            local num = tonumber(value) or 400
            if num < 120 then num = 120 end
            if num > 2000 then num = 2000 end
            Config:Set("swingBarWidth", num); ApplySwingTimer()
        end,
        T("Swing Timer Width"), T("Total width in pixels. Dual-wield divides this width between both hands. Range: 120-2000."))
    swingWidthBox:SetPoint("LEFT", swingWidthLabel, "RIGHT", 5, 0)

    local swingHeightLabel = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    swingHeightLabel:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 135, swingBox.contentTop - 37)
    swingHeightLabel:SetHeight(20)
    swingHeightLabel:SetText(T("Height") .. ":")
    local swingHeightBox = self:CreateEditBox(swingBox, 35,
        function() return tostring(Config:Get("swingBarHeight") or 4) end,
        function(value)
            local num = tonumber(value) or 4
            if num < 3 then num = 3 end
            if num > 40 then num = 40 end
            Config:Set("swingBarHeight", num); ApplySwingTimer()
        end,
        T("Swing Timer Height"), T("Height of each swing strip in pixels. Range: 3-40."))
    swingHeightBox:SetPoint("LEFT", swingHeightLabel, "RIGHT", 5, 0)

    local swingGapLabel = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    swingGapLabel:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 265, swingBox.contentTop - 37)
    swingGapLabel:SetHeight(20)
    swingGapLabel:SetText(T("Bar gap") .. ":")
    local swingGapBox = self:CreateEditBox(swingBox, 35,
        function() return tostring(Config:Get("swingBarGap") or 8) end,
        function(value)
            local num = tonumber(value) or 8
            if num < 0 then num = 0 end
            if num > 40 then num = 40 end
            Config:Set("swingBarGap", num); ApplySwingTimer()
        end,
        T("Swing Bar Gap"), T("Space between linked dual-wield bars. Range: 0-40. Ranged segments use a fixed 3-pixel gap."))
    swingGapBox:SetPoint("LEFT", swingGapLabel, "RIGHT", 5, 0)

    local fadeLabel = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fadeLabel:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 390, swingBox.contentTop - 37)
    fadeLabel:SetHeight(20)
    fadeLabel:SetText(T("Fade") .. ":")
    local fadeBox = self:CreateEditBox(swingBox, 35,
        function() return tostring(Config:Get("swingBarFadeDuration") or 0.25) end,
        function(value)
            local num = tonumber(value) or 0.25
            if num < 0 then num = 0 end
            if num > 3 then num = 3 end
            Config:Set("swingBarFadeDuration", num); ApplySwingTimer()
        end,
        T("Swing Timer Fade"), T("Fade-in and fade-out duration in seconds. Range: 0-3."), 0.1)
    fadeBox:SetPoint("LEFT", fadeLabel, "RIGHT", 5, 0)

    local swingColorLabel = swingBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    swingColorLabel:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 510, swingBox.contentTop - 37)
    swingColorLabel:SetHeight(20)
    swingColorLabel:SetText(T("Color") .. ":")
    local swingColorBtn = CreateFrame("Button", self:GetNextElementName("ColorBtn"), swingBox)
    swingColorBtn:SetWidth(40)
    swingColorBtn:SetHeight(20)
    swingColorBtn:SetPoint("LEFT", swingColorLabel, "RIGHT", 5, 0)
    swingColorBtn:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    swingColorBtn:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    swingColorBtn.label = T("Swing Timer Color")
    swingColorBtn.tooltipText = T("Choose the fill color used by every swing timer segment. Interrupted draws flash red and released shots flash white.")
    local swingColorPreview = swingColorBtn:CreateTexture(nil, "BACKGROUND")
    swingColorPreview:SetAllPoints()
    local function UpdateSwingColorPreview()
        swingColorPreview:SetTexture(Config:Get("swingBarColorR") or 1, Config:Get("swingBarColorG") or 0.82, Config:Get("swingBarColorB") or 0.18)
    end
    UpdateSwingColorPreview()
    swingColorBtn:SetScript("OnClick", function()
        local oldR = Config:Get("swingBarColorR") or 1
        local oldG = Config:Get("swingBarColorG") or 0.82
        local oldB = Config:Get("swingBarColorB") or 0.18
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(2000)
        if ColorPickerOkayButton then
            ColorPickerOkayButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerOkayButton:SetFrameLevel(2001)
        end
        if ColorPickerCancelButton then
            ColorPickerCancelButton:SetFrameStrata("FULLSCREEN_DIALOG")
            ColorPickerCancelButton:SetFrameLevel(2001)
        end
        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            Config:Set("swingBarColorR", r); Config:Set("swingBarColorG", g); Config:Set("swingBarColorB", b)
            UpdateSwingColorPreview(); ApplySwingTimer()
        end
        ColorPickerFrame.cancelFunc = function()
            Config:Set("swingBarColorR", oldR); Config:Set("swingBarColorG", oldG); Config:Set("swingBarColorB", oldB)
            UpdateSwingColorPreview(); ApplySwingTimer()
        end
        ColorPickerFrame:SetColorRGB(oldR, oldG, oldB)
        ColorPickerFrame.hasOpacity = false
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            ColorPickerFrame:Show()
        end)
        delayFrame:Show()
    end)

    local swingXBox, swingYBox = self:AddOffsetRow(swingBox, swingWidthLabel, "swingBarOffsetX", "swingBarOffsetY", ApplySwingTimer, nil, swingBox.contentTop - 74)

    local mainLabelCheck = self:CreateCheckbox(swingBox, T("Main weapon name"),
        function() return Config:Get("swingBarShowMainLabel") ~= false end,
        function(checked) Config:Set("swingBarShowMainLabel", checked); ApplySwingTimer() end,
        T("Show the equipped main-hand weapon name."))
    mainLabelCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft, swingBox.contentTop - 104)

    local offLabelCheck = self:CreateCheckbox(swingBox, T("Off weapon name"),
        function() return Config:Get("swingBarShowOffLabel") ~= false end,
        function(checked) Config:Set("swingBarShowOffLabel", checked); ApplySwingTimer() end,
        T("Show the equipped off-hand weapon name."))
    offLabelCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 170, swingBox.contentTop - 104)

    local rangedLabelCheck = self:CreateCheckbox(swingBox, T("Ranged weapon name"),
        function() return Config:Get("swingBarShowRangedLabel") ~= false end,
        function(checked) Config:Set("swingBarShowRangedLabel", checked); ApplySwingTimer() end,
        T("Show the equipped bow, gun, wand, or thrown weapon name."))
    rangedLabelCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 340, swingBox.contentTop - 104)

    local timerLabelCheck = self:CreateCheckbox(swingBox, T("Timer label"),
        function() return Config:Get("swingBarShowTimer") ~= false end,
        function(checked) Config:Set("swingBarShowTimer", checked); ApplySwingTimer() end,
        T("Show elapsed and total swing time."))
    timerLabelCheck:SetPoint("TOPLEFT", swingBox, "TOPLEFT", swingBox.contentLeft + 530, swingBox.contentTop - 104)

    self:AddSectionReset(swingBox, function()
        local keys = { "swingBarEnabled", "swingBarWidth", "swingBarHeight", "swingBarGap",
            "swingBarOffsetX", "swingBarOffsetY", "swingBarShowMainLabel", "swingBarShowOffLabel",
            "swingBarShowRangedLabel", "swingBarShowTimer", "swingBarShowSpark", "swingBarCombatOnly",
            "swingBarFadeDuration", "swingBarColorR", "swingBarColorG", "swingBarColorB" }
        local i
        for i = 1, table.getn(keys) do Config:Set(keys[i], Config.DEFAULTS[keys[i]]) end
        swingEnabledCheck:SetChecked(Config.DEFAULTS.swingBarEnabled and 1 or 0)
        combatOnlyCheck:SetChecked(Config.DEFAULTS.swingBarCombatOnly and 1 or 0)
        sparkCheck:SetChecked(Config.DEFAULTS.swingBarShowSpark and 1 or 0)
        mainLabelCheck:SetChecked(Config.DEFAULTS.swingBarShowMainLabel and 1 or 0)
        offLabelCheck:SetChecked(Config.DEFAULTS.swingBarShowOffLabel and 1 or 0)
        rangedLabelCheck:SetChecked(Config.DEFAULTS.swingBarShowRangedLabel and 1 or 0)
        timerLabelCheck:SetChecked(Config.DEFAULTS.swingBarShowTimer and 1 or 0)
        swingWidthBox:SetText(tostring(Config.DEFAULTS.swingBarWidth))
        swingHeightBox:SetText(tostring(Config.DEFAULTS.swingBarHeight))
        swingGapBox:SetText(tostring(Config.DEFAULTS.swingBarGap))
        fadeBox:SetText(tostring(Config.DEFAULTS.swingBarFadeDuration))
        swingXBox:SetText(tostring(Config.DEFAULTS.swingBarOffsetX))
        swingYBox:SetText(tostring(Config.DEFAULTS.swingBarOffsetY))
        UpdateSwingColorPreview(); ApplySwingTimer()
    end)

    local lootBox = self:CreateSectionBox(hudSection, T("Loot"))
    lootBox:ClearAllPoints()
    lootBox:SetPoint("TOPLEFT", swingBox, "BOTTOMLEFT", 0, -6)
    lootBox:SetPoint("RIGHT", hudSection, "RIGHT", -5, 0)
    lootBox:SetHeight(64)
    lootBox.heightCalculated = true

    local function ApplyLoot()
        if ConsoleUI.loot and ConsoleUI.loot.ApplyEnabled then
            ConsoleUI.loot:ApplyEnabled()
        end
    end

    local lootFrameCheck = self:CreateCheckbox(lootBox, T("Loot frame"),
        function() return Config:Get("lootFrameEnabled") ~= false end,
        function(checked)
            Config:Set("lootFrameEnabled", checked)
            ApplyLoot()
        end,
        T("Custom loot window. Uncheck to use Blizzard loot."))
    lootFrameCheck:SetPoint("TOPLEFT", lootBox, "TOPLEFT", lootBox.contentLeft, lootBox.contentTop)

    local lootRollCheck = self:CreateCheckbox(lootBox, T("Group rolls"),
        function() return Config:Get("lootRollEnabled") ~= false end,
        function(checked)
            Config:Set("lootRollEnabled", checked)
            ApplyLoot()
        end,
        T("Custom group roll window. Uncheck to use Blizzard rolls."))
    lootRollCheck:SetPoint("TOPLEFT", lootBox, "TOPLEFT", lootBox.contentLeft + 240, lootBox.contentTop)

    self:AddSectionReset(lootBox, function()
        Config:Set("lootFrameEnabled", Config.DEFAULTS.lootFrameEnabled)
        Config:Set("lootRollEnabled", Config.DEFAULTS.lootRollEnabled)
        lootFrameCheck:SetChecked(Config.DEFAULTS.lootFrameEnabled and 1 or 0)
        lootRollCheck:SetChecked(Config.DEFAULTS.lootRollEnabled and 1 or 0)
        ApplyLoot()
    end)

    local hintBox = self:CreateSectionBox(hudSection, T("Hint bar"))
    hintBox:ClearAllPoints()
    hintBox:SetPoint("TOPLEFT", lootBox, "BOTTOMLEFT", 0, -6)
    hintBox:SetPoint("RIGHT", hudSection, "RIGHT", -5, 0)
    hintBox:SetHeight(138)
    hintBox.heightCalculated = true

    local function ApplyHintBar()
        if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
            ConsoleUI.cursor.hintbar:Refresh()
        end
    end

    local hintCheck = self:CreateCheckbox(hintBox, T("Enable"),
        function() return Config:Get("hintBarEnabled") ~= false end,
        function(checked)
            Config:Set("hintBarEnabled", checked)
            ApplyHintBar()
        end,
        T("Show A/B/X/Y prompts on screen while the cursor is active."))
    hintCheck:SetPoint("TOPLEFT", hintBox, "TOPLEFT", hintBox.contentLeft, hintBox.contentTop)

    local tooltipHintsCheck = self:CreateCheckbox(hintBox, T("Tooltip action hints"),
        function() return Config:Get("tooltipActionHints") ~= false end,
        function(checked)
            Config:Set("tooltipActionHints", checked)
            if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ApplyPromptVisibility then
                ConsoleUI.cursor.tooltip:ApplyPromptVisibility()
            end
            ApplyHintBar()
        end,
        T("Show controller glyphs and action prompts inside tooltips. Disable to use only the Hint Bar."))
    tooltipHintsCheck:SetPoint("TOPLEFT", hintCheck, "BOTTOMLEFT", 0, -6)

    local posLabel = hintBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    posLabel:SetPoint("TOPLEFT", hintBox, "TOPLEFT", hintBox.contentLeft + 180, hintBox.contentTop)
    posLabel:SetText(T("Position") .. ":")
    posLabel:SetTextColor(unpack(self.UI_COLORS.muted))

    local posDrop = CreateFrame("Frame", "ConsoleUIConfigHintBarPosDropdown", hintBox, "UIDropDownMenuTemplate")
    posDrop:SetPoint("LEFT", posLabel, "RIGHT", -16, -2)

    local function PosLabel(value)
        if value == "bottom" then
            return T("Bottom")
        end
        return T("Top")
    end

    local function InitHintPos()
        local selected = UIDropDownMenu_GetSelectedValue(posDrop) or (Config:Get("hintBarPosition") or "top")
        local info = {}
        info.text = T("Bottom")
        info.value = "bottom"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(posDrop, "bottom")
            UIDropDownMenu_SetText(T("Bottom"), posDrop)
            Config:Set("hintBarPosition", "bottom")
            ApplyHintBar()
        end
        if info.value == selected then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
        info = {}
        info.text = T("Top")
        info.value = "top"
        info.func = function()
            UIDropDownMenu_SetSelectedValue(posDrop, "top")
            UIDropDownMenu_SetText(T("Top"), posDrop)
            Config:Set("hintBarPosition", "top")
            ApplyHintBar()
        end
        if info.value == selected then info.checked = 1 end
        UIDropDownMenu_AddButton(info)
    end
    UIDropDownMenu_Initialize(posDrop, InitHintPos)
    UIDropDownMenu_SetWidth(100, posDrop)
    local currentPos = Config:Get("hintBarPosition") or "top"
    UIDropDownMenu_SetSelectedValue(posDrop, currentPos)
    UIDropDownMenu_SetText(PosLabel(currentPos), posDrop)

    local hintXBox, hintYBox = self:AddOffsetRow(hintBox, tooltipHintsCheck, "hintBarOffsetX", "hintBarOffsetY", ApplyHintBar)

    local hintScaleLabel = hintBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hintScaleLabel:SetPoint("LEFT", hintYBox, "RIGHT", 24, 0)
    hintScaleLabel:SetText(T("Scale") .. ":")
    local hintScaleBox = self:CreateEditBox(hintBox, 42,
        function() return string.format("%.1f", Config:Get("hintBarScale") or 1.0) end,
        function(value)
            local num = tonumber(value) or 1.0
            if num < 0.5 then num = 0.5 end
            if num > 2.0 then num = 2.0 end
            Config:Set("hintBarScale", num)
            ApplyHintBar()
        end,
        T("Hint Bar Scale"),
        T("Scale of the persistent hint bar. Range: 0.5-2.0."),
        self.NUDGE_SCALE)
    hintScaleBox:SetPoint("LEFT", hintScaleLabel, "RIGHT", 5, 0)
    hintScaleBox:SetScript("OnTextChanged", function()
        local num = tonumber(this:GetText())
        if num and num >= 0.5 and num <= 2.0 then
            Config:Set("hintBarScale", num)
            ApplyHintBar()
        end
    end)
    self.scaleEditBoxes.hint = hintScaleBox

    self:AddSectionReset(hintBox, function()
        Config:Set("hintBarEnabled", Config.DEFAULTS.hintBarEnabled)
        Config:Set("tooltipActionHints", Config.DEFAULTS.tooltipActionHints)
        Config:Set("hintBarPosition", Config.DEFAULTS.hintBarPosition)
        Config:Set("hintBarOffsetX", Config.DEFAULTS.hintBarOffsetX)
        Config:Set("hintBarOffsetY", Config.DEFAULTS.hintBarOffsetY)
        Config:Set("hintBarScale", Config.DEFAULTS.hintBarScale)
        hintCheck:SetChecked(Config.DEFAULTS.hintBarEnabled and 1 or 0)
        tooltipHintsCheck:SetChecked(Config.DEFAULTS.tooltipActionHints and 1 or 0)
        UIDropDownMenu_SetSelectedValue(posDrop, Config.DEFAULTS.hintBarPosition)
        UIDropDownMenu_SetText(PosLabel(Config.DEFAULTS.hintBarPosition), posDrop)
        hintXBox:SetText(tostring(Config.DEFAULTS.hintBarOffsetX))
        hintYBox:SetText(tostring(Config.DEFAULTS.hintBarOffsetY))
        hintScaleBox:SetText(string.format("%.1f", Config.DEFAULTS.hintBarScale))
        if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ApplyPromptVisibility then
            ConsoleUI.cursor.tooltip:ApplyPromptVisibility()
        end
        ApplyHintBar()
    end)
    
    self.contentSections["bars"] = section
    self.contentSections["hud"] = hudSection
end



function Config:CreateProfilesSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    local currentBox = self:CreateSectionBox(section, T("This Character"))
    currentBox:SetPoint("TOP", section, "TOP", 0, -6)
    currentBox:SetHeight(104)
    currentBox.heightCalculated = true

    local currentName = currentBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentName:SetPoint("TOPLEFT", currentBox, "TOPLEFT", currentBox.contentLeft, currentBox.contentTop)
    currentName:SetTextColor(unpack(self.UI_COLORS.text))

    local currentHelp = currentBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentHelp:SetPoint("TOPLEFT", currentName, "BOTTOMLEFT", 0, -8)
    currentHelp:SetPoint("RIGHT", currentBox, "RIGHT", -18, 0)
    currentHelp:SetJustifyH("LEFT")
    currentHelp:SetTextColor(unpack(self.UI_COLORS.muted))
    currentHelp:SetText(T("Every character now owns an automatic account-visible profile. Settings, scales, positions, bindings, rings, touch assignments, keyboard layout, and action bars are saved together."))

    local copyBox = self:CreateSectionBox(section, T("Copy From"))
    copyBox:SetPoint("TOP", currentBox, "BOTTOM", 0, -8)
    copyBox:SetHeight(152)
    copyBox.heightCalculated = true

    local sourceLabel = copyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetPoint("TOPLEFT", copyBox, "TOPLEFT", copyBox.contentLeft, copyBox.contentTop)
    sourceLabel:SetText(T("Character or legacy profile") .. ":")

    local profileDropdown = CreateFrame("Frame", "ConsoleUIConfigProfileDropdown", copyBox, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", -16, -3)

    local copyButton = self:MakePanelButton(copyBox, "ConsoleUIConfigCopyProfile", 116, T("Copy Profile"))
    copyButton:SetPoint("LEFT", profileDropdown, "RIGHT", 2, 2)

    local copyHelp = copyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    copyHelp:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", 16, -8)
    copyHelp:SetPoint("RIGHT", copyBox, "RIGHT", -18, 0)
    copyHelp:SetJustifyH("LEFT")
    copyHelp:SetTextColor(unpack(self.UI_COLORS.muted))
    copyHelp:SetText(T("Copying replaces this character's ConsoleUI setup after making a backup. Action bars are restored outside combat; missing spells, items, or macros are reported and their current slots are kept."))

    local safetyBox = self:CreateSectionBox(section, T("Migration Safety"))
    safetyBox:SetPoint("TOP", copyBox, "BOTTOM", 0, -8)
    safetyBox:SetHeight(88)
    safetyBox.heightCalculated = true

    local safetyText = safetyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    safetyText:SetPoint("TOPLEFT", safetyBox, "TOPLEFT", safetyBox.contentLeft, safetyBox.contentTop)
    safetyText:SetPoint("RIGHT", safetyBox, "RIGHT", -18, 0)
    safetyText:SetJustifyH("LEFT")
    safetyText:SetTextColor(unpack(self.UI_COLORS.muted))
    safetyText:SetText(T("Existing RC6 data is preserved in ConsoleUIDB and imported once. Legacy named profiles remain available as copy sources; migration never deletes the old tables."))

    local function RefreshProfileDropdown()
        local profiles = ConsoleUI.profiles
        local sources = profiles and profiles.ListCopySources and profiles:ListCopySources() or {}
        local chosen = nil
        local i
        for i = 1, table.getn(sources) do
            if sources[i].key == Config.selectedCopyProfileKey then chosen = sources[i] end
        end
        if not chosen then
            chosen = sources[1]
            Config.selectedCopyProfileKey = chosen and chosen.key or nil
        end

        UIDropDownMenu_Initialize(profileDropdown, function()
            local index
            for index = 1, table.getn(sources) do
                local source = sources[index]
                local sourceKey, sourceName = source.key, source.label
                local info = {}
                info.text = sourceName
                info.value = sourceKey
                info.checked = sourceKey == Config.selectedCopyProfileKey and 1 or nil
                info.func = function()
                    Config.selectedCopyProfileKey = sourceKey
                    UIDropDownMenu_SetSelectedValue(profileDropdown, sourceKey)
                    UIDropDownMenu_SetText(sourceName, profileDropdown)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetWidth(270, profileDropdown)
        if chosen then
            UIDropDownMenu_SetSelectedValue(profileDropdown, chosen.key)
            UIDropDownMenu_SetText(chosen.label, profileDropdown)
            copyButton:Enable()
            copyButton:SetAlpha(1)
        else
            UIDropDownMenu_SetSelectedValue(profileDropdown, nil)
            UIDropDownMenu_SetText(T("No other profiles yet"), profileDropdown)
            copyButton:Disable()
            copyButton:SetAlpha(0.45)
        end
        currentName:SetText(profiles and profiles:GetCurrentProfileName() or T("Current character"))
    end

    copyButton:SetScript("OnClick", function()
        if not Config.selectedCopyProfileKey then return end
        local source = ConsoleUI.profiles:GetProfile(Config.selectedCopyProfileKey)
        local label = source and source.displayName or Config.selectedCopyProfileKey
        local dialog = StaticPopup_Show("ConsoleUI_COPY_CHARACTER_PROFILE", label)
        if dialog then dialog.data = Config.selectedCopyProfileKey end
    end)

    RefreshProfileDropdown()
    self.profileDropdown = profileDropdown
    self.RefreshProfileDropdown = RefreshProfileDropdown
    self.contentSections["profiles"] = section
end

function Config:CreateRingsSection()
    if ConsoleUI.BuildRingsSection then
        ConsoleUI.BuildRingsSection(self, self.frame.content)
    end
end

function Config:CreateAboutSection()
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    local content = self.frame.content
    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -4, 4)
    section:Hide()

    local hero = CreateFrame("Frame", nil, section)
    hero:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    hero:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)
    hero:SetHeight(78)
    hero:SetBackdrop(self.BACKDROP_CARD)
    hero:SetBackdropColor(unpack(self.UI_COLORS.section))
    hero:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local mark = hero:CreateTexture(nil, "ARTWORK")
    mark:SetTexture(self.MARK)
    mark:SetWidth(54)
    mark:SetHeight(54)
    mark:SetPoint("LEFT", hero, "LEFT", 12, 0)

    local name = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("LEFT", mark, "RIGHT", 12, 8)
    name:SetText("ConsoleUI")
    name:SetTextColor(unpack(self.UI_COLORS.text))

    local by = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    by:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    by:SetText("by HouseLegend")
    by:SetTextColor(unpack(self.UI_COLORS.muted))

    local version = GetAddOnMetadata and GetAddOnMetadata("ConsoleUI", "Version") or "1.0.2"
    local pill = CreateFrame("Frame", nil, hero)
    pill:SetWidth(110)
    pill:SetHeight(24)
    pill:SetPoint("RIGHT", hero, "RIGHT", -12, 0)
    pill:SetBackdrop(self.BACKDROP_CARD)
    pill:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
    pill:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
    local pillText = pill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pillText:SetPoint("CENTER", pill, "CENTER", 0, 0)
    pillText:SetText("Version " .. version)
    pillText:SetTextColor(unpack(self.UI_COLORS.gold))

    local link = CreateFrame("Button", "ConsoleUIAboutGithub", section)
    link:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -10)
    link:SetPoint("TOPRIGHT", hero, "BOTTOMRIGHT", 0, -10)
    link:SetHeight(42)
    link:SetBackdrop(self.BACKDROP_CARD)
    link:SetBackdropColor(unpack(self.UI_COLORS.inset))
    link:SetBackdropBorderColor(unpack(self.UI_COLORS.border))
    local linkLabel = link:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    linkLabel:SetPoint("LEFT", link, "LEFT", 12, 0)
    linkLabel:SetText("GitHub")
    local linkUrl = link:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    linkUrl:SetPoint("RIGHT", link, "RIGHT", -12, 0)
    linkUrl:SetText("github.com/racha/ConsoleUI")
    linkUrl:SetTextColor(unpack(self.UI_COLORS.gold))
    link:SetScript("OnClick", function()
        local url = "https://github.com/racha/ConsoleUI"
        if ChatFrameEditBox then
            ChatFrameEditBox:Show()
            ChatFrameEditBox:SetText(url)
            ChatFrameEditBox:HighlightText()
            ChatFrameEditBox:SetFocus()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd12eConsoleUI|r " .. url)
    end)

    local showOnboard = self:MakePanelButton(section, "ConsoleUIAboutOnboard", 140, T("Show Welcome"), "primary")
    showOnboard:SetPoint("TOPLEFT", link, "BOTTOMLEFT", 0, -10)
    showOnboard:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        Config:Hide()
        if ConsoleUI.onboarding and ConsoleUI.onboarding.Show then
            ConsoleUI.onboarding:Show()
        end
    end)
    local showChanges = self:MakePanelButton(section, "ConsoleUIAboutChangelog", 140, T("Show Changelog"), "ghost")
    showChanges:SetPoint("LEFT", showOnboard, "RIGHT", 8, 0)
    showChanges:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        Config:Hide()
        if ConsoleUI.changelog and ConsoleUI.changelog.Show then
            ConsoleUI.changelog:Show(true)
        end
    end)

    local credits = self:CreateSectionBox(section, "Credits")
    credits:ClearAllPoints()
    credits:SetPoint("TOPLEFT", showOnboard, "BOTTOMLEFT", 0, -10)
    credits:SetPoint("TOPRIGHT", link, "BOTTOMRIGHT", 0, -10)
    credits:SetHeight(278)
    credits.heightCalculated = true

    local rows = {
        { "World of Warcraft", "Blizzard Entertainment", "www.blizzard.com", "Website" },
        { "ConsoleExperience Classic", "Pedro · pepordev", "github.com/pepordev/ConsoleExperienceClassic", "GitHub" },
        { "ConsolePortLK", "leoaviana", "github.com/leoaviana/ConsolePortLK", "GitHub" },
        { "ConsolePort", "Sebastian Lindfors · MunkDev", "github.com/seblindfors/ConsolePort", "GitHub" },
        { "Cursor", "Development assistance", "cursor.com", "Website" },
    }
    local i
    for i = 1, table.getn(rows) do
        local info = rows[i]
        local row = CreateFrame("Button", "ConsoleUIAboutCredit" .. i, credits)
        row:SetHeight(48)
        row:SetPoint("TOPLEFT", credits, "TOPLEFT", 8, credits.contentTop - ((i - 1) * 48))
        row:SetPoint("RIGHT", credits, "RIGHT", -8, 0)
        if i < table.getn(rows) then
            local rule = row:CreateTexture(nil, "ARTWORK")
            rule:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            rule:SetHeight(1)
            rule:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
            rule:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
            rule:SetVertexColor(1, 1, 1, 0.08)
        end
        local title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("LEFT", row, "LEFT", 4, 6)
        title:SetText(info[1])
        title:SetTextColor(unpack(self.UI_COLORS.text))
        local who = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        who:SetPoint("LEFT", row, "LEFT", 4, -8)
        who:SetText(info[2])
        who:SetTextColor(unpack(self.UI_COLORS.muted))
        local href = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        href:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        href:SetText(info[4])
        href:SetTextColor(unpack(self.UI_COLORS.gold))
        local url = "https://" .. info[3]
        row:SetScript("OnClick", function()
            if ChatFrameEditBox then
                ChatFrameEditBox:Show()
                ChatFrameEditBox:SetText(url)
                ChatFrameEditBox:HighlightText()
                ChatFrameEditBox:SetFocus()
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd12eConsoleUI|r " .. url)
        end)
    end

    local legal = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    legal:SetPoint("TOPLEFT", credits, "BOTTOMLEFT", 4, -10)
    legal:SetPoint("TOPRIGHT", credits, "BOTTOMRIGHT", -4, -10)
    legal:SetJustifyH("LEFT")
    legal:SetText("World of Warcraft is a trademark of Blizzard Entertainment. This project is for educational purposes only. It is not affiliated with Blizzard or any private server.")
    legal:SetTextColor(unpack(self.UI_COLORS.muted))

    self.contentSections["about"] = section
end

function Config:CreateDebugSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    local selectBtn = self:MakePanelButton(section, "ConsoleUIConfigDebugSelectAll", 100, T("Select All"))
    selectBtn:SetPoint("TOPLEFT", section, "TOPLEFT", 4, -4)
    selectBtn:SetScript("OnClick", function()
        if Config.debugEditBox then
            Config.debugEditBox:SetFocus()
            Config.debugEditBox:HighlightText()
        end
    end)

    local clearBtn = self:MakePanelButton(section, "ConsoleUIConfigDebugClear", 80, T("Clear"))
    clearBtn:SetPoint("LEFT", selectBtn, "RIGHT", 8, 0)
    clearBtn:SetScript("OnClick", function()
        ConsoleUI_ClearDebugLog()
        Config:RefreshDebugLog()
    end)

    local snapBtn = self:MakePanelButton(section, "ConsoleUIConfigDebugSnapshot", 110, T("Snapshot"))
    snapBtn:SetPoint("LEFT", clearBtn, "RIGHT", 8, 0)
    snapBtn:SetScript("OnClick", function()
        if ConsoleUI.ReportDiagnostics then
            ConsoleUI:ReportDiagnostics()
        end
        Config:RefreshDebugLog()
        if Config.debugEditBox then
            Config.debugEditBox:SetFocus()
            Config.debugEditBox:HighlightText()
        end
    end)

    local testBtn = self:MakePanelButton(section, "ConsoleUIConfigDebugTest", 80, T("Test"))
    testBtn:SetPoint("LEFT", snapBtn, "RIGHT", 8, 0)
    testBtn:SetScript("OnClick", function()
        if ConsoleUI.RunAudit then
            ConsoleUI:RunAudit()
        end
    end)

    local box = CreateFrame("Frame", "ConsoleUIConfigDebugLogBox", section)
    box:SetPoint("TOPLEFT", selectBtn, "BOTTOMLEFT", 0, -10)
    box:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -8, 8)
    box:SetBackdrop(self.BACKDROP_CARD)
    box:SetBackdropColor(unpack(self.UI_COLORS.inset))
    box:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local scroll = CreateFrame("ScrollFrame", "ConsoleUIConfigDebugLogScroll", box, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", box, "TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -14, 8)

    local edit = CreateFrame("EditBox", "ConsoleUIConfigDebugLogEdit", scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetMaxLetters(40000)
    edit:SetWidth(480)
    edit:SetHeight(400)
    edit:SetTextInsets(4, 4, 4, 4)
    edit:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    scroll:SetScrollChild(edit)
    self:HookScrollWheel(scroll, 30)

    self.debugEditBox = edit
    self.debugScroll = scroll
    self.debugLogCount = -1

    section:SetScript("OnShow", function()
        local width = scroll:GetWidth()
        if width and width > 50 then
            edit:SetWidth(width)
        end
        Config:RefreshDebugLog()
    end)
    section:SetScript("OnUpdate", function()
        if not this:IsVisible() then return end
        this.elapsed = (this.elapsed or 0) + arg1
        if this.elapsed < 0.4 then return end
        this.elapsed = 0
        local count = ConsoleUI.debugLog and table.getn(ConsoleUI.debugLog) or 0
        if count ~= Config.debugLogCount then
            Config:RefreshDebugLog()
        end
    end)

    self.contentSections["debug"] = section
end

function Config:RefreshDebugLog()
    if not self.debugEditBox then return end
    local lines = ConsoleUI.debugLog
    local count = lines and table.getn(lines) or 0
    self.debugLogCount = count
    local text = ConsoleUI_GetDebugLog and ConsoleUI_GetDebugLog() or ""
    if text == "" then
        text = "(empty — turn Debug ON at the bottom, reproduce the issue, then come back)"
    end
    self.debugEditBox:SetText(text)
    local height = count * 14 + 24
    if height < 220 then height = 220 end
    self.debugEditBox:SetHeight(height)
    self:SyncScrollBar(self.debugScroll)
    if self.debugScroll and self.debugScroll.GetVerticalScroll then
        local bar = self:ScrollBarOf(self.debugScroll)
        local maxV = 0
        if bar and bar.GetMinMaxValues then
            local _, hi = bar:GetMinMaxValues()
            maxV = hi or 0
        end
        self.debugScroll:SetVerticalScroll(maxV)
        if bar and bar.SetValue then
            bar:SetValue(maxV)
        end
    end
end

-- ============================================================================
-- UI Helpers
-- ============================================================================

-- Counter for generating unique names
Config.elementCounter = 0

function Config:GetNextElementName(prefix)
    self.elementCounter = self.elementCounter + 1
    return "ConsoleUIConfig" .. prefix .. self.elementCounter
end

-- Create a section box with title (like UIOptionsFrame's OptionFrameBoxTemplate)
-- If height is nil, call box:CalculateHeight() after adding all children
function Config:CreateSectionBox(parent, title, height)
    local name = self:GetNextElementName("Section")
    local box = CreateFrame("Frame", name, parent)
    box:SetHeight(height or 50)  -- Initial height, will be recalculated if needed
    
    -- Use anchor points for full width (5px padding on each side)
    box:SetPoint("LEFT", parent, "LEFT", 5, 0)
    box:SetPoint("RIGHT", parent, "RIGHT", -5, 0)
    
    -- Backdrop (like OptionFrameBoxTemplate)
    box:SetBackdrop(self.BACKDROP_CARD)
    box:SetBackdropColor(unpack(self.UI_COLORS.section))
    box:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local pip = box:CreateTexture(nil, "ARTWORK")
    pip:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    pip:SetWidth(3)
    pip:SetHeight(10)
    pip:SetPoint("TOPLEFT", box, "TOPLEFT", 10, -10)
    pip:SetVertexColor(unpack(self.UI_COLORS.gold))
    box.pip = pip
    
    local titleText = box:CreateFontString(name .. "Title", "OVERLAY", "GameFontNormalSmall")
    titleText:SetPoint("LEFT", pip, "RIGHT", 7, 0)
    titleText:SetText(string.upper(title or ""))
    titleText:SetTextColor(0.78, 0.79, 0.81)
    box.title = titleText
    
    -- Content inset (area inside the box for controls)
    box.contentTop = -28
    box.contentLeft = 12
    box.contentRight = -12
    box.bottomPadding = 10
    
    -- Method to calculate height based on children (call after layout settles)
    -- Only calculates once to prevent growing on repeated calls
    box.CalculateHeight = function(self)
        -- Only calculate once
        if self.heightCalculated then return end
        
        local boxTop = self:GetTop()
        if not boxTop then return end
        
        local lowestPoint = boxTop  -- Start at top
        
        -- Scan all child frames
        local children = {self:GetChildren()}
        for _, child in ipairs(children) do
            local bottom = child:GetBottom()
            if bottom and bottom < lowestPoint then
                lowestPoint = bottom
            end
        end
        
        -- Also scan font strings (they're not frames)
        local regions = {self:GetRegions()}
        for _, region in ipairs(regions) do
            if region.GetBottom then
                local bottom = region:GetBottom()
                if bottom and bottom < lowestPoint then
                    lowestPoint = bottom
                end
            end
        end
        
        -- Calculate needed height
        local neededHeight = (boxTop - lowestPoint) + self.bottomPadding
        if neededHeight < 40 then neededHeight = 40 end  -- Minimum height
        
        self:SetHeight(neededHeight)
        self.heightCalculated = true
    end
    
    return box
end

function Config:CreateCheckbox(parent, label, getFunc, setFunc, tooltipText)
    local name = self:GetNextElementName("Check")
    local check = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    check:SetWidth(24)
    check:SetHeight(24)
    
    local text = check:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", check, "RIGHT", 5, 0)
    text:SetText(label)
    
    -- Store label for tooltip/debug
    check.label = label
    -- Store tooltip help text
    check.tooltipText = tooltipText
    -- Store getFunc so we can refresh the checkbox state
    check.getFunc = getFunc
    
    -- Set initial state
    check:SetChecked(getFunc() and 1 or 0)
    
    -- Click handler
    check:SetScript("OnClick", function()
        local checked = this:GetChecked() == 1
        setFunc(checked)
    end)
    
    return check
end

-- Refresh all checkboxes in a section
function Config:RefreshCheckboxes(section)
    if not section then return end
    
    -- Find all checkboxes in the section
    local function RefreshCheckboxRecursive(frame)
        if frame and frame.getFunc then
            -- This is a checkbox with a getFunc, refresh it
            local value = frame.getFunc()
            frame:SetChecked(value and 1 or 0)
        end
        
        -- Recursively check children
        local children = {frame:GetChildren()}
        for _, child in ipairs(children) do
            RefreshCheckboxRecursive(child)
        end
    end
    
    RefreshCheckboxRecursive(section)
end

function Config:AddSectionReset(box, onClick)
    if not box or not onClick then
        return nil
    end
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    local btn = self:MakePanelButton(box, self:GetNextElementName("Reset"), 80, T("Reset"), "ghost")
    btn:SetHeight(22)
    btn:SetPoint("TOPRIGHT", box, "TOPRIGHT", -8, -5)
    btn.tooltipText = T("Reset this section to defaults.")
    btn:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        onClick()
    end)
    return btn
end

function Config:RefreshSettingInputs()
    local boxes = self.settingEditBoxes or {}
    local i
    for i = 1, table.getn(boxes) do
        local box = boxes[i]
        -- Some fields save immediately in OnTextChanged. A read-only refresh
        -- must not execute those setters or overwrite the copied profile.
        local changed = box:GetScript("OnTextChanged")
        box:SetScript("OnTextChanged", nil)
        local value = box.cuiGetValue()
        if value ~= nil then box:SetText(value) end
        box:SetScript("OnTextChanged", changed)
    end
end

function Config:CreateEditBox(parent, width, getFunc, setFunc, label, tooltipText, step)
    local name = self:GetNextElementName("Edit")
    local editBox = CreateFrame("EditBox", name, parent)
    self.settingEditBoxes = self.settingEditBoxes or {}
    editBox.cuiGetValue = getFunc
    table.insert(self.settingEditBoxes, editBox)
    local minW = self.EDIT_BOX_WIDTH or 56
    if not width or width < minW then
        width = minW
    end
    editBox:SetWidth(width)
    editBox:SetHeight(20)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetJustifyH("CENTER")
    editBox:SetTextInsets(2, 12, 0, 0)
    local nudge = step or 1

    local function Commit()
        setFunc(editBox:GetText())
        local shown = getFunc()
        if shown ~= nil then
            editBox:SetText(shown)
        end
    end

    local function ApplyNudge(delta)
        local val = tonumber(editBox:GetText()) or 0
        val = val + delta
        if nudge < 1 then
            val = math.floor(val * 10 + 0.5) / 10
            editBox:SetText(string.format("%.1f", val))
        else
            editBox:SetText(tostring(val))
        end
        Commit()
        PlaySound("igMainMenuOptionCheckBoxOn")
    end
	
	-- initial value
    editBox:SetText(getFunc() or "0")
	
    --  Create an increase button (Up)
    local btnUp = CreateFrame("Button", name.."Up", editBox)
    btnUp:SetWidth(12)
    btnUp:SetHeight(10)
    btnUp:SetPoint("TOPRIGHT", editBox, "TOPRIGHT", -1, 0)
    
    -- Use the built-in up arrow texture in the system
    local upTex = btnUp:CreateTexture(nil, "ARTWORK")
    upTex:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
    upTex:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    upTex:SetAllPoints(btnUp)
    btnUp:SetNormalTexture(upTex)
    
    btnUp:SetScript("OnClick", function()
        ApplyNudge(nudge)
    end)

     -- Create a decrease button (Down)
    local btnDown = CreateFrame("Button", name.."Down", editBox)
    btnDown:SetWidth(12)
    btnDown:SetHeight(10)
    btnDown:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", -1, 0)
    
    -- Use the built-in downward arrow image in the system
    local downTex = btnDown:CreateTexture(nil, "ARTWORK")
    downTex:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
    downTex:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    downTex:SetAllPoints(btnDown)
    btnDown:SetNormalTexture(downTex)
    
    btnDown:SetScript("OnClick", function()
        ApplyNudge(-nudge)
    end)
    -- end
    
    -- Store label and tooltip for cursor tooltip
    editBox.label = label or T("Text Input")
    editBox.tooltipText = tooltipText
    
    -- Background
    editBox:SetBackdrop(self.BACKDROP_CARD)
    editBox:SetBackdropColor(0.063, 0.067, 0.082, 0.96)
    editBox:SetBackdropBorderColor(unpack(self.UI_COLORS.borderStrong))
    
    -- Set initial value
    editBox:SetText(getFunc())
    
    -- Focus handlers
    editBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        this:SetText(getFunc())
    end)
    
    editBox:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        Commit()
    end)
    
    editBox:SetScript("OnEditFocusLost", function()
        Commit()
    end)

    if ConsoleUIKeyboard and ConsoleUIKeyboard.HookBox then
        ConsoleUIKeyboard:HookBox(editBox)
    end
    
    return editBox
end

-- ============================================================================
-- Section Management
-- ============================================================================

function Config:ScrollBarOf(scroll)
    if not scroll or not scroll.GetName then
        return nil
    end
    local name = scroll:GetName()
    if not name then
        return nil
    end
    return getglobal(name .. "ScrollBar")
end

function Config:ScrollBarThumb(bar)
    if not bar or not bar.GetName then
        return nil
    end
    local name = bar:GetName()
    if not name then
        return nil
    end
    return getglobal(name .. "ThumbTexture")
end

function Config:SectionFillsPage()
    return self.currentSection == "bindings"
end

-- Stock UIPanel scroll is the silver 1.12 widget. Hide arrows and
-- the knob, keep a 3px White.tga rail.
function Config:SkinScrollBar(scroll)
    local bar = self:ScrollBarOf(scroll)
    if not bar then
        return
    end
    local thumb = self:ScrollBarThumb(bar)
    if bar.GetChildren then
        local kids = { bar:GetChildren() }
        local i
        for i = 1, table.getn(kids) do
            local kid = kids[i]
            if kid and kid.IsObjectType and kid:IsObjectType("Button") then
                if not kid.consoleUIHidden then
                    kid.consoleUIHidden = true
                    kid:SetScript("OnShow", function()
                        this:Hide()
                    end)
                end
                kid:Hide()
                kid:EnableMouse(nil)
            end
        end
    end
    if bar.GetRegions then
        local regions = { bar:GetRegions() }
        local i
        for i = 1, table.getn(regions) do
            local r = regions[i]
            if r and r ~= thumb and r.GetObjectType and r:GetObjectType() == "Texture" then
                r:SetTexture(nil)
                r:Hide()
            end
        end
    end
    bar:SetWidth(6)
    bar:ClearAllPoints()
    bar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 8, 0)
    bar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 8, 0)
    if not bar.cuiTrack then
        local track = bar:CreateTexture((bar:GetName() or "ConsoleUIScroll") .. "CuiTrack", "BACKGROUND")
        track:SetTexture("Interface\\AddOns\\ConsoleUI\\textures\\hud\\White.tga")
        track:SetVertexColor(1, 1, 1)
        track:SetAlpha(0.10)
        track:SetWidth(3)
        track:ClearAllPoints()
        track:SetPoint("TOP", bar, "TOP", 0, 0)
        track:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
        bar.cuiTrack = track
    end
    if thumb then
        thumb:SetTexture("Interface\\AddOns\\ConsoleUI\\textures\\hud\\White.tga")
        thumb:SetVertexColor(1, 1, 1)
        thumb:SetAlpha(0.28)
        thumb:SetWidth(3)
        if thumb.SetTexCoord then
            thumb:SetTexCoord(0, 1, 0, 1)
        end
    end
end

-- 1.12 GetVerticalScrollRange is often 0 until UpdateScrollChildRect.
-- OnScrollRangeChanged then SetMinMaxValues(0,0) and the knob dies.
-- D-pad still scrolls the child. We keep the slider range ourselves.
function Config:EnsureScrollBarHook(scroll)
    if not scroll or scroll.consoleUIBarHooked then
        return
    end
    scroll.consoleUIBarHooked = true
    scroll.scrollBarHideable = nil
    scroll:SetScript("OnScrollRangeChanged", function()
        if this.consoleUIScrollBusy then
            return
        end
        this.consoleUIScrollBusy = true
        Config:SyncScrollBar(this)
        this.consoleUIScrollBusy = nil
    end)
end

function Config:HookScrollWheel(scroll, step)
    if not scroll then
        return
    end
    self:EnsureScrollBarHook(scroll)
    step = step or 40
    scroll:EnableMouseWheel(1)
    scroll:SetScript("OnMouseWheel", function()
        local bar = Config:ScrollBarOf(this)
        local cur = this:GetVerticalScroll() or 0
        local minV, maxV = 0, 0
        if bar and bar.GetMinMaxValues then
            minV, maxV = bar:GetMinMaxValues()
        end
        if (maxV or 0) <= 0 then
            maxV = this:GetVerticalScrollRange() or 0
        end
        local next = cur - (arg1 * step)
        if next < (minV or 0) then
            next = minV or 0
        end
        if next > (maxV or 0) then
            next = maxV or 0
        end
        this:SetVerticalScroll(next)
        if bar and bar.SetValue then
            bar:SetValue(next)
        end
    end)
end

function Config:SyncScrollBar(scroll)
    if not scroll then
        return
    end
    self:EnsureScrollBarHook(scroll)
    if scroll.UpdateScrollChildRect and not scroll.consoleUIScrollBusy then
        scroll:UpdateScrollChildRect()
    end
    local bar = self:ScrollBarOf(scroll)
    local child = scroll.GetScrollChild and scroll:GetScrollChild()
    local viewH = scroll.GetHeight and (scroll:GetHeight() or 0) or 0
    local need = 0
    if child and child.GetHeight then
        need = child:GetHeight() or 0
    end
    local range = need - viewH
    if range < 0 then
        range = 0
    end
    if bar and bar.SetMinMaxValues then
        bar:SetMinMaxValues(0, range)
    end
    local cur = 0
    if scroll.GetVerticalScroll then
        cur = scroll:GetVerticalScroll() or 0
    end
    if cur > range then
        cur = range
    end
    if scroll.SetVerticalScroll then
        scroll:SetVerticalScroll(cur)
    end
    if bar and bar.SetValue then
        bar:SetValue(cur)
    end
    self:SkinScrollBar(scroll)
    if bar then
        if range > 1 then
            bar:Show()
            bar:EnableMouse(1)
            local thumb = self:ScrollBarThumb(bar)
            if thumb then
                local track = viewH - 8
                local th = 24
                if need > 0 and track > 24 then
                    th = track * viewH / need
                    if th < 24 then
                        th = 24
                    end
                    if th > track then
                        th = track
                    end
                end
                if thumb.SetHeight then
                    thumb:SetHeight(th)
                end
                thumb:Show()
            end
        else
            bar:Hide()
            bar:EnableMouse(nil)
        end
    end
end

function Config:RunResetBindings()
    PlaySound("igMainMenuOptionCheckBoxOn")
    if ConsoleUIKeybindings and ConsoleUIKeybindings.ResetAllBindings then
        ConsoleUIKeybindings:ResetAllBindings()
    end
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
        ConsoleUI.actionbars:UpdateAllButtons()
    end
    if self.RefreshBindingWorkspace then
        self:RefreshBindingWorkspace()
    end
    if ConsoleUI.profiles and ConsoleUI.profiles.MarkDirty then
        ConsoleUI.profiles:MarkDirty(false)
    end
end

function Config:ConfirmResetBindings()
    StaticPopup_Show("ConsoleUI_RESET_BINDINGS")
end

function Config:FitContentScroll()
    local scroll = self.frame and self.frame.contentScroll
    local child = self.frame and self.frame.content
    local host = self.frame and self.frame.contentHost
    if not scroll or not child then
        return
    end
    local viewH = scroll:GetHeight() or 400
    if host then
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -4)
        if self:SectionFillsPage() then
            scroll:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -4, 4)
        else
            scroll:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -16, 4)
        end
    end
    viewH = scroll:GetHeight() or viewH
    if self:SectionFillsPage() then
        child:SetHeight(viewH)
        if scroll.UpdateScrollChildRect then
            scroll:UpdateScrollChildRect()
        end
        if scroll.SetVerticalScroll then
            scroll:SetVerticalScroll(0)
        end
        local bar = self:ScrollBarOf(scroll)
        if bar then
            bar:Hide()
            bar:EnableMouse(nil)
        end
        return
    end
    local need = viewH
    local section = self.currentSection and self.contentSections[self.currentSection]
    if section and section.GetTop and section:GetTop() then
        local top = section:GetTop()
        local lowest = top
        local kids = {section:GetChildren()}
        local i
        for i = 1, table.getn(kids) do
            local bottom = kids[i].GetBottom and kids[i]:GetBottom()
            if bottom and bottom < lowest then
                lowest = bottom
            end
        end
        need = (top - lowest) + 16
    end
    if need < viewH then
        need = viewH
    end
    child:SetHeight(need)
    if scroll.UpdateScrollChildRect then
        scroll:UpdateScrollChildRect()
    end
    if scroll.SetVerticalScroll then
        scroll:SetVerticalScroll(0)
    end
    self:SyncScrollBar(scroll)
end

function Config:ShowSection(sectionId)
    -- Refresh profile dropdown if showing profiles section
    if sectionId == "profiles" then
        if self.RefreshProfileDropdown then
            self:RefreshProfileDropdown()
        end
        if self.UpdateDeleteButtonState then
            self:UpdateDeleteButtonState()
        end
    end
    if sectionId == "debug" and self.RefreshDebugLog then
        self:RefreshDebugLog()
    end
    if sectionId == "rings" and self.RefreshRingsEditor then
        self:RefreshRingsEditor()
    end
    if sectionId == "interface" and self.RefreshGlyphControls then
        self:RefreshGlyphControls()
    end
    -- Hide all sections
    for id, section in pairs(self.contentSections) do
        section:Hide()
    end
    
    for id, button in pairs(self.sidebarButtons) do
        self:SetNavState(button, "idle")
    end
    
    -- Show selected section
    if self.contentSections[sectionId] then
        local section = self.contentSections[sectionId]
        section:Show()
        
        -- Refresh all checkboxes in this section to reflect current config values
        self:RefreshCheckboxes(section)
        self:RefreshSettingInputs()
        
        -- Refresh proxied dropdowns if showing keybindings section
        if sectionId == "keybindings" or sectionId == "bindings" then
            if self.RefreshProxiedDropdowns then
                self:RefreshProxiedDropdowns()
            end
        end
        
        -- Recalculate box heights after layout settles
        local calcFrame = CreateFrame("Frame")
        calcFrame.section = section
        calcFrame:SetScript("OnUpdate", function()
            this:Hide()
            local section = this.section
            -- Find all boxes in this section and recalculate their heights
            local children = {section:GetChildren()}
            for _, child in ipairs(children) do
                if child.CalculateHeight then
                    child:CalculateHeight()
                end
            end
            if Config.FitContentScroll then
                Config:FitContentScroll()
            end
        end)
        calcFrame:Show()
    end
    
    if self.sidebarButtons[sectionId] then
        self:SetNavState(self.sidebarButtons[sectionId], "active")
    end
    
    self.currentSection = sectionId
    if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
        ConsoleUI.cursor.hintbar:Refresh()
    end
    
    -- Refresh cursor navigation to detect dropdown buttons and other elements
    if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
                ConsoleUI.cursor:RefreshFrame()
            end
        end)
        delayFrame:Show()
    end
end

-- ============================================================================
-- Toggle/Show/Hide
-- ============================================================================

function Config:Toggle()
    if not self.frame then
        self:CreateMainFrame()
    end
    
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function Config:Show()
    if not self.frame then
        self:CreateMainFrame()
    end
    self.frame:Show()
    
    -- Refresh cursor navigation to include dropdown buttons
    if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function()
            delayFrame:Hide()
            if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
                ConsoleUI.cursor:RefreshFrame()
            end
        end)
        delayFrame:Show()
    end
end

function Config:Hide()
    -- Save current profile before hiding
    if ConsoleUI.profiles and ConsoleUI.profiles.SaveCurrentProfile then
        ConsoleUI.profiles:SaveCurrentProfile()
    end
    if self.frame then
        self.frame:Hide()
    end
end

-- ============================================================================
-- Game Menu Button
-- ============================================================================

function Config:LayoutGameMenuButton()
    local ours = GameMenuButtonConsoleUI
    if not ours or not GameMenuFrame then
        return
    end
    -- Do not ClearAllPoints / SetPoint any other menu button. Turtle Shop,
    -- Shagu Advanced Options, and stock Continue/Quit stay where they are.
    local children = {GameMenuFrame:GetChildren()}
    local bottom, bottomY
    local i
    for i = 1, table.getn(children) do
        local child = children[i]
        if child and child ~= ours and child.GetObjectType and child:GetObjectType() == "Button" then
            local visible = true
            if child.IsShown then
                visible = child:IsShown()
            end
            if visible and child.GetBottom then
                local y = child:GetBottom()
                if y and (not bottomY or y < bottomY) then
                    bottomY = y
                    bottom = child
                end
            end
        end
    end
    if not bottom then
        bottom = GameMenuButtonContinue or GameMenuButtonExit or GameMenuButtonQuit or GameMenuButtonShop or GameMenuButtonOptions
    end
    if not bottom then
        return
    end
    ours:ClearAllPoints()
    ours:SetPoint("TOP", bottom, "BOTTOM", 0, -1)
    if not self.gameMenuGrew then
        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 22)
        self.gameMenuGrew = true
    end
end

function Config:HookGameMenuLayout()
    if self.gameMenuLayoutHooked or not GameMenuFrame then
        return
    end
    self.gameMenuLayoutHooked = true
    local wait = CreateFrame("Frame")
    wait:Hide()
    wait:SetScript("OnUpdate", function()
        this:Hide()
        pcall(function()
            Config:LayoutGameMenuButton()
        end)
    end)
    local previous = GameMenuFrame:GetScript("OnShow")
    GameMenuFrame:SetScript("OnShow", function()
        if previous then
            previous()
        end
        wait:Show()
    end)
end

function Config:CreateGameMenuButton()
    if GameMenuButtonConsoleUI then
        self:HookGameMenuLayout()
        return
    end
    local button = CreateFrame("Button", "GameMenuButtonConsoleUI", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText("ConsoleUI")
    button:SetScript("OnClick", function()
        ConsoleUI.config:Toggle()
        HideUIPanel(GameMenuFrame)
    end)
    self:HookGameMenuLayout()
    pcall(function()
        self:LayoutGameMenuButton()
    end)
end

-- Helper function to recursively find all buttons and dropdowns in a frame
local function FindAllButtonsAndDropdowns(parent, results)
    results = results or {}
    if not parent then return results end
    
    -- Check all children
    local children = {parent:GetChildren()}
    for _, child in ipairs(children) do
        local objType = child:GetObjectType()
        local name = child:GetName() or ""
        
        -- Check if it's a Frame with UIDropDownMenuTemplate (dropdowns are Frames, not Buttons)
        if objType == "Frame" then
            -- Check if it has a button child (indicating it's a dropdown)
            local buttonName = name .. "Button"
            local button = _G[buttonName]
            if button then
                -- This is a dropdown frame
                table.insert(results, {frame = child, type = "dropdown"})
            else
                -- Regular frame, check its children
                FindAllButtonsAndDropdowns(child, results)
            end
        elseif objType == "Button" then
            -- Regular button (not a dropdown)
            table.insert(results, {frame = child, type = "button"})
        elseif objType == "CheckButton" then
            -- Checkbox
            table.insert(results, {frame = child, type = "checkbox"})
        else
            -- Other frame types, check their children
            FindAllButtonsAndDropdowns(child, results)
        end
    end
    
    return results
end

-- Function to apply pfUI styling to config frame and buttons
function Config:ApplyPfUIStyling()
    if not pfUI or not pfUI.GetEnvironment then 
        ConsoleUI_Debug("ApplyPfUIStyling: pfUI not found or GetEnvironment not available")
        return 
    end
    
    local frame = self.frame
    if not frame then 
        ConsoleUI_Debug("ApplyPfUIStyling: frame not found")
        return 
    end
    
    -- Try to get pfUI environment functions
    local env = pfUI:GetEnvironment()
    if not env then 
        ConsoleUI_Debug("ApplyPfUIStyling: Could not get pfUI environment")
        return 
    end
    
    ConsoleUI_Debug("ApplyPfUIStyling: Got pfUI environment")
    
    -- Check if functions exist in environment
    local CreateBackdrop = env.CreateBackdrop
    local CreateBackdropShadow = env.CreateBackdropShadow
    local SkinButton = env.SkinButton
    
    ConsoleUI_Debug("ApplyPfUIStyling: CreateBackdrop=" .. tostring(CreateBackdrop ~= nil) .. 
             ", CreateBackdropShadow=" .. tostring(CreateBackdropShadow ~= nil) .. 
             ", SkinButton=" .. tostring(SkinButton ~= nil))
    
    -- Keep the ConsoleUI panel look. pfUI CreateBackdrop fights the restyle.
    
    -- Apply pfUI styling to all buttons and dropdowns
    local SkinDropDown = env.SkinDropDown
    local SkinCheckbox = env.SkinCheckbox
    if SkinButton or SkinDropDown or SkinCheckbox then
        local success, err = pcall(function()
            -- Find all buttons and dropdowns in the config frame
            local allElements = FindAllButtonsAndDropdowns(frame)
            local styledCount = 0
            
            for _, element in ipairs(allElements) do
                if element.frame and not element.frame.pfUISkinned then
                    if element.type == "dropdown" and SkinDropDown then
                        -- Use SkinDropDown for dropdowns (this styles the frame, button, text, and arrow)
                        SkinDropDown(element.frame)
                        element.frame.pfUISkinned = true
                        styledCount = styledCount + 1
                    elseif element.type == "checkbox" and SkinCheckbox then
                        -- Use SkinCheckbox for checkboxes (this properly styles the checkbox texture)
                        SkinCheckbox(element.frame)
                        element.frame.pfUISkinned = true
                        styledCount = styledCount + 1
                    elseif element.type == "button" and SkinButton and not element.frame.sectionId then
                        SkinButton(element.frame)
                        element.frame.pfUISkinned = true
                        styledCount = styledCount + 1
                    end
                end
            end
            
            -- Also style specific known buttons
            if frame.closeButton and not frame.closeButton.pfUISkinned and SkinButton then
                SkinButton(frame.closeButton)
                frame.closeButton.pfUISkinned = true
                styledCount = styledCount + 1
            end
            if frame.debugButton and not frame.debugButton.pfUISkinned and SkinButton then
                SkinButton(frame.debugButton)
                frame.debugButton.pfUISkinned = true
                styledCount = styledCount + 1
            end
            
            ConsoleUI_Debug("ApplyPfUIStyling: Styled " .. styledCount .. " buttons/dropdowns")
        end)
        if success then
            ConsoleUI_Debug("ApplyPfUIStyling: Successfully applied button styling")
        else
            ConsoleUI_Debug("ApplyPfUIStyling: Failed to apply button styling: " .. tostring(err))
        end
    end
    
end

-- Function to apply pfUI styling to main menu button
function Config:ApplyPfUIStylingToMainMenuButton()
    if not pfUI or not pfUI.GetEnvironment then return end
    
    local env = pfUI:GetEnvironment()
    if not env or not env.SkinButton then return end
    
    if GameMenuButtonConsoleUI then
        pcall(function()
            env.SkinButton(GameMenuButtonConsoleUI)
            ConsoleUI_Debug("ApplyPfUIStylingToMainMenuButton: Styled main menu button")
        end)
    end
end

-- Apply pfUI styling after pfUI loads (check periodically)
local pfUICheckFrame = CreateFrame("Frame")
local pfUICheckElapsed = 0
local pfUICheckAttempts = 0
pfUICheckFrame:SetScript("OnUpdate", function()
    pfUICheckElapsed = pfUICheckElapsed + arg1
    if pfUICheckElapsed > 0.5 then
        pfUICheckElapsed = 0
        pfUICheckAttempts = pfUICheckAttempts + 1
        
        if pfUI and pfUI.GetEnvironment then
            local env = pfUI:GetEnvironment()
            if env and env.SkinButton then
                -- Apply styling to config frame
                if Config.frame and not Config.frame.pfUIStyled then
                    Config:ApplyPfUIStyling()
                    Config.frame.pfUIStyled = true
                end
                
                -- Apply styling to main menu button
                Config:ApplyPfUIStylingToMainMenuButton()
                
                -- Stop checking once both are styled
                if Config.frame and Config.frame.pfUIStyled then
                    this:SetScript("OnUpdate", nil)
                end
            end
        end
        
        -- Stop checking after 20 attempts (10 seconds)
        if pfUICheckAttempts >= 20 then
            this:SetScript("OnUpdate", nil)
        end
    end
end)

-- Create reload UI popup
StaticPopupDialogs["ConsoleUI_RELOAD_UI"] = {
    text = "Language changed. Reload UI to apply?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["ConsoleUI_RESET_BINDINGS"] = {
    text = "Reset every ConsoleUI controller and touch binding to defaults?",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        if ConsoleUI.config then ConsoleUI.config:RunResetBindings() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["ConsoleUI_COPY_CHARACTER_PROFILE"] = {
    text = "Copy all ConsoleUI settings from '%s'? Your current character profile will be backed up first.",
    button1 = "Copy",
    button2 = "Cancel",
    OnAccept = function(sourceKey)
        -- Vanilla passes dialog.data directly; global `this` can be Button1.
        -- Do not guess StaticPopup1: another popup may occupy that slot.
        if type(sourceKey) ~= "string" or not ConsoleUI.profiles then
            StaticPopup_Show("ConsoleUI_PROFILE_ERROR", "The copy source is missing. Please select a profile and try again.")
            return
        end
        local ok, why = ConsoleUI.profiles:CopyFrom(sourceKey)
        if not ok then
            StaticPopup_Show("ConsoleUI_PROFILE_ERROR", why or "Failed to copy profile")
        elseif ConsoleUI.config and ConsoleUI.config.RefreshProfileDropdown then
            ConsoleUI.config:RefreshProfileDropdown()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Helper function to trim whitespace (WoW 1.12 doesn't have string.trim)
local function trimString(s)
    if not s then return "" end
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

-- Create profile popups
StaticPopupDialogs["ConsoleUI_CREATE_PROFILE"] = {
    text = "Enter profile name:",
    button1 = "Create",
    button2 = "Cancel",
    hasEditBox = true,
    maxLetters = 20,
    OnAccept = function()
        local dialog = getglobal("StaticPopup1")
        local editBox = getglobal("StaticPopup1EditBox")
        if editBox then
            local name = editBox:GetText()
            if name and name ~= "" then
                name = trimString(name)
                if name ~= "" then
                    local success, error = ConsoleUI.profiles:CreateProfile(name, nil)
                    if success then
                        -- Switch to new profile
                        ConsoleUI.profiles:SetProfile(name)
                        -- Refresh UI
                        if ConsoleUI.config and ConsoleUI.config.RefreshProfileDropdown then
                            ConsoleUI.config:RefreshProfileDropdown()
                        end
                        if ConsoleUI.config and ConsoleUI.config.UpdateDeleteButtonState then
                            ConsoleUI.config:UpdateDeleteButtonState()
                        end
                    else
                        StaticPopup_Show("ConsoleUI_PROFILE_ERROR", error or "Failed to create profile")
                    end
                end
            end
        end
    end,
    OnShow = function()
        local editBox = getglobal("StaticPopup1EditBox")
        if editBox then
            editBox:SetText("")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["ConsoleUI_CLONE_PROFILE"] = {
    text = "Enter name for cloned profile:",
    button1 = "Clone",
    button2 = "Cancel",
    hasEditBox = true,
    maxLetters = 20,
    OnAccept = function()
        local editBox = getglobal("StaticPopup1EditBox")
        if editBox then
            local name = editBox:GetText()
            if name and name ~= "" then
                name = trimString(name)
                if name ~= "" then
                    local currentProfile = ConsoleUI.profiles:GetCurrentProfileName()
                    -- Save current profile first
                    ConsoleUI.profiles:SaveCurrentProfile()
                    -- Clone it
                    local success, error = ConsoleUI.profiles:CreateProfile(name, currentProfile)
                    if success then
                        -- Switch to the newly cloned profile
                        ConsoleUI.profiles:SetProfile(name)
                        -- Refresh UI
                        if ConsoleUI.config and ConsoleUI.config.RefreshProfileDropdown then
                            ConsoleUI.config:RefreshProfileDropdown()
                        end
                        if ConsoleUI.config and ConsoleUI.config.UpdateDeleteButtonState then
                            ConsoleUI.config:UpdateDeleteButtonState()
                        end
                        -- Refresh the profiles section to show the new profile is selected
                        if ConsoleUI.config and ConsoleUI.config.frame and ConsoleUI.config.frame:IsVisible() then
                            if ConsoleUI.config.ShowSection then
                                ConsoleUI.config:ShowSection("profiles")
                            end
                        end
                    else
                        StaticPopup_Show("ConsoleUI_PROFILE_ERROR", error or "Failed to clone profile")
                    end
                end
            end
        end
    end,
    OnShow = function()
        local editBox = getglobal("StaticPopup1EditBox")
        if editBox then
            editBox:SetText("")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["ConsoleUI_DELETE_PROFILE"] = {
    text = "Delete profile '%s'? This cannot be undone.",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function()
        local dialog = getglobal("StaticPopup1")
        local profileName = dialog and dialog.data
        if profileName then
            local success, error = ConsoleUI.profiles:DeleteProfile(profileName)
            if success then
                -- Refresh UI
                if ConsoleUI.config and ConsoleUI.config.RefreshProfileDropdown then
                    ConsoleUI.config:RefreshProfileDropdown()
                end
                if ConsoleUI.config and ConsoleUI.config.UpdateDeleteButtonState then
                    ConsoleUI.config:UpdateDeleteButtonState()
                end
            else
                StaticPopup_Show("ConsoleUI_PROFILE_ERROR", error or "Failed to delete profile")
            end
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["ConsoleUI_PROFILE_ERROR"] = {
    text = "%s",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- ============================================================================
-- Crosshair
-- ============================================================================

function Config:CreateCrosshair()
    if self.crosshairFrame then return self.crosshairFrame end
    
    local frame = CreateFrame("Frame", "ConsoleUICrosshair", UIParent)
    frame:SetWidth(32)
    frame:SetHeight(32)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")
    
    -- Create crosshair texture (simple cross)
    local size = 24
    local thickness = 2
    
    -- Horizontal line
    local hLine = frame:CreateTexture(nil, "OVERLAY")
    hLine:SetTexture(1, 1, 1, 0.8)
    hLine:SetWidth(size)
    hLine:SetHeight(thickness)
    hLine:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.hLine = hLine
    
    -- Vertical line
    local vLine = frame:CreateTexture(nil, "OVERLAY")
    vLine:SetTexture(1, 1, 1, 0.8)
    vLine:SetWidth(thickness)
    vLine:SetHeight(size)
    vLine:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.vLine = vLine
    
    -- Center dot
    local dot = frame:CreateTexture(nil, "OVERLAY")
    dot:SetTexture(1, 0.2, 0.2, 1)
    dot:SetWidth(4)
    dot:SetHeight(4)
    dot:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.dot = dot
    
    frame:Hide()
    self.crosshairFrame = frame
    
    return frame
end

function Config:UpdateCrosshair()
    if not self.crosshairFrame then
        self:CreateCrosshair()
    end
    
    local enabled = self:Get("crosshairEnabled")
    local xOffset = self:Get("crosshairX") or 0
    local yOffset = self:Get("crosshairY") or 0
    local size = self:Get("crosshairSize") or 24
    local crosshairType = self:Get("crosshairType") or "cross"
    local r = self:Get("crosshairColorR") or 1.0
    local g = self:Get("crosshairColorG") or 1.0
    local b = self:Get("crosshairColorB") or 1.0
    local a = self:Get("crosshairColorA") or 0.8
    local thickness = math.max(2, math.floor(size / 12))
    
    -- Update position
    self.crosshairFrame:ClearAllPoints()
    self.crosshairFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
    self.crosshairFrame:SetWidth(size + 8)
    self.crosshairFrame:SetHeight(size + 8)
    
    -- Update crosshair based on type
    if crosshairType == "dot" then
        -- Dot only - hide lines, show dot with configured color
        if self.crosshairFrame.hLine then
            self.crosshairFrame.hLine:Hide()
        end
        if self.crosshairFrame.vLine then
            self.crosshairFrame.vLine:Hide()
        end
        if self.crosshairFrame.dot then
            local dotSize = math.max(2, math.floor(size / 6))
            self.crosshairFrame.dot:SetWidth(dotSize)
            self.crosshairFrame.dot:SetHeight(dotSize)
            self.crosshairFrame.dot:SetTexture(r, g, b, a)
            self.crosshairFrame.dot:Show()
        end
    else
        -- Cross - show lines and dot (dot uses red tint for visibility in cross mode)
        if self.crosshairFrame.hLine then
            self.crosshairFrame.hLine:SetWidth(size)
            self.crosshairFrame.hLine:SetHeight(thickness)
            self.crosshairFrame.hLine:SetTexture(r, g, b, a)
            self.crosshairFrame.hLine:Show()
        end
        if self.crosshairFrame.vLine then
            self.crosshairFrame.vLine:SetWidth(thickness)
            self.crosshairFrame.vLine:SetHeight(size)
            self.crosshairFrame.vLine:SetTexture(r, g, b, a)
            self.crosshairFrame.vLine:Show()
        end
        if self.crosshairFrame.dot then
            local dotSize = math.max(2, math.floor(size / 6))
            self.crosshairFrame.dot:SetWidth(dotSize)
            self.crosshairFrame.dot:SetHeight(dotSize)
            -- Dot uses red tint for visibility when lines are present (original behavior)
            self.crosshairFrame.dot:SetTexture(r, g * 0.2, b * 0.2, a)
            self.crosshairFrame.dot:Show()
        end
    end
    
    if enabled then
        self.crosshairFrame:Show()
    else
        self.crosshairFrame:Hide()
    end
end

-- Initialize crosshair on load (will apply saved settings after VARIABLES_LOADED via InitializeDB)
Config:CreateCrosshair()

-- ============================================================================
-- Action Bar Layout
-- ============================================================================

-- Kept as id lists for anything still reading these tables.
Config.BUTTON_LAYOUT = {
    { id = 7,  star = "left" },
    { id = 5,  star = "left" },
    { id = 6,  star = "left" },
    { id = 8,  star = "left" },
    { id = 9,  star = "right" }, -- RB
    { id = 10, star = "right" }, -- RT
    { id = 3,  star = "right" },
    { id = 1,  star = "right" },
    { id = 2,  star = "right" },
    { id = 4,  star = "right" },
}

Config.FLAT_LAYOUT = {
    { id = 6,  star = "left",  slot = 2 },
    { id = 7,  star = "left",  slot = 3 },
    { id = 5,  star = "left",  slot = 4 },
    { id = 8,  star = "left",  slot = 5 },
    { id = 2,  star = "right", slot = 0 },
    { id = 3,  star = "right", slot = 1 },
    { id = 1,  star = "right", slot = 2 },
    { id = 4,  star = "right", slot = 3 },
    { id = 9,  star = "right", slot = 4 }, -- RB
    { id = 10, star = "right", slot = 5 }, -- RT
}

function Config:UpdateActionBarLayout()
    local scale = self:Get("barScale") or 1.0
    local buttonSize = self:Get("barButtonSize") or 82
    local padding = self:Get("barPadding") or 65
    local starPadding = self:Get("barStarPadding") or 600
    local flankGap = self:Get("barFlankGap") or 50
    local xOffset = self:Get("barXOffset") or 0
    local yOffset = self:Get("barYOffset") or 70
    local layout = self:Get("barLayout") or "controller"
    local Layout = ConsoleUI.actionbars and ConsoleUI.actionbars.Layout
    if Layout and Layout.ApplyScale then
        buttonSize, padding, starPadding, flankGap = Layout.ApplyScale(
            buttonSize, padding, starPadding, flankGap, scale)
    else
        buttonSize = buttonSize * scale
        padding = padding * scale
        flankGap = flankGap * scale
    end
    if layout == "full" and Layout and Layout.FullFit then
        local uiW = 1920
        if UIParent and UIParent.GetWidth then
            uiW = UIParent:GetWidth() or uiW
        end
        local fitted, fittedGap = Layout.FullFit(buttonSize, flankGap, uiW)
        buttonSize = fitted
        if fittedGap then
            flankGap = fittedGap
        end
    end
    local metrics = nil
    if Layout then
        metrics = Layout.Metrics(buttonSize, flankGap)
    end
    
    local starSpacing = starPadding / 2
    self.leftStarCenterX = -starSpacing + xOffset
    self.rightStarCenterX = starSpacing + xOffset
    self.starYOffset = yOffset

    local id
    local bars = ConsoleUI.actionbars
    local function place(button, btnId, col)
        if not button then
            return
        end
        local world
        if Layout then
            world = Layout.World(btnId, layout, metrics, padding, starPadding, xOffset, yOffset, col)
        else
            world = { x = 0, y = yOffset }
        end
        button:ClearAllPoints()
        button:SetPoint("BOTTOM", UIParent, "BOTTOM", world.x, world.y)
        button:SetWidth(buttonSize)
        button:SetHeight(buttonSize)
        button:SetScale(1)
        local icon = getglobal(button:GetName() .. "Icon")
        if icon then
            local appearance = self:Get("barAppearance") or "classic"
            if appearance == "modern" then
                icon:SetWidth(buttonSize - 2)
                icon:SetHeight(buttonSize - 2)
            else
                icon:SetWidth(buttonSize - 4)
                icon:SetHeight(buttonSize - 4)
            end
        end
        local bg = getglobal(button:GetName() .. "Background")
        if bg then
            bg:SetWidth(buttonSize * 1.6)
            bg:SetHeight(buttonSize * 1.6)
        end
        local normalTex = getglobal(button:GetName() .. "NormalTexture")
        if normalTex then
            normalTex:SetWidth(buttonSize * 1.6)
            normalTex:SetHeight(buttonSize * 1.6)
        end
        if bars and bars.ApplyButtonAppearance then
            bars:ApplyButtonAppearance(button)
        end
        local cooldown = getglobal(button:GetName() .. "Cooldown")
        if cooldown then
            local defaultCooldownSize = 36
            local scaleFactor = buttonSize / defaultCooldownSize
            cooldown:SetScale(scaleFactor)
            cooldown:ClearAllPoints()
            cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
            cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        end
        button:Show()
    end

    local function placeModifier(button, modifier, col)
        if not button or not Layout or not Layout.ModifierWorld then
            return
        end
        local world = Layout.ModifierWorld(modifier, layout, metrics, padding, starPadding, xOffset, yOffset, col)
        button:ClearAllPoints()
        button:SetPoint("BOTTOM", UIParent, "BOTTOM", world.x, world.y)
        button:SetWidth(buttonSize)
        button:SetHeight(buttonSize)
        button:SetScale(1)
        if bars and bars.PaintModifierButton then
            local active = modifier == "lb" and IsControlKeyDown and IsControlKeyDown()
                or modifier == "lt" and IsShiftKeyDown and IsShiftKeyDown()
            bars:PaintModifierButton(button, active)
        end
        button:Show()
    end

    if bars and bars.EnsureModifierButtons then
        bars:EnsureModifierButtons()
    end

    if layout == "full" then
        if bars and bars.EnsureFullButtons then
            bars:EnsureFullButtons()
        end
        for id = 1, 10 do
            place(getglobal("ConsoleActionButton" .. id), id, 0)
            if bars and bars.fullLeft then
                place(bars.fullLeft[id], id, -1)
                place(bars.fullRight[id], id, 1)
            end
        end
        if bars and bars.modifierButtons then
            local cols = { -1, 0, 1 }
            local ci
            for ci = 1, 3 do
                local col = cols[ci]
                placeModifier(bars.modifierButtons[col].lb, "lb", col)
                placeModifier(bars.modifierButtons[col].lt, "lt", col)
            end
        end
        if bars and bars.ApplyFullAlpha then
            bars:ApplyFullAlpha()
        end
    else
        if bars and bars.fullLeft then
            for id = 1, 10 do
                if bars.fullLeft[id] then
                    bars.fullLeft[id]:Hide()
                end
                if bars.fullRight[id] then
                    bars.fullRight[id]:Hide()
                end
            end
        end
        if bars and bars.modifierButtons then
            bars.modifierButtons[-1].lb:Hide()
            bars.modifierButtons[-1].lt:Hide()
            bars.modifierButtons[1].lb:Hide()
            bars.modifierButtons[1].lt:Hide()
            placeModifier(bars.modifierButtons[0].lb, "lb", 0)
            placeModifier(bars.modifierButtons[0].lt, "lt", 0)
            bars:SetModifierColumnAlpha(0, 1)
        end
        for id = 1, 10 do
            local button = getglobal("ConsoleActionButton" .. id)
            place(button, id)
            if button then
                button:SetAlpha(1)
            end
        end
    end
    
    -- Update side action bars to match new settings
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
        ConsoleUI.actionbars:UpdateSideBars()
    end
    if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
        ConsoleUI.xpbar:UpdateAllBars()
    end
    if ConsoleUI.castbar then
        if ConsoleUI.castbar.castBar and ConsoleUI.castbar.PaintLook then
            ConsoleUI.castbar:PaintLook(ConsoleUI.castbar.castBar)
        end
        if ConsoleUI.castbar.UpdateColor then
            ConsoleUI.castbar:UpdateColor()
        end
    end
end

-- ============================================================================
-- Slash Command
-- ============================================================================

SLASH_CONSOLEUI1 = "/cui"
SLASH_CONSOLEUI2 = "/consoleui"
SlashCmdList["CONSOLEUI"] = function(msg)
    local command = string.lower(string.gsub(msg or "", "^%s*(.-)%s*$", "%1"))
    if command == "test" or command == "audit" then
        if ConsoleUI.RunAudit then
            ConsoleUI:RunAudit()
        else
            ConsoleUI_Print("Audit is not loaded.")
        end
    elseif command == "debug" or command == "diag" or command == "diagnostics" or command == "verify" then
        if ConsoleUI.ReportDiagnostics then
            ConsoleUI:ReportDiagnostics()
        end
    elseif command == "debug on" then
        Config:Set("debugEnabled", true)
        ConsoleUI_Print("Debug messages enabled. Run /cui debug to print a report.")
    elseif command == "debug off" then
        Config:Set("debugEnabled", false)
        ConsoleUI_Print("Debug messages disabled.")
    elseif command == "modern" or command == "classic" then
        Config:Set("barAppearance", command)
        Config:UpdateActionBarLayout()
        ConsoleUI_Print("Action-bar appearance: " .. command)
    elseif command == "gold" or command == "gold on" then
        Config:Set("barGoldBorder", true)
        Config:UpdateActionBarLayout()
        ConsoleUI_Print("Action-bar gold border: on")
    elseif command == "gold off" then
        Config:Set("barGoldBorder", false)
        Config:UpdateActionBarLayout()
        ConsoleUI_Print("Action-bar gold border: off")
    elseif command == "look" then
        if ConsoleUI_MouseLook then
            ConsoleUI_MouseLook()
        end
    elseif command == "help" then
        ConsoleUI_Print("/cui - settings; /cui test; /cui debug; /cui look; /cui gold|gold off; /cui modern|classic")
        ConsoleUI_Print("/cuiignore - manage persistent cursor navigation exclusions")
    else
        Config:Toggle()
    end
end

SLASH_CONSOLEUIHEALER1 = "/cuihealer"
SLASH_CONSOLEUIHEALER2 = "/cuiheal"
SlashCmdList["CONSOLEUIHEALER"] = function(msg)
    local currentValue = Config:Get("healerMode")
    local newValue = currentValue
    local msgLower = string.lower(string.gsub(msg or "", "^%s*(.-)%s*$", "%1"))
    
    if msgLower == "on" or msgLower == "enable" or msgLower == "1" or msgLower == "true" then
        newValue = true
    elseif msgLower == "off" or msgLower == "disable" or msgLower == "0" or msgLower == "false" then
        newValue = false
    elseif msgLower == "" or msgLower == "toggle" then
        -- Toggle if no argument or "toggle" is provided
        newValue = not currentValue
    else
        -- Show current state and usage
        ConsoleUI_Print("Healer mode is currently: " .. (currentValue and "ENABLED" or "DISABLED"))
        ConsoleUI_Print("Usage: /cuihealer [on|off|toggle]")
        return
    end
    
    -- Only update if value changed
    if newValue ~= currentValue then
        Config:Set("healerMode", newValue)
        if newValue then
            ConsoleUI_Print("Healer mode ENABLED")
        else
            ConsoleUI_Print("Healer mode DISABLED")
        end
        -- Update party/raid frame hooks when healer mode changes
        if ConsoleUI.hooks and ConsoleUI.hooks.HookPartyRaidFrames then
            ConsoleUI.hooks:HookPartyRaidFrames()
        end
        -- Update action bar buttons (to hide/show D-pad buttons)
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
    else
        -- Value didn't change, just show current state
        ConsoleUI_Print("Healer mode is already: " .. (currentValue and "ENABLED" or "DISABLED"))
    end
end

-- After UpdateActionBarLayout / UpdateCrosshair exist. A SetPoint error
-- here must not abort the rest of this file.
Config:CreateGameMenuButton()
