--[[
    ConsoleUI bindings workspace.
    Left: inputs grouped by modifier. Right: actions for the selected input.
]]

local Config = ConsoleUI.config

Config.BIND_BUTTON_ICONS = { "a", "x", "y", "b", "down", "left", "up", "right", "rb", "rt" }
Config.BIND_BUTTON_LABELS = {
    "A Button", "X Button", "Y Button", "B Button",
    "D-Pad Down", "D-Pad Left", "D-Pad Up", "D-Pad Right",
    "Right Bumper", "Right Trigger",
}
Config.BIND_LAYER_TITLES = {
    "Base layer",
    "LT layer",
    "LB layer",
    "LT + LB layer",
}

function Config:GetControllerIconPath(iconName)
    local controllerType = self:Get("controllerType") or "xbox"
    local dPadIcons = { down = true, left = true, right = true, up = true }
    if dPadIcons[iconName] then
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. iconName
    end
    return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. controllerType .. "\\" .. iconName
end

function Config:GetSlotActionLabel(slot)
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end
    if ConsoleUI.proxied and ConsoleUI.proxied.GetSlotBinding then
        local current = ConsoleUI.proxied:GetSlotBinding(slot)
        if current then
            local action = ConsoleUI.proxied:GetActionByID(current)
            if action and action.name then
                return action.name, current
            end
            return current, current
        end
    end
    return T("Action Bar Slot") .. " " .. slot, nil
end

local function PaintBindRow(row, selected)
    if selected then
        row:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
        row:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
    else
        row:SetBackdropColor(0.078, 0.082, 0.102, 0.96)
        row:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

function Config:SelectBindingSlot(slot)
    self.selectedBindSlot = slot
    local i
    if self.bindingInputRows then
        for i = 1, table.getn(self.bindingInputRows) do
            local row = self.bindingInputRows[i]
            if row then
                PaintBindRow(row, row.slot == slot)
            end
        end
    end
    self:RefreshBindingSelection()
end

function Config:RefreshBindingSelection()
    local slot = self.selectedBindSlot
    if not slot then return end
    local label, bindingID = self:GetSlotActionLabel(slot)
    local row = self.bindingInputBySlot and self.bindingInputBySlot[slot]
    if self.selectedBindName then
        self.selectedBindName:SetText(row and row.inputName or ("Slot " .. slot))
    end
    if self.selectedBindAction then
        self.selectedBindAction:SetText(label)
    end
    if self.selectedBindIcon and row and row.icon then
        self.selectedBindIcon:SetTexture(row.icon:GetTexture())
    end
    if self.bindingActionRows then
        local i
        for i = 1, table.getn(self.bindingActionRows) do
            local actionRow = self.bindingActionRows[i]
            local selected = false
            if actionRow.kind == "default" then
                selected = bindingID == nil
            else
                selected = actionRow.bindingID == bindingID
            end
            PaintBindRow(actionRow, selected)
            if actionRow.check then
                if selected then
                    actionRow.check:SetText("OK")
                    actionRow.check:SetTextColor(1.00, 0.82, 0.18)
                else
                    actionRow.check:SetText("")
                end
            end
        end
    end
end

function Config:AssignSelectedBinding(bindingID)
    local slot = self.selectedBindSlot
    if not slot or not ConsoleUI.proxied then return end
    ConsoleUI.proxied:SetSlotBinding(slot, bindingID)
    self:RefreshBindingWorkspace()
end

function Config:RefreshBindingWorkspace()
    if not self.bindingInputRows then return end
    local i
    for i = 1, table.getn(self.bindingInputRows) do
        local row = self.bindingInputRows[i]
        if row and row.assign then
            local label = self:GetSlotActionLabel(row.slot)
            row.assign:SetText(label)
        end
    end
    self:RefreshBindingIcons()
    self:UpdateSidebarBindingVisibility()
    self:RefreshBindingSelection()
end

function Config:RefreshBindingIcons()
    if not self.bindingInputRows then return end
    local size = 18
    if self.GetGlyphSize then
        size = self:GetGlyphSize("ui")
    end
    local i
    for i = 1, table.getn(self.bindingInputRows) do
        local row = self.bindingInputRows[i]
        if row and row.iconName and row.icon then
            row.icon:SetTexture(self:GetControllerIconPath(row.iconName))
            row.icon:SetWidth(size)
            row.icon:SetHeight(size)
        end
    end
    if self.selectedBindIcon then
        self.selectedBindIcon:SetWidth(size)
        self.selectedBindIcon:SetHeight(size)
    end
    if self.selectedBindSlot then
        local row = self.bindingInputBySlot and self.bindingInputBySlot[self.selectedBindSlot]
        if self.selectedBindIcon and row and row.icon then
            self.selectedBindIcon:SetTexture(row.icon:GetTexture())
        end
    end
