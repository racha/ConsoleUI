local ns = ConsoleUIKeyboardNS
local Language = ns
local Keyboard = ConsoleUIKeyboard

local TEX = "Interface\\AddOns\\ConsoleUIKeyboard\\Textures\\"

local CMD_ICON = {
    ["{ck1}"] = TEX .. "IconSpace.tga",
    ["{ck2}"] = TEX .. "IconEraser.tga",
    ["{ck3}"] = "Interface\\Buttons\\UI-CheckBox-Check",
    ["{ck4}"] = "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
    ["X"] = "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
    ["DEL"] = TEX .. "IconEraser.tga",
    ["SPC"] = TEX .. "IconSpace.tga",
    ["OK"] = "Interface\\Buttons\\UI-CheckBox-Check",
}

local GOLD = { 1.00, 0.82, 0.18 }

local function LabelFor(value)
    if not value or value == "" then return "" end
    if Language.Markers and Language.Markers[value] then
        return Language.Markers[value]
    end
    if string.len(value) > 6 then
        return string.sub(value, 1, 6)
    end
    return value
end

local function ColorTex(tex, r, g, b, a)
    if not tex then return end
    -- 1.12 Texture:SetVertexColor is rgb; alpha is a separate call.
    tex:SetVertexColor(r, g, b)
    if tex.SetAlpha then
        tex:SetAlpha(a or 1)
    end
end

local function TweenTex(tex, r, g, b, a, hideAtZero)
    if not tex then return end
    local Radial = ConsoleUI and ConsoleUI.radial
    if Radial and Radial.TweenColor then
        Radial:TweenColor(tex, r, g, b, a, 0.16, hideAtZero)
        return
    end
    ColorTex(tex, r, g, b, a)
    if hideAtZero and (a or 0) <= 0.01 then
        if tex.Hide then tex:Hide() end
    elseif (a or 0) > 0.01 and tex.Show then
        tex:Show()
    end
end

local function PaintIdle(btn)
    if not btn then return end
    TweenTex(btn.Background, 0, 0, 0, 1)
    if btn.Text then
        btn.Text:SetTextColor(1, 1, 1, 1)
    end
    if btn.Ring then
        TweenTex(btn.Ring, GOLD[1], GOLD[2], GOLD[3], 0, true)
    end
end

local function PaintSection(btn)
    if not btn then return end
    TweenTex(btn.Background, 0, 0, 0, 1)
    if btn.Text then
        btn.Text:SetTextColor(1, 1, 1, 1)
    end
    TweenTex(btn.Ring, GOLD[1], GOLD[2], GOLD[3], 1)
end

function Keyboard:PaintButton(btn, value)
    if not btn then return end
    local icon = CMD_ICON[value]
    if icon and btn.Icon then
        btn.Icon:SetTexture(icon)
        btn.Icon:Show()
        if btn.Text then btn.Text:SetText("") end
        return
    end
    if btn.Icon then btn.Icon:Hide() end
    if btn.Text then
        btn.Text:SetText(LabelFor(value))
    end
end

local function CharSetEnter(self)
    local i
    for i = 1, table.getn(self.Buttons) do
        PaintSection(self.Buttons[i])
    end
end

local function CharSetLeave(self)
    local i
    for i = 1, table.getn(self.Buttons) do
        PaintIdle(self.Buttons[i])
    end
end

local function CharSetChar(self, index)
    self.Index = index
    Keyboard:PaintButton(self, self.Set and self.Set[index] or "")
end

local function CharClick(self)
    if self.Flash then
        self:Flash()
    end
    if Keyboard.DIR == 9 or self.command then
        local cmd = self.command
        if cmd == "SPC" then
            Keyboard:SPACE()
        elseif cmd == "DEL" then
            Keyboard:ERASE()
        elseif cmd == "X" then
            Keyboard:CLOSE()
        elseif cmd == "OK" then
            Keyboard:ENTER()
        end
        return
    end
    if Keyboard.Focus and self.Set and self.Index then
        Keyboard.Focus:Insert(self.Set[self.Index] or "")
    end
