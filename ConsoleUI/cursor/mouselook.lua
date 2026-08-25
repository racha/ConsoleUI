-- Manual Mouse Look toggle for WoW Vanilla 1.12.
--
-- This module performs no work during addon load or login. Mouse Look starts
-- only from an existing player input path. Automatic unlocks are controlled by
-- ConsoleUI settings; right-click is the only one enabled by default.

ConsoleUI = ConsoleUI or {}
ConsoleUI.mouselook = ConsoleUI.mouselook or {}
local ManualLook = ConsoleUI.mouselook

ManualLook.DOUBLE_TAP_WINDOW = 0.30

ManualLook.DEFAULTS = {
    mouseLookEnabled = true,
    mouseLookLockOnMovement = true,
    mouseLookLockOnActions = true,
    mouseLookInvertX = false,
    mouseLookInvertY = false,
    mouseLookMouseSpeed = 1,
    mouseLookUnlockRightClick = true,
    mouseLookUnlockModifierDoubleTap = false,
    mouseLookUnlockGameMenu = false,
    mouseLookUnlockBags = false,
    mouseLookUnlockWorldMap = false,
    mouseLookUnlockCharacter = false,
    mouseLookUnlockSpellbook = false,
    mouseLookUnlockTalents = false,
    mouseLookUnlockQuests = false,
    mouseLookUnlockSocial = false,
    mouseLookUnlockCommerce = false,
    mouseLookUnlockProfessions = false,
    mouseLookUnlockOtherWindows = false,
}

ManualLook.FRAME_UNLOCK_OPTIONS = {
    GameMenuFrame = "mouseLookUnlockGameMenu",
    WorldMapFrame = "mouseLookUnlockWorldMap",
    BattlefieldMinimap = "mouseLookUnlockWorldMap",

    CharacterFrame = "mouseLookUnlockCharacter",
    InspectFrame = "mouseLookUnlockCharacter",
    HonorFrame = "mouseLookUnlockCharacter",
    DressUpFrame = "mouseLookUnlockCharacter",

    SpellBookFrame = "mouseLookUnlockSpellbook",
    TalentFrame = "mouseLookUnlockTalents",
    SkillFrame = "mouseLookUnlockTalents",

    QuestLogFrame = "mouseLookUnlockQuests",
    QuestFrame = "mouseLookUnlockQuests",
    QuestFrameGreetingPanel = "mouseLookUnlockQuests",
    QuestFrameDetailPanel = "mouseLookUnlockQuests",
    QuestFrameProgressPanel = "mouseLookUnlockQuests",
    QuestFrameRewardPanel = "mouseLookUnlockQuests",
    GossipFrame = "mouseLookUnlockQuests",
    GossipGreetingScrollFrame = "mouseLookUnlockQuests",
    ItemTextFrame = "mouseLookUnlockQuests",

    FriendsFrame = "mouseLookUnlockSocial",
    LFTFrame = "mouseLookUnlockSocial",
    ReadyCheckFrame = "mouseLookUnlockSocial",

    MerchantFrame = "mouseLookUnlockCommerce",
    AuctionFrame = "mouseLookUnlockCommerce",
    TradeFrame = "mouseLookUnlockCommerce",
    BankFrame = "mouseLookUnlockCommerce",
    MailFrame = "mouseLookUnlockCommerce",
    OpenMailFrame = "mouseLookUnlockCommerce",
    StackSplitFrame = "mouseLookUnlockCommerce",
    CoinPickupFrame = "mouseLookUnlockCommerce",

    TradeSkillFrame = "mouseLookUnlockProfessions",
    CraftFrame = "mouseLookUnlockProfessions",
    ClassTrainerFrame = "mouseLookUnlockProfessions",
    PetStableFrame = "mouseLookUnlockProfessions",

    TaxiFrame = "mouseLookUnlockOtherWindows",
    StaticPopup1 = "mouseLookUnlockOtherWindows",
    StaticPopup2 = "mouseLookUnlockOtherWindows",
    StaticPopup3 = "mouseLookUnlockOtherWindows",
    StaticPopup4 = "mouseLookUnlockOtherWindows",
    LootFrame = "mouseLookUnlockOtherWindows",
    GroupLootFrame1 = "mouseLookUnlockOtherWindows",
    GroupLootFrame2 = "mouseLookUnlockOtherWindows",
    GroupLootFrame3 = "mouseLookUnlockOtherWindows",
    GroupLootFrame4 = "mouseLookUnlockOtherWindows",
    ConsoleUIConfigFrame = "mouseLookUnlockOtherWindows",
    ConsoleUIOnboardFrame = "mouseLookUnlockOtherWindows",
    ConsoleUIChangelogFrame = "mouseLookUnlockOtherWindows",
    ConsoleUIPlacementFrame = "mouseLookUnlockOtherWindows",
    MacroFrame = "mouseLookUnlockOtherWindows",
    VideoOptionsFrame = "mouseLookUnlockOtherWindows",
    SoundOptionsFrame = "mouseLookUnlockOtherWindows",
    UIOptionsFrame = "mouseLookUnlockOtherWindows",
    OptionsFrame = "mouseLookUnlockOtherWindows",
    KeyBindingFrame = "mouseLookUnlockOtherWindows",
    HelpFrame = "mouseLookUnlockOtherWindows",
    CinematicFrame = "mouseLookUnlockOtherWindows",
    ColorPickerFrame = "mouseLookUnlockOtherWindows",
    BattlefieldFrame = "mouseLookUnlockOtherWindows",
}

