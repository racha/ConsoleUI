-- Get localized text (with fallback)
local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

--[[
    ConsoleUI - Keybindings Module
    
    Handles keybindings like pfUI does:
    - Creates binding names dynamically with _G["BINDING_NAME_..."]
    - Overrides ActionButtonDown/Up to redirect to our buttons
    - Uses runOnUp="true" in Bindings.xml
    
    40 action slots mapped to keys:
    - Actions 1-10: No modifier (keys 1-0)
    - Actions 11-20: Shift (Shift+1-0)
    - Actions 21-30: Ctrl (Ctrl+1-0)
    - Actions 31-40: Ctrl+Shift (Ctrl+Shift+1-0)
]]

-- ============================================================================
-- Create Binding Names Dynamically (like pfUI does)
-- ============================================================================

-- Binding header
_G["BINDING_HEADER_CONSOLEUI"] = "ConsoleUI"
_G["BINDING_HEADER_CONSOLEUILEFTBAR"] = "ConsoleUI Left Touch Bar"
_G["BINDING_HEADER_CONSOLEUIRIGHTBAR"] = "ConsoleUI Right Touch Bar"

-- Controller button names for each position (1-10)
local buttonNames = {
    [1] = "A",
    [2] = "X",
    [3] = "Y",
    [4] = "B",
    [5] = L("Down"),
    [6] = L("Left"),
    [7] = L("Up"),
    [8] = L("Right"),
    [9] = "RB",
    [10] = "RT",
}

-- Modifier prefixes for each page
local modifierPrefixes = {
    [1] = "",           -- 1-10: No modifier
    [2] = "LT + ",      -- 11-20: Shift = LT
    [3] = "LB + ",      -- 21-30: Ctrl = LB
    [4] = "LT + LB + ", -- 31-40: Shift+Ctrl = LT + LB
}

-- Create all 40 binding names with controller button combos
for i = 1, 40 do
    local page = math.floor((i - 1) / 10) + 1
    local buttonIndex = math.mod(i - 1, 10) + 1
    local buttonName = buttonNames[buttonIndex]
    local modifier = modifierPrefixes[page]
    _G["BINDING_NAME_ConsoleUI_ACTION_" .. i] = L("Action") .. i .. " (" .. modifier .. buttonName .. ")"
end

-- Create binding names for left touch bar (slots 41-45)
for i = 41, 45 do
    local buttonIndex = i - 40  -- Button 1-5 on left bar
    _G["BINDING_NAME_ConsoleUI_ACTION_" .. i] = L("Left Touch Bar Button") .. " " .. buttonIndex
end

-- Create binding names for right touch bar (slots 46-50)
for i = 46, 50 do
    local buttonIndex = i - 45  -- Button 1-5 on right bar
    _G["BINDING_NAME_ConsoleUI_ACTION_" .. i] = L("Right Touch Bar Button") .. " " .. buttonIndex
end

-- Cursor header and binding names
_G["BINDING_HEADER_CONSOLEUICURSOR"] = L("ConsoleUI Cursor")
_G["BINDING_NAME_ConsoleUI_CURSOR_MOVE_UP"] = L("Cursor Up")
_G["BINDING_NAME_ConsoleUI_CURSOR_MOVE_DOWN"] = L("Cursor Down")
_G["BINDING_NAME_ConsoleUI_CURSOR_MOVE_LEFT"] = L("Cursor Left")
_G["BINDING_NAME_ConsoleUI_CURSOR_MOVE_RIGHT"] = L("Cursor Right")
_G["BINDING_NAME_ConsoleUI_CURSOR_CLICK_LEFT"] = L("Cursor Click")
_G["BINDING_NAME_ConsoleUI_CURSOR_CLICK_RIGHT"] = L("Cursor Right-Click")
_G["BINDING_NAME_ConsoleUI_CURSOR_PICKUP"] = L("Cursor Pickup")
_G["BINDING_NAME_ConsoleUI_CURSOR_BIND"] = L("Cursor Bind")
_G["BINDING_NAME_ConsoleUI_CURSOR_DELETE"] = L("Cursor Delete")
_G["BINDING_NAME_ConsoleUI_CURSOR_UNEQUIP"] = L("Cursor Unequip")
_G["BINDING_NAME_ConsoleUI_CURSOR_CLOSE"] = L("Cursor Close")

