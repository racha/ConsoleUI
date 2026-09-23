local path = arg and arg[0] or "config/check_mouse.lua"
local dir = string.gsub(path, "[^/]+$", "")

local function Read(file)
    local handle = assert(io.open(file, "r"))
    local source = handle:read("*a")
    handle:close()
    return source
end

local config = Read(dir .. "config.lua")
local mouse = Read(dir .. "mouse.lua")
local init = Read(dir .. "../init/config.xml")
local look = Read(dir .. "../cursor/mouselook.lua")
local keys = Read(dir .. "../keybindings.lua")
local bindings = Read(dir .. "../Bindings.xml")
local proxied = Read(dir .. "proxied.lua")

local required = {
    "mouseLookEnabled = true",
    "mouseLookUnlockRightClick = true",
    "mouseLookUnlockModifierDoubleTap = false",
    "mouseLookUnlockGameMenu = false",
    "mouseLookUnlockBags = false",
    "mouseLookUnlockWorldMap = false",
    "mouseLookUnlockCharacter = false",
    "mouseLookUnlockSpellbook = false",
    "mouseLookUnlockTalents = false",
    "mouseLookUnlockQuests = false",
    "mouseLookUnlockSocial = false",
    "mouseLookUnlockCommerce = false",
    "mouseLookUnlockProfessions = false",
    "mouseLookUnlockOtherWindows = false",
}
local i
for i = 1, 14 do
    if not string.find(config, required[i], 1, true) then
        error("missing Mouse setting default: " .. required[i])
    end
end

if not string.find(config, '{ id = "mouse", name = "Mouse" }', 1, true) then
    error("Mouse settings navigation section missing")
end
if not string.find(init, 'config\\mouse.lua', 1, true) then
    error("Mouse settings file is not loaded")
end
if not string.find(mouse, "Lock Mouse On", 1, true)
    or not string.find(mouse, "Unlock Mouse On", 1, true)
    or not string.find(mouse, "touch bars cannot be used", 1, true) then
    error("Mouse settings groups or touch warning missing")
end
if string.find(look, "RunBinding", 1, true) then
    error("Mouse Look must not replay protected bindings")
end
if not string.find(keys, 'SetBinding("F9", "ConsoleUI_MOUSELOOK_START")', 1, true)
    or not string.find(keys, "self:ClaimMouseLookMapperKey()", 1, true) then
    error("F9 Mouse Look Start auto-binding missing")
end
local exposed = {
    'name="ConsoleUI_MOUSELOCK"',
    'name="ConsoleUI_MOUSELOCK_HOLD" runOnUp="true"',
    'name="ConsoleUI_MOUSEUNLOCK"',
    'name="ConsoleUI_MOUSEUNLOCK_HOLD" runOnUp="true"',
    'name="ConsoleUI_MOUSELOOK"',
}
for i = 1, #exposed do
    if not string.find(bindings, exposed[i], 1, true) then
        error("missing exposed Mouse binding: " .. exposed[i])
    end
end
if not string.find(bindings, 'name="ConsoleUI_MOUSELOOK_START" hidden="true"', 1, true) then
    error("F9 mapper binding must remain internal")
end
local assignable = {
    'id = "ConsoleUI_MOUSELOCK"',
    'id = "ConsoleUI_MOUSEUNLOCK"',
    'id = "ConsoleUI_MOUSELOOK"',
}
for i = 1, #assignable do
    if not string.find(proxied, assignable[i], 1, true) then
        error("Mouse action missing from ConsoleUI Bindings: " .. assignable[i])
    end
end
if string.find(proxied, 'id = "ConsoleUI_MOUSELOCK_HOLD"', 1, true)
    or string.find(proxied, 'id = "ConsoleUI_MOUSEUNLOCK_HOLD"', 1, true) then
    error("Hold Mouse actions must not appear in ConsoleUI Bindings")
end

print("Mouse settings check OK")