ManualLook.BAG_FRAME_NAMES = {
    pfBag = true,
    pfBank = true,
    pfBags = true,
    BagshuiBagsFrame = true,
    BagshuiBankFrame = true,
    Bagnon = true,
    Banknon = true,
    BagnonFrame = true,
    BagnonInventory = true,
    BagnonFrame1 = true,
}

function ManualLook:IsActive()
    return self.active and true or false
end

function ManualLook:GetSetting(key)
    if ConsoleUI.config and ConsoleUI.config.Get then
        local value = ConsoleUI.config:Get(key)
        if value ~= nil then
            return value
        end
    end
    return self.DEFAULTS[key]
end

function ManualLook:IsEngineEnabled()
    return self:GetSetting("mouseLookEnabled") ~= false
end

function ManualLook:IsUnlockEnabled(option)
    return self:GetSetting(option) and true or false
end

function ManualLook:TryAutomaticUnlock(option)
    if self.active and self:IsUnlockEnabled(option) then
        return self:Stop()
    end
    return false
end

function ManualLook:UnlockOptionForFrame(frameName)
    if not frameName then
        return nil
    end
    if string.find(frameName, "^ContainerFrame%d+$") or self.BAG_FRAME_NAMES[frameName] then
        return "mouseLookUnlockBags"
    end
    return self.FRAME_UNLOCK_OPTIONS[frameName]
end

function ManualLook:OnFrameShown(frameName)
    local option = self:UnlockOptionForFrame(frameName)
    if option then
        return self:TryAutomaticUnlock(option)
    end
    return false
end

function ManualLook:OnRightClick()
    return self:TryAutomaticUnlock("mouseLookUnlockRightClick")
end

function ManualLook:ResetModifierTaps()
    self.lastShiftTap = nil
    self.lastControlTap = nil
end

function ManualLook:OnModifierDown(name, now)
    if not self:IsUnlockEnabled("mouseLookUnlockModifierDoubleTap") then
        return false
    end
    local field = name == "SHIFT" and "lastShiftTap" or "lastControlTap"
    local previous = self[field]
    self[field] = now
    if previous and now - previous <= self.DOUBLE_TAP_WINDOW then
        self[field] = nil
        return self:Stop()
    end
    return false
end