-- Radial menu header and binding name
_G["BINDING_HEADER_CONSOLEUIRADIAL"] = L("ConsoleUI Radial Menu")
_G["BINDING_NAME_ConsoleUI_TOGGLE_RADIAL"] = L("Toggle Radial Menu")
_G["BINDING_NAME_ConsoleUI_RADIAL_UP"] = L("Radial Stick Up")
_G["BINDING_NAME_ConsoleUI_RADIAL_DOWN"] = L("Radial Stick Down")
_G["BINDING_NAME_ConsoleUI_RADIAL_LEFT"] = L("Radial Stick Left")
_G["BINDING_NAME_ConsoleUI_RADIAL_RIGHT"] = L("Radial Stick Right")
_G["BINDING_NAME_ConsoleUI_RADIAL_ACTION_A"] = L("Radial Action A")
_G["BINDING_NAME_ConsoleUI_RADIAL_ACTION_X"] = L("Radial Action X")
_G["BINDING_NAME_ConsoleUI_RADIAL_ACTION_Y"] = L("Radial Action Y")
_G["BINDING_NAME_ConsoleUI_RADIAL_ACTION_B"] = L("Radial Action B")
_G["BINDING_NAME_ConsoleUI_RING_1"] = L("Ring") .. " 1"
_G["BINDING_NAME_ConsoleUI_RING_2"] = L("Ring") .. " 2"
_G["BINDING_NAME_ConsoleUI_RING_3"] = L("Ring") .. " 3"
_G["BINDING_NAME_ConsoleUI_RING_4"] = L("Ring") .. " 4"
_G["BINDING_NAME_ConsoleUI_RING_5"] = L("Ring") .. " 5"
_G["BINDING_NAME_ConsoleUI_RING_6"] = L("Ring") .. " 6"
_G["BINDING_NAME_ConsoleUI_RING_7"] = L("Ring") .. " 7"
_G["BINDING_NAME_ConsoleUI_RING_8"] = L("Ring") .. " 8"
_G["BINDING_NAME_ConsoleUI_RING_CANCEL"] = L("Cancel Ring")

-- Interact header and binding name
_G["BINDING_HEADER_CONSOLEUIINTERACT"] = L("ConsoleUI Interact")
_G["BINDING_NAME_ConsoleUI_INTERACT"] = L("Interact with Target")

-- ============================================================================
-- ConsoleUI_InteractNearest Function (used by ConsoleUI_INTERACT binding)
-- ============================================================================

function ConsoleUI_InteractNearest()
    -- InteractNearest is provided by Interact.dll (Turtle WoW addon)
    if InteractNearest then
        InteractNearest(1)
    else
        -- Fallback: target nearest enemy if Interact.dll is not loaded
        ConsoleUI_Print(L("Interact.dll not loaded - using TargetNearestEnemy() as fallback"))
        TargetNearestEnemy()
    end
end

