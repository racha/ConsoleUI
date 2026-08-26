--[[
    Unit menu. Loot chrome, text rows, no row icons.
    A do / B back / D-pad. Bind ConsoleUI_UNIT_MENU.
    1.12: player social rows only. NPC marks if grouped. No open without a unit.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.unit = ConsoleUI.unit or {}
local Unit = ConsoleUI.unit

Unit.MAX = 16
Unit.ROW_H = 32
Unit.WHITE = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
Unit.WASH = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\WashPanel"
Unit.WASH_PAD_X = 72
Unit.WASH_PAD_Y = 56
Unit.WASH_SCALE = 1.1
Unit.WASH_A = 0.70
Unit.WASH_DEEP_A = 0.10

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local function GoldRGB()
    local cfg = ConsoleUI.config
    if cfg and cfg.GetHudBorderColor then
        return cfg:GetHudBorderColor()
    end
    return 1.00, 0.82, 0.18
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

local RAID_MARKS = {
    "Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull",
}

function Unit:Busy()
    return self.host and self.host:IsShown()
end

function Unit:OverlayOpen()
    if ConsoleUI.loot and ConsoleUI.loot.Busy and ConsoleUI.loot:Busy() then
        return true
    end
    if ConsoleUI.radial and ConsoleUI.radial.IsOpen and ConsoleUI.radial:IsOpen() then
        return true
    end
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        return true
    end
    return false
end

function Unit:CanDist(unit, dist)
    if not unit or not UnitExists or not UnitExists(unit) then
        return false
    end
    if CheckInteractDistance then
        return CheckInteractDistance(unit, dist)
    end
    return true
end

function Unit:CollectKeys(action)
    local out = {}
    if not action or action == "" or not GetBindingKey then
        return out
    end
    local a, b = GetBindingKey(action)
    if a and a ~= "" then
        table.insert(out, a)
    end
    if b and b ~= "" then
        table.insert(out, b)
    end
    return out
end

function Unit:KeysForSlot(slot)
    local keys = {}
    local seen = {}
    local function add(key)
        if key and key ~= "" and not seen[key] then
            seen[key] = true
            table.insert(keys, key)
        end
    end
    add(tostring(slot))
    local list = self:CollectKeys("ConsoleUI_ACTION_" .. slot)
    local i
    for i = 1, table.getn(list) do
        add(list[i])
    end
    if ConsoleUI.proxied and ConsoleUI.proxied.GetSlotBinding then
        local proxied = ConsoleUI.proxied:GetSlotBinding(slot)
        if proxied and proxied ~= "" then
            list = self:CollectKeys(proxied)
            for i = 1, table.getn(list) do
                add(list[i])
            end
        end
    end
    return keys
end

function Unit:PersistSlot(slot)
    if ConsoleUI_PersistPadAction then
        return ConsoleUI_PersistPadAction(slot)
    end
    return "ConsoleUI_ACTION_" .. slot
end

function Unit:StealPad()
    if self._padStolen then
        return
    end
    if not SetBinding or not GetBindingAction then
        return
    end
    self._padStolen = {}
    local slot
    for slot = 1, 8 do
        local keys = self:KeysForSlot(slot)
        local persist = self:PersistSlot(slot)
        local want = "ConsoleUI_ACTION_" .. slot
        local k
        for k = 1, table.getn(keys) do
            local key = keys[k]
            if self._padStolen[key] == nil then
                local prev = GetBindingAction(key) or ""
                if prev == "" or (ConsoleUI_IsTransientPadAction and ConsoleUI_IsTransientPadAction(prev)) then
                    self._padStolen[key] = persist
                else
                    self._padStolen[key] = prev
                end
                SetBinding(key, want)
            end
        end
    end
end

function Unit:RestorePad()
    if not self._padStolen or not SetBinding then
        self._padStolen = nil
        return
    end
    local key, prev
    for key, prev in pairs(self._padStolen) do
        if prev and prev ~= "" then
            SetBinding(key, prev)
        else
            SetBinding(key, nil)
        end
    end
    self._padStolen = nil
    if ConsoleUI.keybindings and ConsoleUI.keybindings.RepairPadGameplay then
        ConsoleUI.keybindings:RepairPadGameplay()
    end
end

function Unit:SyncPad()
    if self:Busy() and not self:OverlayOpen() then
        self:StealPad()
    else
        self:RestorePad()
    end
end

function Unit:HookEscape()
    if self._escHooked or not CloseSpecialWindows then
        return
    end
    self._escHooked = true
    local orig = CloseSpecialWindows
    CloseSpecialWindows = function()
        local closed = orig()
        if Unit:Busy() then
            Unit:Close()
            return 1
        end
        return closed
    end
end

function Unit:Ensure()
    self:HookEscape()
    if self.host then
        return self.host
    end
    local host = CreateFrame("Frame", "ConsoleUIUnitMenu", UIParent)
    host:SetFrameStrata("FULLSCREEN_DIALOG")
    host:SetFrameLevel(210)
    host:SetWidth(280)
    host:SetHeight(120)
    host:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    host:EnableMouse(false)
    host:Hide()
    host:SetScript("OnHide", function()
        Unit:OnHide()
    end)

    local wash = host:CreateTexture(nil, "BACKGROUND")
    wash:SetTexture(self.WASH)
    host.wash = wash
    local deep = host:CreateTexture(nil, "BACKGROUND")
    deep:SetTexture(self.WASH)
    host.washDeep = deep

    local title = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", host, "TOPLEFT", 8, -4)
    host.title = title

    local sub = host:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    sub:SetTextColor(0.75, 0.75, 0.75)
    host.sub = sub

    local rule = host:CreateTexture(nil, "ARTWORK")
    rule:SetTexture(self.WHITE)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -6)
    rule:SetPoint("RIGHT", host, "RIGHT", -8, 0)
    host.titleRule = rule

    host.rows = {}
    local i
    for i = 1, self.MAX do
        local row = CreateFrame("Button", "ConsoleUIUnitRow" .. i, host)
        row:SetWidth(260)
        row:SetHeight(self.ROW_H)
        row:RegisterForClicks("LeftButtonUp")
        row:EnableMouse(true)
        row:Hide()
        local glow = row:CreateTexture(nil, "BACKGROUND")
        glow:SetTexture(self.WHITE)
        glow:SetAllPoints(row)
        PaintTex(glow, 1.00, 0.82, 0.18, 0)
        row.glow = glow
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", row, "LEFT", 8, 0)
        name:SetJustifyH("LEFT")
        row.name = name
        local sep = row:CreateTexture(nil, "ARTWORK")
        sep:SetTexture(self.WHITE)
        sep:SetHeight(1)
        sep:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
        sep:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        PaintTex(sep, 1, 1, 1, 0.08)
        row.sep = sep
        row:SetScript("OnClick", function()
            Unit:Activate(this.index)
        end)
        host.rows[i] = row
    end

    local hintRule = host:CreateTexture(nil, "ARTWORK")
    hintRule:SetTexture(self.WHITE)
    hintRule:SetHeight(1)
    hintRule:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 8, 28)
    hintRule:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -8, 28)
    PaintTex(hintRule, 1, 1, 1, 0.08)
    host.hintRule = hintRule
    host.hintX = 8
    host.hintY = 6
    if ConsoleUI.hints and ConsoleUI.hints.Attach then
        ConsoleUI.hints:Attach(host)
    end

    self.host = host
    return host
