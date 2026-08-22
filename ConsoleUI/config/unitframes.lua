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
if Config.DEFAULTS.minimapXOffset == nil then
    Config.DEFAULTS.minimapXOffset = 0
end
if Config.DEFAULTS.minimapYOffset == nil then
    Config.DEFAULTS.minimapYOffset = 0
end

Config.MINIMAP_FRAMES = { "MinimapCluster", "Minimap" }
Config.MINIMAP_OFFSET_MIN = -2000
Config.MINIMAP_OFFSET_MAX = 2000
Config.BUFF_BUTTON_MAX = 32
Config.DEBUFF_BUTTON_MAX = 16
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

function Config:ApplyAuraScales()
    if not getglobal then
        return
    end
    local buffs = 1.0
    local debuffs = 1.0
    if self.Get then
        buffs = self:Get("buffScale") or 1.0
        debuffs = self:Get("debuffScale") or 1.0
    end
    buffs = self:ClampUnitFrameScale(buffs)
    debuffs = self:ClampUnitFrameScale(debuffs)
    self:ApplyAuraPrefix("BuffButton", self.BUFF_BUTTON_MAX, buffs)
    self:ApplyAuraPrefix("DebuffButton", self.DEBUFF_BUTTON_MAX, debuffs)
    local i
    for i = 1, Count(self.BUFF_EXTRA) do
        self:ApplyNamedScale(self.BUFF_EXTRA[i], buffs)
    end
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
    if self.unitFrameScaleBoxes then
        if self.unitFrameScaleBoxes.buffScale then
            self.unitFrameScaleBoxes.buffScale:SetText("1.0")
        end
        if self.unitFrameScaleBoxes.debuffScale then
            self.unitFrameScaleBoxes.debuffScale:SetText("1.0")
        end
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

    local function AddOffsetField(parent, key, labelText, x, y)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        label:SetWidth(24)
        label:SetJustifyH("LEFT")
        label:SetText(labelText)
        label:SetTextColor(unpack(self.UI_COLORS.muted))

        local box = self:CreateEditBox(
            parent,
            50,
            function()
                return tostring(Config:Get(key) or 0)
            end,
            function(value)
                Config:Set(key, Config:ClampMinimapOffset(value))
                Config:ApplyMinimapScale()
            end,
            T("Minimap") .. " " .. labelText,
            T("Offset from Blizzard's top-right corner, in screen pixels. Negative X is left, negative Y is down. Range: -2000 to 2000."),
            20)
        box:ClearAllPoints()
        box:SetPoint("LEFT", label, "RIGHT", 4, 0)
        box:SetScript("OnTextChanged", function()
            local num = tonumber(this:GetText())
            if num and num >= Config.MINIMAP_OFFSET_MIN and num <= Config.MINIMAP_OFFSET_MAX then
                Config:Set(key, Config:ClampMinimapOffset(num))
                Config:ApplyMinimapScale()
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
    auraBox:SetHeight(28 + 28 + auraBox.bottomPadding)
    auraBox.heightCalculated = true
    self:AddSectionReset(auraBox, function()
        Config:ResetAuraSection()
    end)

    local playerBox = self:CreateSectionBox(section, T("Player"))
    playerBox:ClearAllPoints()
    playerBox:SetPoint("TOPLEFT", auraBox, "BOTTOMLEFT", 0, -6)
    playerBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    playerBox:SetHeight(FillGroupBox(playerBox, "player"))
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
