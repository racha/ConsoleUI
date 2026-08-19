--[[
    ConsoleUI - Action Bars Module
    
    Button Layout (Key = Button ID):
    - 1 = A, 2 = X, 3 = Y, 4 = B  (Face buttons)
    - 5 = Down, 6 = Left, 7 = Up, 8 = Right  (D-Pad)
    - 9 = RB, 10 = RT  (RB / RT. LB is Ctrl, not a diamond.)
    
    Page System (based on modifier keys):
    - Page 1: No modifiers (default)
    - Page 2: Shift held
    - Page 3: Ctrl held
    - Page 4: Shift+Ctrl held
]]

-- Create the actionbars module namespace
if ConsoleUI.actionbars == nil then
    ConsoleUI.actionbars = {}
end

local ActionBars = ConsoleUI.actionbars

-- ============================================================================
-- Constants
-- ============================================================================

ActionBars.NUM_BUTTONS = 10
ActionBars.NUM_PAGES = 4  -- 4 pages accessible via modifier keys
ActionBars.TOOLTIP_UPDATE_TIME = 0.2
ActionBars.RANGE_CHECK_TIME = 0.2  -- Check range every 200ms (like pfUI)
ActionBars.FLASH_TIME = 0.4
ActionBars.MODIFIER_CHECK_TIME = 0.05  -- Check modifiers every 50ms

-- Color configurations for button states (matching pfUI defaults)
ActionBars.RANGE_COLOR = {1.0, 0.1, 0.1, 1.0}  -- Red for out of range
ActionBars.OOM_COLOR = {0.5, 0.5, 1.0, 1.0}    -- Blue for out of mana
ActionBars.NA_COLOR = {0.4, 0.4, 0.4, 1.0}     -- Gray for not usable
ActionBars.NORMAL_COLOR = {1.0, 1.0, 1.0, 1.0} -- White for normal
ActionBars.DIAMOND_FILL = { 0, 0, 0 }
ActionBars.DIAMOND_ACTIVE = { 1, 1, 1 }

-- Event caching system (like pfUI)
ActionBars.eventCache = {}
ActionBars.updateCache = {}

-- Action slot offsets for each page (each page uses 10 consecutive action slots)
-- WoW 1.12 has 120 action slots total (12 action bar pages of 12 buttons each)
-- Warriors/Druids/Rogues use bonus bars for stances/forms (slots 73+)
-- We use modifier keys to access additional pages for non-stance abilities
ActionBars.PAGE_OFFSETS = {
    [1] = 0,    -- Page 1: slots 1-10 (no modifier, no stance)
    [2] = 10,   -- Page 2: slots 11-20 (Shift)
    [3] = 20,   -- Page 3: slots 21-30 (Ctrl)
    [4] = 30,   -- Page 4: slots 31-40 (Shift+Ctrl)
}

-- Bonus bar offset calculation for stances/forms
-- Formula: (NUM_ACTIONBAR_PAGES + bonusBarOffset - 1) * 12
-- Where NUM_ACTIONBAR_PAGES = 6, so base offset is 60 + (bonusBarOffset * 12)
-- Battle Stance (bonus=1): 72, Defensive (bonus=2): 84, Berserker (bonus=3): 96
ActionBars.BONUS_BAR_BASE = 60  -- (6 pages * 12 buttons) - 12 = 60

-- Current active page
ActionBars.currentPage = 1

-- Get current druid form name (returns nil if not druid or in caster form)
function ActionBars:GetCurrentDruidForm()
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return nil end
    
    local numForms = GetNumShapeshiftForms() or 0
    for i = 1, numForms do
        local texture, name, isActive = GetShapeshiftFormInfo(i)
        if isActive == 1 and name then
            return name
        end
    end
    
    return nil  -- Caster form
end

-- Check if druid is in cat form with stealth/prowl active
-- Based on pfUI's IsCatStealth() function
function ActionBars:IsCatStealth()
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return nil end
    
    local cat, stealth = nil, nil
    
    -- Check player buffs for cat form and stealth
    -- In WoW 1.12, we need to check buff textures
    for i = 0, 31 do
        local texture = nil
        
        -- Try different methods to get buff texture (WoW 1.12 compatibility)
        if GetPlayerBuffTexture then
            texture = GetPlayerBuffTexture(i)
        elseif GetPlayerBuff then
            -- GetPlayerBuff returns texture, rank, and other info
            texture = GetPlayerBuff(i)
        end
        
        if not texture then break end
        
        -- Cat form icon detected
        if string.find(texture, "Ability_Druid_CatForm") then
            if stealth then 
                return true 
            end
            cat = true
        end
        
        -- Stealth/prowl icon detected (uses Ambush icon)
        if string.find(texture, "Ability_Ambush") then
            if cat then 
                return true 
            end
            stealth = true
        end
    end
    
    return nil
end

-- Function to get controller icon path based on controller type
function ActionBars:GetControllerIconPath(iconName)
    local controllerType = "xbox"  -- Default
    if ConsoleUI.config and ConsoleUI.config.Get then
        controllerType = ConsoleUI.config:Get("controllerType") or "xbox"
    elseif ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.controllerType then
        controllerType = ConsoleUIDB.config.controllerType
    end
    
    -- D-pad icons are shared, controller-specific icons are in controllers/<type>/
    local dPadIcons = {down = true, left = true, right = true, up = true}
    if dPadIcons[iconName] then
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. iconName
    else
        return "Interface\\AddOns\\ConsoleUI\\textures\\controllers\\" .. controllerType .. "\\" .. iconName
    end
end

local function PaintTex(tex, r, g, b, a)
    if not tex then return end
    tex:SetVertexColor(r, g, b)
    if a ~= nil then
        tex:SetAlpha(a)
    end
end

local function ButtonHasIcon(button)
    if not button or not button.GetName then
        return false
    end
    local icon = getglobal(button:GetName() .. "Icon") or button.icon
    return icon and icon:IsShown() and icon:GetTexture() ~= nil
end

function ActionBars:IsMainBarButton(button)
    if not button or not button.GetID or not button.GetName then
        return false
    end
    local id = button:GetID()
    if not id or id < 1 or id > 10 then
        return false
    end
    return button:GetName() == ("ConsoleActionButton" .. id)
end

function ActionBars:BarLayoutKind()
    if ConsoleUI.config and ConsoleUI.config.Get then
        return ConsoleUI.config:Get("barLayout") or "controller"
    end
    return "controller"
end

function ActionBars:UsesDiamondChrome(button)
    return self:IsMainBarButton(button) and self:BarLayoutKind() ~= "flat"
end

function ActionBars:HideDiamond(button)
    if button.diamondPlate then
        button.diamondPlate:Hide()
    end
    if button.diamondRim then
        button.diamondRim:Hide()
    end
    if button.diamondRing then
        button.diamondRing:Hide()
    end
    if button.diamondChrome then
        button.diamondChrome:Hide()
    end
end

function ActionBars:RaiseDiamondChrome(button)
    if not button.diamondChrome then
        return
    end
    local base = button:GetFrameLevel()
    if button._sliceMask then
        base = button._sliceMask:GetFrameLevel()
    end
    button.diamondChrome:SetFrameLevel(base + 2)
    button.diamondChrome:Show()
end

function ActionBars:EnsureDiamond(button)
    if not button.diamondPlate then
        local plate = button:CreateTexture(nil, "BACKGROUND")
        plate:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
        plate:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
        button.diamondPlate = plate
    end
    if not button.diamondChrome then
        local chrome = CreateFrame("Frame", button:GetName() .. "DiamondChrome", button)
        chrome:SetAllPoints(button)
        if chrome.EnableMouse then
            chrome:EnableMouse(false)
        end
        button.diamondChrome = chrome
    end
    if not button.diamondRim then
        button.diamondRim = button.diamondChrome:CreateTexture(nil, "ARTWORK")
    else
        button.diamondRim:SetParent(button.diamondChrome)
    end
    local rimIn = 3
    local goldOut = 6
    if self.Layout then
        rimIn = self.Layout.RIM_IN or rimIn
        goldOut = self.Layout.GOLD_OUT or goldOut
    end
    button.diamondRim:ClearAllPoints()
    button.diamondRim:SetPoint("TOPLEFT", button, "TOPLEFT", rimIn, -rimIn)
    button.diamondRim:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -rimIn, rimIn)
    if not button.diamondRing then
        button.diamondRing = button.diamondChrome:CreateTexture(nil, "OVERLAY")
    else
        button.diamondRing:SetParent(button.diamondChrome)
    end
    button.diamondRing:ClearAllPoints()
    button.diamondRing:SetPoint("TOPLEFT", button, "TOPLEFT", -goldOut, goldOut)
    button.diamondRing:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", goldOut, -goldOut)
    self:RaiseDiamondChrome(button)
end

function ActionBars:IsProxiedButton(button)
    if button.isProxiedAction then
        return true
    end
    if not (ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied) then
        return false
    end
    local slot = button.actionSlot
    if not slot then
        local id = button.GetID and button:GetID()
        if id and id > 0 then
            slot = (self:GetActionOffset() or 0) + id
        end
    end
    return slot and ConsoleUI.proxied:IsSlotProxied(slot)
end

function ActionBars:IdleDiamond(button)
    if button.SetButtonState then
        button:SetButtonState("NORMAL")
    end
    button._diamondPushed = nil
    if button.SetChecked then
        button:SetChecked(0)
    end
    if self:HasPlate(button) then
        self:PaintDiamond(button)
    end
end

function ActionBars:DiamondActive(button)
    -- Touch bars use slots 41-50. GetActionID used to read the trailing
    -- "Button3" and treat that as main-bar slot 3, so a Y-cast painted
    -- left-3 white. They also should never show current-action fill.
    if button.sideBarIndex then
        return false
    end
    if button._diamondPushed then
        return true
    end
    if button.GetButtonState and button:GetButtonState() == "PUSHED" then
        return true
    end
    -- JUMP / INTERACT / etc. only replace the key. The old spell or Attack
    -- can stay in the slot. IsCurrentAction on that slot painted the
    -- proxied diamond white, especially after a modifier page refresh.
    if self:IsProxiedButton(button) then
        return false
    end
    local actionID = self:GetActionID(button)
    if actionID and IsCurrentAction and IsCurrentAction(actionID) then
        return true
    end
    if actionID and IsAutoRepeatAction and IsAutoRepeatAction(actionID) then
        return true
    end
    if button.actionSlot and IsCurrentAction and IsCurrentAction(button.actionSlot) then
        return true
    end
    if button.actionSlot and IsAutoRepeatAction and IsAutoRepeatAction(button.actionSlot) then
        return true
    end
    return false
end

function ActionBars:HasPlate(button)
    return button and button.diamondPlate and button.diamondPlate:IsShown()
end

function ActionBars:PaintDiamond(button)
    if not button.diamondPlate then
        return
    end
    local active = self:DiamondActive(button)
    local hasIcon = ButtonHasIcon(button)
    local plateAlpha = 1
    if not hasIcon and not self:IsMainBarButton(button) then
        plateAlpha = 0.5
    end
    if active then
        PaintTex(button.diamondPlate, self.DIAMOND_ACTIVE[1], self.DIAMOND_ACTIVE[2], self.DIAMOND_ACTIVE[3], plateAlpha)
    else
        PaintTex(button.diamondPlate, self.DIAMOND_FILL[1], self.DIAMOND_FILL[2], self.DIAMOND_FILL[3], plateAlpha)
    end
    local gold = false
    if ConsoleUI.config and ConsoleUI.config.Get then
        gold = ConsoleUI.config:Get("barGoldBorder") and true or false
    end
    if button.diamondRim then
        if hasIcon then
            if active then
                PaintTex(button.diamondRim, self.DIAMOND_ACTIVE[1], self.DIAMOND_ACTIVE[2], self.DIAMOND_ACTIVE[3], 1)
            else
                PaintTex(button.diamondRim, 0, 0, 0, 1)
            end
            button.diamondRim:Show()
        else
            button.diamondRim:Hide()
        end
    end
    if button.diamondRing then
        if gold then
            local r, g, b = 1.00, 0.82, 0.18
            if ConsoleUI.config and ConsoleUI.config.GetHudBorderColor then
                r, g, b = ConsoleUI.config:GetHudBorderColor()
            end
            PaintTex(button.diamondRing, r, g, b, 1)
            button.diamondRing:Show()
        else
            button.diamondRing:Hide()
        end
    end
