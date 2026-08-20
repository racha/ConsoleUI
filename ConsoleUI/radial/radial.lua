--[[
    ConsoleUI - Quick Menu

    8 stick slices, gold donut chrome, white highlight.
    Center is Y menu / X reload / A confirm slice / B back.
]]

local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

ConsoleUI.radial = ConsoleUI.radial or {}
local Radial = ConsoleUI.radial

local MENU_SIZE = 520
local ICON_SIZE = 36
local RING_RADIUS = 154
local LABEL_BELOW = 27
local FACE_INNER = 33
local FACE_SIZE = 56
local CHROME_FILL = 452
local CHROME_RING = 456
local CHROME_INNER = 164
local TEX = "Interface\\AddOns\\ConsoleUI\\textures\\radial\\"
local GOLD = { 1.00, 0.82, 0.18 }

Radial.TEX = TEX
Radial.NUM_SLICES = 8
Radial.STICK_ANGLES = {
    TOP = 90, TOPRIGHT = 45, RIGHT = 0, BOTTOMRIGHT = 315,
    BOTTOM = 270, BOTTOMLEFT = 225, LEFT = 180, TOPLEFT = 135,
}

local STICK_ANGLES = Radial.STICK_ANGLES

local function ToggleBags()
    if IsBagOpen(0) then CloseAllBags() else OpenAllBags() end
end

local function ToggleChatBox()
    if not ChatFrameEditBox then return end
    if ChatFrameEditBox:IsVisible() then
        ChatFrameEditBox:Hide()
        return
    end
    ChatFrameEditBox:Show()
    ChatFrameEditBox:Raise()
    if ChatFrameEditBox.SetFocus then
        ChatFrameEditBox:SetFocus()
    end
end

local function ToggleGameMenuSafe()
    if ToggleGameMenu then
        ToggleGameMenu()
        return
    end
    if GameMenuFrame then
        if GameMenuFrame:IsVisible() then
            HideUIPanel(GameMenuFrame)
        else
            ShowUIPanel(GameMenuFrame)
        end
    end
end

local menuItems = {
    { dir = "TOP", name = L("Character"), icon = "Interface\\Icons\\INV_Shirt_White_01",
        action = function() ToggleCharacter("PaperDollFrame") end },
    { dir = "TOPRIGHT", name = L("Inventory"), icon = "Interface\\Icons\\INV_Misc_Bag_08",
        action = ToggleBags },
    { dir = "RIGHT", name = L("Spellbook"), icon = "Interface\\Icons\\INV_Misc_Book_09",
        action = function() ToggleSpellBook(BOOKTYPE_SPELL) end },
    { dir = "BOTTOMRIGHT", name = L("Quest Log"), icon = "Interface\\Icons\\INV_Misc_Note_01",
        action = function() ToggleQuestLog() end },
    { dir = "BOTTOM", name = L("World Map"), icon = "Interface\\Icons\\INV_Misc_Map_01",
        action = function() ToggleWorldMap() end },
    { dir = "BOTTOMLEFT", name = L("Social"), icon = "Interface\\Icons\\INV_Letter_02",
        action = function() ToggleFriendsFrame(1) end },
    { dir = "LEFT", name = L("Chat"), icon = "Interface\\Icons\\INV_Misc_Note_02",
        action = ToggleChatBox },
    { dir = "TOPLEFT", name = L("Setup"), icon = "Interface\\Icons\\Trade_Engineering",
        action = function()
            if ConsoleUI.config then
                ConsoleUI.config:Toggle()
            end
        end },
}

local NUM_ITEMS = table.getn(menuItems)
for i, item in ipairs(menuItems) do
    item.angle = STICK_ANGLES[item.dir] or (90 - (i - 1) * (360 / NUM_ITEMS))
end
Radial.SLICE_MIDS = { 90, 45, 0, 315, 270, 225, 180, 135 }

local MOVEMENT_MAP = {
    { action = "MOVEFORWARD", radialAction = "ConsoleUI_RADIAL_UP", keys = {"W", "UP"} },
    { action = "MOVEBACKWARD", radialAction = "ConsoleUI_RADIAL_DOWN", keys = {"S", "DOWN"} },
    { action = "STRAFELEFT", radialAction = "ConsoleUI_RADIAL_LEFT", keys = {"A", "LEFT"} },
    { action = "STRAFERIGHT", radialAction = "ConsoleUI_RADIAL_RIGHT", keys = {"D", "RIGHT"} },
}

