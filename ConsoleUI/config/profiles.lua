--[[
    ConsoleUI - Profiles Module
    
    Manages multiple configuration profiles per character.
    Each profile stores:
    - Complete config settings
    - Proxied action bindings
    - Action bar contents (slots 1-120)
]]

-- Create the profiles module namespace
ConsoleUI.profiles = ConsoleUI.profiles or {}
local Profiles = ConsoleUI.profiles

-- Constants
Profiles.DEFAULT_PROFILE_NAME = "Default"
Profiles.MAX_ACTION_SLOTS = 120  -- WoW 1.12 has 120 action slots total

-- ============================================================================
-- Profile Data Access
-- ============================================================================

-- Get current profile name (returns "Default" if not set)
function Profiles:GetCurrentProfileName()
    if not ConsoleUIDB or not ConsoleUIDB.currentProfile then
        return self.DEFAULT_PROFILE_NAME
    end
    return ConsoleUIDB.currentProfile
end

-- Get profile data by name
function Profiles:GetProfile(profileName)
    if not ConsoleUIDB or not ConsoleUIDB.profiles then
        return nil
    end
    return ConsoleUIDB.profiles[profileName]
end

-- Get current profile data
function Profiles:GetCurrentProfile()
    local profileName = self:GetCurrentProfileName()
    return self:GetProfile(profileName)
end

-- List all profile names
function Profiles:ListProfiles()
    if not ConsoleUIDB or not ConsoleUIDB.profiles then
        return {}
    end
    
    local profiles = {}
    for name, _ in pairs(ConsoleUIDB.profiles) do
        table.insert(profiles, name)
    end
    table.sort(profiles)  -- Sort alphabetically
    return profiles
end

-- ============================================================================
-- Action Bar Save/Load
-- ============================================================================

-- Helper: Find spell ID in spellbook by name (base name without rank)
local function FindSpellIDByName(spellName)
    if not spellName then return nil end
    
    -- Remove rank from spell name to get base name
    local baseName = string.gsub(spellName, " %(Rank %d+%)", "")
    
    -- Search spellbook
    local i = 1
    while true do
        local spellNameInBook, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellNameInBook then break end
        
        -- Get base name from spellbook
        local baseNameInBook = string.gsub(spellNameInBook, " %(Rank %d+%)", "")
        
        -- Check if names match
        if baseNameInBook == baseName then
            return i  -- Return spell index (ID)
        end
        
        i = i + 1
    end
    
    return nil
end

-- Helper: Find macro ID by name
local function FindMacroIDByName(macroName)
    if not macroName then return nil end
    
    -- Search through macros (1-36 in WoW 1.12)
    for i = 1, 36 do
        local name, texture, body = GetMacroInfo(i)
        if name and name == macroName then
            return i
        end
    end
    
    return nil
end

-- 1.12 has no item-id pickup. Find the item in bags or on the paper doll.
local function FindItemLocationByName(itemName)
    if not itemName then return nil end
    local bag
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag) or 0
        local slot
        for slot = 1, numSlots do
            local link = GetContainerItemLink(bag, slot)
            if link and string.find(link, "[" .. itemName .. "]", 1, true) then
                return "bag", bag, slot
            end
        end
    end
    local inv
    for inv = 0, 19 do
        local link = GetInventoryItemLink("player", inv)
        if link and string.find(link, "[" .. itemName .. "]", 1, true) then
            return "inv", inv, nil
        end
    end
    return nil
end

local function PickupItemByName(itemName)
    local kind, a, b = FindItemLocationByName(itemName)
    if kind == "bag" then
        PickupContainerItem(a, b)
        return true
    elseif kind == "inv" then
        PickupInventoryItem(a)
        return true
    end
    return false
end

