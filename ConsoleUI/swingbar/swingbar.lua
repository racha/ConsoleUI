--[[
    ConsoleUI - Swing Timer

    Cast-bar styled melee and ranged swing timers for the Vanilla 1.12 API.
    Dual-wield bars share one anchor and meet toward the centre with a gap.
    Ranged attacks use fixed Draw, Shoot, and Cooldown segments.
]]

ConsoleUI.swingbar = ConsoleUI.swingbar or {}
local SwingBar = ConsoleUI.swingbar

SwingBar.FILL_TEX = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
SwingBar.SPARK_TEX = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\CastSpark"
SwingBar.INFO_HEIGHT = 14
SwingBar.MIN_HEIGHT = 3
SwingBar.MIN_WIDTH = 120
SwingBar.RANGED_DRAW_TIME = 0.50
SwingBar.RANGED_FIRE_TIME = 0.08
SwingBar.RANGED_DRAW_SHARE = 0.18
SwingBar.RANGED_FIRE_SHARE = 0.04
SwingBar.RANGED_SEGMENT_GAP = 3
SwingBar.RANGED_CANCEL_FLASH = 0.18
SwingBar.RANGED_SHOT_FLASH = 0.16

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then value = low end
    if value > high then value = high end
    return value
end

local function HasFlag(value, flag)
    value = tonumber(value) or 0
    return math.mod(math.floor(value / flag), 2) == 1
end

local function ItemName(slot, fallback)
    if GetInventoryItemLink then
        local link = GetInventoryItemLink("player", slot)
        if link then
            local _, _, name = string.find(link, "%[(.-)%]")
            if name and name ~= "" then return name end
        end
    end
    return fallback
end

local function SetShown(region, shown)
    if shown then
        if not region:IsShown() then region:Show() end
    elseif region:IsShown() then
        region:Hide()
    end
end

local function UpdateHandler()
    SwingBar:OnUpdate(arg1)
end

-- Keep animation at full frame rate, but only submit text when a displayed
-- digit changes. Use the formatter's rounding (including exact half-tenths).
local function SetTimerText(lane, label, elapsed, duration)
    local elapsedText = elapsed and string.format("%.1f", elapsed)
    if lane.textLabel == label and lane.elapsedText == elapsedText and lane.textDuration == duration then return end
    lane.textLabel, lane.elapsedText, lane.textDuration = label, elapsedText, duration
    if elapsed then
        if label == "" then
            lane.timer:SetText(string.format("%.1f / %.2f", elapsed, duration))
        else
            lane.timer:SetText(string.format("%s %.1f / %.2f", label, elapsed, duration))
        end
    else
        lane.timer:SetText(label)
    end
end

function SwingBar:Config(key, fallback)
    if ConsoleUI.config and ConsoleUI.config.Get then
        local value = ConsoleUI.config:Get(key)
        if value ~= nil then return value end
    end
    return fallback
end

function SwingBar:ProgressHeight()
    return Clamp(self:Config("swingBarHeight", 4), self.MIN_HEIGHT, 40)
end

function SwingBar:InfoVisible()
    return self:Config("swingBarShowMainLabel", true)
        or self:Config("swingBarShowOffLabel", true)
        or self:Config("swingBarShowRangedLabel", true)
        or self:Config("swingBarShowTimer", true)
end

function SwingBar:HostHeight()
    local height = self:ProgressHeight()
    if self:InfoVisible() then height = height + self.INFO_HEIGHT end
    return height
end

function SwingBar:NewTimer(kind)
    return { kind = kind, speed = 0, startTime = 0, endTime = 0, active = false }
end

