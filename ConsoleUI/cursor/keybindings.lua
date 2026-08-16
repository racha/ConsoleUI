--[[
    ConsoleUI - Cursor Keybindings Module
    
    Manages dynamic key bindings when cursor mode is active
]]

-- Create cursor keybindings module namespace
ConsoleUI.cursor = ConsoleUI.cursor or {}
ConsoleUI.cursor.keybindings = ConsoleUI.cursor.keybindings or {}
local CursorKeys = ConsoleUI.cursor.keybindings

-- Default cursor control keys (matching the action bar layout)
-- D-pad keys for navigation
CursorKeys.CURSOR_CONTROLS = {
    up = "7",      -- D-pad Up
    down = "5",    -- D-pad Down
    left = "6",    -- D-pad Left
    right = "8",   -- D-pad Right
    confirm = "1", -- A button (confirm/click)
    cancel = "4",  -- B button (cancel/back)
}

-- Store original bindings to restore later
CursorKeys.originalDPadBindings = {}  -- Stores original D-pad bindings (saved once when cursor mode starts)
CursorKeys.buttonBindings = {}  -- Stores bindings per button (D-pad + actions for regular, D-pad only for healer mode)
CursorKeys.originalDPadBindingsSaved = false  -- Flag to track if we've saved original D-pad bindings
CursorKeys.currentButton = nil    -- Tracks which button we're currently on
CursorKeys.cursorModeActive = false

local FACE_GAMEPLAY = {
    ["1"] = "ConsoleUI_ACTION_1",
    ["2"] = "ConsoleUI_ACTION_2",
    ["3"] = "ConsoleUI_ACTION_3",
    ["4"] = "ConsoleUI_ACTION_4",
}

local function GameplayAction(key, action)
    if not action or action == "" then
        return action
    end
    if key ~= "1" and key ~= "2" and key ~= "3" and key ~= "4" then
        return action
    end
    if not string.find(action, "^ConsoleUI_RADIAL") and not string.find(action, "^ConsoleUI_CURSOR") then
        return action
    end
    local slot = tonumber(key)
    if slot and ConsoleUI.proxied and ConsoleUI.proxied.GetSlotBinding then
        local proxied = ConsoleUI.proxied:GetSlotBinding(slot)
        if proxied and proxied ~= "" then
            return proxied
        end
    end
    return FACE_GAMEPLAY[key] or action
end

-- ============================================================================
-- Binding Management
-- ============================================================================

function CursorKeys:SetupCursorBindings()
    -- If already active, don't save bindings again (they're already saved)
    if self.cursorModeActive then 
        ConsoleUI_Debug("Cursor bindings already active, skipping setup")
        return
    end
    
    ConsoleUI_Debug("Setting up cursor bindings...")
    
    -- Save original D-pad bindings (movement keys) - only once when cursor mode starts
    if not self.originalDPadBindingsSaved then
        self:SaveOriginalDPadBindings()
        self.originalDPadBindingsSaved = true
    end
    
    -- Mark cursor mode as active
    self.cursorModeActive = true
    self.currentButton = nil
    
    -- Apply base D-pad navigation bindings immediately so navigation works even before moving to a button
    local Tooltip = ConsoleUI.cursor.tooltip
    if Tooltip and Tooltip.GetBindings then
        -- Get default bindings (no button name = default, which includes D-pad)
        local bindings = Tooltip:GetBindings(nil)
        if bindings then
            -- Apply only D-pad bindings for now (no button yet)
            for _, binding in ipairs(bindings) do
                if binding.key and binding.action then
                    -- Only apply D-pad keys (5, 6, 7, 8)
                    local key = binding.key
                    if key == "5" or key == "6" or key == "7" or key == "8" then
                        SetBinding(key, binding.action)
                        ConsoleUI_Debug("Applied D-pad binding: Key " .. key .. " = " .. binding.action)
                    end
                end
            end
        end
    end
    
    ConsoleUI_Debug("Cursor bindings activated!")
end

