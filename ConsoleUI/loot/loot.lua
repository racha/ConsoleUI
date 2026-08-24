--[[
    Custom loot + group roll. KeySq chrome. Soft wash, no panel.
    Pad: A loot / B close / X all + D-pad. Roll A need / X greed / B pass.
    Steal 1-8 while shown. Restore on hide. Memory only. Hide stock.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.loot = ConsoleUI.loot or {}
local Loot = ConsoleUI.loot

Loot.MAX_SLOTS = 16
Loot.MAX_ROLLS = 4
Loot.HIT = 48
Loot.ROW_H = 52
Loot.NAME_IDLE = 0.72
Loot.LOOT_X = 200
Loot.LOOT_Y = 40
Loot.ROLL_X = -220
Loot.ROLL_Y = -80
Loot.TIMER_H = 6
Loot.WHITE = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\White"
Loot.WASH = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\WashPanel"
Loot.WASH_PAD_X = 72
Loot.WASH_PAD_Y = 56
Loot.WASH_SCALE = 1.1
Loot.WASH_A = 0.70
Loot.WASH_DEEP_A = 0.10
Loot.BADGE = "Interface\\AddOns\\ConsoleUI\\textures\\radial\\CountBadge"

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local function Config()
    return ConsoleUI.config
end

local function Bars()
    return ConsoleUI.actionbars
end

local function GoldRGB()
    local cfg = Config()
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

function Loot:LootOn()
    local cfg = Config()
    if cfg and cfg.Get then
        return cfg:Get("lootFrameEnabled") ~= false
    end
    return true
end

function Loot:RollOn()
    local cfg = Config()
    if cfg and cfg.Get then
        return cfg:Get("lootRollEnabled") ~= false
    end
    return true
end

function Loot:LootShown()
    return self.lootHost and self.lootHost:IsShown()
end

function Loot:RollShown()
    return self.rollHost and self.rollHost:IsShown()
end

function Loot:Busy()
    return self:LootShown() or self:RollShown()
end

function Loot:OverlayOpen()
    if ConsoleUI.radial and ConsoleUI.radial.IsOpen and ConsoleUI.radial:IsOpen() then
        return true
    end
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        return true
    end
    return false
end

function Loot:CollectKeys(action)
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

function Loot:KeysForSlot(slot)
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

function Loot:PersistSlot(slot)
    if ConsoleUI_PersistPadAction then
        return ConsoleUI_PersistPadAction(slot)
    end
    return "ConsoleUI_ACTION_" .. slot
end

function Loot:StealPad()
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

function Loot:RestorePad()
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

function Loot:SyncPad()
    if self:Busy() and not self:OverlayOpen() then
        self:StealPad()
    else
        self:RestorePad()
    end
end

function Loot:QualityColor(quality)
    local c = ITEM_QUALITY_COLORS and quality and ITEM_QUALITY_COLORS[quality]
    if c then
        return c.r, c.g, c.b
    end
    return 1, 1, 1
end

function Loot:PaintFace(button)
    if not button or not button.faceIcon then
        return
    end
    if button.icon then
        button.icon:Hide()
    end
    if button.face then
        button.face:Hide()
    end
    self:SetBadge(button, 0)
    local parent = button.diamondChrome or button
    if not button.glyph then
        button.glyph = parent:CreateTexture(nil, "OVERLAY")
        button.glyph:SetPoint("CENTER", button, "CENTER", 0, 0)
    end
    local sz = 22
    if ConsoleUI.hints and ConsoleUI.hints.Size then
        sz = ConsoleUI.hints:Size()
    elseif ConsoleUI.config and ConsoleUI.config.GetGlyphSize then
        sz = ConsoleUI.config:GetGlyphSize("hud")
    end
    local cap = self.HIT - 14
    if sz > cap then
        sz = cap
    end
    local path
    if ConsoleUI.hints and ConsoleUI.hints.IconPath then
        path = ConsoleUI.hints:IconPath(button.faceIcon)
    elseif ConsoleUI.config and ConsoleUI.config.GetControllerIconPath then
        path = ConsoleUI.config:GetControllerIconPath(button.faceIcon)
    end
    button.glyph:SetWidth(sz)
    button.glyph:SetHeight(sz)
    button.glyph:SetTexture(path)
    button.glyph:SetTexCoord(0, 1, 0, 1)
    button.glyph:SetVertexColor(1, 1, 1)
    button.glyph:SetAlpha(1)
    button.glyph:Show()
end

function Loot:PaintSquare(button, selected)
    if not button then
        return
    end
    local bars = Bars()
    if bars and bars.ApplySquareAppearance then
        bars:ApplySquareAppearance(button)
    end
    if button.diamondPlate then
        PaintTex(button.diamondPlate, 0, 0, 0, 1)
    end
    if button.diamondRim then
        PaintTex(button.diamondRim, 0, 0, 0, 1)
        button.diamondRim:Show()
    end
    if button.diamondRing then
        if selected then
            local r, g, b = GoldRGB()
            PaintTex(button.diamondRing, r, g, b, 1)
            button.diamondRing:Show()
        else
            button.diamondRing:Hide()
        end
    end
    if bars and bars.RaiseDiamondChrome then
        bars:RaiseDiamondChrome(button)
    end
    if button.icon then
        local size = self.HIT - 14
        local lay = bars and bars.Layout
        if lay and lay.SquareIconSize then
            size = lay.SquareIconSize(self.HIT)
        end
        button.icon:SetWidth(size)
        button.icon:SetHeight(size)
        button.icon:SetAlpha(1)
        button.icon:SetDrawLayer("ARTWORK")
    end
end

function Loot:AttachBadge(button)
    if not button or button.countBadge or not button.icon then
        return
    end
    local badge = button:CreateTexture(nil, "OVERLAY")
    badge:SetWidth(16)
    badge:SetHeight(16)
    badge:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 3, -3)
    badge:SetTexture(self.BADGE)
    badge:SetVertexColor(0, 0, 0)
    badge:SetAlpha(1)
    badge:Hide()
    button.countBadge = badge
    local text = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    text:SetPoint("CENTER", badge, "CENTER", 0, 0)
    text:SetTextColor(1, 1, 1)
    text:Hide()
    button.countText = text
end

function Loot:SetBadge(button, count)
    if not button or not button.countBadge then
        return
    end
    count = tonumber(count) or 0
    if count > 1 then
        button.countBadge:Show()
        button.countText:Show()
        button.countText:SetText(tostring(count))
        button.countText:SetTextColor(1, 1, 1)
    else
        button.countBadge:Hide()
        button.countText:Hide()
    end
end

function Loot:MakeSquare(parent, name)
    local button = CreateFrame("Button", name, parent)
    button:SetWidth(self.HIT)
    button:SetHeight(self.HIT)
    local icon = button:CreateTexture(name .. "Icon", "ARTWORK")
    icon:SetWidth(self.HIT)
    icon:SetHeight(self.HIT)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.icon = icon
    button:RegisterForClicks("LeftButtonUp")
    button:EnableMouse(true)
    self:AttachBadge(button)
    return button
end

function Loot:PinWash(tex, host, w, h, a)
    if not tex then
        return
    end
    tex:ClearAllPoints()
    tex:SetWidth(w)
    tex:SetHeight(h)
    tex:SetPoint("CENTER", host, "CENTER", 0, 0)
    PaintTex(tex, 0, 0, 0, a)
end

function Loot:FitWash(host)
    if not host or not host.wash then
        return
    end
    local w = ((host:GetWidth() or 320) + self.WASH_PAD_X) * self.WASH_SCALE
    local h = ((host:GetHeight() or 80) + self.WASH_PAD_Y) * self.WASH_SCALE
    self:PinWash(host.wash, host, w, h, self.WASH_A)
    self:PinWash(host.washDeep, host, w, h, self.WASH_DEEP_A)
end

function Loot:MakeWash(host)
    local wash = host:CreateTexture(nil, "BACKGROUND")
    wash:SetTexture(self.WASH)
    host.wash = wash
    local deep = host:CreateTexture(nil, "BACKGROUND")
    deep:SetTexture(self.WASH)
    host.washDeep = deep
    self:FitWash(host)
end

function Loot:EnsureLoot()
    if self.lootHost then
        return
    end
    local host = CreateFrame("Frame", "ConsoleUILootFrame", UIParent)
    host:SetFrameStrata("FULLSCREEN_DIALOG")
    host:SetFrameLevel(200)
    host:SetWidth(320)
    host:SetHeight(80)
    host:SetPoint("CENTER", UIParent, "CENTER", self.LOOT_X, self.LOOT_Y)
    host:EnableMouse(false)
    host:Hide()
    host:SetScript("OnHide", function()
        Loot:OnLootHide()
    end)

    self:MakeWash(host)

    local title = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -2)
    title:SetText(T("Loot"))
    host.title = title

    local rule = host:CreateTexture(nil, "ARTWORK")
    rule:SetTexture(self.WHITE)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    rule:SetPoint("RIGHT", host, "RIGHT", -8, 0)
    host.titleRule = rule

    host.rows = {}
    local i
    for i = 1, self.MAX_SLOTS do
        local row = CreateFrame("Button", "ConsoleUILootRow" .. i, host)
        row:SetWidth(300)
        row:SetHeight(self.ROW_H)
        row:RegisterForClicks("LeftButtonUp")
        row:EnableMouse(true)
        row:Hide()
        local square = self:MakeSquare(row, "ConsoleUILootButton" .. i)
        square:SetPoint("LEFT", row, "LEFT", 0, 0)
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", square, "RIGHT", 10, 0)
        name:SetJustifyH("LEFT")
        local sep = row:CreateTexture(nil, "ARTWORK")
        sep:SetTexture(self.WHITE)
        sep:SetHeight(1)
        sep:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
        sep:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        PaintTex(sep, 1, 1, 1, 0.08)
        row.square = square
        row.name = name
        row.sep = sep
        row:SetScript("OnClick", function()
            Loot:ClickSlot(this.lootSlot)
        end)
        row:SetScript("OnEnter", function()
            Loot:HoverSlot(this.lootSlot, this.square)
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        square:SetScript("OnClick", function()
            Loot:ClickSlot(this.lootSlot)
        end)
        square:SetScript("OnEnter", function()
            Loot:HoverSlot(this.lootSlot, this)
        end)
        square:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        host.rows[i] = row
    end

    local hintRule = host:CreateTexture(nil, "ARTWORK")
    hintRule:SetTexture(self.WHITE)
    hintRule:SetHeight(1)
    hintRule:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 4, 30)
    hintRule:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -8, 30)
    PaintTex(hintRule, 1, 1, 1, 0.08)
    host.hintRule = hintRule

    host.hintX = 4
    host.hintY = 6
    if ConsoleUI.hints and ConsoleUI.hints.Attach then
        ConsoleUI.hints:Attach(host)
    end

    self.lootHost = host
    self:DropSpecialFrame("ConsoleUILootFrame")
