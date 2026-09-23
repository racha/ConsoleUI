local path = arg and arg[0] or "cursor/check_mouselook.lua"
local dir = string.gsub(path, "[^/]+$", "")

local configValues = {
    mouseLookEnabled = true,
    mouseLookLockOnMovement = true,
    mouseLookLockOnActions = true,
    mouseLookUnlockRightClick = true,
    mouseLookUnlockModifierDoubleTap = false,
    mouseLookUnlockGameMenu = false,
    mouseLookUnlockBags = false,
    mouseLookUnlockWorldMap = false,
    mouseLookUnlockCharacter = false,
}
ConsoleUI = {
    config = {
        Get = function(_, key)
            return configValues[key]
        end,
    },
}
local started = 0
local stopped = 0
local worldScripts = {}
local gameMenuScripts = {}
local worldMapScripts = {}
local bagScripts = {}
local modifierScripts = {}
local oldDownCalls = 0
local oldShowCalls = 0
local oldMapShowCalls = 0
local oldBagShowCalls = 0
local shiftDown = false
local controlDown = false
local clock = 0
local cvars = {
    mouseInvertYaw = "0",
    mouseInvertPitch = "0",
    mouseSpeed = "1.00",
}
worldScripts.OnMouseDown = function()
    oldDownCalls = oldDownCalls + 1
end
WorldFrame = {
    GetScript = function(_, name)
        return worldScripts[name]
    end,
    SetScript = function(_, name, script)
        worldScripts[name] = script
    end,
}
gameMenuScripts.OnShow = function()
    oldShowCalls = oldShowCalls + 1
end
GameMenuFrame = {
    GetScript = function(_, name)
        return gameMenuScripts[name]
    end,
    SetScript = function(_, name, script)
        gameMenuScripts[name] = script
    end,
}
worldMapScripts.OnShow = function()
    oldMapShowCalls = oldMapShowCalls + 1
end
WorldMapFrame = {
    GetScript = function(_, name)
        return worldMapScripts[name]
    end,
    SetScript = function(_, name, script)
        worldMapScripts[name] = script
    end,
}
bagScripts.OnShow = function()
    oldBagShowCalls = oldBagShowCalls + 1
end
ContainerFrame1 = {
    GetScript = function(_, name)
        return bagScripts[name]
    end,
    SetScript = function(_, name, script)
        bagScripts[name] = script
    end,
}
getglobal = function(name)
    return _G[name]
end
CreateFrame = function()
    return {
        SetScript = function(_, name, script)
            modifierScripts[name] = script
        end,
    }
end
IsShiftKeyDown = function()
    return shiftDown
end
IsControlKeyDown = function()
    return controlDown
end
GetTime = function()
    return clock
end
GetCVar = function(name)
    return cvars[name]
end
SetCVar = function(name, value)
    cvars[name] = value
end
MouselookStart = function()
    started = started + 1
end

MouselookStop = function()
    stopped = stopped + 1
end

dofile(dir .. "mouselook.lua")

if ConsoleUI.mouselook:IsActive() then
    error("manual look started during module load")
end
if started ~= 0 or stopped ~= 0 then
    error("client API called during module load")
end
if modifierScripts.OnUpdate then
    error("modifier watcher started during module load")
end
ConsoleUI_MouseLook()
if started ~= 1 or stopped ~= 0 or not ConsoleUI.mouselook:IsActive() then
    error("manual start failed")
end
if type(worldScripts.OnMouseDown) ~= "function" then
    error("right-click watcher not installed after manual start")
end
if type(gameMenuScripts.OnShow) ~= "function" then
    error("Escape menu watcher not installed after manual start")
end
if type(worldMapScripts.OnShow) ~= "function" then
    error("World Map watcher not installed after manual start")
end
if type(bagScripts.OnShow) ~= "function" then
    error("bag watcher not installed after manual start")
end
if modifierScripts.OnUpdate then
    error("disabled modifier watcher installed after manual start")
end
ConsoleUI.mouselook:OnFrameShown("CharacterFrame")
if stopped ~= 0 or not ConsoleUI.mouselook:IsActive() then
    error("disabled frame option unlocked Mouse Look")
end
arg1 = "LeftButton"
worldScripts.OnMouseDown()
if stopped ~= 0 or not ConsoleUI.mouselook:IsActive() or oldDownCalls ~= 1 then
    error("left click changed manual look")
end