function SwingBar:CreateLane(parent, reverse)
    local lane = CreateFrame("Frame", nil, parent)
    lane.reverse = reverse

    lane.strip = CreateFrame("Frame", nil, lane)
    lane.border = lane.strip:CreateTexture(nil, "BACKGROUND")
    lane.border:SetTexture(self.FILL_TEX)
    lane.border:SetVertexColor(0, 0, 0, 1)
    lane.border:SetAllPoints(lane.strip)

    lane.empty = lane.strip:CreateTexture(nil, "BORDER")
    lane.empty:SetTexture(self.FILL_TEX)
    lane.empty:SetVertexColor(0.04, 0.04, 0.05, 1)
    lane.empty:SetPoint("TOPLEFT", lane.strip, "TOPLEFT", 1, -1)
    lane.empty:SetPoint("BOTTOMRIGHT", lane.strip, "BOTTOMRIGHT", -1, 1)

    lane.fill = lane.strip:CreateTexture(nil, "ARTWORK")
    lane.fill:SetTexture(self.FILL_TEX)
    lane.fill:SetTexCoord(0, 1, 0, 1)

    lane.spark = lane.strip:CreateTexture(nil, "OVERLAY")
    lane.spark:SetTexture(self.SPARK_TEX)
    lane.spark:SetWidth(8)
    lane.spark:SetHeight(16)
    lane.spark:SetBlendMode("ADD")

    lane.label = lane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lane.label:SetFont("Fonts\\FRIZQT__.TTF", 10)
    lane.label:SetJustifyH("LEFT")
    lane.label:SetTextColor(1, 1, 1, 1)

    lane.timer = lane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lane.timer:SetFont("Fonts\\FRIZQT__.TTF", 10)
    lane.timer:SetJustifyH("RIGHT")
    lane.timer:SetTextColor(1, 1, 1, 1)
    return lane
end

function SwingBar:CreateRangedSegment(parent)
    local segment = CreateFrame("Frame", nil, parent)
    segment.border = segment:CreateTexture(nil, "BACKGROUND")
    segment.border:SetTexture(self.FILL_TEX)
    segment.border:SetVertexColor(0, 0, 0, 1)
    segment.border:SetAllPoints(segment)
    segment.empty = segment:CreateTexture(nil, "BORDER")
    segment.empty:SetTexture(self.FILL_TEX)
    segment.empty:SetVertexColor(0.04, 0.04, 0.05, 1)
    segment.empty:SetPoint("TOPLEFT", segment, "TOPLEFT", 1, -1)
    segment.empty:SetPoint("BOTTOMRIGHT", segment, "BOTTOMRIGHT", -1, 1)
    segment.fill = segment:CreateTexture(nil, "ARTWORK")
    segment.fill:SetTexture(self.FILL_TEX)
    segment.fill:SetPoint("TOPLEFT", segment, "TOPLEFT", 1, -1)
    segment.fill:SetPoint("BOTTOMLEFT", segment, "BOTTOMLEFT", 1, 1)
    segment.fill:Hide()
    return segment
end

function SwingBar:CreateRangedLane(parent)
    local lane = CreateFrame("Frame", nil, parent)
    lane.draw = self:CreateRangedSegment(lane)
    lane.fire = self:CreateRangedSegment(lane)
    lane.cooldown = self:CreateRangedSegment(lane)

    lane.spark = lane:CreateTexture(nil, "OVERLAY")
    lane.spark:SetTexture(self.SPARK_TEX)
    lane.spark:SetWidth(8)
    lane.spark:SetHeight(16)
    lane.spark:SetBlendMode("ADD")

    lane.label = lane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lane.label:SetFont("Fonts\\FRIZQT__.TTF", 10)
    lane.label:SetJustifyH("LEFT")
    lane.label:SetTextColor(1, 1, 1, 1)

    lane.timer = lane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lane.timer:SetFont("Fonts\\FRIZQT__.TTF", 10)
    lane.timer:SetJustifyH("RIGHT")
    lane.timer:SetTextColor(1, 1, 1, 1)
    return lane
end