local FACE_MAP = {
    { key = "1", action = "ConsoleUI_RADIAL_ACTION_A", restore = "ConsoleUI_ACTION_1" },
    { key = "2", action = "ConsoleUI_RADIAL_ACTION_X", restore = "ConsoleUI_ACTION_2" },
    { key = "3", action = "ConsoleUI_RADIAL_ACTION_Y", restore = "ConsoleUI_ACTION_3" },
    { key = "4", action = "ConsoleUI_RADIAL_ACTION_B", restore = "ConsoleUI_ACTION_4" },
}

local function IsTransientBinding(action)
    if not action or action == "" then return false end
    if string.find(action, "^ConsoleUI_RADIAL") then return true end
    if string.find(action, "^CONSOLEUIK_") then return true end
    if action == "ConsoleUI_RING_CANCEL" then return true end
    return false
end

local function StripSpecialFrame(name)
    if not UISpecialFrames then return end
    local i
    for i = table.getn(UISpecialFrames), 1, -1 do
        if UISpecialFrames[i] == name then
            table.remove(UISpecialFrames, i)
        end
    end
end

local CHAT_FILL = { 0, 0, 0, 1 }
local COLOR_TWEEN = 0.16
local colorTweens = {}

local function ApplyColor(tex, r, g, b, a, hideAtZero)
    if not tex then return end
    tex._cuiR, tex._cuiG, tex._cuiB, tex._cuiA = r, g, b, a
    tex:SetVertexColor(r, g, b)
    if tex.SetAlpha then
        tex:SetAlpha(a)
    end
    if hideAtZero and a <= 0.01 then
        if tex.Hide then tex:Hide() end
    elseif a > 0.01 then
        if tex.Show then tex:Show() end
    end
end

function Radial:SnapColor(tex, r, g, b, a, hideAtZero)
    if not tex then return end
    local i
    for i = table.getn(colorTweens), 1, -1 do
        if colorTweens[i].tex == tex then
            table.remove(colorTweens, i)
        end
    end
    ApplyColor(tex, r, g, b, a, hideAtZero)
end

function Radial:TweenColor(tex, r, g, b, a, dur, hideAtZero)
    if not tex then return end
    dur = dur or COLOR_TWEEN
    local r0 = tex._cuiR
    local g0 = tex._cuiG
    local b0 = tex._cuiB
    local a0 = tex._cuiA
    if r0 == nil then
        r0, g0, b0, a0 = r, g, b, a
    end
    if dur <= 0 or (math.abs(r0 - r) + math.abs(g0 - g) + math.abs(b0 - b) + math.abs(a0 - a)) < 0.012 then
        self:SnapColor(tex, r, g, b, a, hideAtZero)
        return
    end
    if a > 0.01 and tex.Show then
        tex:Show()
    end
    local i
    for i = 1, table.getn(colorTweens) do
        if colorTweens[i].tex == tex then
            colorTweens[i].r0 = r0
            colorTweens[i].g0 = g0
            colorTweens[i].b0 = b0
            colorTweens[i].a0 = a0
            colorTweens[i].r1 = r
            colorTweens[i].g1 = g
            colorTweens[i].b1 = b
            colorTweens[i].a1 = a
            colorTweens[i].t = 0
            colorTweens[i].dur = dur
            colorTweens[i].hideAtZero = hideAtZero
            return
        end
    end
    table.insert(colorTweens, {
        tex = tex, r0 = r0, g0 = g0, b0 = b0, a0 = a0,
        r1 = r, g1 = g, b1 = b, a1 = a, t = 0, dur = dur,
        hideAtZero = hideAtZero,
    })
end