-- Save current action bar state
-- Returns a table mapping slot -> action data
-- Note: We save ALL slots (1-120), including empty ones as nil entries
-- This ensures that when loading, we can clear slots that were previously filled
function Profiles:SaveActionBars()
    local actionBars = {}
    local profile = self:GetCurrentProfile()
    
    -- Start with existing action bars from profile (to preserve slots that might not be in current state)
    if profile and profile.actionBars then
        for slot, data in pairs(profile.actionBars) do
            actionBars[slot] = data
        end
    end
    
    -- Now update with current state - iterate through all possible action slots (1-120)
    for slot = 1, self.MAX_ACTION_SLOTS do
        if HasAction(slot) then
            -- Get texture (always available)
            local texture = GetActionTexture(slot)
            
            -- Get tooltip info to identify the action
            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            GameTooltip:ClearLines()
            GameTooltip:SetAction(slot)
            
            local actionName = nil
            local numLines = GameTooltip:NumLines() or 0
            if numLines > 0 then
                local firstLine = getglobal("GameTooltipTextLeft1")
                if firstLine and firstLine.GetText then
                    actionName = firstLine:GetText()
                end
            end
            
            GameTooltip:Hide()
            
            if actionName and texture then
                -- Try to identify as spell
                local spellID = FindSpellIDByName(actionName)
                if spellID then
                    actionBars[slot] = {
                        type = "spell",
                        id = spellID,
                        name = actionName,  -- Store name for reference
                        texture = texture,
                    }
                else
                    -- Try to identify as macro
                    local macroID = FindMacroIDByName(actionName)
                    if macroID then
                        actionBars[slot] = {
                            type = "macro",
                            id = macroID,
                            name = actionName,  -- Store name for reference
                            texture = texture,
                        }
                    else
                        local isItem = (IsConsumableAction and IsConsumableAction(slot))
                            or (IsEquippedAction and IsEquippedAction(slot))
                            or FindItemLocationByName(actionName)
                        if isItem then
                            actionBars[slot] = {
                                type = "item",
                                name = actionName,
                                texture = texture,
                            }
                        else
                            actionBars[slot] = {
                                type = "unknown",
                                name = actionName,
                                texture = texture,
                            }
                        end
                    end
                end
            end
        else
            -- Slot is empty - explicitly set to nil to clear it from profile
            actionBars[slot] = nil
        end
    end
    
    return actionBars
end

local function RestoreProfileSlot(slot, data)
    if not data then
        if HasAction(slot) then
            PickupAction(slot)
            ClearCursor()
        end
        return
    end
    if data.type == "spell" and data.id then
        PickupSpell(data.id, BOOKTYPE_SPELL)
        PlaceAction(slot)
        ClearCursor()
    elseif data.type == "macro" and data.id then
        PickupMacro(data.id)
        PlaceAction(slot)
        ClearCursor()
    elseif (data.type == "item" or data.type == "unknown") and data.name then
        local spellID = FindSpellIDByName(data.name)
        if data.type ~= "item" and spellID then
            PickupSpell(spellID, BOOKTYPE_SPELL)
            PlaceAction(slot)
            ClearCursor()
        else
            local macroID = FindMacroIDByName(data.name)
            if data.type ~= "item" and macroID then
                PickupMacro(macroID)
                PlaceAction(slot)
                ClearCursor()
            elseif PickupItemByName(data.name) then
                PlaceAction(slot)
                ClearCursor()
            elseif spellID then
                PickupSpell(spellID, BOOKTYPE_SPELL)
                PlaceAction(slot)
                ClearCursor()
            elseif macroID then
                PickupMacro(macroID)
                PlaceAction(slot)
                ClearCursor()
            end
        end
    end
end