arg1 = "RightButton"
worldScripts.OnMouseDown()
if started ~= 1 or stopped ~= 1 or ConsoleUI.mouselook:IsActive() or oldDownCalls ~= 2 then
    error("right click stop failed")
end

ConsoleUI_MouseLook()
ConsoleUI_MouseLook()
if started ~= 2 or stopped ~= 2 or ConsoleUI.mouselook:IsActive() then
    error("manual stop failed after watcher install")
end

ConsoleUI_MouseLookStart()
ConsoleUI_MouseLookStart()
if started ~= 3 or stopped ~= 2 or not ConsoleUI.mouselook:IsActive() then
    error("start-only binding was not idempotent")
end

arg1 = "RightButton"
worldScripts.OnMouseDown()
if stopped ~= 3 or ConsoleUI.mouselook:IsActive() then
    error("right click did not stop start-only look")
end

ConsoleUI.mouselook:OnActionBinding()
ConsoleUI.mouselook:OnActionBinding()
if started ~= 4 or stopped ~= 3 or not ConsoleUI.mouselook:IsActive() then
    error("action binding did not start look idempotently")
end

arg1 = "RightButton"
worldScripts.OnMouseDown()
if stopped ~= 4 or ConsoleUI.mouselook:IsActive() then
    error("right click did not stop action look")
end

ConsoleUI_MouseLookStart()
if started ~= 5 or not ConsoleUI.mouselook:IsActive() then
    error("World Map test failed to start")
end
configValues.mouseLookUnlockWorldMap = true
worldMapScripts.OnShow()
if stopped ~= 5 or ConsoleUI.mouselook:IsActive() or oldMapShowCalls ~= 1 then
    error("World Map did not stop Mouse Look or preserve its old handler")
end

ConsoleUI_MouseLookStart()
if started ~= 6 or not ConsoleUI.mouselook:IsActive() then
    error("bag test failed to start")
end
configValues.mouseLookUnlockBags = true
bagScripts.OnShow()
if stopped ~= 6 or ConsoleUI.mouselook:IsActive() or oldBagShowCalls ~= 1 then
    error("bag did not stop Mouse Look or preserve its old handler")
end

ConsoleUI_MouseLookStart()
if started ~= 7 or not ConsoleUI.mouselook:IsActive() then
    error("Escape menu test failed to start")
end
configValues.mouseLookUnlockGameMenu = true
gameMenuScripts.OnShow()
if stopped ~= 7 or ConsoleUI.mouselook:IsActive() or oldShowCalls ~= 1 then
    error("Escape menu did not stop Mouse Look or preserve its old handler")
end
gameMenuScripts.OnShow()
if stopped ~= 7 or oldShowCalls ~= 2 then
    error("Escape menu stopped inactive Mouse Look")
end

configValues.mouseLookUnlockModifierDoubleTap = true
ConsoleUI_MouseLookStart()
if started ~= 8 or not ConsoleUI.mouselook:IsActive() then
    error("modifier test failed to start")
end

-- A single Shift tap must not unlock.
clock = 1.00
shiftDown = true
modifierScripts.OnUpdate()
clock = 1.05
shiftDown = false
modifierScripts.OnUpdate()
if stopped ~= 7 or not ConsoleUI.mouselook:IsActive() then
    error("single Shift tap unlocked Mouse Look")
end

-- A second Shift down-edge inside the window must unlock.
clock = 1.20
shiftDown = true
modifierScripts.OnUpdate()
if stopped ~= 8 or ConsoleUI.mouselook:IsActive() then
    error("double Shift tap did not unlock Mouse Look")
end
if modifierScripts.OnUpdate then
    error("modifier watcher remained active after unlock")
end

-- Slow Ctrl taps must not unlock; a later fast pair must.
shiftDown = false
controlDown = false
ConsoleUI_MouseLookStart()
clock = 2.00
controlDown = true
modifierScripts.OnUpdate()
clock = 2.05
controlDown = false
modifierScripts.OnUpdate()
clock = 2.50
controlDown = true
modifierScripts.OnUpdate()
clock = 2.55
controlDown = false
modifierScripts.OnUpdate()
if stopped ~= 8 or not ConsoleUI.mouselook:IsActive() then
    error("slow Ctrl taps unlocked Mouse Look")
end
clock = 2.65
controlDown = true
modifierScripts.OnUpdate()
if stopped ~= 9 or ConsoleUI.mouselook:IsActive() then
    error("double Ctrl tap did not unlock Mouse Look")