end

function Loot:EnsureRolls()
    if self.rollHost then
        return
    end
    local host = CreateFrame("Frame", "ConsoleUIRollHost", UIParent)
    host:SetFrameStrata("HIGH")
    host:SetWidth(280)
    host:SetHeight(160)
    host:SetPoint("CENTER", UIParent, "CENTER", self.ROLL_X, self.ROLL_Y)
    host:EnableMouse(false)
    host:Hide()
    host:SetScript("OnUpdate", function()
        Loot:OnRollUpdate()
    end)

    self:MakeWash(host)

    local title = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -2)
    title:SetText(T("Roll"))
    host.title = title

    local rule = host:CreateTexture(nil, "ARTWORK")
    rule:SetTexture(self.WHITE)
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    rule:SetPoint("RIGHT", host, "RIGHT", -8, 0)
    host.titleRule = rule

    host.cards = {}
    local i
    for i = 1, self.MAX_ROLLS do
        local card = CreateFrame("Frame", "ConsoleUIRollFrame" .. i, host)
        card:SetWidth(260)
        card:SetHeight(120)
        card:Hide()

        local item = self:MakeSquare(card, "ConsoleUIRollItem" .. i)
        item:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
        item:SetScript("OnEnter", function()
            Loot:RollItemTip(this.rollId)
        end)
        item:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", item, "RIGHT", 10, 0)
        name:SetJustifyH("LEFT")

        local need = self:MakeSquare(card, "ConsoleUIRollNeed" .. i)
        need:SetPoint("TOPLEFT", item, "BOTTOMLEFT", 0, -10)
        local greed = self:MakeSquare(card, "ConsoleUIRollGreed" .. i)
        greed:SetPoint("LEFT", need, "RIGHT", 12, 0)
        local pass = self:MakeSquare(card, "ConsoleUIRollPass" .. i)
        pass:SetPoint("LEFT", greed, "RIGHT", 12, 0)

        need.faceIcon = "a"
        greed.faceIcon = "x"
        pass.faceIcon = "b"

        local function Lab(anchor, key)
            local fs = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            fs:SetPoint("TOP", anchor, "BOTTOM", 0, -4)
            fs:SetText(T(key))
            fs:SetTextColor(0.55, 0.55, 0.55)
            return fs
        end
        card.needLab = Lab(need, "Need")
        card.greedLab = Lab(greed, "Greed")
        card.passLab = Lab(pass, "Pass")

        need:SetScript("OnClick", function()
            Loot:DoRoll(this.rollId, 1)
        end)
        greed:SetScript("OnClick", function()
            Loot:DoRoll(this.rollId, 2)
        end)
        pass:SetScript("OnClick", function()
            Loot:DoRoll(this.rollId, 0)
        end)

        local track = card:CreateTexture(nil, "ARTWORK")
        track:SetTexture(self.WHITE)
        track:SetHeight(self.TIMER_H)
        track:SetWidth(220)
        track:SetPoint("TOPLEFT", need, "BOTTOMLEFT", 0, -22)
        PaintTex(track, 0.04, 0.04, 0.05, 1)
        local fill = card:CreateTexture(nil, "OVERLAY")
        fill:SetTexture(self.WHITE)
        fill:SetHeight(self.TIMER_H)
        fill:SetPoint("TOPLEFT", track, "TOPLEFT", 0, 0)
        fill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", 0, 0)
        fill:SetWidth(220)

        card.item = item
        card.name = name
        card.need = need
        card.greed = greed
        card.pass = pass
        card.track = track
        card.fill = fill
        host.cards[i] = card
    end

    self.rollHost = host
    self.rolls = {}
    self.rollSel = 1
