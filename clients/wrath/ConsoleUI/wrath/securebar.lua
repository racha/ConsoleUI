-- First Wrath vertical slice: the same ten diamond positions, with secure
-- action execution and modifier pages. No insecure UseAction or binding Lua.
ConsoleUI = ConsoleUI or {}
ConsoleUI.wrathBar = ConsoleUI.wrathBar or {}
local Bar = ConsoleUI.wrathBar
local KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
local MODIFIERS = { "", "SHIFT-", "CTRL-", "CTRL-SHIFT-" }
local PAGE_DRIVER = "[mod:shift,mod:ctrl] 4; [mod:shift] 2; [mod:ctrl] 3; 1"
Bar.BUTTON_SIZE = 82
Bar.STAR_GAP = 600
Bar.Y_OFFSET = 70
local TEX = "Interface\\AddOns\\ConsoleUI\\textures\\"

local function Paint(button)
    local slot = button:GetAttribute("action")
    if slot and HasAction(slot) then
        button.icon:SetTexture(GetActionTexture(slot))
        button.icon:Show()
    else
        button.icon:Hide()
    end
    ConsoleUI.actionbars.SliceMask:Sync(button)
end

function Bar:CreateButton(id)
    local layout = ConsoleUI.actionbars.Layout
    local button = CreateFrame("CheckButton", "ConsoleUIWrathAction" .. id, UIParent,
        "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    button:SetID(id)
    button:SetWidth(self.BUTTON_SIZE)
    button:SetHeight(self.BUTTON_SIZE)
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("type", "action")
    for page = 1, 4 do
        button:SetAttribute("page" .. page, (page - 1) * 10 + id)
    end
    button:SetAttribute("action", id)
    button:SetAttribute("_onstate-page",
        "self:SetAttribute('action', self:GetAttribute('page' .. newstate))")
    RegisterStateDriver(button, "page", PAGE_DRIVER)

    local metrics = layout.Metrics(self.BUTTON_SIZE, layout.FLANK_GAP)
    local position = layout.Local(id, "controller", metrics)
    local side = position.star == "left" and -1 or 1
    button:SetPoint("CENTER", UIParent, "BOTTOM", side * self.STAR_GAP / 2 + position.x,
        self.Y_OFFSET + position.y)

    local plate = button:CreateTexture(nil, "BACKGROUND")
    plate:SetAllPoints(button)
    plate:SetTexture(layout.KeyPath(position.dir))
    button.plate = plate

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(layout.SliceClipSize(self.BUTTON_SIZE))
    icon:SetHeight(layout.SliceClipSize(self.BUTTON_SIZE))
    icon:SetPoint("CENTER", button, "CENTER")
    button.icon = icon
    ConsoleUI.actionbars.SliceMask:Ensure(button, self.BUTTON_SIZE)
    icon:SetAlpha(0)

    local glyphName = ({ "a", "x", "y", "b", "down", "left", "up", "right", "rb", "rt" })[id]
    local chrome = CreateFrame("Frame", nil, button)
    chrome:SetAllPoints(button)
    chrome:SetFrameLevel(button._sliceMask:GetFrameLevel() + 1)
    chrome:EnableMouse(false)
    local glyph = chrome:CreateTexture(nil, "OVERLAY")
    glyph:SetWidth(22)
    glyph:SetHeight(22)
    glyph:SetPoint("TOP", button, "TOP", 0, -2)
    if id >= 5 and id <= 8 then
        glyph:SetTexture(TEX .. "controllers\\" .. glyphName)
    else
        glyph:SetTexture(TEX .. "controllers\\xbox\\" .. glyphName)
    end
    button.glyph = glyph
    button.chrome = chrome

    button:HookScript("OnAttributeChanged", function(self, name)
        if name == "action" then Paint(self) end
    end)
    button:SetScript("OnEnter", function(self)
        local slot = self:GetAttribute("action")
        if slot and HasAction(slot) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetAction(slot)
        end
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Paint(button)
    return button
end

function Bar:Initialize()
    if self.initialized then return end
    if InCombatLockdown() then return end
    self.initialized = true
    self.buttons = {}
    self.bindingOwner = CreateFrame("Frame", "ConsoleUIWrathBindingOwner", UIParent)
    local i, j
    for i = 1, 10 do
        local button = self:CreateButton(i)
        self.buttons[i] = button
        for j = 1, 4 do
            SetOverrideBindingClick(self.bindingOwner, false,
                MODIFIERS[j] .. KEYS[i], button:GetName(), "LeftButton")
        end
    end
    self.events = CreateFrame("Frame")
    self.events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    self.events:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    self.events:SetScript("OnEvent", function()
        for i = 1, 10 do Paint(Bar.buttons[i]) end
    end)
end
