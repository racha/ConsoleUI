--[[
    ConsoleUI - Auto Spell Rank Module
    
    Automatically updates action bar spells to their highest rank
    when a new spell rank is learned.
    
    Based on AutoSpellRanker addon logic.
]]

-- Create the autorank module namespace
if ConsoleUI.autorank == nil then
    ConsoleUI.autorank = {}
end

local AutoRank = ConsoleUI.autorank

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Get the highest rank spell index from spellbook for a given base spell name
-- Returns: spellIndex, rankNumber (or nil if not found)
function AutoRank:GetHighestRankSpell(spellBase)
    local i = 1
    local highestRank = 0
    local highestIndex = nil
    
    ConsoleUI_Debug("AutoRank: Searching spellbook for '" .. tostring(spellBase) .. "'")
    
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then break end
        
        -- Get the base name without rank (same as AutoSpellRanker)
        local baseName = string.gsub(spellName, " %(Rank %d+%)", "")
        
        -- Parse rank number from the spellRank return value
        local rankNum = 0
        if spellRank and type(spellRank) == "string" then
            local _, _, found = string.find(spellRank, "(%d+)")
            if found then 
                rankNum = tonumber(found) 
            end
        end
        
        -- Check if this is the spell we're looking for and has higher rank
        if baseName == spellBase then
            ConsoleUI_Debug("AutoRank: Found '" .. baseName .. "' rank " .. rankNum .. " at index " .. i)
            if rankNum > highestRank then
                highestRank = rankNum
                highestIndex = i
            end
        end
        
        i = i + 1
    end
    
    if highestIndex then
        ConsoleUI_Debug("AutoRank: Highest rank for '" .. spellBase .. "' is " .. highestRank .. " at index " .. highestIndex)
    else
        ConsoleUI_Debug("AutoRank: Spell '" .. spellBase .. "' not found in spellbook")
    end
    
    return highestIndex, highestRank
end

-- Get all tooltip lines for an action slot (same approach as AutoSpellRanker)
function AutoRank:GetTooltipLines(slot)
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:SetAction(slot)
    
    local lines = {}
    local numLines = GameTooltip:NumLines() or 0
    for i = 1, numLines do
        local leftLine = getglobal("GameTooltipTextLeft" .. i)
        if leftLine and leftLine.GetText then
            local text = leftLine:GetText()
            if text then
                table.insert(lines, text)
            end
        end
        local rightLine = getglobal("GameTooltipTextRight" .. i)
        if rightLine and rightLine.GetText then
            local text = rightLine:GetText()
            if text then
                table.insert(lines, text)
            end
        end
    end
    
    GameTooltip:Hide()
    return lines
end

-- Get spell info from an action slot using tooltip
-- Returns: spellName (base name without rank), currentRank
function AutoRank:GetActionSpellInfo(slot)
    if not HasAction(slot) then
        return nil, 0
    end
    if IsConsumableAction and IsConsumableAction(slot) then
        return nil, 0
    end
    
    -- Get all tooltip lines (same approach as AutoSpellRanker)
    local lines = self:GetTooltipLines(slot)
    local spellName = lines[1] or nil
    local currentRank = 0
    
    if spellName and type(spellName) == "string" then
        -- Check for rank embedded in spell name (e.g., "Fireball (Rank 4)")
        local _, _, embedded = string.find(spellName, "%(Rank (%d+)%)")
        if embedded then
            currentRank = tonumber(embedded)
        else
            -- Search all tooltip lines for "Rank X"
            for _, line in ipairs(lines) do
                if type(line) == "string" and string.find(line, "Rank") then
                    local _, _, found = string.find(line, "Rank (%d+)")
                    if found then
                        currentRank = tonumber(found)
                        break
                    end
                end
            end
        end
        
        -- Remove rank from spell name to get base name
        local baseName = string.gsub(spellName, " %(Rank %d+%)", "")
        
        -- Debug: show what we found
        if currentRank > 0 then
            ConsoleUI_Debug("AutoRank: Slot " .. slot .. " tooltip: '" .. spellName .. "' -> base: '" .. baseName .. "', rank: " .. currentRank)
            return baseName, currentRank
        else
            -- Show raw tooltip for debugging
            ConsoleUI_Debug("AutoRank: Slot " .. slot .. " - no rank found in: " .. table.concat(lines, " | "))
        end
    end
    
    return nil, 0