end

function Loot:PaintTitle(fs)
    if not fs then
        return
    end
    local r, g, b = GoldRGB()
    fs:SetTextColor(r, g, b)
end

function Loot:PaintHints()
    local host = self.lootHost
    if not host then
        return
    end
    if ConsoleUI.hints and ConsoleUI.hints.Paint then
        ConsoleUI.hints:Paint(host, {
            { icon = "a", prompt = T("Loot") },
            { icon = "b", prompt = T("Close") },
            { icon = "x", prompt = T("All") },
        })
    end
    local r, g, b = GoldRGB()
    if host.titleRule then
        PaintTex(host.titleRule, r, g, b, 0.22)
    end
    self:PaintTitle(host.title)
    if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then
        ConsoleUI.cursor.hintbar:Refresh()
    end
end

function Loot:PaintChrome()
    self:PaintHints()
    if self:LootShown() then
        self:PaintLootRows()
    end
    if self.rollHost then
        self:PaintTitle(self.rollHost.title)
        local r, g, b = GoldRGB()
        if self.rollHost.titleRule then
            PaintTex(self.rollHost.titleRule, r, g, b, 0.22)
        end
        self:PaintRollCards()
    end
end

function Loot:LootCount()
    return GetNumLootItems and (GetNumLootItems() or 0) or 0
