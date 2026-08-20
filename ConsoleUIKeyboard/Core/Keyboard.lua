local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Language = ns

BINDING_HEADER_CONSOLEUIKEYBOARD = "ConsoleUI Keyboard"
BINDING_NAME_CONSOLEUIK_PAD_UP = "Keyboard Pad Up"
BINDING_NAME_CONSOLEUIK_PAD_DOWN = "Keyboard Pad Down"
BINDING_NAME_CONSOLEUIK_PAD_LEFT = "Keyboard Pad Left"
BINDING_NAME_CONSOLEUIK_PAD_RIGHT = "Keyboard Pad Right"
BINDING_NAME_CONSOLEUIK_FACE_Y = "Keyboard Y"
BINDING_NAME_CONSOLEUIK_FACE_X = "Keyboard X"
BINDING_NAME_CONSOLEUIK_FACE_A = "Keyboard A"
BINDING_NAME_CONSOLEUIK_FACE_B = "Keyboard B"
BINDING_NAME_CONSOLEUIK_ACCEPT = "Keyboard Accept"
BINDING_NAME_CONSOLEUIK_GUESS_UP = "Keyboard Prev Suggestion"
BINDING_NAME_CONSOLEUIK_GUESS_DOWN = "Keyboard Next Suggestion"
BINDING_NAME_CONSOLEUIK_CLOSE = "Keyboard Close"

local Keyboard = CreateFrame("Frame", "ConsoleUIKeyboard", UIParent)
Keyboard.Util = U
Keyboard.Language = Language
Keyboard.Sets = {}
Keyboard.DIR = 9
Keyboard.KEY = { UP = false, DOWN = false, LEFT = false, RIGHT = false }
Keyboard.enabled = true
Keyboard.Timer = 0

-- LT=Shift and LB=Ctrl are layer modifiers. WoW looks up SHIFT-3, not 3,
-- so the unmodified steal alone cannot type uppercase / symbols.
local STEAL_BASE = {
    { key = "1", action = "CONSOLEUIK_FACE_A" },
    { key = "2", action = "CONSOLEUIK_FACE_X" },
    { key = "3", action = "CONSOLEUIK_FACE_Y" },
    { key = "4", action = "CONSOLEUIK_FACE_B" },
    { key = "5", action = "CONSOLEUIK_GUESS_DOWN" },
    { key = "6", action = "CONSOLEUIK_PAD_LEFT" },
    { key = "7", action = "CONSOLEUIK_GUESS_UP" },
    { key = "8", action = "CONSOLEUIK_PAD_RIGHT" },
    { key = "0", action = "CONSOLEUIK_ACCEPT" },
    { key = "W", action = "CONSOLEUIK_PAD_UP" },
    { key = "A", action = "CONSOLEUIK_PAD_LEFT" },
    { key = "S", action = "CONSOLEUIK_PAD_DOWN" },
    { key = "D", action = "CONSOLEUIK_PAD_RIGHT" },
    { key = "UP", action = "CONSOLEUIK_PAD_UP" },
    { key = "DOWN", action = "CONSOLEUIK_PAD_DOWN" },
    { key = "LEFT", action = "CONSOLEUIK_PAD_LEFT" },
    { key = "RIGHT", action = "CONSOLEUIK_PAD_RIGHT" },
}

local STEAL_MODS = { "", "SHIFT-", "CTRL-", "CTRL-SHIFT-" }
local STEAL = {}
do
    local bi, mi
    for bi = 1, table.getn(STEAL_BASE) do
        for mi = 1, table.getn(STEAL_MODS) do
            table.insert(STEAL, {
                key = STEAL_MODS[mi] .. STEAL_BASE[bi].key,
                action = STEAL_BASE[bi].action,
            })
        end
    end
end
-- Plain Escape only. SHIFT-ESCAPE is ConsoleUI radial; do not steal the mods.
table.insert(STEAL, { key = "ESCAPE", action = "CONSOLEUIK_CLOSE" })
Keyboard.StealCount = table.getn(STEAL)

local function SplitStealKey(key)
    if string.find(key, "^CTRL%-SHIFT%-") then
        return "CTRL-SHIFT-", string.sub(key, 12)
    elseif string.find(key, "^SHIFT%-") then
        return "SHIFT-", string.sub(key, 7)
    elseif string.find(key, "^CTRL%-") then
        return "CTRL-", string.sub(key, 6)
    end
    return "", key
end