function SwingBar:CreateBar()
    if self.frame then return self.frame end
    local frame = CreateFrame("Frame", "ConsoleUISwingBar", UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetAlpha(0)
    frame:Hide()
    frame.left = self:CreateLane(frame, false)
    frame.right = self:CreateLane(frame, true)
    frame.single = self:CreateLane(frame, false)
    frame.ranged = self:CreateRangedLane(frame)
    self.frame = frame
    self.main = self:NewTimer("main")
    self.off = self:NewTimer("off")
    self.ranged = self:NewTimer("ranged")
    self.fadeTarget = 0
    self.inCombat = false
    self.meleeActive = false
    self.rangedActive = false
    self:Layout()
    return frame
end

function SwingBar:LayoutLane(lane, width, height)
    lane.innerWidth = math.max(1, width - 2)
    lane.fillWidth = nil
    lane.sparkTarget = nil
    lane:SetWidth(width)
    lane:SetHeight(self:HostHeight())
    lane.strip:ClearAllPoints()
    lane.strip:SetPoint("TOPLEFT", lane, "TOPLEFT", 0, 0)
    lane.strip:SetPoint("TOPRIGHT", lane, "TOPRIGHT", 0, 0)
    lane.strip:SetHeight(height)
    lane.fill:ClearAllPoints()
    if lane.reverse then
        lane.fill:SetPoint("TOPRIGHT", lane.strip, "TOPRIGHT", -1, -1)
        lane.fill:SetPoint("BOTTOMRIGHT", lane.strip, "BOTTOMRIGHT", -1, 1)
    else
        lane.fill:SetPoint("TOPLEFT", lane.strip, "TOPLEFT", 1, -1)
        lane.fill:SetPoint("BOTTOMLEFT", lane.strip, "BOTTOMLEFT", 1, 1)
    end
    lane.label:ClearAllPoints()
    lane.label:SetPoint("TOPLEFT", lane.strip, "BOTTOMLEFT", 8, -1)
    lane.label:SetPoint("RIGHT", lane.timer, "LEFT", -6, 0)
    lane.timer:ClearAllPoints()
    lane.timer:SetPoint("TOPRIGHT", lane.strip, "BOTTOMRIGHT", -8, -1)
end

function SwingBar:LayoutRangedLane(lane, width, height, gap)
    local available = math.max(12, width - gap * 2)
    local drawWidth = math.max(3, math.floor(available * self.RANGED_DRAW_SHARE))
    local fireWidth = math.max(3, math.floor(available * self.RANGED_FIRE_SHARE))
    local cooldownWidth = math.max(3, available - drawWidth - fireWidth)

    lane:SetWidth(width)
    lane:SetHeight(self:HostHeight())
    lane.draw:ClearAllPoints()
    lane.draw:SetPoint("TOPLEFT", lane, "TOPLEFT", 0, 0)
    lane.draw:SetWidth(drawWidth)
    lane.draw:SetHeight(height)
    lane.fire:ClearAllPoints()
    lane.fire:SetPoint("TOPLEFT", lane.draw, "TOPRIGHT", gap, 0)
    lane.fire:SetWidth(fireWidth)
    lane.fire:SetHeight(height)
    lane.cooldown:ClearAllPoints()
    lane.cooldown:SetPoint("TOPLEFT", lane.fire, "TOPRIGHT", gap, 0)
    lane.cooldown:SetWidth(cooldownWidth)
    lane.cooldown:SetHeight(height)
    lane.draw.innerWidth = math.max(1, drawWidth - 2)
    lane.fire.innerWidth = math.max(1, fireWidth - 2)
    lane.cooldown.innerWidth = math.max(1, cooldownWidth - 2)
    lane.draw.fillWidth, lane.fire.fillWidth, lane.cooldown.fillWidth = nil, nil, nil
    lane.sparkTarget = nil

    lane.label:ClearAllPoints()
    lane.label:SetPoint("TOPLEFT", lane, "TOPLEFT", 8, -height - 1)
    lane.label:SetPoint("RIGHT", lane.timer, "LEFT", -6, 0)
    lane.timer:ClearAllPoints()
    lane.timer:SetPoint("TOPRIGHT", lane, "TOPRIGHT", -8, -height - 1)
end

function SwingBar:Layout()
    if not self.frame then return end
    local width = Clamp(self:Config("swingBarWidth", 400), self.MIN_WIDTH, 2000)
    local height = self:ProgressHeight()
    local gap = Clamp(self:Config("swingBarGap", 8), 0, 40)
    if gap > width - 40 then gap = width - 40 end
    local half = (width - gap) / 2
    local hostH = self:HostHeight()
    local frame = self.frame
    frame:SetWidth(width)
    frame:SetHeight(hostH)
    self:LayoutLane(frame.left, half, height)
    self:LayoutLane(frame.right, half, height)
    self:LayoutLane(frame.single, width, height)
    self:LayoutRangedLane(frame.ranged, width, height, self.RANGED_SEGMENT_GAP)
    frame.left:ClearAllPoints()
    frame.left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.right:ClearAllPoints()
    frame.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.single:ClearAllPoints()
    frame.single:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.ranged:ClearAllPoints()
    frame.ranged:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    self:UpdatePosition()
    self:UpdateColor()
    self:UpdateLabels()
end

function SwingBar:UpdatePosition()
    if not self.frame then return end
    local config = ConsoleUI.config
    local stackHeight = 0
    if ConsoleUI.xpbar and ConsoleUI.xpbar.StackTop then
        stackHeight = ConsoleUI.xpbar:StackTop()
    end
    local reserved = 5
    if config and config:Get("castbarEnabled") ~= false then
        local castH = 20
        if ConsoleUI.castbar and ConsoleUI.castbar.HostHeight then
            castH = ConsoleUI.castbar:HostHeight()
        end
        reserved = reserved + (config:HudOffset("castbarOffsetY", 16) or 16) + castH + 5
    end
    local ox = config and config:HudOffset("swingBarOffsetX", 0) or 0
    local oy = config and config:HudOffset("swingBarOffsetY", 0) or 0
    local y = stackHeight + reserved + oy
    if self.positionX == ox and self.positionY == y then return end
    self.positionX, self.positionY = ox, y
    self.frame:ClearAllPoints()
    self.frame:SetPoint("BOTTOM", UIParent, "BOTTOM", ox, y)
end

function SwingBar:UpdateColor()
    if not self.frame then return end
    local r = Clamp(self:Config("swingBarColorR", 1), 0, 1)
    local g = Clamp(self:Config("swingBarColorG", 0.82), 0, 1)
    local b = Clamp(self:Config("swingBarColorB", 0.18), 0, 1)
    self.colorR, self.colorG, self.colorB = r, g, b
    self.frame.ranged.cancelColor = nil
    self.frame.ranged.shotColor = nil
    local lanes = { self.frame.left, self.frame.right, self.frame.single }
    local i
    for i = 1, 3 do lanes[i].fill:SetVertexColor(r, g, b, 1) end
    -- Ranged stages use the same selected color. Red and white are temporary
    -- state flashes for an interrupted draw and a released projectile.
    self.frame.ranged.draw.fill:SetVertexColor(r, g, b, 1)
    self.frame.ranged.fire.fill:SetVertexColor(r, g, b, 1)
    self.frame.ranged.cooldown.fill:SetVertexColor(r, g, b, 1)
end

function SwingBar:UpdateSpeeds(restart)
    local mainSpeed, offSpeed = 0, 0
    if UnitAttackSpeed then mainSpeed, offSpeed = UnitAttackSpeed("player") end
    local rangedSpeed = 0
    if UnitRangedDamage then rangedSpeed = UnitRangedDamage("player") end
    mainSpeed = tonumber(mainSpeed) or 0
    offSpeed = tonumber(offSpeed) or 0
    rangedSpeed = tonumber(rangedSpeed) or 0
    local now = GetTime()
    local timers = { self.main, self.off, self.ranged }
    local speeds = { mainSpeed, offSpeed, rangedSpeed }
    local i
    for i = 1, 3 do
        local timer = timers[i]
        local speed = speeds[i]
        if speed > 0 then
            timer.speed = speed
            if restart and timer.active then
                timer.startTime = now
                timer.endTime = now + speed
            elseif timer.active then
                timer.endTime = timer.startTime + speed
            end
        else
            timer.speed = 0
            timer.active = false
        end
    end
end

function SwingBar:UpdateLabels()
    if not self.frame then return end
    local showTimer = self:Config("swingBarShowTimer", true)
    local labels = {
        { self.frame.left, self:Config("swingBarShowMainLabel", true), ItemName(16, "Main Hand") },
        { self.frame.right, self:Config("swingBarShowOffLabel", true), ItemName(17, "Off Hand") },
        { self.frame.single, self:Config("swingBarShowMainLabel", true), ItemName(16, "Main Hand") },
        { self.frame.ranged, self:Config("swingBarShowRangedLabel", true), ItemName(18, "Ranged") },
    }
    local i
    for i = 1, 4 do
        labels[i][1].label:SetText(labels[i][3])
        if labels[i][2] then labels[i][1].label:Show() else labels[i][1].label:Hide() end
        if showTimer then labels[i][1].timer:Show() else labels[i][1].timer:Hide() end
    end
end

function SwingBar:StartTimer(timer, now)
    if not timer or not timer.speed or timer.speed <= 0 then return end
    now = now or GetTime()
    timer.startTime = now
    timer.endTime = now + timer.speed
    timer.active = true
end

function SwingBar:StartMelee()
    self.meleeActive = true
    self:UpdateSpeeds(false)
    local now = GetTime()
    self:StartTimer(self.main, now)
    if self.off.speed > 0 then self:StartTimer(self.off, now) end
    self:UpdateLabels()
    self:RefreshVisibility()
end

function SwingBar:StopMelee()
    self.meleeActive = false
    self.main.active = false
    self.off.active = false
    self:RefreshVisibility()
end

function SwingBar:RecordMeleeSwing(offhand)
    if not self.meleeActive then self:StartMelee() end
    local now = GetTime()
    local timer = self.main
    if offhand and self.off.speed > 0 then
        timer = self.off
    elseif self.off.speed > 0 then
        local mainDelta = math.abs(now - (self.main.endTime or now))
        local offDelta = math.abs(now - (self.off.endTime or now))
        if offDelta + 0.02 < mainDelta then timer = self.off end
        if self.lastSwingTimer == timer and now - (self.lastSwingAt or 0) < 0.15 then
            if timer == self.main then timer = self.off else timer = self.main end
        end
    end
    self:StartTimer(timer, now)
    self.lastSwingTimer = timer
    self.lastSwingAt = now
    self:RefreshVisibility()
end

function SwingBar:StartRanged()
    self.rangedActive = true
    self:UpdateSpeeds(false)
    local now = GetTime()
    self.ranged.active = self.ranged.speed > 0
    self.lastRangedShotAt = nil
    self:SetRangedPhase("draw", now)
    self:UpdateLabels()
    self:RefreshVisibility()
end

function SwingBar:StopRanged()
    self.rangedActive = false
    self.ranged.active = false
    self.ranged.phase = nil
    self.lastRangedShotAt = nil
    self:RefreshVisibility()
end

function SwingBar:SnapshotRangedPosition()
    if not GetPlayerMapPosition then
        self.rangedPositionX = nil
        self.rangedPositionY = nil
        return
    end
    self.rangedPositionX, self.rangedPositionY = GetPlayerMapPosition("player")
end

function SwingBar:SetRangedPhase(phase, now)
    if not self.ranged or not self.ranged.active then return end
    now = now or GetTime()
    local duration = self.RANGED_FIRE_TIME
    if phase == "draw" then
        duration = self.RANGED_DRAW_TIME
        self.ranged.drawCancelUntil = nil
        self:SnapshotRangedPosition()
    elseif phase == "cooldown" then
        duration = math.max(0.10, self.ranged.speed - self.RANGED_DRAW_TIME - self.RANGED_FIRE_TIME)
    end
    self.ranged.phase = phase
    self.ranged.phaseStart = now
    self.ranged.phaseEnd = now + duration
    self.ranged.startTime = now
    self.ranged.endTime = now + duration
end

function SwingBar:CancelRangedDraw(now)
    if not self.ranged or not self.ranged.active then return end
    now = now or GetTime()
    self.ranged.phase = "draw"
    self.ranged.drawCancelUntil = now + self.RANGED_CANCEL_FLASH
    self.ranged.phaseStart = self.ranged.drawCancelUntil
    self.ranged.phaseEnd = self.ranged.phaseStart + self.RANGED_DRAW_TIME
    self.ranged.startTime = self.ranged.phaseStart
    self.ranged.endTime = self.ranged.phaseEnd
    -- RangedDrawWasInterrupted already sampled the position this frame.
end

function SwingBar:RecordRangedShot(now, source)
    if not self.rangedActive or not self.ranged.active then return end
    now = now or GetTime()
    if self.lastRangedShotAt and now - self.lastRangedShotAt < 0.12 then return end
    self.lastRangedShotAt = now
    self.lastRangedShotSource = source
    self.ranged.shotFlashUntil = now + self.RANGED_SHOT_FLASH
    self:SetRangedPhase("cooldown", now)
end

function SwingBar:RangedDrawWasInterrupted()
    if not GetPlayerMapPosition or self.rangedPositionX == nil or self.rangedPositionY == nil then return false end
    local x, y = GetPlayerMapPosition("player")
    local moved = x ~= self.rangedPositionX or y ~= self.rangedPositionY
    self.rangedPositionX = x
    self.rangedPositionY = y
    return moved
end

function SwingBar:UpdateRangedState(now)
    local timer = self.ranged
    if not timer or not timer.active or not timer.phase then return end

    if timer.phase == "draw" and self:RangedDrawWasInterrupted() then
        self:CancelRangedDraw(now)
        return
    end

    local guard = 0
    while timer.phaseEnd and now >= timer.phaseEnd and guard < 4 do
        guard = guard + 1
        local boundary = timer.phaseEnd
        if timer.phase == "draw" then
            self:SetRangedPhase("fire", boundary)
        elseif timer.phase == "fire" then
            -- Stock 1.12 has no dedicated Auto Shot release event. Predict the
            -- release at the end of Shoot; exact events correct this point.
            self:RecordRangedShot(boundary, "predicted")
        else
            self:SetRangedPhase("draw", boundary)
        end
    end
end

function SwingBar:HasActiveTimer()
    if self.rangedActive and self.ranged.active and self.ranged.speed > 0 then return true end
    if self.meleeActive and self.main.active and self.main.speed > 0 then return true end
    return false
end

function SwingBar:RefreshVisibility()
    if not self.frame then return end
    local visible = self.enabled and self:HasActiveTimer()
    if visible and self.combatOnly and not self.inCombat then visible = false end
    self.fadeTarget = visible and 1 or 0
    local duration = self.fadeDuration or 0.25
    if visible then
        self:UpdatePosition()
        SetShown(self.frame, true)
    end
    if duration <= 0 then
        self.frame:SetAlpha(self.fadeTarget)
        if not visible then self.frame:Hide() end
    end
    self:SyncUpdater()
end

function SwingBar:SyncUpdater()
    if not self.eventFrame then return end
    -- Keep an active Auto Shot's phases and movement cancellation current,
    -- even if disabled/combat-only hides the art. Re-enabling must not replay
    -- stale cycles. Fully faded idle timers do no per-frame work.
    local rangedStateNeeded = self.rangedActive and self.ranged.active and self.ranged.speed > 0
    local running = (self.enabled and self:HasActiveTimer())
        or rangedStateNeeded
        or (self.frame and (self.frame:GetAlpha() or 0) > 0)
    running = running and true or false
    if self.updaterRunning ~= running then
        self.updaterRunning = running
        if running then self.eventFrame:SetScript("OnUpdate", UpdateHandler)
        else self.eventFrame:SetScript("OnUpdate", nil) end
    end
end

function SwingBar:SetDisplayMode(mode)
    if self.displayMode == mode then return end
    self.displayMode = mode
    SetShown(self.frame.left, mode == "dual")
    SetShown(self.frame.right, mode == "dual")
    SetShown(self.frame.single, mode == "main")
    SetShown(self.frame.ranged, mode == "ranged")
end

function SwingBar:PaintSpark(lane, target, point, offset, shown)
    SetShown(lane.spark, shown)
    if not shown then return end
    if lane.sparkTarget ~= target or lane.sparkPoint ~= point then
        lane.spark:ClearAllPoints()
        lane.sparkTarget, lane.sparkPoint = target, point
        lane.sparkOffset = nil
    end
    if lane.sparkOffset ~= offset then
        lane.spark:SetPoint("CENTER", target, point, offset, 0)
        lane.sparkOffset = offset
    end
end

function SwingBar:SelectMode()
    if self.rangedActive and self.ranged.active and self.ranged.speed > 0 then return "ranged" end
    if self.meleeActive and self.main.active and self.main.speed > 0 then
        if self.off.active and self.off.speed > 0 then return "dual" end
        return "main"
    end
    return nil
end

function SwingBar:PaintLane(lane, timer, now)
    local pct = 0
    if timer and timer.speed and timer.speed > 0 then
        pct = (now - timer.startTime) / timer.speed
    end
    pct = Clamp(pct, 0, 1)
    local inner = lane.innerWidth
    local fillWidth = inner * pct
    SetShown(lane.fill, fillWidth >= 1)
    if fillWidth >= 1 and lane.fillWidth ~= fillWidth then
        lane.fill:SetWidth(fillWidth)
        lane.fillWidth = fillWidth
    end
    self:PaintSpark(lane, lane.strip, lane.reverse and "RIGHT" or "LEFT",
        lane.reverse and (-1 - fillWidth) or (1 + fillWidth), self.showSpark and pct > 0 and pct < 1)
    if self.showTimer and timer and timer.speed > 0 then
        SetTimerText(lane, "", math.min(now - timer.startTime, timer.speed), timer.speed)
    end
end

function SwingBar:SetRangedSegmentProgress(segment, pct)
    pct = Clamp(pct, 0, 1)
    if pct <= 0 then
        SetShown(segment.fill, false)
        return
    end
    local width = math.max(1, segment.innerWidth * pct)
    if segment.fillWidth ~= width then
        segment.fill:SetWidth(width)
        segment.fillWidth = width
    end
    SetShown(segment.fill, true)
end

function SwingBar:PaintRanged(lane, timer, now)
    local phase = timer and timer.phase or "draw"
    local duration = math.max(0.01, (timer.phaseEnd or now) - (timer.phaseStart or now))
    local elapsed = Clamp(now - (timer.phaseStart or now), 0, duration)
    local pct = Clamp(elapsed / duration, 0, 1)
    local cancelled = phase == "draw" and timer.drawCancelUntil and now < timer.drawCancelUntil
    local shotFlash = timer.shotFlashUntil and now < timer.shotFlashUntil
    local drawPct, firePct, cooldownPct = 0, 0, 0
    local segment = lane.draw
    local phaseName = "Draw"

    if phase == "draw" then
        drawPct = cancelled and 1 or pct
    elseif phase == "fire" then
        drawPct = 1
        firePct = pct
        segment = lane.fire
        phaseName = "Shoot"
    else
        drawPct = 1
        firePct = 1
        cooldownPct = pct
        segment = lane.cooldown
        phaseName = "Cooldown"
    end

    self:SetRangedSegmentProgress(lane.draw, drawPct)
    self:SetRangedSegmentProgress(lane.fire, firePct)
    self:SetRangedSegmentProgress(lane.cooldown, cooldownPct)

    cancelled, shotFlash = cancelled and true or false, shotFlash and true or false
    if lane.cancelColor ~= cancelled then
        lane.cancelColor = cancelled
        if cancelled then lane.draw.fill:SetVertexColor(1, 0.08, 0.05, 1)
        else lane.draw.fill:SetVertexColor(self.colorR, self.colorG, self.colorB, 1) end
    end
    if lane.shotColor ~= shotFlash then
        lane.shotColor = shotFlash
        if shotFlash then lane.fire.fill:SetVertexColor(1, 1, 1, 1)
        else lane.fire.fill:SetVertexColor(self.colorR, self.colorG, self.colorB, 1) end
    end

    self:PaintSpark(lane, segment, "LEFT", 1 + segment.innerWidth * pct,
        self.showSpark and not cancelled and pct < 1)

    if self.showTimer then
        if cancelled then
            SetTimerText(lane, "Draw cancelled")
        elseif shotFlash then
            SetTimerText(lane, "Shot")
        else
            SetTimerText(lane, phaseName, elapsed, duration)
        end
    end
end

function SwingBar:OnUpdate(elapsed)
    if not self.frame then return end
    local now = GetTime()
    local mode = self:SelectMode()
    if mode == "ranged" then self:UpdateRangedState(now) end
    -- The hidden state machine may still be needed, but hidden art is not.
    if self.fadeTarget == 0 and (self.frame:GetAlpha() or 0) <= 0 then
        self:SyncUpdater()
        return
    end
    self:SetDisplayMode(mode)
    if mode == "dual" then
        self:PaintLane(self.frame.left, self.main, now)
        self:PaintLane(self.frame.right, self.off, now)
    elseif mode == "main" then
        self:PaintLane(self.frame.single, self.main, now)
    elseif mode == "ranged" then
        self:PaintRanged(self.frame.ranged, self.ranged, now)
    end
    local target = self.fadeTarget or 0
    local alpha = self.frame:GetAlpha() or 0
    local previousAlpha = alpha
    local duration = self.fadeDuration
    if duration <= 0 then
        alpha = target
    else
        local step = (tonumber(elapsed) or 0) / duration
        if alpha < target then alpha = math.min(target, alpha + step) end
        if alpha > target then alpha = math.max(target, alpha - step) end
    end
    if alpha ~= previousAlpha then self.frame:SetAlpha(alpha) end
    if alpha <= 0 and target == 0 then
        SetShown(self.frame, false)
        self:SyncUpdater()
    end
end

function SwingBar:OnEvent(which, a1, a2, a3, a4)
    if which == "PLAYER_ENTERING_WORLD" then
        self.inCombat = UnitAffectingCombat and UnitAffectingCombat("player") or false
        self:StopMelee(); self:StopRanged(); self:UpdateSpeeds(false); self:Layout()
    elseif which == "PLAYER_REGEN_DISABLED" then
        self.inCombat = true; self:RefreshVisibility()
    elseif which == "PLAYER_REGEN_ENABLED" then
        self.inCombat = false; self:RefreshVisibility()
    elseif which == "PLAYER_ENTER_COMBAT" then
        self:StartMelee()
    elseif which == "PLAYER_LEAVE_COMBAT" then
        self:StopMelee()
    elseif which == "START_AUTOREPEAT_SPELL" then
        self:StartRanged()
    elseif which == "STOP_AUTOREPEAT_SPELL" then
        self:StopRanged()
    elseif which == "UNIT_ATTACK_SPEED" then
        if not a1 or a1 == "player" then self:UpdateSpeeds(false); self:RefreshVisibility() end
    elseif which == "UNIT_INVENTORY_CHANGED" then
        if not a1 or a1 == "player" then
            self:UpdateSpeeds(false); self:UpdateLabels(); self:RefreshVisibility()
        end
    elseif which == "AUTO_ATTACK_SELF" then
        if HasFlag(a4, 65536) then
            self:RecordRangedShot(GetTime(), "auto_attack")
        else
            self:RecordMeleeSwing(HasFlag(a4, 4))
        end
        self.enhancedSwingAt = GetTime()
    elseif which == "SPELL_GO_SELF" then
        -- Nampower supplies the exact server-confirmed Auto Shot release.
        if tonumber(a2) == 75 then self:RecordRangedShot(GetTime(), "spell_go") end
    elseif which == "ITEM_LOCK_CHANGED" then
        -- Stock 1.12 consumes ammunition at Auto Shot release. Restrict the
        -- heuristic to the short draw window so ordinary inventory changes
        -- during the much longer cooldown do not move the timer.
        local now = GetTime()
        local inDrawWindow = self.ranged.phase == "draw"
            and now >= (self.ranged.phaseStart or now) + 0.15
        if self.rangedActive and self.ranged.active
            and (inDrawWindow or self.ranged.phase == "fire") then
            self:RecordRangedShot(now, "item_lock")
        end
    elseif which == "CHAT_MSG_COMBAT_SELF_HITS" or which == "CHAT_MSG_COMBAT_SELF_MISSES" then
        if not self.rangedActive and (not self.enhancedSwingAt or GetTime() - self.enhancedSwingAt > 0.2) then
            self:RecordMeleeSwing(false)
        end
    elseif which == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        -- Queued melee attacks (Heroic Strike, Cleave, Maul, Raptor Strike)
        -- use the spell combat channel on stock 1.12. Only accept the event at
        -- the predicted main-hand boundary so ordinary instant spells cannot
        -- reset the timer.
        local now = GetTime()
        if self.meleeActive and not self.rangedActive and self.main.active
            and now >= (self.main.endTime or 0) - 0.15
            and (not self.enhancedSwingAt or now - self.enhancedSwingAt > 0.2) then
            self:StartTimer(self.main, now)
            self.lastSwingTimer = self.main
            self.lastSwingAt = now
        end
    end
end

function SwingBar:RegisterEvents()
    if not self.eventFrame then self.eventFrame = CreateFrame("Frame") end
    local frame = self.eventFrame
    frame:UnregisterAllEvents()
    local events = {
        "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
        "PLAYER_ENTER_COMBAT", "PLAYER_LEAVE_COMBAT", "START_AUTOREPEAT_SPELL",
        "STOP_AUTOREPEAT_SPELL", "UNIT_ATTACK_SPEED", "UNIT_INVENTORY_CHANGED",
        "CHAT_MSG_COMBAT_SELF_HITS", "CHAT_MSG_COMBAT_SELF_MISSES", "CHAT_MSG_SPELL_SELF_DAMAGE",
        "ITEM_LOCK_CHANGED",
    }
    local i
    for i = 1, table.getn(events) do pcall(frame.RegisterEvent, frame, events[i]) end
    pcall(frame.RegisterEvent, frame, "AUTO_ATTACK_SELF")
    pcall(frame.RegisterEvent, frame, "SPELL_GO_SELF")
    frame:SetScript("OnEvent", function() SwingBar:OnEvent(event, arg1, arg2, arg3, arg4) end)
    frame:SetScript("OnUpdate", nil)
    self.updaterRunning = false
    self:SyncUpdater()
end

function SwingBar:ReloadConfig()
    if not self.frame then self:CreateBar() end
    self.enabled = self:Config("swingBarEnabled", true)
    self.combatOnly = self:Config("swingBarCombatOnly", true)
    self.showSpark = self:Config("swingBarShowSpark", true)
    self.showTimer = self:Config("swingBarShowTimer", true)
    self.fadeDuration = Clamp(self:Config("swingBarFadeDuration", 0.25), 0, 3)
    self:Layout()
    self:RefreshVisibility()
end

function SwingBar:Initialize()
    self:CreateBar()
    self:UpdateSpeeds(false)
    self:RegisterEvents()
    self:ReloadConfig()
    ConsoleUI_Debug("Swing timer module initialized")
end