-- Save original D-pad bindings (called once when cursor mode starts)
function CursorKeys:SaveOriginalDPadBindings()
    self.originalDPadBindings = {}
    
    local dPadKeys = {
        self.CURSOR_CONTROLS.up,      -- 7
        self.CURSOR_CONTROLS.down,    -- 5
        self.CURSOR_CONTROLS.left,    -- 6
        self.CURSOR_CONTROLS.right,   -- 8
    }
    
    ConsoleUI_Debug("Saving original D-pad bindings:")
    for _, key in ipairs(dPadKeys) do
        local action = GetBindingAction(key)
        if action and action ~= "" then
            self.originalDPadBindings[key] = action
            ConsoleUI_Debug("  Key " .. key .. " = " .. action)
        else
            ConsoleUI_Debug("  Key " .. key .. " = (none)")
        end
    end
    
end

-- Save current bindings for a button before applying new ones
-- For regular buttons: saves D-pad + action buttons (1, 2, 3, 4)
-- For healer mode frames: saves only D-pad (action buttons keep their original bindings)
function CursorKeys:SaveButtonBindings(button, isHealerModeFrame)
    if not button then return end
    
    local buttonName = button:GetName() or tostring(button)
    self.buttonBindings[buttonName] = {}
    
    -- Always save D-pad bindings
    local dPadKeys = {
        self.CURSOR_CONTROLS.up,      -- 7
        self.CURSOR_CONTROLS.down,    -- 5
        self.CURSOR_CONTROLS.left,    -- 6
        self.CURSOR_CONTROLS.right,   -- 8
    }
    
    ConsoleUI_Debug("Saving bindings for button: " .. buttonName .. (isHealerModeFrame and " (healer mode - D-pad only)" or ""))
    for _, key in ipairs(dPadKeys) do
        local action = GetBindingAction(key)
        if action and action ~= "" then
            self.buttonBindings[buttonName][key] = action
            ConsoleUI_Debug("  Key " .. key .. " = " .. action)
        end
    end
    
    -- For regular buttons, also save action buttons (1, 2, 3, 4)
    if not isHealerModeFrame then
        local actionKeys = {
            self.CURSOR_CONTROLS.confirm, -- 1
            "2",  -- X button
            "3",  -- Y button
            self.CURSOR_CONTROLS.cancel,  -- 4
        }
        
        for _, key in ipairs(actionKeys) do
            local action = GameplayAction(key, GetBindingAction(key))
            if action and action ~= "" then
                self.buttonBindings[buttonName][key] = action
                ConsoleUI_Debug("  Key " .. key .. " = " .. action)
            end
        end
    end
end

-- Restore bindings for a button (what was saved before applying new bindings)
function CursorKeys:RestoreButtonBindings(button)
    if not button then return end
    
    local buttonName = button:GetName() or tostring(button)
    
    if not self.buttonBindings[buttonName] then
        ConsoleUI_Debug("  No saved bindings for button: " .. buttonName)
        return
    end
    
    ConsoleUI_Debug("Restoring bindings for button: " .. buttonName)
    for key, action in pairs(self.buttonBindings[buttonName]) do
        action = GameplayAction(key, action)
        SetBinding(key, action)
        ConsoleUI_Debug("  Restored key " .. key .. " to: " .. action)
    end
    
    -- Remove from buttonBindings after restoring
    self.buttonBindings[buttonName] = nil
end


function CursorKeys:RestoreOriginalBindings()
    if not self.cursorModeActive then return end
    
    -- Restore current button's bindings first
    if self.currentButton then
        self:RestoreButtonBindings(self.currentButton)
    end
    
    -- Restore original D-pad bindings
    ConsoleUI_Debug("Restoring original D-pad bindings:")
    local dPadKeys = {
        self.CURSOR_CONTROLS.up,      -- 7
        self.CURSOR_CONTROLS.down,    -- 5
        self.CURSOR_CONTROLS.left,    -- 6
        self.CURSOR_CONTROLS.right,   -- 8
    }
    
    for _, key in ipairs(dPadKeys) do
        local originalAction = self.originalDPadBindings[key]
        if originalAction then
            SetBinding(key, originalAction)
            ConsoleUI_Debug("  Restored key " .. key .. " to: " .. originalAction)
        else
            SetBinding(key, nil)
        end
    end
    
    self.cursorModeActive = false
    self.originalDPadBindings = {}
    self.buttonBindings = {}
    self.originalDPadBindingsSaved = false
    self.currentButton = nil
    
    -- Re-apply proxied bindings after cursor nav is cleared, then persist.
    -- Saving before ApplyAllBindings wrote cursor/D-pad leftovers to the binding set.
    if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then
        ConsoleUI.proxied:ApplyAllBindings()
    else
        ConsoleUI_SaveBindings()
    end
    
    ConsoleUI_Debug("Cursor bindings deactivated")
