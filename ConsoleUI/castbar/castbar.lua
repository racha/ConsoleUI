--[[
    ConsoleUI - Cast Bar Module
    
    Custom cast bar that appears above the chat frame
    Uses the same texture style as the XP/Rep bars
]]

-- Create the castbar module namespace
if ConsoleUI.castbar == nil then
    ConsoleUI.castbar = {}
end

local CastBar = ConsoleUI.castbar

-- ============================================================================
-- Constants
-- ============================================================================

CastBar.MIN_HEIGHT = 20  -- Minimum height for border texture to render properly

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function round(num)
    return math.floor(num + 0.5)
end

-- ============================================================================
-- Default Castbar Management
-- ============================================================================

-- Store original functions to restore later
CastBar.originalCastingBarShow = nil
CastBar.blizzardCastbarHidden = false

function CastBar:HideBlizzardCastbar()
    if self.blizzardCastbarHidden then return end
    
    if CastingBarFrame then
        -- Store original OnShow if not already stored
        if not self.originalCastingBarShow then
            self.originalCastingBarShow = CastingBarFrame:GetScript("OnShow")
        end
        
        -- Override OnShow to prevent it from showing
        CastingBarFrame:SetScript("OnShow", function()
            CastingBarFrame:Hide()
        end)
        
        -- Unregister all events and hide
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:Hide()
        
        self.blizzardCastbarHidden = true
    end
end

function CastBar:ShowBlizzardCastbar()
    if not self.blizzardCastbarHidden then return end
    
    if CastingBarFrame then
        -- Restore original OnShow script
        if self.originalCastingBarShow then
            CastingBarFrame:SetScript("OnShow", self.originalCastingBarShow)
        else
            CastingBarFrame:SetScript("OnShow", nil)
        end
        
        -- Re-register events for the default castbar
        CastingBarFrame:RegisterEvent("SPELLCAST_START")
        CastingBarFrame:RegisterEvent("SPELLCAST_STOP")
        CastingBarFrame:RegisterEvent("SPELLCAST_FAILED")
        CastingBarFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
        CastingBarFrame:RegisterEvent("SPELLCAST_DELAYED")
        CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
        CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
        CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
        
        self.blizzardCastbarHidden = false
    end
end

-- ============================================================================
-- Cast Bar Creation
-- ============================================================================

function CastBar:CreateBar()
    local config = ConsoleUI.config
    if not config then return end
    
    -- Check if castbar is enabled
    if not config:Get("castbarEnabled") then return end
    
    local name = "ConsoleUICastBar"
    
    -- Create the main frame
    local b = _G[name] or CreateFrame("Frame", name, UIParent)
    
    -- Get dimensions from config
    local barWidth = config:Get("xpBarWidth") or 400
    local barHeight = math.max(CastBar.MIN_HEIGHT, config:Get("castbarHeight") or 20)
    
    b.width = barWidth
    b.height = barHeight
    
    b:SetWidth(barWidth)
    b:SetHeight(barHeight)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(10)
    
    -- Create status bar. Fill + rim come from PaintStatusBarChrome.
    b.bar = b.bar or CreateFrame("StatusBar", nil, b)
    local inset = (config.STATUS_BAR_INSET) or 3
    b.bar:ClearAllPoints()
    b.bar:SetPoint("TOPLEFT", b, "TOPLEFT", inset, -inset)
    b.bar:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -inset, inset)
    
    -- Get color from config (blue by default)
    local colorR = config:Get("castbarColorR") or 0.0
    local colorG = config:Get("castbarColorG") or 0.5
    local colorB = config:Get("castbarColorB") or 1.0
    b.bar:SetStatusBarColor(colorR, colorG, colorB, 1.0)
    b.bar:SetOrientation("HORIZONTAL")
    b.bar:SetMinMaxValues(0, 100)
    b.bar:SetValue(0)
    b.bar:Show()
    
    if config.PaintStatusBarChrome then
        config:PaintStatusBarChrome(b)
    end
    local overlay = b.cuiChrome or b

    -- Spark + text on the rim frame so they sit above the fill
    b.spark = b.spark or overlay:CreateTexture(nil, "OVERLAY")
    b.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    b.spark:SetWidth(16)
    b.spark:SetHeight(barHeight * 2)
    b.spark:SetBlendMode("ADD")
    b.spark:Hide()
    
    local fontSize = math.max(8, math.min(14, math.floor(barHeight * 0.5)))
    b.text = b.text or overlay:CreateFontString(nil, "OVERLAY")
    b.text:SetPoint("CENTER", b.bar, "CENTER", 0, 0)
    b.text:SetJustifyH("CENTER")
    b.text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    b.text:SetTextColor(1, 1, 1, 1)
    b.text:SetText("")
    
    b.timer = b.timer or overlay:CreateFontString(nil, "OVERLAY")
    b.timer:SetPoint("RIGHT", b.bar, "RIGHT", -5, 0)
    b.timer:SetJustifyH("RIGHT")
    b.timer:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    b.timer:SetTextColor(1, 1, 1, 1)
    b.timer:SetText("")

    -- Hide by default
    b:Hide()
    
    -- Store reference
    self.castBar = b
    
    -- Hide the default Blizzard castbar
    self:HideBlizzardCastbar()
    
    -- Set up casting events
    self:SetupEvents()
    
    return b
