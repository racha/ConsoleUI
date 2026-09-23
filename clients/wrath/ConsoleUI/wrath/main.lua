-- Wrath entry point. Never load the Vanilla main.lua or keybindings.lua here.
ConsoleUI = ConsoleUI or {}
ConsoleUIWrathDB = ConsoleUIWrathDB or {}

local startup = CreateFrame("Frame", "ConsoleUIWrathStartup", UIParent)
startup:RegisterEvent("PLAYER_LOGIN")
startup:SetScript("OnEvent", function(self, event)
    if event ~= "PLAYER_LOGIN" then return end
    self:UnregisterEvent("PLAYER_LOGIN")
    if ConsoleUI.wrathBar then ConsoleUI.wrathBar:Initialize() end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd12eConsoleUI|r 3.3.5a port preview: secure action-bar prototype loaded.")
end)