local function IsTransientBinding(action)
    if not action or action == "" then return false end
    if string.find(action, "^CONSOLEUIK_") then return true end
    if string.find(action, "^ConsoleUI_RADIAL") then return true end
    if action == "ConsoleUI_RING_CANCEL" then return true end
    return false
end

local function OverlayOwnsStick()
    local cui = ConsoleUI
    if not cui then return false end
    if cui.radial and cui.radial.IsOpen and cui.radial:IsOpen() then
        return true
    end
    if cui.rings and cui.rings.IsVisible and cui.rings:IsVisible() then
        return true
    end
    return false
end

local function RepairActionFor(key)
    local mod, base = SplitStealKey(key)
    if string.find(base, "^[0-9]$") then
        local slot = tonumber(base)
        if slot == 0 then slot = 10 end
        if mod == "CTRL-SHIFT-" then
            slot = slot + 30
        elseif mod == "CTRL-" then
            slot = slot + 20
        elseif mod == "SHIFT-" then
            slot = slot + 10
        end
        return "ConsoleUI_ACTION_" .. slot
    end
    if mod ~= "" then
        return nil
    end
    if base == "W" or base == "UP" then return "MOVEFORWARD" end
    if base == "S" or base == "DOWN" then return "MOVEBACKWARD" end
    if base == "A" then return "STRAFELEFT" end
    if base == "D" then return "STRAFERIGHT" end
    if base == "LEFT" then return "TURNLEFT" end
    if base == "RIGHT" then return "TURNRIGHT" end
    if base == "ESCAPE" then return "TOGGLEGAMEMENU" end
    return nil
end

local function RecordedPrevious(key, current)
    if current and current ~= "" and not IsTransientBinding(current) then
        return current
    end
    local fallback = RepairActionFor(key)
    if fallback then
        return fallback
    end
    return false
end

function Keyboard:GetFocusUTF8Pos()
    if not self.Focus then return 0 end
    local text = self.Focus:GetText() or ""
    -- Stock 1.12 has no GetCursorPosition. OSK Insert keeps the caret at end.
    if self.Focus.GetCursorPosition then
        return U.byteToChars(text, self.Focus:GetCursorPosition() or 0)
    end
    return U.utf8len(text)
end

function Keyboard:SetFocusUTF8Pos(pos)
    if not self.Focus or not self.Focus.SetCursorPosition then return end
    local text = self.Focus:GetText() or ""
    self.Focus:SetCursorPosition(U.charsToByte(text, pos))
end

function Keyboard:IsEnabled()
    if ConsoleUIKeyboardDB and ConsoleUIKeyboardDB.disabled then
        return false
    end
    return self.enabled
end

function Keyboard:SetEnabled(state)
    self.enabled = state and true or false
    if not self.enabled then
        self:CLOSE()
    end
end

function Keyboard:LoadSettings()
    ConsoleUIKeyboardDB = ConsoleUIKeyboardDB or {}
    local ver = Language.LayoutVersion or 1
    if not ConsoleUIKeyboardLayout or ConsoleUIKeyboardDB.layoutVersion ~= ver then
        local locale = GetLocale and GetLocale() or "enUS"
        local name = Language.Default and Language.Default[locale]
        local src = (name and Language[name]) or Language.English
        ConsoleUIKeyboardLayout = U.CopyLayout(src)
        ConsoleUIKeyboardDB.layoutVersion = ver
    end
    local ok = U.LayoutOk(ConsoleUIKeyboardLayout)
    if not ok then
        ConsoleUIKeyboardLayout = U.CopyLayout(Language.English)
        ConsoleUIKeyboardDB.layoutVersion = ver
    end
    if not ConsoleUIKeyboardDictionary then
        ConsoleUIKeyboardDictionary = {}
    end
    self.Dictionary = ConsoleUIKeyboardDictionary
end

function Keyboard:EnsureDictionary()
    if self.dictionaryReady then return end
    self.dictionaryReady = true
    if self.Dictionary and next(self.Dictionary) then
        return
    end
    if self.GenerateDictionary then
        self.Dictionary = self:GenerateDictionary()
        if self.NormalizeDictionary then
            self:NormalizeDictionary()
        end
        ConsoleUIKeyboardDictionary = self.Dictionary
        U.Debug("dictionary built")
    end
end

function Keyboard:SetLayout()
    local layout = ConsoleUIKeyboardLayout
    if not layout or not self.Sets then return end
    local i
    for i = 1, 8 do
        local set = self.Sets[i]
        if set and set.Buttons then
            local j
            for j = 1, 4 do
                local char = set.Buttons[j]
                if char and layout[i] and layout[i][j] then
                    char.Set = layout[i][j]
                end
            end
        end
    end
    self:CheckModifier()