end

function Config:RefreshProxiedDropdowns()
    self:RefreshBindingWorkspace()
end

function Config:RefreshBindingActionList()
    if not self.bindingActionRows then return end
    local rings = ConsoleUI.proxied and ConsoleUI.proxied.RingList and ConsoleUI.proxied:RingList()
    local ringCount = rings and table.getn(rings) or 0
    local i
    for i = 1, 8 do
        local row = self.bindingRingRows and self.bindingRingRows[i]
        if row then
            if i <= ringCount then
                local ring = rings[i]
                row.bindingID = ConsoleUI.rings:BindingID(ring.id)
                row.label:SetText(ring.name or ("Ring " .. ring.id))
                row:Show()
            else
                row.bindingID = nil
                row:Hide()
            end
        end
    end
    self:LayoutBindingActions()
    self:RefreshBindingSelection()
end

function Config:LayoutBindingInputs()
    if not self.bindingSections then return end
    local leftEnabled = self:Get("sideBarLeftEnabled")
    local rightEnabled = self:Get("sideBarRightEnabled")
    local leftCount = self:Get("sideBarLeftButtons") or 3
    local rightCount = self:Get("sideBarRightButtons") or 3
    if leftCount < 1 then leftCount = 1 end
    if leftCount > 5 then leftCount = 5 end
    if rightCount < 1 then rightCount = 1 end
    if rightCount > 5 then rightCount = 5 end

    local y = 0
    local s
    for s = 1, table.getn(self.bindingSections) do
        local section = self.bindingSections[s]
        local visible = true
        local count = table.getn(section.rows)
        if section.kind == "left" then
            visible = leftEnabled and true or false
            count = leftCount
        elseif section.kind == "right" then
            visible = rightEnabled and true or false
            count = rightCount
        end
        if visible then
            section.header:ClearAllPoints()
            section.header:SetPoint("TOPLEFT", self.bindingListChild, "TOPLEFT", 0, -y)
            section.header:Show()
            y = y + 22
            local i
            for i = 1, table.getn(section.rows) do
                local row = section.rows[i]
                if i <= count then
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", self.bindingListChild, "TOPLEFT", 0, -y)
                    row:SetPoint("RIGHT", self.bindingListChild, "RIGHT", 0, 0)
                    row:Show()
                    y = y + 31
                else
                    row:Hide()
                end
            end
            y = y + 4
        else
            section.header:Hide()
            local i
            for i = 1, table.getn(section.rows) do
                section.rows[i]:Hide()
            end
        end
    end
    if self.bindingListChild then
        if y < 200 then y = 200 end
        self.bindingListChild:SetHeight(y + 8)
    end
end

function Config:LayoutBindingActions()
    if not self.bindingActionRows or not self.actionListChild then return end
    local y = 0
    local i
    for i = 1, table.getn(self.bindingActionRows) do
        local row = self.bindingActionRows[i]
        if row:IsShown() then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", self.actionListChild, "TOPLEFT", 0, -y)
            row:SetPoint("RIGHT", self.actionListChild, "RIGHT", 0, 0)
            y = y + (row.rowHeight or 28)
        end
    end
    if y < 200 then y = 200 end
    self.actionListChild:SetHeight(y + 8)
end

function Config:UpdateSidebarBindingVisibility()
    self:LayoutBindingInputs()
end

local function MakeListRow(parent, name, height)
    local row = CreateFrame("Button", name, parent)
    row:SetHeight(height or 31)
    row:SetBackdrop(Config.BACKDROP_CARD)
    PaintBindRow(row, false)
    row:EnableMouse(true)
    return row
end

