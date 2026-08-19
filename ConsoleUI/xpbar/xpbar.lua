--[[
    ConsoleUI - XP/Reputation Bar Module
    
    Custom experience and reputation bars similar to pfUI
    Shows XP/Rep bars below chat frame, fades out after timeout
]]

-- Create the xpbar module namespace
if ConsoleUI.xpbar == nil then
    ConsoleUI.xpbar = {}
end

local XPBar = ConsoleUI.xpbar

-- ============================================================================
-- Constants
-- ============================================================================

XPBar.DEFAULT_TIMEOUT = 5.0  -- Seconds before bar fades out
XPBar.FADE_SPEED = 0.05      -- Alpha decrease per frame
XPBar.UPDATE_INTERVAL = 0.01 -- Update interval for fade

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function round(num)
    return math.floor(num + 0.5)
end

local function GetStringColor(colorString)
    -- Parse color string like "1.0,1.0,1.0,1.0" or "r,g,b,a"
    -- Manual split for WoW 1.12 compatibility (strsplit not available)
    local str = colorString or "1.0,1.0,1.0,1.0"
    local parts = {}
    local start = 1
    local pos = 1
    
    while pos <= string.len(str) do
        local found = string.find(str, ",", pos)
        if not found then
            -- Last part
            table.insert(parts, string.sub(str, start))
            break
        else
            table.insert(parts, string.sub(str, start, found - 1))
            start = found + 1
            pos = found + 1
        end
    end
    
    local r = tonumber(parts[1]) or 1.0
    local g = tonumber(parts[2]) or 1.0
    local b = tonumber(parts[3]) or 1.0
    local a = tonumber(parts[4]) or 1.0
    
    return r, g, b, a
end

-- ============================================================================
-- Data Tracking Frame
-- ============================================================================

local function CreateDataFrame()
    local data = CreateFrame("Frame", "ConsoleUIXPBarData", UIParent)
    data:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    data:RegisterEvent("PLAYER_ENTERING_WORLD")
    data:RegisterEvent("PLAYER_LEVEL_UP")
    
    -- Parse faction change messages
    local parse_faction = string.gsub(FACTION_STANDING_INCREASED, "%%s", "(.+)")
    parse_faction = string.gsub(parse_faction, "%%d", "%%d+")
    
    data:SetScript("OnEvent", function()
        if event == "PLAYER_ENTERING_WORLD" then
            this.starttime = GetTime()
            this.startxp = UnitXP("player") or 0
        elseif event == "PLAYER_LEVEL_UP" then
            -- Add previously gained experience to the session
            this.startxp = this.startxp - UnitXPMax("player")
        elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
            local _, _, faction, amount = string.find(arg1, parse_faction)
            this.faction = faction or this.faction
        end
    end)
    
    return data
end

local dataFrame = CreateDataFrame()

-- ============================================================================
-- Tooltip Functions
-- ============================================================================

local function OnLeave()
    local self = this
    self.tick = GetTime() + 3.0
    GameTooltip:Hide()
end