end

function Keyboard:SelectSet()
    local dir = U.SelectDir(self.KEY.UP, self.KEY.DOWN, self.KEY.LEFT, self.KEY.RIGHT)
    self.DIR = dir
    if self.Current and self.Current.Leave then
        self.Current:Leave()
    end
    if self.Sets[dir] then
        if self.CenterSet and self.CenterSet.Update then
            self.CenterSet:Update()
        end
        if self.Sets[dir].Enter then
            self.Sets[dir]:Enter()
        end
        self.Current = self.Sets[dir]
    else
        self.Current = nil
    end
    return dir
end

local LAYER_LABEL = { "ABC", "abc", "#?!", "/cmd" }

function Keyboard:CheckModifier()
    if not self.Sets then return end
    local index = U.ModifierIndex(IsShiftKeyDown() and true or false, IsControlKeyDown() and true or false)
    if self.LayerText then
        self.LayerText:SetText(LAYER_LABEL[index] or "abc")
    end
    local i
    for i = 1, table.getn(self.Sets) do
        local set = self.Sets[i]
        if set and set.Buttons then
            local j
            for j = 1, table.getn(set.Buttons) do
                local char = set.Buttons[j]
                if char and char.SetChar then
                    char:SetChar(index)
                end
            end
        end
    end
    if self.CenterSet and self.CenterSet.Update then
        self.CenterSet:Update()
    end
end

function Keyboard:INPUT(index)
    if not index or not self.Current or not self.Current.Buttons then return end
    local button = self.Current.Buttons[index]
    if button and button.Click then
        button.Click(button)
    end
end

local function RunBoxScript(box, handler)
    local script = box:GetScript(handler)
    if not script then return end
    local previous = this
    this = box
    script()
    this = previous
end

function Keyboard:SPACE()
    if not self.Focus then return end
    RunBoxScript(self.Focus, "OnSpacePressed")
    self.Focus:Insert(" ")
end

function Keyboard:ERASE()
    if not self.Focus then return end
    local pos = self:GetFocusUTF8Pos()
    if pos == 0 then return end
    local text = self.Focus:GetText() or ""
    local before = U.utf8sub(text, 1, pos)
    local leftEnd = pos - 1
    if string.find(before, "{rt%d}$") then
        leftEnd = pos - 5
    end
    if leftEnd < 0 then leftEnd = 0 end
    local first = U.utf8sub(text, 1, leftEnd)
    local second = U.utf8sub(text, pos + 1, U.utf8len(text) - pos)
    self.Focus:SetText(first .. second)
    self:SetFocusUTF8Pos(leftEnd)
end

function Keyboard:ENTER()
    if not self.Focus then
        self:CLOSE()
        return
    end
    RunBoxScript(self.Focus, "OnEnterPressed")
    self:CLOSE()
end

function Keyboard:LEFT()
    if not self.Focus then return end
    local text = self.Focus:GetText() or ""
    local pos = self:GetFocusUTF8Pos()
    local marker = string.find(string.sub(text, math.max(1, U.charsToByte(text, pos) - 4), U.charsToByte(text, pos)), "{rt%d}")
    self:SetFocusUTF8Pos(marker and pos - 5 or pos - 1)
end

function Keyboard:RIGHT()
    if not self.Focus then return end
    local text = self.Focus:GetText() or ""
    local pos = self:GetFocusUTF8Pos()
    local byte = U.charsToByte(text, pos)
    local marker = string.find(string.sub(text, byte + 1, byte + 5), "{rt%d}")
    self:SetFocusUTF8Pos(marker and pos + 5 or pos + 1)
end

function Keyboard:EnsureStolen()
    if not self:IsShown() then return end
    if not self.stolen then
        self:StealKeys()
        return
    end
    local leaveRadial = OverlayOwnsStick()
    local i
    for i = 1, table.getn(STEAL) do
        local row = STEAL[i]
        local current = GetBindingAction(row.key)
        if current ~= row.action then
            if leaveRadial and current and string.find(current, "^ConsoleUI_RADIAL") then
                -- pie / ring still owns this key
            else
                SetBinding(row.key, row.action)
            end
        end
    end
end