end

-- ============================================================================
-- Main Update Function
-- ============================================================================

-- Scan all action bars and update outdated spells
function AutoRank:UpdateOutdatedSpells(silent)
    local config = ConsoleUI.config
    if not config or not config:Get("autoRankEnabled") then
        ConsoleUI_Debug("AutoRank: Disabled or no config, skipping scan")
        return 0
    end

    if UnitAffectingCombat and UnitAffectingCombat("player") then
        ConsoleUI_Debug("AutoRank: skipped, player in combat")
        return 0
    end
    
    ConsoleUI_Debug("AutoRank: Starting scan of action bars...")
    
    local updatedCount = 0
    local scannedSpells = 0
    
    -- Scan all 120 action slots (main bar + all extra bars)
    for slot = 1, 120 do
        local spellName, currentRank = self:GetActionSpellInfo(slot)
        
        if spellName and currentRank > 0 then
            scannedSpells = scannedSpells + 1
            local highestIndex, highestRank = self:GetHighestRankSpell(spellName)
            
            ConsoleUI_Debug("AutoRank: Slot " .. slot .. " - " .. spellName .. " Rank " .. currentRank .. " (highest available: " .. (highestRank or "?") .. ")")
            
            if highestIndex and highestRank > currentRank then
                if UnitAffectingCombat and UnitAffectingCombat("player") then
                    ConsoleUI_Debug("AutoRank: entered combat, stopping scan")
                    return updatedCount
                end
                -- Found a higher rank - update the action bar slot
                ConsoleUI_Debug("AutoRank: Updating " .. spellName .. " from Rank " .. currentRank .. " to Rank " .. highestRank)
                
                -- Pick up the spell from spellbook
                PickupSpell(highestIndex, BOOKTYPE_SPELL)
                
                -- Place it on the action bar (this replaces the old spell)
                PlaceAction(slot)
                
                -- Clear cursor if anything remains
                ClearCursor()
                
                updatedCount = updatedCount + 1
                
                ConsoleUI_Debug("Updated " .. spellName .. " from Rank " .. currentRank .. " to Rank " .. highestRank .. " (slot " .. slot .. ")")
            end
        end
    end
    
    ConsoleUI_Debug("AutoRank: Scan complete. Scanned " .. scannedSpells .. " spells, updated " .. updatedCount)
    
    if updatedCount > 0 then
        ConsoleUI_Debug("Updated " .. updatedCount .. " spell(s) to highest rank.")
    elseif not silent then
        ConsoleUI_Debug("All spells are already at their highest ranks.")
    end
    
    return updatedCount
end

-- ============================================================================
-- Event Handling
-- ============================================================================