local function OnEnter()
    local self = this
    if not self or not self.bar then return end  -- Bar not initialized yet
    local lines = {}
    local config = ConsoleUI.config
    
    -- Determine display mode
    local mode = self.display
    if self.display == "XPFLEX" then
        mode = UnitLevel("player") < MAX_PLAYER_LEVEL and "XP" or "REP"
    elseif self.display == "FLEX" then
        mode = "REP"
    end
    
    self:SetAlpha(1)
    
    if mode == "XP" then
        local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
        local xp_perc = round(xp / xpmax * 100)
        local remaining = xpmax - xp
        local remaining_perc = round(remaining / xpmax * 100)
        local exh_perc = GetXPExhaustion() and round(GetXPExhaustion() / xpmax * 100) or 0
        local xp_persec = ((xp - dataFrame.startxp) / (GetTime() - dataFrame.starttime))
        local session = UnitXP("player") - dataFrame.startxp
        local avg_hour = math.floor(((UnitXP("player") - dataFrame.startxp) / (GetTime() - dataFrame.starttime)) * 60 * 60)
        local time_remaining = xp_persec > 0 and SecondsToTime(remaining / xp_persec) or 0
        
        table.insert(lines, { "|cff555555Experience", "" })
        table.insert(lines, { "XP", "|cffffffff" .. xp .. " / " .. xpmax .. " (" .. xp_perc .. "%)" })
        table.insert(lines, { "Remaining", "|cffffffff" .. remaining .. " (" .. remaining_perc .. "%)" })
        if IsResting() then
            table.insert(lines, { "Status", "|cffffffffResting" })
        end
        if GetXPExhaustion() then
            table.insert(lines, { "Rested", "|cff5555ff+" .. exh .. " (" .. exh_perc .. "%)" })
        end
        table.insert(lines, { "" })
        table.insert(lines, { "This Session", "|cffffffff" .. session })
        table.insert(lines, { "Average Per Hour", "|cffffffff" .. avg_hour })
        table.insert(lines, { "Time Remaining", "|cffffffff" .. time_remaining })
    elseif mode == "PETXP" then
        local xp, xpmax = GetPetExperience()
        local xp_perc = round(xp / xpmax * 100)
        local remaining = xpmax - xp
        local remaining_perc = round(remaining / xpmax * 100)
        
        table.insert(lines, { "|cff555555Experience", "" })
        table.insert(lines, { "XP", "|cffffffff" .. xp .. " / " .. xpmax .. " (" .. xp_perc .. "%)" })
        table.insert(lines, { "Remaining", "|cffffffff" .. remaining .. " (" .. remaining_perc .. "%)" })
    elseif mode == "REP" then
        for i = 1, 99 do
            local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
            if (isWatched and not self.faction) or (self.faction and name == self.faction) then
                barMax = barMax - barMin
                barValue = barValue - barMin
                
                local color = FACTION_BAR_COLORS[standingID]
                local colorStr = "|cff808080"
                if color then
                    local r = math.floor((color.r + 0.3) * 255)
                    local g = math.floor((color.g + 0.3) * 255)
                    local b = math.floor((color.b + 0.3) * 255)
                    colorStr = string.format("|cff%02x%02x%02x", r, g, b)
                end
                
                table.insert(lines, { "|cff555555Reputation", "" })
                table.insert(lines, { colorStr .. name .. " (" .. GetText("FACTION_STANDING_LABEL" .. standingID, UnitSex("player")) .. ")" })
                table.insert(lines, { barValue .. " / " .. barMax .. " (" .. round(barValue / barMax * 100) .. "%)" })
                break
            end
        end
    end
    
    -- Draw tooltip
    GameTooltip:ClearLines()
    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    
    for id, data in pairs(lines) do
        if data[2] then
            GameTooltip:AddDoubleLine(data[1], data[2])
        else
            GameTooltip:AddLine(data[1])
        end
    end
    GameTooltip:Show()
end

-- ============================================================================
-- Update Functions
-- ============================================================================

local function OnUpdate()
    local self = this
    if not self or not self.bar then return end  -- Bar not initialized yet
    local config = ConsoleUI.config
    
    -- Show/hide text on mouseover
    if config:Get(self.text_mouse_key) == true then
        if MouseIsOver(self) then
            self.bar.text:Show()
        else
            self.bar.text:Hide()
        end
    end
    
    -- Always visible mode - skip fade
    if self.always then return end
    
    -- Skip fade if mouseover or already invisible
    if self:GetAlpha() == 0 or MouseIsOver(self) then return end
    
    -- Fade out
    if (self.tick or 1) > GetTime() then return else self.tick = GetTime() + XPBar.UPDATE_INTERVAL end
    local wasVisible = self:IsShown() and self:GetAlpha() > 0
    local newAlpha = self:GetAlpha() - XPBar.FADE_SPEED
    if newAlpha <= 0 then
        self:SetAlpha(0)
        self:Hide()  -- Hide completely when faded out
        
        -- Update chat position when bar fades out
        if wasVisible and ConsoleUI.xpbar then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    else
        self:SetAlpha(newAlpha)
    end
end

