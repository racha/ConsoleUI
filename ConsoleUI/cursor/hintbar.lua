--[[
    Persistent A/B/X/Y strip. Same prompts as tooltip.lua. Existing glyphs.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.cursor = ConsoleUI.cursor or {}
ConsoleUI.cursor.hintbar = ConsoleUI.cursor.hintbar or {}
local HintBar = ConsoleUI.cursor.hintbar

HintBar.WASH = "Interface\\AddOns\\ConsoleUI\\textures\\hud\\WashPanel"
HintBar.WASH_PAD_X = 72
HintBar.WASH_PAD_Y = 16
HintBar.WASH_SCALE = 1.1
HintBar.WASH_A = 0.70
HintBar.WASH_DEEP_A = 0.10

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local function Cfg()
    return ConsoleUI.config
end

local function PaintTex(tex, r, g, b, a)
    if not tex then
        return
    end
    tex:SetVertexColor(r, g, b)
    if a ~= nil then
        tex:SetAlpha(a)
    end
end

function HintBar:Enabled()
    local cfg = Cfg()
    if cfg and cfg.Get then
        return cfg:Get("hintBarEnabled") ~= false
    end
    return true
end

function HintBar:Position()
    local cfg = Cfg()
    local pos = cfg and cfg.Get and cfg:Get("hintBarPosition")
    if pos == "bottom" then
        return "bottom"
    end
    return "top"
end

function HintBar:UserScale()
    local cfg = Cfg()
    local s = 1.0
    if cfg and cfg.Get then
        s = tonumber(cfg:Get("hintBarScale")) or 1.0
    end
    if s < 0.5 then
        s = 0.5
    end
    if s > 2.0 then
        s = 2.0
    end
    return s
end

function HintBar:ApplyScale()
    local f = self.frame
    if f and f.SetScale then
        f:SetScale(self:UserScale())
    end
end

function HintBar:OverlayBusy()
    if ConsoleUI.loot and ConsoleUI.loot.Busy and ConsoleUI.loot:Busy() then
        return true
    end
    if ConsoleUI.unit and ConsoleUI.unit.Busy and ConsoleUI.unit:Busy() then
        return true
    end
    if ConsoleUI.radial and ConsoleUI.radial.IsOpen and ConsoleUI.radial:IsOpen() then
        return true
    end
    if ConsoleUI.rings and ConsoleUI.rings.IsVisible and ConsoleUI.rings:IsVisible() then
        return true
    end
    if ConsoleUIKeyboard and ConsoleUIKeyboard.IsShown and ConsoleUIKeyboard:IsShown() then
        return true
    end
    return false
end

function HintBar:Previewing()
    local cfg = Cfg()
    if not cfg or not cfg.frame or not cfg.frame.IsShown or not cfg.frame:IsShown() then
        return false
    end
    return cfg.currentSection == "hud"
end

function HintBar:Ensure()
    if self.frame then
        return self.frame
    end
    local f = CreateFrame("Frame", "ConsoleUIHintBar", UIParent)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(40)
    f:SetWidth(280)
    f:SetHeight(28)
    f:EnableMouse(false)
    f:Hide()
    f.hintX = 0
    f.hintY = 0
    f.hintPoint = "LEFT"
    f.hintRelPoint = "LEFT"
    if ConsoleUI.hints and ConsoleUI.hints.Attach then
        ConsoleUI.hints:Attach(f)
    end
    local wash = f:CreateTexture(nil, "BACKGROUND")
    wash:SetTexture(self.WASH)
    f.wash = wash
    local deep = f:CreateTexture(nil, "BACKGROUND")
    deep:SetTexture(self.WASH)
    f.washDeep = deep
    self.frame = f
    self:FitWash()
    return f
end

function HintBar:PinWash(tex, w, h, a)
    local f = self.frame
    if not tex or not f then
        return
    end
    tex:ClearAllPoints()
    tex:SetWidth(w)
    tex:SetHeight(h)
    tex:SetPoint("CENTER", f, "CENTER", 0, 0)
    PaintTex(tex, 0, 0, 0, a)
end

function HintBar:FitWash()
    local f = self.frame
    if not f or not f.wash then
        return
    end
    local w = ((f:GetWidth() or 280) + self.WASH_PAD_X) * self.WASH_SCALE
    local h = ((f:GetHeight() or 28) + self.WASH_PAD_Y) * self.WASH_SCALE
    self:PinWash(f.wash, w, h, self.WASH_A)
    self:PinWash(f.washDeep, w, h, self.WASH_DEEP_A)
end

function HintBar:UpdatePosition()
    local f = self:Ensure()
    local cfg = Cfg()
    local x = 0
    local y = 0
    if cfg and cfg.HudOffset then
        x = cfg:HudOffset("hintBarOffsetX", 0)
        y = cfg:HudOffset("hintBarOffsetY", 0)
    end
    f:ClearAllPoints()
    if self:Position() == "top" then
        f:SetPoint("TOP", UIParent, "TOP", x, -16 + y)
    else
        f:SetPoint("BOTTOM", UIParent, "BOTTOM", x, 16 + y)
    end
end

function HintBar:SamplePrompts()
    return {
        { icon = "a", prompt = T("Select") },
        { icon = "b", prompt = T("Close") },
    }
end

function HintBar:Refresh()
    local f = self:Ensure()
    self:ApplyScale()
    self:UpdatePosition()
    if not self:Enabled() then
        f:Hide()
        return
    end
    if self:OverlayBusy() then
        f:Hide()
        return
    end
    local prompts = nil
    local cursor = ConsoleUI.cursor
    local on = cursor and cursor.keybindings and cursor.keybindings.IsCursorModeActive
        and cursor.keybindings:IsCursorModeActive()
    local button = cursor and cursor.navigationState and cursor.navigationState.currentButton
    if on and button and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ActionsForButton then
        prompts = ConsoleUI.cursor.tooltip:ActionsForButton(button)
    elseif self:Previewing() then
        prompts = self:SamplePrompts()
    end
    if not prompts or table.getn(prompts) == 0 then
        f:Hide()
        return
    end
    local w = 80
    if ConsoleUI.hints and ConsoleUI.hints.Paint then
        w = ConsoleUI.hints:Paint(f, prompts)
    end
    if w < 80 then
        w = 80
    end
    f:SetWidth(w)
    f:SetHeight((ConsoleUI.hints and ConsoleUI.hints.Size and ConsoleUI.hints:Size()) or 22)
    self:FitWash()
    f:Show()
end

function HintBar:Hide()
    if self.frame then
        self.frame:Hide()
    end
end
