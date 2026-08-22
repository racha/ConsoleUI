--[[
    ConsoleUI - Cast Bar Module
    
    Thin gold strip, red latency tail, name + timer under it.
]]

-- Create the castbar module namespace
if ConsoleUI.castbar == nil then
    ConsoleUI.castbar = {}
end

local CastBar = ConsoleUI.castbar

-- ============================================================================
-- Constants
-- ============================================================================

CastBar.MIN_HEIGHT = 6
CastBar.INFO_HEIGHT = 14
CastBar.FILL_TEX = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
CastBar.SPARK_TEX = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\CastSpark"
CastBar.LAG_R = 0.77
CastBar.LAG_G = 0.19
CastBar.LAG_B = 0.19

-- ============================================================================
-- Helper Functions
-- ============================================================================

function CastBar.FormatTimer(elapsed, duration)
    elapsed = tonumber(elapsed) or 0
    duration = tonumber(duration) or 0
    if duration <= 0 then
        return ""
    end
    return string.format("%.1f / %.2f", elapsed, duration)
end

function CastBar.LatencyMs()
    if not GetNetStats then
        return 0
    end
    local _, _, latency = GetNetStats()
    return tonumber(latency) or 0
end

function CastBar:ProgressHeight()
    local config = ConsoleUI.config
    local h = 6
    if config and config.Get then
        h = config:Get("castbarHeight") or 6
    end
    return math.max(CastBar.MIN_HEIGHT, h)
end

function CastBar:HostHeight()
    return self:ProgressHeight() + CastBar.INFO_HEIGHT
end

function CastBar:SetSpellIcon(bar, spellName)
    if bar and bar.icon then
        bar.icon:Hide()
    end
end

function CastBar:ApplyFillColor(b)
    if not b or not b.bar then
        return
    end
    local config = ConsoleUI.config
    if not config then
        return
    end
    local r, g, bb
    if b.channeling then
        r = config:Get("castbarChannelColorR") or 1.00
        g = config:Get("castbarChannelColorG") or 0.82
        bb = config:Get("castbarChannelColorB") or 0.18
    else
        r = config:Get("castbarColorR") or 1.00
        g = config:Get("castbarColorG") or 0.82
        bb = config:Get("castbarColorB") or 0.18
    end
    b.cuiFillR = r
    b.cuiFillG = g
    b.cuiFillB = bb
    b.bar:SetStatusBarColor(r, g, bb, 1.0)
    if b.cuiCastFill then
        b.cuiCastFill:SetVertexColor(r, g, bb, 1)
    end
end

function CastBar:EnsureFill(b)
    if not b or not b.bar then
        return
    end
    if ConsoleUI.config and ConsoleUI.config.HideStockFill then
        ConsoleUI.config:HideStockFill(b.bar)
    end
    if b.cuiWatchFill then
        b.cuiWatchFill:Hide()
    end
    -- Fill must live on the strip. A texture on the host paints under
    -- cuiCastEmpty and the bar looks empty except for the spark.
    local strip = b.cuiStrip or b.bar
    if b.cuiCastFill and b.cuiCastFill.GetParent and b.cuiCastFill:GetParent() ~= strip then
        b.cuiCastFill:Hide()
        b.cuiCastFill = nil
    end
    if not b.cuiCastFill then
        local fill = strip:CreateTexture(nil, "ARTWORK")
        fill:SetTexture(CastBar.FILL_TEX)
        fill:SetTexCoord(0, 1, 0, 1)
        fill:SetVertexColor(1.00, 0.82, 0.18, 1)
        fill:Hide()
        b.cuiCastFill = fill
    end
    b.cuiCastFill:SetTexture(CastBar.FILL_TEX)
    b.cuiCastFill:SetDrawLayer("ARTWORK")
    b.cuiCastFill:ClearAllPoints()
    b.cuiCastFill:SetPoint("TOPLEFT", strip, "TOPLEFT", 1, -1)
    b.cuiCastFill:SetPoint("BOTTOMLEFT", strip, "BOTTOMLEFT", 1, 1)
end

