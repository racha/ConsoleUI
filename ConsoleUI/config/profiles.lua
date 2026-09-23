--[[
    ConsoleUI character profiles.

    V2 stores one account-visible profile per character so other characters can
    copy it. ConsoleUIDB remains per-character and is never deleted; RC6 profile
    tables are retained as a rollback copy and imported as legacy templates.
]]

ConsoleUI.profiles = ConsoleUI.profiles or {}
local Profiles = ConsoleUI.profiles

Profiles.SCHEMA_VERSION = 2
Profiles.MAX_ACTION_SLOTS = 120
Profiles.SAVE_DELAY = 0.75
Profiles.RESTORE_DELAY = 0.05
Profiles.DEFAULT_PROFILE_NAME = "Default" -- legacy API compatibility

local CONFIG_METADATA = {
    onboardingSeen = true,
    changelogSeenVersion = true,
    barSizeV2 = true,
    watchBarV2 = true,
    castBarThinV1 = true,
    castBarCPV1 = true,
    castBarSlimV1 = true,
    extraBarScaleV1 = true,
    extraBarScaleV2 = true,
}

local function DeepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    local key, child
    for key, child in pairs(value) do
        out[DeepCopy(key, seen)] = DeepCopy(child, seen)
    end
    return out
end

Profiles.DeepCopy = DeepCopy

local function CountKeys(tbl)
    if not tbl then return 0 end
    local count = 0
    local _
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function Profiles:CountTableKeys(tbl) return CountKeys(tbl) end

local function Now()
    if time then return time() end
    return 0
end

local function Trim(text)
    return string.gsub(text or "", "^%s*(.-)%s*$", "%1")
end

local function BaseSpellName(name)
    if not name then return nil end
    return string.gsub(name, " %(Rank %d+%)", "")
end

local function ParseItemID(link)
    if not link then return nil end
    local _, _, id = string.find(link, "item:(%d+)")
    return id and tonumber(id) or nil
end

local function CharacterIdentity()
    local name = UnitName and UnitName("player") or nil
    if not name or name == "" then name = "Unknown" end
    local realm = GetRealmName and GetRealmName() or nil
    if not realm or realm == "" then realm = "Unknown Realm" end
    local className, classToken
    if UnitClass then className, classToken = UnitClass("player") end
    local key = realm .. "/" .. name
    return key, name, realm, classToken or className or "UNKNOWN"
end

local function ProfileLabel(name, realm)
    return tostring(name or "Unknown") .. " - " .. tostring(realm or "Unknown Realm")
end

function Profiles:EnsureAccountDB()
    ConsoleUIProfileDB = ConsoleUIProfileDB or {}
    ConsoleUIProfileDB.schemaVersion = self.SCHEMA_VERSION
    ConsoleUIProfileDB.characters = ConsoleUIProfileDB.characters or {}
    ConsoleUIProfileDB.templates = ConsoleUIProfileDB.templates or {}
    ConsoleUIProfileDB.legacyBackups = ConsoleUIProfileDB.legacyBackups or {}
    ConsoleUIProfileDB.migratedCharacters = ConsoleUIProfileDB.migratedCharacters or {}
    ConsoleUIProfileDB.backups = ConsoleUIProfileDB.backups or {}
    return ConsoleUIProfileDB
end

function Profiles:GetCurrentProfileKey()
    if ConsoleUIDB and ConsoleUIDB.profileKey then return ConsoleUIDB.profileKey end
    local key = CharacterIdentity()
    return key
end

function Profiles:GetCurrentProfile()
    return self:EnsureAccountDB().characters[self:GetCurrentProfileKey()]
end

function Profiles:GetCurrentProfileName()
    local profile = self:GetCurrentProfile()
    if profile and profile.displayName then return profile.displayName end
    local _, name, realm = CharacterIdentity()
    return ProfileLabel(name, realm)
end