-- Load action bar state from saved data.
-- Restore first, then clear empties. A wipe-all-first left bars empty on combat/DC.
function Profiles:LoadActionBars(actionBars)
    if UnitAffectingCombat and UnitAffectingCombat("player") then
        ConsoleUI_Print("Cannot restore action bars while in combat.")
        return
    end

    actionBars = actionBars or {}
    local work = {}
    local restoreSet = {}
    for slot, data in pairs(actionBars) do
        table.insert(work, { slot = slot, data = data })
        restoreSet[slot] = true
    end
    local slot
    for slot = 1, self.MAX_ACTION_SLOTS do
        if not restoreSet[slot] and HasAction(slot) then
            table.insert(work, { slot = slot, data = nil })
        end
    end

    if table.getn(work) == 0 then
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
        ConsoleUI_Debug("Profiles: All action bars cleared (empty profile)")
        return
    end

    local restoreFrame = CreateFrame("Frame")
    local currentIndex = 1
    local restoreDelay = 0
    local slotsCount = table.getn(work)
    restoreFrame:SetScript("OnUpdate", function()
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            restoreFrame:SetScript("OnUpdate", nil)
            restoreFrame:Hide()
            ConsoleUI_Print("Action bar restore stopped — entered combat.")
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
                ConsoleUI.actionbars:UpdateAllButtons()
            end
            return
        end

        restoreDelay = restoreDelay + arg1
        if restoreDelay < 0.1 then
            return
        end

        if currentIndex <= slotsCount then
            local item = work[currentIndex]
            RestoreProfileSlot(item.slot, item.data)
            currentIndex = currentIndex + 1
        else
            restoreFrame:SetScript("OnUpdate", nil)
            restoreFrame:Hide()
            if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
                ConsoleUI.actionbars:UpdateAllButtons()
            end
            ConsoleUI_Debug("Profiles: Action bars restored (" .. slotsCount .. " slots)")
        end
    end)
end

-- ============================================================================
-- Profile Management
-- ============================================================================

-- Create a new profile
-- sourceProfile: profile name to copy from (nil = use defaults)
function Profiles:CreateProfile(name, sourceProfile)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    -- Check if profile already exists
    if self:GetProfile(name) then
        return false, "Profile already exists"
    end
    
    -- Initialize profiles table if needed
    if not ConsoleUIDB.profiles then
        ConsoleUIDB.profiles = {}
    end
    
    local newProfile = {
        config = {},
        proxiedActions = {},
        actionBars = {},
        rings = {},
    }
    
    if sourceProfile then
        -- Clone from source profile
        local source = self:GetProfile(sourceProfile)
        if source then
            -- Deep copy config
            for key, value in pairs(source.config or {}) do
                newProfile.config[key] = value
            end
            -- Deep copy proxied actions
            for slot, binding in pairs(source.proxiedActions or {}) do
                newProfile.proxiedActions[slot] = binding
            end
            -- Deep copy action bars
            for slot, action in pairs(source.actionBars or {}) do
                newProfile.actionBars[slot] = {}
                for k, v in pairs(action) do
                    newProfile.actionBars[slot][k] = v
                end
            end
            if ConsoleUI.rings and ConsoleUI.rings.CloneData then
                newProfile.rings = ConsoleUI.rings:CloneData(source.rings)
            end
        end
    else
        -- New profile with defaults
        -- Config will be populated with defaults when loaded
        -- Action bars start empty
        -- Set default proxied actions (same as proxied.lua Initialize)
        newProfile.proxiedActions[1] = "JUMP"
        newProfile.proxiedActions[30] = "ConsoleUI_INTERACT"
        ConsoleUI_Debug("Profiles: Created new profile with default proxied actions (JUMP on slot 1, ConsoleUI_INTERACT on slot 30)")
    end
    
    ConsoleUIDB.profiles[name] = newProfile
    return true, nil
end

-- Delete a profile
function Profiles:DeleteProfile(name)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    -- Prevent deleting default profile
    if name == self.DEFAULT_PROFILE_NAME then
        return false, "Cannot delete the default profile"
    end
    
    -- Check if profile exists
    if not self:GetProfile(name) then
        return false, "Profile does not exist"
    end
    
    -- If deleting current profile, switch to default first
    if self:GetCurrentProfileName() == name then
        self:SetProfile(self.DEFAULT_PROFILE_NAME)
    end
    
    -- Delete the profile
    ConsoleUIDB.profiles[name] = nil
    
    return true, nil
end

-- Switch to a profile
function Profiles:SetProfile(profileName)
    if not profileName or profileName == "" then
        profileName = self.DEFAULT_PROFILE_NAME
    end
    
    -- Check if profile exists
    if not self:GetProfile(profileName) then
        ConsoleUI_Debug("Profiles: Profile '" .. profileName .. "' does not exist, creating it")
        self:CreateProfile(profileName, nil)
    end
    
    -- Save current state before switching (if we have a current profile)
    local currentProfileName = self:GetCurrentProfileName()
    if currentProfileName and currentProfileName ~= profileName then
        self:SaveCurrentProfile()
    end
    
    -- Set new current profile
    ConsoleUIDB.currentProfile = profileName
    
    -- Load the new profile
    self:LoadProfile(profileName)
    
    return true, nil
