--[[
    First-run welcome. Two buttons: Hide, Configure.
    Close marks seen; never auto-shows again. About → Show Welcome brings it back.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.onboarding = ConsoleUI.onboarding or {}
local OB = ConsoleUI.onboarding

local function T(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

local function C()
    return ConsoleUI.config
end

function OB:HasSeen()
    local cfg = C()
    if cfg and cfg.Get then
        return cfg:Get("onboardingSeen") == true
    end
    return ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.onboardingSeen == true
end

function OB:MarkSeen()
    local cfg = C()
    if cfg and cfg.Set then
        cfg:Set("onboardingSeen", true)
        return
    end
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.config then
        ConsoleUIDB.config = {}
    end
    ConsoleUIDB.config.onboardingSeen = true
end

function OB:MaybeShowFirstRun()
    if self:HasSeen() or self.pending then
        return
    end
    self.pending = true
    local wait = CreateFrame("Frame")
    local t = 0
    wait:SetScript("OnUpdate", function()
        t = t + arg1
        if t < 0.35 then
            return
        end
        this:Hide()
        OB.pending = false
        if not OB:HasSeen() then
            OB:Show()
        end
    end)
    wait:Show()
end

function OB:HideWelcome()
    if self.frame then
        self.frame:Hide()
    end
end

function OB:OpenConfig()
    self:HideWelcome()
    local cfg = C()
    if cfg and cfg.Show then
        cfg:Show()
    end
end

function OB:Show()
    if not self.frame then
        self:Create()
    end
    local cfg = C()
    if cfg and cfg.frame and cfg.frame:IsShown() then
        cfg:Hide()
    end
    self.frame:Show()
    if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
        ConsoleUI.hooks:HookDynamicFrame(self.frame, "ConsoleUI Onboarding")
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

function OB:Create()
    if self.frame then
        return self.frame
    end
    local cfg = C()
    local frame = CreateFrame("Frame", "ConsoleUIOnboardFrame", UIParent)
    frame:SetWidth(480)
    frame:SetHeight(320)
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
    title:SetText(T("Welcome to Console"))
    title:SetTextColor(unpack(cfg.UI_COLORS.text))
    local brand = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    brand:SetPoint("LEFT", title, "RIGHT", 0, 0)
    brand:SetText("UI")
    brand:SetTextColor(unpack(cfg.UI_COLORS.gold))

    local version = GetAddOnMetadata and GetAddOnMetadata("ConsoleUI", "Version") or "1.0.0-RC3.1"
    local pill = CreateFrame("Frame", nil, frame)
    pill:SetWidth(118)
    pill:SetHeight(22)
    pill:SetPoint("RIGHT", headerFill, "RIGHT", -12, 0)
    pill:SetBackdrop(cfg.BACKDROP_CARD)
    pill:SetBackdropColor(0.145, 0.122, 0.055, 0.96)
    pill:SetBackdropBorderColor(1.00, 0.82, 0.18, 0.28)
    local pillText = pill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pillText:SetPoint("CENTER", pill, "CENTER", 0, 0)
    pillText:SetText(T("Version") .. " " .. version)
    pillText:SetTextColor(unpack(cfg.UI_COLORS.gold))

    local by = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    by:SetPoint("TOPLEFT", headerFill, "BOTTOMLEFT", 16, -12)
    by:SetText("by HouseLegend")
    by:SetTextColor(unpack(cfg.UI_COLORS.muted))

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", by, "BOTTOMLEFT", 0, -10)
    body:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    body:SetJustifyH("LEFT")
    body:SetText(T("Face buttons are your action bar. Left stick walks. Right stick is the mouse.") .. " " .. T("Vanilla has no gamepad. Steam Input or WoWpadX sends keys. Layout, touch bars, and Quick Menu are in /cui."))
    body:SetTextColor(0.78, 0.79, 0.81)

    local link = CreateFrame("Button", "ConsoleUIOnboardGithub", frame)
    link:SetHeight(36)
    link:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 60)
    link:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 60)
    link:SetBackdrop(cfg.BACKDROP_CARD)
    link:SetBackdropColor(unpack(cfg.UI_COLORS.inset))
    link:SetBackdropBorderColor(unpack(cfg.UI_COLORS.border))
    local linkLabel = link:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    linkLabel:SetPoint("LEFT", link, "LEFT", 12, 0)
    linkLabel:SetText("GitHub")
    link.label = linkLabel
    local linkUrl = link:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    linkUrl:SetPoint("RIGHT", link, "RIGHT", -12, 0)
    linkUrl:SetText("github.com/racha/ConsoleUI")
    linkUrl:SetTextColor(unpack(cfg.UI_COLORS.gold))
    link.tooltipText = T("Copy the GitHub address to chat.")
    link:SetScript("OnClick", function()
        local url = "https://github.com/racha/ConsoleUI"
        if ChatFrameEditBox then
            ChatFrameEditBox:Show()
            ChatFrameEditBox:SetText(url)
            ChatFrameEditBox:HighlightText()
            ChatFrameEditBox:SetFocus()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd12eConsoleUI|r " .. url)
    end)

    local hideBtn = cfg:MakePanelButton(frame, "ConsoleUIOnboardHide", 140, T("HIDE"), "ghost")
    hideBtn:SetHeight(36)
    hideBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    hideBtn:SetScript("OnClick", function()
        PlaySound("gsTitleOptionExit")
        OB:HideWelcome()
    end)

    local configBtn = cfg:MakePanelButton(frame, "ConsoleUIOnboardConfigure", 140, T("CONFIGURE"), "primary")
    configBtn:SetHeight(36)
    configBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    configBtn:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        OB:OpenConfig()
    end)

    frame:SetScript("OnHide", function()
        OB:MarkSeen()
        if ConsoleUI.changelog and ConsoleUI.changelog.StampIfEmpty then
            ConsoleUI.changelog:StampIfEmpty()
        end
    end)

    if UISpecialFrames then
        table.insert(UISpecialFrames, "ConsoleUIOnboardFrame")
    end
    return frame
end