function Radial:TickColorTweens(elapsed)
    if not elapsed or elapsed <= 0 then return end
    local now = GetTime and GetTime() or nil
    if now and self._tweenStamp == now then return end
    self._tweenStamp = now
    local i
    for i = table.getn(colorTweens), 1, -1 do
        local tw = colorTweens[i]
        tw.t = tw.t + elapsed
        local u = tw.t / tw.dur
        if u >= 1 then
            ApplyColor(tw.tex, tw.r1, tw.g1, tw.b1, tw.a1, tw.hideAtZero)
            table.remove(colorTweens, i)
        else
            ApplyColor(tw.tex,
                tw.r0 + (tw.r1 - tw.r0) * u,
                tw.g0 + (tw.g1 - tw.g0) * u,
                tw.b0 + (tw.b1 - tw.b0) * u,
                tw.a0 + (tw.a1 - tw.a0) * u,
                nil)
        end
    end
end

local function MakeCenteredTexture(parent, layer, file, size)
    local texture = parent:CreateTexture(nil, layer)
    texture:SetWidth(size)
    texture:SetHeight(size)
    texture:SetPoint("CENTER", parent, "CENTER", 0, 0)
    texture:SetTexture(file)
    return texture
end

function Radial:BuildPieChrome(parent)
    local chrome = {}
    chrome.donut = MakeCenteredTexture(parent, "BACKGROUND", TEX .. "Donut", CHROME_FILL)
    self:SnapColor(chrome.donut, 0.12, 0.12, 0.12, 0.75)
    chrome.slices = {}
    local i
    for i = 1, 8 do
        local slice = MakeCenteredTexture(parent, "BORDER", TEX .. "Slice" .. i, CHROME_FILL)
        self:SnapColor(slice, 1, 1, 1, 0)
        chrome.slices[i] = slice
    end
    chrome.seps = MakeCenteredTexture(parent, "ARTWORK", TEX .. "Separators", CHROME_FILL)
    self:SnapColor(chrome.seps, 1, 1, 1, 0.95)
    chrome.ring = MakeCenteredTexture(parent, "OVERLAY", TEX .. "Ring", CHROME_RING)
    self:SnapColor(chrome.ring, GOLD[1], GOLD[2], GOLD[3], 0.9)
    chrome.inner = MakeCenteredTexture(parent, "OVERLAY", TEX .. "Inner", CHROME_INNER)
    self:SnapColor(chrome.inner, GOLD[1], GOLD[2], GOLD[3], 0.9)
    return chrome
end

function Radial:SetPieHighlight(chrome, index)
    if not chrome or not chrome.slices then return end
    local i
    for i = 1, 8 do
        local a = (index and i == index) and 0.92 or 0
        self:TweenColor(chrome.slices[i], 1, 1, 1, a, COLOR_TWEEN)
    end
end

function Radial:SlicePoint(angle, radius)
    local rad = math.rad(angle)
    return math.cos(rad) * radius, math.sin(rad) * radius
end

function Radial:CreateFrame()
    if self.frame then return self.frame end

    local frame = CreateFrame("Frame", "ConsoleUIRadialMenu", UIParent)
    frame:SetWidth(MENU_SIZE)
    frame:SetHeight(MENU_SIZE)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(100)
    frame:EnableMouse(false)
    frame:Hide()

    local overlay = CreateFrame("Frame", "ConsoleUIRadialOverlay", UIParent)
    overlay:SetAllPoints(UIParent)
    overlay:SetFrameStrata("FULLSCREEN")
    overlay:SetFrameLevel(99)
    overlay:EnableMouse(true)
    overlay:Hide()
    overlay:SetAlpha(0)
    local overlayBg = overlay:CreateTexture(nil, "BACKGROUND")
    overlayBg:SetAllPoints(overlay)
    overlayBg:SetTexture(0, 0, 0, 1)
    overlay.bg = overlayBg
    overlay:SetScript("OnMouseDown", function()
        Radial:Hide()
    end)
    self.overlay = overlay

    self.frame = frame
    self.chrome = self:BuildPieChrome(frame)
    self:CreateButtons()
    self:CreateFaceCluster(frame)

    StripSpecialFrame("ConsoleUIRadialMenu")
    frame:SetScript("OnHide", function()
        Radial:Cleanup()
    end)
    frame:SetScript("OnUpdate", function()
        Radial:OnUpdate(arg1)
    end)
    return frame
end

function Radial:CreateButtons()
    self.buttons = {}
    local i
    for i = 1, NUM_ITEMS do
        table.insert(self.buttons, self:CreateMenuButton(i, menuItems[i]))
    end
end

