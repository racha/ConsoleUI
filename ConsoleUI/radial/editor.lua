--[[
    ConsoleUI - Rings editor for /cui
]]

local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local Rings = ConsoleUI.rings

local function PickupToEntry()
    local p = Rings and Rings.lastPickup
    if not p or not p.kind or not p.name then
        return nil
    end
    return {
        kind = p.kind,
        name = p.name,
        itemID = p.itemID,
        texture = p.texture,
    }
end

function ConsoleUI.BuildRingsSection(Config, content)
    local T = L
    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -4, 4)
    section:Hide()

    local heading = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", section, "TOPLEFT", 4, -2)
    heading:SetText(T("Rings"))
    heading:SetTextColor(unpack(Config.UI_COLORS.text))

    local newBtn = Config:MakePanelButton(section, "ConsoleUIConfigRingNew", 90, T("New Ring"), "primary")
    newBtn:SetPoint("TOPRIGHT", section, "TOPRIGHT", -4, -2)
    newBtn:SetScript("OnClick", function()
        StaticPopup_Show("ConsoleUI_CREATE_RING")
    end)

    local renameBtn = Config:MakePanelButton(section, "ConsoleUIConfigRingRename", 80, T("Rename"), "ghost")
    renameBtn:SetPoint("RIGHT", newBtn, "LEFT", -6, 0)
    renameBtn:SetScript("OnClick", function()
        if Config.selectedRingID then
            StaticPopup_Show("ConsoleUI_RENAME_RING")
        end
    end)

    local deleteBtn = Config:MakePanelButton(section, "ConsoleUIConfigRingDelete", 80, T("Delete"), "danger")
    deleteBtn:SetPoint("RIGHT", renameBtn, "LEFT", -6, 0)
    deleteBtn:SetScript("OnClick", function()
        if Config.selectedRingID then
            StaticPopup_Show("ConsoleUI_DELETE_RING")
        end
    end)

    local listPanel = CreateFrame("Frame", "ConsoleUIConfigRingList", section)
    listPanel:SetPoint("TOPLEFT", section, "TOPLEFT", 0, -34)
    listPanel:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT", 0, 0)
    listPanel:SetWidth(176)
    listPanel:SetBackdrop(Config.BACKDROP_CARD)
    listPanel:SetBackdropColor(unpack(Config.UI_COLORS.section))
    listPanel:SetBackdropBorderColor(unpack(Config.UI_COLORS.border))

    local listLabel = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    listLabel:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 8, -8)
    listLabel:SetText("MY RINGS")
    listLabel:SetTextColor(0.77, 0.78, 0.80)
    Config.ringsListLabel = listLabel

    local empty = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    empty:SetPoint("TOPLEFT", listLabel, "BOTTOMLEFT", 0, -12)
    empty:SetText(T("No rings yet"))
    empty:SetTextColor(unpack(Config.UI_COLORS.muted))
    Config.ringsEmpty = empty

    Config.ringListButtons = {}

    local i
    for i = 1, 8 do
        local btn = Config:MakePanelButton(listPanel, "ConsoleUIConfigRingPick" .. i, 160, "", "ghost")
        btn:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 8, -28 - (i - 1) * 32)
        btn.ringID = i
        btn:SetScript("OnClick", function()
            Config.selectedRingID = this.ringID
            Config:RefreshRingsEditor()
        end)
        btn:Hide()
        Config.ringListButtons[i] = btn
    end

    local slotPanel = CreateFrame("Frame", "ConsoleUIConfigRingSlots", section)
    slotPanel:SetPoint("TOPLEFT", listPanel, "TOPRIGHT", 8, 0)
    slotPanel:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", 0, 0)
    slotPanel:SetBackdrop(Config.BACKDROP_CARD)
    slotPanel:SetBackdropColor(unpack(Config.UI_COLORS.section))
    slotPanel:SetBackdropBorderColor(unpack(Config.UI_COLORS.border))
    Config.ringSlotPanel = slotPanel

    local slotLabel = slotPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotLabel:SetPoint("TOPLEFT", slotPanel, "TOPLEFT", 8, -8)
    slotLabel:SetText("SLOTS")
    slotLabel:SetTextColor(0.77, 0.78, 0.80)
    Config.ringsSlotLabel = slotLabel

    local slots = {}
    for i = 1, 8 do
        local slot = CreateFrame("Button", "ConsoleUIConfigRingSlot" .. i, slotPanel)
        slot:SetHeight(42)
        slot:SetPoint("TOPLEFT", slotPanel, "TOPLEFT", 8, -28 - (i - 1) * 46)
        slot:SetPoint("RIGHT", slotPanel, "RIGHT", -8, 0)
        slot:SetBackdrop(Config.BACKDROP_CARD)
        slot:SetBackdropColor(unpack(Config.UI_COLORS.inset))
        slot:SetBackdropBorderColor(0, 0, 0, 0)
        slot.index = i

        local idx = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idx:SetPoint("LEFT", slot, "LEFT", 8, 0)
        idx:SetWidth(16)
        idx:SetText(tostring(i))
        idx:SetTextColor(0.33, 0.35, 0.38)
        slot.idx = idx

        local icon = slot:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(28)
        icon:SetHeight(28)
        icon:SetPoint("LEFT", idx, "RIGHT", 8, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        slot.icon = icon

        local label = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        label:SetPoint("RIGHT", slot, "RIGHT", -8, 0)
        label:SetJustifyH("LEFT")
        slot.label = label
        if Rings.AttachCountBadge then
            Rings:AttachCountBadge(slot, icon)
        end

        slot:SetScript("OnClick", function()
            if not Config.selectedRingID or not Rings then return end
            local entry = PickupToEntry()
            if entry then
                Rings:SetSlot(Config.selectedRingID, this.index, entry)
                if ClearCursor then ClearCursor() end
                Rings.lastPickup = nil
            else
                Rings:SetSlot(Config.selectedRingID, this.index, nil)
            end
            Config:RefreshRingsEditor()
            if ConsoleUI.proxied and ConsoleUI.config and ConsoleUI.config.RefreshProxiedDropdowns then
                ConsoleUI.config:RefreshProxiedDropdowns()
            end
        end)
        slots[i] = slot
    end
    Config.ringSlotButtons = slots

    function Config:RefreshRingsEditor()
        if not Rings then return end
        local listData = Rings:List()
        local n = table.getn(listData)
        if Config.ringsEmpty then
            if n == 0 then Config.ringsEmpty:Show() else Config.ringsEmpty:Hide() end
        end
        if Config.ringsListLabel then
            Config.ringsListLabel:SetText("MY RINGS")
        end
        local i
        for i = 1, 8 do
            local btn = Config.ringListButtons[i]
            local ring = nil
            local r
            for r = 1, n do
                if listData[r].id == i then
                    ring = listData[r]
                    break
                end
            end
            if ring then
                btn:Show()
                if btn.label then
                    btn.label:SetText(ring.name or (T("Ring") .. " " .. i))
                end
                btn.kind = Config.selectedRingID == i and "on" or "ghost"
                Config:PaintButton(btn, btn.kind, false)
            else
                btn:Hide()
            end
        end
        if not Config.selectedRingID or not Rings:GetRing(Config.selectedRingID) then
            if n > 0 then
                Config.selectedRingID = listData[1].id
            else
                Config.selectedRingID = nil
            end
        end
        local selected = Config.selectedRingID and Rings:GetRing(Config.selectedRingID)
        if Config.ringsSlotLabel then
            if selected then
                Config.ringsSlotLabel:SetText(string.upper(selected.name or T("Slots")))
            else
                Config.ringsSlotLabel:SetText("SLOTS")
            end
        end
        for i = 1, 8 do
            local slot = Config.ringSlotButtons[i]
            if selected then
                slot:Show()
                local entry = selected.slots and selected.slots[i]
                if entry then
                    slot.icon:SetTexture(entry.texture)
                    slot.icon:Show()
                    slot.label:SetText(entry.name or "")
                    slot.label:SetTextColor(0.90, 0.90, 0.91)
                    slot:SetBackdropBorderColor(1, 1, 1, 0.08)
                else
                    slot.icon:SetTexture(nil)
                    slot.icon:Hide()
                    slot.label:SetText(T("Empty slot"))
                    slot.label:SetTextColor(0.56, 0.57, 0.60)
                    slot:SetBackdropBorderColor(0, 0, 0, 0)
                end
                if Rings.SetCountBadge then
                    Rings:SetCountBadge(slot, entry)
                end
            else
                slot:Hide()
            end
        end
    end

    section:SetScript("OnShow", function()
        Config:RefreshRingsEditor()
    end)

    Config.contentSections["rings"] = section
end

StaticPopupDialogs["ConsoleUI_CREATE_RING"] = {
    text = "Ring name",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function()
        local editBox = this.editBox or getglobal(this:GetName() .. "EditBox") or getglobal("StaticPopup1EditBox")
        if editBox then
            editBox:SetText("")
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = this.editBox
        if not editBox and this.GetName then
            editBox = getglobal(this:GetName() .. "EditBox")
        end
        if not editBox then
            editBox = getglobal("StaticPopup1EditBox")
        end
        local name = editBox and editBox:GetText() or ""
        if ConsoleUI.rings then
            local id = ConsoleUI.rings:CreateRing(name)
            if ConsoleUI.config then
                ConsoleUI.config.selectedRingID = id
                if ConsoleUI.config.RefreshRingsEditor then
                    ConsoleUI.config:RefreshRingsEditor()
                end
                if ConsoleUI.config.RefreshProxiedDropdowns then
                    ConsoleUI.config:RefreshProxiedDropdowns()
                end
            end
        end
    end,
}

StaticPopupDialogs["ConsoleUI_RENAME_RING"] = {
    text = "Rename ring",
    button1 = OKAY,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 24,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function()
        local editBox = this.editBox or getglobal(this:GetName() .. "EditBox") or getglobal("StaticPopup1EditBox")
        local id = ConsoleUI.config and ConsoleUI.config.selectedRingID
        local ring = id and ConsoleUI.rings and ConsoleUI.rings:GetRing(id)
        if editBox then
            editBox:SetText(ring and ring.name or "")
            editBox:SetFocus()
        end
    end,
    OnAccept = function()
        local editBox = this.editBox
        if not editBox and this.GetName then
            editBox = getglobal(this:GetName() .. "EditBox")
        end
        if not editBox then
            editBox = getglobal("StaticPopup1EditBox")
        end
        local name = editBox and editBox:GetText() or ""
        local id = ConsoleUI.config and ConsoleUI.config.selectedRingID
        if id and ConsoleUI.rings then
            ConsoleUI.rings:RenameRing(id, name)
            if ConsoleUI.config.RefreshRingsEditor then
                ConsoleUI.config:RefreshRingsEditor()
            end
            if ConsoleUI.config.RefreshProxiedDropdowns then
                ConsoleUI.config:RefreshProxiedDropdowns()
            end
        end
    end,
}

StaticPopupDialogs["ConsoleUI_DELETE_RING"] = {
    text = "Delete this ring?",
    button1 = OKAY,
    button2 = CANCEL,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function()
        local id = ConsoleUI.config and ConsoleUI.config.selectedRingID
        if id and ConsoleUI.rings then
            ConsoleUI.rings:DeleteRing(id)
            ConsoleUI.config.selectedRingID = nil
            if ConsoleUI.config.RefreshRingsEditor then
                ConsoleUI.config:RefreshRingsEditor()
            end
            if ConsoleUI.config.RefreshProxiedDropdowns then
                ConsoleUI.config:RefreshProxiedDropdowns()
            end
        end
    end,
}