end

function ActionBars:ApplyDiamondAppearance(button)
    self:EnsureDiamond(button)
    local Layout = self.Layout
    local id = button:GetID()
    local kind = "controller"
    if ConsoleUI.config and ConsoleUI.config.Get then
        kind = ConsoleUI.config:Get("barLayout") or "controller"
    end
    local dir = "N"
    if Layout then
        dir = Layout.Dir(id, kind)
        button.diamondPlate:SetTexture(Layout.KeyPath(dir, nil))
        button.diamondRim:SetTexture(Layout.KeyPath(dir, "in"))
        button.diamondRing:SetTexture(Layout.KeyPath(dir, 1))
    end
    PaintTex(button.diamondPlate, self.DIAMOND_FILL[1], self.DIAMOND_FILL[2], self.DIAMOND_FILL[3], 1)
    button.diamondPlate:Show()

    local bg = getglobal(button:GetName() .. "Background")
    if bg then
        bg:SetTexture(nil)
        bg:Hide()
    end
    local normalTex = getglobal(button:GetName() .. "NormalTexture")
    if normalTex then
        normalTex:SetTexture(nil)
        normalTex:Hide()
    end

    local highlightTex = button:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetTexture(nil)
        highlightTex:Hide()
    end
    local pushedTex = button:GetPushedTexture()
    if pushedTex then
        pushedTex:SetTexture(nil)
        pushedTex:Hide()
    end
    local checkedTex = button:GetCheckedTexture()
    if checkedTex then
        checkedTex:SetTexture(nil)
        checkedTex:Hide()
    end

    self:SetThinOutline(button, false)
    local overlay = getglobal(button:GetName() .. "Overlay")
    if overlay then overlay:Hide() end

    local buttonSize = button:GetWidth()
    if buttonSize == 0 then
        buttonSize = 56
    end
    local iconSize = 24 * buttonSize / 56
    if Layout then
        local metrics = Layout.Metrics(buttonSize, 50)
        iconSize = metrics.icon
    end
    local icon = getglobal(button:GetName() .. "Icon")
    if icon then
        icon:SetWidth(iconSize)
        icon:SetHeight(iconSize)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetDrawLayer("ARTWORK")
    end

    local flash = getglobal(button:GetName() .. "Flash")
    if flash then
        flash:SetWidth(iconSize)
        flash:SetHeight(iconSize)
        flash:ClearAllPoints()
        flash:SetPoint("CENTER", button, "CENTER", 0, 0)
    end

    if button.activeFrame then
        if button.activeFrame.glow then
            button.activeFrame.glow:Hide()
        end
        if button.activeFrame.border then
            button.activeFrame.border:Hide()
        end
    end

    self:PlaceControllerPip(button, buttonSize, kind)
    self:PaintDiamond(button)

    local icon = getglobal(button:GetName() .. "Icon")
    if icon then
        icon:SetAlpha(0)
    end
    local flash = getglobal(button:GetName() .. "Flash")
    if flash then
        flash:SetAlpha(0)
    end
    if self.SliceMask then
        self.SliceMask:Ensure(button, buttonSize)
        self.SliceMask:Sync(button)
    end
    self:RaiseDiamondChrome(button)
end

function ActionBars:PlaceControllerPip(button, buttonSize, kind)
    local controllerIcon = getglobal(button:GetName() .. "ControllerIcon")
    if not controllerIcon then
        return
    end
    local Layout = self.Layout
    local pip = 22
    local point, px, py = "BOTTOM", 0, 2
    if Layout then
        pip = Layout.PIP_SIZE or 22
        point, px, py = Layout.PipAnchor(button:GetID(), buttonSize, kind)
    end
    controllerIcon:SetWidth(pip)
    controllerIcon:SetHeight(pip)
    if not button.controllerIconFrame then
        local iconFrame = CreateFrame("Frame", button:GetName() .. "ControllerIconFrame", button)
        iconFrame:SetFrameLevel(button:GetFrameLevel() + 10)
        iconFrame:SetAllPoints(button)
        button.controllerIconFrame = iconFrame
    end
    controllerIcon:SetParent(button.controllerIconFrame)
    controllerIcon:SetDrawLayer("OVERLAY")
    controllerIcon:ClearAllPoints()
    if point == "BOTTOM" then
        controllerIcon:SetPoint("BOTTOM", button, "BOTTOM", px, py)
    else
        controllerIcon:SetPoint(point, button, "CENTER", px, py)
    end
    controllerIcon:Show()
end

function ActionBars:ApplySquareAppearance(button)
    if self.SliceMask then
        self.SliceMask:Remove(button)
    end
    self:EnsureDiamond(button)
    local Layout = self.Layout
    if Layout then
        button.diamondPlate:SetTexture(Layout.KeyPath("Q", nil))
        button.diamondRim:SetTexture(Layout.KeyPath("Q", "in"))
        button.diamondRing:SetTexture(Layout.KeyPath("Q", 1))
    end
    button.diamondPlate:SetDrawLayer("BACKGROUND")
    PaintTex(button.diamondPlate, self.DIAMOND_FILL[1], self.DIAMOND_FILL[2], self.DIAMOND_FILL[3], 1)
    button.diamondPlate:Show()
    self:PaintDiamond(button)
    self:RaiseDiamondChrome(button)

    local bg = getglobal(button:GetName() .. "Background")
    if bg then
        bg:SetTexture(nil)
        bg:Hide()
    end
    local normalTex = getglobal(button:GetName() .. "NormalTexture")
    if normalTex then
        normalTex:SetTexture(nil)
        normalTex:Hide()
    end

    local highlightTex = button:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetTexture(nil)
        highlightTex:Hide()
    end
    local pushedTex = button:GetPushedTexture()
    if pushedTex then
        pushedTex:SetTexture(nil)
        pushedTex:Hide()
    end
    local checkedTex = button:GetCheckedTexture()
    if checkedTex then
        checkedTex:SetTexture(nil)
        checkedTex:Hide()
    end

    self:SetThinOutline(button, false)
    local overlay = getglobal(button:GetName() .. "Overlay")
    if overlay then
        overlay:Hide()
    end

    local buttonSize = button:GetWidth()
    if buttonSize == 0 then
        buttonSize = button:GetHeight()
    end
    if buttonSize == 0 then
        buttonSize = 40
    end

    local iconSize = buttonSize - 24
    if Layout and Layout.SquareIconSize then
        iconSize = Layout.SquareIconSize(buttonSize)
    elseif iconSize < 8 then
        iconSize = 8
    end
    local icon = getglobal(button:GetName() .. "Icon")
    if icon then
        icon:SetAlpha(1)
        icon:SetWidth(iconSize)
        icon:SetHeight(iconSize)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetDrawLayer("ARTWORK")
    end

    local flash = getglobal(button:GetName() .. "Flash")
    if flash then
        flash:SetAlpha(1)
        flash:SetTexture("Interface\\Buttons\\UI-QuickslotRed")
        flash:SetWidth(iconSize)
        flash:SetHeight(iconSize)
        flash:ClearAllPoints()
        flash:SetPoint("CENTER", button, "CENTER", 0, 0)
        flash:SetBlendMode("ADD")
    end

    if button.activeFrame then
        if button.activeFrame.glow then
            button.activeFrame.glow:Hide()
        end
        if button.activeFrame.border then
            button.activeFrame.border:Hide()
        end
    end

    if self:IsMainBarButton(button) then
        self:PlaceControllerPip(button, buttonSize, "flat")
    end
end

-- Controller button icon mapping (Button ID matches keyboard key)
-- Button 1-9 = keys 1-9, Button 10 = key 0
-- Icons are loaded dynamically based on controller type
function ActionBars:GetButtonIcons()
    return {
        [1] = self:GetControllerIconPath("a"),      -- Key 1
        [2] = self:GetControllerIconPath("x"),      -- Key 2
        [3] = self:GetControllerIconPath("y"),      -- Key 3
        [4] = self:GetControllerIconPath("b"),      -- Key 4
        [5] = self:GetControllerIconPath("down"),   -- Key 5
        [6] = self:GetControllerIconPath("left"),   -- Key 6
        [7] = self:GetControllerIconPath("up"),     -- Key 7
        [8] = self:GetControllerIconPath("right"),  -- Key 8
        [9] = self:GetControllerIconPath("rb"),     -- Key 9
        [10] = self:GetControllerIconPath("rt"),    -- Key 0
    }
end

-- ============================================================================
-- Module Initialization
-- ============================================================================

function ActionBars:Initialize()
    self:ApplyDefaultBarVisibility()
    self:CreateModifierFrame()
    self:UpdateAllButtons()
    self:CreateSideBars()
    self:InitializeBagBar()
    self:HookCooldownFrame()
end

-- Hook CooldownFrame_SetTimer to hide default cooldowns for our buttons
function ActionBars:HookCooldownFrame()
    if not self.cooldownHookSet then
        -- Store original function
        local originalSetTimer = CooldownFrame_SetTimer
        -- Replace with our version
        CooldownFrame_SetTimer = function(cooldown, start, duration, enable)
            -- Hide cooldown if it belongs to one of our action buttons
            -- We use our own cooldown system (darkened icon + timer text)
            if cooldown and cooldown:GetParent() then
                local parent = cooldown:GetParent()
                local parentName = parent:GetName() or ""
                if string.find(parentName, "ConsoleActionButton") then
                    -- Hide default cooldown - we handle it ourselves
                    cooldown:Hide()
                    return
                end
            end
            -- For non-ConsoleActionButton cooldowns, call original
            originalSetTimer(cooldown, start, duration, enable)
        end
        self.cooldownHookSet = true
    end
end

-- ============================================================================
-- Custom Circular Cooldown for Modern Style
-- ============================================================================