function Radial:CreateMenuButton(index, item)
    local frame = self.frame
    local button = CreateFrame("Button", "ConsoleUIRadialButton" .. index, frame)
    button:SetWidth(ICON_SIZE + 8)
    button:SetHeight(ICON_SIZE + 28)
    button.item = item
    button.index = index

    local px, py = self:SlicePoint(item.angle, RING_RADIUS)
    button:SetPoint("CENTER", frame, "CENTER", px, py + 8)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(ICON_SIZE)
    icon:SetHeight(ICON_SIZE)
    icon:SetPoint("TOP", button, "TOP", 0, 0)
    icon:SetTexture(item.icon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOP", icon, "BOTTOM", 0, -(LABEL_BELOW - 18))
    label:SetText(item.name)
    label:SetTextColor(0.93, 0.93, 0.93)
    button.label = label

    button:SetScript("OnClick", function()
        Radial:SetSelectedIndex(this.index)
        Radial:ActivateFace("A")
    end)
    button:SetScript("OnEnter", function()
        Radial:SetSelectedIndex(this.index)
    end)
    return button
end

function Radial:CreateFaceCluster(frame)
    self.faceButtons = {}
    local layout = {
        { id = "Y", x = 0, y = FACE_INNER, key = "N", icon = TEX .. "Menu", crop = false },
        { id = "X", x = -FACE_INNER, y = 0, key = "W", icon = TEX .. "Reload", crop = false },
        { id = "A", x = 0, y = -FACE_INNER, key = "S", icon = "Interface\\Buttons\\UI-CheckBox-Check", crop = false },
        { id = "B", x = FACE_INNER, y = 0, key = "E", icon = "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up", crop = false },
    }
    local parentLevel = frame:GetFrameLevel() or 100
    local i
    for i = 1, table.getn(layout) do
        local spec = layout[i]
        local button = CreateFrame("Button", "ConsoleUIRadialFace" .. spec.id, frame)
        button:SetWidth(FACE_SIZE)
        button:SetHeight(FACE_SIZE)
        button:SetFrameLevel(parentLevel + 12)
        button:SetPoint("CENTER", frame, "CENTER", spec.x, spec.y)
        button.face = spec.id

        local plate = button:CreateTexture(nil, "BACKGROUND")
        plate:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
        plate:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
        plate:SetTexture(TEX .. "Key" .. spec.key)
        self:SnapColor(plate, CHAT_FILL[1], CHAT_FILL[2], CHAT_FILL[3], CHAT_FILL[4])
        button.plate = plate

        local ring = button:CreateTexture(nil, "BORDER")
        ring:SetPoint("TOPLEFT", button, "TOPLEFT", -6, 6)
        ring:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 6, -6)
        ring:SetTexture(TEX .. "KeyHi" .. spec.key)
        self:SnapColor(ring, GOLD[1], GOLD[2], GOLD[3], 1)
        button.ring = ring

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(24)
        icon:SetHeight(24)
        icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        if spec.icon then
            icon:SetTexture(spec.icon)
            if spec.crop then
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            else
                icon:SetTexCoord(0, 1, 0, 1)
            end
            icon:Show()
        else
            icon:Hide()
        end
        button.icon = icon

        button:SetScript("OnClick", function()
            Radial:ActivateFace(this.face)
        end)
        self.faceButtons[spec.id] = button
    end
end

function Radial:SetFaceClusterShown(shown)
    if not self.faceButtons then return end
    local id, button
    for id, button in pairs(self.faceButtons) do
        if shown then button:Show() else button:Hide() end
    end
end