function Profiles:GetProfile(keyOrName)
    if not keyOrName then return nil end
    local db = self:EnsureAccountDB()
    if db.characters[keyOrName] then return db.characters[keyOrName] end
    if db.templates[keyOrName] then return db.templates[keyOrName] end
    local _, profile
    for _, profile in pairs(db.characters) do
        if profile.displayName == keyOrName then return profile end
    end
    for _, profile in pairs(db.templates) do
        if profile.displayName == keyOrName or profile.legacyName == keyOrName then return profile end
    end
    return nil
end

function Profiles:GetProfileKey(profile)
    if not profile then return nil end
    local db = self:EnsureAccountDB()
    local key, candidate
    for key, candidate in pairs(db.characters) do if candidate == profile then return key end end
    for key, candidate in pairs(db.templates) do if candidate == profile then return key end end
    return nil
end

function Profiles:ListCopySources()
    local db = self:EnsureAccountDB()
    local currentKey = self:GetCurrentProfileKey()
    local out = {}
    local key, profile
    for key, profile in pairs(db.characters) do
        if key ~= currentKey then
            table.insert(out, { key = key, label = profile.displayName or key, class = profile.class, legacy = false })
        end
    end
    for key, profile in pairs(db.templates) do
        table.insert(out, {
            key = key,
            label = profile.displayName or profile.legacyName or key,
            class = profile.class,
            legacy = true,
        })
    end
    table.sort(out, function(a, b) return tostring(a.label) < tostring(b.label) end)
    return out
end

function Profiles:ListProfiles()
    local out = { self:GetCurrentProfileName() }
    local sources = self:ListCopySources()
    local i
    for i = 1, table.getn(sources) do table.insert(out, sources[i].label) end
    return out
end

local function CopyProfileConfig(source)
    local out = {}
    local key, value
    for key, value in pairs(source or {}) do
        if not CONFIG_METADATA[key] then out[key] = DeepCopy(value) end
    end
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        for key, value in pairs(ConsoleUI.config.DEFAULTS) do
            if out[key] == nil then out[key] = DeepCopy(value) end
        end
    end
    return out
end

local function CaptureKeyboard()
    if not ConsoleUIKeyboardDB and not ConsoleUIKeyboardLayout then return nil end
    return {
        settings = DeepCopy(ConsoleUIKeyboardDB or {}),
        layout = DeepCopy(ConsoleUIKeyboardLayout),
    }
end

local function ApplyKeyboard(data)
    if not data then return end
    ConsoleUIKeyboardDB = DeepCopy(data.settings or {})
    if data.layout then ConsoleUIKeyboardLayout = DeepCopy(data.layout) end
    if ConsoleUIKeyboard then
        if ConsoleUIKeyboard.SetEnabled then ConsoleUIKeyboard:SetEnabled(not ConsoleUIKeyboardDB.disabled) end
        if ConsoleUIKeyboard.SetShowFor then ConsoleUIKeyboard:SetShowFor(ConsoleUIKeyboardDB.showFor) end
        if ConsoleUIKeyboard.SetLayout then ConsoleUIKeyboard:SetLayout() end
    end
end

local function ReadActionTooltip(slot)
    local name, rank
    if not GameTooltip then return nil, nil end
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:SetAction(slot)
    local left = getglobal("GameTooltipTextLeft1")
    local right = getglobal("GameTooltipTextRight1")
    if left and left.GetText then name = left:GetText() end
    if right and right.GetText then rank = right:GetText() end
    if not rank or rank == "" then
        local second = getglobal("GameTooltipTextLeft2")
        local value = second and second.GetText and second:GetText()
        if value and string.find(value, "Rank", 1, true) then rank = value end
    end
    GameTooltip:Hide()
    return name, rank
end