end

function Unit:PinWash(tex, w, h, a)
    local host = self.host
    if not tex or not host then
        return
    end
    tex:ClearAllPoints()
    tex:SetWidth(w)
    tex:SetHeight(h)
    tex:SetPoint("CENTER", host, "CENTER", 0, 0)
    PaintTex(tex, 0, 0, 0, a)
end

function Unit:FitWash()
    local host = self.host
    if not host or not host.wash then
        return
    end
    local w = ((host:GetWidth() or 280) + self.WASH_PAD_X) * self.WASH_SCALE
    local h = ((host:GetHeight() or 120) + self.WASH_PAD_Y) * self.WASH_SCALE
    self:PinWash(host.wash, w, h, self.WASH_A)
    self:PinWash(host.washDeep, w, h, self.WASH_DEEP_A)
end

function Unit:ClassColor(unit)
    if UnitIsPlayer and UnitIsPlayer(unit) and UnitClass and RAID_CLASS_COLORS then
        local _, class = UnitClass(unit)
        local c = class and RAID_CLASS_COLORS[class]
        if c then
            return c.r, c.g, c.b
        end
    end
    return GoldRGB()
end

function Unit:Describe(unit)
    local level = UnitLevel and UnitLevel(unit)
    local line = ""
    if level and level > 0 then
        line = T("Level") .. " " .. level
    end
    if UnitIsPlayer and UnitIsPlayer(unit) then
        local race = UnitRace and (UnitRace(unit) or "") or ""
        local class = UnitClass and (UnitClass(unit) or "") or ""
        if race ~= "" or class ~= "" then
            line = line .. " " .. race
            if class ~= "" then
                line = line .. " (" .. class .. ")"
            end
        end
    elseif UnitCreatureType then
        local ctype = UnitCreatureType(unit)
        if ctype then
            line = line .. " " .. ctype
        end
    end
    return line