end

local frameOptions = {
    CharacterFrame = "mouseLookUnlockCharacter",
    SpellBookFrame = "mouseLookUnlockSpellbook",
    TalentFrame = "mouseLookUnlockTalents",
    QuestLogFrame = "mouseLookUnlockQuests",
    FriendsFrame = "mouseLookUnlockSocial",
    MerchantFrame = "mouseLookUnlockCommerce",
    TradeSkillFrame = "mouseLookUnlockProfessions",
    HelpFrame = "mouseLookUnlockOtherWindows",
    ContainerFrame12 = "mouseLookUnlockBags",
    pfBag = "mouseLookUnlockBags",
    WorldMapFrame = "mouseLookUnlockWorldMap",
}
for frameName, option in pairs(frameOptions) do
    if ConsoleUI.mouselook:UnlockOptionForFrame(frameName) ~= option then
        error("wrong unlock category for " .. frameName)
    end
end

configValues.mouseLookLockOnMovement = false
ConsoleUI_MouseLookStart()
if started ~= 9 then
    error("disabled movement lock started Mouse Look")
end
configValues.mouseLookLockOnActions = false
ConsoleUI.mouselook:OnActionBinding()
if started ~= 9 then
    error("disabled action lock started Mouse Look")
end
configValues.mouseLookEnabled = false
ConsoleUI_MouseLook()
if started ~= 9 then
    error("disabled engine started Mouse Look")
end

configValues.mouseLookEnabled = true
configValues.mouseLookLockOnMovement = true
ConsoleUI_MouseLookStart()
configValues.mouseLookEnabled = false
ConsoleUI.mouselook:ApplySettings("mouseLookEnabled")
if started ~= 10 or stopped ~= 10 or ConsoleUI.mouselook:IsActive() then
    error("disabling engine did not release tracked Mouse Look")
end

configValues.mouseLookEnabled = true
configValues.mouseLookUnlockCharacter = true
ConsoleUI_MouseLookStart()
ConsoleUI.mouselook:OnFrameShown("CharacterFrame")
if started ~= 11 or stopped ~= 11 or ConsoleUI.mouselook:IsActive() then
    error("enabled character-window option did not unlock Mouse Look")
end

configValues.mouseLookInvertX = true
configValues.mouseLookInvertY = true
configValues.mouseLookMouseSpeed = 6
ConsoleUI.mouselook:ApplyCameraSettings()
if cvars.mouseInvertYaw ~= "1" or cvars.mouseInvertPitch ~= "1" or cvars.mouseSpeed ~= "4.00" then
    error("camera settings were not applied or clamped")
end

-- User-facing direct controls are independent from automatic movement policy.
configValues.mouseLookLockOnMovement = false
ConsoleUI_MouseLock()
ConsoleUI_MouseLock()
if started ~= 12 or stopped ~= 11 or not ConsoleUI.mouselook:IsActive() then
    error("Mouse Lock was not direct and idempotent")
end
ConsoleUI_MouseUnlock()
if started ~= 12 or stopped ~= 12 or ConsoleUI.mouselook:IsActive() then
    error("Mouse Unlock failed")
end

ConsoleUI_MouseLockHold(true)
if started ~= 13 or stopped ~= 12 or not ConsoleUI.mouselook:IsActive() then
    error("Mouse Lock Hold key-down failed")
end
ConsoleUI_MouseLockHold(false)
if started ~= 13 or stopped ~= 13 or ConsoleUI.mouselook:IsActive() then
    error("Mouse Lock Hold key-up failed")
end

ConsoleUI_MouseLock()
ConsoleUI_MouseUnlockHold(true)
if started ~= 14 or stopped ~= 14 or ConsoleUI.mouselook:IsActive() then
    error("Mouse Unlock Hold key-down failed")
end
ConsoleUI_MouseUnlockHold(false)
if started ~= 15 or stopped ~= 14 or not ConsoleUI.mouselook:IsActive() then
    error("Mouse Unlock Hold key-up failed")
end
ConsoleUI_MouseUnlock()

ConsoleUI_MouseLockToggle()
ConsoleUI_MouseLockToggle()
if started ~= 16 or stopped ~= 16 or ConsoleUI.mouselook:IsActive() then
    error("Mouse Lock Toggle failed")
end
print("Mouse Look check OK")
