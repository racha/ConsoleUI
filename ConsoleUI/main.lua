--[[
    ConsoleUI
    A controller-style action bar for WoW 1.12
    
    Main entry point - creates the ConsoleUI global frame
    that other modules attach to.
]]

_G = getfenv(0)

-- Create the main addon frame
ConsoleUI = CreateFrame("Frame", nil, UIParent)
ConsoleUI:RegisterEvent("ADDON_LOADED")
ConsoleUI:RegisterEvent("VARIABLES_LOADED")
ConsoleUI:RegisterEvent("PLAYER_ENTERING_WORLD")
ConsoleUI:RegisterEvent("PLAYER_LOGOUT")

-- Configuration storage (saved variables)
ConsoleUIDB = ConsoleUIDB or {}

ConsoleUI:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 == "ConsoleExperienceClassic" or arg1 == "ConsoleExperience" then
            ConsoleUI_WarnIfDualAddonLoaded()
        end
        
        if arg1 == "ConsoleUI" then
            -- Initialize configuration if it doesn't exist
            if ConsoleUIDB == nil then
                ConsoleUIDB = {}
            end
        end
        
    elseif event == "VARIABLES_LOADED" then
        -- Initialize config DB with defaults
        if ConsoleUI.config and ConsoleUI.config.InitializeDB then
            ConsoleUI.config:InitializeDB()
        end
        
        -- Initialize action bars after saved variables are loaded
        if ConsoleUI.actionbars and ConsoleUI.actionbars.Initialize then
            ConsoleUI.actionbars:Initialize()
        end
        
        -- Initialize auto spell rank module
        if ConsoleUI.autorank and ConsoleUI.autorank.Initialize then
            ConsoleUI.autorank:Initialize()
        end
        
        -- Initialize cursor tooltip module
        if ConsoleUI.cursor and ConsoleUI.cursor.tooltip and ConsoleUI.cursor.tooltip.Initialize then
            ConsoleUI.cursor.tooltip:Initialize()
        end
        
        -- Initialize frame hooks for cursor navigation
        if ConsoleUI.hooks and ConsoleUI.hooks.Initialize then
            ConsoleUI.hooks:Initialize()
        end
        
        -- Initialize radial menu
        if ConsoleUI.radial and ConsoleUI.radial.Initialize then
            ConsoleUI.radial:Initialize()
        end
        
        -- Initialize placement frame
        if ConsoleUI.placement and ConsoleUI.placement.Initialize then
            ConsoleUI.placement:Initialize()
        end
        
        ConsoleUI_WarnIfDualAddonLoaded()
        
        -- Initialize XP/Rep bar module
        if ConsoleUI.xpbar and ConsoleUI.xpbar.Initialize then
            ConsoleUI.xpbar:Initialize()
        end
        
        -- Initialize cast bar module
        if ConsoleUI.castbar and ConsoleUI.castbar.Initialize then
            ConsoleUI.castbar:Initialize()
        end
        
        ConsoleUI_Debug("ConsoleUI loaded!")
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Re-initialize action bars on zone changes/reloads
        if ConsoleUI.actionbars and ConsoleUI.actionbars.OnPlayerEnteringWorld then
            ConsoleUI.actionbars:OnPlayerEnteringWorld()
        end
        
        -- Setup keybindings on PLAYER_ENTERING_WORLD (later than VARIABLES_LOADED)
        -- Only run once, not on every zone change
        if not ConsoleUI.keybindingsInitialized then
            ConsoleUI.keybindingsInitialized = true
            if ConsoleUI.keybindings and ConsoleUI.keybindings.Initialize then
                ConsoleUI.keybindings:Initialize()
            end
        end
        if ConsoleUI.radial and ConsoleUI.radial.EnsureOverlayMatchesFrame then
            ConsoleUI.radial:EnsureOverlayMatchesFrame()
        end
        if ConsoleUI.rings and ConsoleUI.rings.EnsureOverlayMatchesFrame then
            ConsoleUI.rings:EnsureOverlayMatchesFrame()
        end
        if ConsoleUI_RepairCameraBindings and ConsoleUI_RepairCameraBindings() then
            ConsoleUI_SaveBindings()
        end
        ConsoleUI_Welcome()
        if ConsoleUI.onboarding and ConsoleUI.onboarding.MaybeShowFirstRun then
            ConsoleUI.onboarding:MaybeShowFirstRun()
        end
        if ConsoleUI.changelog and ConsoleUI.changelog.MaybeShow then
            ConsoleUI.changelog:MaybeShow()
        end
        
    elseif event == "PLAYER_LOGOUT" then
        -- Save configuration
        ConsoleUIDB = ConsoleUIDB
    end