end

-- Save current profile state (config, proxied actions, action bars)
function Profiles:SaveCurrentProfile()
    local profileName = self:GetCurrentProfileName()
    local profile = self:GetProfile(profileName)
    
    if not profile then
        -- Create profile if it doesn't exist
        self:CreateProfile(profileName, nil)
        profile = self:GetProfile(profileName)
    end
    
    -- Save config (copy from ConsoleUIDB.config)
    if ConsoleUIDB.config then
        profile.config = {}
        for key, value in pairs(ConsoleUIDB.config) do
            profile.config[key] = value
        end
    end
    
    -- Ensure all defaults are in the profile (adds any new defaults that were added)
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        for key, defaultValue in pairs(ConsoleUI.config.DEFAULTS) do
            if profile.config[key] == nil then
                profile.config[key] = defaultValue
                ConsoleUI_Debug("Profiles: Added missing default '" .. key .. "' = " .. tostring(defaultValue) .. " to profile when saving")
            end
        end
    end
    
    -- Save proxied actions (copy from ConsoleUIDB.proxiedActions)
    if ConsoleUIDB.proxiedActions then
        profile.proxiedActions = {}
        for slot, binding in pairs(ConsoleUIDB.proxiedActions) do
            profile.proxiedActions[slot] = binding
        end
    end
    
    if ConsoleUI.rings and ConsoleUI.rings.CopyAll then
        profile.rings = ConsoleUI.rings:CopyAll()
    else
        profile.rings = {}
    end

    -- Save action bars (only saves slots that have actions)
    -- Empty slots are not saved, which is fine because LoadActionBars clears all slots first
    profile.actionBars = self:SaveActionBars()
    
    ConsoleUI_Debug("Profiles: Saved " .. (self:CountTableKeys(profile.actionBars) or 0) .. " action bar slots")
end

