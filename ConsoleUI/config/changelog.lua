--[[
    Changelog. Shows once when the addon version changes.
    Add a newest-first block to ConsoleUI.CHANGELOG when you ship.
    First install uses Welcome only; this window is for upgrades.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.changelog = ConsoleUI.changelog or {}
local CL = ConsoleUI.changelog

-- Newest first. version must match the TOC Version string.
ConsoleUI.CHANGELOG = {
    {
        version = "1.0.0-RC3.1",
        lines = {
            "Esc menu no longer errors with Turtle Shop / Donation Rewards.",
        },
    },
    {
        version = "1.0.0-RC3",
        lines = {
            "Welcome screen on first login.",
            "What's new after each update.",
            "Bindings rework: 1-0, M, and Escape stay yours. Only LT/LB chords are written.",
            "Login no longer wipes keybinds. Camera and Jump stay put.",
            "HUD border tint on diamonds, XP, and cast.",
            "XP, reputation, and cast bars restyled.",
            "Main bar scale no longer changes side touch bars.",
            "Jump and other system binds no longer stick white after LT or LB.",
            "Bag drop (Y) asks Yes/No before destroying an item.",
            "Esc menu no longer overlaps Shagu Tweaks Advanced Options.",
            "D-pad casts work with Shagu Tweaks without opening chat first.",
        },
    },
    {
        version = "1.0.0-RC2",
        lines = {
            "Spell Placement matches settings chrome.",
            "Touch bars cap at 5 slots.",
        },
    },
}

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local function C()
    return ConsoleUI.config
end

local function Count(t)
    local n = 0
    while t[n + 1] ~= nil do
        n = n + 1
    end
    return n
end

function CL.CurrentVersion()
    if GetAddOnMetadata then
        return GetAddOnMetadata("ConsoleUI", "Version") or "1.0.0-RC3.1"
    end
    return "1.0.0-RC3.1"
end

function CL.EntriesSince(last, all)
    local src = ConsoleUI.CHANGELOG
    local out = {}
    local i
    for i = 1, Count(src) do
        local e = src[i]
        if not all and last and e.version == last then
            break
        end
        out[Count(out) + 1] = e
    end
    return out
end

function CL:SeenVersion()
    local cfg = C()
    if cfg and cfg.Get then
        return cfg:Get("changelogSeenVersion")
    end
    if ConsoleUIDB and ConsoleUIDB.config then
        return ConsoleUIDB.config.changelogSeenVersion
    end
    return nil
end

function CL:StampSeen()
    local v = self.CurrentVersion()
    local cfg = C()
    if cfg and cfg.Set then
        cfg:Set("changelogSeenVersion", v)
        return
    end
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.config then
        ConsoleUIDB.config = {}
    end
    ConsoleUIDB.config.changelogSeenVersion = v
end

function CL:StampIfEmpty()
    if not self:SeenVersion() then
        self:StampSeen()
    end
end

function CL:NeedsShow()
    local last = self:SeenVersion()
    if last == self.CurrentVersion() then
        return false
    end
    return Count(self.EntriesSince(last)) > 0
end

function CL:MaybeShow()
    if ConsoleUI.onboarding and ConsoleUI.onboarding.HasSeen then
        if not ConsoleUI.onboarding:HasSeen() then
            return
        end
    end
    if ConsoleUI.onboarding and ConsoleUI.onboarding.frame and ConsoleUI.onboarding.frame:IsShown() then
        return
    end
    if not self:NeedsShow() or self.pending then
        return
    end
    self.pending = true
    local wait = CreateFrame("Frame")
    local t = 0
    wait:SetScript("OnUpdate", function()
        t = t + arg1
        if t < 0.4 then
            return
        end
        this:Hide()
        CL.pending = false
        if CL:NeedsShow() then
            CL:Show(false)
        end
    end)
    wait:Show()
end

function CL:HideFrame()
    if self.frame then
        self.frame:Hide()
    end
end

function CL:Show(all)
    if not self.frame then
        self:Create()
    end
    local cfg = C()
    if cfg and cfg.frame and cfg.frame:IsShown() then
        cfg:Hide()
    end
    if ConsoleUI.onboarding and ConsoleUI.onboarding.frame and ConsoleUI.onboarding.frame:IsShown() then
        ConsoleUI.onboarding:HideWelcome()
    end
    self.showAll = all and true or false
    self:Fill(self.showAll)
    self.frame:Show()
    if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
        ConsoleUI.hooks:HookDynamicFrame(self.frame, "ConsoleUI Changelog")
    end
    if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
        local delay = CreateFrame("Frame")
        delay:SetScript("OnUpdate", function()
            this:Hide()
            if ConsoleUI.cursor and ConsoleUI.cursor.RefreshFrame then
                ConsoleUI.cursor:RefreshFrame()
            end
        end)
        delay:Show()
    end
end

function CL:Fill(all)
    if not self.scrollChild then
        return
    end
    if self.bits then
        local i
        for i = 1, Count(self.bits) do
            self.bits[i]:Hide()
        end
    end
    self.bits = self.bits or {}
    local last = all and nil or self:SeenVersion()
    local entries = self.EntriesSince(last, all)
    local y = -6
    local used = 0
    local function take()
        used = used + 1
        if not self.bits[used] then
            self.bits[used] = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            self.bits[used]:SetJustifyH("LEFT")
            self.bits[used]:SetWidth(408)
        end
        return self.bits[used]
    end
    local i
    if Count(entries) == 0 then
        local empty = take()
        empty:ClearAllPoints()
        empty:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 4, y)
        empty:SetText(T("No notes for this version yet."))
        empty:SetTextColor(0.545, 0.561, 0.596)
        empty:Show()
        y = y - 20
    end
    for i = 1, Count(entries) do
        local e = entries[i]
        local head = take()
        head:ClearAllPoints()
        head:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 4, y)
        head:SetFontObject(GameFontNormal)
        head:SetText(e.version)
        head:SetTextColor(1.00, 0.82, 0.18)
        head:Show()
        y = y - 18
        local n
        for n = 1, Count(e.lines) do
            local line = take()
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 4, y)
            line:SetFontObject(GameFontHighlight)
            line:SetText("• " .. e.lines[n])
            line:SetTextColor(0.78, 0.79, 0.81)
            line:Show()
            y = y - 16
        end
        y = y - 8
    end
    local h = -y + 8
    if h < 160 then
        h = 160
    end
    self.scrollChild:SetHeight(h)
    if self.scroll and self.scroll.SetVerticalScroll then
        self.scroll:SetVerticalScroll(0)
    end