end

function Unit:InGroup()
    if GetNumRaidMembers and GetNumRaidMembers() > 0 then
        return true
    end
    if GetNumPartyMembers and GetNumPartyMembers() > 0 then
        return true
    end
    return false
end

function Unit:BuildTarget()
    local unit = self.unit
    local page = {}
    if UnitIsPlayer and UnitIsPlayer(unit) then
        table.insert(page, { text = T("Inspect"), cmd = "DoInspect", need = 1 })
        if UnitIsFriend and UnitIsFriend("player", unit) then
            table.insert(page, { text = T("Trade"), cmd = "DoTrade", need = 2 })
            table.insert(page, { text = T("Follow"), cmd = "DoFollow", need = 4 })
            table.insert(page, { text = T("Duel"), cmd = "DoDuel", need = 3 })
            table.insert(page, { text = T("Whisper"), cmd = "DoWhisper" })
            local leader = IsPartyLeader and IsPartyLeader()
            local inGroup = (UnitInParty and UnitInParty(unit)) or (UnitInRaid and UnitInRaid(unit))
            if leader and inGroup then
                table.insert(page, { text = T("Kick"), cmd = "DoKick" })
            else
                table.insert(page, { text = T("Invite"), cmd = "DoInvite" })
            end
            table.insert(page, { text = T("Add Friend"), cmd = "DoAddFriend" })
        end
    end
    if self:InGroup() then
        table.insert(page, { text = T("Marks"), cmd = "PushMarks" })
    end
    local out = {}
    local i
    for i = 1, table.getn(page) do
        local row = page[i]
        if not row.need or self:CanDist(unit, row.need) then
            table.insert(out, row)
        end
    end
    return out
end

function Unit:BuildPlayer()
    if self:InGroup() then
        return {
            { text = T("Marks"), cmd = "PushMarks" },
        }
    end
    return {}
end

function Unit:BuildMarks()
    local page = {
        { text = T("Back"), cmd = "PopPage" },
        { text = T("None"), cmd = "DoMark", data = 0 },
    }
    local i
    for i = 1, 8 do
        table.insert(page, { text = T(RAID_MARKS[i]), cmd = "DoMark", data = i })
    end
    return page
end