function Radial:ActivateStickNavigation()
    if self.stickBindings then return end

    self.stickBindings = {}
    local i
    for i = 1, table.getn(MOVEMENT_MAP) do
        local mapping = MOVEMENT_MAP[i]
        local keys = {}
        local primaryKey, secondaryKey = GetBindingKey(mapping.action)
        if primaryKey then table.insert(keys, primaryKey) end
        if secondaryKey then table.insert(keys, secondaryKey) end
        if table.getn(keys) == 0 then
            keys = mapping.keys
        end
        local k
        for k = 1, table.getn(keys) do
            local key = keys[k]
            if self.stickBindings[key] == nil then
                local previousAction = GetBindingAction(key)
                if previousAction == "" or IsTransientBinding(previousAction) then
                    self.stickBindings[key] = mapping.action
                else
                    self.stickBindings[key] = previousAction
                end
                SetBinding(key, mapping.radialAction)
            end
        end
    end

    for i = 1, table.getn(FACE_MAP) do
        local binding = FACE_MAP[i]
        local key = GetBindingKey(binding.restore)
        if not key or key == "" then
            key = binding.key
        end
        if self.stickBindings[key] == nil then
            local previousAction = GetBindingAction(key)
            if previousAction == "" or IsTransientBinding(previousAction) then
                self.stickBindings[key] = binding.restore
            else
                self.stickBindings[key] = previousAction
            end
            SetBinding(key, binding.action)
        end
    end

    self.directionState = { UP = false, DOWN = false, LEFT = false, RIGHT = false }
end

function Radial:ActivateRingNavigation()
    if self.stickBindings then return end

    self.stickBindings = {}
    local i
    for i = 1, table.getn(MOVEMENT_MAP) do
        local mapping = MOVEMENT_MAP[i]
        local keys = {}
        local primaryKey, secondaryKey = GetBindingKey(mapping.action)
        if primaryKey then table.insert(keys, primaryKey) end
        if secondaryKey then table.insert(keys, secondaryKey) end
        if table.getn(keys) == 0 then
            keys = mapping.keys
        end
        local k
        for k = 1, table.getn(keys) do
            local key = keys[k]
            if self.stickBindings[key] == nil then
                local previousAction = GetBindingAction(key)
                if previousAction == "" or IsTransientBinding(previousAction) then
                    self.stickBindings[key] = mapping.action
                else
                    self.stickBindings[key] = previousAction
                end
                SetBinding(key, mapping.radialAction)
            end
        end
    end

    local bKey = GetBindingKey("ConsoleUI_ACTION_4")
    if not bKey or bKey == "" then
        bKey = "4"
    end
    local bNow = GetBindingAction(bKey)
    -- Don't steal B if this hold is the ring trigger itself.
    if not (bNow and string.find(bNow, "^ConsoleUI_RING_")) then
        if self.stickBindings[bKey] == nil then
            if bNow == "" or IsTransientBinding(bNow) then
                self.stickBindings[bKey] = "ConsoleUI_ACTION_4"
            else
                self.stickBindings[bKey] = bNow
            end
            SetBinding(bKey, "ConsoleUI_RADIAL_ACTION_B")
        end
    end

    local esc = GetBindingAction("ESCAPE")
    if esc ~= "ConsoleUI_RING_CANCEL" then
        if esc == "" or IsTransientBinding(esc) then
            self.stickBindings["ESCAPE"] = "TOGGLEGAMEMENU"
        else
            self.stickBindings["ESCAPE"] = esc
        end
        SetBinding("ESCAPE", "ConsoleUI_RING_CANCEL")
    end

    self.directionState = { UP = false, DOWN = false, LEFT = false, RIGHT = false }
end

function Radial:RestoreStickNavigation()
    if self.stickBindings then
        for key, previousAction in pairs(self.stickBindings) do
            if key == "ESCAPE" then
                if previousAction and previousAction ~= "" and not IsTransientBinding(previousAction) then
                    SetBinding(key, previousAction)
                else
                    SetBinding(key, "TOGGLEGAMEMENU")
                end
            elseif previousAction and not IsTransientBinding(previousAction) then
                SetBinding(key, previousAction)
            else
                SetBinding(key, nil)
            end
        end
        self.stickBindings = nil
        self.directionState = { UP = false, DOWN = false, LEFT = false, RIGHT = false }
    end
    self:ClearStolenBindings()
    self:RepairEscapeBinding()
end

function Radial:RepairEscapeBinding()
    if ConsoleUI_BindingsReady and not ConsoleUI_BindingsReady() then
        return false
    end
    local escape = GetBindingAction("ESCAPE")
    if escape and escape ~= "" and not IsTransientBinding(escape) then
        return false
    end
    SetBinding("ESCAPE", "TOGGLEGAMEMENU")
    return true
end