function CastBar:SyncFill(b, pct)
    self:EnsureFill(b)
    if not b or not b.cuiCastFill then
        return
    end
    if ConsoleUI.config and ConsoleUI.config.HideStockFill then
        ConsoleUI.config:HideStockFill(b.bar)
    end
    pct = tonumber(pct) or 0
    if pct < 0 then
        pct = 0
    end
    if pct > 1 then
        pct = 1
    end
    local full = 0
    if b.cuiStrip and b.cuiStrip.GetWidth then
        full = (b.cuiStrip:GetWidth() or 0) - 2
    end
    if full < 1 and b.width then
        full = (b.width or 0) - 2
    end
    local width = full * pct
    local fill = b.cuiCastFill
    if width < 1 then
        fill:Hide()
        return
    end
    -- Stretch only. SetTexCoord(0, pct) is the choppy watch-bar crop.
    fill:SetTexCoord(0, 1, 0, 1)
    fill:SetWidth(width)
    fill:SetVertexColor(
        b.cuiFillR or 1.00,
        b.cuiFillG or 0.82,
        b.cuiFillB or 0.18,
        1
    )
    fill:Show()
end

function CastBar:EnsureLag(b)
    if not b or not b.bar then
        return
    end
    local strip = b.cuiStrip or b.bar
    if b.cuiCastLag and b.cuiCastLag.GetParent and b.cuiCastLag:GetParent() ~= strip then
        b.cuiCastLag:Hide()
        b.cuiCastLag = nil
    end
    if not b.cuiCastLag then
        local lag = strip:CreateTexture(nil, "ARTWORK")
        lag:Hide()
        b.cuiCastLag = lag
    end
    b.cuiCastLag:SetTexture(CastBar.FILL_TEX)
    b.cuiCastLag:SetVertexColor(CastBar.LAG_R, CastBar.LAG_G, CastBar.LAG_B, 1)
    b.cuiCastLag:ClearAllPoints()
    b.cuiCastLag:SetPoint("TOPRIGHT", strip, "TOPRIGHT", -1, -1)
    b.cuiCastLag:SetPoint("BOTTOMRIGHT", strip, "BOTTOMRIGHT", -1, 1)
end

function CastBar:SyncLag(b, duration)
    self:EnsureLag(b)
    if not b or not b.cuiCastLag then
        return
    end
    duration = tonumber(duration) or 0
    local lagSec = CastBar.LatencyMs() / 1000
    local pct = 0
    if duration > 0 then
        pct = lagSec / duration
    end
    if pct < 0 then
        pct = 0
    end
    if pct > 0.45 then
        pct = 0.45
    end
    local full = 0
    if b.cuiStrip and b.cuiStrip.GetWidth then
        full = (b.cuiStrip:GetWidth() or 0) - 2
    end
    if full < 1 and b.width then
        full = (b.width or 0) - 2
    end
    local width = full * pct
    if width < 1 then
        b.cuiCastLag:Hide()
        return
    end
    b.cuiCastLag:SetWidth(width)
    b.cuiCastLag:Show()
end

function CastBar:HideWatchChrome(b)
    if b.cuiNotch then
        b.cuiNotch:Hide()
    end
    if b.cuiTicks then
        local i
        for i = 1, 19 do
            if b.cuiTicks[i] then
                b.cuiTicks[i]:Hide()
            end
        end
    end
    if b.cuiPips then
        local i
        for i = 1, 3 do
            if b.cuiPips[i] then
                b.cuiPips[i]:Hide()
            end
        end
    end
    if b.cuiEdgeT then b.cuiEdgeT:Hide() end
    if b.cuiEdgeB then b.cuiEdgeB:Hide() end
    if b.cuiEdgeL then b.cuiEdgeL:Hide() end
    if b.cuiEdgeR then b.cuiEdgeR:Hide() end
end

function CastBar:FontSize(height)
    height = height or CastBar.INFO_HEIGHT
    return math.max(10, math.min(12, math.floor(height)))
end