end

local function Flash(self)
    local parent = self:GetParent()
    if parent and parent.isCenter then
        TweenTex(self.Background, 0.22, 0.22, 0.22, 1)
        if self.Ring then
            TweenTex(self.Ring, GOLD[1], GOLD[2], GOLD[3], 1)
        end
    else
        TweenTex(self.Background, 1, 1, 1, 1)
        if self.Text then
            self.Text:SetTextColor(0, 0, 0, 1)
        end
        TweenTex(self.Ring, GOLD[1], GOLD[2], GOLD[3], 1)
    end
    self.flashLeft = 0.12
    self:SetScript("OnUpdate", function()
        this.flashLeft = this.flashLeft - arg1
        if this.flashLeft <= 0 then
            this:SetScript("OnUpdate", nil)
            local owner = this:GetParent()
            if owner and Keyboard.Current == owner then
                PaintSection(this)
            else
                PaintIdle(this)
            end
        end
    end)
end

function Keyboard:CreateCharset(i)
    local radius = 154
    -- +3px from 30: more air than now, less than the +5px mock.
    local inner = 33
    local charset = CreateFrame("Frame", "$parentSet" .. i, self)
    charset:SetWidth(140)
    charset:SetHeight(140)
    charset.Enter = CharSetEnter
    charset.Leave = CharSetLeave
    charset.Buttons = {}

    if i < 9 then
        local angle = (i + 1) * (360 / 8) * math.pi / 180
        local ptx = radius * math.cos(angle)
        local pty = radius * math.sin(angle)
        charset.xOff = -ptx
        charset.yOff = pty
        charset:SetPoint("CENTER", self, "CENTER", -ptx, pty)
    else
        charset.xOff = 0
        charset.yOff = 0
        charset:SetPoint("CENTER", self, "CENTER", 0, 0)
    end

    -- Face map: 1=Y top, 2=X left, 3=A bottom, 4=B right.
    local POS = {
        { 0, inner },
        { -inner, 0 },
        { 0, -inner },
        { inner, 0 },
    }
    -- Outer tip of each diamond: 1 top, 2 left, 3 bottom, 4 right.
    local OUTER = { "N", "W", "S", "E" }

    local char
    for char = 1, 4 do
        local btn = CreateFrame("Button", "$parentBtn" .. char, charset)
        btn:SetWidth(56)
        btn:SetHeight(56)
        btn:SetPoint("CENTER", charset, "CENTER", POS[char][1], POS[char][2])
        btn:EnableMouse(true)
        btn.Index = 2
        if ConsoleUIKeyboardLayout and ConsoleUIKeyboardLayout[i] then
            btn.Set = ConsoleUIKeyboardLayout[i][char]
        else
            btn.Set = { "", "", "", "" }
        end

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", btn, "TOPLEFT", -5, 5)
        bg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 5, -5)
        bg:SetTexture(TEX .. "Key" .. OUTER[char] .. ".tga")
        btn.Background = bg

        local ring = btn:CreateTexture(nil, "BORDER")
        ring:SetPoint("TOPLEFT", btn, "TOPLEFT", -6, 6)
        ring:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 6, -6)
        ring:SetTexture(TEX .. "KeyHi" .. OUTER[char] .. ".tga")
        btn.Ring = ring
        PaintIdle(btn)

        btn.Icon = btn:CreateTexture(nil, "ARTWORK")
        btn.Icon:SetWidth(24)
        btn.Icon:SetHeight(24)
        btn.Icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.Icon:Hide()

        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        btn.Text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.Text:SetJustifyH("CENTER")
        btn.Text:SetTextColor(1, 1, 1, 1)
        Keyboard:PaintButton(btn, btn.Set and btn.Set[2] or "")
        btn.SetChar = CharSetChar
        btn.Click = CharClick
        btn.Flash = Flash
        btn:SetScript("OnClick", function()
            CharClick(this)
        end)
        table.insert(charset.Buttons, btn)
    end

    charset:Leave()
    return charset
end