function Unit:PaintHints()
    local host = self.host
    if not host or not ConsoleUI.hints then
        return
    end
    local prompts
    if self.page == "marks" then
        prompts = {
            { icon = "a", prompt = T("Set") },
            { icon = "b", prompt = T("Back") },
        }
    else
        prompts = {
            { icon = "a", prompt = T("Select") },
            { icon = "b", prompt = T("Close") },
        }
    end
    ConsoleUI.hints:Paint(host, prompts)
    local r, g, b = GoldRGB()
    PaintTex(host.titleRule, r, g, b, 0.22)
    host.title:SetTextColor(r, g, b)
end

function Unit:Paint()
    local host = self:Ensure()
    local rows = self.rows or {}
    local n = table.getn(rows)
    if self.sel < 1 or self.sel > n then
        self.sel = 1
    end
    local name = (UnitName and self.unit and UnitName(self.unit)) or T("Unit Menu")
    if self.page == "marks" then
        host.title:SetText(T("Marks"))
        host.sub:SetText(name)
        host.sub:SetTextColor(0.75, 0.75, 0.75)
    else
        host.title:SetText(name)
        host.sub:SetText(self:Describe(self.unit))
        host.sub:SetTextColor(self:ClassColor(self.unit))
    end
    local i
    for i = 1, self.MAX do
        local row = host.rows[i]
        local spec = rows[i]
        if spec then
            row.index = i
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", host, "TOPLEFT", 8, -40 - (i - 1) * self.ROW_H)
            row.name:SetText(spec.text)
            if i == self.sel then
                row.name:SetTextColor(1, 1, 1)
                row.name:SetAlpha(1)
                PaintTex(row.glow, 1.00, 0.82, 0.18, 0.10)
            else
                row.name:SetTextColor(1, 1, 1)
                row.name:SetAlpha(0.72)
                PaintTex(row.glow, 1.00, 0.82, 0.18, 0)
            end
            row:Show()
        else
            row:Hide()
        end
    end
    host:SetHeight(40 + n * self.ROW_H + 36)
    self:FitWash()
    self:PaintHints()
    if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
        ConsoleUI.cursor.hintbar:Refresh()
    end
end

function Unit:ShowPage(page)
    self.page = page
    if page == "marks" then
        self.rows = self:BuildMarks()
        self.sel = 3
    elseif self.unit and UnitIsUnit and UnitIsUnit(self.unit, "player") then
        self.rows = self:BuildPlayer()
        self.sel = 1
    else
        self.rows = self:BuildTarget()
        self.sel = 1
    end
    self:Paint()
end

function Unit:Open(unit)
    if self:OverlayOpen() then
        return
    end
    unit = unit or "target"
    if not UnitExists or not UnitExists(unit) then
        return
    end
    self.unit = unit
    self.stack = {}
    self:Ensure()
    self:ShowPage("root")
    if not self.rows or table.getn(self.rows) < 1 then
        self.unit = nil
        self.rows = nil
        self.page = nil
        return
    end
    self.host:Show()
    self:SyncPad()
end

function Unit:Close()
    if self.host then
        self.host:Hide()
    end
end

function Unit:OnHide()
    self:RestorePad()
    self.unit = nil
    self.rows = nil
    self.page = nil
    if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
        ConsoleUI.cursor.hintbar:Refresh()
    end
end

function Unit:Move(delta)
    local n = table.getn(self.rows or {})
    if n < 1 then
        return
    end
    self.sel = self.sel + delta
    if self.sel < 1 then
        self.sel = n
    end
    if self.sel > n then
        self.sel = 1
    end
    self:Paint()
end

function Unit:Activate(index)
    local spec = self.rows and self.rows[index or self.sel]
    if not spec or not spec.cmd then
        return
    end
    local fn = self[spec.cmd]
    if fn then
        fn(self, spec.data)
    end
end

function Unit:PushMarks()
    table.insert(self.stack, { page = self.page, sel = self.sel })
    self:ShowPage("marks")
end

function Unit:PopPage()
    local prev = table.remove(self.stack)
    if prev then
        self:ShowPage(prev.page)
        self.sel = prev.sel
        self:Paint()
        return
    end
    self:Close()
end