local function OnEvent()
    local self = this
    if not self or not self.bar then return end  -- Bar not initialized yet
    local config = ConsoleUI.config
    
    -- Update position when entering world
    if event == "PLAYER_ENTERING_WORLD" then
        XPBar:UpdateBarPosition(self)
        -- If not always visible, don't show bars on world entry - only show on actual data changes
        if not self.always then
            return
        end
    end
    
    -- Determine display mode
    local mode = self.display
    if self.display == "XPFLEX" then
        self.faction = dataFrame.faction or nil
        mode = UnitLevel("player") < MAX_PLAYER_LEVEL and "XP" or "REP"
    elseif self.display == "FLEX" then
        self.faction = dataFrame.faction or nil
        mode = "REP"
    end
    
    -- Skip events that don't apply to this mode
    -- Also skip if event is nil (initial call during bar creation) UNLESS always is true
    if not event then
        -- If always visible, we still want to populate data on initial load
        if not self.always then
            return
        end
        -- For always visible bars, use a default event to trigger data population
        event = "PLAYER_ENTERING_WORLD"
    end
    
    if mode == "XP" and (event == "CHAT_MSG_COMBAT_FACTION_CHANGE" or event == "UPDATE_FACTION") then return end
    if mode == "REP" and (event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION") then return end
    
    -- Set always visible (after checking mode, so we can populate data)
    if self.always then
        self:SetAlpha(1)
        self:Show()
    end
    
    if mode == "XP" then
        local wasVisible = self:IsShown() and self:GetAlpha() > 0
        self.enabled = true
        self:Show()  -- Show the bar when there's data
        self:SetAlpha(1)
        
        local xp, xpmax, ex = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
        
        -- Set bar values
        self.bar:SetMinMaxValues(0, xpmax)
        self.bar:SetValue(xp)
        
        -- Set rested bar and XP bar color based on rested status
        if ex and ex > 0 then
            -- Has rested XP - show rested bar and use blue color
            if self.restedbar then
                self.restedbar:Show()
                self.restedbar:SetMinMaxValues(0, xpmax)
                self.restedbar:SetValue(xp + ex)
            end
            -- Blue color when rested
            self.bar:SetStatusBarColor(0.0, 0.5, 1.0, 1.0)
        else
            -- No rested XP - hide rested bar and use purple color
            if self.restedbar then
                self.restedbar:Hide()
            end
            -- Purple color when not rested
            self.bar:SetStatusBarColor(0.6, 0.0, 0.8, 1.0)
        end
        
        -- Set text
        local text = "%s: %s%%"
        local xpperc = xpmax > 0 and round(xp / xpmax * 100) or 0
        local experc = ex and xpmax > 0 and round(ex / xpmax * 100) or 0
        if ex and ex > 0 then 
            text = "%s: %s%% (%s%% Rested)" 
        end
        if self.bar.text then
            self.bar.text:SetText(string.format(text, "Experience", xpperc, experc))
        end
        
        self.tick = GetTime() + self.timeout
        
        -- Update position immediately when bar becomes visible
        if not wasVisible and ConsoleUI.xpbar then
            ConsoleUI.xpbar:UpdateBarPosition(self)
            ConsoleUI.xpbar:UpdateAllBars()
        end
        return
    elseif mode == "PETXP" then
        if self.restedbar then
            self.restedbar:Hide()
        end
        self.enabled = true
        self:Show()  -- Show the bar when there's data
        self:SetAlpha(1)
        
        local currXP, nextXP = GetPetExperience()
        self.bar:SetMinMaxValues(math.min(0, currXP), nextXP)
        self.bar:SetValue(currXP)
        
        local text = "%s: %s%%"
        local xpperc = nextXP and nextXP ~= 0 and round(currXP / nextXP * 100) or 0
        if self.bar.text then
            self.bar.text:SetText(string.format(text, "Pet Experience", xpperc))
        end
        
        self.tick = GetTime() + self.timeout
        return
    elseif mode == "REP" then
        if self.restedbar then
            self.restedbar:Hide()
        end
        
        -- Only show rep bar if always visible OR if it's a reputation change event
        -- Don't show on UPDATE_FACTION or other events when always is false
        if not self.always and event ~= "CHAT_MSG_COMBAT_FACTION_CHANGE" then
            -- Not always visible and not a reputation change event, don't show
            return
        end
        
        for i = 1, 99 do
            local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i)
            if (isWatched and not self.faction) or (self.faction and name == self.faction) then
                local wasVisible = self:IsShown() and self:GetAlpha() > 0
                self.enabled = true
                self:Show()  -- Show the bar when there's data
                self:SetAlpha(1)
                
                barMax = barMax - barMin
                barValue = barValue - barMin
                
                self.bar:SetMinMaxValues(0, barMax)
                self.bar:SetValue(barValue)
                
                local color = FACTION_BAR_COLORS[standingID]
                if color then
                    self.bar:SetStatusBarColor((color.r + 0.5) * 0.5, (color.g + 0.5) * 0.5, (color.b + 0.5) * 0.5, 1)
                else
                    -- Default to green if no faction color available (matching WoW default UI)
                    self.bar:SetStatusBarColor(0.0, 1.0, 0.0, 1)
                end
                
                local text = "%s: %s%% (%s)"
                local perc = round(barValue / barMax * 100)
                local standing = GetText("FACTION_STANDING_LABEL" .. standingID, UnitSex("player"))
                if self.bar.text then
                    self.bar.text:SetText(string.format(text, name, perc, standing))
                end
                
                self.tick = GetTime() + self.timeout
                
                -- Update position immediately when bar becomes visible
                if not wasVisible and ConsoleUI.xpbar then
                    ConsoleUI.xpbar:UpdateBarPosition(self)
                    ConsoleUI.xpbar:UpdateAllBars()
                end
                return
            end
        end
    end
    
    -- No data to show
    local wasVisible = self:IsShown() and self:GetAlpha() > 0
    self.enabled = false
    if not self.always then
        self:SetAlpha(0)
        self:Hide()  -- Hide the bar when there's no data and not always visible
        
        -- Update chat position if bar was visible and now hidden
        if wasVisible and ConsoleUI.xpbar then
            ConsoleUI.xpbar:UpdateAllBars()
        end
    else
        self.bar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        self.bar:SetMinMaxValues(0, 1)
        self.bar:SetValue(0)
    end
    