function Radial:HookGameMenu()
    if self.gameMenuHooked or not GameMenuFrame then return end
    self.gameMenuHooked = true
    local previous = GameMenuFrame:GetScript("OnShow")
    GameMenuFrame:SetScript("OnShow", function()
        if previous then previous() end
        if Radial.IsOpen and Radial:IsOpen() then
            Radial:Hide()
        end
        if ConsoleUI.rings and ConsoleUI.rings.Cancel then
            ConsoleUI.rings:Cancel()
        end
    end)
end

function Radial:ClearStolenBindings()
    local i
    for i = 1, table.getn(FACE_MAP) do
        local binding = FACE_MAP[i]
        if IsTransientBinding(GetBindingAction(binding.key)) then
            SetBinding(binding.key, binding.restore)
        end
    end
    for i = 1, table.getn(MOVEMENT_MAP) do
        local mapping = MOVEMENT_MAP[i]
        local k
        for k = 1, table.getn(mapping.keys) do
            local key = mapping.keys[k]
            if IsTransientBinding(GetBindingAction(key)) then
                SetBinding(key, mapping.action)
            end
        end
    end
end

function Radial:RepairMovementBindings()
    self:RestoreStickNavigation()
    local lists = { "DropDownList1", "DropDownList2" }
    local li
    for li = 1, 2 do
        local frame = getglobal(lists[li])
        if frame and frame.IsShown and frame:IsShown() then
            frame:Hide()
        end
    end
    if ConsoleUI_BindingsReady and not ConsoleUI_BindingsReady() then
        return
    end
    local changed = false
    if ConsoleUIKeyboard and ConsoleUIKeyboard.RepairKeys then
        if ConsoleUIKeyboard:RepairKeys() then
            changed = true
        end
    end
    local KEY_MODS = { "", "SHIFT-", "CTRL-", "CTRL-SHIFT-" }
    local i
    for i = 1, table.getn(MOVEMENT_MAP) do
        local mapping = MOVEMENT_MAP[i]
        local k
        for k = 1, table.getn(mapping.keys) do
            local mi
            for mi = 1, table.getn(KEY_MODS) do
                local key = KEY_MODS[mi] .. mapping.keys[k]
                local current = GetBindingAction(key)
                if IsTransientBinding(current) then
                    if KEY_MODS[mi] == "" then
                        SetBinding(key, mapping.action)
                    else
                        SetBinding(key, nil)
                    end
                    changed = true
                end
            end
        end
        if not GetBindingKey(mapping.action) then
            SetBinding(mapping.keys[1], mapping.action)
            changed = true
        end
    end
    for i = 1, table.getn(FACE_MAP) do
        local binding = FACE_MAP[i]
        local current = GetBindingAction(binding.key)
        if IsTransientBinding(current) then
            SetBinding(binding.key, binding.restore)
            changed = true
        end
    end
    if self:RepairEscapeBinding() then
        changed = true
    end
    if changed then
        if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then
            ConsoleUI.proxied:ApplyAllBindings()
        else
            ConsoleUI_SaveBindings()
        end
        ConsoleUI_PrintDebug("Restored movement keys that were stuck on the Quick Menu.")
    end
end

function Radial:SetSelectedIndex(index)
    local selected = index and menuItems[index] or nil
    self.selectedIndex = index
    self.selectedItem = selected
    self:SetPieHighlight(self.chrome, index)
    if self.buttons then
        local _, button
        for _, button in ipairs(self.buttons) do
            if button.label then
                if index and button.index == index then
                    button.label:SetTextColor(0.07, 0.07, 0.07)
                else
                    button.label:SetTextColor(0.93, 0.93, 0.93)
                end
            end
        end
    end
end

function Radial:StickAngle()
    local state = self.directionState
    if not state then return nil end
    local id = nil
    if state.UP and not state.DOWN then
        if state.LEFT and not state.RIGHT then id = "TOPLEFT"
        elseif state.RIGHT and not state.LEFT then id = "TOPRIGHT"
        elseif not state.LEFT and not state.RIGHT then id = "TOP" end
    elseif state.DOWN and not state.UP then
        if state.LEFT and not state.RIGHT then id = "BOTTOMLEFT"
        elseif state.RIGHT and not state.LEFT then id = "BOTTOMRIGHT"
        elseif not state.LEFT and not state.RIGHT then id = "BOTTOM" end
    elseif state.LEFT and not state.RIGHT then
        id = "LEFT"
    elseif state.RIGHT and not state.LEFT then
        id = "RIGHT"
    end
    return id and STICK_ANGLES[id] or nil
