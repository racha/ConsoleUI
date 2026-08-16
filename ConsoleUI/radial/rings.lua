--[[
    ConsoleUI - User rings

    Hold ConsoleUI_RING_N to show, point, release to use. B / ESC cancel.
    No center cluster. Spells and items only.
]]

local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

ConsoleUI.rings = ConsoleUI.rings or {}
local Rings = ConsoleUI.rings
local Radial = ConsoleUI.radial

local MAX_RINGS = 8
local ICON_SIZE = 36
local RING_RADIUS = 154
local LABEL_BELOW = 27
local FALLBACK_ICON = "Interface\\Icons\\Trade_Engineering"
local COUNT_BADGE = "Interface\\AddOns\\ConsoleUI\\textures\\radial\\CountBadge"
local COUNT_SIZE = 16

function Rings:EnsureDB()
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.rings then
        ConsoleUIDB.rings = {}
    end
    return ConsoleUIDB.rings
end

function Rings:BindingID(id)
    return "ConsoleUI_RING_" .. id
end

function Rings:ParseBindingID(bindingID)
    if not bindingID then return nil end
    local _, _, num = string.find(bindingID, "^ConsoleUI_RING_(%d+)$")
    if not num then return nil end
    return tonumber(num)
end

function Rings:GetRing(id)
    local db = self:EnsureDB()
    return db[id]
end

function Rings:List()
    local db = self:EnsureDB()
    local list = {}
    local i
    for i = 1, MAX_RINGS do
        if db[i] then
            table.insert(list, db[i])
            db[i].id = i
        end
    end
    return list
end

function Rings:NextFreeID()
    local db = self:EnsureDB()
    local i
    for i = 1, MAX_RINGS do
        if not db[i] then
            return i
        end
    end
    return nil
end

function Rings:CreateRing(name)
    local id = self:NextFreeID()
    if not id then
        return nil
    end
    if not name or name == "" then
        name = L("Ring") .. " " .. id
    end
    local db = self:EnsureDB()
    db[id] = {
        name = name,
        icon = nil,
        slots = {},
    }
    return id
end

function Rings:UnbindRing(id)
    local bindingID = self:BindingID(id)
    if not ConsoleUIDB or not ConsoleUIDB.proxiedActions then
        return
    end
    local slot, bound
    for slot, bound in pairs(ConsoleUIDB.proxiedActions) do
        if bound == bindingID then
            ConsoleUIDB.proxiedActions[slot] = nil
            if slot >= 1 and slot <= 50 then
                if ConsoleUI.proxied and ConsoleUI.proxied.ApplySlotBinding then
                    ConsoleUI.proxied:ApplySlotBinding(slot)
                end
            end
        end
    end
end

function Rings:DeleteRing(id)
    local db = self:EnsureDB()
    if not db[id] then return end
    if self.activeID == id then
        self:Cancel()
    end
    self:UnbindRing(id)
    db[id] = nil
end

function Rings:RenameRing(id, name)
    local ring = self:GetRing(id)
    if not ring then return end
    if name and name ~= "" then
        ring.name = name
    end
end

function Rings:SetSlot(id, index, entry)
    local ring = self:GetRing(id)
    if not ring or index < 1 or index > 8 then return end
    if not ring.slots then
        ring.slots = {}
    end
    ring.slots[index] = entry
    if not ring.icon and entry and entry.texture then
        ring.icon = entry.texture
    end
end

function Rings:RingIcon(ring)
    if not ring then return FALLBACK_ICON end
    if ring.icon then return ring.icon end
    local i
    for i = 1, 8 do
        local slot = ring.slots and ring.slots[i]
        if slot and slot.texture then
            return slot.texture
        end
    end
    return FALLBACK_ICON
end

function Rings:GetActionInfo(bindingID)
    local id = self:ParseBindingID(bindingID)
    if not id then return nil end
    local ring = self:GetRing(id)
    if not ring then return nil end
    return {
        id = bindingID,
        name = ring.name or (L("Ring") .. " " .. id),
        desc = L("Hold to show ring, release to use"),
        icon = self:RingIcon(ring),
    }
end

function Rings:CloneData(src)
    local out = {}
    if not src then return out end
    local id
    for id = 1, MAX_RINGS do
        local ring = src[id]
        if ring then
            local slots = {}
            local s
            for s = 1, 8 do
                local e = ring.slots and ring.slots[s]
                if e then
                    slots[s] = {
                        kind = e.kind,
                        name = e.name,
                        itemID = e.itemID,
                        texture = e.texture,
                    }
                end
            end
            out[id] = { name = ring.name, icon = ring.icon, slots = slots }
        end
    end
    return out
end

function Rings:CopyAll()
    return self:CloneData(self:EnsureDB())
end