function CastBar:LayoutChrome(b)
    if not b then
        return
    end
    local progressH = self:ProgressHeight()
    local hostW = b.width or 400
    local hostH = progressH + CastBar.INFO_HEIGHT
    local rim = 1
    b.height = progressH
    if b.SetWidth then
        b:SetWidth(hostW)
        b:SetHeight(hostH)
    end
    if b.SetBackdrop then
        b:SetBackdrop(nil)
    end
    if b.cuiTrack then
        b.cuiTrack:Hide()
    end
    if b.cuiCastLeft then
        b.cuiCastLeft:Hide()
    end
    if b.cuiCastRight then
        b.cuiCastRight:Hide()
    end
    if b.cuiCastMid then
        b.cuiCastMid:Hide()
    end
    if b.cuiCastTrack then
        b.cuiCastTrack:Hide()
    end
    if b.cuiPlateTex then
        b.cuiPlateTex:Hide()
    end

    if not b.cuiStrip then
        b.cuiStrip = CreateFrame("Frame", nil, b)
    end
    b.cuiStrip:ClearAllPoints()
    b.cuiStrip:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    b.cuiStrip:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, 0)
    b.cuiStrip:SetHeight(progressH)
    b.cuiStrip:Show()

    if not b.cuiCastBorder then
        b.cuiCastBorder = b.cuiStrip:CreateTexture(nil, "BACKGROUND")
    end
    b.cuiCastBorder:SetTexture(CastBar.FILL_TEX)
    b.cuiCastBorder:ClearAllPoints()
    b.cuiCastBorder:SetAllPoints(b.cuiStrip)
    b.cuiCastBorder:SetVertexColor(0, 0, 0, 1)
    b.cuiCastBorder:Show()

    if not b.cuiCastEmpty then
        b.cuiCastEmpty = b.cuiStrip:CreateTexture(nil, "BORDER")
    end
    b.cuiCastEmpty:SetTexture(CastBar.FILL_TEX)
    b.cuiCastEmpty:ClearAllPoints()
    b.cuiCastEmpty:SetPoint("TOPLEFT", b.cuiStrip, "TOPLEFT", rim, -rim)
    b.cuiCastEmpty:SetPoint("BOTTOMRIGHT", b.cuiStrip, "BOTTOMRIGHT", -rim, rim)
    b.cuiCastEmpty:SetVertexColor(0.04, 0.04, 0.05, 1)
    b.cuiCastEmpty:Show()

    if b.bar then
        b.bar:ClearAllPoints()
        b.bar:SetPoint("TOPLEFT", b.cuiStrip, "TOPLEFT", rim, -rim)
        b.bar:SetPoint("BOTTOMRIGHT", b.cuiStrip, "BOTTOMRIGHT", -rim, rim)
    end

    if not b.cuiPlate then
        b.cuiPlate = CreateFrame("Frame", nil, b)
    end
    b.cuiPlate:ClearAllPoints()
    b.cuiPlate:SetPoint("TOPLEFT", b, "TOPLEFT", 0, -progressH)
    b.cuiPlate:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    b.cuiPlate:Show()
end

function CastBar:EnsureLayers(b)
    if not b then
        return
    end
    self:LayoutChrome(b)
    local labelsParent = b.cuiPlate or b
    if not b.cuiText then
        local textFrame = CreateFrame("Frame", nil, b)
        if ConsoleUI.config and ConsoleUI.config.StackAbove then
            ConsoleUI.config:StackAbove(textFrame, labelsParent)
        end
        b.cuiText = textFrame
    end
    b.cuiText:ClearAllPoints()
    b.cuiText:SetAllPoints(labelsParent)
    local labels = b.cuiText
    if b.text and b.text.GetParent and b.text:GetParent() ~= labels then
        b.text:Hide()
        b.text = nil
    end
    if b.timer and b.timer.GetParent and b.timer:GetParent() ~= labels then
        b.timer:Hide()
        b.timer = nil
    end
    local fontSize = self:FontSize(CastBar.INFO_HEIGHT)
    -- 1.12: inherit a font object, then SetFont, then SetText. Bare
    -- CreateFontString has no font; SetText errors and aborts init.
    if not b.timer then
        b.timer = labels:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        b.timer:SetJustifyH("RIGHT")
        b.timer:SetTextColor(1, 1, 1, 1)
    end
    b.timer:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
    b.timer:ClearAllPoints()
    b.timer:SetPoint("RIGHT", labels, "RIGHT", -8, 0)
    if not b.text then
        b.text = labels:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        b.text:SetJustifyH("LEFT")
        b.text:SetTextColor(1, 1, 1, 1)
    end
    b.text:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
    b.text:ClearAllPoints()
    b.text:SetPoint("LEFT", labels, "LEFT", 8, 0)
    b.text:SetPoint("RIGHT", b.timer, "LEFT", -8, 0)
    if b.bar then
        if b.spark and b.spark.GetParent and b.spark:GetParent() ~= b.bar then
            b.spark:Hide()
            b.spark = nil
        end
        if not b.spark then
            b.spark = b.bar:CreateTexture(nil, "OVERLAY")
            b.spark:SetTexture(CastBar.SPARK_TEX)
            b.spark:SetWidth(8)
            b.spark:SetBlendMode("ADD")
            b.spark:Hide()
        end
        b.spark:SetTexture(CastBar.SPARK_TEX)
        b.spark:SetWidth(8)
        b.spark:SetHeight(16)
    end
    if b.icon then
        b.icon:Hide()
    end
    self:EnsureFill(b)
    self:EnsureLag(b)