function AutoRank:Initialize()
    local config = ConsoleUI.config
    if not config then 
        ConsoleUI_Debug("AutoRank: No config found, cannot initialize")
        return 
    end
    
    ConsoleUI_Debug("AutoRank: Initializing module...")
    ConsoleUI_Debug("AutoRank: Auto-rank enabled = " .. tostring(config:Get("autoRankEnabled")))
    
    -- Create event frame
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        
        -- Register for spell learning events
        self.eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
        self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        
        ConsoleUI_Debug("AutoRank: Registered for LEARNED_SPELL_IN_TAB and PLAYER_ENTERING_WORLD events")
        
        self.eventFrame:SetScript("OnEvent", function()
            ConsoleUI_Debug("AutoRank: Event received - " .. event)
            
            -- Small delay to ensure spellbook is updated
            if event == "LEARNED_SPELL_IN_TAB" then
                ConsoleUI_Debug("AutoRank: New spell learned, will scan in 0.5 seconds...")
                -- Use a small delay frame to let the spellbook update
                if not AutoRank.delayFrame then
                    AutoRank.delayFrame = CreateFrame("Frame")
                    AutoRank.delayFrame.elapsed = 0
                end
                AutoRank.delayFrame.elapsed = 0
                AutoRank.delayFrame:SetScript("OnUpdate", function()
                    this.elapsed = this.elapsed + arg1
                    if this.elapsed > 0.5 then
                        this:SetScript("OnUpdate", nil)
                        ConsoleUI_Debug("AutoRank: Scanning after spell learned...")
                        AutoRank:UpdateOutdatedSpells(false)
                    end
                end)
            elseif event == "PLAYER_ENTERING_WORLD" then
                ConsoleUI_Debug("AutoRank: PLAYER_ENTERING_WORLD - checking if auto-rank is enabled")
                -- Initial scan on login (silent)
                if config:Get("autoRankEnabled") then
                    ConsoleUI_Debug("AutoRank: Auto-rank enabled, will scan in 2 seconds...")
                    -- Delay to ensure everything is loaded
                    if not AutoRank.initFrame then
                        AutoRank.initFrame = CreateFrame("Frame")
                        AutoRank.initFrame.elapsed = 0
                    end
                    AutoRank.initFrame.elapsed = 0
                    AutoRank.initFrame:SetScript("OnUpdate", function()
                        this.elapsed = this.elapsed + arg1
                        if this.elapsed > 2.0 then
                            this:SetScript("OnUpdate", nil)
                            ConsoleUI_Debug("AutoRank: Running initial login scan...")
                            local count = AutoRank:UpdateOutdatedSpells(false)
                            ConsoleUI_Debug("AutoRank: Login scan complete, updated " .. count .. " spells")
                        end
                    end)
                else
                    ConsoleUI_Debug("AutoRank: Auto-rank is disabled, skipping login scan")
                end
            end
        end)
    end
    
    -- Register slash commands
    self:RegisterSlashCommand()
    
    ConsoleUI_Debug("Module loaded. Auto-update: " .. (config:Get("autoRankEnabled") and "ON" or "OFF") .. ". Type /cuirank for commands.")
    ConsoleUI_Debug("AutoRank module initialized")
end

-- Manual trigger function (can be called from slash command or config)
function AutoRank:ManualUpdate()
    local count = self:UpdateOutdatedSpells(false)
    if count == 0 then
        ConsoleUI_Debug("All spells are already at their highest ranks.")
    end
end

-- Debug scan - shows what's on the action bars without updating
function AutoRank:DebugScan()
    ConsoleUI_Debug("Scanning action bars...")
    
    local spellCount = 0
    for slot = 1, 120 do
        if HasAction(slot) then
            local lines = self:GetTooltipLines(slot)
            local spellName = lines[1] or "???"
            
            if spellName and type(spellName) == "string" then
                -- Check for rank
                local currentRank = 0
                local _, _, embedded = string.find(spellName, "%(Rank (%d+)%)")
                if embedded then
                    currentRank = tonumber(embedded)
                else
                    for _, line in ipairs(lines) do
                        if type(line) == "string" and string.find(line, "Rank") then
                            local _, _, found = string.find(line, "Rank (%d+)")
                            if found then
                                currentRank = tonumber(found)
                                break
                            end
                        end
                    end
                end
                
                if currentRank > 0 then
                    local baseName = string.gsub(spellName, " %(Rank %d+%)", "")
                    local highestIndex, highestRank = self:GetHighestRankSpell(baseName)
                    
                    spellCount = spellCount + 1
                    local status = ""
                    if highestRank > currentRank then
                        status = "|cffff0000 OUTDATED -> Rank " .. highestRank .. "|r"
                    else
                        status = "|cff00ff00 OK|r"
                    end
                    
                    ConsoleUI_Debug("  Slot " .. slot .. ": " .. baseName .. " (Rank " .. currentRank .. ")" .. status)
                else
                    ConsoleUI_Debug("  Slot " .. slot .. ": " .. spellName .. " (no rank)")
                end
            end
        end
    end
    
    ConsoleUI_Debug("Found " .. spellCount .. " ranked spells on action bars.")
end

-- Register slash command
function AutoRank:RegisterSlashCommand()
    SLASH_CUIAUTORANK1 = "/cuirank"
    SLASH_CUIAUTORANK2 = "/autorank"
    SLASH_CUIAUTORANK3 = "/cerank"
    SlashCmdList["CUIAUTORANK"] = function(msg)
        if msg == "debug" then
            AutoRank:DebugScan()
        elseif msg == "update" then
            AutoRank:ManualUpdate()
        else
            ConsoleUI_Debug("Commands:")
            ConsoleUI_Debug("  /cuirank debug - Show all spells on action bars")
            ConsoleUI_Debug("  /cuirank update - Update outdated spells to highest rank")
        end
    end
end