end

function Loot:VisibleSlots()
    local out = {}
    local n = self:LootCount()
    local i
    for i = 1, n do
        table.insert(out, i)
    end
    return out
end

function Loot:HasSlot(slot)
    local vis = self:VisibleSlots()
    local i
    for i = 1, table.getn(vis) do
        if vis[i] == slot then
            return true
        end
    end
    return false
end

function Loot:ClickSlot(slot)
    if not slot or not LootSlot then
        return
    end
    LootSlot(slot)
end

function Loot:HoverSlot(slot, owner)
    if not slot then
        return
    end
    self.sel = slot
    self:PaintLootRows()
    if LootSlotIsCoin and LootSlotIsCoin(slot) then
        GameTooltip:Hide()
        return
    end
    if not owner then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if GameTooltip.SetLootItem then
        GameTooltip:SetLootItem(slot)
    end
    GameTooltip:Show()
end

function Loot:LootSelected()
    if self.sel then
        self:ClickSlot(self.sel)
    end
end

function Loot:LootAll()
    if not LootSlot then
        return
    end
    local n = GetNumLootItems and (GetNumLootItems() or 0) or 0
    local i
    for i = n, 1, -1 do
        LootSlot(i)
    end
end

function Loot:MoveSel(delta)
    local vis = self:VisibleSlots()
    local n = table.getn(vis)
    if n < 1 then
        return
    end
    local at = 1
    local i
    for i = 1, n do
        if vis[i] == self.sel then
            at = i
            break
        end
    end
    at = at + (delta or 1)
    if at < 1 then
        at = n
    end
    if at > n then
        at = 1
    end
    self.sel = vis[at]
    self:PaintLootRows()