local function FindMacro(name, body, legacyID)
    local nameFallback = nil
    local i
    for i = 1, 36 do
        local macroName, texture, macroBody = GetMacroInfo(i)
        if macroName and name and macroName == name then
            if body and macroBody == body then return i, texture, macroBody end
            if not nameFallback then nameFallback = i end
        end
    end
    if nameFallback then
        local _, texture, macroBody = GetMacroInfo(nameFallback)
        return nameFallback, texture, macroBody
    end
    if legacyID then
        local macroName, texture, macroBody = GetMacroInfo(legacyID)
        if macroName and (not name or macroName == name) then return legacyID, texture, macroBody end
    end
    return nil
end

local function FindSpell(name, rank, texture, legacyID)
    if not GetSpellName then return nil, nil end
    local wanted = BaseSpellName(name)
    local best, bestRank, bestScore = nil, nil, -1
    local i = 1
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then break end
        if BaseSpellName(spellName) == wanted then
            local spellTexture = GetSpellTexture and GetSpellTexture(i, BOOKTYPE_SPELL)
            local score = 1
            if texture and spellTexture == texture then score = score + 2 end
            if rank and rank ~= "" and spellRank == rank then score = score + 4 end
            if score >= bestScore then best, bestRank, bestScore = i, spellRank, score end
        end
        i = i + 1
    end
    if best then return best, bestRank end
    if legacyID then
        local spellName, spellRank = GetSpellName(legacyID, BOOKTYPE_SPELL)
        if spellName and (not wanted or BaseSpellName(spellName) == wanted) then return legacyID, spellRank end
    end
    return nil, nil
end

local function FindItem(itemID, name)
    local function Matches(link)
        if not link then return false end
        if itemID and ParseItemID(link) == tonumber(itemID) then return true end
        if name and string.find(link, "[" .. name .. "]", 1, true) then return true end
        return false
    end
    local bag
    for bag = 0, 4 do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        local slot
        for slot = 1, slots do
            local link = GetContainerItemLink and GetContainerItemLink(bag, slot)
            if Matches(link) then return "bag", bag, slot, link end
        end
    end
    local inv
    for inv = 0, 19 do
        local link = GetInventoryItemLink and GetInventoryItemLink("player", inv)
        if Matches(link) then return "inventory", inv, nil, link end
    end
    return nil
end

local function PickupItem(itemID, name)
    local kind, a, b = FindItem(itemID, name)
    if kind == "bag" then PickupContainerItem(a, b); return true end
    if kind == "inventory" then PickupInventoryItem(a); return true end
    return false
end

function Profiles:SaveActionBars()
    local actionBars = {}
    if not HasAction or not GameTooltip then return actionBars end
    local currentProfile = self:GetCurrentProfile()
    local previous = currentProfile and currentProfile.actionBars or {}
    self.capturingActionBars = true
    local slot
    for slot = 1, self.MAX_ACTION_SLOTS do
        if HasAction(slot) then
            local texture = GetActionTexture and GetActionTexture(slot)
            local actionName, tooltipRank = ReadActionTooltip(slot)
            local macroName = GetActionText and GetActionText(slot)
            if macroName and macroName ~= "" then
                local macroID, macroTexture, macroBody = FindMacro(macroName, nil, nil)
                actionBars[slot] = {
                    type = "macro", id = macroID, name = macroName,
                    body = macroBody, texture = macroTexture or texture,
                }
            else
                local spellID, spellRank = FindSpell(actionName, tooltipRank, texture, nil)
                if spellID then
                    actionBars[slot] = {
                        type = "spell", id = spellID, name = actionName,
                        rank = spellRank or tooltipRank, texture = texture,
                    }
                else
                    local itemKind, _, _, itemLink = FindItem(nil, actionName)
                    local itemAction = (IsConsumableAction and IsConsumableAction(slot))
                        or (IsEquippedAction and IsEquippedAction(slot)) or itemKind
                    if itemAction and actionName then
                        actionBars[slot] = {
                            type = "item", name = actionName,
                            itemID = ParseItemID(itemLink), link = itemLink, texture = texture,
                        }
                    else
                        local prior = previous and previous[slot]
                        if prior and prior.type ~= "unknown"
                            and ((prior.texture and prior.texture == texture)
                                or (prior.name and prior.name == actionName)) then
                            actionBars[slot] = DeepCopy(prior)
                        else
                            actionBars[slot] = { type = "unknown", name = actionName, texture = texture }
                        end
                    end
                end
            end
        end
    end
    self.capturingActionBars = false
    return actionBars