function Keyboard:StealKeys()
    if self.stolen then return end
    self.stolen = {}
    local leaveRadial = OverlayOwnsStick()
    local i
    for i = 1, table.getn(STEAL) do
        local row = STEAL[i]
        local current = GetBindingAction(row.key)
        self.stolen[row.key] = RecordedPrevious(row.key, current)
        if current == row.action then
            -- already ours
        elseif leaveRadial and current and string.find(current, "^ConsoleUI_RADIAL") then
            U.Debug("skip steal " .. row.key .. " (radial owns it)")
        else
            SetBinding(row.key, row.action)
        end
    end
    U.Debug("stole pad/face/accept keys")
end

function Keyboard:RestoreKeys()
    if not self.stolen then return end
    local leaveRadial = OverlayOwnsStick()
    local key, previous
    for key, previous in pairs(self.stolen) do
        local now = GetBindingAction(key)
        if leaveRadial and now and string.find(now, "^ConsoleUI_RADIAL") then
            -- pie / ring still owns this key
        elseif now == "" or IsTransientBinding(now) then
            if previous then
                SetBinding(key, previous)
            else
                SetBinding(key, nil)
            end
        end
    end
    self.stolen = nil
    U.Debug("restored keys")
end

function Keyboard:RestoreCursorPad()
    local cursor = ConsoleUI and ConsoleUI.cursor
    local ck = cursor and cursor.keybindings
    local btn = cursor and cursor.navigationState and cursor.navigationState.currentButton
    if ck and ck.cursorModeActive and btn and cursor.tooltip then
        ck.currentButton = nil
        ck:ApplyContextBindings(cursor.tooltip:GetBindings(btn:GetName() or ""), btn)
    end
end

function Keyboard:RepairKeys()
    if self:IsShown() then return false end
    local leaveRadial = OverlayOwnsStick()
    local changed = false
    local i
    for i = 1, table.getn(STEAL) do
        local row = STEAL[i]
        local current = GetBindingAction(row.key)
        if leaveRadial and current and string.find(current, "^ConsoleUI_RADIAL") then
            -- pie / ring still owns this key
        elseif IsTransientBinding(current) then
            local action = RepairActionFor(row.key)
            if action then
                SetBinding(row.key, action)
            else
                SetBinding(row.key, nil)
            end
            changed = true
        end
    end
    -- Chat close already writes these via RecordedPrevious. Do the same on
    -- login when 5-8 were wiped empty and ACTION_n has no other key.
    if not ConsoleUI_BindingsReady or ConsoleUI_BindingsReady() then
        local slot
        for slot = 5, 8 do
            local key = tostring(slot)
            local current = GetBindingAction(key)
            if not current or current == "" then
                local action = "ConsoleUI_ACTION_" .. slot
                if not GetBindingKey or not GetBindingKey(action) then
                    SetBinding(key, action)
                    changed = true
                end
            end
        end
    end
    return changed
end

function Keyboard:ReleaseIdleChatBox()
    if self:IsShown() or self.settingFocus then
        return
    end
    -- OSK hidden. Leftover Focus / a shown chat box ate 1-4 and D-pad
    -- until the player opened and closed chat.
    local dirty = false
    if self.Focus then
        local live = self.Focus
        if live ~= ChatFrameEditBox and live.IsVisible and live:IsVisible() then
            self:SetFocus(live)
            return
        end
        self.Focus = nil
        dirty = true
    end
    if not self:IsEnabled() then
        if dirty then
            if self.stolen then
                self:RestoreKeys()
            end
            self:RepairKeys()
        end
        return
    end
    local box = ChatFrameEditBox
    if box then
        local focused = box.HasFocus and box:HasFocus()
        if focused then
            local now = GetTime and GetTime() or 0
            if self.chatWanted and (now - self.chatWanted) < 1 then
                self:SetFocus(box)
                return
            end
            if box.ClearFocus then
                box:ClearFocus()
            end
            dirty = true
        end
        if box.IsShown and box:IsShown() then
            box:Hide()
            dirty = true
        end
    end
    if self.stolen then
        self:RestoreKeys()
        dirty = true
    end
    if dirty then
        self:RepairKeys()
    end
end

function Keyboard:HookSaveBindings()
    if self.saveHooked then return end
    if ConsoleUI_SaveBindings then
        local prev = ConsoleUI_SaveBindings
        ConsoleUI_SaveBindings = function()
            local wasOn = Keyboard.stolen and true or false
            if wasOn then
                Keyboard:RestoreKeys()
            end
            prev()
            if wasOn and Keyboard:IsShown() then
                Keyboard:StealKeys()
            end
        end
        self.saveHooked = true
    end