end

function Loot:PaintLootRows()
    local host = self.lootHost
    if not host then
        return
    end
    local vis = self:VisibleSlots()
    local n = table.getn(vis)
    if n < 1 then
        return
    end
    if not self.sel or not self:HasSlot(self.sel) then
        self.sel = vis[1]
    end
    local i
    for i = 1, self.MAX_SLOTS do
        local row = host.rows[i]
        if i <= n then
            local slot = vis[i]
            local texture, item, quantity, quality, locked = GetLootSlotInfo(slot)
            row.lootSlot = slot
            row.square.lootSlot = slot
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -28 - (i - 1) * self.ROW_H)
            row:Show()
            if row.square.icon then
                if texture then
                    row.square.icon:SetTexture(texture)
                    row.square.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    if locked then
                        row.square.icon:SetVertexColor(0.5, 0.5, 0.5)
                    else
                        row.square.icon:SetVertexColor(1, 1, 1)
                    end
                    row.square.icon:Show()
                else
                    row.square.icon:Hide()
                end
            end
            self:SetBadge(row.square, quantity)
            self:PaintSquare(row.square, slot == self.sel)
            local r, g, b = self:QualityColor(quality)
            row.name:SetText(item or "")
            if slot == self.sel then
                row.name:SetTextColor(r, g, b)
            else
                row.name:SetTextColor(r * self.NAME_IDLE, g * self.NAME_IDLE, b * self.NAME_IDLE)
            end
            if i < n then
                row.sep:Show()
            else
                row.sep:Hide()
            end
        else
            row:Hide()
        end
    end
    host:SetWidth(320)
    host:SetHeight(28 + n * self.ROW_H + 36)
    self:FitWash(host)
    self:PaintHints()
end

function Loot:ShowLoot()
    self:EnsureLoot()
    if ConsoleUI.unit and ConsoleUI.unit.Close then
        ConsoleUI.unit:Close()
    end
    if self:LootCount() < 1 then
        self:HideLoot()
        return
    end
    self:PaintLootRows()
    self._hiding = true
    self.lootHost:Show()
    self._hiding = nil
    self:SyncPad()
end

function Loot:HideLoot()
    if self.lootHost then
        self._hiding = true
        self.lootHost:Hide()
        self._hiding = nil
    end
    self.sel = nil
    self:SyncPad()
end

function Loot:OnLootHide()
    return
end

function Loot:UpdateLoot()
    if not self:LootOn() then
        return
    end
    if self:LootCount() < 1 then
        self:HideLoot()
        return
    end
    self:ShowLoot()
end

function Loot:RequestClose()
    self._hiding = true
    self:HideLoot()
    if CloseLoot then
        CloseLoot()
    end
    self._hiding = nil
