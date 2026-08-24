--[[
    Blizzard unit-frame scale. SetScale on each FrameXML unit frame.
    Pet / ToT / party pets are children — own scale is desired / parent chain
    so the sliders stay independent.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.config = ConsoleUI.config or {}
local Config = ConsoleUI.config

local function Count(t)
    if table.getn then
        return table.getn(t)
    end
    local n = 0
    local i = 1
    while t[i] ~= nil do
        n = i
        i = i + 1
    end
    return n
end

Config.UNIT_FRAME_SCALE_MIN = 0.5
Config.UNIT_FRAME_SCALE_MAX = 2.0

-- Parents first. group is settings-page layout only.
Config.UNIT_FRAMES = {
    { key = "unitFrameScalePlayer",    name = "Player",           frame = "PlayerFrame",              group = "player" },
    { key = "unitFrameScalePet",       name = "Pet",              frame = "PetFrame",                 group = "player" },
    { key = "unitFrameScaleTarget",    name = "Target",           frame = "TargetFrame",              group = "target" },
    { key = "unitFrameScaleToT",       name = "Target of Target", frame = "TargetofTargetFrame",      group = "target" },
    { key = "unitFrameScaleParty1",    name = "Party 1",          frame = "PartyMemberFrame1",        group = "party" },
    { key = "unitFrameScaleParty2",    name = "Party 2",          frame = "PartyMemberFrame2",        group = "party" },
    { key = "unitFrameScaleParty3",    name = "Party 3",          frame = "PartyMemberFrame3",        group = "party" },
    { key = "unitFrameScaleParty4",    name = "Party 4",          frame = "PartyMemberFrame4",        group = "party" },
    { key = "unitFrameScalePartyPet1", name = "Party 1 Pet",      frame = "PartyMemberFrame1PetFrame", group = "partypet" },
    { key = "unitFrameScalePartyPet2", name = "Party 2 Pet",      frame = "PartyMemberFrame2PetFrame", group = "partypet" },
    { key = "unitFrameScalePartyPet3", name = "Party 3 Pet",      frame = "PartyMemberFrame3PetFrame", group = "partypet" },
    { key = "unitFrameScalePartyPet4", name = "Party 4 Pet",      frame = "PartyMemberFrame4PetFrame", group = "partypet" },
}

Config.DEFAULTS = Config.DEFAULTS or {}
do
    local i
    for i = 1, Count(Config.UNIT_FRAMES) do
        local spec = Config.UNIT_FRAMES[i]
        if Config.DEFAULTS[spec.key] == nil then
            Config.DEFAULTS[spec.key] = 1.0
        end
    end
end
if Config.DEFAULTS.minimapScale == nil then
    Config.DEFAULTS.minimapScale = 1.0
end
if Config.DEFAULTS.buffScale == nil then
    Config.DEFAULTS.buffScale = 1.0
end
if Config.DEFAULTS.debuffScale == nil then
    Config.DEFAULTS.debuffScale = 1.0
end
if Config.DEFAULTS.buffXOffset == nil then
    Config.DEFAULTS.buffXOffset = 0
end
if Config.DEFAULTS.buffYOffset == nil then
    Config.DEFAULTS.buffYOffset = 0
end
if Config.DEFAULTS.debuffXOffset == nil then
    Config.DEFAULTS.debuffXOffset = 0
end
if Config.DEFAULTS.debuffYOffset == nil then
    Config.DEFAULTS.debuffYOffset = 0
end
if Config.DEFAULTS.minimapXOffset == nil then
    Config.DEFAULTS.minimapXOffset = 0
end
if Config.DEFAULTS.minimapYOffset == nil then
    Config.DEFAULTS.minimapYOffset = 0
end
if Config.DEFAULTS.petFrameXOffset == nil then
    Config.DEFAULTS.petFrameXOffset = 0
end
if Config.DEFAULTS.petFrameYOffset == nil then
    Config.DEFAULTS.petFrameYOffset = 0
end
Config.PET_FRAME_STOCK_X = 80
Config.PET_FRAME_STOCK_Y = -47

Config.MINIMAP_FRAMES = { "MinimapCluster", "Minimap" }
Config.MINIMAP_OFFSET_MIN = -2000
Config.MINIMAP_OFFSET_MAX = 2000
Config.BUFF_BUTTON_MAX = 32
Config.DEBUFF_BUTTON_MAX = 16
Config.BUFF_VANILLA_LAST = 15
Config.DEBUFF_VANILLA_FIRST = 16
Config.DEBUFF_VANILLA_LAST = 23
Config.BUFF_EXTRA = { "TempEnchant1", "TempEnchant2" }

function Config:ClampUnitFrameScale(value)
    local n = tonumber(value)
    if not n then
        n = 1.0
    end
    if n < Config.UNIT_FRAME_SCALE_MIN then
        n = Config.UNIT_FRAME_SCALE_MIN
    end
    if n > Config.UNIT_FRAME_SCALE_MAX then
        n = Config.UNIT_FRAME_SCALE_MAX
    end
    return n
end

function Config:ClampMinimapOffset(value)
    local n = tonumber(value)
    if not n then
        n = 0
    end
    if n < Config.MINIMAP_OFFSET_MIN then
        n = Config.MINIMAP_OFFSET_MIN
    end
    if n > Config.MINIMAP_OFFSET_MAX then
        n = Config.MINIMAP_OFFSET_MAX
    end
    if math.floor then
        n = math.floor(n + 0.5)
    end
    return n
end

-- Visual size vs UIParent = own * parentChain. Solve own so visual == desired.
function Config:UnitFrameOwnScale(desired, parentChain)
    desired = self:ClampUnitFrameScale(desired)
    parentChain = tonumber(parentChain) or 1
    if parentChain < 0.05 then
        parentChain = 0.05
    end
    return desired / parentChain
end

function Config:UnitFrameParentChainScale(frame)
    local s = 1
    if not frame or not frame.GetParent then
        return s
    end
    local p = frame:GetParent()
    while p and p ~= UIParent do
        if p.GetScale then
            s = s * (p:GetScale() or 1)
        end
        if p.GetParent then
            p = p:GetParent()
        else
            p = nil
        end
    end
    return s
end

function Config:WatchUnitFrame(frame)
    if not frame or frame.consoleUIUnitScale then
        return
    end
    frame.consoleUIUnitScale = true
    local prev = nil
    if frame.GetScript then
        prev = frame:GetScript("OnShow")
    end
    frame:SetScript("OnShow", function()
        if prev then
            prev()
        end
        if ConsoleUI.config and ConsoleUI.config.ApplyUnitFrameScales then
            ConsoleUI.config:ApplyUnitFrameScales()
        end
    end)
end

function Config:ApplyOneUnitFrame(spec)
    if not spec or not getglobal then
        return
    end
    local frame = getglobal(spec.frame)
    if not frame or not frame.SetScale then
        return
    end
    local desired = 1.0
    if self.Get then
        desired = self:Get(spec.key) or 1.0
    end
    desired = self:ClampUnitFrameScale(desired)
    local chain = self:UnitFrameParentChainScale(frame)
    frame:SetScale(self:UnitFrameOwnScale(desired, chain))
    self:WatchUnitFrame(frame)
    if spec.frame == "PetFrame" then
        self:ApplyPetFramePosition()
    end
end

function Config:HookPetFramePosition()
    if self._petFrameHooked then
        return
    end
    self._petFrameHooked = true
    if PetFrame_Update then
        local orig = PetFrame_Update
        PetFrame_Update = function()
            orig()
            if ConsoleUI.config and ConsoleUI.config.ApplyPetFramePosition then
                ConsoleUI.config:ApplyPetFramePosition()
            end
        end
    end
end

function Config:PetFrameStock(frame)
    if frame.consoleUIPetStock then
        return frame.consoleUIPetStock
    end
    local p, rel, rp, x, y
    if frame.GetPoint then
        p, rel, rp, x, y = frame:GetPoint(1)
    end
    if not p then
        p = "TOPLEFT"
        rel = getglobal("PlayerFrame") or UIParent
        rp = "TOPLEFT"
        x = self.PET_FRAME_STOCK_X
        y = self.PET_FRAME_STOCK_Y
    end
    frame.consoleUIPetStock = { p, rel, rp, tonumber(x) or 0, tonumber(y) or 0 }
    return frame.consoleUIPetStock
end

function Config:ApplyPetFramePosition()
    if self.petFramePosBusy then
        return
    end
    self.petFramePosBusy = true
    if getglobal then
        self:HookPetFramePosition()
        local frame = getglobal("PetFrame")
        if frame and frame.ClearAllPoints and frame.SetPoint then
            local ox = 0
            local oy = 0
            if self.Get then
                ox = self:Get("petFrameXOffset") or 0
                oy = self:Get("petFrameYOffset") or 0
            end
            ox = self:ClampMinimapOffset(ox)
            oy = self:ClampMinimapOffset(oy)
            if ox == 0 and oy == 0 and not frame.consoleUIPetMoved then
                if not frame.consoleUIPetStock then
                    self:PetFrameStock(frame)
                end
            else
                local stock = self:PetFrameStock(frame)
                frame:ClearAllPoints()
                frame:SetPoint(stock[1], stock[2], stock[3], stock[4] + ox, stock[5] + oy)
                if ox == 0 and oy == 0 then
                    frame.consoleUIPetMoved = nil
                else
                    frame.consoleUIPetMoved = true
                end
            end
        end
    end
    self.petFramePosBusy = nil
end

function Config:GetMinimapFrame()
    if not getglobal then
        return nil
    end
    local i
    for i = 1, Count(self.MINIMAP_FRAMES) do
        local candidate = getglobal(self.MINIMAP_FRAMES[i])
        if candidate and candidate.SetScale then
            return candidate
        end
    end
    return nil
end

function Config:ApplyMinimapPosition(frame)
    if not frame or not frame.ClearAllPoints or not frame.SetPoint or not UIParent then
        return
    end
    local x = 0
    local y = 0
    if self.Get then
        x = self:Get("minimapXOffset") or 0
        y = self:Get("minimapYOffset") or 0
    end
    x = self:ClampMinimapOffset(x)
    y = self:ClampMinimapOffset(y)
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", x, y)
end

function Config:ApplyMinimapScale()
    local desired = 1.0
    if self.Get then
        desired = self:Get("minimapScale") or 1.0
    end
    desired = self:ClampUnitFrameScale(desired)
    local frame = self:GetMinimapFrame()
    if not frame then
        return
    end
    local chain = self:UnitFrameParentChainScale(frame)
    frame:SetScale(self:UnitFrameOwnScale(desired, chain))
    self:ApplyMinimapPosition(frame)
    self:WatchUnitFrame(frame)
    local map = getglobal("Minimap")
    if map and map ~= frame and map.SetScale then
        map:SetScale(1)
    end
end

function Config:ApplyNamedScale(name, desired)
    if not getglobal or not name then
        return
    end
    local frame = getglobal(name)
    if not frame or not frame.SetScale then
        return
    end
    local chain = self:UnitFrameParentChainScale(frame)
    frame:SetScale(self:UnitFrameOwnScale(desired, chain))
    self:WatchUnitFrame(frame)
end

function Config:ApplyAuraPrefix(prefix, maxCount, desired)
    local i
    for i = 1, maxCount do
        self:ApplyNamedScale(prefix .. i, desired)
    end
end

function Config:ApplyAuraRange(prefix, first, last, desired)
    local i
    for i = first, last do
        self:ApplyNamedScale(prefix .. i, desired)
    end
end

function Config:HookAuraLayout()
    if self._auraLayoutHooked then
        return
    end
    self._auraLayoutHooked = true
    if BuffButtons_UpdatePositions then
        local orig = BuffButtons_UpdatePositions
        BuffButtons_UpdatePositions = function()
            orig()
            if ConsoleUI.config and ConsoleUI.config.ApplyAuraPositions then
                ConsoleUI.config:ApplyAuraPositions()
            end
        end
    end
end

function Config:DebuffRowStockY()
    if SHOW_BUFF_DURATIONS == "1" then
        return -90
    end
    return -70
end

function Config:ApplyAuraPositions()
    if not getglobal then
        return
    end
    local bx = 0
    local by = 0
    local dx = 0
    local dy = 0
    if self.Get then
        bx = self:Get("buffXOffset") or 0
        by = self:Get("buffYOffset") or 0
        dx = self:Get("debuffXOffset") or 0
        dy = self:Get("debuffYOffset") or 0
    end
    bx = self:ClampMinimapOffset(bx)
    by = self:ClampMinimapOffset(by)
    dx = self:ClampMinimapOffset(dx)
    dy = self:ClampMinimapOffset(dy)
    local host = getglobal("TemporaryEnchantFrame")
    if host and host.ClearAllPoints then
        if bx ~= 0 or by ~= 0 or host.consoleUIAuraMoved then
            local rel = getglobal("MinimapCluster") or UIParent
            local rp = getglobal("MinimapCluster") and "TOPLEFT" or "TOPRIGHT"
            host:ClearAllPoints()
            host:SetPoint("TOPRIGHT", rel, rp, bx, -13 + by)
            host.consoleUIAuraMoved = true
        end
    end
    local btn = getglobal("DebuffButton1") or getglobal("BuffButton16")
    if btn and btn.ClearAllPoints then
        if dx ~= 0 or dy ~= 0 or btn.consoleUIAuraMoved then
            local rel = getglobal("TemporaryEnchantFrame") or UIParent
            btn:ClearAllPoints()
            btn:SetPoint("TOPRIGHT", rel, "TOPRIGHT", dx, self:DebuffRowStockY() + dy)
            btn.consoleUIAuraMoved = true
        end
    end
end

function Config:ApplyAuraScales()
    if not getglobal then
        return
    end
    self:HookAuraLayout()
    local buffs = 1.0
    local debuffs = 1.0
    if self.Get then
        buffs = self:Get("buffScale") or 1.0
        debuffs = self:Get("debuffScale") or 1.0
    end
    buffs = self:ClampUnitFrameScale(buffs)
    debuffs = self:ClampUnitFrameScale(debuffs)
    if getglobal("DebuffButton1") then
        self:ApplyNamedScale("BuffButton0", buffs)
        self:ApplyAuraPrefix("BuffButton", self.BUFF_BUTTON_MAX, buffs)
        self:ApplyAuraPrefix("DebuffButton", self.DEBUFF_BUTTON_MAX, debuffs)
    else
        self:ApplyAuraRange("BuffButton", 0, self.BUFF_VANILLA_LAST, buffs)
        self:ApplyAuraRange("BuffButton", self.DEBUFF_VANILLA_FIRST, self.DEBUFF_VANILLA_LAST, debuffs)
    end
    local i
    for i = 1, Count(self.BUFF_EXTRA) do
        self:ApplyNamedScale(self.BUFF_EXTRA[i], buffs)
    end
    self:ApplyAuraPositions()
end

function Config:ApplyUnitFrameScales()
    if self.unitFrameScaleBusy then
        return
    end
    self.unitFrameScaleBusy = true
    local i
    for i = 1, Count(self.UNIT_FRAMES) do
        self:ApplyOneUnitFrame(self.UNIT_FRAMES[i])
    end
    self:ApplyMinimapScale()
    self:ApplyAuraScales()
    self:ApplyPetFramePosition()
    self.unitFrameScaleBusy = nil
end

function Config:ResetUnitFrameGroup(group)
    local i
    for i = 1, Count(self.UNIT_FRAMES) do
        local spec = self.UNIT_FRAMES[i]
        if spec.group == group then
            self:Set(spec.key, 1.0)
            if self.unitFrameScaleBoxes and self.unitFrameScaleBoxes[spec.key] then
                self.unitFrameScaleBoxes[spec.key]:SetText("1.0")
            end
        end
    end
    if group == "player" then
        self:Set("petFrameXOffset", 0)
        self:Set("petFrameYOffset", 0)
        if self.petFrameXBox then
            self.petFrameXBox:SetText("0")
        end
        if self.petFrameYBox then
            self.petFrameYBox:SetText("0")
        end
    end
    self:ApplyUnitFrameScales()
end

function Config:ResetMinimapSection()
    self:Set("minimapScale", 1.0)
    self:Set("minimapXOffset", 0)
    self:Set("minimapYOffset", 0)
    if self.minimapScaleBox then
        self.minimapScaleBox:SetText("1.0")
    end
    if self.minimapXBox then
        self.minimapXBox:SetText("0")
    end
    if self.minimapYBox then
        self.minimapYBox:SetText("0")
    end
    self:ApplyUnitFrameScales()
end

function Config:ResetAuraSection()
    self:Set("buffScale", 1.0)
    self:Set("debuffScale", 1.0)
    self:Set("buffXOffset", 0)
    self:Set("buffYOffset", 0)
    self:Set("debuffXOffset", 0)
    self:Set("debuffYOffset", 0)
    if self.unitFrameScaleBoxes then
        if self.unitFrameScaleBoxes.buffScale then
            self.unitFrameScaleBoxes.buffScale:SetText("1.0")
        end
        if self.unitFrameScaleBoxes.debuffScale then
            self.unitFrameScaleBoxes.debuffScale:SetText("1.0")
        end
    end
    if self.buffXBox then
        self.buffXBox:SetText("0")
    end
    if self.buffYBox then
        self.buffYBox:SetText("0")
    end
    if self.debuffXBox then
        self.debuffXBox:SetText("0")
    end
    if self.debuffYBox then
        self.debuffYBox:SetText("0")
    end
    self:ApplyUnitFrameScales()
end

function Config:ResetUnitFrameScales()
    local seen = {}
    local i
    for i = 1, Count(self.UNIT_FRAMES) do
        local group = self.UNIT_FRAMES[i].group
        if not seen[group] then
            seen[group] = true
            self:ResetUnitFrameGroup(group)
        end
    end
    self:ResetMinimapSection()
    self:ResetAuraSection()
end

function Config:EnsureUnitFrameScaleEvents()
    if self.unitFrameScaleEvents or not CreateFrame then
        return
    end
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    watcher:RegisterEvent("UNIT_PET")
    watcher:RegisterEvent("PARTY_MEMBERS_CHANGED")
    watcher:RegisterEvent("PLAYER_AURAS_CHANGED")
    watcher:RegisterEvent("UNIT_AURA")
    watcher:SetScript("OnEvent", function()
        local cfg = ConsoleUI.config
        if not cfg then
            return
        end
        if event == "PLAYER_AURAS_CHANGED" or event == "UNIT_AURA" then
            if cfg.ApplyAuraScales then
                cfg:ApplyAuraScales()
            end
            return
        end
        if cfg.ApplyUnitFrameScales then
            cfg:ApplyUnitFrameScales()
        end
    end)
    self.unitFrameScaleEvents = watcher
end

function Config:InitializeUnitFrameScales()
    self:EnsureUnitFrameScaleEvents()
    self:ApplyUnitFrameScales()
end

local function Mod(a, b)
    if math.mod then
        return math.mod(a, b)
    end
    return math.fmod(a, b)
end

function Config:CreateUnitFramesSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    local function MakeGet(key)
        return function()
            return string.format("%.1f", Config:Get(key) or 1.0)
        end
    end

    local function MakeSet(key)
        return function(value)
            Config:Set(key, Config:ClampUnitFrameScale(value))
            Config:ApplyUnitFrameScales()
        end
    end

    local function MakeChanged(key)
        return function()
            local num = tonumber(this:GetText())
            if num and num >= Config.UNIT_FRAME_SCALE_MIN and num <= Config.UNIT_FRAME_SCALE_MAX then
                Config:Set(key, Config:ClampUnitFrameScale(num))
                Config:ApplyUnitFrameScales()
            end
        end
    end

    local function AddScaleField(parent, spec, x, y)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        label:SetWidth(128)
        label:SetJustifyH("LEFT")
        label:SetText(T(spec.name))
        label:SetTextColor(unpack(self.UI_COLORS.muted))

        local box = self:CreateEditBox(
            parent,
            42,
            MakeGet(spec.key),
            MakeSet(spec.key),
            T(spec.name),
            T("1.0 is Blizzard default. Range: 0.5–2.0."),
            self.NUDGE_SCALE)
        box:ClearAllPoints()
        box:SetPoint("LEFT", label, "RIGHT", 4, 0)
        box:SetScript("OnTextChanged", MakeChanged(spec.key))
        self.unitFrameScaleBoxes[spec.key] = box
        return box
    end

    local function SpecsInGroup(group)
        local out = {}
        local i
        for i = 1, Count(self.UNIT_FRAMES) do
            local spec = self.UNIT_FRAMES[i]
            if spec.group == group then
                table.insert(out, spec)
            end
        end
        return out
    end

    local function FillGroupBox(box, group)
        local specs = SpecsInGroup(group)
        local n = Count(specs)
        local rowH = 28
        local colW = 310
        local i
        for i = 1, n do
            local row = math.floor((i - 1) / 2)
            local col = Mod(i - 1, 2)
            local x = box.contentLeft + col * colW
            local y = box.contentTop - row * rowH
            AddScaleField(box, specs[i], x, y)
        end
        local rows = math.floor((n + 1) / 2)
        if rows < 1 then
            rows = 1
        end
        return 28 + rows * rowH + box.bottomPadding
    end

    self.unitFrameScaleBoxes = {}

    local function AddOffsetField(parent, key, labelText, x, y, applyFn, tip)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        label:SetWidth(24)
        label:SetJustifyH("LEFT")
        label:SetText(labelText)
        label:SetTextColor(unpack(self.UI_COLORS.muted))

        local apply = applyFn or function()
            Config:ApplyMinimapScale()
        end
        local box = self:CreateEditBox(
            parent,
            50,
            function()
                return tostring(Config:Get(key) or 0)
            end,
            function(value)
                Config:Set(key, Config:ClampMinimapOffset(value))
                apply()
            end,
            labelText,
            tip or T("Offset from Blizzard's top-right corner, in screen pixels. Negative X is left, negative Y is down. Range: -2000 to 2000."),
            20)
        box:ClearAllPoints()
        box:SetPoint("LEFT", label, "RIGHT", 4, 0)
        box:SetScript("OnTextChanged", function()
            local num = tonumber(this:GetText())
            if num and num >= Config.MINIMAP_OFFSET_MIN and num <= Config.MINIMAP_OFFSET_MAX then
                Config:Set(key, Config:ClampMinimapOffset(num))
                apply()
            end
        end)
        return box
    end

    local minimapBox = self:CreateSectionBox(section, T("Minimap"))
    minimapBox:SetPoint("TOP", section, "TOP", 0, -6)
    local minimapSpec = { key = "minimapScale", name = "Size" }
    AddScaleField(minimapBox, minimapSpec, minimapBox.contentLeft, minimapBox.contentTop)
    self.minimapScaleBox = self.unitFrameScaleBoxes.minimapScale
    self.minimapXBox = AddOffsetField(minimapBox, "minimapXOffset", "X:", minimapBox.contentLeft, minimapBox.contentTop - 28)
    self.minimapYBox = AddOffsetField(minimapBox, "minimapYOffset", "Y:", minimapBox.contentLeft + 140, minimapBox.contentTop - 28)
    minimapBox:SetHeight(28 + 56 + minimapBox.bottomPadding)
    minimapBox.heightCalculated = true
    self:AddSectionReset(minimapBox, function()
        Config:ResetMinimapSection()
    end)

    local auraBox = self:CreateSectionBox(section, T("Buffs / Debuffs"))
    auraBox:ClearAllPoints()
    auraBox:SetPoint("TOPLEFT", minimapBox, "BOTTOMLEFT", 0, -6)
    auraBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    AddScaleField(auraBox, { key = "buffScale", name = "Buffs" }, auraBox.contentLeft, auraBox.contentTop)
    AddScaleField(auraBox, { key = "debuffScale", name = "Debuffs" }, auraBox.contentLeft + 310, auraBox.contentTop)
    local applyAuras = function()
        Config:ApplyAuraScales()
    end
    self.buffXBox = AddOffsetField(auraBox, "buffXOffset", "X:", auraBox.contentLeft, auraBox.contentTop - 28, applyAuras)
    self.buffYBox = AddOffsetField(auraBox, "buffYOffset", "Y:", auraBox.contentLeft + 140, auraBox.contentTop - 28, applyAuras)
    self.debuffXBox = AddOffsetField(auraBox, "debuffXOffset", "X:", auraBox.contentLeft + 310, auraBox.contentTop - 28, applyAuras)
    self.debuffYBox = AddOffsetField(auraBox, "debuffYOffset", "Y:", auraBox.contentLeft + 450, auraBox.contentTop - 28, applyAuras)
    auraBox:SetHeight(28 + 56 + auraBox.bottomPadding)
    auraBox.heightCalculated = true
    self:AddSectionReset(auraBox, function()
        Config:ResetAuraSection()
    end)

    local playerBox = self:CreateSectionBox(section, T("Player"))
    playerBox:ClearAllPoints()
    playerBox:SetPoint("TOPLEFT", auraBox, "BOTTOMLEFT", 0, -6)
    playerBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    local playerH = FillGroupBox(playerBox, "player")
    local applyPetFrame = function()
        Config:ApplyPetFramePosition()
    end
    local petTip = T("Offset from Blizzard's pet frame position, in screen pixels. Negative X is left, negative Y is down. Range: -2000 to 2000.")
    self.petFrameXBox = AddOffsetField(playerBox, "petFrameXOffset", "X:", playerBox.contentLeft + 310, playerBox.contentTop - 28, applyPetFrame, petTip)
    self.petFrameYBox = AddOffsetField(playerBox, "petFrameYOffset", "Y:", playerBox.contentLeft + 450, playerBox.contentTop - 28, applyPetFrame, petTip)
    playerBox:SetHeight(playerH + 28)
    playerBox.heightCalculated = true
    self:AddSectionReset(playerBox, function()
        Config:ResetUnitFrameGroup("player")
    end)

    local targetBox = self:CreateSectionBox(section, T("Target"))
    targetBox:ClearAllPoints()
    targetBox:SetPoint("TOPLEFT", playerBox, "BOTTOMLEFT", 0, -6)
    targetBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    targetBox:SetHeight(FillGroupBox(targetBox, "target"))
    targetBox.heightCalculated = true
    self:AddSectionReset(targetBox, function()
        Config:ResetUnitFrameGroup("target")
    end)

    local partyBox = self:CreateSectionBox(section, T("Party"))
    partyBox:ClearAllPoints()
    partyBox:SetPoint("TOPLEFT", targetBox, "BOTTOMLEFT", 0, -6)
    partyBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    partyBox:SetHeight(FillGroupBox(partyBox, "party"))
    partyBox.heightCalculated = true
    self:AddSectionReset(partyBox, function()
        Config:ResetUnitFrameGroup("party")
    end)

    local petBox = self:CreateSectionBox(section, T("Party Pets"))
    petBox:ClearAllPoints()
    petBox:SetPoint("TOPLEFT", partyBox, "BOTTOMLEFT", 0, -6)
    petBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    petBox:SetHeight(FillGroupBox(petBox, "partypet"))
    petBox.heightCalculated = true
    self:AddSectionReset(petBox, function()
        Config:ResetUnitFrameGroup("partypet")
    end)

    local hint = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("TOPLEFT", petBox, "BOTTOMLEFT", 4, -8)
    hint:SetPoint("RIGHT", section, "RIGHT", -8, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText(T("Each slider is independent. Pet and Target of Target do not inherit Player or Target scale."))
    hint:SetTextColor(unpack(self.UI_COLORS.muted))

    self.contentSections.unitframes = section
end