end

local function PlaceCursorAction(slot)
    PlaceAction(slot)
    ClearCursor()
    return HasAction(slot) and true or false
end

local function RestoreProfileSlot(slot, data)
    if not data then
        if HasAction(slot) then PickupAction(slot); ClearCursor() end
        return "empty"
    end
    ClearCursor()
    if data.type == "spell" then
        local spellID, actualRank = FindSpell(data.name, data.rank, data.texture, data.id)
        if not spellID then return "unresolved" end
        PickupSpell(spellID, BOOKTYPE_SPELL)
        if not PlaceCursorAction(slot) then return "unresolved" end
        if data.rank and actualRank ~= data.rank then return "fallback" end
        return "restored"
    elseif data.type == "macro" then
        local macroID = FindMacro(data.name, data.body, data.id)
        if not macroID then return "unresolved" end
        PickupMacro(macroID)
        return PlaceCursorAction(slot) and "restored" or "unresolved"
    elseif data.type == "item" then
        if not PickupItem(data.itemID or ParseItemID(data.link), data.name) then return "unresolved" end
        return PlaceCursorAction(slot) and "restored" or "unresolved"
    end
    local spellID = FindSpell(data.name, data.rank, data.texture, data.id)
    if spellID then PickupSpell(spellID, BOOKTYPE_SPELL); return PlaceCursorAction(slot) and "fallback" or "unresolved" end
    local macroID = FindMacro(data.name, data.body, data.id)
    if macroID then PickupMacro(macroID); return PlaceCursorAction(slot) and "fallback" or "unresolved" end
    if PickupItem(data.itemID or ParseItemID(data.link), data.name) then
        return PlaceCursorAction(slot) and "fallback" or "unresolved"
    end
    return "unresolved"
end

function Profiles:FinishActionBarRestore(job)
    if not job then return end
    if job.frame then job.frame:SetScript("OnUpdate", nil); job.frame:Hide() end
    self.restoreJob = nil
    self.restoring = false
    ConsoleUIDB.profileRestorePending = nil
    if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateAllButtons then ConsoleUI.actionbars:UpdateAllButtons() end
    local report = {
        restored = job.restored, cleared = job.cleared, fallback = job.fallback,
        unresolved = job.unresolved, unresolvedSlots = DeepCopy(job.unresolvedSlots),
        source = job.source,
    }
    ConsoleUIDB.profileLastRestore = report
    self:SaveCurrentProfile(false)
    ConsoleUI_Print("Profile applied: " .. job.restored .. " restored, " .. job.cleared
        .. " cleared, " .. job.fallback .. " substituted, " .. job.unresolved .. " unresolved.")
    if job.unresolved > 0 then
        ConsoleUI_Print("Unresolved slots kept their existing action: " .. table.concat(job.unresolvedSlots, ", "))
    end
    if job.onComplete then job.onComplete(report) end
end

