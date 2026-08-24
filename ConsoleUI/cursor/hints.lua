--[[
    Shared A/B/X/Y glyph strip. Hint bar, loot, unit menu.
    Same controller textures as the tooltip.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.hints = ConsoleUI.hints or {}
local Hints = ConsoleUI.hints

Hints.MAX = 4

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

function Hints:Size()
    if ConsoleUI.config and ConsoleUI.config.GetGlyphSize then
        return ConsoleUI.config:GetGlyphSize("hud")
    end
    return 22
end

function Hints:IconPath(name)
    if not name then
        return nil
    end
    if ConsoleUI.config and ConsoleUI.config.GetControllerIconPath then
        return ConsoleUI.config:GetControllerIconPath(name)
    end
    local dPad = { down = true, left = true, right = true, up = true }
    if dPad[name] then
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. name
    end
    return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\xbox\\" .. name
end

function Hints:Attach(parent)
    if not parent or parent.hintSlots then
        return parent and parent.hintSlots
    end
    parent.hintSlots = {}
    local i
    for i = 1, self.MAX do
        local slot = CreateFrame("Frame", nil, parent)
        slot:SetWidth(72)
        slot:SetHeight(22)
        slot:EnableMouse(false)
        local icon = slot:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(22)
        icon:SetHeight(22)
        icon:SetPoint("LEFT", slot, "LEFT", 0, 0)
        local lab = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lab:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        lab:SetJustifyH("LEFT")
        lab:SetTextColor(0.75, 0.75, 0.75)
        slot.icon = icon
        slot.label = lab
        slot:Hide()
        parent.hintSlots[i] = slot
    end
    return parent.hintSlots
end

function Hints:Paint(parent, prompts)
    if not parent then
        return 0
    end
    self:Attach(parent)
    local sz = self:Size()
    local n = 0
    if prompts and table.getn then
        n = table.getn(prompts)
    end
    local x = parent.hintX or 0
    local y = parent.hintY or 0
    local point = parent.hintPoint or "BOTTOMLEFT"
    local rel = parent.hintRel or parent
    local relPoint = parent.hintRelPoint or "BOTTOMLEFT"
    local total = 0
    local prev = nil
    local i
    for i = 1, self.MAX do
        local slot = parent.hintSlots[i]
        local p = prompts and prompts[i]
        if slot and p and p.prompt then
            slot.icon:SetWidth(sz)
            slot.icon:SetHeight(sz)
            slot.icon:SetTexture(self:IconPath(p.icon))
            slot.icon:Show()
            slot.label:SetText(p.prompt)
            local lw = 40
            if slot.label.GetStringWidth then
                lw = slot.label:GetStringWidth() or 40
            end
            slot:SetWidth(sz + 4 + lw + 2)
            slot:SetHeight(sz)
            slot:ClearAllPoints()
            if prev then
                slot:SetPoint("LEFT", prev, "RIGHT", 14, 0)
            else
                slot:SetPoint(point, rel, relPoint, x, y)
            end
            slot:Show()
            total = total + slot:GetWidth() + (prev and 14 or 0)
            prev = slot
        elseif slot then
            slot:Hide()
        end
    end
    return total
end

function Hints:Refresh(parent)
    if not parent or not parent.hintSlots then
        return
    end
    local i
    for i = 1, self.MAX do
        local slot = parent.hintSlots[i]
        if slot and slot:IsShown() and slot.icon then
            local path = slot.icon.GetTexture and slot.icon:GetTexture()
            if path then
                slot.icon:SetTexture(path)
            end
            local sz = self:Size()
            slot.icon:SetWidth(sz)
            slot.icon:SetHeight(sz)
        end
    end
end