-- ClassicAPI builds used by Octo do not all emit MODIFIER_STATE_CHANGED.
-- As a no-binding fallback, sample only while Mouse Look is already active.
-- This path can stop Mouse Look; it never starts it or replays an input.
function ManualLook:PollModifierTaps()
    if not self.active then
        return
    end
    if not self:IsUnlockEnabled("mouseLookUnlockModifierDoubleTap") then
        self:DisableModifierWatch()
        return
    end

    local shift = IsShiftKeyDown and IsShiftKeyDown() and true or false
    local control = IsControlKeyDown and IsControlKeyDown() and true or false
    local now = GetTime and GetTime() or nil

    if now then
        if shift and not self.previousShiftDown then
            self:OnModifierDown("SHIFT", now)
        end
        if self.active and control and not self.previousControlDown then
            self:OnModifierDown("CONTROL", now)
        end
    end

    self.previousShiftDown = shift
    self.previousControlDown = control
end

function ManualLook:EnableModifierWatch()
    if not self:IsUnlockEnabled("mouseLookUnlockModifierDoubleTap") then
        self:DisableModifierWatch()
        return
    end
    if not CreateFrame then
        return
    end
    if not self.modifierWatch then
        self.modifierWatch = CreateFrame("Frame")
    end
    if not self.modifierWatch or not self.modifierWatch.SetScript then
        return
    end

    self.previousShiftDown = IsShiftKeyDown and IsShiftKeyDown() and true or false
    self.previousControlDown = IsControlKeyDown and IsControlKeyDown() and true or false
    self:ResetModifierTaps()
    self.modifierWatch:SetScript("OnUpdate", function()
        ManualLook:PollModifierTaps()
    end)
end

function ManualLook:DisableModifierWatch()
    if self.modifierWatch and self.modifierWatch.SetScript then
        self.modifierWatch:SetScript("OnUpdate", nil)
    end
    self.previousShiftDown = nil
    self.previousControlDown = nil
    self:ResetModifierTaps()
end

function ManualLook:RefreshUnlockOptions()
    if self.active and self:IsEngineEnabled()
        and self:IsUnlockEnabled("mouseLookUnlockModifierDoubleTap") then
        self:EnableModifierWatch()
    else
        self:DisableModifierWatch()
    end
end

function ManualLook:ApplyCameraSettings()
    if not GetCVar or not SetCVar then
        return
    end

    local invertX = self:GetSetting("mouseLookInvertX") and true or false
    local invertY = self:GetSetting("mouseLookInvertY") and true or false
    if GetCVar("mouseInvertYaw") ~= nil then
        SetCVar("mouseInvertYaw", invertX and "1" or "0")
    end
    if GetCVar("mouseInvertPitch") ~= nil then
        SetCVar("mouseInvertPitch", invertY and "1" or "0")
    elseif GetCVar("invertMouse") ~= nil then
        SetCVar("invertMouse", invertY and "1" or "0")
    end

    local speed = tonumber(self:GetSetting("mouseLookMouseSpeed")) or 1
    if speed < 0.05 then
        speed = 0.05
    end
    if speed > 4 then
        speed = 4
    end
    if GetCVar("mouseSpeed") ~= nil then
        SetCVar("mouseSpeed", string.format("%.2f", speed))
    end
end

-- Settings/profile application never starts Mouse Look. Disabling the master
-- switch may release a currently tracked lock; camera CVars update immediately.
function ManualLook:ApplySettings(changedKey)
    self:ApplyCameraSettings()
    self:RefreshUnlockOptions()
    if not self:IsEngineEnabled() and self.active then
        self:Stop()
    end
end

-- Install only after the player's first explicit manual toggle. Nothing hooks
-- WorldFrame during addon load/login, and left click remains entirely Blizzard.
function ManualLook:WatchRightClick()
    if self.rightClickWatch or not WorldFrame then
        return
    end
    if not WorldFrame.GetScript or not WorldFrame.SetScript then
        return
    end
    self.rightClickWatch = true
    local oldDown = WorldFrame:GetScript("OnMouseDown")
    WorldFrame:SetScript("OnMouseDown", function()
        if arg1 == "RightButton" then
            ManualLook:OnRightClick()
        end
        if oldDown then
            oldDown()
        end
    end)