end

function Loot:FindRoll(id)
    local i
    for i = 1, table.getn(self.rolls or {}) do
        if self.rolls[i].id == id then
            return i, self.rolls[i]
        end
    end
    return nil
end

function Loot:RemoveRoll(id)
    local at = self:FindRoll(id)
    if not at then
        return
    end
    table.remove(self.rolls, at)
    if self.rollSel > table.getn(self.rolls) then
        self.rollSel = table.getn(self.rolls)
    end
    if self.rollSel < 1 then
        self.rollSel = 1
    end
    self:PaintRollCards()
end

function Loot:DoRoll(id, kind)
    if not id or not RollOnLoot then
        return
    end
    RollOnLoot(id, kind)
end

function Loot:RollSelected(kind)
    local row = self.rolls and self.rolls[self.rollSel]
    if row then
        self:DoRoll(row.id, kind)
    end
end

function Loot:MoveRoll(delta)
    local n = table.getn(self.rolls or {})
    if n < 1 then
        return
    end
    local at = (self.rollSel or 1) + (delta or 1)
    if at < 1 then
        at = n
    end
    if at > n then
        at = 1
    end
    self.rollSel = at
    self:PaintRollCards()
end

function Loot:RollItemTip(id)
    if not id then
        return
    end
    local card = self.rollHost and self.rollHost.cards[self:FindRoll(id) or 0]
    local owner = card and card.item
    if not owner then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if GameTooltip.SetLootRollItem then
        GameTooltip:SetLootRollItem(id)
    end
    GameTooltip:Show()
end

function Loot:RollTimeLeft(row)
    if not row then
        return 0, 1
    end
    local dur = row.duration or 1
    if dur <= 0 then
        dur = 1
    end
    local left = dur
    if GetLootRollTimeLeft then
        left = GetLootRollTimeLeft(row.id) or left
    elseif GetTime and row.t0 then
        left = dur - (GetTime() - row.t0) * 1000
    end
    if left < 0 then
        left = 0
    end
    return left, dur
end

function Loot:PaintRollCards()
    local host = self.rollHost
    if not host then
        return
    end
    local n = table.getn(self.rolls or {})
    local i
    local y = -28
    for i = 1, self.MAX_ROLLS do
        local card = host.cards[i]
        local row = self.rolls[i]
        if row then
            local texture, name, count, quality = GetLootRollItemInfo(row.id)
            card.item.rollId = row.id
            card.need.rollId = row.id
            card.greed.rollId = row.id
            card.pass.rollId = row.id
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", host, "TOPLEFT", 4, y)
            card:Show()
            if card.item.icon then
                if texture then
                    card.item.icon:SetTexture(texture)
                    card.item.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    card.item.icon:SetVertexColor(1, 1, 1)
                    card.item.icon:Show()
                else
                    card.item.icon:Hide()
                end
            end
            self:SetBadge(card.item, count)
            self:PaintSquare(card.item, i == self.rollSel)
            local r, g, b = self:QualityColor(quality)
            card.name:SetText(name or "")
            if i == self.rollSel then
                card.name:SetTextColor(r, g, b)
            else
                card.name:SetTextColor(r * self.NAME_IDLE, g * self.NAME_IDLE, b * self.NAME_IDLE)
            end
            self:PaintSquare(card.need, false)
            self:PaintSquare(card.greed, false)
            self:PaintSquare(card.pass, false)
            self:PaintFace(card.need)
            self:PaintFace(card.greed)
            self:PaintFace(card.pass)
            local left, dur = self:RollTimeLeft(row)
            local pct = left / dur
            if pct < 0 then
                pct = 0
            end
            if pct > 1 then
                pct = 1
            end
            card.fill:SetWidth(220 * pct)
            local gr, gg, gb = GoldRGB()
            PaintTex(card.fill, gr, gg, gb, 1)
            y = y - 128
        else
            card:Hide()
        end
    end
    if n < 1 then
        host:Hide()
        self:SyncPad()
        return
    end
    host:SetHeight(28 + n * 128)
    self:FitWash(host)
    host:Show()
    self:SyncPad()
