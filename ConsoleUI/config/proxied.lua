--[[
    ConsoleUI - Proxied Actions Module
    
    Handles system bindings (JUMP, AUTORUN, etc.) that can be assigned to 
    controller buttons instead of action bar slots.
    
    When a button is assigned to a proxied action:
    - The WoW binding is set directly (e.g., key "1" -> "JUMP")
    - The action bar shows the proxied action's icon
    - The placement frame hides that slot
]]

-- Create the proxied module namespace
ConsoleUI.proxied = ConsoleUI.proxied or {}
local Proxied = ConsoleUI.proxied

-- Helper function to get localized text
local function L(key)
    if ConsoleUI.locale and ConsoleUI.locale.T then
        return ConsoleUI.locale.T(key)
    end
    return key
end

-- ============================================================================
-- Proxied Actions Definition
-- ============================================================================

-- Available proxied actions organized by category
-- Format: { id = "WOW_BINDING_ID", nameKey = "translation key", icon = "texture path" }
-- Note: id can be a native WoW binding (e.g., "JUMP") or a CE custom binding (e.g., "ConsoleUI_INTERACT")
Proxied.ACTIONS = {
    -- Movement
    { headerKey = "Movement" },
    { 
        id = "JUMP", 
        nameKey = "Jump", 
        icon = "Interface\\Icons\\Ability_Rogue_FleetFooted",
        descKey = "Jump"
    },
    { 
        id = "TOGGLEAUTORUN", 
        nameKey = "Auto Run", 
        icon = "Interface\\Icons\\Ability_Rogue_Sprint",
        descKey = "Toggle auto-run"
    },
    { 
        id = "TOGGLERUN", 
        nameKey = "Run/Walk", 
        icon = "Interface\\Icons\\Ability_Tracking",
        descKey = "Toggle run/walk speed"
    },
    
    -- Targeting
    { headerKey = "Targeting" },
    { 
        id = "ConsoleUI_INTERACT", 
        nameKey = "Interact", 
        icon = "Interface\\Icons\\Ability_Eyeoftheowl",
        descKey = "Interact with nearest target"
    },
    { 
        id = "TARGETSELF", 
        nameKey = "Target Self", 
        icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
        descKey = "Target yourself"
    },
    { 
        id = "TARGETNEARESTENEMY", 
        nameKey = "Target Nearest Enemy", 
        icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
        descKey = "Target the nearest enemy"
    },
    { 
        id = "TARGETPREVIOUSENEMY", 
        nameKey = "Target Previous Enemy", 
        icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
        descKey = "Target the previous enemy"
    },
    { 
        id = "TARGETNEARESTFRIEND", 
        nameKey = "Target Nearest Friend", 
        icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        descKey = "Target the nearest friendly player"
    },
    { 
        id = "ASSISTTARGET", 
        nameKey = "Assist Target", 
        icon = "Interface\\Icons\\Ability_Hunter_AspectOfTheViper",
        descKey = "Target your target's target"
    },
    
    -- Interface
    { headerKey = "Interface" },
    { 
        id = "OPENALLBAGS", 
        nameKey = "Open Bags", 
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
        descKey = "Open all bags"
    },
    { 
        id = "TOGGLEGAMEMENU", 
        nameKey = "Game Menu", 
        icon = "Interface\\Icons\\INV_Misc_Gear_01",
        descKey = "Open the game menu"
    },
    { 
        id = "TOGGLEWORLDMAP", 
        nameKey = "World Map", 
        icon = "Interface\\Icons\\INV_Misc_Map_01",
        descKey = "Toggle world map"
    },
    { 
        id = "TOGGLECHARACTER0", 
        nameKey = "Character Panel", 
        icon = "Interface\\Icons\\INV_Shirt_Black_01",
        descKey = "Toggle character info"
    },
    { 
        id = "TOGGLESPELLBOOK", 
        nameKey = "Spellbook", 
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        descKey = "Toggle spellbook"
    },
    { 
        id = "TOGGLETALENTS", 
        nameKey = "Talents", 
        icon = "Interface\\Icons\\Ability_Marksmanship",
        descKey = "Toggle talent window"
    },
    { 
        id = "TOGGLEQUESTLOG", 
        nameKey = "Quest Log", 
        icon = "Interface\\Icons\\INV_Misc_Book_08",
        descKey = "Toggle quest log"
    },
    { 
        id = "TOGGLESOCIAL", 
        nameKey = "Social", 
        icon = "Interface\\Icons\\INV_Letter_02",
        descKey = "Toggle friends list"
    },
    
    -- Camera
    { headerKey = "Camera" },
    { 
        id = "CAMERAZOOMIN", 
        nameKey = "Zoom In", 
        icon = "Interface\\Icons\\INV_Misc_SpyGlass_03",
        descKey = "Zoom camera in"
    },
    { 
        id = "CAMERAZOOMOUT", 
        nameKey = "Zoom Out", 
        icon = "Interface\\Icons\\INV_Misc_SpyGlass_02",
        descKey = "Zoom camera out"
    },
    
    -- Combat
    { headerKey = "Combat" },
    { 
        id = "ATTACKTARGET", 
        nameKey = "Attack", 
        icon = "Interface\\Icons\\Ability_SteelMelee",
        descKey = "Start auto-attack"
    },
    { 
        id = "PETATTACK", 
        nameKey = "Pet Attack", 
        icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
        descKey = "Command pet to attack"
    },
    { 
        id = "STOPATTACK", 
        nameKey = "Stop Attack", 
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        descKey = "Stop attacking"
    },
}