-- Load a profile (apply its settings)
function Profiles:LoadProfile(profileName)
    local profile = self:GetProfile(profileName)
    if not profile then
        ConsoleUI_Debug("Profiles: Profile '" .. profileName .. "' not found")
        return false
    end
    
    -- Initialize config if needed
    if not ConsoleUIDB.config then
        ConsoleUIDB.config = {}
    end
    
    -- Load config (merge with defaults)
    -- First, reset to defaults (ensures new defaults are added)
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        for key, defaultValue in pairs(ConsoleUI.config.DEFAULTS) do
            ConsoleUIDB.config[key] = defaultValue
        end
    end
    
    -- Then apply saved values from profile
    if profile.config then
        for key, value in pairs(profile.config) do
            ConsoleUIDB.config[key] = value
        end
    end
    
    -- Ensure any new defaults not in the profile are added
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        for key, defaultValue in pairs(ConsoleUI.config.DEFAULTS) do
            if ConsoleUIDB.config[key] == nil then
                ConsoleUIDB.config[key] = defaultValue
                ConsoleUI_Debug("Profiles: Added missing default config '" .. key .. "' = " .. tostring(defaultValue) .. " when loading profile")
            end
        end
    end
    
    -- Load proxied actions
    if not ConsoleUIDB.proxiedActions then
        ConsoleUIDB.proxiedActions = {}
    else
        -- Clear existing proxied actions
        for slot, _ in pairs(ConsoleUIDB.proxiedActions) do
            ConsoleUIDB.proxiedActions[slot] = nil
        end
    end
    
    if ConsoleUI.rings and ConsoleUI.rings.ReplaceAll then
        ConsoleUI.rings:ReplaceAll(profile.rings or {})
    else
        ConsoleUIDB.rings = profile.rings or {}
    end

    if profile.proxiedActions then
        for slot, binding in pairs(profile.proxiedActions) do
            ConsoleUIDB.proxiedActions[slot] = binding
            ConsoleUI_Debug("Profiles: Loaded proxied action - slot " .. slot .. " -> " .. tostring(binding))
        end
    else
        -- If profile has no proxied actions, check if it's a new profile and should have defaults
        -- (This shouldn't happen if CreateProfile sets defaults, but just in case)
        if not profile.config or next(profile.config) == nil then
            -- Looks like a new profile, set defaults
            ConsoleUIDB.proxiedActions[1] = "JUMP"
            ConsoleUIDB.proxiedActions[30] = "ConsoleUI_INTERACT"
            ConsoleUI_Debug("Profiles: Applied default proxied actions to new profile")
        end
    end
    
    -- Apply config settings immediately
    if ConsoleUI.config then
        -- Apply debug setting
        if ConsoleUIDB.config.debugEnabled ~= nil then
            ConsoleUI_DEBUG_KEYS = ConsoleUIDB.config.debugEnabled
        end
        
        -- Apply crosshair
        if ConsoleUI.config.UpdateCrosshair then
            ConsoleUI.config:UpdateCrosshair()
        end
        
        -- Apply action bar layout
        if ConsoleUI.config.UpdateActionBarLayout then
            ConsoleUI.config:UpdateActionBarLayout()
        end
        
        -- Apply sidebars (must be called after action bar layout)
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then
            ConsoleUI.actionbars:UpdateSideBars()
        end
        
        -- Apply XP/Rep bar layout
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then
            ConsoleUI.xpbar:UpdateAllBars()
        end
        
        -- Apply castbar layout
        if ConsoleUI.castbar and ConsoleUI.castbar.ReloadConfig then
            ConsoleUI.castbar:ReloadConfig()
        end
        
        -- Update sidebar binding visibility in config UI
        if ConsoleUI.config.UpdateSidebarBindingVisibility then
            ConsoleUI.config:UpdateSidebarBindingVisibility()
        end
        
        -- Refresh binding icons in config UI
        if ConsoleUI.config.RefreshBindingIcons then
            ConsoleUI.config:RefreshBindingIcons()
        end
        
        -- Refresh proxied action dropdowns in config UI
        if ConsoleUI.config.RefreshProxiedDropdowns then
            ConsoleUI.config:RefreshProxiedDropdowns()
        end
        
        -- Update all action bar buttons (to reflect proxied actions, etc.)
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then
            ConsoleUI.actionbars:UpdateAllButtons()
        end
        
        -- Refresh config UI checkboxes if config window is open
        -- We need to refresh all checkboxes to reflect the new profile values
        if ConsoleUI.config.frame and ConsoleUI.config.frame:IsVisible() then
            local currentSection = ConsoleUI.config.currentSection
            if currentSection then
                -- Small delay to ensure config values are set, then refresh checkboxes
                local refreshFrame = CreateFrame("Frame")
                refreshFrame:SetScript("OnUpdate", function()
                    refreshFrame:SetScript("OnUpdate", nil)
                    -- Refresh checkboxes in the current section
                    if ConsoleUI.config.RefreshCheckboxes then
                        local section = ConsoleUI.config.contentSections[currentSection]
                        if section then
                            ConsoleUI.config:RefreshCheckboxes(section)
                        end
                    end
                    -- Also refresh dropdowns and other UI elements by re-showing the section
                    if ConsoleUI.config.ShowSection then
                        ConsoleUI.config:ShowSection(currentSection)
                    end
                end)
            end
        end
    end
    
    -- Apply proxied bindings
    if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then
        ConsoleUI.proxied:ApplyAllBindings()
    end
    
    -- Load action bars (with delay to ensure everything else is loaded first)
    if profile.actionBars then
        -- Use a small delay before loading action bars
        local loadFrame = CreateFrame("Frame")
        loadFrame:SetScript("OnUpdate", function()
            loadFrame:SetScript("OnUpdate", nil)
            Profiles:LoadActionBars(profile.actionBars)
        end)
    end
    
    return true
end

-- ============================================================================
-- Migration from Legacy Config
-- ============================================================================

-- Migrate legacy config to profile system
function Profiles:MigrateLegacyConfig()
    -- Check if migration is needed
    if ConsoleUIDB.profiles and ConsoleUIDB.profiles[self.DEFAULT_PROFILE_NAME] then
        -- Profiles already exist, no migration needed
        return false
    end
    
    ConsoleUI_Debug("Profiles: Migrating legacy config to profile system...")
    
    -- Initialize profiles table
    if not ConsoleUIDB.profiles then
        ConsoleUIDB.profiles = {}
    end
    
    -- Create default profile
    local defaultProfile = {
        config = {},
        proxiedActions = {},
        actionBars = {},
        rings = {},
    }
    
    -- Migrate config settings
    if ConsoleUIDB.config then
        -- Copy all existing config values
        for key, value in pairs(ConsoleUIDB.config) do
            defaultProfile.config[key] = value
        end
    else
        -- Initialize with defaults if config doesn't exist
        ConsoleUIDB.config = {}
    end
    
    -- Ensure all default values are set in both places (generic migration)
    -- This automatically adds any new default values that weren't in the old config
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        for key, defaultValue in pairs(ConsoleUI.config.DEFAULTS) do
            -- Add to ConsoleUIDB.config if missing
            if ConsoleUIDB.config[key] == nil then
                ConsoleUIDB.config[key] = defaultValue
                ConsoleUI_Debug("Profiles: Added missing default config '" .. key .. "' = " .. tostring(defaultValue))
            end
            -- Add to defaultProfile.config if missing
            if defaultProfile.config[key] == nil then
                defaultProfile.config[key] = defaultValue
                ConsoleUI_Debug("Profiles: Added missing default config to profile '" .. key .. "' = " .. tostring(defaultValue))
            end
        end
    end
    
    -- Migrate proxied actions
    if ConsoleUIDB.proxiedActions then
        -- Copy all proxied actions
        for slot, binding in pairs(ConsoleUIDB.proxiedActions) do
            defaultProfile.proxiedActions[slot] = binding
            ConsoleUI_Debug("Profiles: Migrated proxied action - slot " .. slot .. " -> " .. tostring(binding))
        end
    else
        -- Initialize if it doesn't exist
        ConsoleUIDB.proxiedActions = {}
    end
    
    -- Ensure proxied actions are also preserved in ConsoleUIDB.proxiedActions
    -- (they should already be there, but make sure they're not lost)
    if ConsoleUIDB.proxiedActions and next(ConsoleUIDB.proxiedActions) == nil then
        -- If proxiedActions is empty but we have them in the profile, restore them
        if defaultProfile.proxiedActions and next(defaultProfile.proxiedActions) ~= nil then
            for slot, binding in pairs(defaultProfile.proxiedActions) do
                ConsoleUIDB.proxiedActions[slot] = binding
                ConsoleUI_Debug("Profiles: Restored proxied action to ConsoleUIDB - slot " .. slot .. " -> " .. tostring(binding))
            end
        end
    end
    
    if ConsoleUI.rings and ConsoleUI.rings.CopyAll then
        defaultProfile.rings = ConsoleUI.rings:CopyAll()
    end

    -- Save current action bar state
    defaultProfile.actionBars = self:SaveActionBars()
    
    -- Store default profile
    ConsoleUIDB.profiles[self.DEFAULT_PROFILE_NAME] = defaultProfile
    
    -- Set as current profile
    ConsoleUIDB.currentProfile = self.DEFAULT_PROFILE_NAME
    
    ConsoleUI_Debug("Profiles: Migration complete. Created default profile with:")
    ConsoleUI_Debug("  - " .. (self:CountTableKeys(defaultProfile.config) or 0) .. " config settings")
    ConsoleUI_Debug("  - " .. (self:CountTableKeys(defaultProfile.proxiedActions) or 0) .. " proxied actions")
    ConsoleUI_Debug("  - " .. (self:CountTableKeys(defaultProfile.actionBars) or 0) .. " action bar slots")
    
    -- Apply proxied bindings after migration (if proxied module is available)
    -- This ensures the bindings are actually set in the game
    if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then
        -- Small delay to ensure everything is initialized
        local applyFrame = CreateFrame("Frame")
        applyFrame:SetScript("OnUpdate", function()
            applyFrame:SetScript("OnUpdate", nil)
            ConsoleUI.proxied:ApplyAllBindings()
            ConsoleUI_Debug("Profiles: Applied proxied bindings after migration")
        end)
    end
    
    return true
end

-- Helper function to count table keys
function Profiles:CountTableKeys(tbl)
    if not tbl then return 0 end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- ============================================================================
-- Initialization
-- ============================================================================

-- Hook into action bar changes
local function OnActionBarSlotChanged()
    -- Save current profile immediately when action bars change
    if ConsoleUI.profiles and ConsoleUI.profiles.SaveCurrentProfile then
        ConsoleUI.profiles:SaveCurrentProfile()
        ConsoleUI_Debug("Profiles: Auto-saved profile after action bar change (slot " .. (arg1 or "unknown") .. ")")
    end
end

function Profiles:Initialize()
    -- Run migration first
    local migrated = self:MigrateLegacyConfig()
    
    -- Ensure current profile is set
    if not ConsoleUIDB.currentProfile then
        ConsoleUIDB.currentProfile = self.DEFAULT_PROFILE_NAME
    end
    
    -- Ensure default profile exists
    if not self:GetProfile(self.DEFAULT_PROFILE_NAME) then
        self:CreateProfile(self.DEFAULT_PROFILE_NAME, nil)
    end
    
    -- If migration happened, ensure proxied actions are synced
    if migrated then
        local defaultProfile = self:GetProfile(self.DEFAULT_PROFILE_NAME)
        if defaultProfile and defaultProfile.proxiedActions then
            -- Make sure ConsoleUIDB.proxiedActions matches the profile
            if not ConsoleUIDB.proxiedActions then
                ConsoleUIDB.proxiedActions = {}
            end
            -- Sync from profile to ConsoleUIDB
            for slot, binding in pairs(defaultProfile.proxiedActions) do
                if not ConsoleUIDB.proxiedActions[slot] or ConsoleUIDB.proxiedActions[slot] ~= binding then
                    ConsoleUIDB.proxiedActions[slot] = binding
                    ConsoleUI_Debug("Profiles: Synced proxied action from profile - slot " .. slot .. " -> " .. tostring(binding))
                end
            end
        end
    end
    
    -- Register for action bar change events to auto-save profile
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
        self.eventFrame:SetScript("OnEvent", function()
            if event == "ACTIONBAR_SLOT_CHANGED" then
                OnActionBarSlotChanged()
            end
        end)
    end
    
    ConsoleUI_Debug("Profiles: Initialized. Current profile: " .. self:GetCurrentProfileName())
end

-- ============================================================================
-- Slash Commands
-- ============================================================================

SLASH_CUIPROFILE1 = "/cuiprofile"
SLASH_CUIPROFILE2 = "/cuip"
SLASH_CUIPROFILE3 = "/ceprofile"
SLASH_CUIPROFILE4 = "/cep"
SlashCmdList["CUIPROFILE"] = function(msg)
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1")  -- Trim whitespace
    
    if msg == "" or msg == nil then
        -- Show current profile
        local currentProfile = Profiles:GetCurrentProfileName()
        ConsoleUI_Print("Current profile: " .. currentProfile)
        ConsoleUI_Print("Usage: /cuiprofile <name> or /cuip <name>")
        ConsoleUI_Print("Available profiles:")
        local profiles = Profiles:ListProfiles()
        for _, name in ipairs(profiles) do
            local marker = (name == currentProfile) and " (current)" or ""
            ConsoleUI_Print("  - " .. name .. marker)
        end
    else
        -- Switch to specified profile
        local profileName = msg
        local profile = Profiles:GetProfile(profileName)
        
        if profile then
            -- Save current profile before switching
            Profiles:SaveCurrentProfile()
            -- Switch to the profile
            Profiles:SetProfile(profileName)
            ConsoleUI_Print("Switched to profile: " .. profileName)
        else
            ConsoleUI_Print("Profile '" .. profileName .. "' not found.")
            ConsoleUI_Print("Available profiles:")
            local profiles = Profiles:ListProfiles()
            for _, name in ipairs(profiles) do
                ConsoleUI_Print("  - " .. name)
            end
        end
    end
end

ConsoleUI_Debug("Profiles module loaded")
