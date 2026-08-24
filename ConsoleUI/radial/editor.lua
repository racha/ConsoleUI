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

    local slotHint = slotPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slotHint:SetPoint("TOPLEFT", slotLabel, "BOTTOMLEFT", 0, -4)
    slotHint:SetPoint("RIGHT", slotPanel, "RIGHT", -8, 0)
    slotHint:SetJustifyH("LEFT")
    slotHint:SetText(T("Drop a spell, item, or macro on a square. X or Clear empties it."))
    slotHint:SetTextColor(unpack(Config.UI_COLORS.muted))
    Config.ringsSlotHint = slotHint

    local lay = ConsoleUI.actionbars and ConsoleUI.actionbars.Layout
    local HIT = (lay and lay.HIT) or 56
    local STEP = (lay and lay.SquareStep and lay.SquareStep(HIT)) or (HIT + 20)
    local COLS = 4

    local function AfterSlotChange()
        Config:RefreshRingsEditor()
        if ConsoleUI.proxied and ConsoleUI.config and ConsoleUI.config.RefreshProxiedDropdowns then
            ConsoleUI.config:RefreshProxiedDropdowns()
        end
    end

    function Config:PaintRingSlot(slot, entry, hover)
        if not slot then
            return
        end
        local bars = ConsoleUI.actionbars
        if bars and bars.ApplySquareAppearance then
            bars:ApplySquareAppearance(slot)
        end
        if slot.diamondPlate then
            slot.diamondPlate:SetVertexColor(0, 0, 0)
            slot.diamondPlate:SetAlpha(1)
        end
        if slot.diamondRim then
            slot.diamondRim:SetVertexColor(0, 0, 0)
            slot.diamondRim:SetAlpha(1)
            slot.diamondRim:Show()
        end
        if slot.diamondRing then
            if hover then
                local r, g, b = 1.00, 0.82, 0.18
                if ConsoleUI.config and ConsoleUI.config.GetHudBorderColor then
                    r, g, b = ConsoleUI.config:GetHudBorderColor()
                end
                slot.diamondRing:SetVertexColor(r, g, b)
                slot.diamondRing:SetAlpha(1)
                slot.diamondRing:Show()
            else
                slot.diamondRing:Hide()
            end
        end
        if bars and bars.RaiseDiamondChrome then
            bars:RaiseDiamondChrome(slot)
        end
        if slot.icon then
            if entry and entry.texture then
                slot.icon:SetTexture(entry.texture)
                slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                slot.icon:SetAlpha(1)
                slot.icon:Show()
            else
                slot.icon:SetTexture(nil)
                slot.icon:Hide()
            end
        end
        if slot.label then
            if entry and entry.name then
                slot.label:SetText(entry.name)
                slot.label:SetTextColor(0.90, 0.90, 0.91)
            else
                slot.label:SetText(T("Empty"))
                slot.label:SetTextColor(0.56, 0.57, 0.60)
            end
        end
        if Rings.SetCountBadge then
            Rings:SetCountBadge(slot, entry)
        end
    end

    function Config:DropOnRingSlot(slot, clearIfEmpty)
        if not slot or not Config.selectedRingID or not Rings then
            return
        end
        local entry = Rings.EntryFromCursor and Rings:EntryFromCursor()
        if entry then
            Rings:SetSlot(Config.selectedRingID, slot.index, entry)
            if ClearCursor then
                ClearCursor()
            end
            if ConsoleUI.cursor and ConsoleUI.cursor.ClearHeldItemTexture then
                ConsoleUI.cursor:ClearHeldItemTexture()
            end
            Rings.lastPickup = nil
        elseif clearIfEmpty then
            Rings:SetSlot(Config.selectedRingID, slot.index, nil)
        else
            return
        end
        AfterSlotChange()
    end

    function Config:HideRingClearChip()
        if self.ringClearBtn then
            self.ringClearBtn:Hide()
            self.ringClearBtn.owner = nil
        end
    end

    function Config:ShowRingClearFor(slot)
        if not slot or not self:RingSlotHasEntry(slot) then
            self:HideRingClearChip()
            return
        end
        if Rings and Rings.CursorLooksHeld and Rings:CursorLooksHeld() then
            self:HideRingClearChip()
            return
        end
        local btn = self.ringClearBtn
        if not btn then
            return
        end
        btn.owner = slot
        btn:ClearAllPoints()
        btn:SetPoint("BOTTOM", slot, "BOTTOM", 0, 2)
        btn:SetFrameLevel((slot:GetFrameLevel() or 1) + 8)
        btn:Show()
    end

    function Config:ClearRingSlot(slot)
        if not slot or not slot.index or not Config.selectedRingID or not Rings then
            return
        end
        Rings:SetSlot(Config.selectedRingID, slot.index, nil)
        self:HideRingClearChip()
        AfterSlotChange()
    end

    function Config:RingSlotHasEntry(slot)
        if not slot or not slot.index or not self.selectedRingID or not Rings then
            return nil
        end
        local ring = Rings:GetRing(self.selectedRingID)
        return ring and ring.slots and ring.slots[slot.index]
    end

    local slots = {}
    for i = 1, 8 do
        local slot = CreateFrame("Button", "ConsoleUIConfigRingSlot" .. i, slotPanel)
        slot:SetWidth(HIT)
        slot:SetHeight(HIT)
        local col = math.mod(i - 1, COLS)
        local row = math.floor((i - 1) / COLS)
        slot:SetPoint("TOPLEFT", slotPanel, "TOPLEFT", 16 + col * STEP, -48 - row * (STEP + 18))
        slot.index = i
        slot:EnableMouse(true)
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:RegisterForDrag("LeftButton")

        local icon = slot:CreateTexture(slot:GetName() .. "Icon", "ARTWORK")
        icon:SetWidth(HIT)
        icon:SetHeight(HIT)
        icon:SetPoint("CENTER", slot, "CENTER", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        slot.icon = icon

        local label = slotPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOP", slot, "BOTTOM", 0, -2)
        label:SetWidth(STEP - 8)
        label:SetJustifyH("CENTER")
        slot.label = label
        if Rings.AttachCountBadge then
            Rings:AttachCountBadge(slot, icon)
        end

        slot:SetScript("OnReceiveDrag", function()
            Config:DropOnRingSlot(this, false)
        end)
        slot:SetScript("OnMouseUp", function()
            if Rings and Rings.EntryFromCursor and Rings:EntryFromCursor() then
                Config:DropOnRingSlot(this, false)
            end
        end)
        slot:SetScript("OnClick", function()
            if arg1 == "RightButton" then
                Config:ClearRingSlot(this)
                return
            end
            Config:DropOnRingSlot(this, false)
        end)
        slot:SetScript("OnEnter", function()
            local ring = Config.selectedRingID and Rings and Rings:GetRing(Config.selectedRingID)
            local entry = ring and ring.slots and ring.slots[this.index]
            local hover = Rings and ((Rings.CursorLooksHeld and Rings:CursorLooksHeld()) or (Rings.lastPickup and Rings.lastPickup.kind))
            Config:PaintRingSlot(this, entry, hover)
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            if entry and entry.name then
                GameTooltip:SetText(entry.name, 1, 1, 1)
            else
                GameTooltip:SetText(T("Empty"))
                GameTooltip:AddLine(T("Drop a spell, item, or macro on a square. X or Clear empties it."), 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
            Config:ShowRingClearFor(this)
        end)
        slot:SetScript("OnLeave", function()
            local ring = Config.selectedRingID and Rings and Rings:GetRing(Config.selectedRingID)
            local entry = ring and ring.slots and ring.slots[this.index]
            Config:PaintRingSlot(this, entry, false)
            GameTooltip:Hide()
        end)
        slots[i] = slot
    end
    Config.ringSlotButtons = slots

    local clearBtn = CreateFrame("Button", "ConsoleUIConfigRingClear", slotPanel)
    clearBtn:SetWidth(HIT - 6)
    clearBtn:SetHeight(16)
    clearBtn:SetBackdrop(Config.BACKDROP_CARD)
    clearBtn:SetBackdropColor(0.16, 0.06, 0.07, 0.96)
    clearBtn:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.35)
    clearBtn:Hide()
    local clearLabel = clearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    clearLabel:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
    clearLabel:SetText(T("Clear"))
    clearLabel:SetTextColor(0.95, 0.55, 0.58)
    clearBtn:SetScript("OnClick", function()
        if this.owner then
            Config:ClearRingSlot(this.owner)
        end
    end)
    clearBtn:SetScript("OnEnter", function()
        this:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.70)
    end)
    clearBtn:SetScript("OnLeave", function()
        this:SetBackdropBorderColor(0.84, 0.30, 0.36, 0.35)
    end)
    clearBtn:SetScript("OnUpdate", function()
        local owner = this.owner
        if not owner then
            this:Hide()
            return
        end
        local focus = GetMouseFocus()
        if focus ~= this and focus ~= owner then
            Config:HideRingClearChip()
        end
    end)
    Config.ringClearBtn = clearBtn

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
                if slot.label then
                    slot.label:Show()
                end
                Config:PaintRingSlot(slot, selected.slots and selected.slots[i], false)
            else
                slot:Hide()
                if slot.label then
                    slot.label:Hide()
                end
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
