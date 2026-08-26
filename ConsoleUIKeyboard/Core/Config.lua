local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Language = ns
local Keyboard = ConsoleUIKeyboard

function Keyboard:ApplyLanguage(name)
    if not Language[name] then return end
    ConsoleUIKeyboardLayout = U.CopyLayout(Language[name])
    ConsoleUIKeyboardDB = ConsoleUIKeyboardDB or {}
    ConsoleUIKeyboardDB.layoutVersion = Language.LayoutVersion or 2
    self:SetLayout()
    if ConsoleUI and ConsoleUI.profiles and ConsoleUI.profiles.MarkDirty then
        ConsoleUI.profiles:MarkDirty(false)
    end
    U.Print("layout " .. name)
end

SLASH_CONSOLEUIK1 = "/cuik"
SLASH_CONSOLEUIK2 = "/consoleuikeyboard"
SlashCmdList["CONSOLEUIK"] = function(msg)
    msg = string.lower(U.trim(msg or ""))
    local Keyboard = ConsoleUIKeyboard
    if msg == "on" then
        ConsoleUIKeyboardDB = ConsoleUIKeyboardDB or {}
        ConsoleUIKeyboardDB.disabled = nil
        Keyboard:SetEnabled(true)
        U.Print("enabled")
    elseif msg == "off" then
        ConsoleUIKeyboardDB = ConsoleUIKeyboardDB or {}
        ConsoleUIKeyboardDB.disabled = true
        Keyboard:SetEnabled(false)
        U.Print("disabled")
    elseif msg == "check" or msg == "debug" then
        if Keyboard.RunSelfCheck then
            Keyboard:RunSelfCheck(true)
        end
    else
        U.Print("/cuik on|off|check")
    end
end