end

function CL:Create()
    if self.frame then
        return self.frame
    end
    local cfg = C()
    local frame = CreateFrame("Frame", "ConsoleUIChangelogFrame", UIParent)
    frame:SetWidth(480)
    frame:SetHeight(380)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(120)
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:Hide()
    frame:SetBackdrop(cfg.BACKDROP_PANEL)
    frame:SetBackdropColor(unpack(cfg.UI_COLORS.panel))
    frame:SetBackdropBorderColor(unpack(cfg.UI_COLORS.borderStrong))
    self.frame = frame

    local headerFill = cfg:Paint(frame, "BORDER", 0.082, 0.086, 0.106, 0.98)
    headerFill:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    headerFill:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    headerFill:SetHeight(48)

    local mark = frame:CreateTexture(nil, "ARTWORK")
    mark:SetTexture(cfg.MARK)
    mark:SetWidth(34)
    mark:SetHeight(34)
    mark:SetPoint("LEFT", headerFill, "LEFT", 12, 0)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", mark, "RIGHT", 10, 0)
    title:SetText(T("What's new"))
    title:SetTextColor(unpack(cfg.UI_COLORS.text))

    local pill = CreateFrame("Frame", nil, frame)
    pill:SetWidth(118)
    pill:SetHeight(22)
    pill:SetPoint("RIGHT", headerFill, "RIGHT", -12, 0)
    pill:SetBackdrop(cfg.BACKDROP_CARD)
    pill:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
    pill:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
    local pillText = pill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pillText:SetPoint("CENTER", pill, "CENTER", 0, 0)
    pillText:SetText(T("Version") .. " " .. self.CurrentVersion())
    pillText:SetTextColor(unpack(cfg.UI_COLORS.gold))

    local host = CreateFrame("Frame", nil, frame)
    host:SetPoint("TOPLEFT", headerFill, "BOTTOMLEFT", 10, -8)
    host:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 58)
    host:SetBackdrop(cfg.BACKDROP_FLAT)
    host:SetBackdropColor(unpack(cfg.UI_COLORS.content))

    local scroll = CreateFrame("ScrollFrame", "ConsoleUIChangelogScroll", host)
    scroll:SetPoint("TOPLEFT", host, "TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -8, 8)
    scroll:EnableMouseWheel(1)
    scroll:SetScript("OnMouseWheel", function()
        local cur = this:GetVerticalScroll()
        local range = this:GetVerticalScrollRange() or 0
        local next = cur - (arg1 * 30)
        if next < 0 then next = 0 end
        if next > range then next = range end
        this:SetVerticalScroll(next)
    end)
    local child = CreateFrame("Frame", "ConsoleUIChangelogChild", scroll)
    child:SetWidth(416)
    child:SetHeight(160)
    scroll:SetScrollChild(child)
    self.scroll = scroll
    self.scrollChild = child

    local hideBtn = cfg:MakePanelButton(frame, "ConsoleUIChangelogHide", 140, T("HIDE"), "ghost")
    hideBtn:SetHeight(36)
    hideBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
    hideBtn:SetScript("OnClick", function()
        PlaySound("gsTitleOptionExit")
        CL:HideFrame()
    end)

    frame:SetScript("OnHide", function()
        CL:StampSeen()
    end)

    if UISpecialFrames then
        table.insert(UISpecialFrames, "ConsoleUIChangelogFrame")
    end
    return frame
end

if not CreateFrame then
    local function Fail(ok, name, detail)
        if not ok then
            print("Changelog check FAIL: " .. name .. " " .. tostring(detail))
            return false
        end
        return true
    end
    local ok = true
    ConsoleUI.CHANGELOG = {
        { version = "2.0", lines = { "b" } },
        { version = "1.0", lines = { "a" } },
    }
    local all = CL.EntriesSince(nil)
    if not Fail(Count(all) == 2, "all", Count(all)) then ok = false end
    local mid = CL.EntriesSince("1.0")
    if not Fail(Count(mid) == 1 and mid[1].version == "2.0", "since 1.0", Count(mid)) then ok = false end
    local none = CL.EntriesSince("2.0")
    if not Fail(Count(none) == 0, "current", Count(none)) then ok = false end
    if ok then
        print("Changelog check OK")
    end
end
