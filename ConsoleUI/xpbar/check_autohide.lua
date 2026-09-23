local path = arg and arg[0] or "xpbar/check_autohide.lua"
local dir = string.gsub(path, "[^/]+$", "")

ConsoleUI = { xpbar = {} }
UIParent = {}
FACTION_STANDING_INCREASED = "Reputation with %s increased by %d."

CreateFrame = function()
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
    }
end

dofile(dir .. "xpbar.lua")

local policy = ConsoleUI.xpbar
if policy:EventAction("XP", "PLAYER_XP_UPDATE") ~= "show" then
    error("player XP changes must show the XP bar")
end
if policy:EventAction("XP", "UPDATE_EXHAUSTION") ~= "refresh" then
    error("rested XP changes must only refresh the XP bar")
end
if policy:EventAction("XP", "UNIT_PET") ~= nil or policy:EventAction("XP", "UNIT_PET_EXPERIENCE") ~= nil then
    error("pet events must not affect the player XP bar")
end
if policy:EventAction("XP", "UNIT_LEVEL", "pet") ~= nil or policy:EventAction("XP", "UNIT_LEVEL", "player") ~= "show" then
    error("UNIT_LEVEL must be restricted to the player")
end
if policy:EventAction("PETXP", "UNIT_PET_EXPERIENCE") ~= "show" then
    error("pet XP changes must show a Pet XP bar")
end
if policy:EventAction("REP", "UPDATE_FACTION") ~= "refresh" then
    error("faction-list updates must only refresh the reputation bar")
end

local function Bar(shown, alpha, tick, always)
    return {
        shown = shown,
        alpha = alpha,
        tick = tick,
        always = always,
        IsShown = function(self) return self.shown end,
        GetAlpha = function(self) return self.alpha end,
        SetAlpha = function(self, value) self.alpha = value end,
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
    }
end

local xp = Bar(false, 0, 123, false)
local rep = Bar(true, 0.4, 456, false)
ConsoleUI.xpbar.xpBar = xp
ConsoleUI.xpbar.repBar = rep

ConsoleUI.xpbar.Fire = function(_, bar)
    bar:SetAlpha(1)
    bar:Show()
    bar.tick = 999
end

ConsoleUI.xpbar:RefreshFills()

if xp:IsShown() or xp:GetAlpha() ~= 0 or xp.tick ~= 123 then
    error("synthetic refresh revived hidden XP bar")
end
if not rep:IsShown() or rep:GetAlpha() ~= 0.4 or rep.tick ~= 456 then
    error("synthetic refresh reset fading Reputation bar")
end

xp.always = true
ConsoleUI.xpbar:RefreshFills()
if not xp:IsShown() or xp:GetAlpha() ~= 1 or xp.tick ~= 999 then
    error("always-visible XP bar did not accept refresh state")
end

print("XP/Rep auto-hide check OK")