end

function Loot:OnRollUpdate()
    if not self:RollShown() then
        return
    end
    local i
    for i = 1, table.getn(self.rolls or {}) do
        local card = self.rollHost.cards[i]
        local row = self.rolls[i]
        if card and row then
            local left, dur = self:RollTimeLeft(row)
            local pct = left / dur
            if pct < 0 then
                pct = 0
            end
            card.fill:SetWidth(220 * pct)
        end
    end
end

function Loot:AddRoll(id, duration)
    if not id then
        return
    end
    if self:FindRoll(id) then
        return
    end
    if table.getn(self.rolls) >= self.MAX_ROLLS then
        return
    end
    table.insert(self.rolls, {
        id = id,
        duration = duration or 60000,
        t0 = GetTime and GetTime() or 0,
    })
    if table.getn(self.rolls) == 1 then
        self.rollSel = 1
    end
    self:PaintRollCards()
end

function Loot:ConsumePad(slot)
    if not self:Busy() then
        return false
    end
    if self:OverlayOpen() then
        return false
    end
    if self:LootShown() then
        if slot == 1 then
            self:LootSelected()
            return true
        end
        if slot == 2 then
            self:LootAll()
            return true
        end
        if slot == 4 then
            self:RequestClose()
            return true
        end
        if slot == 5 then
            self:MoveSel(1)
            return true
        end
        if slot == 7 then
            self:MoveSel(-1)
            return true
        end
        return true
    end
    if slot == 1 then
        self:RollSelected(1)
        return true
    end
    if slot == 2 then
        self:RollSelected(2)
        return true
    end
    if slot == 4 then
        self:RollSelected(0)
        return true
    end
    if slot == 5 then
        self:MoveRoll(1)
        return true
    end
    if slot == 7 then
        self:MoveRoll(-1)
        return true
    end
    return true
end

function Loot:DropSpecialFrame(name)
    if not UISpecialFrames or not name then
        return
    end
    local i
    for i = table.getn(UISpecialFrames), 1, -1 do
        if UISpecialFrames[i] == name then
            table.remove(UISpecialFrames, i)
        end
    end
end

function Loot:HookEscape()
    if self._escHooked or not CloseSpecialWindows then
        return
    end
    self._escHooked = true
    local orig = CloseSpecialWindows
    CloseSpecialWindows = function()
        local closed = orig()
        if Loot:LootShown() then
            Loot:RequestClose()
            return 1
        end
        return closed
    end
end

function Loot:HookStockLoot()
    if not LootFrame or self._lootHooked then
        return
    end
    self._lootHooked = true
    self._lootOnShow = LootFrame:GetScript("OnShow")
    self._lootOnHide = LootFrame:GetScript("OnHide")
    self._lootOnEvent = LootFrame:GetScript("OnEvent")
    LootFrame:SetScript("OnEvent", function()
        if Loot:LootOn() then
            return
        end
        if Loot._lootOnEvent then
            Loot._lootOnEvent()
        end
    end)
    LootFrame:SetScript("OnShow", function()
        if Loot:LootOn() then
            this:Hide()
            return
        end
        if Loot._lootOnShow then
            Loot._lootOnShow()
        end
    end)
    LootFrame:SetScript("OnHide", function()
        if Loot:LootOn() then
            return
        end
        if Loot._lootOnHide then
            Loot._lootOnHide()
        end
    end)
    if LootFrame_OnEvent and not self._lootEventWrapped then
        self._lootEventWrapped = true
        local orig = LootFrame_OnEvent
        LootFrame_OnEvent = function()
            if Loot:LootOn() then
                return
            end
            orig()
        end
    end
end

function Loot:HookStockRoll()
    local i
    for i = 1, 4 do
        local f = getglobal("GroupLootFrame" .. i)
        if f and not f._cuiLootHooked then
            f._cuiLootHooked = true
            f._cuiOnShow = f:GetScript("OnShow")
            f:SetScript("OnShow", function()
                if Loot:RollOn() then
                    this:Hide()
                    return
                end
                if this._cuiOnShow then
                    this._cuiOnShow()
                end
            end)
        end
    end