-- ============================================================================
-- Global Action Button Handler (like pfUI's pfActionButton)
-- ============================================================================

-- Debug flag - set to true to see key press debug info
ConsoleUI_DEBUG_KEYS = false

-- Block casts only while the radial keyboard is actually on screen.
-- Shagu Chat Tweaks / an idle ChatFrameEditBox can stay shown or focused
-- without the OSK. That used to eat 1-4 and D-pad until chat was toggled.
-- Stale Keyboard.Focus with the OSK hidden is the same leak.
function ConsoleUI_ChatBlocksActions()
    local kb = ConsoleUIKeyboard
    if kb and kb.IsShown and kb:IsShown() then
        return true
    end
    if kb and kb.ReleaseIdleChatBox then
        kb:ReleaseIdleChatBox()
    end
    if kb and kb.IsShown and kb:IsShown() then
        return true
    end
    if kb and kb.IsEnabled and kb:IsEnabled() then
        return false
    end
    local box = ChatFrameEditBox
    if box and box.HasFocus and box:HasFocus() then
        return true
    end
    return false
end

function ConsoleUI_ActionButton(slot)
    if ConsoleUI_ChatBlocksActions() then return end

    -- ACTION bindings and ActionButtonDown do not set keystate.
    -- runOnUp leftovers (chat / radial) stay "up" and used to skip every cast
    -- until a later "down" leaked in. Skip only an explicit release.
    if keystate == "up" then
        return
    end
    local actualSlot = slot
        local ActionBars = ConsoleUI.actionbars
        
        -- For slots 1-10 (base bar without modifiers), use GetActionOffset logic
        if slot >= 1 and slot <= 10 then
            if ActionBars and ActionBars.GetActionOffset then
                -- Use the same offset calculation as the action bars
                local offset = ActionBars:GetActionOffset()
                actualSlot = offset + slot
            else
                -- Fallback: basic bonus bar calculation
                local bonusBar = GetBonusBarOffset()
                if bonusBar and bonusBar > 0 then
                    actualSlot = 60 + (bonusBar * 12) + slot
                end
            end
        end
        
        -- Debug output
        if ConsoleUI_DEBUG_KEYS then
            local bonusBar = GetBonusBarOffset() or 0
            ConsoleUI_Debug("Key slot=" .. slot .. " bonus=" .. bonusBar .. " actual=" .. actualSlot .. " has=" .. tostring(HasAction(actualSlot)))
        end
        
        -- Check if healer mode is enabled and cursor is over a party/raid/player frame
        local ActionBars = ConsoleUI.actionbars
        if ActionBars and ActionBars.ShouldCastOnHealerTarget and ActionBars:ShouldCastOnHealerTarget() then
            local Cursor = ConsoleUI.cursor
            local currentButton = Cursor.navigationState.currentButton
            local unit = ActionBars:GetUnitFromFrame(currentButton)
            
            if unit then
                -- Use the action first
                UseAction(actualSlot, 0)
                
                -- If spell is awaiting target selection, check if we can cast on the unit
                if SpellIsTargeting() then
                    -- Check if the spell can target this unit
                    if SpellCanTargetUnit(unit) then
                        -- Cast on the unit
                        SpellTargetUnit(unit)
                        ConsoleUI_Debug("Healer mode: Casting action " .. actualSlot .. " on " .. unit)
                        
                        -- Update button visual
                        local buttonNum = math.mod(slot - 1, 10) + 1
                        local button = getglobal("ConsoleActionButton" .. buttonNum)
                        if button and ConsoleUI.actionbars then
                            ConsoleUI.actionbars:UpdateButtonState(button)
                        end
                        return
                    else
                        -- Can't target this unit, let it work normally (player can target manually or use current target)
                        ConsoleUI_Debug("Healer mode: Cannot cast action " .. actualSlot .. " on " .. unit .. " (invalid target, using default behavior)")
                        -- Don't return - let it fall through to normal behavior below
                    end
                else
                    -- Spell doesn't require targeting (instant cast, self-buff, etc.) - already executed
                    ConsoleUI_Debug("Healer mode: Used action " .. actualSlot .. " (no targeting required)")
                    
                    -- Update button visual
                    local buttonNum = math.mod(slot - 1, 10) + 1
                    local button = getglobal("ConsoleActionButton" .. buttonNum)
                    if button and ConsoleUI.actionbars then
                        ConsoleUI.actionbars:UpdateButtonState(button)
                    end
                    return
                end
            end
        end
        
        -- Use the action (checkCursor=0, onSelf=nil to use normal targeting)
        UseAction(actualSlot, 0)
        
        -- Update button visual
        local buttonNum = math.mod(slot - 1, 10) + 1
        local button = getglobal("ConsoleActionButton" .. buttonNum)
        if button and ConsoleUI.actionbars then
            ConsoleUI.actionbars:UpdateButtonState(button)
        end
end

-- ============================================================================
-- Keybindings Module
-- ============================================================================

ConsoleUIKeybindings = {}

-- Default key bindings (can be customized)
ConsoleUIKeybindings.DEFAULT_KEYS = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
}

-- GetCurrentBindingSet is 0 until the player's set is in memory.
-- SetBinding + SaveBindings in that window writes an empty table over
-- the real keyboard (often account-wide).
function ConsoleUI_BindingsReady()
    if GetCurrentBindingSet then
        local set = GetCurrentBindingSet()
        if set ~= 1 and set ~= 2 then
            return false
        end
    end
    if GetBindingKey then
        if GetBindingKey("MOVEFORWARD")
            or GetBindingKey("CAMERAORSELECTORMOVE")
            or GetBindingKey("ACTIONBUTTON1")
            or GetBindingKey("JUMP") then
            return true
        end
    end
    if GetBindingAction then
        local walk = GetBindingAction("W")
        local one = GetBindingAction("1")
        if (walk and walk ~= "") or (one and one ~= "") then
            return true
        end
    end
    return false
end

-- Auto-setup may only take a free key or one already owned by ConsoleUI.
-- Never used for bare 1-0 / M / ESCAPE. Those stay the player's.
function ConsoleUI_CanClaimKey(key)
    if not key or key == "" or not GetBindingAction then
        return false
    end
    local current = GetBindingAction(key)
    if not current or current == "" then
        return true
    end
    return string.find(current, "^ConsoleUI_") ~= nil
end