-- Get translated action info
function Proxied:GetActionName(action)
    if action.nameKey then
        return L(action.nameKey)
    end
    return action.name or ""
end

function Proxied:GetActionDesc(action)
    if action.descKey then
        return L(action.descKey)
    end
    return action.desc or ""
end

function Proxied:GetHeaderName(action)
    if action.headerKey then
        return L(action.headerKey)
    end
    return action.header or ""
end

-- Key slot mapping (maps slot numbers to key combinations)
-- Slot 1-10: No modifier (keys 1-0)
-- Slot 11-20: Shift (LT) + keys 1-0
-- Slot 21-30: Ctrl (LB) + keys 1-0
-- Slot 31-40: Shift+Ctrl (LT+LB) + keys 1-0
Proxied.SLOT_KEYS = {
    -- No modifier
    [1] = "1", [2] = "2", [3] = "3", [4] = "4", [5] = "5",
    [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "0",
    -- Shift (LT)
    [11] = "SHIFT-1", [12] = "SHIFT-2", [13] = "SHIFT-3", [14] = "SHIFT-4", [15] = "SHIFT-5",
    [16] = "SHIFT-6", [17] = "SHIFT-7", [18] = "SHIFT-8", [19] = "SHIFT-9", [20] = "SHIFT-0",
    -- Ctrl (LB)
    [21] = "CTRL-1", [22] = "CTRL-2", [23] = "CTRL-3", [24] = "CTRL-4", [25] = "CTRL-5",
    [26] = "CTRL-6", [27] = "CTRL-7", [28] = "CTRL-8", [29] = "CTRL-9", [30] = "CTRL-0",
    -- Ctrl+Shift (LT+LB)
    [31] = "CTRL-SHIFT-1", [32] = "CTRL-SHIFT-2", [33] = "CTRL-SHIFT-3", [34] = "CTRL-SHIFT-4", [35] = "CTRL-SHIFT-5",
    [36] = "CTRL-SHIFT-6", [37] = "CTRL-SHIFT-7", [38] = "CTRL-SHIFT-8", [39] = "CTRL-SHIFT-9", [40] = "CTRL-SHIFT-0",
}

-- Slot names for display (button names)
Proxied.SLOT_NAMES = {
    [1] = "A", [2] = "X", [3] = "Y", [4] = "B", [5] = "Down",
    [6] = "Left", [7] = "Up", [8] = "Right", [9] = "RB", [10] = "RT",
}

-- Modifier names for pages
Proxied.PAGE_MODIFIERS = {
    [1] = "",
    [2] = "LT + ",
    [3] = "LB + ",
    [4] = "LT + LB + ",
}

-- Protected bindings that can only be executed via keyboard, not mouse clicks
-- These are WoW system functions that require secure execution
Proxied.PROTECTED_BINDINGS = {
    -- Movement
    ["JUMP"] = true,
    ["TOGGLEAUTORUN"] = true,
    ["TOGGLERUN"] = true,
    -- Combat
    -- ["ATTACKTARGET"] = true,
    -- ["STOPATTACK"] = true,
    -- ["PETATTACK"] = true,
    -- -- Targeting (some may be protected)
    -- ["TARGETSELF"] = true,
    -- ["TARGETNEARESTENEMY"] = true,
    -- ["TARGETPREVIOUSENEMY"] = true,
    -- ["TARGETNEARESTFRIEND"] = true,
    -- ["ASSISTTARGET"] = true,
}

-- Check if a binding ID is protected (can only be executed via keyboard)
function Proxied:IsProtectedBinding(bindingID)
    if not bindingID then return false end
    return self.PROTECTED_BINDINGS[bindingID] == true
end

-- ============================================================================
-- Sidebar Slot Configuration
-- ============================================================================

-- Sidebar slot offsets (same as in bars.lua)
Proxied.SIDE_BAR_LEFT_OFFSET = 40   -- Slots 41-45
Proxied.SIDE_BAR_RIGHT_OFFSET = 45  -- Slots 46-50

-- Sidebar slot names for display
Proxied.SIDEBAR_SLOT_NAMES = {
    -- Left sidebar (slots 41-45)
    [41] = "Left 1", [42] = "Left 2", [43] = "Left 3", [44] = "Left 4", [45] = "Left 5",
    -- Right sidebar (slots 46-50)
    [46] = "Right 1", [47] = "Right 2", [48] = "Right 3", [49] = "Right 4", [50] = "Right 5",
}

-- Check if a slot is a sidebar slot
function Proxied:IsSidebarSlot(slot)
    return slot >= 41 and slot <= 50
end

-- Get sidebar side and button index for a slot
-- Returns: side ("left" or "right"), buttonIndex (1-5), or nil if not a sidebar slot
function Proxied:GetSidebarSlotInfo(slot)
    if slot >= 41 and slot <= 45 then
        return "left", slot - 40
    elseif slot >= 46 and slot <= 50 then
        return "right", slot - 45
    end
    return nil, nil
end

-- Get slot number for a sidebar button
function Proxied:GetSidebarSlot(side, buttonIndex)
    if side == "left" then
        return 40 + buttonIndex
    elseif side == "right" then
        return 45 + buttonIndex
    end
    return nil
end

-- ============================================================================
-- Get Action Info
-- ============================================================================

-- Get action info by binding ID (returns with translated name/desc)
function Proxied:GetActionByID(bindingID)
    if ConsoleUI.rings and ConsoleUI.rings.GetActionInfo then
        local ringInfo = ConsoleUI.rings:GetActionInfo(bindingID)
        if ringInfo then
            return ringInfo
        end
    end
    for _, action in ipairs(self.ACTIONS) do
        if action.id == bindingID then
            -- Return a copy with translated name and desc for display
            return {
                id = action.id,
                name = self:GetActionName(action),
                desc = self:GetActionDesc(action),
                icon = action.icon
            }
        end
    end
    return nil
end

-- Get all non-header actions
function Proxied:GetAllActions()
    local actions = {}
    for _, action in ipairs(self.ACTIONS) do
        if not action.headerKey then
            table.insert(actions, action)
        end
    end
    return actions
end

-- ============================================================================
-- Slot/Key Management
-- ============================================================================

-- Get the key combination for a slot
function Proxied:GetKeyForSlot(slot)
    return self.SLOT_KEYS[slot]
end

-- Get display name for a slot
function Proxied:GetSlotDisplayName(slot)
    -- Check if it's a sidebar slot
    if self.SIDEBAR_SLOT_NAMES[slot] then
        return self.SIDEBAR_SLOT_NAMES[slot]
    end
    
    -- Main action bar slots (1-40)
    local page = math.floor((slot - 1) / 10) + 1
    local buttonIndex = math.mod(slot - 1, 10) + 1
    local modifier = self.PAGE_MODIFIERS[page] or ""
    local buttonName = self.SLOT_NAMES[buttonIndex] or ("Slot " .. buttonIndex)
    return modifier .. buttonName
end

-- ============================================================================
-- Stance Slot Mapping
-- ============================================================================

-- Bonus bar base offset (same as in bars.lua and placement.lua)
local BONUS_BAR_BASE = 60

-- Calculate offset for a given bonus bar number
-- Formula: 60 + (bonusBar * 12)
local function GetStanceOffset(bonusBar)
    if not bonusBar or bonusBar == 0 then
        return 0
    end
    return BONUS_BAR_BASE + (bonusBar * 12)
end

-- Check if a slot is a stance/form slot (bonus bar)
function Proxied:IsStanceSlot(slot)
    return slot >= 73 and slot <= 130
end

-- Get the button position (1-10) for any slot
-- For stance slots (73+), returns the button position within that stance bar
-- For modifier slots (11-40), returns nil (handled separately)
-- For base slots (1-10), returns the slot itself
function Proxied:GetButtonPositionForSlot(slot)
    if slot >= 1 and slot <= 10 then
        return slot
    elseif slot >= 73 and slot <= 82 then
        return slot - 72  -- Bonus bar 1: 73->1, 82->10
    elseif slot >= 85 and slot <= 94 then
        return slot - 84  -- Bonus bar 2: 85->1, 94->10
    elseif slot >= 97 and slot <= 106 then
        return slot - 96  -- Bonus bar 3: 97->1, 106->10
    elseif slot >= 109 and slot <= 118 then
        return slot - 108  -- Bonus bar 4: 109->1, 118->10
    elseif slot >= 121 and slot <= 130 then
        return slot - 120  -- Bonus bar 5: 121->1, 130->10
    end
    return nil  -- Modifier slots (11-40) or other
end

-- Get all slots that share the same button position (1-10)
-- This includes the base slot and all stance bar slots
function Proxied:GetAllSlotsForButtonPosition(buttonPos)
    if buttonPos < 1 or buttonPos > 10 then
        return {}
    end
    
    local slots = { buttonPos }  -- Base slot
    
    -- Add stance bar slots
    for bonusBar = 1, 5 do
        table.insert(slots, GetStanceOffset(bonusBar) + buttonPos)
    end
    
    return slots
end

-- ============================================================================
-- Database Access
-- ============================================================================

-- Get proxied action for a slot (returns binding ID or nil)
-- For stance slots, also checks the corresponding base slot (1-10)
function Proxied:GetSlotBinding(slot)
    if not ConsoleUIDB or not ConsoleUIDB.proxiedActions then
        return nil
    end
    
    -- First check the exact slot
    local binding = ConsoleUIDB.proxiedActions[slot]
    if binding then
        return binding
    end
    
    -- For stance slots (73+), also check the corresponding base slot (1-10)
    local buttonPos = self:GetButtonPositionForSlot(slot)
    if buttonPos and buttonPos ~= slot then
        return ConsoleUIDB.proxiedActions[buttonPos]
    end
    
    return nil
end

-- Set proxied action for a slot (bindingID or nil to clear)
function Proxied:SetSlotBinding(slot, bindingID)
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.proxiedActions then
        ConsoleUIDB.proxiedActions = {}
    end
    
    -- Normalize stance slots (73+) to base button position (1-10)
    -- This ensures proxied actions apply to all stances
    local buttonPos = self:GetButtonPositionForSlot(slot)
    local normalizedSlot = buttonPos or slot
    
    -- If assigning a proxied action, check if it's already bound to another slot
    -- and release that binding first (set back to ConsoleUI_ACTION_X)
    local previousSlot = nil
    if bindingID then
        for existingSlot, existingBindingID in pairs(ConsoleUIDB.proxiedActions) do
            if existingBindingID == bindingID and existingSlot ~= normalizedSlot then
                previousSlot = existingSlot
                break
            end
        end

        if previousSlot then
            ConsoleUI_Debug("Proxied: Action " .. bindingID .. " was already on slot " .. previousSlot .. ", releasing it")
            ConsoleUIDB.proxiedActions[previousSlot] = nil
            -- Apply the binding change to restore ConsoleUI_ACTION_X for the previous slot
            self:ApplySlotBinding(previousSlot)
        end
    end

    ConsoleUIDB.proxiedActions[normalizedSlot] = bindingID

    -- Apply the binding change to all equivalent slots (base + all stance slots)
    if buttonPos then
        -- Apply to base slot and all stance slots
        local allSlots = self:GetAllSlotsForButtonPosition(buttonPos)
        for _, slotToApply in ipairs(allSlots) do
            self:ApplySlotBinding(slotToApply)
        end
    else
        -- Apply to just this slot (modifier slots 11-40)
        self:ApplySlotBinding(slot)
    end
    
    ConsoleUI_SaveBindings()
    
    -- Update action bar display
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
        ConsoleUI.actionbars:UpdateAllButtons()
    end
    
    -- Update placement frame if open
    if ConsoleUI.placement and ConsoleUI.placement.UpdateButtonVisibility then
        ConsoleUI.placement:UpdateButtonVisibility()
    end
    
    -- Update config dropdowns if the config panel is open (to reflect the released slot)
    if previousSlot and ConsoleUI.config and ConsoleUI.config.bindingDropdowns then
        local previousDropdown = ConsoleUI.config.bindingDropdowns[previousSlot]
        if previousDropdown then
            UIDropDownMenu_SetSelectedValue(previousDropdown, nil)
            local noneText = "None (Action Bar)"
            if Locale and Locale.T then
                noneText = Locale.T("None (Action Bar)")
            end
            UIDropDownMenu_SetText(noneText, previousDropdown)
        end
    end
end

-- Check if a slot has a proxied action
function Proxied:IsSlotProxied(slot)
    return self:GetSlotBinding(slot) ~= nil
end

-- Get the icon for a proxied slot (or nil if not proxied)
function Proxied:GetSlotIcon(slot)
    local bindingID = self:GetSlotBinding(slot)
    if bindingID then
        local action = self:GetActionByID(bindingID)
        if action then
            return action.icon
        end
    end
    return nil
end

-- Get the action info for a proxied slot (or nil if not proxied)
function Proxied:GetSlotActionInfo(slot)
    local bindingID = self:GetSlotBinding(slot)
    if bindingID then
        return self:GetActionByID(bindingID)
    end
    return nil
end

-- ============================================================================
-- Sidebar Binding Release
-- ============================================================================

-- Release proxied actions for hidden sidebar slots
-- side: "left" or "right"
-- maxButtons: maximum number of visible buttons (1-5)
function Proxied:ReleaseSidebarBindings(side, maxButtons)
    if not ConsoleUIDB or not ConsoleUIDB.proxiedActions then
        return
    end
    
    local startSlot, endSlot
    if side == "left" then
        startSlot = 41
        endSlot = 45
    elseif side == "right" then
        startSlot = 46
        endSlot = 50
    else
        return
    end
    
    -- Release bindings for slots beyond maxButtons
    for i = (maxButtons + 1), 5 do
        local slot = startSlot + i - 1
        if ConsoleUIDB.proxiedActions[slot] then
            ConsoleUI_Debug("Proxied: Releasing sidebar binding for " .. self:GetSlotDisplayName(slot))
            ConsoleUIDB.proxiedActions[slot] = nil
        end
    end
    
    -- Update action bar display
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllSideBarButtons then
        ConsoleUI.actionbars:UpdateAllSideBarButtons()
    end
    
    -- Update config dropdowns if open
    if ConsoleUI.config and ConsoleUI.config.bindingDropdowns then
        for i = (maxButtons + 1), 5 do
            local slot = startSlot + i - 1
            local dropdown = ConsoleUI.config.bindingDropdowns[slot]
            if dropdown then
                UIDropDownMenu_SetSelectedValue(dropdown, nil)
                local noneText = "None (Action Bar)"
                if Locale and Locale.T then
                    noneText = Locale.T("None (Action Bar)")
                end
                UIDropDownMenu_SetText(noneText, dropdown)
            end
        end
    end
end

-- Release proxied actions for a disabled sidebar
-- side: "left" or "right"
function Proxied:ReleaseSidebarAllBindings(side)
    self:ReleaseSidebarBindings(side, 0)
end

-- ============================================================================
-- Binding Application
-- ============================================================================

-- Apply binding for a single slot
function Proxied:ApplySlotBinding(slot)
    -- Sidebar slots (41-50) don't use keyboard bindings - they're click-activated
    -- We just need to update the sidebar button display
    if self:IsSidebarSlot(slot) then
        ConsoleUI_Debug("Proxied: Sidebar slot " .. slot .. " binding updated (click-activated)")
        -- Update sidebar button display
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllSideBarButtons then
            ConsoleUI.actionbars:UpdateAllSideBarButtons()
        end
        return
    end
    
    local key = self:GetKeyForSlot(slot)
    if not key then return end
    
    local bindingID = self:GetSlotBinding(slot)
    
    -- Target action to bind
    local targetAction = bindingID or ("ConsoleUI_ACTION_" .. slot)
    
    -- Debug output
    local currentBinding = GetBindingAction(key)
    ConsoleUI_Debug("Proxied: ApplySlotBinding slot=" .. slot .. " key=" .. key .. " bindingID=" .. tostring(bindingID) .. " currentBinding=" .. tostring(currentBinding) .. " targetAction=" .. targetAction)
    
    -- Check if cursor mode is active
    local cursorModeActive = false
    if ConsoleUI.cursor and ConsoleUI.cursor.keybindings then
        cursorModeActive = ConsoleUI.cursor.keybindings.cursorModeActive
    end
    
    -- Check if this key is managed by cursor mode (keys 1-8 are used for cursor navigation)
    -- Modifier keys (SHIFT-X, CTRL-X, etc.) are NOT managed by cursor mode
    local isCursorManagedKey = (slot >= 1 and slot <= 8)
    
    if cursorModeActive and isCursorManagedKey then
        -- For keys 1-8 during cursor mode: update the table RestoreOriginalBindings reads.
        -- The binding is applied when cursor mode exits via ApplyAllBindings().
        local cursorKeys = ConsoleUI.cursor.keybindings
        if key == "5" or key == "6" or key == "7" or key == "8" then
            if not cursorKeys.originalDPadBindings then
                cursorKeys.originalDPadBindings = {}
            end
            cursorKeys.originalDPadBindings[key] = targetAction
        end
        ConsoleUI_Debug("Proxied: Updated cursor original binding for " .. key .. " to " .. targetAction .. " (will apply when cursor mode exits)")
        
        -- Also update buttonBindings if we're currently on a button
        -- This ensures the binding is updated for the current button context
        if cursorKeys.currentButton then
            local buttonName = cursorKeys.currentButton:GetName() or tostring(cursorKeys.currentButton)
            if cursorKeys.buttonBindings and cursorKeys.buttonBindings[buttonName] then
                cursorKeys.buttonBindings[buttonName][key] = targetAction
                ConsoleUI_Debug("Proxied: Updated button binding for " .. buttonName .. " key " .. key .. " to " .. targetAction)
            end
        end
        
        -- IMPORTANT: Even during cursor mode, we must clear the old proxied binding immediately
        -- Otherwise the old action (like JUMP) will still be active
        -- We can't set the new binding yet (cursor mode needs the key), but we can clear the old one
        local currentBinding = GetBindingAction(key)
        if currentBinding and currentBinding ~= targetAction and not string.find(currentBinding, "^ConsoleUI_CURSOR") then
            ConsoleUI_Debug("Proxied: Clearing old binding " .. currentBinding .. " from " .. key .. " during cursor mode")
            SetBinding(key, nil)
        end
    else
        -- For modifier keys (slots 9-40) OR when cursor mode is not active:
        -- Apply the binding immediately via SetBinding
        
        -- First, clear any existing binding on this key
        if currentBinding then
            ConsoleUI_Debug("Proxied: Clearing existing binding " .. currentBinding .. " from " .. key)
            SetBinding(key, nil)
            -- Verify it was cleared
            local verifyCleared = GetBindingAction(key)
            if verifyCleared then
                ConsoleUI_Debug("Proxied: WARNING - Key " .. key .. " still bound to " .. verifyCleared .. " after clear, trying again")
                SetBinding(key, nil)
            end
        end
        
        -- Now set the new binding
        SetBinding(key, targetAction)
        
        -- Verify the binding was set by checking what action this key is now bound to
        local verifyAction = GetBindingAction(key)
        if verifyAction == targetAction then
            ConsoleUI_Debug("Proxied: Successfully set " .. key .. " to " .. targetAction .. " (verified)")
        elseif verifyAction then
            ConsoleUI_Debug("Proxied: WARNING - " .. key .. " is bound to " .. verifyAction .. " instead of " .. targetAction .. ", forcing correct binding")
            -- Force the correct binding
            SetBinding(key, nil)
            SetBinding(key, targetAction)
            verifyAction = GetBindingAction(key)
            if verifyAction == targetAction then
                ConsoleUI_Debug("Proxied: Successfully forced binding to " .. targetAction)
            else
                ConsoleUI_Debug("Proxied: ERROR - Failed to set binding after force, still bound to " .. tostring(verifyAction))
            end
        else
            ConsoleUI_Debug("Proxied: WARNING - " .. key .. " has no binding after SetBinding call")
        end
    end
end

-- Apply all proxied bindings
function Proxied:ApplyAllBindings()
    ConsoleUI_Debug("Proxied: Applying all bindings...")
    
    -- Only apply bindings for slots that have proxied actions
    -- Non-proxied slots keep their existing WoW binding settings
    -- (ConsoleUI_ACTION_X from initial setup, or user customizations from Blizzard UI)
    if ConsoleUIDB and ConsoleUIDB.proxiedActions then
        for slot, bindingID in pairs(ConsoleUIDB.proxiedActions) do
            self:ApplySlotBinding(slot)
        end
    end
    
    ConsoleUI_SaveBindings()
    
    -- Update sidebar buttons (slots 41-50 are click-activated, not key-bound)
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllSideBarButtons then
        ConsoleUI.actionbars:UpdateAllSideBarButtons()
    end
    
    ConsoleUI_Debug("Proxied: All bindings applied and saved")
end

-- ============================================================================
-- Initialization
-- ============================================================================

function Proxied:Initialize()
    -- Initialize DB if needed
    if not ConsoleUIDB then
        ConsoleUIDB = {}
    end
    if not ConsoleUIDB.proxiedActions then
        ConsoleUIDB.proxiedActions = {}
    end
    
    -- Check if this is a fresh install by checking if the initialized flag exists
    -- This flag is set the first time Initialize runs, so we only set defaults once
    local isFreshInstall = (ConsoleUIDB.proxiedActionsInitialized ~= true)
    
    -- Migrate from old useAForJump setting
    if ConsoleUIDB.config and ConsoleUIDB.config.useAForJump then
        -- If useAForJump was enabled, set slot 1 to JUMP (only if not already set)
        if ConsoleUIDB.proxiedActions[1] == nil then
            ConsoleUIDB.proxiedActions[1] = "JUMP"
            ConsoleUI_Debug("Proxied: Migrated useAForJump to proxied action JUMP on slot 1")
        end
    end
    
    -- Fresh install: do not touch 1-0 / M / ESCAPE.
    -- Interact on LB+RT (CTRL-0) is a modifier chord; claim only if free.
    if isFreshInstall then
        if ConsoleUI_CanClaimKey and ConsoleUI_CanClaimKey("CTRL-0") then
            ConsoleUIDB.proxiedActions[30] = "ConsoleUI_INTERACT"
            ConsoleUI_Debug("Proxied: Set default ConsoleUI_INTERACT on CTRL-0")
        end
        ConsoleUIDB.proxiedActionsInitialized = true
    end
    
    -- Apply all bindings
    self:ApplyAllBindings()
    
    ConsoleUI_Debug("Proxied actions module initialized")
end

-- ============================================================================
-- Dropdown Options Generation
-- ============================================================================

-- Generate dropdown options for a slot (used in config UI)
function Proxied:GetDropdownOptions()
    local options = {}
    
    -- First option: None (use action bar)
    table.insert(options, { text = "None (Action Bar)", value = nil })
    
    -- Add separator
    table.insert(options, { text = "---", value = "SEPARATOR", disabled = true })
    
    -- Add all actions organized by headers
    local currentHeader = nil
    for _, action in ipairs(self.ACTIONS) do
        if action.headerKey then
            currentHeader = action.headerKey
            table.insert(options, { text = "-- " .. self:GetHeaderName(action) .. " --", value = "HEADER_" .. action.headerKey, disabled = true })
        elseif action.nameKey then
            table.insert(options, { text = self:GetActionName(action), value = action.id })
        end
    end

    if ConsoleUI.rings and ConsoleUI.rings.List then
        local rings = ConsoleUI.rings:List()
        if table.getn(rings) > 0 then
            table.insert(options, { text = "-- Rings --", value = "HEADER_RINGS", disabled = true })
            local i
            for i = 1, table.getn(rings) do
                local ring = rings[i]
                table.insert(options, {
                    text = ring.name or ("Ring " .. ring.id),
                    value = ConsoleUI.rings:BindingID(ring.id),
                })
            end
        end
    end
    
    return options
end

function Proxied:RingList()
    if not ConsoleUI.rings or not ConsoleUI.rings.List then
        return nil
    end
    local rings = ConsoleUI.rings:List()
    if not rings or table.getn(rings) == 0 then
        return nil
    end
    return rings
end

function Proxied:AddRingDropdownButtons(dropdown, slot)
    local rings = self:RingList()
    if not rings then return end
    local currentValue = self:GetSlotBinding(slot)
    local header = {}
    header.text = "-- Rings --"
    header.disabled = 1
    header.notCheckable = 1
    UIDropDownMenu_AddButton(header)
    local i
    for i = 1, table.getn(rings) do
        local ring = rings[i]
        local actionId = ConsoleUI.rings:BindingID(ring.id)
        local actionName = ring.name or ("Ring " .. ring.id)
        local info = {}
        info.text = actionName
        info.value = actionId
        info.func = function()
            self:SetSlotBinding(slot, actionId)
            UIDropDownMenu_SetSelectedValue(dropdown, actionId)
            UIDropDownMenu_SetText(actionName, dropdown)
        end
        if currentValue == actionId then
            info.checked = 1
        end
        UIDropDownMenu_AddButton(info)
    end
end

-- 1.12 UIDropDownMenu only creates 32 buttons. None + 8 rings + all
-- proxied rows overflow; drop Combat, then Camera, until it fits.
function Proxied:FillSlotDropdown(dropdown, slot)
    local currentValue = self:GetSlotBinding(slot)
    local info = {}
    info.text = L("None (Action Bar)")
    info.value = nil
    info.func = function()
        self:SetSlotBinding(slot, nil)
        UIDropDownMenu_SetSelectedValue(dropdown, nil)
        UIDropDownMenu_SetText(L("None (Action Bar)"), dropdown)
    end
    if currentValue == nil then
        info.checked = 1
    end
    UIDropDownMenu_AddButton(info)

    local used = 1
    local rings = self:RingList()
    local ringRows = 0
    if rings then
        ringRows = 1 + table.getn(rings)
    end
    local actionRows = table.getn(self.ACTIONS)
    local skip = {}
    -- ponytail: Combat is 4 rows, Camera is 3. Recount if those sections change.
    if used + ringRows + actionRows > 32 then
        skip["Combat"] = true
        actionRows = actionRows - 4
    end
    if used + ringRows + actionRows > 32 then
        skip["Camera"] = true
        actionRows = actionRows - 3
    end

    if rings then
        self:AddRingDropdownButtons(dropdown, slot)
    end

    local headerKey = nil
    local i
    for i = 1, table.getn(self.ACTIONS) do
        local action = self.ACTIONS[i]
        if action.headerKey then
            headerKey = action.headerKey
            if not skip[headerKey] then
                info = {}
                info.text = "-- " .. self:GetHeaderName(action) .. " --"
                info.disabled = 1
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info)
            end
        elseif action.nameKey then
            if not skip[headerKey] or action.id == currentValue then
                local actionId = action.id
                local actionName = self:GetActionName(action)
                info = {}
                info.text = actionName
                info.value = actionId
                info.func = function()
                    self:SetSlotBinding(slot, actionId)
                    UIDropDownMenu_SetSelectedValue(dropdown, actionId)
                    UIDropDownMenu_SetText(actionName, dropdown)
                end
                if currentValue == actionId then
                    info.checked = 1
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end

ConsoleUI_Debug("Proxied actions module loaded")
