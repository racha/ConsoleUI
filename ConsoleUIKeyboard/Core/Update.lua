local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Keyboard = ConsoleUIKeyboard

local NAMED_BOXES = {
    "ChatFrameEditBox",
    "SendMailNameEditBox",
    "SendMailSubjectEditBox",
    "SendMailBodyEditBox",
    "MacroFrameText",
    "MacroPopupEditBox",
    "StaticPopup1EditBox",
    "StaticPopup2EditBox",
    "StaticPopup3EditBox",
    "StaticPopup4EditBox",
    "AuctionNameEditBox",
    "BrowseName",
    "BrowseMinLevel",
    "BrowseMaxLevel",
    "TabardFrameCustomText",
    "PetRenameEditBox",
    "GuildInfoEditBox",
    "WhoFrameEditBox",
    "FriendsFrameBroadcastInput",
    "BagItemSearchBox",
}

local function IsOwn(box)
    if not box then return true end
    local name = box.GetName and box:GetName()
    if name and string.find(name, "ConsoleUIKeyboard") then
        return true
    end
    if name and string.find(name, "^ConsoleUIKField") then
        return true
    end
    local parent = box.GetParent and box:GetParent()
    while parent do
        if parent == Keyboard or parent == Keyboard.config then
            return true
        end
        parent = parent.GetParent and parent:GetParent()
    end
    return false
end

local function HookBox(box, force)
    if not box or IsOwn(box) then return end
    if not box.GetObjectType or box:GetObjectType() ~= "EditBox" then return end
    if box.cuikHooked and not force then return end
    box.cuikHooked = true

    local oldGain = box:GetScript("OnEditFocusGained")
    box:SetScript("OnEditFocusGained", function()
        if oldGain then oldGain() end
        if Keyboard:IsEnabled() then
            Keyboard:SetFocus(this)
        end
    end)

    local oldEscape = box:GetScript("OnEscapePressed")
    box:SetScript("OnEscapePressed", function()
        if Keyboard.Focus == this then
            Keyboard:CLOSE()
        end
        if oldEscape then oldEscape() end
    end)
end

function Keyboard:HookBox(box, force)
    HookBox(box, force)
end

function Keyboard:HookNamedBoxes()
    local i
    for i = 1, table.getn(NAMED_BOXES) do
        local box = getglobal(NAMED_BOXES[i])
        if box then
            HookBox(box)
        end
    end
end

local function FocusIfShown(box)
    if box and box.IsVisible and box:IsVisible() and Keyboard:IsEnabled() then
        HookBox(box, true)
        Keyboard:SetFocus(box)
    end
end

function Keyboard:HookStaticPopups()
    if self.staticPopupHooked or not StaticPopup_Show then return end
    self.staticPopupHooked = true
    local prev = StaticPopup_Show
    StaticPopup_Show = function(which, text_arg1, text_arg2, data)
        local frame = prev(which, text_arg1, text_arg2, data)
        local i
        for i = 1, 4 do
            FocusIfShown(getglobal("StaticPopup" .. i .. "EditBox"))
        end
        return frame
    end
end

function Keyboard:HookMacroPopup()
    local popup = getglobal("MacroPopupFrame")
    if popup and not popup.cuikShowHooked then
        popup.cuikShowHooked = true
        local oldShow = popup:GetScript("OnShow")
        popup:SetScript("OnShow", function()
            if oldShow then oldShow() end
            FocusIfShown(getglobal("MacroPopupEditBox"))
        end)
    end
    HookBox(getglobal("MacroPopupEditBox"))
    HookBox(getglobal("MacroFrameText"))
end

function Keyboard:HookEditBoxes()
    self:HookNamedBoxes()
    self:HookStaticPopups()
    self:HookMacroPopup()
    if not ChatFrameEditBox then return end
    if ChatFrameEditBox.cuikShowHooked then return end
    ChatFrameEditBox.cuikShowHooked = true

    local oldShow = ChatFrameEditBox:GetScript("OnShow")
    ChatFrameEditBox:SetScript("OnShow", function()
        if oldShow then oldShow() end
        if Keyboard:IsEnabled() then
            Keyboard:SetFocus(ChatFrameEditBox)
        end
    end)

    local oldHide = ChatFrameEditBox:GetScript("OnHide")
    ChatFrameEditBox:SetScript("OnHide", function()
        if oldHide then oldHide() end
        if Keyboard.Focus == ChatFrameEditBox then
            Keyboard:CLOSE()
        end
    end)
end

-- Late-created boxes (mail, macros, AH, /cui fields).
local scan = CreateFrame("Frame")
scan.elapsed = 0
scan:SetScript("OnUpdate", function()
    this.elapsed = this.elapsed + arg1
    if this.elapsed < 2 then return end
    this.elapsed = 0
    Keyboard:HookNamedBoxes()
    Keyboard:HookMacroPopup()
end)
