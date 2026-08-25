-- Mouse Look settings. All automatic unlocks except right-click default off.

ConsoleUI = ConsoleUI or {}
ConsoleUI.config = ConsoleUI.config or {}
local Config = ConsoleUI.config

function Config:CreateMouseSection()
    local content = self.frame.content
    local Locale = ConsoleUI.locale
    local T = Locale and Locale.T or function(key) return key end

    local section = CreateFrame("Frame", nil, content)
    section:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    section:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 5)
    section:Hide()

    local function AddCheck(box, label, key, tip)
        return self:CreateCheckbox(box, T(label),
            function()
                return Config:Get(key) and true or false
            end,
            function(checked)
                Config:Set(key, checked)
            end,
            T(tip))
    end

    local function AddHelp(box, anchor, text, offset, color)
        local fs = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offset or -6)
        fs:SetWidth(650)
        fs:SetJustifyH("LEFT")
        if color == "warning" then
            fs:SetTextColor(1.00, 0.82, 0.18)
        else
            fs:SetTextColor(0.545, 0.561, 0.596)
        end
        fs:SetText(T(text))
        return fs
    end

    local enableBox = self:CreateSectionBox(section, T("Mouse Look"))
    enableBox:SetPoint("TOP", section, "TOP", 0, -6)
    enableBox:SetHeight(126)
    enableBox.heightCalculated = true

    local enableCheck = AddCheck(enableBox, "Enable Mouse Look System", "mouseLookEnabled",
        "Enable ConsoleUI Mouse Look locking, automatic lock triggers, and unlock rules.")
    enableCheck:SetPoint("TOPLEFT", enableBox, "TOPLEFT", enableBox.contentLeft, enableBox.contentTop)
    local engineHelp = AddHelp(enableBox, enableCheck,
        "Locks the cursor so mouse or right-stick movement controls the camera without holding right mouse.")
    AddHelp(enableBox, engineHelp,
        "Important: while Mouse Look is locked, touch bars cannot be used until you unlock the mouse first.",
        -6, "warning")

    self:AddSectionReset(enableBox, function()
        Config:Set("mouseLookEnabled", Config.DEFAULTS.mouseLookEnabled)
        enableCheck:SetChecked(Config.DEFAULTS.mouseLookEnabled and 1 or 0)
    end)

    local lockBox = self:CreateSectionBox(section, T("Lock Mouse On"))
    lockBox:SetPoint("TOP", enableBox, "BOTTOM", 0, -8)
    lockBox:SetHeight(94)
    lockBox.heightCalculated = true

    local movementCheck = AddCheck(lockBox, "Starting to move", "mouseLookLockOnMovement",
        "Allow Mouse Look Start (Mapper), currently emitted with WASD/F9, to lock the mouse.")
    movementCheck:SetPoint("TOPLEFT", lockBox, "TOPLEFT", lockBox.contentLeft, lockBox.contentTop)
    local actionCheck = AddCheck(lockBox, "Casting spells / actions", "mouseLookLockOnActions",
        "Lock when a ConsoleUI action binding casts or uses an action.")
    actionCheck:SetPoint("TOPLEFT", lockBox, "TOPLEFT", 340, lockBox.contentTop)
    AddHelp(lockBox, movementCheck,
        "The manual Mouse Look binding and /cui look remain available whenever the system is enabled.", -8)

    self:AddSectionReset(lockBox, function()
        Config:Set("mouseLookLockOnMovement", Config.DEFAULTS.mouseLookLockOnMovement)
        Config:Set("mouseLookLockOnActions", Config.DEFAULTS.mouseLookLockOnActions)
        movementCheck:SetChecked(Config.DEFAULTS.mouseLookLockOnMovement and 1 or 0)
        actionCheck:SetChecked(Config.DEFAULTS.mouseLookLockOnActions and 1 or 0)
    end)

    local unlockBox = self:CreateSectionBox(section, T("Unlock Mouse On"))
    unlockBox:SetPoint("TOP", lockBox, "BOTTOM", 0, -8)
    unlockBox:SetHeight(206)
    unlockBox.heightCalculated = true

    local unlockOptions = {
        {"Right mouse button", "mouseLookUnlockRightClick", "Right-click or R3 unlocks Mouse Look."},
        {"Double-tap Shift / Ctrl", "mouseLookUnlockModifierDoubleTap", "Quickly double-tap Shift or Ctrl to unlock."},
        {"Escape menu", "mouseLookUnlockGameMenu", "Unlock when the Escape Game Menu opens."},
        {"Bags", "mouseLookUnlockBags", "Unlock when Blizzard or a supported bag window opens."},
        {"World map", "mouseLookUnlockWorldMap", "Unlock when the World Map or battlefield map opens."},
        {"Character / inspect", "mouseLookUnlockCharacter", "Unlock for the character, honor, inspect, and dressing windows."},
        {"Spellbook", "mouseLookUnlockSpellbook", "Unlock when the Spellbook opens."},
        {"Talents / skills", "mouseLookUnlockTalents", "Unlock when Talents or Skills opens."},
        {"Quests / gossip", "mouseLookUnlockQuests", "Unlock for the Quest Log, quest dialogs, gossip, and readable items."},
        {"Social / groups", "mouseLookUnlockSocial", "Unlock for Friends, group finder, and ready checks."},
        {"Vendors / bank / trade", "mouseLookUnlockCommerce", "Unlock for merchants, banks, mail, auctions, and trade."},
        {"Professions / trainers", "mouseLookUnlockProfessions", "Unlock for professions, crafting, trainers, and pet stables."},
        {"Other interface windows", "mouseLookUnlockOtherWindows", "Unlock for options, macros, loot, travel, popups, and other supported windows."},
    }
    local unlockChecks = {}
    local i
    for i = 1, table.getn(unlockOptions) do
        local entry = unlockOptions[i]
        local check = AddCheck(unlockBox, entry[1], entry[2], entry[3])
        local column = (i - 1) - math.floor((i - 1) / 2) * 2
        local row = math.floor((i - 1) / 2)
        check:SetPoint("TOPLEFT", unlockBox, "TOPLEFT",
            column == 0 and unlockBox.contentLeft or 340,
            unlockBox.contentTop - row * 24)
        unlockChecks[i] = check
    end

    self:AddSectionReset(unlockBox, function()
        local j
        for j = 1, table.getn(unlockOptions) do
            local entry = unlockOptions[j]
            local value = Config.DEFAULTS[entry[2]]
            Config:Set(entry[2], value)
            unlockChecks[j]:SetChecked(value and 1 or 0)
        end
    end)

    local cameraBox = self:CreateSectionBox(section, T("Camera"))
    cameraBox:SetPoint("TOP", unlockBox, "BOTTOM", 0, -8)
    cameraBox:SetHeight(98)
    cameraBox.heightCalculated = true

    local invertXCheck = AddCheck(cameraBox, "Invert X direction", "mouseLookInvertX",
        "Reverse camera look left and right when the client supports mouse yaw inversion.")
    invertXCheck:SetPoint("TOPLEFT", cameraBox, "TOPLEFT", cameraBox.contentLeft, cameraBox.contentTop)
    local invertYCheck = AddCheck(cameraBox, "Invert Y direction", "mouseLookInvertY",
        "Reverse camera look up and down.")
    invertYCheck:SetPoint("TOPLEFT", cameraBox, "TOPLEFT", 230, cameraBox.contentTop)

    local speedLabel = cameraBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    speedLabel:SetPoint("TOPLEFT", cameraBox, "TOPLEFT", 460, cameraBox.contentTop - 4)
    speedLabel:SetText(T("Mouse speed") .. ":")
    local speedBox = self:CreateEditBox(cameraBox, 56,
        function()
            return string.format("%.1f", tonumber(Config:Get("mouseLookMouseSpeed")) or 1)
        end,
        function(value)
            local speed = tonumber(value) or 1
            if speed < 0.05 then speed = 0.05 end
            if speed > 4 then speed = 4 end
            Config:Set("mouseLookMouseSpeed", speed)
        end,
        T("Mouse speed"),
        T("Cursor and camera speed. Range: 0.05 to 4."),
        0.1)
    speedBox:SetPoint("LEFT", speedLabel, "RIGHT", 5, 0)

    self:AddSectionReset(cameraBox, function()
        Config:Set("mouseLookInvertX", Config.DEFAULTS.mouseLookInvertX)
        Config:Set("mouseLookInvertY", Config.DEFAULTS.mouseLookInvertY)
        Config:Set("mouseLookMouseSpeed", Config.DEFAULTS.mouseLookMouseSpeed)
        invertXCheck:SetChecked(Config.DEFAULTS.mouseLookInvertX and 1 or 0)
        invertYCheck:SetChecked(Config.DEFAULTS.mouseLookInvertY and 1 or 0)
        speedBox:SetText(string.format("%.1f", Config.DEFAULTS.mouseLookMouseSpeed or 1))
    end)

    self.contentSections.mouse = section
end