end

function Keyboard:SilenceBox(box)
    if not box then return end
    if box.EnableKeyboard then
        box:EnableKeyboard(false)
    end
    if box.ClearFocus then
        box:ClearFocus()
    end
end

function Keyboard:RestoreBox(box)
    if not box then return end
    if box.EnableKeyboard then
        box:EnableKeyboard(true)
    end
end

function Keyboard:SetFocus(box)
    if self.closing or self.settingFocus then return end
    if not box or not self:IsEnabled() then return end
    if self.Focus == box and self:IsShown() then
        self:SilenceBox(box)
        return
    end
    self.settingFocus = true
    self:EnsureDictionary()
    if self.Focus and self.Focus ~= box then
        self:RestoreBox(self.Focus)
    end
    self.Focus = box
    -- Focused EditBox eats WASD/1-4 as text. Bindings never fire. CE does this too.
    self:SilenceBox(box)
    self:StealKeys()
    self:SelectSet()
    self:CheckModifier()
    self:Show()
    PlaySound("igMainMenuOptionCheckBoxOn")
    self.settingFocus = nil
    U.Debug("focus " .. tostring(box:GetName() or "anon"))
end

function Keyboard:CLOSE()
    if self.closing then return end
    self.closing = true
    self:RestoreKeys()
    local box = self.Focus
    self.Focus = nil
    self.KEY.UP = false
    self.KEY.DOWN = false
    self.KEY.LEFT = false
    self.KEY.RIGHT = false
    self.DIR = 9
    if self.UpdateDictionary and self.Mime then
        self:UpdateDictionary()
    end
    self.lastSuggestWord = nil
    self:Hide()
    if box then
        self:RestoreBox(box)
        if box.ClearFocus then
            box:ClearFocus()
        end
        if box == ChatFrameEditBox and box:IsShown() then
            box:Hide()
        end
    end
    self:RestoreCursorPad()
    self.closing = nil
end

function Keyboard:LoadChrome()
    local TEX = "Interface\\AddOns\\ConsoleUIKeyboard\\Textures\\"
    -- Official Keyboard.xml: 160x160, Fill extends 64px, vertex 0.12 / 0.35.
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self:SetFrameStrata("TOOLTIP")
    self:SetWidth(240)
    self:SetHeight(240)
    self:EnableMouse(false)
    self:Hide()

    local fill = self:CreateTexture(nil, "BACKGROUND")
    fill:SetWidth(452)
    fill:SetHeight(452)
    fill:SetPoint("CENTER", self, "CENTER", 0, 0)
    fill:SetTexture(TEX .. "Donut.tga")
    fill:SetVertexColor(0.12, 0.12, 0.12)
    if fill.SetAlpha then
        fill:SetAlpha(0.75)
    end
    self.Fill = fill

    local edge = self:CreateTexture(nil, "BORDER")
    edge:SetWidth(456)
    edge:SetHeight(456)
    edge:SetPoint("CENTER", self, "CENTER", 0, 0)
    edge:SetTexture(TEX .. "Ring.tga")
    edge:SetVertexColor(1.00, 0.82, 0.18)
    if edge.SetAlpha then
        edge:SetAlpha(0.9)
    end
    self.Edge = edge

    local inner = self:CreateTexture(nil, "BORDER")
    inner:SetWidth(164)
    inner:SetHeight(164)
    inner:SetPoint("CENTER", self, "CENTER", 0, 0)
    inner:SetTexture(TEX .. "Inner.tga")
    inner:SetVertexColor(1.00, 0.82, 0.18)
    if inner.SetAlpha then
        inner:SetAlpha(0.9)
    end
    self.Inner = inner

    self.LayerText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.LayerText:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.LayerText:SetTextColor(0.45, 0.45, 0.45, 0.0)
    self.LayerText:SetText("")
end