end

function CursorKeys:IsCursorModeActive()
    return self.cursorModeActive
end

-- Apply context-specific bindings based on hovered element
-- This should be called with the button object and its bindings
function CursorKeys:ApplyContextBindings(bindings, button)
    if not self.cursorModeActive then return end
    if not bindings then return end
    if ConsoleUIKeyboard and ConsoleUIKeyboard.IsShown and ConsoleUIKeyboard:IsShown() then
        return
    end
    
    -- Check if we're already on this button - if so, don't do anything (prevents loops)
    if self.currentButton == button then
        ConsoleUI_Debug("Already on button, skipping save/restore cycle")
        return
    end
    
    -- Check if this is a party/raid/player frame (healer mode - D-pad only)
    local isHealerModeFrame = false
    if button then
        local buttonName = button:GetName() or ""
        if ConsoleUI.hooks and ConsoleUI.hooks.IsPartyRaidFrame then
            isHealerModeFrame = ConsoleUI.hooks:IsPartyRaidFrame(buttonName)
        end
    end
    
    -- Simple flow: Restore previous button's bindings -> Save current button's bindings -> Apply new bindings
    -- This works the same way for all button types (regular or healer mode)
    if self.currentButton and self.currentButton ~= button then
        -- Restore what was saved for the previous button
        self:RestoreButtonBindings(self.currentButton)
    end
    
    -- Save current button's bindings before applying new ones
    -- For healer mode frames: save only D-pad
    -- For regular buttons: save D-pad + action buttons
    if button then
        self:SaveButtonBindings(button, isHealerModeFrame)
        self.currentButton = button
    end
    
    -- Track if B button has a specific binding
    local hasBBinding = false
    
    -- Log all bindings being applied
    local buttonName = button and (button:GetName() or tostring(button)) or "unknown"
    ConsoleUI_Debug("Applying context bindings for button: " .. buttonName .. (isHealerModeFrame and " (healer mode - D-pad only)" or ""))
    for _, binding in ipairs(bindings) do
        if binding.key and binding.action then
            ConsoleUI_Debug("  Key " .. binding.key .. " = " .. binding.action)
        end
    end
    
    -- Apply bindings (filtered for healer mode frames)
    for _, binding in ipairs(bindings) do
        if binding.key and binding.action then
            -- In healer mode frames, only apply D-pad bindings (5, 6, 7, 8)
            -- Other keys (1, 2, 3, 4) keep their original actions
            if isHealerModeFrame then
                if binding.key == "5" or binding.key == "6" or binding.key == "7" or binding.key == "8" then
                    SetBinding(binding.key, binding.action)
                end
            else
                -- Normal mode - apply all bindings
                SetBinding(binding.key, binding.action)
            end
            
            if binding.key == self.CURSOR_CONTROLS.cancel then
                hasBBinding = true
            end
        end
    end
    
    -- If no B binding defined and not in healer mode, default to close frame
    -- (In healer mode, B button keeps its original action)
    if not hasBBinding and not isHealerModeFrame then
        SetBinding(self.CURSOR_CONTROLS.cancel, "ConsoleUI_CURSOR_CLOSE")
        ConsoleUI_Debug("  Key " .. self.CURSOR_CONTROLS.cancel .. " = ConsoleUI_CURSOR_CLOSE (default)")
    end
    
    -- Note: Don't SaveBindings here - too frequent, will cause lag
end

-- Module loaded silently