end

-- Watch the menu opening instead of rebinding Escape. Escape keeps all of its
-- normal close/cancel behavior; only showing GameMenuFrame unlocks the mouse.
function ManualLook:WatchEscapeMenu()
    if self.escapeMenuWatch or not GameMenuFrame then
        return
    end
    if not GameMenuFrame.GetScript or not GameMenuFrame.SetScript then
        return
    end
    self.escapeMenuWatch = true
    local oldShow = GameMenuFrame:GetScript("OnShow")
    GameMenuFrame:SetScript("OnShow", function()
        ManualLook:OnFrameShown("GameMenuFrame")
        if oldShow then
            oldShow()
        end
    end)
end

function ManualLook:WatchUnlockFrame(frame, frameName)
    if not frame or not frame.GetScript or not frame.SetScript then
        return
    end
    self.unlockFrames = self.unlockFrames or {}
    if self.unlockFrames[frame] then
        return
    end
    self.unlockFrames[frame] = true
    local watchedName = frameName
    if not watchedName and frame.GetName then
        watchedName = frame:GetName()
    end
    local oldShow = frame:GetScript("OnShow")
    frame:SetScript("OnShow", function()
        ManualLook:OnFrameShown(watchedName)
        if oldShow then
            oldShow()
        end
    end)
end

-- The map and Blizzard container frames are watched only after the player's
-- first Mouse Look start. Their keys remain entirely under Blizzard/ConsoleUI.
function ManualLook:WatchBagsAndMap()
    if self.bagsAndMapWatch then
        return
    end
    local complete = true
    local worldMap = WorldMapFrame
    if not worldMap and getglobal then
        worldMap = getglobal("WorldMapFrame")
    end
    if worldMap then
        self:WatchUnlockFrame(worldMap, "WorldMapFrame")
    else
        complete = false
    end

    if getglobal then
        for i = 1, 12 do
            local frame = getglobal("ContainerFrame" .. i)
            if frame then
                self:WatchUnlockFrame(frame, "ContainerFrame" .. i)
            else
                complete = false
            end
        end
    else
        complete = false
    end
    self.bagsAndMapWatch = complete and true or nil
end

function ManualLook:Stop()
    if not self.active or not MouselookStop then
        return false
    end
    local ok, reason = pcall(MouselookStop)
    if ok then
        self.active = nil
        self:DisableModifierWatch()
    elseif ConsoleUI_Log then
        ConsoleUI_Log("MouselookStop failed: " .. tostring(reason))
    end
    return ok and true or false
end

function ManualLook:Start()
    if not self:IsEngineEnabled() then
        return false
    end
    if not MouselookStart then
        return false
    end
    self:WatchRightClick()
    self:WatchEscapeMenu()
    self:WatchBagsAndMap()
    if self.active then
        self:RefreshUnlockOptions()
        return true
    end
    local ok, reason = pcall(MouselookStart)
    if ok then
        self.active = true
        self:EnableModifierWatch()
    elseif ConsoleUI_Log then
        ConsoleUI_Log("MouselookStart failed: " .. tostring(reason))
    end
    return ok and true or false
end

function ManualLook:Toggle()
    if self.active then
        return self:Stop()
    end
    return self:Start()
end

-- ConsoleUI action bindings already run on the player's real hardware stack.
-- Lock before the existing UseAction path; never replay or wrap that action.
function ManualLook:OnActionBinding()
    if self:GetSetting("mouseLookLockOnActions") == false then
        return false
    end
    return self:Start()
end

function ManualLook:OnMovementBinding()
    if self:GetSetting("mouseLookLockOnMovement") == false then
        return false
    end
    return self:Start()
end

function ConsoleUI_MouseLook()
    return ManualLook:Toggle()
end

-- Mapper companion binding: lock only. Movement remains bound directly to
-- Blizzard, and repeated mapper presses leave an existing lock unchanged.
function ConsoleUI_MouseLookStart()
    return ManualLook:OnMovementBinding()
end