end

-- ============================================================================
-- Bar Creation
-- ============================================================================

-- Minimum height for border texture to render properly
-- edgeSize (12) * 2 (top + bottom) + minimum content space (2) = 26
-- Reduced to allow smaller bars while still maintaining border visibility
XPBar.MIN_HEIGHT = 20

function XPBar:ReloadBarConfig(bar, barType)
    local config = ConsoleUI.config
    local prefix = barType == "XP" and "xp" or "rep"
    
    bar.width = config:Get(prefix .. "BarWidth") or 400
    
    -- Enforce minimum height for border texture
    local configHeight = config:Get(prefix .. "BarHeight") or 8
    bar.height = math.max(XPBar.MIN_HEIGHT, configHeight)
    
    bar.timeout = config:Get(prefix .. "BarTimeout") or XPBar.DEFAULT_TIMEOUT
    bar.display = config:Get(prefix .. "BarDisplay") or (barType == "XP" and "XP" or "REP")
    bar.always = config:Get(prefix .. "BarAlways") or false
    -- Load text_show from config, default to true if not set
    -- Need to check for nil explicitly, not use 'or' because false is falsy
    local textShowConfig = config:Get(prefix .. "BarTextShow")
    if textShowConfig == nil then
        bar.text_show = true  -- Default to true if not set
    else
        bar.text_show = textShowConfig  -- Use the actual value (can be false)
    end
    bar.text_mouse = config:Get(prefix .. "BarTextMouse") or false
    bar.text_off_y = config:Get(prefix .. "BarTextOffsetY") or 0
    
    -- Update text visibility if text exists
    if bar.bar and bar.bar.text then
        if bar.text_show then
            bar.bar.text:Show()
        else
            bar.bar.text:Hide()
        end
    end
    
    -- Calculate font size based on bar height (scale proportionally)
    -- Scale from 8px font at MIN_HEIGHT to 16px font at MIN_HEIGHT*2
    bar.font_size = math.max(8, math.min(16, math.floor(bar.height * 0.5)))
    
    -- Store config keys for updates
    bar.text_mouse_key = prefix .. "BarTextMouse"
    bar.width_key = prefix .. "BarWidth"
    bar.height_key = prefix .. "BarHeight"
    bar.display_key = prefix .. "BarDisplay"
    bar.always_key = prefix .. "BarAlways"
    bar.text_show_key = prefix .. "BarTextShow"
    bar.text_off_y_key = prefix .. "BarTextOffsetY"
    bar.barType = barType
    if ConsoleUI.config and ConsoleUI.config.PaintStatusBarChrome then
        ConsoleUI.config:PaintStatusBarChrome(bar)
    end