end

function Loot:ApplyStockLoot()
    if not LootFrame then
        return
    end
    self:HookStockLoot()
    if self:LootOn() then
        LootFrame:UnregisterEvent("LOOT_OPENED")
        LootFrame:UnregisterEvent("LOOT_SLOT_CLEARED")
        LootFrame:UnregisterEvent("LOOT_CLOSED")
        LootFrame:Hide()
    else
        self._hiding = true
        self:HideLoot()
        self._hiding = nil
        LootFrame:RegisterEvent("LOOT_OPENED")
        LootFrame:RegisterEvent("LOOT_SLOT_CLEARED")
        LootFrame:RegisterEvent("LOOT_CLOSED")
        local n = GetNumLootItems and (GetNumLootItems() or 0) or 0
        if n > 0 then
            if LootFrame_Update then
                LootFrame_Update()
            end
            if ShowUIPanel then
                ShowUIPanel(LootFrame)
            else
                LootFrame:Show()
            end
        end
    end
end

function Loot:ApplyStockRoll()
    self:HookStockRoll()
    if self:RollOn() then
        local i
        for i = 1, 4 do
            local f = getglobal("GroupLootFrame" .. i)
            if f then
                if f.rollID and not self:FindRoll(f.rollID) then
                    self:AddRoll(f.rollID, f.rollTime)
                end
                f:Hide()
            end
        end
        if table.getn(self.rolls or {}) > 0 then
            self:PaintRollCards()
        end
        return
    end
    if self.rollHost then
        self.rollHost:Hide()
    end
    local i
    for i = 1, table.getn(self.rolls or {}) do
        local row = self.rolls[i]
        if GroupLootFrame_OpenNewFrame and row then
            GroupLootFrame_OpenNewFrame(row.id, row.duration)
        end
    end
end

function Loot:ApplyEnabled()
    self:EnsureLoot()
    self:EnsureRolls()
    self:ApplyStockLoot()
    self:ApplyStockRoll()
    if self:LootOn() and GetNumLootItems and (GetNumLootItems() or 0) > 0 then
        self:UpdateLoot()
    end
    self:SyncPad()
end

function Loot:DeferLoot()
    if self._defer then
        return
    end
    local f = CreateFrame("Frame")
    self._defer = f
    f.n = 0
    f:SetScript("OnUpdate", function()
        this.n = this.n + 1
        if this.n < 2 then
            return
        end
        this:SetScript("OnUpdate", nil)
        Loot._defer = nil
        if Loot:LootOn() then
            Loot:UpdateLoot()
        end
    end)
end

function Loot:OnEvent()
    if event == "LOOT_OPENED" then
        if not self:LootOn() then
            return
        end
        self:UpdateLoot()
        if self:LootCount() < 1 then
            self:DeferLoot()
        end
    elseif event == "LOOT_SLOT_CLEARED" then
        if not self:LootOn() then
            return
        end
        self:UpdateLoot()
    elseif event == "LOOT_CLOSED" then
        self._hiding = true
        self:HideLoot()
        self._hiding = nil
    elseif event == "START_LOOT_ROLL" then
        if not self:RollOn() then
            return
        end
        self:AddRoll(arg1, arg2)
    elseif event == "CANCEL_LOOT_ROLL" then
        self:RemoveRoll(arg1)
    end
end

function Loot:EnsureWatcher()
    if self.watcher then
        return
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("LOOT_OPENED")
    f:RegisterEvent("LOOT_SLOT_CLEARED")
    f:RegisterEvent("LOOT_CLOSED")
    f:RegisterEvent("START_LOOT_ROLL")
    f:RegisterEvent("CANCEL_LOOT_ROLL")
    f:SetScript("OnEvent", function()
        Loot:OnEvent()
    end)
    self.watcher = f
end

function Loot:Initialize()
    self.rolls = self.rolls or {}
    self:EnsureLoot()
    self:EnsureRolls()
    self:EnsureWatcher()
    self:HookEscape()
    self:ApplyEnabled()
    self:PaintChrome()
end