end)

-- In-memory log for /cui → Debug. Copy from the EditBox; do not scrape chat.
ConsoleUI.debugLog = ConsoleUI.debugLog or {}
ConsoleUI.debugLogMax = 400

function ConsoleUI_Log(msg)
    local text = tostring(msg)
    if date then
        text = date("%H:%M:%S") .. "  " .. text
    end
    table.insert(ConsoleUI.debugLog, text)
    while table.getn(ConsoleUI.debugLog) > ConsoleUI.debugLogMax do
        table.remove(ConsoleUI.debugLog, 1)
    end
end

function ConsoleUI_GetDebugLog()
    if not ConsoleUI.debugLog or table.getn(ConsoleUI.debugLog) == 0 then
        return ""
    end
    return table.concat(ConsoleUI.debugLog, "\n")
end

function ConsoleUI_ClearDebugLog()
    ConsoleUI.debugLog = {}
end

-- Debug function - only prints if debug is enabled in config
function ConsoleUI:Debug(msg)
    ConsoleUI_Debug(msg)
end

-- Global shortcut for debug
function ConsoleUI_Debug(msg)
    if ConsoleUI.config and ConsoleUI.config:Get("debugEnabled") then
        ConsoleUI_Log(msg)
    end
end

-- Hold-left = move camera, hold-right = turn. Vanilla defaults.
-- After the ConsoleUI rename, SetupDefaultBindings ran again and could
-- SaveBindings before mouse keys were in memory, wiping both.
function ConsoleUI_RepairCameraBindings()
    if ConsoleUI_BindingsReady and not ConsoleUI_BindingsReady() then
        return false
    end
    local function missing(action)
        local key = GetBindingKey(action)
        return not key or key == ""
    end
    local function free(key)
        local current = GetBindingAction(key)
        return not current or current == ""
    end
    local changed = false
    if missing("CAMERAORSELECTORMOVE") and free("BUTTON1") then
        SetBinding("BUTTON1", "CAMERAORSELECTORMOVE")
        changed = true
        ConsoleUI_Debug("Restored BUTTON1 to CAMERAORSELECTORMOVE")
    end
    if missing("TURNORACTION") and free("BUTTON2") then
        SetBinding("BUTTON2", "TURNORACTION")
        changed = true
        ConsoleUI_Debug("Restored BUTTON2 to TURNORACTION")
    end
    return changed
end

-- Persist bindings to the set the player is actually using.
-- TOC settings are per-character; SaveBindings(1) would leak JUMP/interact to alts.
function ConsoleUI_SaveBindings()
    if ConsoleUI_BindingsReady and not ConsoleUI_BindingsReady() then
        ConsoleUI_Debug("Skipped SaveBindings; player bindings not loaded yet")
        return false
    end
    -- 1.12 only accepts 1 (account) or 2 (character). GetCurrentBindingSet()
    -- can return 0 before bindings are ready; Lua treats 0 as truthy.
    local set = 1
    if GetCurrentBindingSet then
        local current = GetCurrentBindingSet()
        if current == 2 then
            set = 2
        end
    end
    -- Radial steals WASD / face keys in-memory. Persist those and a reload
    -- leaves the player unable to walk.
    local radial = ConsoleUI.radial
    local rings = ConsoleUI.rings
    local stickWasOn = radial and radial.stickBindings
    local menuOpen = radial and radial.IsOpen and radial:IsOpen()
    local ringOpen = rings and rings.IsVisible and rings:IsVisible()
    if stickWasOn then
        radial:RestoreStickNavigation()
    end
    SaveBindings(set)
    -- Re-steal only for a live wheel. A leftover shown frame plus cursor
    -- teardown was re-arming ConsoleUI_RADIAL_* after vendors /cui.
    if stickWasOn and menuOpen then
        radial:ActivateStickNavigation()
    elseif stickWasOn and ringOpen then
        radial:ActivateRingNavigation()
    end
end