end

function Radial:IndexForAngle(angle)
    if not angle then return nil end
    local i
    for i = 1, NUM_ITEMS do
        if menuItems[i].angle == angle then
            return i
        end
    end
    return nil
end

function Radial:UpdateDirectionSelection()
    local angle = self:StickAngle()
    self:SetSelectedIndex(self:IndexForAngle(angle))
end

function Radial:SetDirectionState(direction, pressed)
    if not self:IsVisible() or not self.directionState then return end
    self.directionState[direction] = pressed and true or false
    self:UpdateDirectionSelection()
end

function Radial:ActivateFace(face)
    if face == "B" then
        self:Hide()
        return
    end
    if face == "Y" then
        self:Hide()
        ToggleGameMenuSafe()
        return
    end
    if face == "X" then
        self:Hide()
        ReloadUI()
        return
    end
    if face == "A" then
        local item = self.selectedIndex and menuItems[self.selectedIndex]
        if not item or not item.action then
            return
        end
        self:Hide()
        item.action()
    end
end

function ConsoleUI_RadialInput(direction, pressed)
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        ConsoleUI.rings:SetDirectionState(direction, pressed)
        return
    end
    if ConsoleUI.radial then
        ConsoleUI.radial:SetDirectionState(direction, pressed)
    end
end

function ConsoleUI_RadialActivate(faceButton, pressed)
    if not pressed then return end
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        if faceButton == "B" then
            ConsoleUI.rings:Cancel()
        end
        return
    end
    if ConsoleUI.radial then
        ConsoleUI.radial:ActivateFace(faceButton)
    end
end

function Radial:OnUpdate(elapsed)
    if not elapsed or elapsed <= 0 then elapsed = 0.016 end
    self:TickColorTweens(elapsed)
    self.intro = (self.intro or 0) + elapsed * 8
    if self.intro > 1 then self.intro = 1 end
    if self.overlay and self.overlay:IsShown() then
        self.overlay:SetAlpha(0.35 * self.intro)
    end
end

function Radial:Show()
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        ConsoleUI.rings:Cancel()
    end
    if not self.frame then
        self:CreateFrame()
    end
    self:SetFaceClusterShown(true)
    self.cleaned = nil
    self.intro = 0
    if self.overlay then
        self.overlay:EnableMouse(true)
        self.overlay:SetAlpha(0)
        self.overlay:Show()
    end
    self.frame:Show()
    self:ActivateStickNavigation()
    self:SetSelectedIndex(nil)
    if PlaySound then PlaySound("igMainMenuOpen") end
end

function Radial:Hide()
    self:RestoreStickNavigation()
    if self.overlay then
        self.overlay:EnableMouse(false)
        self.overlay:Hide()
        self.overlay:SetAlpha(0)
    end
    if self.frame and self.frame:IsShown() then
        if PlaySound then PlaySound("igMainMenuClose") end
        self.frame:Hide()
        return
    end
    self:Cleanup()
end

function Radial:Cleanup()
    if self.overlay then
        self.overlay:EnableMouse(false)
        self.overlay:Hide()
        self.overlay:SetAlpha(0)
    end
    self:RestoreStickNavigation()
    self.selectedIndex = nil
    self.selectedItem = nil
    self.directionState = nil
    if self.cleaned then return end
    self.cleaned = true
end

function Radial:IsVisible()
    return self.frame and self.frame:IsVisible()
end

function Radial:IsOpen()
    return self.overlay and self.overlay:IsShown() and self:IsVisible()
end

function Radial:EnsureOverlayMatchesFrame()
    if self.overlay and self.overlay:IsShown() and not self:IsVisible() then
        self.overlay:EnableMouse(false)
        self.overlay:Hide()
        self.overlay:SetAlpha(0)
    end
end

function Radial:Initialize()
    self:CreateFrame()
    self:HookGameMenu()
    StripSpecialFrame("ConsoleUIRadialMenu")
    self:RepairEscapeBinding()
    self:RepairMovementBindings()
    ConsoleUI_Debug("Radial menu loaded.")
end