function Rings:ReplaceAll(src)
    local db = self:EnsureDB()
    local id
    for id = 1, MAX_RINGS do
        db[id] = nil
    end
    if not src then return end
    for id = 1, MAX_RINGS do
        local ring = src[id]
        if ring then
            local slots = {}
            local s
            for s = 1, 8 do
                local e = ring.slots and ring.slots[s]
                if e then
                    slots[s] = {
                        kind = e.kind,
                        name = e.name,
                        itemID = e.itemID,
                        texture = e.texture,
                    }
                end
            end
            db[id] = { name = ring.name, icon = ring.icon, slots = slots }
        end
    end
end

local function ParseItemID(link)
    if not link then return nil end
    local _, _, id = string.find(link, "item:(%d+)")
    if id then return tonumber(id) end
    return nil
end

local function ItemNameFromLink(link)
    if not link then return nil end
    local _, _, name = string.find(link, "%[(.-)%]")
    return name
end

function Rings:CountItem(entry)
    if not entry or entry.kind ~= "item" then
        return 0
    end
    local total = 0
    local bag
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag) or 0
        local slot
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local match = false
                if entry.itemID then
                    local id = ParseItemID(link)
                    if id and id == entry.itemID then
                        match = true
                    end
                elseif entry.name and ItemNameFromLink(link) == entry.name then
                    match = true
                end
                if match then
                    local _, count = GetContainerItemInfo(bag, slot)
                    total = total + (count or 0)
                end
            end
        end
    end
    return total
end

function Rings:AttachCountBadge(button, icon)
    if not button or button.countBadge or not icon then
        return
    end
    local badge = button:CreateTexture(nil, "OVERLAY")
    badge:SetWidth(COUNT_SIZE)
    badge:SetHeight(COUNT_SIZE)
    badge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)
    badge:SetTexture(COUNT_BADGE)
    badge:SetVertexColor(0, 0, 0)
    if badge.SetAlpha then
        badge:SetAlpha(1)
    end
    badge:Hide()
    button.countBadge = badge
    local text = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    text:SetPoint("CENTER", badge, "CENTER", 0, 0)
    text:Hide()
    button.countText = text
end

function Rings:SetCountBadge(button, entry)
    if not button or not button.countBadge then
        return
    end
    if not entry or entry.kind ~= "item" then
        button.countBadge:Hide()
        if button.countText then
            button.countText:Hide()
        end
        return
    end
    local count = self:CountItem(entry)
    button.countBadge:Show()
    button.countText:Show()
    button.countText:SetText(tostring(count))
    if count <= 0 then
        button.countText:SetTextColor(0.55, 0.55, 0.55)
    else
        button.countText:SetTextColor(1, 1, 1)
    end
end

function Rings:FindBagItem(entry)
    if not entry then return nil, nil end
    local bag
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        local slot
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)
            if link then
                if entry.itemID then
                    local id = ParseItemID(link)
                    if id and id == entry.itemID then
                        return bag, slot
                    end
                end
                if entry.name and ItemNameFromLink(link) == entry.name then
                    return bag, slot
                end
            end
        end
    end
    return nil, nil
end

function Rings:UseEntry(entry)
    if not entry or not entry.kind or not entry.name then
        return false
    end
    if entry.kind == "spell" then
        CastSpellByName(entry.name)
        return true
    end
    if entry.kind == "item" then
        local bag, slot = self:FindBagItem(entry)
        if bag and slot then
            UseContainerItem(bag, slot)
            return true
        end
        ConsoleUI_Debug("Rings: item not in bags: " .. tostring(entry.name))
        return false
    end
    return false
end