function Unit:DoInspect()
    if InspectUnit then
        InspectUnit(self.unit)
    end
    self:Close()
end

function Unit:DoTrade()
    if InitiateTrade then
        InitiateTrade(self.unit)
    end
    self:Close()
end

function Unit:DoFollow()
    if FollowUnit then
        FollowUnit(self.unit)
    end
    self:Close()
end

function Unit:DoDuel()
    local name = UnitName and UnitName(self.unit)
    if StartDuel and name then
        StartDuel(name)
    end
    self:Close()
end

function Unit:DoWhisper()
    local name = UnitName and UnitName(self.unit)
    if name and ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. name .. " ", DEFAULT_CHAT_FRAME)
    end
    self:Close()
end

function Unit:DoInvite()
    local name = UnitName and UnitName(self.unit)
    if name then
        if InviteByName then
            InviteByName(name)
        elseif InviteUnit then
            InviteUnit(name)
        end
    end
    self:Close()
end

function Unit:DoKick()
    local name = UnitName and UnitName(self.unit)
    if self.unit and TargetUnit then
        TargetUnit(self.unit)
    end
    if name and UninviteByName then
        UninviteByName(name)
    elseif name and UninviteFromRaid and GetNumRaidMembers and GetNumRaidMembers() > 0 then
        local i
        for i = 1, GetNumRaidMembers() do
            if UnitName and UnitName("raid" .. i) == name then
                UninviteFromRaid(i)
                break
            end
        end
    elseif UninviteFromParty then
        UninviteFromParty()
    end
    self:Close()
end

function Unit:DoAddFriend()
    local name = UnitName and UnitName(self.unit)
    if name and AddFriend then
        AddFriend(name)
    end
    self:Close()
end

function Unit:DoMark(index)
    if SetRaidTarget and self.unit then
        SetRaidTarget(self.unit, index or 0)
    end
    self:Close()
end

function Unit:ConsumePad(slot)
    if not self:Busy() then
        return false
    end
    if self:OverlayOpen() then
        return false
    end
    if slot == 1 then
        self:Activate(self.sel)
        return true
    end
    if slot == 4 then
        if self.page == "marks" then
            self:PopPage()
        else
            self:Close()
        end
        return true
    end
    if slot == 5 then
        self:Move(1)
        return true
    end
    if slot == 7 then
        self:Move(-1)
        return true
    end
    return true
end

function Unit:UnitFromCursor()
    local button = ConsoleUI.cursor and ConsoleUI.cursor.navigationState and ConsoleUI.cursor.navigationState.currentButton
    if not button or not button.GetName then
        return nil
    end
    local name = button:GetName() or ""
    if string.find(name, "PlayerFrame", 1, true) then
        return "player"
    end
    if string.find(name, "TargetFrame", 1, true) then
        return "target"
    end
    local _, _, n = string.find(name, "PartyMemberFrame(%d+)")
    if n then
        return "party" .. n
    end
    return nil
end

function ConsoleUI_UnitMenu()
    if ConsoleUI.unit and ConsoleUI.unit.Busy and ConsoleUI.unit:Busy() then
        ConsoleUI.unit:Close()
        return
    end
    local unit = ConsoleUI.unit:UnitFromCursor() or "target"
    if not UnitExists or not UnitExists(unit) then
        return
    end
    ConsoleUI.unit:Open(unit)
end

local watch = CreateFrame("Frame")
watch:RegisterEvent("PLAYER_TARGET_CHANGED")
watch:RegisterEvent("PLAYER_LEAVING_WORLD")
watch:SetScript("OnEvent", function()
    if not ConsoleUI.unit or not ConsoleUI.unit.Busy or not ConsoleUI.unit:Busy() then
        return
    end
    if event == "PLAYER_LEAVING_WORLD" then
        ConsoleUI.unit:Close()
        return
    end
    local u = ConsoleUI.unit.unit
    if u and u ~= "player" and UnitExists and not UnitExists(u) then
        ConsoleUI.unit:Close()
    end
end)