function Profiles:LoadActionBars(actionBars, sourceLabel, onComplete)
    if self.restoreJob then return false, "An action-bar restore is already running" end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return false, "Cannot apply a profile while in combat" end
    actionBars = DeepCopy(actionBars or {})
    ConsoleUIDB.profileRestorePending = {
        actionBars = DeepCopy(actionBars),
        source = sourceLabel,
        startedAt = Now(),
    }
    local work = {}
    local slot
    for slot = 1, self.MAX_ACTION_SLOTS do
        if actionBars[slot] or HasAction(slot) then table.insert(work, { slot = slot, data = actionBars[slot] }) end
    end
    local job = {
        work = work, index = 1, elapsed = 0, pausedNotice = false,
        restored = 0, cleared = 0, fallback = 0, unresolved = 0,
        unresolvedSlots = {},
        source = sourceLabel, onComplete = onComplete,
    }
    local frame = CreateFrame("Frame")
    job.frame = frame
    self.restoreJob = job
    self.restoring = true
    frame:SetScript("OnUpdate", function()
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            if not job.pausedNotice then
                job.pausedNotice = true
                ConsoleUI_Print("Profile restore paused during combat; it will resume automatically.")
            end
            return
        end
        job.pausedNotice = false
        job.elapsed = job.elapsed + arg1
        if job.elapsed < Profiles.RESTORE_DELAY then return end
        job.elapsed = 0
        local item = job.work[job.index]
        if not item then Profiles:FinishActionBarRestore(job); return end
        local result = RestoreProfileSlot(item.slot, item.data)
        if result == "empty" then job.cleared = job.cleared + 1
        elseif result == "fallback" then job.fallback = job.fallback + 1
        elseif result == "unresolved" then
            job.unresolved = job.unresolved + 1
            table.insert(job.unresolvedSlots, item.slot)
        else job.restored = job.restored + 1 end
        job.index = job.index + 1
    end)
    frame:Show()
    if table.getn(work) == 0 then self:FinishActionBarRestore(job) end
    return true, nil
end

function Profiles:ResumePendingRestore()
    if self.restoring or not ConsoleUIDB or not ConsoleUIDB.profileRestorePending then return false end
    local pending = ConsoleUIDB.profileRestorePending
    local ok, why = self:LoadActionBars(pending.actionBars, pending.source or "interrupted profile restore")
    if not ok and why ~= "Cannot apply a profile while in combat" then
        ConsoleUI_Print("Could not resume profile restore: " .. tostring(why))
    end
    return ok
end

local function SnapshotFromLegacy(legacy, key, name, realm, classToken)
    legacy = legacy or {}
    return {
        schemaVersion = Profiles.SCHEMA_VERSION,
        key = key, name = name, realm = realm, class = classToken,
        displayName = ProfileLabel(name, realm),
        config = CopyProfileConfig((ConsoleUIDB and ConsoleUIDB.config) or legacy.config),
        proxiedActions = DeepCopy((ConsoleUIDB and ConsoleUIDB.proxiedActions) or legacy.proxiedActions or {}),
        rings = DeepCopy((ConsoleUIDB and ConsoleUIDB.rings) or legacy.rings or {}),
        actionBars = DeepCopy(legacy.actionBars or {}),
        keyboard = CaptureKeyboard(), modifiedAt = Now(),
    }
end

function Profiles:MigrateLegacyData(key, name, realm, classToken)
    local db = self:EnsureAccountDB()
    if db.migratedCharacters[key] then return false end
    db.legacyBackups[key] = db.legacyBackups[key] or DeepCopy({
        config = ConsoleUIDB.config, proxiedActions = ConsoleUIDB.proxiedActions,
        rings = ConsoleUIDB.rings, profiles = ConsoleUIDB.profiles,
        currentProfile = ConsoleUIDB.currentProfile,
    })
    local legacyCurrent = nil
    if ConsoleUIDB.profiles then
        legacyCurrent = ConsoleUIDB.profiles[ConsoleUIDB.currentProfile or self.DEFAULT_PROFILE_NAME]
        local legacyName, legacyProfile
        for legacyName, legacyProfile in pairs(ConsoleUIDB.profiles) do
            local templateKey = key .. "/legacy/" .. tostring(legacyName)
            if not db.templates[templateKey] then
                local template = SnapshotFromLegacy(legacyProfile, templateKey, name, realm, classToken)
                template.config = CopyProfileConfig(legacyProfile.config)
                template.proxiedActions = DeepCopy(legacyProfile.proxiedActions or {})
                template.rings = DeepCopy(legacyProfile.rings or {})
                template.actionBars = DeepCopy(legacyProfile.actionBars or {})
                template.legacyName = legacyName
                template.displayName = ProfileLabel(name, realm) .. " / " .. tostring(legacyName) .. " (legacy)"
                template.isTemplate = true
                db.templates[templateKey] = template
            end
        end
    end
    if not db.characters[key] then
        local profile = SnapshotFromLegacy(legacyCurrent, key, name, realm, classToken)
        if HasAction and GameTooltip then
            local captured = self:SaveActionBars()
            if CountKeys(captured) > 0 or CountKeys(profile.actionBars) == 0 then profile.actionBars = captured end
        end
        db.characters[key] = profile
    end
    db.migratedCharacters[key] = true
    ConsoleUIDB.profileMigrationV2 = true
    ConsoleUI_Debug("Profiles: preserved RC6 data and migrated " .. key .. " to character profile V2")
    return true