end

function XPBar:CreateBar(barType)
    local name = barType == "XP" and "ConsoleUIExperienceBar" or "ConsoleUIReputationBar"
    local config = ConsoleUI.config
    
    local b = _G[name] or CreateFrame("Frame", name, UIParent)
    
    -- Store barType before loading config
    b.barType = barType
    
    -- Load config values
    self:ReloadBarConfig(b, barType)
    
    -- Get colors (WoW default colors)
    local xp_color = config:Get("xpBarColor") or "0.0,1.0,0.0,1.0"
    local rest_color = config:Get("xpBarRestColor") or "0.0,0.5,1.0,1.0"
    
    local barLevel, restedLevel = 0, 1
    if config:Get("xpBarDontOverlap") == true then
        barLevel, restedLevel = 1, 0
    end
    
    -- Ensure minimum height
    b.height = math.max(XPBar.MIN_HEIGHT, b.height)
    b:SetWidth(b.width)
    b:SetHeight(b.height)
    b:SetFrameStrata("BACKGROUND")
    
    -- Create status bar
    b.bar = b.bar or CreateFrame("StatusBar", nil, b)
    local inset = (config.STATUS_BAR_INSET) or 3
    b.bar:ClearAllPoints()
    b.bar:SetPoint("TOPLEFT", b, "TOPLEFT", inset, -inset)
    b.bar:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -inset, inset)
    b.bar:SetFrameLevel(barLevel)
    
    -- Set bar color based on bar type
    if barType == "XP" then
        -- Default to purple (not rested) - will be updated dynamically based on rested status
        b.bar:SetStatusBarColor(0.6, 0.0, 0.8, 1.0)
    else
        -- REP bar default color (green, matching WoW default UI)
        -- Will be overridden dynamically based on faction standing
        b.bar:SetStatusBarColor(0.0, 1.0, 0.0, 1)
    end
    b.bar:SetOrientation("HORIZONTAL")
    
    -- Ensure bar is visible and has initial values
    b.bar:SetMinMaxValues(0, 100)
    b.bar:SetValue(50)  -- Set to 50% for testing visibility
    b.bar:Show()
    
    -- Create rested bar (for XP only) - uses same texture as main bar
    if barType == "XP" then
        b.restedbar = b.restedbar or CreateFrame("StatusBar", nil, b)
        b.restedbar:ClearAllPoints()
        b.restedbar:SetPoint("TOPLEFT", b, "TOPLEFT", inset, -inset)
        b.restedbar:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -inset, inset)
        b.restedbar:SetFrameLevel(restedLevel)
        local cr, cg, cb, ca = GetStringColor(rest_color)
        b.restedbar:SetStatusBarColor(cr, cg, cb, ca)
        b.restedbar:SetOrientation("HORIZONTAL")
        b.restedbar:SetMinMaxValues(0, 100)
        b.restedbar:SetValue(0)
        b.restedbar:Hide()  -- Hidden by default until rested XP is available
    end
    if config.PaintStatusBarChrome then
        config:PaintStatusBarChrome(b)
    end

    -- Text on the rim frame so the fill does not cover it
    local textParent = b.cuiChrome or b
    b.bar.text = b.bar.text or textParent:CreateFontString(nil, "OVERLAY")
    b.bar.text:SetPoint("CENTER", b, "CENTER", 0, b.text_off_y)
    b.bar.text:SetJustifyH("CENTER")
    b.bar.text:SetFont("Fonts\\FRIZQT__.TTF", b.font_size, "OUTLINE")
    b.bar.text:SetTextColor(1, 1, 1, 1)
    
    if b.text_show then
        b.bar.text:Show()
    else
        b.bar.text:Hide()
    end
    
    -- Enable mouse for tooltip
    b:EnableMouse(true)
    
    -- Register events
    b:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    b:RegisterEvent("UNIT_PET")
    b:RegisterEvent("UNIT_LEVEL")
    b:RegisterEvent("UNIT_PET_EXPERIENCE")
    b:RegisterEvent("PLAYER_ENTERING_WORLD")
    b:RegisterEvent("UPDATE_EXHAUSTION")
    b:RegisterEvent("PLAYER_XP_UPDATE")
    b:RegisterEvent("PLAYER_LEVEL_UP")
    b:RegisterEvent("UPDATE_FACTION")
    
    b:SetScript("OnUpdate", OnUpdate)
    b:SetScript("OnEvent", OnEvent)
    b:SetScript("OnEnter", OnEnter)
    b:SetScript("OnLeave", OnLeave)
    
    -- Ensure bar elements are created, but start hidden
    if b.bar then
        b.bar:Show()
    end
    
    -- Start bars hidden unless always visible is enabled
    -- They will be shown by OnEvent when there's actual data
    if b.always then
        -- If always visible, trigger initial update to show bar
        -- Set event as global so OnEvent can access it
        event = "PLAYER_ENTERING_WORLD"
        b:GetScript("OnEvent")(b)
    else
        -- Start hidden - will be shown by OnEvent when data is available
        b:SetAlpha(0)
        b:Hide()
    end
    
    return b