end

function CastBar:PaintLook(b)
    if not b then
        return
    end
    self:HideWatchChrome(b)
    self:LayoutChrome(b)
    if b.bar then
        if ConsoleUI.config and ConsoleUI.config.PaintCastFill then
            ConsoleUI.config:PaintCastFill(b.bar)
        elseif ConsoleUI.config and ConsoleUI.config.HideStockFill then
            ConsoleUI.config:HideStockFill(b.bar)
        end
        self:EnsureFill(b)
        self:ApplyFillColor(b)
    end
    self:EnsureLayers(b)
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
    
    local barWidth = config:Get("xpBarWidth") or 400
    local barHeight = self:ProgressHeight()
    
    b.width = barWidth
    b.height = barHeight
    
    b:SetWidth(barWidth)
    b:SetHeight(self:HostHeight())
    b:SetFrameStrata("MEDIUM")
    
    -- Fill lives in the octagon; chrome is LayoutChrome (not XP watch ticks).
    b.bar = b.bar or CreateFrame("StatusBar", nil, b)
    if not b.cuiFillStacked and config.StackAbove then
        config:StackAbove(b.bar, b)
        b.cuiFillStacked = true
    end
    
    local colorR = config:Get("castbarColorR") or 1.00
    local colorG = config:Get("castbarColorG") or 0.82
    local colorB = config:Get("castbarColorB") or 0.18
    b.bar:SetStatusBarColor(colorR, colorG, colorB, 1.0)
    b.bar:SetOrientation("HORIZONTAL")
    b.bar:SetMinMaxValues(0, 100)
    b.bar:SetValue(0)
    b.bar:Show()
    
    self:PaintLook(b)

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
            
            CastBar:EnsureLayers(this)
            if this.text then
                this.text:SetText(this.spellName)
            end
            CastBar:SetSpellIcon(this, this.spellName)
            CastBar:ApplyFillColor(this)
            CastBar:SyncFill(this, 0)
            CastBar:SyncLag(this, castTime / 1000)
            
            if this.spark then
                this.spark:Show()
            end
            this:Show()
            CastBar:UpdatePosition()
            
        elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
            this.casting = false
            this.channeling = false
            if this.spark then
                this.spark:Hide()
            end
            if this.icon then
                this.icon:Hide()
            end
            this:Hide()
            
        elseif event == "SPELLCAST_DELAYED" then
            -- arg1 = delay amount (ms)
            local delayAmount = tonumber(arg1)
            if this.casting and delayAmount and this.startTime and this.maxValue then
                this.startTime = this.startTime + (delayAmount / 1000)
                this.maxValue = this.maxValue + (delayAmount / 1000)
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
            
            CastBar:EnsureLayers(this)
            if this.text then
                this.text:SetText(this.spellName)
            end
            CastBar:SetSpellIcon(this, this.spellName)
            CastBar:ApplyFillColor(this)
            CastBar:SyncFill(this, 1)
            CastBar:SyncLag(this, channelTime / 1000)
            
            if this.spark then
                this.spark:Show()
            end
            this:Show()
            CastBar:UpdatePosition()
            
        elseif event == "SPELLCAST_CHANNEL_UPDATE" then
            -- arg1 = new channel time remaining (ms)
            ConsoleUI_Debug("SPELLCAST_CHANNEL_UPDATE: arg1=" .. tostring(arg1))
            local newTimeRemaining = tonumber(arg1)
            if this.channeling and newTimeRemaining and this.endTime and this.startTime then
                local origDuration = this.endTime - this.startTime
                if origDuration > 0 then
                    this.endTime = GetTime() + (newTimeRemaining / 1000)
                    this.startTime = this.endTime - origDuration
                    CastBar:SyncFill(this, (newTimeRemaining / 1000) / origDuration)
                end
            end
            
        elseif event == "SPELLCAST_CHANNEL_STOP" then
            ConsoleUI_Debug("SPELLCAST_CHANNEL_STOP received")
            this.casting = false
            this.channeling = false
            if this.spark then
                this.spark:Hide()
            end
            if this.icon then
                this.icon:Hide()
            end
            this:Hide()
            
        elseif event == "PLAYER_ENTERING_WORLD" then
            CastBar:UpdatePosition()
        end
    end)
    
    -- OnUpdate for smooth progress (following Blizzard's approach)
    bar:SetScript("OnUpdate", function()
        if not this.bar then
            return
        end
        if this.casting then
            -- Safety check for required values
            if not this.maxValue or not this.startTime then
                this.casting = false
                if this.spark then
                    this.spark:Hide()
                end
                this:Hide()
                return
            end
            
            local status = GetTime()
            if status > this.maxValue then
                status = this.maxValue
            end
            local duration = this.maxValue - this.startTime
            local pct = 0
            if duration > 0 then
                pct = (status - this.startTime) / duration
            end
            CastBar:SyncFill(this, pct)
            CastBar:SyncLag(this, duration)
            local barInnerWidth = this.bar:GetWidth() or 0
            if this.spark then
                this.spark:ClearAllPoints()
                this.spark:SetPoint("CENTER", this.bar, "LEFT", pct * barInnerWidth, 0)
            end
            if this.timer then
                this.timer:SetText(CastBar.FormatTimer(status - this.startTime, duration))
            end
            
        elseif this.channeling then
            -- Safety check for required values
            if not this.endTime or not this.startTime then
                this.channeling = false
                if this.spark then
                    this.spark:Hide()
                end
                this:Hide()
                return
            end
            
            local time = GetTime()
            if time > this.endTime then
                time = this.endTime
            end
            if time >= this.endTime then
                this.channeling = false
                if this.spark then
                    this.spark:Hide()
                end
                this:Hide()
                return
            end
            
            local duration = this.endTime - this.startTime
            local pct = 0
            if duration > 0 then
                pct = (this.endTime - time) / duration
            end
            CastBar:SyncFill(this, pct)
            CastBar:SyncLag(this, duration)
            local barInnerWidth = this.bar:GetWidth() or 0
            if this.spark then
                this.spark:ClearAllPoints()
                this.spark:SetPoint("CENTER", this.bar, "LEFT", pct * barInnerWidth, 0)
            end
            if this.timer then
                this.timer:SetText(CastBar.FormatTimer(time - this.startTime, duration))
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
    local barHeight = self:ProgressHeight()
    local hostH = self:HostHeight()
    local gap = 5
    
    local stackHeight = 0
    local xpbar = ConsoleUI.xpbar
    if xpbar and xpbar.StackTop then
        stackHeight = xpbar:StackTop()
    end
    
    local ox = config:HudOffset("castbarOffsetX", 0)
    local oy = config:HudOffset("castbarOffsetY", 16)
    local castBarBottomY = stackHeight + gap + oy
    
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", ox, castBarBottomY)
    bar:SetWidth(barWidth)
    bar:SetHeight(hostH)
    
    bar.width = barWidth
    bar.height = barHeight
    
    -- Layout only. PaintLook resets the StatusBar texture and flashes the fill.
    self:EnsureLayers(bar)
    self:ApplyFillColor(bar)
end

-- ============================================================================
-- Color Update
-- ============================================================================

function CastBar:UpdateColor()
    self:ApplyFillColor(self.castBar)
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
    self:PaintLook(self.castBar)
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