end

function Profiles:ApplyLiveData(profile)
    if not profile then return false end
    ConsoleUIDB = ConsoleUIDB or {}
    local metadata = {}
    local key, value
    for key, value in pairs(ConsoleUIDB.config or {}) do if CONFIG_METADATA[key] then metadata[key] = value end end
    local config = CopyProfileConfig(profile.config)
    for key, value in pairs(metadata) do config[key] = value end
    ConsoleUIDB.config = config
    ConsoleUIDB.proxiedActions = DeepCopy(profile.proxiedActions or {})
    ConsoleUIDB.rings = DeepCopy(profile.rings or {})
    ApplyKeyboard(profile.keyboard)
    return true
end

function Profiles:ApplySettingsAndBindings()
    local cfg = ConsoleUI.config
    if cfg then
        if cfg.RefreshSettingInputs then cfg:RefreshSettingInputs() end
        ConsoleUI_DEBUG_KEYS = ConsoleUIDB.config and ConsoleUIDB.config.debugEnabled
        if cfg.UpdateCrosshair then cfg:UpdateCrosshair() end
        if cfg.UpdateActionBarLayout then cfg:UpdateActionBarLayout() end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.UpdateSideBars then ConsoleUI.actionbars:UpdateSideBars() end
        if ConsoleUI.xpbar and ConsoleUI.xpbar.UpdateAllBars then ConsoleUI.xpbar:UpdateAllBars() end
        if ConsoleUI.castbar and ConsoleUI.castbar.ReloadConfig then ConsoleUI.castbar:ReloadConfig() end
        if ConsoleUI.swingbar and ConsoleUI.swingbar.ReloadConfig then ConsoleUI.swingbar:ReloadConfig() end
        if ConsoleUI.loot and ConsoleUI.loot.ApplyEnabled then ConsoleUI.loot:ApplyEnabled() end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.extra and ConsoleUI.actionbars.extra.Update then ConsoleUI.actionbars.extra:Update() end
        if ConsoleUI.cursor and ConsoleUI.cursor.hintbar and ConsoleUI.cursor.hintbar.Refresh then ConsoleUI.cursor.hintbar:Refresh() end
        if cfg.ApplyHudBorderChrome then cfg:ApplyHudBorderChrome() end
        if ConsoleUI.actionbars and ConsoleUI.actionbars.ApplyDefaultBarVisibility then ConsoleUI.actionbars:ApplyDefaultBarVisibility() end
        if cfg.ApplyUnitFrameScales then cfg:ApplyUnitFrameScales() end
        if cfg.QueueUnitFrameLayout then cfg:QueueUnitFrameLayout() end
        if ConsoleUI.mouselook and ConsoleUI.mouselook.ApplySettings then ConsoleUI.mouselook:ApplySettings() end
        if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.ApplyPromptVisibility then
            ConsoleUI.cursor.tooltip:ApplyPromptVisibility()
        end
        if cfg.RefreshBindingWorkspace then cfg:RefreshBindingWorkspace() end
        if cfg.frame and cfg.frame:IsVisible() and cfg.currentSection then cfg:ShowSection(cfg.currentSection) end
    end
    if ConsoleUI.proxied and ConsoleUI.proxied.ApplyAllBindings then ConsoleUI.proxied:ApplyAllBindings() end
    if ConsoleUI.keybindings and ConsoleUI.keybindings.RepairPadGameplay then ConsoleUI.keybindings:RepairPadGameplay() end