end

-- ============================================================================
-- Event Handling
-- ============================================================================

function CastBar:SetupEvents()
    if not self.castBar then return end
    
    local bar = self.castBar
    
    -- Register events
    bar:RegisterEvent("SPELLCAST_START")
    bar:RegisterEvent("SPELLCAST_STOP")
    bar:RegisterEvent("SPELLCAST_FAILED")
    bar:RegisterEvent("SPELLCAST_INTERRUPTED")
    bar:RegisterEvent("SPELLCAST_DELAYED")
    bar:RegisterEvent("SPELLCAST_CHANNEL_START")
    bar:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
    bar:RegisterEvent("SPELLCAST_CHANNEL_STOP")
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Mark events as registered
    bar.eventsRegistered = true
    
    -- State tracking
    bar.casting = false
    bar.channeling = false
    bar.startTime = 0
    bar.endTime = 0
    bar.spellName = ""
    
    -- Event handler
    bar:SetScript("OnEvent", function()
        local config = ConsoleUI.config
        if not config or not config:Get("castbarEnabled") then
            this:Hide()
            return
        end
        
        if event == "SPELLCAST_START" then
            -- arg1 = spell name, arg2 = cast time (ms)
            local castTime = tonumber(arg2)
            if not castTime or castTime <= 0 then
                -- Invalid cast time, ignore this event
                return
            end
            
            this.casting = true
            this.channeling = false
            this.spellName = arg1 or "Casting"
            this.startTime = GetTime()
            this.maxValue = this.startTime + (castTime / 1000)
            
            -- Use absolute time values like Blizzard does
            this.bar:SetMinMaxValues(this.startTime, this.maxValue)
            this.bar:SetValue(this.startTime)
            this.text:SetText(this.spellName)
            
            -- Set color from config
            local colorR = config:Get("castbarColorR") or 0.0
            local colorG = config:Get("castbarColorG") or 0.5
            local colorB = config:Get("castbarColorB") or 1.0
            this.bar:SetStatusBarColor(colorR, colorG, colorB, 1.0)
            
            this.spark:Show()
            CastBar:UpdatePosition()
            this:Show()
            
        elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
            this.casting = false
            this.channeling = false
            this.spark:Hide()
            this:Hide()
            
        elseif event == "SPELLCAST_DELAYED" then
            -- arg1 = delay amount (ms)
            local delayAmount = tonumber(arg1)
            if this.casting and delayAmount and this.startTime and this.maxValue then
                this.startTime = this.startTime + (delayAmount / 1000)
                this.maxValue = this.maxValue + (delayAmount / 1000)
                this.bar:SetMinMaxValues(this.startTime, this.maxValue)
            end
            
        elseif event == "SPELLCAST_CHANNEL_START" then
            -- TurtleWoW: arg1 = channel time (ms), arg2 = spell name
            -- (This is reversed from standard vanilla where arg1=name, arg2=time)
            ConsoleUI_Debug("SPELLCAST_CHANNEL_START: arg1=" .. tostring(arg1) .. ", arg2=" .. tostring(arg2))
            
            local channelTime = tonumber(arg1)
            local spellName = arg2
            
            -- Fallback: if arg1 looks like a spell name, swap them (standard vanilla order)
            if not channelTime and type(arg1) == "string" then
                channelTime = tonumber(arg2)
                spellName = arg1
            end
            
            -- Default channel time if still invalid
            if not channelTime or channelTime <= 0 then
                channelTime = 8000
                ConsoleUI_Debug("Using default channel time: 8000ms")
            end
            
            this.casting = false
            this.channeling = true
            this.spellName = spellName or "Channeling"
            this.startTime = GetTime()
            this.endTime = this.startTime + (channelTime / 1000)
            
            ConsoleUI_Debug("Channel started: " .. tostring(this.spellName) .. ", duration=" .. (channelTime/1000) .. "s")
            
            -- Use absolute time values like Blizzard does
            this.bar:SetMinMaxValues(this.startTime, this.endTime)
            this.bar:SetValue(this.endTime)  -- Start full for channeling
            this.text:SetText(this.spellName)
            
            -- Set channel color from config (gold by default)
            local colorR = config:Get("castbarChannelColorR") or 1.0
            local colorG = config:Get("castbarChannelColorG") or 0.75
            local colorB = config:Get("castbarChannelColorB") or 0.25
            this.bar:SetStatusBarColor(colorR, colorG, colorB, 1.0)
            
            this.spark:Show()
            CastBar:UpdatePosition()
            this:Show()
            
        elseif event == "SPELLCAST_CHANNEL_UPDATE" then
            -- arg1 = new channel time remaining (ms)
            ConsoleUI_Debug("SPELLCAST_CHANNEL_UPDATE: arg1=" .. tostring(arg1))
            local newTimeRemaining = tonumber(arg1)
            if this.channeling and newTimeRemaining and this.endTime and this.startTime then
                local origDuration = this.endTime - this.startTime
                if origDuration > 0 then
                    this.endTime = GetTime() + (newTimeRemaining / 1000)
                    this.startTime = this.endTime - origDuration
                    this.bar:SetMinMaxValues(this.startTime, this.endTime)
                end
            end
            
        elseif event == "SPELLCAST_CHANNEL_STOP" then
            ConsoleUI_Debug("SPELLCAST_CHANNEL_STOP received")
            this.casting = false
            this.channeling = false
            this.spark:Hide()
            this:Hide()
            
        elseif event == "PLAYER_ENTERING_WORLD" then
            CastBar:UpdatePosition()
        end
    end)
    
    -- OnUpdate for smooth progress (following Blizzard's approach)
    bar:SetScript("OnUpdate", function()
        if this.casting then
            -- Safety check for required values
            if not this.maxValue or not this.startTime then
                this.casting = false
                this.spark:Hide()
                this:Hide()
                return
            end
            
            local status = GetTime()
            if status > this.maxValue then
                status = this.maxValue
            end
            this.bar:SetValue(status)
            
            -- Calculate spark position like Blizzard does
            -- Spark is positioned relative to parent frame, accounting for 3px padding
            local barInnerWidth = this:GetWidth() - 6  -- subtract 3px padding on each side
            local duration = this.maxValue - this.startTime
            local sparkPosition = 0
            if duration > 0 then
                sparkPosition = ((status - this.startTime) / duration) * barInnerWidth
            end
            if sparkPosition < 0 then
                sparkPosition = 0
            end
            this.spark:ClearAllPoints()
            this.spark:SetPoint("CENTER", this, "LEFT", 3 + sparkPosition, 0)
            
            -- Update timer text
            local remaining = this.maxValue - status
            if remaining > 0 then
                this.timer:SetText(string.format("%.1f", remaining))
            else
                this.timer:SetText("")
            end
            
        elseif this.channeling then
            -- Safety check for required values
            if not this.endTime or not this.startTime then
                this.channeling = false
                this.spark:Hide()
                this:Hide()
                return
            end
            
            local time = GetTime()
            if time > this.endTime then
                time = this.endTime
            end
            if time >= this.endTime then
                this.channeling = false
                this.spark:Hide()
                this:Hide()
                return
            end
            
            -- For channeling, bar value goes from endTime down to startTime
            local barValue = this.startTime + (this.endTime - time)
            this.bar:SetValue(barValue)
            
            -- Calculate spark position
            local barInnerWidth = this:GetWidth() - 6  -- subtract 3px padding on each side
            local duration = this.endTime - this.startTime
            local sparkPosition = 0
            if duration > 0 then
                sparkPosition = ((barValue - this.startTime) / duration) * barInnerWidth
            end
            this.spark:ClearAllPoints()
            this.spark:SetPoint("CENTER", this, "LEFT", 3 + sparkPosition, 0)
            
            -- Update timer text
            local remaining = this.endTime - time
            if remaining > 0 then
                this.timer:SetText(string.format("%.1f", remaining))
            else
                this.timer:SetText("")
            end
        end
    end)
end

-- ============================================================================
-- Position Update
-- ============================================================================

function CastBar:UpdatePosition()
    if not self.castBar then return end
    
    local config = ConsoleUI.config
    if not config then return end
    
    local bar = self.castBar
    
    local barWidth = config:Get("xpBarWidth") or 400
    local barHeight = math.max(CastBar.MIN_HEIGHT, config:Get("castbarHeight") or 20)
    local gap = 5
    
    local stackHeight = 0
    local xpbar = ConsoleUI.xpbar
    if xpbar then
        local repH, xpH = 0, 0
        if xpbar.repBar and xpbar.repBar:IsShown() and xpbar.repBar:GetAlpha() > 0 then
            repH = xpbar.repBar.height or config:Get("repBarHeight") or 20
        end
        if xpbar.xpBar and xpbar.xpBar:IsShown() and xpbar.xpBar:GetAlpha() > 0 then
            xpH = xpbar.xpBar.height or config:Get("xpBarHeight") or 20
        end
        if repH > 0 and xpH > 0 then
            stackHeight = repH + 2 + xpH
        else
            stackHeight = repH + xpH
        end
    end
    
    local castBarBottomY = stackHeight + gap
    
    local halfWidth = barWidth / 2
    
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", -halfWidth, castBarBottomY)
    bar:SetPoint("TOPRIGHT", UIParent, "BOTTOM", halfWidth, castBarBottomY + barHeight)
    
    bar.width = barWidth
    bar.height = barHeight
    
    -- Update bar size
    local inset = (config.STATUS_BAR_INSET) or 3
    if bar.bar then
        bar.bar:ClearAllPoints()
        bar.bar:SetPoint("TOPLEFT", bar, "TOPLEFT", inset, -inset)
        bar.bar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -inset, inset)
    end
    
    -- Update font size
    local fontSize = math.max(8, math.min(14, math.floor(barHeight * 0.5)))
    if bar.text then
        bar.text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    end
    if bar.timer then
        bar.timer:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    end
    
    -- Update spark height
    -- Update spark height (spark is child of bar, not bar.bar)
    if bar.spark then
        bar.spark:SetHeight(barHeight * 2)
    end
