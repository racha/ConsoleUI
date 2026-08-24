--[[
    Stance squares + pet bar. KeySq chrome. Square icons, no SliceMask.
    Own binds. Does not claim 1-0.
    Hide via GetNumShapeshiftForms / PetHasActionBar.
    Pet: one command + one stance opposite spells. Click opens the other two.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}

local ActionBars = ConsoleUI.actionbars
local Extra = {}
ActionBars.extra = Extra

local function Layout()
    return ActionBars.Layout
end

local function Config()
    return ConsoleUI.config
end

local function ScaleOf(key)
    local cfg = Config()
    local n = 1
    if cfg and cfg.Get then
        n = tonumber(cfg:Get(key)) or 1
    end
    if n < 0.5 then
        n = 0.5
    end
    if n > 2 then
        n = 2
    end
    return n
end

function Extra:InCombat()
    return UnitAffectingCombat and UnitAffectingCombat("player")
end

function Extra:Unlocked()
    local cfg = Config()
    if cfg and cfg.Get then
        return cfg:Get("extraBarsUnlocked") and true or false
    end
    return false
end

function Extra:CanDrag()
    return self:Unlocked() and not self:InCombat()
end

function Extra:HasStanceClass()
    local _, class = UnitClass and UnitClass("player")
    return class == "WARRIOR" or class == "DRUID" or class == "ROGUE"
end

function Extra:HasStance()
    if not self:HasStanceClass() then
        return false
    end
    local n = GetNumShapeshiftForms and (GetNumShapeshiftForms() or 0) or 0
    return n > 0
end

function Extra:HasPet()
    return PetHasActionBar and PetHasActionBar() and true or false
end

local function PaintTex(tex, r, g, b, a)
    if not tex then
        return
    end
    tex:SetVertexColor(r, g, b)
    if a ~= nil then
        tex:SetAlpha(a)
    end
end

function Extra:PaintSquare(button, active)
    if not button then
        return
    end
    ActionBars:ApplySquareAppearance(button)
    self:SetSquareActive(button, active)
    ActionBars:RaiseDiamondChrome(button)
end

function Extra:SetSquareActive(button, active)
    if not button or not button.diamondPlate then
        return
    end
    PaintTex(button.diamondPlate, ActionBars.DIAMOND_FILL[1], ActionBars.DIAMOND_FILL[2], ActionBars.DIAMOND_FILL[3], 1)
    if button.diamondRim then
        PaintTex(button.diamondRim, 0, 0, 0, 1)
        button.diamondRim:Show()
    end
    if not button.diamondRing then
        return
    end
    local goldOn = active
    if not goldOn and ConsoleUI.config and ConsoleUI.config.Get then
        goldOn = ConsoleUI.config:Get("barGoldBorder") and true or false
    end
    if button.extraKind == "stance" or button.extraKind == "pet" then
        goldOn = false
    end
    if goldOn then
        local r, g, b = 1.00, 0.82, 0.18
        if ConsoleUI.config and ConsoleUI.config.GetHudBorderColor then
            r, g, b = ConsoleUI.config:GetHudBorderColor()
        end
        PaintTex(button.diamondRing, r, g, b, 1)
        button.diamondRing:Show()
    else
        button.diamondRing:Hide()
    end
end

function Extra:PaintStanceIcon(button, texture)
    if not button or not button.icon then
        return
    end
    if type(texture) == "string" and texture ~= "" then
        button.icon:SetTexture(texture)
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button.icon:SetVertexColor(1, 1, 1)
        button.icon:Show()
    else
        button.icon:Hide()
    end
    if button.SetChecked then
        button:SetChecked(0)
    end
end

function Extra:PaintStanceState()
    if not self.stanceButtons then
        return
    end
    local n = self:StanceCount()
    local i
    for i = 1, 8 do
        local button = self.stanceButtons[i]
        if button and i <= n then
            local texture, _, apiActive = self:StanceInfo(i)
            local active = apiActive
            if self.pendingStance then
                active = (i == self.pendingStance)
            end
            self:SetSquareActive(button, active)
            self:PaintStanceIcon(button, texture)
            ActionBars:RaiseDiamondChrome(button)
        end
    end
end

function Extra:BonusOffset()
    if GetBonusBarOffset then
        return GetBonusBarOffset() or 0
    end
    return 0
end

function Extra:RefreshStanceDependents()
    self:PaintStanceState()
    if not self:HasStance() then
        return
    end
    if ActionBars and ActionBars.UpdateAllButtons then
        ActionBars:UpdateAllButtons()
    end
end

function Extra:SyncPendingStance()
    if not self.pendingStance then
        return
    end
    local _, _, active = self:StanceInfo(self.pendingStance)
    if active then
        self.pendingStance = nil
        self.pendingStanceUntil = nil
        return
    end
    if self.pendingStanceUntil and GetTime and GetTime() > self.pendingStanceUntil then
        self.pendingStance = nil
        self.pendingStanceUntil = nil
    end
end

function Extra:AutoParent(button)
    return (button and button.diamondChrome) or button
end

function Extra:EnsureAutocast(button)
    local parent = self:AutoParent(button)
    if not button.extraCastable then
        local overlay = parent:CreateTexture(button:GetName() .. "AutoCastable", "OVERLAY")
        overlay:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
        button.extraCastable = overlay
    elseif button.extraCastable.SetParent then
        button.extraCastable:SetParent(parent)
    end
    if not button.extraShine then
        button.extraShine = {}
        local gold = Layout().GOLD
        local count = (Layout() and Layout().AUTOCAST_DOTS) or 4
        local n
        for n = 1, count do
            local dot = parent:CreateTexture(button:GetName() .. "AutoCastDot" .. n, "OVERLAY")
            dot:SetTexture("Interface\\AddOns\\ConsoleUI\\textures\\hud\\White.tga")
            dot:SetBlendMode("ADD")
            dot:SetVertexColor(gold[1], gold[2], gold[3])
            dot:SetAlpha(1)
            button.extraShine[n] = dot
        end
    end
    return button.extraCastable, button.extraShine
end

function Extra:PaintAutocast(button, auto, allowed)
    local overlay, dots = self:EnsureAutocast(button)
    local lay = Layout()
    local size = button:GetWidth()
    if size == 0 then
        size = 56
    end
    local over = size + 28
    overlay:ClearAllPoints()
    overlay:SetWidth(over)
    overlay:SetHeight(over)
    overlay:SetPoint("CENTER", button, "CENTER", 0, 0)
    local dotSize = (lay and lay.AUTOCAST_DOT) or 6
    local n
    for n = 1, table.getn(dots) do
        local dot = dots[n]
        if dot then
            dot:SetWidth(dotSize)
            dot:SetHeight(dotSize)
            if auto then
                dot:Show()
            else
                dot:Hide()
            end
        end
    end
    if allowed then
        overlay:Show()
    else
        overlay:Hide()
    end
    if auto then
        button._autoDotOn = true
    else
        button._autoDotOn = nil
    end
end

function Extra:UpdateAutocastDots(elapsed)
    local lay = Layout()
    if not lay or not lay.SquarePathPoint or not self.petButtons then
        return
    end
    self._autoClock = (self._autoClock or 0) + (elapsed or 0)
    local period = lay.AUTOCAST_PULSE or 3.2
    local progress = math.mod(self._autoClock, period) / period
    local i
    for i = 1, 10 do
        local button = self.petButtons[i]
        local dots = button and button.extraShine
        if button and button._autoDotOn and dots then
            local half = lay.SquareIconSize(button:GetWidth()) / 2 + lay.AUTOCAST_DOT / 2
            local count = table.getn(dots)
            local n
            for n = 1, count do
                local x, y = lay.SquarePathPoint(progress + (n - 1) / count, half)
                dots[n]:ClearAllPoints()
                dots[n]:SetPoint("CENTER", button, "CENTER", x, y)
            end
        end
    end
end

function Extra:ScaleForHost(host)
    local lay = Layout()
    if host == self.petHost then
        return ScaleOf("petBarScale") * ((lay and lay.PET_BASE) or 0.6)
    end
    return ScaleOf("stanceBarScale") * ((lay and lay.STANCE_BASE) or 0.8)
end

function Extra:PetGrow()
    local cfg = Config()
    if cfg and cfg.Get and cfg:Get("petBarGrow") == "left" then
        return "left"
    end
    return "right"
end

function Extra:HostOffsetKeys(host)
    if host == self.petHost then
        return "petBarOffsetX", "petBarOffsetY"
    end
    return "stanceBarOffsetX", "stanceBarOffsetY"
end

function Extra:CursorUI()
    if not GetCursorPosition or not UIParent then
        return 0, 0
    end
    local mx, my = GetCursorPosition()
    local us = 1
    if UIParent.GetEffectiveScale then
        us = UIParent:GetEffectiveScale() or 1
    end
    if us == 0 then
        us = 1
    end
    return mx / us, my / us
end

function Extra:ReadOffset(key)
    local cfg = Config()
    if cfg and cfg.Get then
        local n = tonumber(cfg:Get(key))
        if n ~= nil then
            return n
        end
    end
    return 0
end

function Extra:SavedCenter(host)
    local xKey, yKey = self:HostOffsetKeys(host)
    return self:ReadOffset(xKey), self:ReadOffset(yKey)
end

function Extra:HostCenter(host)
    if host and host.GetPoint then
        local p, _, rp, px, py = host:GetPoint(1)
        if p == "CENTER" and rp == "CENTER" and px ~= nil then
            return tonumber(px) or 0, tonumber(py) or 0
        end
    end
    return self:SavedCenter(host)
end

function Extra:PinCenter(host, x, y)
    host:ClearAllPoints()
    host:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function Extra:DragFollow(host)
    if not host or not UIParent then
        return
    end
    local mx, my = self:CursorUI()
    local x = mx - (host._dragOffX or 0) - UIParent:GetWidth() / 2
    local y = my - (host._dragOffY or 0) - UIParent:GetHeight() / 2
    self:PinCenter(host, x, y)
    host._dragX = x
    host._dragY = y
end

function Extra:BeginDrag(host)
    if not host or not self:CanDrag() or not UIParent then
        return
    end
    local ox, oy = self:HostCenter(host)
    self:PinCenter(host, ox, oy)
    local mx, my = self:CursorUI()
    host._dragOffX = mx - (UIParent:GetWidth() / 2 + ox)
    host._dragOffY = my - (UIParent:GetHeight() / 2 + oy)
    host._dragX = ox
    host._dragY = oy
    host._extraDragging = true
end

function Extra:EndDrag(host)
    if not host or not host._extraDragging then
        return
    end
    local xKey, yKey = self:HostOffsetKeys(host)
    local x = host._dragX
    local y = host._dragY
    if x == nil or y == nil then
        x, y = self:HostCenter(host)
    end
    host._extraDragging = nil
    host._dragOffX = nil
    host._dragOffY = nil
    host._dragX = nil
    host._dragY = nil
    local cfg = Config()
    if not cfg or not cfg.Set then
        self:PlaceHost(host, xKey, yKey, self:ScaleForHost(host))
        return
    end
    cfg:Set(xKey, x)
    cfg:Set(yKey, y)
    self:PlaceHost(host, xKey, yKey, self:ScaleForHost(host))
    if cfg.RefreshExtraOffsetBoxes then
        cfg:RefreshExtraOffsetBoxes()
    end
end

function Extra:PlaceHost(host, xKey, yKey, scale)
    if host._extraDragging then
        return
    end
    host:SetScale(scale or 1)
    self:PinCenter(host, self:ReadOffset(xKey), self:ReadOffset(yKey))
end

function Extra:MouseHeld()
    if not IsMouseButtonDown then
        return true
    end
    return IsMouseButtonDown("LeftButton")
end

function Extra:OnHostUpdate(host, elapsed)
    if host and host._extraDragging then
        if self:MouseHeld() then
            self:DragFollow(host)
        else
            self:EndDrag(host)
        end
    end
    if host == self.stanceHost and self.pendingStance then
        local bonus = self:BonusOffset()
        self:SyncPendingStance()
        if not self.pendingStance or bonus ~= self.pendingBonus then
            self.pendingBonus = bonus
            self:RefreshStanceDependents()
        end
    end
    if host == self.petHost and self:HasPet() then
        self:UpdateAutocastDots(elapsed)
        self:SyncPetSpellCast()
    end
end

function Extra:EnsureMover(host)
    if host.extraMover then
        return host.extraMover
    end
    local mover = CreateFrame("Frame", host:GetName() .. "Mover", host)
    mover:SetAllPoints(host)
    mover:EnableMouse(false)
    mover:Hide()
    mover:SetScript("OnMouseDown", function()
        if arg1 ~= "LeftButton" then
            return
        end
        Extra:BeginDrag(host)
    end)
    mover:SetScript("OnMouseUp", function()
        Extra:EndDrag(host)
    end)
    host.extraMover = mover
    return mover
end

function Extra:SyncMover(host)
    local mover = host and host.extraMover
    if not mover then
        return
    end
    if self:CanDrag() then
        local lvl = 1
        if host.GetFrameLevel then
            lvl = host:GetFrameLevel() or 1
        end
        mover:SetFrameLevel(lvl + 20)
        mover:EnableMouse(true)
        mover:Show()
    else
        if host._extraDragging then
            self:EndDrag(host)
        end
        mover:EnableMouse(false)
        mover:Hide()
    end
end

function Extra:MakeButton(parent, name, size)
    local button = CreateFrame("CheckButton", name, parent)
    button:SetWidth(size)
    button:SetHeight(size)
    local icon = button:CreateTexture(name .. "Icon", "ARTWORK")
    icon:SetWidth(size)
    icon:SetHeight(size)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.icon = icon
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:EnableMouse(true)
    if button.SetChecked then
        button:SetChecked(0)
    end
    return button
end

function Extra:EnsureFrames()
    if not self.stanceHost then
        local host = CreateFrame("Frame", "ConsoleUIStanceBar", UIParent)
        host:SetFrameStrata("MEDIUM")
        host:EnableMouse(false)
        host:SetScript("OnUpdate", function()
            Extra:OnHostUpdate(this, arg1)
        end)
        host:Hide()
        self.stanceHost = host
        self.stanceButtons = {}
        local i
        for i = 1, 8 do
            local button = self:MakeButton(host, "ConsoleUIStanceButton" .. i, 56)
            button.extraIndex = i
            button.extraKind = "stance"
            if button.SetID then
                button:SetID(i)
            end
            button:SetScript("OnClick", function()
                Extra:ClickStance(this.extraIndex)
            end)
            button:SetScript("OnEnter", function()
                Extra:StanceTooltip(this)
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            self.stanceButtons[i] = button
        end
        self:EnsureMover(host)
    end
    if not self.petHost then
        local host = CreateFrame("Frame", "ConsoleUIPetBar", UIParent)
        host:SetFrameStrata("MEDIUM")
        host:EnableMouse(false)
        host:SetScript("OnUpdate", function()
            Extra:OnHostUpdate(this, arg1)
        end)
        host:Hide()
        self.petHost = host
        local hubSize = (Layout() and Layout().PET_HUB) or 132
        local hub = self:MakeButton(host, "ConsoleUIPetHub", hubSize)
        hub.extraKind = "hub"
        hub:EnableMouse(true)
        hub:SetScript("OnClick", function()
            Extra:ClickPetHub()
        end)
        self.petHub = hub
        self.petButtons = {}
        local i
        for i = 1, 10 do
            local button = self:MakeButton(host, "ConsoleUIPetButton" .. i, 56)
            button.extraIndex = i
            button.extraKind = "pet"
            if button.SetID then
                button:SetID(i)
            end
            button:SetScript("OnClick", function()
                Extra:ClickPet(this.extraIndex, arg1)
            end)
            button:SetScript("OnEnter", function()
                Extra:PetTooltip(this)
            end)
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            self.petButtons[i] = button
        end
        self:EnsureMover(host)
    end
end

function Extra:EnsureWatcher()
    if self.watcher then
        return
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    f:RegisterEvent("PLAYER_AURAS_CHANGED")
    f:RegisterEvent("PET_BAR_UPDATE")
    f:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    if UnitCastingInfo then
        f:RegisterEvent("UNIT_SPELLCAST_START")
        f:RegisterEvent("UNIT_SPELLCAST_STOP")
        f:RegisterEvent("UNIT_SPELLCAST_FAILED")
        f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
        f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    end
    f:RegisterEvent("UNIT_PET")
    f:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    f:SetScript("OnEvent", function()
        if event == "PLAYER_REGEN_DISABLED" then
            Extra:EndDrag(Extra.stanceHost)
            Extra:EndDrag(Extra.petHost)
        end
        if event == "UPDATE_SHAPESHIFT_FORMS" or event == "UPDATE_SHAPESHIFT_FORM"
            or event == "UPDATE_BONUS_ACTIONBAR" or event == "PLAYER_AURAS_CHANGED" then
            Extra:SyncPendingStance()
            Extra:RefreshStanceDependents()
            return
        end
        Extra:Update()
    end)
    self.watcher = f
end

function Extra:StanceInfo(i)
    i = tonumber(i)
    if not self:HasStanceClass() or not GetShapeshiftFormInfo or not i or i < 1 or i > 8 then
        return nil
    end
    local ok, texture, name, isActive = pcall(GetShapeshiftFormInfo, i)
    if not ok then
        return nil
    end
    if type(texture) ~= "string" or texture == "" then
        texture = nil
    end
    if type(name) ~= "string" or name == "" then
        name = nil
    end
    return texture, name, isActive == 1 or isActive == true
end

function Extra:StanceCount()
    if not self:HasStanceClass() then
        return 0
    end
    return GetNumShapeshiftForms and (GetNumShapeshiftForms() or 0) or 0
end

function Extra:PetInfo(i)
    if not self:HasPet() or not GetPetActionInfo then
        return nil
    end
    local name, _, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
    if isToken then
        if texture and getglobal then
            local resolved = getglobal(texture)
            if type(resolved) == "string" then
                texture = resolved
            end
        end
        if name and getglobal then
            local resolved = getglobal(name)
            if type(resolved) == "string" then
                name = resolved
            end
        end
    end
    if type(texture) ~= "string" or texture == "" then
        texture = nil
    end
    if type(name) ~= "string" or name == "" then
        name = nil
    end
    return name, texture, isActive == 1 or isActive == true, autoCastEnabled == 1 or autoCastEnabled == true, autoCastAllowed == 1 or autoCastAllowed == true
end

function Extra:ClickStance(i)
    if ConsoleUI_ChatBlocksActions and ConsoleUI_ChatBlocksActions() then
        return
    end
    if not CastShapeshiftForm then
        return
    end
    CastShapeshiftForm(i)
    self.pendingStance = i
    self.pendingBonus = self:BonusOffset()
    if GetTime then
        self.pendingStanceUntil = GetTime() + 2
    end
    self:RefreshStanceDependents()
end

function Extra:GroupOfKind(kind)
    if kind == "attack" or kind == "follow" or kind == "wait" then
        return "action"
    end
    if kind == "passive" or kind == "defensive" or kind == "aggressive" then
        return "stance"
    end
    return "spell"
end

function Extra:PetGroupOf(slot)
    if not self:HasPet() then
        return "spell"
    end
    local kind = self:ClassifyPetBlob(self:BlobOfPetSlot(slot))
    if kind then
        return self:GroupOfKind(kind)
    end
    if GetPetActionInfo then
        local _, _, _, isToken = GetPetActionInfo(slot)
        if not isToken then
            return "spell"
        end
    end
    local lay = Layout()
    if lay and lay.PetSlotGroup then
        return lay.PetSlotGroup(slot)
    end
    return "spell"
end

function Extra:ClassifyPetBlob(blob)
    if not blob or blob == "" then
        return nil
    end
    blob = string.upper(tostring(blob))
    if string.find(blob, "PASSIVE", 1, true) then
        return "passive"
    end
    if string.find(blob, "DEFENSIVE", 1, true) then
        return "defensive"
    end
    if string.find(blob, "AGGRESSIVE", 1, true) then
        return "aggressive"
    end
    if string.find(blob, "PET_ACTION_FOLLOW", 1, true) or string.find(blob, "PET_FOLLOW", 1, true) or string.find(blob, "FOLLOW", 1, true) then
        return "follow"
    end
    if string.find(blob, "WAIT", 1, true) or string.find(blob, "STAY", 1, true) then
        return "wait"
    end
    if string.find(blob, "PET_ACTION_ATTACK", 1, true) or string.find(blob, "PET_ATTACK", 1, true) or string.find(blob, "ATTACK", 1, true) then
        return "attack"
    end
    return nil
end

function Extra:BlobOfPetSlot(i)
    if not self:HasPet() or not GetPetActionInfo then
        return ""
    end
    local a, b, c, d = GetPetActionInfo(i)
    local blob = tostring(a or "") .. " " .. tostring(b or "") .. " " .. tostring(c or "") .. " " .. tostring(d or "")
    local token = a
    if getglobal and type(token) == "string" and getglobal(token) then
        blob = blob .. " " .. tostring(getglobal(token))
    end
    if getglobal and type(c) == "string" and getglobal(c) then
        blob = blob .. " " .. tostring(getglobal(c))
    end
    return string.upper(blob)
end

function Extra:PetKindOf(i)
    local kind = self:ClassifyPetBlob(self:BlobOfPetSlot(i))
    if kind then
        return kind
    end
    local group = self:PetGroupOf(i)
    if group == "action" then
        if i == 1 then
            return "attack"
        end
        if i == 2 then
            return "follow"
        end
        if i == 3 then
            return "wait"
        end
    end
    if group == "stance" then
        if i == 4 then
            return "aggressive"
        end
        if i == 5 then
            return "defensive"
        end
        if i == 6 then
            return "passive"
        end
    end
    return nil
end

function Extra:FindPetSlot(kind)
    local i
    for i = 1, 10 do
        if self:ClassifyPetBlob(self:BlobOfPetSlot(i)) == kind then
            return i
        end
    end
    if kind == "attack" then
        return 1
    end
    if kind == "follow" then
        return 2
    end
    if kind == "wait" then
        return 3
    end
    if kind == "aggressive" then
        return 4
    end
    if kind == "defensive" then
        return 5
    end
    if kind == "passive" then
        return 6
    end
    return nil
end

function Extra:InstallPetFollowHook()
    if self._petFollowHooked then
        return
    end
    if not PetFollow then
        return
    end
    self._stockPetFollow = PetFollow
    PetFollow = function()
        Extra:FollowAndDismiss()
    end
    self._petFollowHooked = true
end

function Extra:FireStockPetSlot(i)
    i = tonumber(i)
    if not self:HasPet() or not i or not CastPetAction then
        return false
    end
    -- Stock OnClick pickups Follow when LT (Shift) is held. CastPetAction does not.
    CastPetAction(i)
    return true
end

function Extra:FollowAndDismiss(i)
    if self._followBusy then
        return true
    end
    self._followBusy = true
    i = tonumber(i)
    if not i then
        i = self:FindPetSlot("follow") or 2
    end
    self:FireStockPetSlot(i)
    self._followBusy = nil
    return true
end

function Extra:RunProxiedPetBind(bindingID)
    if bindingID == "PETFOLLOW" or bindingID == "ConsoleUI_PET_FOLLOW" then
        return self:FollowAndDismiss()
    end
    return false
end

function Extra:RunPetCommand(i)
    self:InstallPetFollowHook()
    local kind = self:PetKindOf(i)
    if kind == "follow" then
        return self:FollowAndDismiss(i)
    end
    if kind == "attack" and PetAttack then
        PetAttack()
    elseif kind == "wait" and PetWait then
        PetWait()
    elseif kind == "aggressive" and PetAggressiveMode then
        PetAggressiveMode()
    elseif kind == "defensive" and PetDefensiveMode then
        PetDefensiveMode()
    elseif kind == "passive" and PetPassiveMode then
        PetPassiveMode()
    end
    if CastPetAction then
        CastPetAction(i)
        return true
    end
    return kind ~= nil
end

function Extra:SyncPendingPet()
    if not self.pendingPet then
        return
    end
    local _, _, active = self:PetInfo(self.pendingPet)
    if active then
        self.pendingPet = nil
        self.pendingPetUntil = nil
        return
    end
    if self.pendingPetUntil and GetTime and GetTime() > self.pendingPetUntil then
        self.pendingPet = nil
        self.pendingPetUntil = nil
    end
end

function Extra:PetCastName()
    if not self:HasPet() then
        return nil
    end
    if UnitExists and not UnitExists("pet") then
        return nil
    end
    local name
    if UnitCastingInfo then
        name = UnitCastingInfo("pet")
    end
    if (not name or name == "") and UnitChannelInfo then
        name = UnitChannelInfo("pet")
    end
    if name == "" then
        return nil
    end
    return name
end

function Extra:PetSpellBusy(slot, name)
    if self:PetGroupOf(slot) ~= "spell" then
        return false
    end
    if not name then
        name = self:PetInfo(slot)
    end
    local cast = self:PetCastName()
    if not cast or not name then
        return false
    end
    return string.lower(cast) == string.lower(name)
end

function Extra:PaintPetCooldown(button, slot)
    if not self:HasPet() or not button or not GetPetActionCooldown or not ActionBars or not ActionBars.StartCircularCooldown then
        return
    end
    local start, duration, enable = GetPetActionCooldown(slot)
    if start and duration and duration > 0 and enable ~= 0 then
        ActionBars:StartCircularCooldown(button, start, duration)
    elseif ActionBars.StopCircularCooldown then
        ActionBars:StopCircularCooldown(button)
    end
end

function Extra:SyncPetSpellCast()
    if not self:HasPet() or not self.petButtons then
        return
    end
    local i
    for i = 7, 10 do
        local button = self.petButtons[i]
        if button and button.IsShown and button:IsShown() then
            local name, _, active = self:PetInfo(i)
            self:PaintSquare(button, self:PetSlotActive(i, active))
            self:PaintPetCooldown(button, i)
        end
    end
end

function Extra:PetSlotActive(slot, apiActive)
    if self:PetSpellBusy(slot) then
        return true
    end
    if not self.pendingPet then
        return apiActive
    end
    local group = self:PetGroupOf(slot)
    if group ~= "action" and group ~= "stance" then
        return apiActive
    end
    if self:PetGroupOf(self.pendingPet) ~= group then
        return apiActive
    end
    return slot == self.pendingPet
end

function Extra:ClickPetHub()
    if self.petPicker then
        self.petPicker = nil
        self:UpdatePet()
    end
    if self.petHub and self.petHub.SetChecked then
        self.petHub:SetChecked(0)
    end
    if ConsoleUI_ChatBlocksActions and ConsoleUI_ChatBlocksActions() then
        return
    end
    if not UnitExists or not UnitExists("pet") then
        return
    end
    if SpellIsTargeting and SpellIsTargeting() then
        if SpellCanTargetUnit and not SpellCanTargetUnit("pet") then
            return
        end
        if SpellTargetUnit then
            SpellTargetUnit("pet")
        end
        return
    end
    if TargetUnit then
        TargetUnit("pet")
    end
end

function Extra:ClickPet(i, button)
    if ConsoleUI_ChatBlocksActions and ConsoleUI_ChatBlocksActions() then
        return
    end
    if button == "RightButton" then
        if TogglePetAutocast then
            TogglePetAutocast(i)
        end
        self:UpdatePet()
        return
    end
    local group = self:PetGroupOf(i)
    if button == "LeftButton" and (group == "action" or group == "stance") then
        local parked = self.petParkedAction
        if group == "stance" then
            parked = self.petParkedStance
        end
        if i == parked then
            if self.petPicker == group then
                self.petPicker = nil
            else
                self.petPicker = group
            end
            self:UpdatePet()
            return
        end
        self.petPicker = nil
    end
    if self:RunPetCommand(i) then
        if group == "action" or group == "stance" then
            self.pendingPet = i
            if GetTime then
                self.pendingPetUntil = GetTime() + 2
            end
        end
    end
    self:UpdatePet()
end

function Extra:StanceTooltip(button)
    if not button then
        return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    if GameTooltip.SetShapeshift and GameTooltip:SetShapeshift(button.extraIndex) then
        return
    end
    local _, name = self:StanceInfo(button.extraIndex)
    if not name then
        GameTooltip:Hide()
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:SetText(name, 1, 1, 1)
    GameTooltip:Show()
end

function Extra:PetTooltip(button)
    if not button or not GetPetActionInfo then
        return
    end
    local i = button.extraIndex
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    if GameTooltip.SetPetAction and GameTooltip:SetPetAction(i) then
        return
    end
    local name, subtext, _, isToken = GetPetActionInfo(i)
    if isToken and name and getglobal then
        name = getglobal(name) or name
    end
    if not name then
        name = self:PetInfo(i)
    end
    if not name then
        GameTooltip:Hide()
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:SetText(name, 1, 1, 1)
    if subtext and subtext ~= "" then
        GameTooltip:AddLine(subtext, 0.5, 0.5, 0.5)
    end
    GameTooltip:Show()
end

function Extra:SizeButton(button, size)
    button:SetWidth(size)
    button:SetHeight(size)
end

function Extra:UpdateStance()
    self:EnsureFrames()
    local host = self.stanceHost
    if host._extraDragging then
        return
    end
    if not self:HasStance() then
        host:Hide()
        return
    end
    local lay = Layout()
    local hit = lay and lay.HIT or 56
    local step = lay and lay.SquareStep(hit) or (hit + 20)
    local n = self:StanceCount()
    if n < 1 then
        host:Hide()
        return
    end
    if n > 8 then
        n = 8
    end
    local gold = lay and lay.GOLD_OUT or 6
    host:SetWidth(n * step + gold * 2)
    host:SetHeight(hit + gold * 2)
    self:PlaceHost(host, "stanceBarOffsetX", "stanceBarOffsetY", self:ScaleForHost(host))
    local start = -((n - 1) * step) / 2
    local i
    for i = 1, 8 do
        local button = self.stanceButtons[i]
        if i <= n then
            local texture, _, active = self:StanceInfo(i)
            self:SizeButton(button, hit)
            button:ClearAllPoints()
            button:SetPoint("CENTER", host, "CENTER", start + (i - 1) * step, 0)
            button:Show()
            self:PaintSquare(button, active)
            self:PaintStanceIcon(button, texture)
        else
            button:Hide()
        end
    end
    host:Show()
end

function Extra:UpdatePet()
    self:EnsureFrames()
    local host = self.petHost
    if host._extraDragging then
        return
    end
    if not self:HasPet() then
        host:Hide()
        return
    end
    local lay = Layout()
    local hit = lay and lay.HIT or 56
    local hubSize = lay and lay.PET_HUB or 132
    host:SetWidth(hubSize)
    host:SetHeight(hubSize)
    self:PlaceHost(host, "petBarOffsetX", "petBarOffsetY", self:ScaleForHost(host))

    local hub = self.petHub
    self:SizeButton(hub, hubSize)
    hub:ClearAllPoints()
    hub:SetPoint("CENTER", host, "CENTER", 0, 0)
    hub:Show()
    self:PaintSquare(hub, false)
    if hub.icon then
        if SetPortraitTexture and UnitExists and UnitExists("pet") then
            SetPortraitTexture(hub.icon, "pet")
            hub.icon:SetTexCoord(0, 1, 0, 1)
            hub.icon:Show()
        else
            hub.icon:Hide()
        end
    end

    self:SyncPendingPet()
    local grow = self:PetGrow()
    local groups = { action = {}, stance = {}, spell = {} }
    local i
    for i = 1, 10 do
        local button = self.petButtons[i]
        local name, texture = self:PetInfo(i)
        if name or texture then
            table.insert(groups[self:PetGroupOf(i)], i)
        else
            button:Hide()
        end
    end
    if table.getn(groups.stance) > 1 then
        table.sort(groups.stance, function(a, b)
            return a > b
        end)
    end

    local function ParkedSlot(list)
        local n
        for n = 1, table.getn(list) do
            local slot = list[n]
            local _, _, active = self:PetInfo(slot)
            if self:PetSlotActive(slot, active) then
                return slot
            end
        end
        return list[1]
    end

    self.petParkedAction = ParkedSlot(groups.action)
    self.petParkedStance = ParkedSlot(groups.stance)
    if self.petPicker == "action" and table.getn(groups.action) < 2 then
        self.petPicker = nil
    end
    if self.petPicker == "stance" and table.getn(groups.stance) < 2 then
        self.petPicker = nil
    end

    local function PlacePet(slot, group, index, picker)
        local button = self.petButtons[slot]
        local name, texture, active, auto, allowed = self:PetInfo(slot)
        local x = -108
        local y = 35
        if picker and lay and lay.PetPickerPoint then
            x, y = lay.PetPickerPoint(group, index, grow)
        elseif lay and lay.PetGroupPoint then
            x, y = lay.PetGroupPoint(group, index, grow)
        end
        self:SizeButton(button, hit)
        button:ClearAllPoints()
        button:SetPoint("CENTER", host, "CENTER", x, y)
        if button.SetFrameLevel and self.petHub and self.petHub.GetFrameLevel then
            local base = self.petHub:GetFrameLevel() or 1
            if picker then
                button:SetFrameLevel(base + 3)
            else
                button:SetFrameLevel(base + 1)
            end
        end
        button:Show()
        self:PaintSquare(button, self:PetSlotActive(slot, active))
        if button.icon then
            if texture then
                button.icon:SetTexture(texture)
                button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                button.icon:Show()
            else
                button.icon:Hide()
            end
        end
        if group == "spell" then
            self:PaintAutocast(button, auto, allowed)
        else
            self:PaintAutocast(button, nil, nil)
        end
        self:PaintPetCooldown(button, slot)
    end

    local order = { "action", "stance", "spell" }
    local g
    for g = 1, 3 do
        local group = order[g]
        local list = groups[group]
        local parked = self.petParkedAction
        if group == "stance" then
            parked = self.petParkedStance
        end
        local pickN = 0
        local n
        for n = 1, table.getn(list) do
            local slot = list[n]
            if group == "spell" then
                PlacePet(slot, group, n, nil)
            elseif slot == parked then
                PlacePet(slot, group, 1, nil)
            elseif self.petPicker == group then
                pickN = pickN + 1
                PlacePet(slot, group, pickN, true)
            else
                self.petButtons[slot]:Hide()
            end
        end
    end
    host:Show()
end

function Extra:Update()
    if not UIParent then
        return
    end
    self:EnsureFrames()
    self:UpdateStance()
    self:UpdatePet()
    self:SyncMover(self.stanceHost)
    self:SyncMover(self.petHost)
end

function Extra:Initialize()
    self:InstallPetFollowHook()
    if ConsoleUI.keybindings and ConsoleUI.keybindings.ClaimPetFollowKeys then
        ConsoleUI.keybindings:ClaimPetFollowKeys()
    end
    self:EnsureFrames()
    self:EnsureWatcher()
    self:Update()
end

function ConsoleUI_StanceButton(index)
    if Extra and Extra.ClickStance then
        Extra:ClickStance(index)
    end
end

function ConsoleUI_PetButton(index)
    if Extra and Extra.ClickPet then
        Extra:ClickPet(index)
    end
end

function ConsoleUI_PetFollow()
    if Extra and Extra.FollowAndDismiss then
        Extra:FollowAndDismiss()
    end
end

if PetFollow then
    Extra:InstallPetFollowHook()
end