end

function Profiles:SaveCurrentProfile(includeActionBars)
    local profile = self:GetCurrentProfile()
    if not profile then return false end
    profile.config = CopyProfileConfig(ConsoleUIDB.config or {})
    profile.proxiedActions = DeepCopy(ConsoleUIDB.proxiedActions or {})
    if ConsoleUI.rings and ConsoleUI.rings.CopyAll then profile.rings = ConsoleUI.rings:CopyAll()
    else profile.rings = DeepCopy(ConsoleUIDB.rings or {}) end
    profile.keyboard = CaptureKeyboard() or profile.keyboard
    if includeActionBars == nil then includeActionBars = true end
    if includeActionBars and not self.restoring then profile.actionBars = self:SaveActionBars() end
    profile.modifiedAt = Now()
    self.dirty = false
    self.dirtyActionBars = false
    return true
end

function Profiles:MarkDirty(actionBars)
    if self.restoring then return end
    self.dirty = true
    if actionBars then self.dirtyActionBars = true end
    self.saveElapsed = 0
end

function Profiles:CopyFrom(sourceKey)
    if self.restoring then return false, "A profile restore is already running" end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return false, "Cannot copy a profile while in combat" end
    local source = self:GetProfile(sourceKey)
    if not source then return false, "Profile not found" end
    local current = self:GetCurrentProfile()
    if source == current then return false, "That is already this character's profile" end
    self:SaveCurrentProfile(true)
    local db = self:EnsureAccountDB()
    local currentKey = self:GetCurrentProfileKey()
    local backup = DeepCopy(current)
    backup.backedUpAt = Now()
    local backupSet = db.backups[currentKey]
    if backupSet and backupSet.config then
        backupSet = { history = { DeepCopy(backupSet) } }
    end
    if not backupSet or not backupSet.history then backupSet = { history = {} } end
    table.insert(backupSet.history, backup)
    backupSet.latest = DeepCopy(backup)
    db.backups[currentKey] = backupSet
    local copied = DeepCopy(source)
    current.config = CopyProfileConfig(copied.config)
    current.proxiedActions = DeepCopy(copied.proxiedActions or {})
    current.rings = DeepCopy(copied.rings or {})
    current.actionBars = DeepCopy(copied.actionBars or {})
    current.keyboard = DeepCopy(copied.keyboard)
    current.copiedFrom = copied.displayName or sourceKey
    current.modifiedAt = Now()
    self:ApplyLiveData(current)
    self:ApplySettingsAndBindings()
    if current.class and source.class and current.class ~= source.class then
        ConsoleUI_Print("Different-class profile: unavailable spells will be reported and existing actions kept.")
    end
    if ConsoleUI.proxied and ConsoleUI.proxied.ReportInvalidTouchAssignments then
        ConsoleUI.proxied:ReportInvalidTouchAssignments(true)
    end
    local ok, why = self:LoadActionBars(current.actionBars, current.copiedFrom)
    if not ok then
        db.characters[currentKey] = backup
        self:ApplyLiveData(db.characters[currentKey])
        self:ApplySettingsAndBindings()
        return false, why
    end
    return true, nil
end

function Profiles:SetProfile(profileName)
    local profile = self:GetProfile(profileName)
    if not profile then return false, "Profile not found" end
    if profile == self:GetCurrentProfile() then return true, nil end
    return self:CopyFrom(self:GetProfileKey(profile) or profileName)
end

function Profiles:LoadProfile(profileName) return self:SetProfile(profileName) end