function ConsoleUI_WarnIfDualAddonLoaded()
    if ConsoleUI.dualAddonWarned then return end
    local other = false
    if IsAddOnLoaded then
        if IsAddOnLoaded("ConsoleExperienceClassic") or IsAddOnLoaded("ConsoleExperience") then
            other = true
        end
    end
    if getglobal("ConsoleExperience") then
        other = true
    end
    if other then
        ConsoleUI.dualAddonWarned = true
        ConsoleUI_Print("Another controller addon is also loaded. Disable it — both fight over bars, bindings, and the cursor.")
    end
end

-- Print function - always prints (for important messages)
function ConsoleUI:Print(msg)
    ConsoleUI_Print(msg)
end

function ConsoleUI_Print(msg)
    ConsoleUI_Log(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd12e[ConsoleUI]|r " .. tostring(msg))
end

function ConsoleUI_PrintDebug(msg)
    if ConsoleUI.config and ConsoleUI.config:Get("debugEnabled") then
        ConsoleUI_Print(msg)
    end
end

function ConsoleUI_Welcome()
    if ConsoleUI.welcomed then return end
    ConsoleUI.welcomed = true
    local version = "1.0.0-RC3"
    if GetAddOnMetadata then
        version = GetAddOnMetadata("ConsoleUI", "Version") or version
    end
    local text = "v" .. version .. " loaded. Type /cui for settings."
    if ConsoleUI.locale and ConsoleUI.locale.T then
        text = string.format(ConsoleUI.locale.T("v%s loaded. Type /cui for settings."), version)
    end
    ConsoleUI_Print(text)
end

-- Paste the complete chat output from /cui debug into a test report.
-- Kept to APIs available in the 1.12 client.
function ConsoleUI:ReportDiagnostics()
    local version, build, date, toc = GetBuildInfo()
    local cfg = self.config
    ConsoleUI_Print("ConsoleUI-DIAG|BEGIN")
    ConsoleUI_Print("ConsoleUI-DIAG|client=" .. tostring(version) .. "|build=" .. tostring(build) .. "|toc=" .. tostring(toc))
    ConsoleUI_Print("ConsoleUI-DIAG|appearance=" .. tostring(cfg and cfg:Get("barAppearance")) .. "|layout=" .. tostring(cfg and cfg:Get("barLayout")) .. "|gold=" .. tostring(cfg and cfg:Get("barGoldBorder")) .. "|controller=" .. tostring(cfg and cfg:Get("controllerType")) .. "|debug=" .. tostring(cfg and cfg:Get("debugEnabled")))
    if self.actionbars and self.actionbars.SelfCheckLayout then
        ConsoleUI_Print("ConsoleUI-DIAG|layoutCheck=" .. tostring(self.actionbars:SelfCheckLayout()))
    end
    ConsoleUI_Print("ConsoleUI-DIAG|modules=bars:" .. tostring(self.actionbars ~= nil) .. ",cursor:" .. tostring(self.cursor ~= nil) .. ",radial:" .. tostring(self.radial ~= nil) .. ",xpbar:" .. tostring(self.xpbar ~= nil) .. ",castbar:" .. tostring(self.castbar ~= nil))
    local radial = self.radial
    ConsoleUI_Print("ConsoleUI-DIAG|radial=vis:" .. tostring(radial and radial:IsVisible()) .. ",dir:" .. tostring(radial and radial.GetSelectedDirectionID and radial:GetSelectedDirectionID() or "none"))
    ConsoleUI_Print("ConsoleUI-DIAG|bind W=" .. tostring(GetBindingAction("W")) .. "|A=" .. tostring(GetBindingAction("A")) .. "|S=" .. tostring(GetBindingAction("S")) .. "|D=" .. tostring(GetBindingAction("D")) .. "|1=" .. tostring(GetBindingAction("1")))
    ConsoleUI_Print("ConsoleUI-DIAG|mouse BUTTON1=" .. tostring(GetBindingAction("BUTTON1")) .. "|BUTTON2=" .. tostring(GetBindingAction("BUTTON2")) .. "|cam=" .. tostring(GetBindingKey("CAMERAORSELECTORMOVE")) .. "|turn=" .. tostring(GetBindingKey("TURNORACTION")))
    local overlay = radial and radial.overlay
    local ringOverlay = self.rings and self.rings.overlay
    ConsoleUI_Print("ConsoleUI-DIAG|overlay=" .. tostring(overlay and overlay:IsShown()) .. "|ringOverlay=" .. tostring(ringOverlay and ringOverlay:IsShown()))
    if ConsoleUIKeyboard then
        ConsoleUI_Print("ConsoleUI-DIAG|kb=" .. tostring(ConsoleUIKeyboard:IsShown()) .. "|stolen=" .. tostring(ConsoleUIKeyboard.stolen ~= nil))
    end
    for id = 1, 10 do
        local button = getglobal("ConsoleActionButton" .. id)
        if button then
            local actionID = self.actionbars and self.actionbars:GetActionID(button) or "?"
            local point, relativeTo, relativePoint, x, y = button:GetPoint()
            local texture = GetActionTexture and GetActionTexture(actionID) or nil
            ConsoleUI_Print("ConsoleUI-DIAG|button=" .. id .. "|shown=" .. tostring(button:IsShown()) .. "|action=" .. tostring(actionID) .. "|hasAction=" .. tostring(HasAction(actionID)) .. "|point=" .. tostring(point) .. "," .. tostring(x) .. "," .. tostring(y) .. "|texture=" .. tostring(texture))
        else
            ConsoleUI_Print("ConsoleUI-DIAG|button=" .. id .. "|MISSING")
        end
    end
    ConsoleUI_Print("ConsoleUI-DIAG|END")
end

-- Debug slash command to get frame name under mouse
SLASH_CONSOLEUIFRAME1 = "/cuiframe"
SlashCmdList["CONSOLEUIFRAME"] = function(msg)
    local frame = GetMouseFocus()
    if frame then
        local name = frame:GetName() or "(unnamed)"
        local objType = frame:GetObjectType() or "unknown"
        local parent = frame:GetParent()
        local parentName = parent and (parent:GetName() or "(unnamed parent)") or "none"
        
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd12e[ConsoleUI Frame]|r")
        DEFAULT_CHAT_FRAME:AddMessage("  Name: |cffffcc00" .. name .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("  Type: |cff88ccff" .. objType .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("  Parent: |cffcccccc" .. parentName .. "|r")
        
        -- Try to get texture info
        local textureInfo = nil
        
        -- If frame itself is a texture
        if frame.GetTexture and frame:GetTexture() then
            textureInfo = frame:GetTexture()
        end
        
        -- Try to find textures in common child elements
        if not textureInfo then
            -- Check for icon texture (common in buttons)
            local iconName = name and (name .. "Icon")
            local iconTex = iconName and getglobal(iconName)
            if iconTex and iconTex.GetTexture then
                textureInfo = iconTex:GetTexture()
            end
        end
        
        if not textureInfo then
            -- Check NormalTexture (buttons)
            if frame.GetNormalTexture then
                local normalTex = frame:GetNormalTexture()
                if normalTex and normalTex.GetTexture then
                    textureInfo = normalTex:GetTexture()
                end
            end
        end
        
        if not textureInfo then
            -- Scan all regions for textures
            local regions = { frame:GetRegions() }
            for _, region in ipairs(regions) do
                if region and region:GetObjectType() == "Texture" and region.GetTexture then
                    local tex = region:GetTexture()
                    if tex and tex ~= "" then
                        textureInfo = tex
                        break
                    end
                end
            end
        end
        
        if textureInfo then
            DEFAULT_CHAT_FRAME:AddMessage("  Texture: |cff88ff88" .. tostring(textureInfo) .. "|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("  Texture: |cff888888(none found)|r")
        end
        
        -- Also show in a popup for easy copying
        if msg == "copy" then
            -- Create a simple editbox for copying
            if not ConsoleUI_FrameCopyBox then
                local f = CreateFrame("Frame", "ConsoleUI_FrameCopyBox", UIParent)
                f:SetWidth(300)
                f:SetHeight(50)
                f:SetPoint("CENTER")
                f:SetFrameStrata("DIALOG")
                f:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 32, edgeSize = 16,
                    insets = { left = 5, right = 5, top = 5, bottom = 5 }
                })
                f:EnableMouse(true)
                
                local eb = CreateFrame("EditBox", nil, f)
                eb:SetPoint("TOPLEFT", 10, -10)
                eb:SetPoint("BOTTOMRIGHT", -10, 10)
                eb:SetFontObject(GameFontNormal)
                eb:SetAutoFocus(true)
                eb:SetScript("OnEscapePressed", function() f:Hide() end)
                f.editBox = eb
            end
            local copyText = textureInfo or name
            ConsoleUI_FrameCopyBox.editBox:SetText(copyText)
            ConsoleUI_FrameCopyBox.editBox:HighlightText()
            ConsoleUI_FrameCopyBox:Show()
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd12e[ConsoleUI Frame]|r No frame under mouse")
    end
end