end

-- ============================================================================
-- Position Update
-- ============================================================================

function XPBar:UpdateBarPosition(bar)
    if not bar then return end
    
    local config = ConsoleUI.config
    
    -- Reload config to ensure height is updated and minimum enforced
    self:ReloadBarConfig(bar, bar.barType)
    
    local barWidth = config:Get(bar.width_key) or 400
    local gap = 2
    local barHeight = bar.height
    
    -- REP at the bottom. XP stacks above REP when REP is visible.
    local barYOffset = 0
    if bar == self.xpBar and self.repBar and self.repBar:IsShown() and self.repBar:GetAlpha() > 0 then
        barYOffset = (self.repBar.height or XPBar.MIN_HEIGHT) + gap
    end
    
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, barYOffset)
    bar:SetWidth(barWidth)
    bar:SetHeight(barHeight)
    
    -- Update status bar size to match new height
    local inset = (config.STATUS_BAR_INSET) or 3
    if bar.bar then
        bar.bar:ClearAllPoints()
        bar.bar:SetPoint("TOPLEFT", bar, "TOPLEFT", inset, -inset)
        bar.bar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -inset, inset)
    end
    
    -- Update rested bar size if it exists
    if bar.restedbar then
        bar.restedbar:ClearAllPoints()
        bar.restedbar:SetPoint("TOPLEFT", bar, "TOPLEFT", inset, -inset)
        bar.restedbar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -inset, inset)
    end
    if config.PaintStatusBarChrome then
        config:PaintStatusBarChrome(bar)
    end
    
    -- Update text font size to match new height
    if bar.bar and bar.bar.text then
        bar.bar.text:SetFont("Fonts\\FRIZQT__.TTF", bar.font_size, "OUTLINE")
    end
end

function XPBar:UpdateAllBars()
    -- Update REP bar first (it's at the bottom)
    if self.repBar then
        self:ReloadBarConfig(self.repBar, "REP")
        self:UpdateBarPosition(self.repBar)
    end
    -- Then update XP bar (it's above REP bar)
    if self.xpBar then
        self:ReloadBarConfig(self.xpBar, "XP")
        self:UpdateBarPosition(self.xpBar)
    end
    ConsoleUI_Debug("Updating all bars")
    -- Apply text visibility for both bars (ReloadBarConfig already sets text_show, now apply it)
    if self.xpBar and self.xpBar.bar and self.xpBar.bar.text then
        ConsoleUI_Debug("xpBar.text_show: " .. tostring(self.xpBar.text_show))
        if self.xpBar.text_show then
            self.xpBar.bar.text:Show()
        else
            self.xpBar.bar.text:Hide()
        end
    end
    if self.repBar and self.repBar.bar and self.repBar.bar.text then
        ConsoleUI_Debug("repBar.text_show: " .. tostring(self.repBar.text_show))
        if self.repBar.text_show then
            self.repBar.bar.text:Show()
        else
            self.repBar.bar.text:Hide()
        end
    end
    if ConsoleUI.castbar and ConsoleUI.castbar.UpdatePosition then
        ConsoleUI.castbar:UpdatePosition()
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

function XPBar:Initialize()
    -- Create bars
    self.xpBar = self:CreateBar("XP")
    self.repBar = self:CreateBar("REP")
    
    -- Update positions
    self:UpdateAllBars()
    
end