-- Legacy popup compatibility: create/delete account templates, never character profiles.
function Profiles:CreateProfile(name, sourceName)
    name = Trim(name)
    if name == "" then return false, "Profile name cannot be empty" end
    local db = self:EnsureAccountDB()
    local key = "template/" .. self:GetCurrentProfileKey() .. "/" .. name
    if db.templates[key] then return false, "Profile already exists" end
    local source = sourceName and self:GetProfile(sourceName) or nil
    local data
    if source then data = DeepCopy(source)
    else
        data = {
            config = CopyProfileConfig({}), proxiedActions = { [30] = "ConsoleUI_INTERACT" },
            rings = {}, actionBars = {}, keyboard = CaptureKeyboard(),
        }
    end
    data.key = key
    data.legacyName = name
    data.displayName = name .. " (template)"
    data.isTemplate = true
    data.modifiedAt = Now()
    db.templates[key] = data
    return true, nil
end

function Profiles:DeleteProfile(name)
    local profile = self:GetProfile(name)
    if not profile or not profile.isTemplate then return false, "Character profiles cannot be deleted" end
    local key = self:GetProfileKey(profile)
    self:EnsureAccountDB().templates[key] = nil
    return true, nil
end

function Profiles:Initialize()
    ConsoleUIDB = ConsoleUIDB or {}
    local key, name, realm, classToken = CharacterIdentity()
    ConsoleUIDB.profileKey = key
    self:MigrateLegacyData(key, name, realm, classToken)
    local profile = self:EnsureAccountDB().characters[key]
    if not profile then
        profile = SnapshotFromLegacy(nil, key, name, realm, classToken)
        profile.actionBars = self:SaveActionBars()
        self:EnsureAccountDB().characters[key] = profile
    end
    profile.key, profile.name, profile.realm, profile.class = key, name, realm, classToken
    profile.displayName = ProfileLabel(name, realm)
    self:ApplyLiveData(profile)
    if not self.eventFrame then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:SetScript("OnEvent", function()
            if event == "ACTIONBAR_SLOT_CHANGED" and not Profiles.restoring then Profiles:MarkDirty(true) end
            if event == "PLAYER_REGEN_ENABLED" then Profiles:ResumePendingRestore() end
        end)
        frame:SetScript("OnUpdate", function()
            if not Profiles.dirty or Profiles.restoring then return end
            Profiles.saveElapsed = (Profiles.saveElapsed or 0) + arg1
            if Profiles.saveElapsed < Profiles.SAVE_DELAY then return end
            if UnitAffectingCombat and UnitAffectingCombat("player") then return end
            Profiles:SaveCurrentProfile(Profiles.dirtyActionBars)
        end)
        self.eventFrame = frame
    end
    ConsoleUI_Debug("Profiles: active character profile " .. profile.displayName)
end

SLASH_CUIPROFILE1 = "/cuiprofile"
SLASH_CUIPROFILE2 = "/cuip"
SLASH_CUIPROFILE3 = "/ceprofile"
SLASH_CUIPROFILE4 = "/cep"
SlashCmdList["CUIPROFILE"] = function(msg)
    msg = Trim(msg)
    if msg == "" then
        ConsoleUI_Print("Character profile: " .. Profiles:GetCurrentProfileName())
        local sources = Profiles:ListCopySources()
        if table.getn(sources) == 0 then ConsoleUI_Print("No other character profiles are available yet.")
        else
            ConsoleUI_Print("Copy sources:")
            local i
            for i = 1, table.getn(sources) do ConsoleUI_Print("  - " .. sources[i].label) end
        end
        return
    end
    local profile = Profiles:GetProfile(msg)
    if not profile then ConsoleUI_Print("Profile '" .. msg .. "' not found."); return end
    local ok, why = Profiles:CopyFrom(Profiles:GetProfileKey(profile))
    if not ok then ConsoleUI_Print(why) end
end

ConsoleUI_Debug("Profiles V2 module loaded")