end

-- ============================================================================
-- Color Update
-- ============================================================================

function CastBar:UpdateColor()
    if not self.castBar or not self.castBar.bar then return end
    
    local config = ConsoleUI.config
    if not config then return end
    
    local colorR = config:Get("castbarColorR") or 0.0
    local colorG = config:Get("castbarColorG") or 0.5
    local colorB = config:Get("castbarColorB") or 1.0
    
    self.castBar.bar:SetStatusBarColor(colorR, colorG, colorB, 1.0)
end

-- ============================================================================
-- Reload Configuration
-- ============================================================================

function CastBar:ReloadConfig()
    local config = ConsoleUI.config
    if not config then return end
    
    -- Check if enabled
    if not config:Get("castbarEnabled") then
        if self.castBar then
            self.castBar:Hide()
            self.castBar:UnregisterAllEvents()
            self.castBar.eventsRegistered = false
        end
        -- Restore the default Blizzard castbar when our castbar is disabled
        self:ShowBlizzardCastbar()
        return
    end
    
    -- Create bar if it doesn't exist
    if not self.castBar then
        self:CreateBar()
    else
        -- If bar already exists, just make sure Blizzard castbar is hidden
        self:HideBlizzardCastbar()
    end
    
    -- Update position and color
    self:UpdatePosition()
    if config.PaintStatusBarChrome then
        config:PaintStatusBarChrome(self.castBar)
    end
    self:UpdateColor()
    
    -- Re-register events if needed
    if self.castBar and not self.castBar.eventsRegistered then
        self:SetupEvents()
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

function CastBar:Initialize()
    local config = ConsoleUI.config
    if not config then return end
    
    -- Only create if enabled
    if config:Get("castbarEnabled") then
        self:CreateBar()
        self:UpdatePosition()
    end
    
    ConsoleUI_Debug("Cast bar module initialized")
end