function Config:CreateBindingsSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -4, 4)
    section:Hide()

    local title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", section, "TOPLEFT", 4, -2)
    title:SetText(T("Bindings"))
    title:SetTextColor(unpack(self.UI_COLORS.text))

    local resetBtn = self:MakePanelButton(section, "ConsoleUIConfigResetBindings", 120, T("Reset Bindings"), "ghost")
    resetBtn:SetPoint("TOPRIGHT", section, "TOPRIGHT", -4, -2)
    resetBtn:SetScript("OnClick", function()
        if ConsoleUIKeybindings and ConsoleUIKeybindings.ResetAllBindings then
            ConsoleUIKeybindings:ResetAllBindings()
        end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
        Config:RefreshBindingWorkspace()
    end)

    local placeBtn = self:MakePanelButton(section, "ConsoleUIConfigShowPlacement", 120, T("Spell Placement"))
    placeBtn:SetPoint("RIGHT", resetBtn, "LEFT", -6, 0)
    placeBtn:SetScript("OnClick", function()
        if ConsoleUI.placement then
            ConsoleUI.placement:Show()
            Config:Hide()
        end
    end)

    local leftPanel = CreateFrame("Frame", "ConsoleUIBindInputPanel", section)
    leftPanel:SetPoint("TOPLEFT", section, "TOPLEFT", 0, -32)
    leftPanel:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT", 0, 0)
    leftPanel:SetWidth(338)
    leftPanel:SetBackdrop(self.BACKDROP_CARD)
    leftPanel:SetBackdropColor(unpack(self.UI_COLORS.section))
    leftPanel:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local leftTitle = leftPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftTitle:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 8, -6)
    leftTitle:SetText("INPUTS")
    leftTitle:SetTextColor(0.77, 0.78, 0.80)

    local leftScroll = CreateFrame("ScrollFrame", "ConsoleUIBindInputScroll", leftPanel, "UIPanelScrollFrameTemplate")
    leftScroll:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 6, -24)
    leftScroll:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", -26, 6)
    local leftChild = CreateFrame("Frame", "ConsoleUIBindInputChild", leftScroll)
    leftChild:SetWidth(300)
    leftChild:SetHeight(400)
    leftScroll:SetScrollChild(leftChild)
    self.bindingListChild = leftChild

    local rightPanel = CreateFrame("Frame", "ConsoleUIBindActionPanel", section)
    rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", 8, 0)
    rightPanel:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", 0, 0)
    rightPanel:SetBackdrop(self.BACKDROP_CARD)
    rightPanel:SetBackdropColor(unpack(self.UI_COLORS.section))
    rightPanel:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local rightTitle = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightTitle:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 8, -6)
    rightTitle:SetText("ACTIONS")
    rightTitle:SetTextColor(0.77, 0.78, 0.80)

    local selected = CreateFrame("Frame", "ConsoleUIBindSelected", rightPanel)
    selected:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 6, -24)
    selected:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -6, -24)
    selected:SetHeight(36)
    selected:SetBackdrop(self.BACKDROP_CARD)
    selected:SetBackdropColor(unpack(self.UI_COLORS.inset))
    selected:SetBackdropBorderColor(unpack(self.UI_COLORS.border))

    local selectedIcon = selected:CreateTexture(nil, "ARTWORK")
    local selectedSize = 20
    if self.GetGlyphSize then
        selectedSize = self:GetGlyphSize("ui")
    end
    selectedIcon:SetWidth(selectedSize)
    selectedIcon:SetHeight(selectedSize)
    selectedIcon:SetPoint("LEFT", selected, "LEFT", 8, 0)
    self.selectedBindIcon = selectedIcon

    local selectedName = selected:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selectedName:SetPoint("LEFT", selectedIcon, "RIGHT", 8, 0)
    selectedName:SetTextColor(unpack(self.UI_COLORS.text))
    self.selectedBindName = selectedName

    local selectedAction = selected:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    selectedAction:SetPoint("RIGHT", selected, "RIGHT", -8, 0)
    selectedAction:SetTextColor(unpack(self.UI_COLORS.gold))
    self.selectedBindAction = selectedAction

    local actionScroll = CreateFrame("ScrollFrame", "ConsoleUIBindActionScroll", rightPanel, "UIPanelScrollFrameTemplate")
    actionScroll:SetPoint("TOPLEFT", selected, "BOTTOMLEFT", 0, -4)
    actionScroll:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", -26, 6)
    local actionChild = CreateFrame("Frame", "ConsoleUIBindActionChild", actionScroll)
    actionChild:SetWidth(300)
    actionChild:SetHeight(400)
    actionScroll:SetScrollChild(actionChild)
    self.actionListChild = actionChild

    self.bindingInputRows = {}
    self.bindingInputBySlot = {}
    self.bindingSections = {}
    self.bindingActionRows = {}
    self.bindingRingRows = {}

    local function AddInputSection(title, kind, slots)
        local header = leftChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetText(string.upper(title))
        header:SetTextColor(0.78, 0.79, 0.81)
        local sectionInfo = { title = title, kind = kind, header = header, rows = {} }
        local i
        for i = 1, table.getn(slots) do
            local spec = slots[i]
            local row = MakeListRow(leftChild, "ConsoleUIBindInput" .. spec.slot, 31)
            row.slot = spec.slot
            row.inputName = spec.name
            row.iconName = spec.iconName
            local icon = row:CreateTexture(nil, "ARTWORK")
            local iconSize = 18
            if self.GetGlyphSize then
                iconSize = self:GetGlyphSize("ui")
            end
            icon:SetWidth(iconSize)
            icon:SetHeight(iconSize)
            icon:SetPoint("LEFT", row, "LEFT", 6, 0)
            if spec.iconName then
                icon:SetTexture(self:GetControllerIconPath(spec.iconName))
            else
                icon:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
                icon:SetVertexColor(0.16, 0.16, 0.19, 1)
            end
            row.icon = icon
            local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            name:SetPoint("LEFT", icon, "RIGHT", 6, 4)
            name:SetText(spec.name)
            name:SetTextColor(unpack(self.UI_COLORS.text))
            local assign = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            assign:SetPoint("LEFT", icon, "RIGHT", 6, -8)
            assign:SetTextColor(0.40, 0.41, 0.45)
            row.assign = assign
            local capturedSlot = spec.slot
            row:SetScript("OnClick", function()
                Config:SelectBindingSlot(capturedSlot)
            end)
            table.insert(sectionInfo.rows, row)
            table.insert(self.bindingInputRows, row)
            self.bindingInputBySlot[spec.slot] = row
        end
        table.insert(self.bindingSections, sectionInfo)
    end

    local layer
    for layer = 1, 4 do
        local slots = {}
        local btn
        for btn = 1, 10 do
            table.insert(slots, {
                slot = ((layer - 1) * 10) + btn,
                name = self.BIND_BUTTON_LABELS[btn],
                iconName = self.BIND_BUTTON_ICONS[btn],
            })
        end
        AddInputSection(self.BIND_LAYER_TITLES[layer], "controller", slots)
    end

    local leftSlots = {}
    local rightSlots = {}
    local t
    for t = 1, 5 do
        table.insert(leftSlots, { slot = 40 + t, name = "Button " .. t })
        table.insert(rightSlots, { slot = 45 + t, name = "Button " .. t })
    end
    AddInputSection("Left touch bar", "left", leftSlots)
    AddInputSection("Right touch bar", "right", rightSlots)

    local function AddActionRow(kind, bindingID, label, iconPath)
        local row = MakeListRow(actionChild, nil, 28)
        row.kind = kind
        row.bindingID = bindingID
        row.rowHeight = 28
        if iconPath then
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetWidth(18)
            icon:SetHeight(18)
            icon:SetPoint("LEFT", row, "LEFT", 6, 0)
            icon:SetTexture(iconPath)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", row, "LEFT", 28, 0)
        text:SetText(label)
        text:SetTextColor(0.84, 0.85, 0.87)
        row.label = text
        local check = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        check:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        check:SetTextColor(unpack(self.UI_COLORS.gold))
        row.check = check
        local capturedID = bindingID
        local capturedKind = kind
        row:SetScript("OnClick", function()
            if capturedKind == "default" then
                Config:AssignSelectedBinding(nil)
            else
                Config:AssignSelectedBinding(this.bindingID or capturedID)
            end
        end)
        table.insert(self.bindingActionRows, row)
        return row
    end

    local function AddActionHeader(label)
        local row = CreateFrame("Frame", nil, actionChild)
        row:SetHeight(20)
        row.rowHeight = 20
        row.kind = "header"
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", row, "LEFT", 6, 0)
        text:SetText(string.upper(label))
        text:SetTextColor(0.40, 0.41, 0.45)
        row:EnableMouse(false)
        table.insert(self.bindingActionRows, row)
        return row
    end

    AddActionRow("default", nil, T("Action Bar Slot"), "Interface\\Icons\\INV_Misc_QuestionMark")
    AddActionHeader("Rings")
    local r
    for r = 1, 8 do
        local row = AddActionRow("ring", nil, "Ring " .. r, "Interface\\Icons\\INV_Misc_Orb_05")
        self.bindingRingRows[r] = row
        row:Hide()
    end

    if ConsoleUI.proxied and ConsoleUI.proxied.ACTIONS then
        local i
        for i = 1, table.getn(ConsoleUI.proxied.ACTIONS) do
            local action = ConsoleUI.proxied.ACTIONS[i]
            if action.headerKey then
                AddActionHeader(ConsoleUI.proxied:GetHeaderName(action))
            elseif action.id then
                AddActionRow("action", action.id, ConsoleUI.proxied:GetActionName(action), action.icon)
            end
        end
    end

    self.selectedBindSlot = 1
    self:RefreshBindingWorkspace()
    self:RefreshBindingActionList()
    self:SelectBindingSlot(1)

    section:SetScript("OnShow", function()
        Config:RefreshBindingActionList()
        Config:RefreshBindingWorkspace()
    end)

    self.contentSections["bindings"] = section
end