function Keyboard:LoadFrame()
    if self.frameLoaded then return end
    self:LoadChrome()
    local i
    for i = 1, 8 do
        table.insert(self.Sets, self:CreateCharset(i))
    end
    local center = self:CreateCharset(9)
    center.isCenter = true
    table.insert(self.Sets, center)
    -- Y space, X erase, A enter, B cancel
    local commands = { "SPC", "DEL", "OK", "X" }
    local j
    for j = 1, 4 do
        center.Buttons[j].Set = { "{ck" .. j .. "}", "{ck" .. j .. "}", "{ck" .. j .. "}", "{ck" .. j .. "}" }
        center.Buttons[j].command = commands[j]
    end
    center.Update = function(this)
        -- Center always shows space / erase / enter / cancel.
        local b
        for b = 1, 4 do
            Keyboard:PaintButton(center.Buttons[b], "{ck" .. b .. "}")
        end
    end
    center:ClearAllPoints()
    center:SetPoint("CENTER", self, "CENTER", 0, 0)
    if center.xOff then
        center.xOff = 0
        center.yOff = 0
    end
    self.CenterSet = center
    self.Current = center
    self.frameLoaded = true
    if self.Complete then
        self.Complete:ClearAllPoints()
        self.Complete:SetPoint("LEFT", self, "RIGHT", 170, 0)
    end
    self:SelectSet()
    self:CheckModifier()
end

function Keyboard:OnUpdate(elapsed)
    if not elapsed or elapsed <= 0 then elapsed = 0.016 end
    local Radial = ConsoleUI and ConsoleUI.radial
    if Radial and Radial.TickColorTweens then
        Radial:TickColorTweens(elapsed)
    end
    if not self:IsShown() then return end
    self:EnsureStolen()
    self.Timer = self.Timer + elapsed
    if self.Timer < 0.1 then return end
    self.Timer = 0
    self:CheckModifier()
    if self.Focus then
        self:SilenceBox(self.Focus)
        if not self.Focus:IsVisible() then
            self:CLOSE()
            return
        end
        if self.Mime and self.Mime.Sync then
            self.Mime:Sync()
        end
        if self.GetSuggestions then
            self:GetSuggestions()
        end
    end
end

function Keyboard:OnHide()
    self.KEY.UP = false
    self.KEY.DOWN = false
    self.KEY.LEFT = false
    self.KEY.RIGHT = false
    if self.Focus then
        self:RestoreBox(self.Focus)
        if not self.closing then
            self.Focus = nil
        end
    end
    if self.stolen then
        self:RestoreKeys()
    end
    self:RepairKeys()
end

function Keyboard:OnEvent()
    if event == "ADDON_LOADED" and arg1 == "ConsoleUIKeyboard" then
        self:LoadSettings()
        self:LoadFrame()
        self:HookSaveBindings()
        if self.HookEditBoxes then
            self:HookEditBoxes()
        end
        self:RepairKeys()
        self:UnregisterEvent("ADDON_LOADED")
        U.Debug("loaded")
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:HookSaveBindings()
        if self.HookEditBoxes then
            self:HookEditBoxes()
        end
        self:ReleaseIdleChatBox()
        self:RepairKeys()
    elseif event == "PLAYER_LOGOUT" then
        self:RestoreKeys()
    end
end

function CONSOLEUIK_Pad(dir, pressed)
    local Keyboard = ConsoleUIKeyboard
    if not Keyboard or not Keyboard:IsShown() then return end
    Keyboard.KEY[dir] = pressed and true or false
    Keyboard:SelectSet()
    Keyboard:CheckModifier()
end

function CONSOLEUIK_Face(index, pressed)
    local Keyboard = ConsoleUIKeyboard
    if not Keyboard or not Keyboard:IsShown() or not pressed then return end
    Keyboard:INPUT(index)
end

function CONSOLEUIK_Accept(pressed)
    local Keyboard = ConsoleUIKeyboard
    if not Keyboard or not Keyboard:IsShown() or not pressed then return end
    if Keyboard.AUTOCOMPLETE then
        Keyboard:AUTOCOMPLETE()
    end
end

function CONSOLEUIK_Guess(delta, pressed)
    local Keyboard = ConsoleUIKeyboard
    if not Keyboard or not Keyboard:IsShown() or not pressed then return end
    if Keyboard.PickGuess then
        Keyboard:PickGuess(delta)
    end
end

function CONSOLEUIK_Close(pressed)
    local Keyboard = ConsoleUIKeyboard
    if not Keyboard or not Keyboard:IsShown() or not pressed then return end
    Keyboard:CLOSE()
end

Keyboard:RegisterEvent("ADDON_LOADED")
Keyboard:RegisterEvent("PLAYER_ENTERING_WORLD")
Keyboard:RegisterEvent("PLAYER_LOGOUT")
Keyboard:SetScript("OnEvent", function() Keyboard:OnEvent() end)
Keyboard:SetScript("OnUpdate", function() Keyboard:OnUpdate(arg1) end)
Keyboard:SetScript("OnHide", function() Keyboard:OnHide() end)