function Rings:CreateFrame()
    if self.frame then return self.frame end
    if not Radial or not Radial.BuildPieChrome then
        return nil
    end

    local frame = CreateFrame("Frame", "ConsoleUIUserRing", UIParent)
    frame:SetWidth(520)
    frame:SetHeight(520)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(100)
    frame:EnableMouse(false)
    frame:Hide()

    local overlay = CreateFrame("Frame", "ConsoleUIUserRingOverlay", UIParent)
    overlay:SetAllPoints(UIParent)
    overlay:SetFrameStrata("FULLSCREEN")
    overlay:SetFrameLevel(99)
    overlay:EnableMouse(true)
    overlay:Hide()
    local overlayBg = overlay:CreateTexture(nil, "BACKGROUND")
    overlayBg:SetAllPoints(overlay)
    overlayBg:SetTexture(0, 0, 0, 1)
    overlay:SetScript("OnMouseDown", function()
        Rings:Cancel()
    end)
    self.overlay = overlay

    self.chrome = Radial:BuildPieChrome(frame)
    self.buttons = {}
    local i
    for i = 1, 8 do
        local button = CreateFrame("Button", "ConsoleUIUserRingSlot" .. i, frame)
        button:SetWidth(ICON_SIZE + 8)
        button:SetHeight(ICON_SIZE + 28)
        button.index = i
        local angle = Radial.SLICE_MIDS[i]
        local px, py = Radial:SlicePoint(angle, RING_RADIUS)
        button:SetPoint("CENTER", frame, "CENTER", px, py + 8)

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(ICON_SIZE)
        icon:SetHeight(ICON_SIZE)
        icon:SetPoint("TOP", button, "TOP", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button.icon = icon

        local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOP", icon, "BOTTOM", 0, -(LABEL_BELOW - 18))
        label:SetTextColor(0.93, 0.93, 0.93)
        button.label = label
        self:AttachCountBadge(button, icon)
        self.buttons[i] = button
    end

    frame:RegisterEvent("BAG_UPDATE")
    frame:SetScript("OnEvent", function()
        if event == "BAG_UPDATE" and Rings:IsVisible() then
            Rings:RefreshCounts()
        end
    end)
    frame:SetScript("OnUpdate", function()
        Rings:OnUpdate(arg1)
    end)
    self.frame = frame
    return frame
end

function Rings:ApplyRingContent(id)
    local ring = self:GetRing(id)
    local i
    for i = 1, 8 do
        local button = self.buttons[i]
        local slot = ring and ring.slots and ring.slots[i]
        if slot and slot.texture then
            button.icon:SetTexture(slot.texture)
            button.icon:Show()
            button.label:SetText(slot.name or "")
        else
            button.icon:SetTexture(nil)
            button.icon:Hide()
            button.label:SetText("")
        end
        button.label:SetTextColor(0.93, 0.93, 0.93)
        self:SetCountBadge(button, slot)
    end
end

function Rings:RefreshCounts()
    if not self.buttons or not self.activeID then
        return
    end
    local ring = self:GetRing(self.activeID)
    local i
    for i = 1, 8 do
        local slot = ring and ring.slots and ring.slots[i]
        self:SetCountBadge(self.buttons[i], slot)
    end
end

function Rings:SetSelectedIndex(index)
    self.selectedIndex = index
    if Radial and Radial.SetPieHighlight then
        Radial:SetPieHighlight(self.chrome, index)
    end
    local i
    for i = 1, 8 do
        local button = self.buttons and self.buttons[i]
        if button and button.label then
            if index and i == index then
                button.label:SetTextColor(0.07, 0.07, 0.07)
            else
                button.label:SetTextColor(0.93, 0.93, 0.93)
            end
        end
    end
end

function Rings:SetDirectionState(direction, pressed)
    if not self:IsVisible() or not Radial then return end
    Radial.directionState = Radial.directionState or { UP = false, DOWN = false, LEFT = false, RIGHT = false }
    Radial.directionState[direction] = pressed and true or false
    local angle = Radial:StickAngle()
    self:SetSelectedIndex(Radial:IndexForAngle(angle))
end

function Rings:OnUpdate(elapsed)
    if not elapsed or elapsed <= 0 then elapsed = 0.016 end
    if Radial and Radial.TickColorTweens then
        Radial:TickColorTweens(elapsed)
    end
    self.intro = (self.intro or 0) + elapsed * 8
    if self.intro > 1 then self.intro = 1 end
    if self.overlay and self.overlay:IsShown() then
        self.overlay:SetAlpha(0.35 * self.intro)
    end
end

function Rings:Show(id)
    if not self:GetRing(id) then return end
    if Radial and Radial.IsVisible and Radial:IsVisible() then
        Radial:Hide()
    end
    if not self.frame then
        self:CreateFrame()
    end
    self.activeID = id
    self.cancelled = false
    self.intro = 0
    self:ApplyRingContent(id)
    self:SetSelectedIndex(nil)
    if self.overlay then
        self.overlay:EnableMouse(true)
        self.overlay:SetAlpha(0)
        self.overlay:Show()
    end
    self.frame:Show()
    if Radial and Radial.ActivateRingNavigation then
        Radial:ActivateRingNavigation()
    end
    if PlaySound then PlaySound("igMainMenuOpen") end
end

function Rings:Hide()
    if Radial and Radial.RestoreStickNavigation then
        Radial:RestoreStickNavigation()
    end
    if self.overlay then
        self.overlay:EnableMouse(false)
        self.overlay:Hide()
        self.overlay:SetAlpha(0)
    end
    if self.frame and self.frame:IsShown() then
        if PlaySound then PlaySound("igMainMenuClose") end
        self.frame:Hide()
    end
    self.activeID = nil
    self.selectedIndex = nil
end

function Rings:Cancel()
    if not self:IsVisible() then return end
    self.cancelled = true
    self:Hide()
end

function Rings:IsVisible()
    return self.frame and self.frame:IsVisible()
end

function Rings:OnBinding(id, pressed)
    if pressed then
        self:Show(id)
        return
    end
    if self.cancelled or self.activeID ~= id then
        self.cancelled = false
        if self:IsVisible() then
            self:Hide()
        end
        return
    end
    local ring = self:GetRing(id)
    local index = self.selectedIndex
    local entry = ring and index and ring.slots and ring.slots[index]
    self:Hide()
    if entry then
        self:UseEntry(entry)
    end
end

function ConsoleUI_RingButton(id, pressed)
    if ConsoleUI.rings then
        ConsoleUI.rings:OnBinding(id, pressed)
    end
end

function ConsoleUI_RingCancel()
    if ConsoleUI.rings then
        ConsoleUI.rings:Cancel()
    end
end