-- Create a circular cooldown overlay for a button
function ActionBars:CreateCircularCooldown(button)
    local buttonName = button:GetName()
    local frameName = buttonName .. "CircularCooldown"
    
    -- Check if already created
    if button.circularCooldown then
        return button.circularCooldown
    end
    
    -- Create the main cooldown frame (just for text, we'll darken the icon directly)
    local frame = CreateFrame("Frame", frameName, button)
    frame:SetFrameLevel(button:GetFrameLevel() + 5)
    frame:SetAllPoints(button)
    frame:Hide()
    
    -- Store cooldown state
    frame.start = 0
    frame.duration = 0
    frame.enabled = false
    
    -- Store reference to the icon texture (we'll darken it during cooldown)
    frame.icon = getglobal(buttonName .. "Icon") or button.icon
    
    -- Create cooldown text (remaining time) - like OmniCC
    local text = frame:CreateFontString(frameName .. "Text", "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetTextColor(1, 0.8, 0, 1)  -- Gold color
    text:SetText("")
    frame.text = text
    
    -- OnUpdate handler for animation
    frame:SetScript("OnUpdate", function()
        ActionBars:UpdateCircularCooldown(this)
    end)
    
    button.circularCooldown = frame
    return frame
end

-- Update the circular cooldown animation
function ActionBars:UpdateCircularCooldown(frame)
    if not frame.enabled or frame.duration == 0 then
        frame:Hide()
        -- Restore icon color when cooldown ends
        if frame.icon then
            frame.icon:SetVertexColor(1, 1, 1, 1)
        end
        if ActionBars.SliceMask then
            ActionBars.SliceMask:SyncColor(frame:GetParent())
        end
        return
    end
    
    local now = GetTime()
    local elapsed = now - frame.start
    local remaining = frame.duration - elapsed
    
    if remaining <= 0 then
        -- Cooldown finished
        frame.enabled = false
        frame:Hide()
        
        -- Restore icon color
        if frame.icon then
            frame.icon:SetVertexColor(1, 1, 1, 1)
        end
        if ActionBars.SliceMask then
            ActionBars.SliceMask:SyncColor(frame:GetParent())
        end
        return
    end
    
    -- Calculate progress (0 = just started, 1 = almost done)
    local progress = elapsed / frame.duration
    
    -- Darken the icon based on cooldown progress
    -- Start very dark (0.3) and gradually brighten to (0.7) as cooldown ends
    if frame.icon then
        local brightness = 0.3 + (progress * 0.4)
        frame.icon:SetVertexColor(brightness, brightness, brightness, 1)
        if ActionBars.SliceMask then
            ActionBars.SliceMask:SyncColor(frame:GetParent())
        end
    end
    
    -- Update cooldown text (no decimals)
    if frame.text then
        if remaining > 60 then
            frame.text:SetText(math.floor(remaining / 60) .. "m")
        elseif remaining > 0 then
            frame.text:SetText(math.ceil(remaining))
        else
            frame.text:SetText("")
        end
    end
end

-- Start the circular cooldown
function ActionBars:StartCircularCooldown(button, start, duration)
    if not button.circularCooldown then
        self:CreateCircularCooldown(button)
    end
    
    local frame = button.circularCooldown
    if not frame then return end
    
    if duration > 0 and start > 0 then
        frame.start = start
        frame.duration = duration
        frame.enabled = true
        frame:Show()
        
        -- Position text at icon center
        local buttonSize = button:GetWidth()
        if frame.text then
            frame.text:ClearAllPoints()
            frame.text:SetPoint("CENTER", button, "CENTER", -buttonSize * 0.02, 0)
        end
        
        -- Immediately darken the icon
        if frame.icon then
            frame.icon:SetVertexColor(0.3, 0.3, 0.3, 1)
        end
        if self.SliceMask then
            self.SliceMask:SyncColor(button)
        end
    else
        frame.enabled = false
        frame:Hide()
        -- Restore icon color
        if frame.icon then
            frame.icon:SetVertexColor(1, 1, 1, 1)
        end
        if self.SliceMask then
            self.SliceMask:SyncColor(button)
        end
    end
end

-- Stop/hide the circular cooldown
function ActionBars:StopCircularCooldown(button)
    if button.circularCooldown then
        button.circularCooldown.enabled = false
        button.circularCooldown:Hide()
        -- Restore icon color
        if button.circularCooldown.icon then
            button.circularCooldown.icon:SetVertexColor(1, 1, 1, 1)
        end
        if self.SliceMask then
            self.SliceMask:SyncColor(button)
        end
    end
end

function ActionBars:OnPlayerEnteringWorld()
    self:ApplyDefaultBarVisibility()
    self:UpdateAllButtons()
end

-- ============================================================================
-- Modifier Key Checking (Page Switching)
-- ============================================================================

function ActionBars:CreateModifierFrame()
    -- Create a frame to check modifier keys on update
    if self.modifierFrame then return end
    
    self.modifierFrame = CreateFrame("Frame", "ConsoleUIModifierFrame", UIParent)
    self.modifierFrame.timeSinceLastUpdate = 0
    self.modifierFrame.stealthCheckTime = 0
    self.modifierFrame.lastStealthState = nil
    
    self.modifierFrame:SetScript("OnUpdate", function()
        this.timeSinceLastUpdate = this.timeSinceLastUpdate + arg1
        if this.timeSinceLastUpdate >= ActionBars.MODIFIER_CHECK_TIME then
            this.timeSinceLastUpdate = 0
            ActionBars:CheckModifiers()
        end
        
        -- Check for druid stealth state changes (check less frequently)
        this.stealthCheckTime = this.stealthCheckTime + arg1
        if this.stealthCheckTime >= 0.1 then  -- Check every 100ms
            this.stealthCheckTime = 0
            
            -- Only check if druid stealth feature is enabled
            local useDruidStealth = false
            if ConsoleUI.config and ConsoleUI.config.Get then
                useDruidStealth = ConsoleUI.config:Get("druidStealth") or false
            elseif ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.druidStealth then
                useDruidStealth = ConsoleUIDB.config.druidStealth
            end
            
            if useDruidStealth then
                local _, class = UnitClass("player")
                if class == "DRUID" then
                    local bonusBar = GetBonusBarOffset() or 0
                    
                    if bonusBar == 1 then
                        -- In cat form, check stealth state
                        local currentStealth = ActionBars:IsCatStealth()
                        
                        -- If stealth state changed, update buttons
                        if currentStealth ~= this.lastStealthState then
                            ConsoleUI_Debug("Stealth state changed: " .. tostring(this.lastStealthState) .. " -> " .. tostring(currentStealth))
                            this.lastStealthState = currentStealth
                            -- Force update all buttons when stealth state changes
                            ActionBars:UpdateAllButtons()
                        end
                    else
                        -- Not in cat form, reset stealth state tracking
                        if this.lastStealthState ~= nil then
                            this.lastStealthState = nil
                        end
                    end
                end
            end
        end
    end)
end

function ActionBars:GetCurrentModifierPage()
    local shift = IsShiftKeyDown()
    local ctrl = IsControlKeyDown()

    if shift and ctrl then
        return 4  -- Shift+Ctrl
    elseif ctrl then
        return 3  -- Ctrl only
    elseif shift then
        return 2  -- Shift only
    else
        return 1  -- No modifiers (WoW handles stance swapping internally)
    end
end

function ActionBars:CheckModifiers()
    local newPage = self:GetCurrentModifierPage()
    
    if newPage ~= self.currentPage then
        -- Clear all active states from previous page before switching
        -- This prevents buttons from showing glow/flash from actions on the old page
        for i = 1, self.NUM_BUTTONS do
            local button = getglobal("ConsoleActionButton"..i)
            if button then
                -- Stop flashing (red overlay) - reset state completely
                button.flashing = 0
                button.flashtime = 0
                local flash = getglobal(button:GetName().."Flash")
                if flash then
                    flash:Hide()
                end
                
                -- Force hide active glow/border when switching pages
                if button.activeFrame then
                    button.activeFrame.glow:Hide()
                    if button.activeFrame.border then
                        button.activeFrame.border:Hide()
                    end
                end
                
                -- Reset checked / pushed. Modifier release used to leave
                -- JUMP (proxied) white because IsCurrentAction still saw
                -- the leftover action in that slot.
                self:IdleDiamond(button)
            end
        end
        
        self.currentPage = newPage
        -- Force full update of all buttons when page changes
        -- This ensures icons, cooldowns, states, etc. are all refreshed
        self:UpdateAllButtons()
        -- Debug message (optional)
        -- DEFAULT_CHAT_FRAME:AddMessage("|cffffd12e[ConsoleUI]|r Switched to page " .. newPage)
    end
end

function ActionBars:GetActionOffset()
    -- If using modifier keys (pages 2-4), use those offsets
    if self.currentPage > 1 then
        return self.PAGE_OFFSETS[self.currentPage] or self.PAGE_OFFSETS[1]
    end
    
    -- For page 1 (no modifier), check for bonus bar (stances/forms)
    -- Warriors: Battle=1, Defensive=2, Berserker=3
    -- Druids: Cat=1, Bear=3, Travel=4, Moonkin=5 (Aquatic uses regular bar)
    -- Rogues: Stealth=1
    local bonusBar = GetBonusBarOffset()
    
    -- Check for druid forms that don't use bonus bars (like Travel Form)
    local _, class = UnitClass("player")
    if class == "DRUID" then
        local currentForm = self:GetCurrentDruidForm()
        if currentForm then
            local formLower = string.lower(currentForm)
            
            -- Travel form doesn't use a bonus bar, but we want to use travel form bar slots
            if string.find(formLower, "travel") then
                return self.BONUS_BAR_BASE + (4 * 12)
            end
        end
    end
    
    if bonusBar and bonusBar > 0 then
        -- Check if druid stealth feature is enabled and druid is in cat form with stealth
        -- When enabled, use travel form bar (bonus bar 4) instead of cat form bar (bonus bar 1)
        local useDruidStealth = false
        if ConsoleUI.config and ConsoleUI.config.Get then
            useDruidStealth = ConsoleUI.config:Get("druidStealth") or false
        elseif ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.druidStealth then
            useDruidStealth = ConsoleUIDB.config.druidStealth
        end
        
        if useDruidStealth and bonusBar == 1 then
            local isStealth = self:IsCatStealth()
            if isStealth then
                -- In cat form with stealth active, use travel form bar (bonus bar 4)
                return self.BONUS_BAR_BASE + (4 * 12)
            end
        end
        
        -- Bonus bar slots start at 73 (offset 72)
        -- Formula: 60 + (bonusBar * 12) = offset for first slot
        -- But we use 10 buttons, so: 60 + (bonusBar * 12)
        return self.BONUS_BAR_BASE + (bonusBar * 12)
    end
    
    -- No bonus bar active, use page 1 (slots 1-10)
    return self.PAGE_OFFSETS[1]
end

-- ============================================================================
-- Hide Default Action Bars
-- ============================================================================

local DEFAULT_BAR_FRAMES = {
    "MainMenuBar",
    "MainMenuBarArtFrame",
    "MainMenuExpBar",
    "MainMenuBarMaxLevelBar",
    "ReputationWatchBar",
    "MainMenuBarPerformanceBarFrame",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarLeft",
    "MultiBarRight",
    "BonusActionBarFrame",
    "ShapeshiftBarFrame",
    "PetActionBarFrame",
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "QuestLogMicroButton",
    "SocialsMicroButton",
    "WorldMapMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
}

function ActionBars:HideDefaultBars()
    local i
    for i = 1, table.getn(DEFAULT_BAR_FRAMES) do
        local frame = getglobal(DEFAULT_BAR_FRAMES[i])
        if frame then
            frame:Hide()
        end
    end
end

function ActionBars:RestoreDefaultBars()
    local i
    for i = 1, table.getn(DEFAULT_BAR_FRAMES) do
        local frame = getglobal(DEFAULT_BAR_FRAMES[i])
        if frame then
            frame:Show()
        end
    end
end

function ActionBars:ApplyDefaultBarVisibility()
    local config = ConsoleUI.config
    local hide = true
    if config and config.Get then
        hide = config:Get("hideBlizzardBars")
        if hide == nil then hide = true end
    end
    if hide then
        self:HideDefaultBars()
    else
        self:RestoreDefaultBars()
    end
end

-- ============================================================================
-- Action Button Functions
-- ============================================================================

function ActionBars:GetActionID(button)
    if button.actionSlot then
        return button.actionSlot
    end
    local id = button:GetID()
    if not id or id == 0 then
        local name = button:GetName() or ""
        local _, _, num = string.find(name, "(%d+)$")
        id = tonumber(num) or 0
    end
    return self:GetActionOffset() + id
end

function ActionBars:ButtonOnLoad(button)
    local id = button:GetID()
    if not id or id == 0 then
        local name = button:GetName() or ""
        local _, _, num = string.find(name, "(%d+)$")
        id = tonumber(num) or 0
        button:SetID(id)
    end
    
    -- Initialize button state
    button.flashing = 0
    button.flashtime = 0
    button.rangeTimer = nil
    button.updateTooltip = nil
    
    -- Vertex state tracking (like pfUI: 0=normal, 1=out of range, 2=oom, 3=not usable)
    button.vertexstate = 0
    button.outofrange = nil
    
    -- Create active state glow frame (for casting indicator)
    local activeFrameName = button:GetName().."Active"
    local activeFrame = getglobal(activeFrameName)
    if not activeFrame then
        activeFrame = CreateFrame("Frame", activeFrameName, button)
        activeFrame:SetAllPoints(button)
        activeFrame:SetFrameLevel(button:GetFrameLevel() + 1)
        
        -- Create colored border overlay (like pfUI's active indicator)
        local border = activeFrame:CreateTexture(nil, "OVERLAY")
        border:SetAllPoints(button)
        border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        border:SetBlendMode("ADD")
        border:Hide()
        activeFrame.border = border
        
        -- Create glow overlay using CheckButtonHilight texture
        local glow = activeFrame:CreateTexture(nil, "OVERLAY")
        glow:SetAllPoints(button)
        glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        glow:SetBlendMode("ADD")
        glow:SetAlpha(0.6)
        glow:Hide()
        activeFrame.glow = glow
        
        button.activeFrame = activeFrame
    end
    
    -- Create cooldown frame if it doesn't exist
    local cooldownName = button:GetName().."Cooldown"
    local cooldown = getglobal(cooldownName)
    if not cooldown then
        cooldown = CreateFrame("Model", cooldownName, button, "CooldownFrameTemplate")
        -- Cooldown will be sized in UpdateActionBarLayout to match button
        -- Use SetAllPoints to fill the button
        cooldown:SetAllPoints(button)
    end
    
    -- Set controller icon
    local controllerIcon = getglobal(button:GetName().."ControllerIcon")
    if controllerIcon then
        local buttonIcons = self:GetButtonIcons()
        if buttonIcons[id] then
            controllerIcon:SetTexture(buttonIcons[id])
        end
    end
    
    -- Register for drag and click
    button:RegisterForDrag("LeftButton", "RightButton")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Register events
    button:RegisterEvent("PLAYER_ENTERING_WORLD")
    button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    button:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    button:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    button:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    button:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    button:RegisterEvent("PLAYER_ENTER_COMBAT")
    button:RegisterEvent("PLAYER_LEAVE_COMBAT")
    button:RegisterEvent("PLAYER_AURAS_CHANGED")
    button:RegisterEvent("PLAYER_TARGET_CHANGED")
    button:RegisterEvent("START_AUTOREPEAT_SPELL")
    button:RegisterEvent("STOP_AUTOREPEAT_SPELL")
    button:RegisterEvent("UNIT_INVENTORY_CHANGED")
    button:RegisterEvent("UPDATE_INVENTORY_ALERTS")
end

function ActionBars:UpdateButton(button)
    local actionID = self:GetActionID(button)
    local buttonID = button:GetID()
    local icon = getglobal(button:GetName().."Icon")
    local cooldown = getglobal(button:GetName().."Cooldown")
    local texture = GetActionTexture(actionID)
    
    -- Check if D-pad buttons (5, 6, 7, 8) should be hidden in healer mode
    -- Only hide base D-pad buttons on page 1 (no modifiers), and only when in party/raid
    -- Modified D-pad buttons (Shift/Ctrl) should remain visible
    local shouldHideDPad = false
    if buttonID >= 5 and buttonID <= 8 then
        -- Only hide on page 1 (no modifiers)
        local currentPage = self.currentPage or 1
        if currentPage == 1 then
            local config = ConsoleUI.config
            local healerMode = false
            if config and config.Get then
                healerMode = config:Get("healerMode") or false
            end
            
            if healerMode then
                -- Check if player is in party or raid
                local inParty = GetNumPartyMembers() > 0
                local inRaid = GetNumRaidMembers() > 0
                
                if inParty or inRaid then
                    -- Hide D-pad buttons when in healer mode and in party/raid (page 1 only)
                    shouldHideDPad = true
                end
            end
        end
    end
    
    -- Update controller icon based on current controller type
    local controllerIcon = getglobal(button:GetName().."ControllerIcon")
    if controllerIcon then
        local buttonIcons = self:GetButtonIcons()
        if buttonIcons[buttonID] then
            controllerIcon:SetTexture(buttonIcons[buttonID])
        end
    end
    
    -- Check for proxied actions (like JUMP, AUTORUN, etc.)
    -- These are WoW bindings assigned to controller buttons instead of action bar slots
    local proxiedAction = nil
    local actionSlot = self:GetActionOffset() + buttonID
    
    if ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied then
        if ConsoleUI.proxied:IsSlotProxied(actionSlot) then
            proxiedAction = ConsoleUI.proxied:GetSlotActionInfo(actionSlot)
        end
    end
    
    -- Get appearance setting
    local appearance = "classic"
    if ConsoleUI.config and ConsoleUI.config.Get then
        appearance = ConsoleUI.config:Get("barAppearance") or "classic"
    elseif ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.barAppearance then
        appearance = ConsoleUIDB.config.barAppearance
    end
    
    -- Determine normal texture based on appearance
    local normalTexture = "Interface\\Buttons\\UI-Quickslot2"
    local emptyTexture = "Interface\\Buttons\\UI-Quickslot"
    
    -- If slot has a proxied action, show that icon (priority over action slot)
    if proxiedAction then
        icon:SetTexture(proxiedAction.icon)
        icon:Show()
        button.rangeTimer = nil
        button.isProxiedAction = proxiedAction
        cooldown:Hide()
        -- Stop any flashing/glow effects since this is a proxied action, not an action slot
        self:StopFlash(button)
        self:IdleDiamond(button)
        self:UpdateButtonCount(button)
    elseif texture then
        icon:SetTexture(texture)
        icon:Show()
        button.isProxiedAction = nil
        
        -- Reset range state when updating button
        -- Use -1 to force UpdateButtonUsable to refresh colors (since valid states are 0-3)
        button.outofrange = nil
        button.vertexstate = -1
        
        self:UpdateButtonState(button)
        self:UpdateButtonUsable(button)
        self:UpdateButtonCooldown(button)
        self:UpdateButtonCount(button)
        self:UpdateButtonFlash(button)
        
        -- Initialize range timer for range checking (only if action has range)
        if HasAction(actionID) and ActionHasRange(actionID) then
            button.rangeTimer = self.RANGE_CHECK_TIME
        else
            button.rangeTimer = nil
        end
    else
        icon:Hide()
        cooldown:Hide()
        button.rangeTimer = nil
        button.isProxiedAction = nil
        -- Reset color state for empty slots
        button.outofrange = nil
        button.vertexstate = -1
        -- Reset colors to normal (white) for normalTexture and overlay
        local normalTexture = getglobal(button:GetName().."NormalTexture")
        local overlay = getglobal(button:GetName().."Overlay")
        if normalTexture then
            normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        self:UpdateButtonCount(button)
    end
    
    -- Apply button appearance styling after updating button content
    -- This handles normal texture, icon sizing/positioning, overlay, flash, etc.
    self:ApplyButtonAppearance(button)
    
    -- Show or hide button based on healer mode
    if shouldHideDPad then
        button:Hide()
    else
        -- Always keep button visible so we can drop actions onto it
        button:Show()
    end
    
    -- Update equipped border (only if not a proxied action)
    local border = getglobal(button:GetName().."Border")
    if border then
        if button.isProxiedAction then
            -- Hide border for proxied actions
            border:Hide()
        elseif IsEquippedAction(actionID) then
            border:SetVertexColor(0, 1.0, 0, 0.35)
            border:Show()
        else
            border:Hide()
        end
    end
    
    -- Update tooltip if shown
    if GameTooltip:IsOwned(button) then
        self:SetButtonTooltip(button)
    end
    
    -- Update macro name
    local macroName = getglobal(button:GetName().."Name")
    if macroName then
        if button.isProxiedAction then
            macroName:SetText(button.isProxiedAction.name)
        else
            macroName:SetText(GetActionText(actionID))
        end
    end
end

function ActionBars:SetThinOutline(button, shown)
    if not button.thinOutline then
        local function edge()
            local tex = button:CreateTexture(nil, "OVERLAY")
            tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            tex:SetVertexColor(0.80, 0.86, 0.92, 0.80)
            return tex
        end
        local top = edge()
        top:SetHeight(1)
        top:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        top:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        local bottom = edge()
        bottom:SetHeight(1)
        bottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        bottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        local left = edge()
        left:SetWidth(1)
        left:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        local right = edge()
        right:SetWidth(1)
        right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.thinOutline = { top, bottom, left, right }
    end
    local i
    for i = 1, 4 do
        if shown then
            button.thinOutline[i]:Show()
        else
            button.thinOutline[i]:Hide()
        end
    end
end

function ActionBars:ApplyButtonAppearance(button)
    if self:UsesDiamondChrome(button) then
        self:ApplyDiamondAppearance(button)
        return
    end
    self:ApplySquareAppearance(button)
end


function ActionBars:UpdateButtonState(button)
    local actionID = self:GetActionID(button)
    local active = IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)
    
    if active then
        button:SetChecked(1)
    else
        button:SetChecked(0)
    end

    if self:IsMainBarButton(button) then
        if button.activeFrame then
            if button.activeFrame.glow then
                button.activeFrame.glow:Hide()
            end
            if button.activeFrame.border then
                button.activeFrame.border:Hide()
            end
        end
        if self:HasPlate(button) then
            self:PaintDiamond(button)
        end
        return
    end

    if active then
        if button.activeFrame then
            button.activeFrame.glow:Show()
            if button.activeFrame.border then
                local _, class = UnitClass("player")
                local color = RAID_CLASS_COLORS and class and RAID_CLASS_COLORS[class]
                if color then
                    button.activeFrame.border:SetVertexColor(color.r, color.g, color.b, 1.0)
                else
                    button.activeFrame.border:SetVertexColor(1.0, 1.0, 0.5, 1.0)
                end
                button.activeFrame.border:Show()
            end
        end
    else
        if button.activeFrame then
            button.activeFrame.glow:Hide()
            if button.activeFrame.border then
                button.activeFrame.border:Hide()
            end
        end
    end
end

function ActionBars:UpdateButtonUsable(button)
    local actionID = self:GetActionID(button)
    local icon = getglobal(button:GetName().."Icon")
    local normalTexture = getglobal(button:GetName().."NormalTexture")
    local overlay = getglobal(button:GetName().."Overlay")  -- Modern style overlay
    if not icon then return end
    
    local isUsable, notEnoughMana = IsUsableAction(actionID)
    local newVertexState = 0
    
    -- Check range first (if out of range, show red)
    if button.outofrange then
        newVertexState = 1
        if button.vertexstate ~= 1 then
            icon:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
            if normalTexture then
                normalTexture:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
            end
            if overlay then
                overlay:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
            end
            button.vertexstate = 1
        end
    -- Usable - Blizzard colors from constants
    elseif isUsable then
        newVertexState = 0
        if button.vertexstate ~= 0 then
            icon:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
            if normalTexture then
                normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
            end
            if overlay then
                overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
            end
            button.vertexstate = 0
        end
    -- Not enough mana - Blizzard colors from constants
    elseif notEnoughMana then
        newVertexState = 2
        if button.vertexstate ~= 2 then
            icon:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
            if normalTexture then
                normalTexture:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
            end
            if overlay then
                overlay:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
            end
            button.vertexstate = 2
        end
    -- Not usable - Blizzard behavior: icon gray, border white
    else
        newVertexState = 3
        if button.vertexstate ~= 3 then
            icon:SetVertexColor(self.NA_COLOR[1], self.NA_COLOR[2], self.NA_COLOR[3], self.NA_COLOR[4])
            if normalTexture then
                normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
            end
            if overlay then
                overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
            end
            button.vertexstate = 3
        end
    end
    if self.SliceMask and button._sliceMask then
        self.SliceMask:SyncColor(button)
    end
end

function ActionBars:UpdateButtonCooldown(button)
    local actionID = self:GetActionID(button)
    local cooldown = getglobal(button:GetName().."Cooldown")
    local start, duration, enable = GetActionCooldown(actionID)
    
    -- Hide default square cooldown - we use our own for both styles
    if cooldown then
        cooldown:Hide()
    end
    
    -- Use our cooldown (darkened icon + timer text) for both modern and classic
    if enable == 1 and duration > 0 then
        self:StartCircularCooldown(button, start, duration)
    else
        self:StopCircularCooldown(button)
    end
end

function ActionBars:UpdateButtonCount(button)
    local count = getglobal(button:GetName().."Count")
    if not count then
        return
    end
    if button.isProxiedAction then
        count:SetText("")
        return
    end
    local actionID = self:GetActionID(button)
    if actionID and IsConsumableAction(actionID) then
        local n = GetActionCount(actionID)
        if n and n > 0 then
            count:SetText(n)
        else
            count:SetText("")
        end
    else
        count:SetText("")
    end
end

function ActionBars:UpdateButtonFlash(button)
    local actionID = self:GetActionID(button)
    if (IsAttackAction(actionID) and IsCurrentAction(actionID)) or IsAutoRepeatAction(actionID) then
        self:StartFlash(button)
    else
        self:StopFlash(button)
    end
end

function ActionBars:StartFlash(button)
    button.flashing = 1
    button.flashtime = 0
    self:UpdateButtonState(button)
end

function ActionBars:StopFlash(button)
    button.flashing = 0
    local flash = getglobal(button:GetName().."Flash")
    if flash then
        flash:Hide()
    end
    self:UpdateButtonState(button)
end

function ActionBars:IsFlashing(button)
    return button.flashing == 1
end

-- ============================================================================
-- Event Handler
-- ============================================================================

function ActionBars:ButtonOnEvent(button, event)
    local actionID = self:GetActionID(button)
    
    -- Skip action-related updates if button has a proxied action (like JUMP, AUTORUN)
    local hasProxiedAction = button.isProxiedAction ~= nil
    
    if event == "PLAYER_ENTERING_WORLD" then
        self:UpdateButton(button)
    elseif event == "ACTIONBAR_SLOT_CHANGED" then
        -- Check if this slot change affects any of our pages
        local buttonID = button:GetID()
        for page = 1, self.NUM_PAGES do
            local pageActionID = self.PAGE_OFFSETS[page] + buttonID
            if arg1 == -1 or arg1 == pageActionID then
                if page == self.currentPage then
                    self:UpdateButton(button)
                end
                break
            end
        end
    elseif event == "ACTIONBAR_UPDATE_STATE" then
        if not hasProxiedAction then
            self:UpdateButtonState(button)
        end
    elseif event == "ACTIONBAR_UPDATE_USABLE" then
        if not hasProxiedAction then
            self:UpdateButtonUsable(button)
        end
    elseif event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "UPDATE_INVENTORY_ALERTS" then
        if not hasProxiedAction then
            self:UpdateButtonCooldown(button)
        end
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_AURAS_CHANGED" then
        self:UpdateButton(button)
        if not hasProxiedAction then
            self:UpdateButtonState(button)
            self:UpdateButtonUsable(button)
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            self:UpdateButton(button)
        end
    elseif event == "PLAYER_ENTER_COMBAT" then
        if not hasProxiedAction and IsAttackAction(actionID) then
            self:StartFlash(button)
        end
    elseif event == "PLAYER_LEAVE_COMBAT" then
        if not hasProxiedAction and IsAttackAction(actionID) then
            self:StopFlash(button)
        end
    elseif event == "START_AUTOREPEAT_SPELL" then
        if not hasProxiedAction and IsAutoRepeatAction(actionID) then
            self:StartFlash(button)
        end
    elseif event == "STOP_AUTOREPEAT_SPELL" then
        if not hasProxiedAction and self:IsFlashing(button) and not IsAttackAction(actionID) then
            self:StopFlash(button)
        end
    elseif event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" or event == "UPDATE_SHAPESHIFT_FORMS" then
        -- Stance or form changed - bonus bar offset changes
        -- Need to update all buttons since they now read from different slots
        -- Use a flag to only trigger once per event (all buttons receive the event)
        if not self._bonusBarUpdatePending then
            self._bonusBarUpdatePending = true
            
            local bonusBar = GetBonusBarOffset() or 0
            ConsoleUI_Debug("Form changed - bonus bar: " .. bonusBar)
            
            -- Schedule update for next frame to batch all button updates
            if not self._bonusBarUpdateFrame then
                self._bonusBarUpdateFrame = CreateFrame("Frame")
                self._bonusBarUpdateFrame.actionBars = self  -- Store reference
                self._bonusBarUpdateFrame:SetScript("OnUpdate", function()
                    this:Hide()
                    this.actionBars._bonusBarUpdatePending = false
                    -- Force immediate update of all buttons
                    this.actionBars:UpdateAllButtons()
                end)
            end
            -- Show frame to trigger OnUpdate on next frame
            self._bonusBarUpdateFrame:Show()
            
            -- Also update immediately (in case OnUpdate doesn't fire fast enough)
            self:UpdateAllButtons()
        end
    end
end

-- ============================================================================
-- Update Handler (for flashing, range checking, tooltips)
-- ============================================================================

function ActionBars:ButtonOnUpdate(button, elapsed)
    if self:HasPlate(button) then
        local pushed = button:GetButtonState() == "PUSHED"
        if pushed ~= button._diamondPushed then
            button._diamondPushed = pushed
            self:PaintDiamond(button)
        end
    end
    local actionID = self:GetActionID(button)
    
    -- Don't flash if button has a proxied action (like JUMP, AUTORUN)
    if button.isProxiedAction then
        if self:IsFlashing(button) then
            self:StopFlash(button)
        end
    end
    
    -- Handle flashing (attack/auto-repeat) - skip if proxied action
    if not button.isProxiedAction and self:IsFlashing(button) then
        button.flashtime = button.flashtime - elapsed
        if button.flashtime <= 0 then
            local overtime = -button.flashtime
            if overtime >= self.FLASH_TIME then
                overtime = 0
            end
            button.flashtime = self.FLASH_TIME - overtime
            
            local flash = getglobal(button:GetName().."Flash")
            if flash then
                if flash:IsVisible() then
                    flash:Hide()
                else
                    flash:Show()
                end
            end
        end
    end
    
    -- Handle range checking (like pfUI)
    if button.rangeTimer then
        button.rangeTimer = button.rangeTimer - elapsed
        if button.rangeTimer <= 0 then
            -- Check if action has range and is out of range
            if HasAction(actionID) and ActionHasRange(actionID) then
                local inRange = IsActionInRange(actionID)
                if inRange == 0 then -- Out of range
                    if not button.outofrange then
                        button.outofrange = true
                        self:UpdateButtonUsable(button)
                    end
                else -- In range or nil (no target)
                    if button.outofrange then
                        button.outofrange = nil
                        self:UpdateButtonUsable(button)
                    end
                end
            else
                -- Action doesn't have range, clear out of range state
                if button.outofrange then
                    button.outofrange = nil
                    self:UpdateButtonUsable(button)
                end
            end
            
            -- Update hotkey color (legacy support)
            local hotkey = getglobal(button:GetName().."HotKey")
            if hotkey then
                if button.outofrange then
                    hotkey:SetVertexColor(1.0, 0.1, 0.1)
                else
                    hotkey:SetVertexColor(0.6, 0.6, 0.6)
                end
            end
            
            button.rangeTimer = self.RANGE_CHECK_TIME
        end
    end
    
    -- Handle tooltip updates
    if button.updateTooltip then
        button.updateTooltip = button.updateTooltip - elapsed
        if button.updateTooltip <= 0 then
            if GameTooltip:IsOwned(button) then
                self:SetButtonTooltip(button)
            else
                button.updateTooltip = nil
            end
        end
    end
end

-- ============================================================================
-- Healer Mode Helpers
-- ============================================================================

-- Get unit ID from a party/raid/player frame
function ActionBars:GetUnitFromFrame(frame)
    if not frame then 
        ConsoleUI_Debug("GetUnitFromFrame: frame is nil")
        return nil 
    end
    
    local frameName = frame:GetName()
    if not frameName then 
        ConsoleUI_Debug("GetUnitFromFrame: frame has no name")
        return nil 
    end
    
    ConsoleUI_Debug("GetUnitFromFrame: Checking frame name: " .. frameName)
    
    -- Player frame
    if frameName == "PlayerFrame" then
        ConsoleUI_Debug("GetUnitFromFrame: Matched PlayerFrame -> 'player'")
        return "player"
    end
    
    -- Party frames: PartyMemberFrame1, PartyMemberFrame2, etc.
    local partyStart, partyEnd, partyNumStr = string.find(frameName, "^PartyMemberFrame(%d+)$")
    if partyStart then
        local partyIndex = tonumber(partyNumStr)
        if partyIndex and partyIndex >= 1 and partyIndex <= 4 then
            -- Use GetPartyMember to check if party member exists, then construct unit ID
            local partyMemberIndex = GetPartyMember(partyIndex)
            if partyMemberIndex then
                -- GetPartyMember returns the index (e.g., "1"), construct unit ID as "party" + index
                local unit = "party" .. partyMemberIndex
                ConsoleUI_Debug("GetUnitFromFrame: Matched PartyMemberFrame" .. partyIndex .. " -> GetPartyMember(" .. partyIndex .. ") = '" .. partyMemberIndex .. "', unit = '" .. unit .. "'")
                return unit
            else
                ConsoleUI_Debug("GetUnitFromFrame: PartyMemberFrame" .. partyIndex .. " matched but GetPartyMember(" .. partyIndex .. ") returned nil")
            end
        end
    end
    
    -- Also check for PartyFrame1, PartyFrame2 (alternative naming)
    local partyFrameStart, partyFrameEnd, partyFrameNumStr = string.find(frameName, "^PartyFrame(%d+)$")
    if partyFrameStart then
        local partyIndex = tonumber(partyFrameNumStr)
        if partyIndex and partyIndex >= 1 and partyIndex <= 4 then
            -- Use GetPartyMember to check if party member exists, then construct unit ID
            local partyMemberIndex = GetPartyMember(partyIndex)
            if partyMemberIndex then
                -- GetPartyMember returns the index (e.g., "1"), construct unit ID as "party" + index
                local unit = "party" .. partyMemberIndex
                ConsoleUI_Debug("GetUnitFromFrame: Matched PartyFrame" .. partyIndex .. " -> GetPartyMember(" .. partyIndex .. ") = '" .. partyMemberIndex .. "', unit = '" .. unit .. "'")
                return unit
            else
                ConsoleUI_Debug("GetUnitFromFrame: PartyFrame" .. partyIndex .. " matched but GetPartyMember(" .. partyIndex .. ") returned nil")
            end
        end
    end
    
    -- Raid frames: RaidGroupButton1, RaidGroupButton2, etc.
    local raidStart, raidEnd, raidNumStr = string.find(frameName, "^RaidGroupButton(%d+)$")
    if raidStart then
        local raidIndex = tonumber(raidNumStr)
        if raidIndex and raidIndex >= 1 and raidIndex <= 40 then
            -- For raid, we can use "raid" .. raidIndex directly, but let's verify it exists
            local unit = "raid" .. raidIndex
            local unitName = UnitName(unit)
            if unitName then
                ConsoleUI_Debug("GetUnitFromFrame: Matched RaidGroupButton" .. raidIndex .. " -> '" .. unit .. "' (name: " .. unitName .. ")")
                return unit
            else
                ConsoleUI_Debug("GetUnitFromFrame: RaidGroupButton" .. raidIndex .. " matched but unit '" .. unit .. "' doesn't exist")
            end
        end
    end
    
    ConsoleUI_Debug("GetUnitFromFrame: No match found for frame name: " .. frameName)
    return nil
end

-- Get spell name from action slot (using tooltip method like AutoRank)
function ActionBars:GetSpellNameFromSlot(slot)
    if not HasAction(slot) then return nil end
    
    -- Use tooltip to get spell name (same approach as AutoRank)
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:SetAction(slot)
    GameTooltip:Show()
    
    -- Get first line of tooltip (spell name)
    local tooltipText = getglobal("GameTooltipTextLeft1")
    if tooltipText and tooltipText:IsShown() then
        local spellName = tooltipText:GetText()
        if spellName and spellName ~= "" then
            GameTooltip:Hide()
            return spellName
        end
    end
    
    GameTooltip:Hide()
    return nil
end

-- Check if healer mode is enabled and cursor is over a party/raid/player frame
function ActionBars:ShouldCastOnHealerTarget()
    -- Check if healer mode is enabled
    local config = ConsoleUI.config
    if not config or not config.Get then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: Config not available")
        return false 
    end
    
    local healerMode = config:Get("healerMode")
    if not healerMode then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: Healer mode disabled")
        return false 
    end
    
    ConsoleUI_Debug("ShouldCastOnHealerTarget: Healer mode is enabled")
    
    -- Check if cursor is active and over a party/raid/player frame
    local Cursor = ConsoleUI.cursor
    if not Cursor or not Cursor.navigationState then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: Cursor not available")
        return false 
    end
    
    local currentButton = Cursor.navigationState.currentButton
    if not currentButton then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: No current button")
        return false 
    end
    
    local frameName = currentButton:GetName()
    ConsoleUI_Debug("ShouldCastOnHealerTarget: Current button name: " .. (frameName or "nil"))
    
    -- Check if current button is a party/raid/player frame
    local Hooks = ConsoleUI.hooks
    if not Hooks or not Hooks.IsPartyRaidFrame then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: Hooks not available")
        return false 
    end
    
    if not frameName then 
        ConsoleUI_Debug("ShouldCastOnHealerTarget: Frame has no name")
        return false 
    end
    
    local isPartyRaidFrame = Hooks:IsPartyRaidFrame(frameName)
    ConsoleUI_Debug("ShouldCastOnHealerTarget: IsPartyRaidFrame('" .. frameName .. "') = " .. tostring(isPartyRaidFrame))
    
    return isPartyRaidFrame
end

-- ============================================================================
-- Click and Drag Handlers
-- ============================================================================

function ActionBars:ButtonOnClick(button, mouseButton)
    -- Check if this is a protected proxied action (like JUMP, AUTORUN)
    -- Protected functions can only be executed via keyboard bindings, not mouse clicks in WoW 1.12
    if button.isProxiedAction then
        local bindingID = button.isProxiedAction.id
        if ConsoleUI.proxied and ConsoleUI.proxied.IsProtectedBinding then
            if ConsoleUI.proxied:IsProtectedBinding(bindingID) then
                local actionName = button.isProxiedAction.name or bindingID or "proxied action"
                DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[ConsoleUI]|r " .. actionName .. " can only be used via keyboard binding, not mouse click.")
                return
            end
            -- Non-protected proxied actions (like UI toggles) might work, but we'll let them try
            -- If they fail, it's not a protected function issue
        end
    end
    
    local buttonID = button:GetID()
    local bonusBar = GetBonusBarOffset() or 0
    local currentPage = self.currentPage or 0
    local offset = self:GetActionOffset()
    local actionID = offset + buttonID

    -- Debug output for stance issues
    ConsoleUI_Debug("Click: Btn=" .. buttonID .. " Page=" .. currentPage .. " Bonus=" .. bonusBar .. " Off=" .. offset .. " Slot=" .. actionID .. " Has=" .. tostring(HasAction(actionID)))

    if MacroFrame_SaveMacro then
        MacroFrame_SaveMacro()
    end

    -- Check if healer mode is enabled and cursor is over a party/raid/player frame
    ConsoleUI_Debug("ButtonOnClick: Checking healer mode, actionID=" .. actionID)
    if self:ShouldCastOnHealerTarget() then
        ConsoleUI_Debug("ButtonOnClick: Healer mode check passed")
        local Cursor = ConsoleUI.cursor
        local currentButton = Cursor.navigationState.currentButton
        ConsoleUI_Debug("ButtonOnClick: Current button: " .. (currentButton and (currentButton:GetName() or "unnamed") or "nil"))
        
        local unit = self:GetUnitFromFrame(currentButton)
        ConsoleUI_Debug("ButtonOnClick: Got unit from frame: " .. (unit or "nil"))
        
        if unit then
            -- Verify unit exists
            local unitName = UnitName(unit)
            ConsoleUI_Debug("ButtonOnClick: Unit '" .. unit .. "' name: " .. (unitName or "nil"))
            
            -- Get spell name from action slot
            local spellName = self:GetSpellNameFromSlot(actionID)
            if spellName then
                ConsoleUI_Debug("ButtonOnClick: Got spell name: " .. spellName)
                
                -- Save current target if we have one (and it's not the unit we want to cast on)
                local hadTarget = false
                if UnitName("target") and not UnitIsUnit("target", unit) then
                    hadTarget = true
                    ConsoleUI_Debug("ButtonOnClick: Saving current target before casting")
                end
                
                -- Cast spell by name (this puts us in targeting mode)
                ConsoleUI_Debug("ButtonOnClick: Calling CastSpellByName('" .. spellName .. "')")
                CastSpellByName(spellName)
                
                -- Target the unit
                ConsoleUI_Debug("ButtonOnClick: Calling SpellTargetUnit('" .. unit .. "')")
                SpellTargetUnit(unit)
                
                -- Restore previous target if we had one
                if hadTarget then
                    ConsoleUI_Debug("ButtonOnClick: Restoring previous target")
                    TargetLastTarget()
                end
                
                ConsoleUI_Debug("ButtonOnClick: Healer mode: Casting " .. spellName .. " on " .. unit)
            else
                -- No spell name found, fall back to UseAction
                ConsoleUI_Debug("ButtonOnClick: No spell name found, using UseAction")
                UseAction(actionID, 1)
                
                -- If spell is awaiting target selection, check if we can cast on the unit
                if SpellIsTargeting() then
                    ConsoleUI_Debug("ButtonOnClick: Spell is targeting")
                    -- Check if the spell can target this unit
                    local canTarget = SpellCanTargetUnit(unit)
                    ConsoleUI_Debug("ButtonOnClick: SpellCanTargetUnit('" .. unit .. "') = " .. tostring(canTarget))
                    
                    if canTarget then
                        -- Cast on the unit
                        ConsoleUI_Debug("ButtonOnClick: Calling SpellTargetUnit('" .. unit .. "')")
                        SpellTargetUnit(unit)
                        ConsoleUI_Debug("ButtonOnClick: Healer mode: Casting action " .. actionID .. " on " .. unit)
                    else
                        -- Can't target this unit, let it work normally
                        ConsoleUI_Debug("ButtonOnClick: Healer mode: Cannot cast action " .. actionID .. " on " .. unit .. " (invalid target, using default behavior)")
                    end
                else
                    -- Spell doesn't require targeting (instant cast, self-buff, etc.)
                    ConsoleUI_Debug("ButtonOnClick: Healer mode: Used action " .. actionID .. " (no targeting required)")
                end
            end
            
            -- Always update button state and return (action already used)
            self:UpdateButtonState(button)
            return
        else
            ConsoleUI_Debug("ButtonOnClick: No unit found from frame")
        end
    else
        ConsoleUI_Debug("ButtonOnClick: Healer mode check failed or not applicable")
    end

    -- Normal action use
    UseAction(actionID, 1)
    self:UpdateButtonState(button)
end

function ActionBars:ButtonOnDragStart(button)
    local actionID = self:GetActionID(button)
    PickupAction(actionID)
    self:UpdateButton(button)
end

function ActionBars:ButtonOnReceiveDrag(button)
    local actionID = self:GetActionID(button)
    PlaceAction(actionID)
    button:SetChecked(0)
    self:UpdateButton(button)
end

-- ============================================================================
-- Tooltip
-- ============================================================================

function ActionBars:SetButtonTooltip(button)
    local actionID = self:GetActionID(button)
    
    if GetCVar("UberTooltips") == "1" then
        GameTooltip_SetDefaultAnchor(GameTooltip, button)
    else
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    end
    
    -- Check for proxied action
    if button.isProxiedAction then
        GameTooltip:SetText(button.isProxiedAction.name, 1, 1, 1)
        if button.isProxiedAction.desc then
            GameTooltip:AddLine(button.isProxiedAction.desc, 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine("Bound to: " .. button.isProxiedAction.id, 0.5, 0.5, 0.5)
        GameTooltip:Show()
        button.updateTooltip = nil
    elseif GameTooltip:SetAction(actionID) then
        button.updateTooltip = self.TOOLTIP_UPDATE_TIME
    else
        button.updateTooltip = nil
    end
end

function ActionBars:ButtonOnEnter(button)
    self:SetButtonTooltip(button)
end

-- ============================================================================
-- Utility: Update all buttons
-- ============================================================================

function ActionBars:UpdateAllButtons()
    for i = 1, self.NUM_BUTTONS do
        local button = getglobal("ConsoleActionButton"..i)
        if button then
            self:UpdateButton(button)
        end
    end
end

-- ============================================================================
-- Bag Bar Management
-- ============================================================================

function ActionBars:InitializeBagBar()
    -- Bag bar buttons
    local bagBarButtons = {
        MainMenuBarBackpackButton,
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot,
        KeyRingButton
    }
    
    -- Hide bag bar initially
    self:UpdateBagBarVisibility()
    
    -- Create update frame to periodically check bag state
    if not self.bagBarUpdateFrame then
        self.bagBarUpdateFrame = CreateFrame("Frame")
        self.bagBarUpdateFrame:RegisterEvent("BAG_UPDATE")
        self.bagBarUpdateFrame:SetScript("OnEvent", function()
            ActionBars:UpdateBagBarVisibility()
        end)
        
        -- Also check periodically
        self.bagBarUpdateFrame:SetScript("OnUpdate", function()
            this.updateTimer = (this.updateTimer or 0) + arg1
            if this.updateTimer >= 0.2 then  -- Check every 200ms
                this.updateTimer = 0
                ActionBars:UpdateBagBarVisibility()
            end
        end)
    end
    
    -- Hook ContainerFrame OnShow/OnHide to detect bag open/close
    -- Check up to 5 container frames (backpack + 4 bags)
    for i = 1, 5 do
        local containerFrame = getglobal("ContainerFrame" .. i)
        if containerFrame then
            local oldOnShow = containerFrame:GetScript("OnShow")
            local oldOnHide = containerFrame:GetScript("OnHide")
            
            containerFrame:SetScript("OnShow", function()
                if oldOnShow then oldOnShow() end
                ActionBars:UpdateBagBarVisibility()
            end)
            
            containerFrame:SetScript("OnHide", function()
                if oldOnHide then oldOnHide() end
                ActionBars:UpdateBagBarVisibility()
            end)
        end
    end
    
    -- Hook bag bar buttons for cursor navigation
    for _, button in ipairs(bagBarButtons) do
        if button then
            -- Enable drag and drop
            button:RegisterForDrag("LeftButton")
            button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            
            -- Hook for cursor navigation
            if ConsoleUI.hooks and ConsoleUI.hooks.HookDynamicFrame then
                ConsoleUI.hooks:HookDynamicFrame(button, "Bag Bar Button")
            end
        end
    end
end

function ActionBars:UpdateBagBarVisibility()
    -- Check if any bag is open (check up to 5 container frames)
    local anyBagOpen = false
    for i = 1, 5 do
        local containerFrame = getglobal("ContainerFrame" .. i)
        if containerFrame and containerFrame:IsVisible() then
            anyBagOpen = true
            break
        end
    end
    
    -- Also check using IsBagOpen if available
    if not anyBagOpen then
        for i = 0, 4 do
            if IsBagOpen and IsBagOpen(i) then
                anyBagOpen = true
                break
            end
        end
    end
    
    -- Show/hide and position bag bar at bottom right corner
    if anyBagOpen then
        -- Position bag bar at bottom right corner
        local buttonSize = 30  -- Approximate button size
        local spacing = 5  -- Spacing between buttons
        local bottomY = 20  -- Distance from bottom
        local rightX = 20  -- Distance from right
        
        -- Position buttons from right to left
        local currentX = rightX
        
        -- Backpack button (rightmost)
        if MainMenuBarBackpackButton then 
            MainMenuBarBackpackButton:SetParent(UIParent)
            MainMenuBarBackpackButton:ClearAllPoints()
            MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            MainMenuBarBackpackButton:Show()
            currentX = currentX + buttonSize + spacing
        end
        
        -- Bag slots (right to left: bag 3, 2, 1, 0)
        if CharacterBag3Slot then 
            CharacterBag3Slot:SetParent(UIParent)
            CharacterBag3Slot:ClearAllPoints()
            CharacterBag3Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            CharacterBag3Slot:Show()
            currentX = currentX + buttonSize + spacing
        end
        
        if CharacterBag2Slot then 
            CharacterBag2Slot:SetParent(UIParent)
            CharacterBag2Slot:ClearAllPoints()
            CharacterBag2Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            CharacterBag2Slot:Show()
            currentX = currentX + buttonSize + spacing
        end
        
        if CharacterBag1Slot then 
            CharacterBag1Slot:SetParent(UIParent)
            CharacterBag1Slot:ClearAllPoints()
            CharacterBag1Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            CharacterBag1Slot:Show()
            currentX = currentX + buttonSize + spacing
        end
        
        if CharacterBag0Slot then 
            CharacterBag0Slot:SetParent(UIParent)
            CharacterBag0Slot:ClearAllPoints()
            CharacterBag0Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            CharacterBag0Slot:Show()
            currentX = currentX + buttonSize + spacing
        end
        
        -- Keyring button (leftmost)
        if KeyRingButton then 
            KeyRingButton:SetParent(UIParent)
            KeyRingButton:ClearAllPoints()
            KeyRingButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -currentX, bottomY)
            KeyRingButton:Show()
        end
    else
        if MainMenuBarBackpackButton then MainMenuBarBackpackButton:Hide() end
        if CharacterBag0Slot then CharacterBag0Slot:Hide() end
        if CharacterBag1Slot then CharacterBag1Slot:Hide() end
        if CharacterBag2Slot then CharacterBag2Slot:Hide() end
        if CharacterBag3Slot then CharacterBag3Slot:Hide() end
        if KeyRingButton then KeyRingButton:Hide() end
    end
end

-- ============================================================================
-- Global wrapper functions for XML callbacks
-- These are required because WoW 1.12 XML uses 'this' keyword
-- ============================================================================

function ConsoleActionButton_OnLoad()
    ConsoleUI.actionbars:ButtonOnLoad(this)
end

function ConsoleActionButton_OnEvent(event)
    ConsoleUI.actionbars:ButtonOnEvent(this, event)
end

function ConsoleActionButton_OnUpdate(elapsed)
    ConsoleUI.actionbars:ButtonOnUpdate(this, elapsed)
end

function ConsoleActionButton_OnClick(mouseButton)
    ConsoleUI.actionbars:ButtonOnClick(this, mouseButton)
end

function ConsoleActionButton_OnDragStart()
    ConsoleUI.actionbars:ButtonOnDragStart(this)
end

function ConsoleActionButton_OnReceiveDrag()
    ConsoleUI.actionbars:ButtonOnReceiveDrag(this)
end

function ConsoleActionButton_OnEnter()
    ConsoleUI.actionbars:ButtonOnEnter(this)
end

-- ============================================================================
-- Side Action Bars (Touch Screen)
-- ============================================================================

-- Side bar action slot offsets (using slots 41-50, which are typically unused)
-- Left bar: slots 41-45 (ConsoleUI_ACTION_41 to ConsoleUI_ACTION_45)
-- Right bar: slots 46-50 (ConsoleUI_ACTION_46 to ConsoleUI_ACTION_50)
ActionBars.SIDE_BAR_LEFT_OFFSET = 40   -- Slots 41-45
ActionBars.SIDE_BAR_RIGHT_OFFSET = 45  -- Slots 46-50

-- Storage for side bar buttons
ActionBars.sideBarLeftButtons = {}
ActionBars.sideBarRightButtons = {}
ActionBars.sideBarLeftFrame = nil
ActionBars.sideBarRightFrame = nil

function ActionBars:CreateSideBarButton(parent, buttonIndex, side)
    local offset = side == "left" and self.SIDE_BAR_LEFT_OFFSET or self.SIDE_BAR_RIGHT_OFFSET
    local actionSlot = offset + buttonIndex
    local buttonName = "ConsoleUISideBar" .. side .. "Button" .. buttonIndex
    
    -- Create button frame
    local button = CreateFrame("CheckButton", buttonName, parent)
    button:SetWidth(40)
    button:SetHeight(40)
    button.actionSlot = actionSlot
    button.sideBarIndex = buttonIndex
    button.sideBarSide = side
    
    -- Background texture
    local background = button:CreateTexture(buttonName .. "Background", "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\UI-Quickslot")
    background:SetWidth(64)
    background:SetHeight(64)
    background:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.background = background
    
    -- Icon texture
    local icon = button:CreateTexture(buttonName .. "Icon", "BORDER")
    icon:SetWidth(36)
    icon:SetHeight(36)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.icon = icon
    
    -- Flash texture
    local flash = button:CreateTexture(buttonName .. "Flash", "ARTWORK")
    flash:SetTexture("Interface\\Buttons\\UI-QuickslotRed")
    flash:SetWidth(36)
    flash:SetHeight(36)
    flash:SetPoint("CENTER", button, "CENTER", 0, 0)
    flash:Hide()
    button.flash = flash
    
    -- Count text
    local count = button:CreateFontString(buttonName .. "Count", "ARTWORK", "NumberFontNormal")
    count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button.count = count
    
    -- Normal texture
    local normalTexture = button:CreateTexture(buttonName .. "NormalTexture")
    normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    normalTexture:SetWidth(64)
    normalTexture:SetHeight(64)
    normalTexture:SetPoint("CENTER", button, "CENTER", 0, 0)
    button:SetNormalTexture(normalTexture)
    
    -- Pushed texture
    button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    
    -- Highlight texture
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    
    -- Checked texture
    button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
    
    -- Create cooldown frame
    local cooldown = CreateFrame("Model", buttonName .. "Cooldown", button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    button.cooldown = cooldown
    
    -- Initialize state
    button.flashing = 0
    button.flashtime = 0
    button.rangeTimer = nil
    button.vertexstate = 0
    
    -- Register for clicks and drag
    button:RegisterForDrag("LeftButton", "RightButton")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Register events
    button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    button:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    button:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    button:RegisterEvent("PLAYER_ENTER_COMBAT")
    button:RegisterEvent("PLAYER_LEAVE_COMBAT")
    button:RegisterEvent("UNIT_INVENTORY_CHANGED")
    
    -- Event handler
    button:SetScript("OnEvent", function()
        ActionBars:SideBarButtonOnEvent(this, event)
    end)
    
    -- Update handler
    button:SetScript("OnUpdate", function()
        ActionBars:SideBarButtonOnUpdate(this, arg1)
    end)
    
    -- Click handler
    button:SetScript("OnClick", function()
        ActionBars:SideBarButtonOnClick(this, arg1)
    end)
    
    -- Drag handlers
    button:SetScript("OnDragStart", function()
        if not IsShiftKeyDown() then return end
        PickupAction(this.actionSlot)
        ActionBars:UpdateSideBarButton(this)
    end)
    
    button:SetScript("OnReceiveDrag", function()
        PlaceAction(this.actionSlot)
        ActionBars:UpdateSideBarButton(this)
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        -- Check for proxied action first
        if this.isProxiedAction then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.isProxiedAction.name, 1, 1, 1)
            if this.isProxiedAction.desc then
                GameTooltip:AddLine(this.isProxiedAction.desc, 0.7, 0.7, 0.7)
            end
            GameTooltip:AddLine("System Binding: " .. this.isProxiedAction.id, 0.5, 0.5, 0.5)
            GameTooltip:Show()
        elseif HasAction(this.actionSlot) then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetAction(this.actionSlot)
        end
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return button
end

function ActionBars:SideBarButtonOnEvent(button, event)
    if event == "ACTIONBAR_SLOT_CHANGED" then
        if arg1 == 0 or arg1 == button.actionSlot then
            self:UpdateSideBarButton(button)
        end
    elseif event == "ACTIONBAR_UPDATE_STATE" or 
           event == "ACTIONBAR_UPDATE_USABLE" or
           event == "PLAYER_ENTER_COMBAT" or
           event == "PLAYER_LEAVE_COMBAT" or
           event == "UNIT_INVENTORY_CHANGED" then
        self:UpdateSideBarButton(button)
    elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
        self:UpdateSideBarButtonCooldown(button)
    end
end

function ActionBars:SideBarButtonOnUpdate(button, elapsed)
    -- Range check timer
    if button.rangeTimer then
        button.rangeTimer = button.rangeTimer - elapsed
        if button.rangeTimer <= 0 then
            local inRange = IsActionInRange(button.actionSlot)
            local normalTexture = getglobal(button:GetName() .. "NormalTexture")
            local overlay = getglobal(button:GetName() .. "Overlay")  -- Modern style overlay
            if inRange == 0 then
                -- Out of range: red color (using same constants as main action bar)
                button.icon:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
                if normalTexture then
                    normalTexture:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
                end
                if overlay then
                    overlay:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
                end
                button.outofrange = true
            else
                -- In range: check usability again to get correct color
                button.outofrange = nil
                local isUsable, notEnoughMana = IsUsableAction(button.actionSlot)
                if isUsable then
                    button.icon:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
                    if normalTexture then
                        normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
                    end
                    if overlay then
                        overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
                    end
                elseif notEnoughMana then
                    button.icon:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
                    if normalTexture then
                        normalTexture:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
                    end
                    if overlay then
                        overlay:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
                    end
                else
                    button.icon:SetVertexColor(self.NA_COLOR[1], self.NA_COLOR[2], self.NA_COLOR[3], self.NA_COLOR[4])
                    if normalTexture then
                        normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
                    end
                    if overlay then
                        overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
                    end
                end
            end
            button.rangeTimer = self.RANGE_CHECK_TIME
        end
    end
    
    -- Flashing
    if button.flashing == 1 then
        button.flashtime = button.flashtime - elapsed
        if button.flashtime <= 0 then
            if button.flash:IsVisible() then
                button.flash:Hide()
            else
                button.flash:Show()
            end
            button.flashtime = self.FLASH_TIME
        end
    end
end

function ActionBars:SideBarButtonOnClick(button, mouseButton)
    -- Check for proxied action first
    if button.isProxiedAction then
        local bindingID = button.isProxiedAction.id
        ConsoleUI_Debug("SideBar: Executing proxied action: " .. bindingID)
        
        -- Execute the binding
        -- RunBinding() triggers the WoW binding action
        if RunBinding then
            RunBinding(bindingID)
        end
        return
    end
    
    -- Normal action bar slot behavior
    if mouseButton == "LeftButton" then
        if IsShiftKeyDown() and not CursorHasItem() then
            PickupAction(button.actionSlot)
        else
            UseAction(button.actionSlot, 0, 1)
        end
    elseif mouseButton == "RightButton" then
        UseAction(button.actionSlot, 1, 1)
    end
    self:UpdateSideBarButton(button)
end

function ActionBars:UpdateSideBarButton(button)
    local actionSlot = button.actionSlot
    
    -- Check for proxied actions (like JUMP, AUTORUN, etc.)
    local proxiedAction = nil
    if ConsoleUI.proxied and ConsoleUI.proxied.IsSlotProxied then
        if ConsoleUI.proxied:IsSlotProxied(actionSlot) then
            proxiedAction = ConsoleUI.proxied:GetSlotActionInfo(actionSlot)
        end
    end
    
    -- Store proxied action on button for click handler
    button.isProxiedAction = proxiedAction
    
    local normalTexture = getglobal(button:GetName() .. "NormalTexture")
    local overlay = getglobal(button:GetName() .. "Overlay")  -- Modern style overlay
    
    -- If slot has a proxied action, show that icon (priority over action slot)
    if proxiedAction then
        button.icon:SetTexture(proxiedAction.icon)
        button.icon:Show()
        button:SetAlpha(1.0)
        button.rangeTimer = nil
        button.cooldown:Hide()
        button:SetChecked(0)
        -- Normal colors for proxied actions
        button.icon:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        if normalTexture then
            normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        -- Hide count for proxied actions
        button.count:Hide()
        if self:HasPlate(button) then
            self:PaintDiamond(button)
        end
        return
    end
    
    local texture = GetActionTexture(actionSlot)
    
    if texture then
        button.icon:SetTexture(texture)
        button.icon:Show()
        button:SetAlpha(1.0)
    else
        button.icon:Hide()
        button:SetAlpha(1.0)
    end
    
    -- Update count
    local count = GetActionCount(actionSlot)
    if count > 1 then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end
    
    -- Update usable state - exact Blizzard behavior (using same constants as main action bar)
    local isUsable, notEnoughMana = IsUsableAction(actionSlot)
    
    -- Check range first (if out of range, show red)
    if button.outofrange then
        button.icon:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
        if normalTexture then
            normalTexture:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.RANGE_COLOR[1], self.RANGE_COLOR[2], self.RANGE_COLOR[3], self.RANGE_COLOR[4])
        end
    elseif isUsable then
        -- Usable: icon white, border white
        button.icon:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        if normalTexture then
            normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
    elseif notEnoughMana then
        -- Not enough mana: icon blue, border blue
        button.icon:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
        if normalTexture then
            normalTexture:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.OOM_COLOR[1], self.OOM_COLOR[2], self.OOM_COLOR[3], self.OOM_COLOR[4])
        end
    else
        -- Not usable: icon gray, border white (Blizzard behavior)
        button.icon:SetVertexColor(self.NA_COLOR[1], self.NA_COLOR[2], self.NA_COLOR[3], self.NA_COLOR[4])
        if normalTexture then
            normalTexture:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
        if overlay then
            overlay:SetVertexColor(self.NORMAL_COLOR[1], self.NORMAL_COLOR[2], self.NORMAL_COLOR[3], self.NORMAL_COLOR[4])
        end
    end
    
    -- Update cooldown
    self:UpdateSideBarButtonCooldown(button)
    
    -- Touch bars never show current-action / auto-attack highlight.
    button:SetChecked(0)
    
    -- Start range timer if action has range
    if ActionHasRange(actionSlot) then
        button.rangeTimer = self.RANGE_CHECK_TIME
    else
        button.rangeTimer = nil
    end

    if self:HasPlate(button) then
        self:PaintDiamond(button)
    end
end

function ActionBars:UpdateSideBarButtonCooldown(button)
    local start, duration, enable = GetActionCooldown(button.actionSlot)
    
    -- Hide default square cooldown - we use our own for both styles
    if button.cooldown then
        button.cooldown:Hide()
    end
    
    -- Use our cooldown (darkened icon + timer text) for both modern and classic
    if enable > 0 and duration > 0 and start > 0 then
        self:StartCircularCooldown(button, start, duration)
    else
        self:StopCircularCooldown(button)
    end
end

function ActionBars:CreateSideBars()
    local config = ConsoleUI.config
    if not config then return end
    
    local buttonSize = config:Get("barButtonSize") or 40
    local padding = 5
    
    -- Create left side bar frame
    if not self.sideBarLeftFrame then
        self.sideBarLeftFrame = CreateFrame("Frame", "ConsoleUISideBarLeft", UIParent)
        self.sideBarLeftFrame:SetFrameStrata("MEDIUM")
    end
    
    -- Create right side bar frame
    if not self.sideBarRightFrame then
        self.sideBarRightFrame = CreateFrame("Frame", "ConsoleUISideBarRight", UIParent)
        self.sideBarRightFrame:SetFrameStrata("MEDIUM")
    end
    
    -- Create/update buttons
    self:UpdateSideBars()
end

function ActionBars:UpdateSideBars()
    local config = ConsoleUI.config
    if not config then return end
    
    local buttonSize = config:Get("barButtonSize") or 60
    local padding = config:Get("barPadding") or 65
    local squareStep = padding
    if self.Layout and self.Layout.SquareStep then
        squareStep = self.Layout.SquareStep(buttonSize, padding)
    end
    local appearance = config:Get("barAppearance") or "classic"
    local leftEnabled = config:Get("sideBarLeftEnabled")
    local rightEnabled = config:Get("sideBarRightEnabled")
    local leftCount = config:Get("sideBarLeftButtons") or 3
    local rightCount = config:Get("sideBarRightButtons") or 3
    local leftEdgeOffset = config:Get("sideBarLeftOffset") or 5
    local rightEdgeOffset = config:Get("sideBarRightOffset") or 5
    local leftTouchScale = config:Get("sideBarLeftScale") or 1.0
    local rightTouchScale = config:Get("sideBarRightScale") or 1.0
    -- Side bars use their own scale sliders, not barScale.
    
    -- Clamp counts
    if leftCount < 1 then leftCount = 1 end
    if leftCount > 5 then leftCount = 5 end
    if rightCount < 1 then rightCount = 1 end
    if rightCount > 5 then rightCount = 5 end
    if leftEdgeOffset < 0 then leftEdgeOffset = 0 end
    if rightEdgeOffset < 0 then rightEdgeOffset = 0 end
    if leftTouchScale < 0.5 then leftTouchScale = 0.5 end
    if leftTouchScale > 2.0 then leftTouchScale = 2.0 end
    if rightTouchScale < 0.5 then rightTouchScale = 0.5 end
    if rightTouchScale > 2.0 then rightTouchScale = 2.0 end
    
    -- Release proxied actions for hidden/disabled sidebar slots
    if ConsoleUI.proxied and ConsoleUI.proxied.ReleaseSidebarBindings then
        if leftEnabled then
            -- Release bindings for buttons beyond the current count
            ConsoleUI.proxied:ReleaseSidebarBindings("left", leftCount)
        else
            -- Release all left sidebar bindings when disabled
            ConsoleUI.proxied:ReleaseSidebarAllBindings("left")
        end
        
        if rightEnabled then
            -- Release bindings for buttons beyond the current count
            ConsoleUI.proxied:ReleaseSidebarBindings("right", rightCount)
        else
            -- Release all right sidebar bindings when disabled
            ConsoleUI.proxied:ReleaseSidebarAllBindings("right")
        end
    end
    
    -- Ensure frames exist
    if not self.sideBarLeftFrame then
        self.sideBarLeftFrame = CreateFrame("Frame", "ConsoleUISideBarLeft", UIParent)
        self.sideBarLeftFrame:SetFrameStrata("MEDIUM")
    end
    if not self.sideBarRightFrame then
        self.sideBarRightFrame = CreateFrame("Frame", "ConsoleUISideBarRight", UIParent)
        self.sideBarRightFrame:SetFrameStrata("MEDIUM")
    end
    
    -- Helper function to update button appearance
    local function UpdateButtonAppearance(button, touchScale)
        button:SetWidth(buttonSize)
        button:SetHeight(buttonSize)
        button:SetScale(touchScale)
        
        -- Update icon size
        if button.icon then
            if appearance == "modern" then
                button.icon:SetWidth(buttonSize - 2)
                button.icon:SetHeight(buttonSize - 2)
            else
                button.icon:SetWidth(buttonSize - 4)
                button.icon:SetHeight(buttonSize - 4)
            end
        end
        
        -- Update background size
        if button.background then
            button.background:SetWidth(buttonSize * 1.6)
            button.background:SetHeight(buttonSize * 1.6)
        end
        
        -- Update normal texture size
        local normalTex = getglobal(button:GetName() .. "NormalTexture")
        if normalTex then
            normalTex:SetWidth(buttonSize * 1.6)
            normalTex:SetHeight(buttonSize * 1.6)
        end
        
        -- Update flash size
        if button.flash then
            button.flash:SetWidth(buttonSize - 4)
            button.flash:SetHeight(buttonSize - 4)
        end
        
        -- Update cooldown size
        if button.cooldown then
            local defaultCooldownSize = 36
            local scaleFactor = buttonSize / defaultCooldownSize
            button.cooldown:SetScale(scaleFactor)
        end
        
        -- Apply button appearance styling
        if self.ApplyButtonAppearance then
            self:ApplyButtonAppearance(button)
        end
    end
    
    -- Update left side bar
    if leftEnabled then
        -- Use padding as center-to-center distance (same as main action bar)
        local totalHeight = (squareStep * leftTouchScale) * (leftCount - 1) + (buttonSize * leftTouchScale)
        self.sideBarLeftFrame:SetWidth(buttonSize * leftTouchScale)
        self.sideBarLeftFrame:SetHeight(totalHeight)
        self.sideBarLeftFrame:SetScale(1.0)
        self.sideBarLeftFrame:ClearAllPoints()
        self.sideBarLeftFrame:SetPoint("LEFT", UIParent, "LEFT", leftEdgeOffset, 0)
        self.sideBarLeftFrame:Show()
        
        -- Create/update buttons
        for i = 1, 5 do
            if i <= leftCount then
                if not self.sideBarLeftButtons[i] then
                    self.sideBarLeftButtons[i] = self:CreateSideBarButton(self.sideBarLeftFrame, i, "left")
                end
                local button = self.sideBarLeftButtons[i]
                UpdateButtonAppearance(button, leftTouchScale)
                button:ClearAllPoints()
                -- Position using padding as center-to-center distance, vertically centered
                local yOffset = -((i - 1) * squareStep * leftTouchScale)
                button:SetPoint("TOP", self.sideBarLeftFrame, "TOP", 0, yOffset)
                button:Show()
                self:UpdateSideBarButton(button)
            else
                if self.sideBarLeftButtons[i] then
                    self.sideBarLeftButtons[i]:Hide()
                end
            end
        end
    else
        self.sideBarLeftFrame:Hide()
        for i = 1, 5 do
            if self.sideBarLeftButtons[i] then
                self.sideBarLeftButtons[i]:Hide()
            end
        end
    end
    
    -- Update right side bar
    if rightEnabled then
        -- Use padding as center-to-center distance (same as main action bar)
        local totalHeight = (squareStep * rightTouchScale) * (rightCount - 1) + (buttonSize * rightTouchScale)
        self.sideBarRightFrame:SetWidth(buttonSize * rightTouchScale)
        self.sideBarRightFrame:SetHeight(totalHeight)
        self.sideBarRightFrame:SetScale(1.0)
        self.sideBarRightFrame:ClearAllPoints()
        self.sideBarRightFrame:SetPoint("RIGHT", UIParent, "RIGHT", -rightEdgeOffset, 0)
        self.sideBarRightFrame:Show()
        
        -- Create/update buttons
        for i = 1, 5 do
            if i <= rightCount then
                if not self.sideBarRightButtons[i] then
                    self.sideBarRightButtons[i] = self:CreateSideBarButton(self.sideBarRightFrame, i, "right")
                end
                local button = self.sideBarRightButtons[i]
                UpdateButtonAppearance(button, rightTouchScale)
                button:ClearAllPoints()
                -- Position using padding as center-to-center distance, vertically centered
                local yOffset = -((i - 1) * squareStep * rightTouchScale)
                button:SetPoint("TOP", self.sideBarRightFrame, "TOP", 0, yOffset)
                button:Show()
                self:UpdateSideBarButton(button)
            else
                if self.sideBarRightButtons[i] then
                    self.sideBarRightButtons[i]:Hide()
                end
            end
        end
    else
        self.sideBarRightFrame:Hide()
        for i = 1, 5 do
            if self.sideBarRightButtons[i] then
                self.sideBarRightButtons[i]:Hide()
            end
        end
    end
end

function ActionBars:UpdateAllSideBarButtons()
    for i = 1, 5 do
        if self.sideBarLeftButtons[i] then
            self:UpdateSideBarButton(self.sideBarLeftButtons[i])
        end
        if self.sideBarRightButtons[i] then
            self:UpdateSideBarButton(self.sideBarRightButtons[i])
        end
    end
end
