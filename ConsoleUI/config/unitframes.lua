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

function Config:ApplyUnitFrameScales()
    if self.unitFrameScaleBusy then
        return
    end
    self.unitFrameScaleBusy = true
    local i
    for i = 1, Count(self.UNIT_FRAMES) do
        self:ApplyOneUnitFrame(self.UNIT_FRAMES[i])
    end
    self.unitFrameScaleBusy = nil
end

function Config:ResetUnitFrameScales()
    local i
    for i = 1, Count(self.UNIT_FRAMES) do
        local spec = self.UNIT_FRAMES[i]
        self:Set(spec.key, 1.0)
        if self.unitFrameScaleBoxes and self.unitFrameScaleBoxes[spec.key] then
            self.unitFrameScaleBoxes[spec.key]:SetText("1.0")
        end
    end
    self:ApplyUnitFrameScales()
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
    watcher:SetScript("OnEvent", function()
        if ConsoleUI.config and ConsoleUI.config.ApplyUnitFrameScales then
            ConsoleUI.config:ApplyUnitFrameScales()
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
            0.1)
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

    local playerBox = self:CreateSectionBox(section, T("Player"))
    playerBox:SetPoint("TOP", section, "TOP", 0, -6)
    local playerH = FillGroupBox(playerBox, "player")
    local resetButton = self:MakePanelButton(playerBox, "ConsoleUIConfigResetUnitFrames", 80, T("Reset"))
    resetButton:SetPoint("TOPLEFT", playerBox, "TOPLEFT", playerBox.contentLeft, playerBox.contentTop - 36)
    resetButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        Config:ResetUnitFrameScales()
    end)
    playerBox:SetHeight(playerH + 30)
    playerBox.heightCalculated = true

    local targetBox = self:CreateSectionBox(section, T("Target"))
    targetBox:ClearAllPoints()
    targetBox:SetPoint("TOPLEFT", playerBox, "BOTTOMLEFT", 0, -6)
    targetBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    targetBox:SetHeight(FillGroupBox(targetBox, "target"))
    targetBox.heightCalculated = true

    local partyBox = self:CreateSectionBox(section, T("Party"))
    partyBox:ClearAllPoints()
    partyBox:SetPoint("TOPLEFT", targetBox, "BOTTOMLEFT", 0, -6)
    partyBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    partyBox:SetHeight(FillGroupBox(partyBox, "party"))
    partyBox.heightCalculated = true

    local petBox = self:CreateSectionBox(section, T("Party Pets"))
    petBox:ClearAllPoints()
    petBox:SetPoint("TOPLEFT", partyBox, "BOTTOMLEFT", 0, -6)
    petBox:SetPoint("RIGHT", section, "RIGHT", -5, 0)
    petBox:SetHeight(FillGroupBox(petBox, "partypet"))
    petBox.heightCalculated = true

    local hint = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("TOPLEFT", petBox, "BOTTOMLEFT", 4, -8)
    hint:SetPoint("RIGHT", section, "RIGHT", -8, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText(T("Each slider is independent. Pet and Target of Target do not inherit Player or Target scale."))
    hint:SetTextColor(unpack(self.UI_COLORS.muted))

    self.contentSections.unitframes = section
end
