--[[
    ConsoleUI - Cursor Module
    
    Implements a fake cursor for controller/keyboard UI navigation
]]

-- Create cursor module namespace
ConsoleUI.cursor = ConsoleUI.cursor or {}
local Cursor = ConsoleUI.cursor

-- Create the cursor frame
local CursorFrame = CreateFrame("Frame", "ConsoleUICursor", UIParent)
CursorFrame:SetWidth(32)
CursorFrame:SetHeight(32)
CursorFrame:SetFrameStrata("FULLSCREEN_DIALOG")
CursorFrame:SetFrameLevel(1001)
CursorFrame:Hide()

-- Create cursor texture (pointer)
local cursorTexture = CursorFrame:CreateTexture(nil, "OVERLAY")
cursorTexture:SetTexture("Interface\\CURSOR\\Point")
cursorTexture:SetAllPoints(CursorFrame)
CursorFrame.texture = cursorTexture

-- Create held item texture (shows what's being carried)
local heldItemTexture = CursorFrame:CreateTexture(nil, "ARTWORK")
heldItemTexture:SetWidth(28)
heldItemTexture:SetHeight(28)
heldItemTexture:SetPoint("BOTTOM", CursorFrame, "TOP", 0, -4)
heldItemTexture:Hide()
CursorFrame.heldItemTexture = heldItemTexture

-- Normal cursor texture path
local NORMAL_CURSOR_TEXTURE = "Interface\\CURSOR\\Point"

-- Create highlight texture for current button
local highlightFrame = CreateFrame("Frame", "ConsoleUICursorHighlight", UIParent)
highlightFrame:SetFrameStrata("FULLSCREEN_DIALOG")
highlightFrame:SetFrameLevel(1000)
highlightFrame:Hide()

local highlightTexture = highlightFrame:CreateTexture(nil, "OVERLAY")
highlightTexture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
highlightTexture:SetBlendMode("ADD")
highlightTexture:SetAllPoints(highlightFrame)
highlightTexture:SetVertexColor(1, 1, 0, 0.7)
highlightFrame.texture = highlightTexture

-- Buttons to ignore (money frames, dropdown buttons, etc.)
Cursor.buttonsToIgnore = {
    "[A-Za-z0-9]+MoneyFrameGoldButton",
    "[A-Za-z0-9]+MoneyFrameSilverButton",
    "[A-Za-z0-9]+MoneyFrameCopperButton",
    "FriendsDropDownButton",
    "TabardFrameMoneyFrame.*",
}

-- Special frames that need their children scanned differently
Cursor.specialFrames = {
    "WorldMapFrame",
}

-- Navigation state
Cursor.navigationState = {
    currentButton = nil,
    currentFrame = nil,
    allButtons = {},
    closest = {},
    distances = {},
    activeFrames = {},
    enabled = false,
}

-- Store frame references
Cursor.frame = CursorFrame
Cursor.highlight = highlightFrame

-- Track if cursor is holding something
Cursor.isHoldingItem = false
Cursor.heldItemTexturePath = nil

-- ============================================================================
-- Cursor Item Tracking
-- ============================================================================

-- Call this when we know what texture is being picked up
function Cursor:SetHeldItemTexture(texture)
    local heldTexture = CursorFrame.heldItemTexture
    
    if texture then
        heldTexture:SetTexture(texture)
        heldTexture:Show()
        self.isHoldingItem = true
        self.heldItemTexturePath = texture
        ConsoleUI_Debug("Cursor now holding item with texture")
    else
        heldTexture:Hide()
        self.isHoldingItem = false
        self.heldItemTexturePath = nil
    end
end

-- Clear the held item texture
function Cursor:ClearHeldItemTexture()
    self:SetHeldItemTexture(nil)
end

-- Check and update cursor state (called on update)
function Cursor:UpdateCursorState()
    local heldTexture = CursorFrame.heldItemTexture
    
    -- Check if cursor still has something (using WoW 1.12 functions)
    local hasItem = CursorHasItem()
    local hasSpell = CursorHasSpell()
    local hasMoney = CursorHasMoney and CursorHasMoney()
    
    -- If we have a manually set texture (e.g., for macros), keep showing it
    -- Macros don't trigger CursorHasItem/CursorHasSpell
    if self.heldItemTexturePath then
        if not heldTexture:IsShown() then
            heldTexture:SetTexture(self.heldItemTexturePath)
            heldTexture:Show()
        end
        return  -- Don't auto-clear manually set textures
    end
    
    if hasItem or hasSpell or hasMoney then
        -- Still holding something, keep showing
        if self.heldItemTexturePath and not heldTexture:IsShown() then
            heldTexture:Show()
        end
    else
        -- Nothing held anymore, hide texture
        if self.isHoldingItem then
            self:ClearHeldItemTexture()
            ConsoleUI_Debug("Cursor cleared (dropped/placed)")
        end
    end
end

-- Set up OnUpdate to track cursor state
CursorFrame:SetScript("OnUpdate", function()
    if CursorFrame:IsShown() then
        Cursor:UpdateCursorState()
    end
end)

-- ============================================================================
-- Helper Functions
-- ============================================================================

function Cursor:CalculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

function Cursor:ShouldIgnoreButton(buttonName)
    if not buttonName then return true end
    
    for _, pattern in ipairs(self.buttonsToIgnore) do
        if string.find(buttonName, pattern) then
            return true
        end
    end
    return false
end

-- ============================================================================
-- Interactive Element Collection (Buttons and EditBoxes)
-- ============================================================================

function Cursor:IsInteractiveElement(frame)
    if not frame or not frame:IsVisible() then
        return false
    end
    
    local frameName = frame:GetName() or ""
    
    -- Check if it's a party/raid/player frame (in healer mode, treat these as interactive)
    if ConsoleUI.hooks and ConsoleUI.hooks.IsPartyRaidFrame then
        if ConsoleUI.hooks:IsPartyRaidFrame(frameName) then
            -- Check if healer mode is enabled
            local config = ConsoleUI.config
            if config and config.Get then
                local healerMode = config:Get("healerMode")
                if healerMode then
                    return true
                end
            end
        end
    end
    
    -- Check if it's a Button (has IsEnabled method)
    if frame:IsObjectType("Button") then
        -- For dropdown buttons, always consider them interactive if visible
        if string.find(frameName, "DropdownButton") or string.find(frameName, "DropDownButton") then
            return true
        end
        if frame.IsEnabled and frame:IsEnabled() then
            return true
        end
        -- Also check if button is visible but might not have IsEnabled (some buttons don't)
        if frame:IsVisible() and not frame.IsEnabled then
            return true
        end
    end
    
    -- Check if it's an EditBox (no IsEnabled method, check if shown)
    if frame:IsObjectType("EditBox") then
        return true
    end
    
    -- Check if it's a CheckButton (has IsEnabled method)
    if frame:IsObjectType("CheckButton") then
        if frame.IsEnabled and frame:IsEnabled() then
            return true
        end
    end
    
    -- Check if it's a Slider (no IsEnabled in 1.12, just check visible)
    if frame:IsObjectType("Slider") then
        return true
    end
    
    return false
end

function Cursor:CollectVisibleButtons(frame, buttons)
    buttons = buttons or {}
    
    if not frame or not frame:IsVisible() then
        return buttons
    end
    
    -- Check if this frame is an interactive element (Button, EditBox, CheckButton, Slider)
    if self:IsInteractiveElement(frame) then
        local elementName = frame:GetName() or ""
        
        if not self:ShouldIgnoreButton(elementName) then
            local x, y = frame:GetCenter()
            if x and y then
                local elementType = "button"
                if frame:IsObjectType("EditBox") then
                    elementType = "editbox"
                elseif frame:IsObjectType("Slider") then
                    elementType = "slider"
                elseif frame:IsObjectType("CheckButton") then
                    elementType = "checkbox"
                end
                
                table.insert(buttons, {
                    button = frame,
                    x = x,
                    y = y,
                    name = elementName,
                    text = frame.GetText and frame:GetText() or "",
                    elementType = elementType
                })
            end
        end
    end
    
    -- Recursively check children
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        self:CollectVisibleButtons(child, buttons)
    end
    
    return buttons
end

function Cursor:CollectAllVisibleButtons()
    local allButtons = {}
    
    for frame, _ in pairs(self.navigationState.activeFrames) do
        if frame and frame:IsVisible() then
            local frameButtons = self:CollectVisibleButtons(frame)
            for _, buttonInfo in ipairs(frameButtons) do
                table.insert(allButtons, buttonInfo)
            end
        end
    end
    
    return allButtons
end

function Cursor:FindFirstVisibleButton(frame)
    if not frame or not frame:IsVisible() then
        return nil
    end
    
    -- Check if this frame is an interactive element
    if self:IsInteractiveElement(frame) then
        local elementName = frame:GetName() or ""
        if not self:ShouldIgnoreButton(elementName) then
            return frame
        end
    end
    
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        local button = self:FindFirstVisibleButton(child)
        if button then
            return button
        end
    end
    
    -- For party/raid/player frames in healer mode, return the frame itself even if no children are interactive
    local frameName = frame:GetName() or ""
    if ConsoleUI.hooks and ConsoleUI.hooks.IsPartyRaidFrame then
        if ConsoleUI.hooks:IsPartyRaidFrame(frameName) then
            local config = ConsoleUI.config
            if config and config.Get then
                local healerMode = config:Get("healerMode")
                if healerMode then
                    -- Party/raid/player frames themselves are the interactive element
                    return frame
                end
            end
        end
    end
    
    return nil
end

-- ============================================================================
-- Direction Finding
-- ============================================================================

function Cursor:FindClosestButtons(currentButton, allButtons)
    if not currentButton then return nil, nil end
    
    local currentX, currentY = currentButton:GetCenter()
    if not currentX or not currentY then return nil, nil end
    
    local closest = {
        up = nil,
        down = nil,
        left = nil,
        right = nil
    }
    
    local minDistances = {
        up = 99999,
        down = 99999,
        left = 99999,
        right = 99999
    }
    
    for _, buttonInfo in ipairs(allButtons) do
        if buttonInfo.button ~= currentButton then
            local distance = self:CalculateDistance(currentX, currentY, buttonInfo.x, buttonInfo.y)
            local dx = buttonInfo.x - currentX
            local dy = buttonInfo.y - currentY
            local angle = math.atan2(dy, dx)
            local degrees = angle * 180 / math.pi
            
            -- Define direction zones (45-degree sectors)
            if degrees >= 45 and degrees < 135 then -- Up
                if distance < minDistances.up then
                    minDistances.up = distance
                    closest.up = buttonInfo
                end
            elseif degrees >= -135 and degrees < -45 then -- Down
                if distance < minDistances.down then
                    minDistances.down = distance
                    closest.down = buttonInfo
                end
            elseif (degrees >= 135 and degrees <= 180) or (degrees >= -180 and degrees < -135) then -- Left
                if distance < minDistances.left then
                    minDistances.left = distance
                    closest.left = buttonInfo
                end
            elseif degrees >= -45 and degrees < 45 then -- Right
                if distance < minDistances.right then
                    minDistances.right = distance
                    closest.right = buttonInfo
                end
            end
        end
    end
    
    return closest, minDistances
end

-- ============================================================================
-- Cursor Movement
-- ============================================================================

function Cursor:UpdateCursorPosition(button)
    if not button then
        self.frame:Hide()
        self.highlight:Hide()
        return
    end
    
    if not button.GetCenter then
        self.frame:Hide()
        self.highlight:Hide()
        return
    end
    
    local x, y = button:GetCenter()
    if x and y then
        -- Position cursor at bottom of button
        self.frame:ClearAllPoints()
        self.frame:SetPoint("CENTER", button, "BOTTOM", 8, 0)
        self.frame:Show()
        
        -- Position highlight around button
        local width = button:GetWidth()
        local height = button:GetHeight()
        self.highlight:ClearAllPoints()
        self.highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
        self.highlight:SetWidth(width + 10)
        self.highlight:SetHeight(height + 10)
        self.highlight:Show()
        
        -- Show tooltip
        if ConsoleUI.cursor.tooltip then
            ConsoleUI.cursor.tooltip:ShowButtonTooltip(button)
        end
    else
        self.frame:Hide()
        self.highlight:Hide()
    end
end

-- Find the parent ScrollFrame of a button (if any)
function Cursor:FindParentScrollFrame(button)
    if not button then return nil end

    local parent = button:GetParent()
    local depth = 0
    while parent and depth < 20 do
        if parent.GetScrollChild and parent.SetVerticalScroll and parent.GetVerticalScroll then
            return parent
        end
        parent = parent:GetParent()
        depth = depth + 1
    end
    return nil
end

-- Auto-scroll a ScrollFrame to make a button visible
function Cursor:ScrollToShowButton(button, scrollFrame)
    if not button or not scrollFrame or not scrollFrame.GetVerticalScroll then
        return
    end

    local frameBottom = scrollFrame:GetBottom()
    local frameTop = scrollFrame:GetTop()
    local buttonBottom = button:GetBottom()
    local buttonTop = button:GetTop()
    if not frameBottom or not frameTop or not buttonBottom or not buttonTop then
        return
    end

    local pad = 12
    local current = scrollFrame:GetVerticalScroll()
    local range = 0
    if scrollFrame.GetVerticalScrollRange then
        range = scrollFrame:GetVerticalScrollRange() or 0
    end
    local newScroll = current
    if buttonBottom < frameBottom + pad then
        newScroll = current + (frameBottom + pad - buttonBottom)
    elseif buttonTop > frameTop - pad then
        newScroll = current - (buttonTop - (frameTop - pad))
    else
        return
    end
    if newScroll < 0 then
        newScroll = 0
    end
    if newScroll > range then
        newScroll = range
    end
    scrollFrame:SetVerticalScroll(newScroll)
    local barName = scrollFrame:GetName() and (scrollFrame:GetName() .. "ScrollBar")
    local bar = barName and getglobal(barName)
    if bar and bar.SetValue then
        bar:SetValue(newScroll)
    end
end

function Cursor:MoveCursorToButton(button)
    if not button then return end
    if not button.GetParent then return end
    
    -- Check if we're already on this button - if so, don't do anything (prevents loops)
    if self.navigationState.currentButton == button then
        ConsoleUI_Debug("Already on button, skipping move")
        return
    end
    
    -- Hide tooltip for previous button
    if self.navigationState.currentButton and ConsoleUI.cursor.tooltip then
        ConsoleUI.cursor.tooltip:HideButtonTooltip()
    end
    
    -- Auto-scroll if button is inside a scroll frame and not fully visible
    local scrollFrame = self:FindParentScrollFrame(button)
    if scrollFrame then
        self:ScrollToShowButton(button, scrollFrame)
    end
    
    -- Update state
    self.navigationState.currentButton = button
    
    -- For party/raid/player frames, the button IS the frame, so use the button itself as currentFrame
    -- Otherwise, use the button's parent
    local buttonName = button:GetName() or ""
    local isPartyRaidFrameButton = false
    if ConsoleUI.hooks and ConsoleUI.hooks.IsPartyRaidFrame then
        isPartyRaidFrameButton = ConsoleUI.hooks:IsPartyRaidFrame(buttonName)
    end
    
    if isPartyRaidFrameButton then
        -- Button is the party/raid/player frame itself
        self.navigationState.currentFrame = button
    else
        -- Normal button, use parent frame
        self.navigationState.currentFrame = button:GetParent()
    end
    
    -- Update cursor position
    self:UpdateCursorPosition(button)
    
    -- Apply context-specific bindings for this button
    if ConsoleUI.cursor.tooltip and ConsoleUI.cursor.keybindings then
        local bindings = ConsoleUI.cursor.tooltip:GetBindings(buttonName)
        ConsoleUI.cursor.keybindings:ApplyContextBindings(bindings, button)
    end
    
    -- Update navigation options (use currentFrame we determined above)
    self:UpdateNavigationState(button, self.navigationState.currentFrame)
    
    -- Show tooltip for the button
    if ConsoleUI.cursor.tooltip then
        ConsoleUI.cursor.tooltip:ShowButtonTooltip(button)
    end
end

function Cursor:UpdateNavigationState(button, frame)
    if not button or not frame then return end
    
    self.navigationState.currentButton = button
    self.navigationState.currentFrame = frame
    self.navigationState.allButtons = self:CollectAllVisibleButtons()
    self.navigationState.closest, self.navigationState.distances = self:FindClosestButtons(button, self.navigationState.allButtons)
end

function Cursor:RefreshFrame()
    local frame = self.navigationState.currentFrame
    if not frame then return end
    
    -- Recollect all visible buttons
    self.navigationState.allButtons = self:CollectAllVisibleButtons()
    
    -- If we have a current button, just update navigation state and cursor position
    -- Don't call MoveCursorToButton again (it would trigger save/restore cycle)
    if self.navigationState.currentButton then
        local button = self.navigationState.currentButton
        -- Update navigation state without triggering bindings again
        self:UpdateNavigationState(button, self.navigationState.currentFrame)
        -- Just update cursor position visually
        self:UpdateCursorPosition(button)
    end
end

-- ============================================================================
-- State Management
-- ============================================================================

function Cursor:ClearNavigationState()
    self.navigationState.currentButton = nil
    self.navigationState.currentFrame = nil
    self.navigationState.allButtons = {}
    self.navigationState.closest = {}
    self.navigationState.distances = {}
    self.navigationState.activeFrames = {}
end

function Cursor:EnsureOnTop(frame)
    if frame then
        local frameName = frame:GetName()
        
        -- For WorldMapFrame, parent to it so we render above the fullscreen map
        if frameName == "WorldMapFrame" then
            self.frame:SetParent(frame)
            self.highlight:SetParent(frame)
            -- WorldMapFrame uses FULLSCREEN, we use TOOLTIP to be on top
            self.frame:SetFrameStrata("TOOLTIP")
            self.frame:SetFrameLevel(1001)
            self.highlight:SetFrameStrata("TOOLTIP")
            self.highlight:SetFrameLevel(1000)
            return
        end
    end
    
    -- Default parenting
    self.frame:SetParent(UIParent)
    self.highlight:SetParent(UIParent)
    self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.frame:SetFrameLevel(1001)
    self.highlight:SetFrameStrata("FULLSCREEN_DIALOG")
    self.highlight:SetFrameLevel(1000)
end

function Cursor:Hide()
    self.frame:Hide()
    self.highlight:Hide()
    if GameTooltip then
        GameTooltip:Hide()
    end
end

function Cursor:Show()
    if self.navigationState.currentButton then
        self.frame:Show()
        self.highlight:Show()
    end
end

function Cursor:IsEnabled()
    return self.navigationState.enabled
end

function Cursor:Enable()
    self.navigationState.enabled = true
end

function Cursor:Disable()
    self.navigationState.enabled = false
    self:Hide()
    self:ClearNavigationState()
end

-- Debug function
function Cursor:DebugPrint(msg)
    ConsoleUI_Debug(msg)
end

-- Module loaded silently