function ConsoleUIKeybindings:SetupDefaultBindings()
    if ConsoleUI_BindingsReady and not ConsoleUI_BindingsReady() then
        return false
    end

    local keys = self.DEFAULT_KEYS
    local changed = false

    local function claim(key, action)
        if GetBindingKey(action) then
            return
        end
        if not ConsoleUI_CanClaimKey(key) then
            return
        end
        if GetBindingAction(key) == action then
            return
        end
        SetBinding(key, action)
        changed = true
    end

    -- Steam layout: 1-0 / M / ESCAPE stay the player's keys.
    -- Only LT (Shift), LB (Ctrl), LT+LB (Ctrl+Shift) chords are ours.
    for i = 1, 10 do
        claim("SHIFT-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 10))
        claim("CTRL-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 20))
        claim("CTRL-SHIFT-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 30))
    end

    if changed then
        ConsoleUI_SaveBindings()
        ConsoleUI_Debug("Default keybindings set!")
    end
    return changed
end

function ConsoleUIKeybindings:InstallActionButtonHooks()
    -- Override default action button handlers like pfUI does
    -- This redirects default action bar keypresses to our buttons
    _G.ActionButtonDown = function(id)
        ConsoleUI_ActionButton(id)
    end
    _G.ActionButtonUp = function(id)
        -- We use runOnUp, so this is handled by ConsoleUI_ActionButton
    end
end

function ConsoleUIKeybindings:FinishInitialize()
    -- Check if any CE_ACTION binding already has a key assigned.
    -- We scan all 40 slots because some may be proxied to system actions (like JUMP),
    -- which replaces their ConsoleUI_ACTION_X key. On a fresh install, none will have keys.
    local hasExistingBindings = false
    for i = 1, 40 do
        if GetBindingKey("ConsoleUI_ACTION_" .. i) then
            hasExistingBindings = true
            break
        end
    end

    if not hasExistingBindings then
        ConsoleUI_Debug("No ConsoleUI bindings found, setting up defaults...")
        self:SetupDefaultBindings()
    else
        ConsoleUI_Debug("Existing ConsoleUI bindings found, skipping default setup")
    end

    -- Initialize and apply proxied actions (replaces old useAForJump system)
    if ConsoleUI.proxied and ConsoleUI.proxied.Initialize then
        ConsoleUI.proxied:Initialize()
    end

    if ConsoleUI.radial and ConsoleUI.radial.RepairMovementBindings then
        ConsoleUI.radial:RepairMovementBindings()
    end

    if ConsoleUI_RepairCameraBindings and ConsoleUI_RepairCameraBindings() then
        ConsoleUI_SaveBindings()
    end

    ConsoleUI_Debug("Keybindings module initialized!")
end

function ConsoleUIKeybindings:WatchForBindings()
    if self.bindWatch then
        return
    end
    local f = CreateFrame("Frame")
    self.bindWatch = f
    f.elapsed = 0
    f.age = 0
    f:SetScript("OnUpdate", function()
        this.elapsed = this.elapsed + arg1
        this.age = this.age + arg1
        if this.elapsed < 0.25 then
            return
        end
        this.elapsed = 0
        local ready = ConsoleUI_BindingsReady and ConsoleUI_BindingsReady()
        if ready or this.age > 8 then
            this:SetScript("OnUpdate", nil)
            ConsoleUI.keybindings.bindWatch = nil
            if ready then
                ConsoleUI.keybindings:FinishInitialize()
            else
                ConsoleUI_Debug("Bindings never loaded; skipped default key rewrite")
            end
        end
    end)
end

function ConsoleUIKeybindings:Initialize()
    self:InstallActionButtonHooks()
    if ConsoleUI_BindingsReady and ConsoleUI_BindingsReady() then
        self:FinishInitialize()
        return
    end
    ConsoleUI_Debug("Player bindings not loaded yet; waiting before any SaveBindings")
    self:WatchForBindings()
end

-- Attach to main addon
ConsoleUI.keybindings = ConsoleUIKeybindings

-- Function to force reset all keybindings (called from config menu)
function ConsoleUIKeybindings:ResetAllBindings()
    local keys = self.DEFAULT_KEYS

    -- Rebind modifier pages only. Leave 1-0 / M / ESCAPE alone.
    for i = 1, 10 do
        SetBinding("SHIFT-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 10))
        SetBinding("CTRL-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 20))
        SetBinding("CTRL-SHIFT-" .. keys[i], "ConsoleUI_ACTION_" .. (i + 30))
    end

    ConsoleUI_SaveBindings()
    
    -- Now apply proxied actions (will override CE_ACTION bindings where needed)
    if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then
        ConsoleUI.proxied:ApplyAllBindings()
    end
end
