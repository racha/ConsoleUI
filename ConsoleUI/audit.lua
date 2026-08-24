--[[
    /cui test — one in-game audit. Writes a copyable report to the Debug log.
    Probes action buttons with UseAction stubbed. Does not cast, loot, sell,
    or persist overlay binds.
]]

local NEED_HOOKS = {
    "InspectFrame",
    "CraftFrame",
    "PetStableFrame",
    "DressUpFrame",
    "StackSplitFrame",
    "CoinPickupFrame",
    "ColorPickerFrame",
    "HonorFrame",
    "BattlefieldFrame",
    "ReadyCheckFrame",
    "BattlefieldMinimap",
}

local FIRE_SLOTS = { 1, 5, 11, 15, 21, 25, 31, 35 }

local function Count(t)
    if not t then
        return 0
    end
    if table.getn then
        return table.getn(t)
    end
    local n = 0
    local k
    for k in pairs(t) do
        n = n + 1
    end
    return n
end

local function Shown(frame)
    return frame and frame.IsShown and frame:IsShown() and true or false
end

local function Exists(frame)
    return frame ~= nil
end

function ConsoleUI:ShowAuditLog()
    local cfg = self.config
    if not cfg then
        return
    end
    if not cfg.frame and cfg.CreateMainFrame then
        cfg:CreateMainFrame()
    end
    if cfg.Show then
        cfg:Show()
    end
    if cfg.ShowSection then
        cfg:ShowSection("debug")
    end
    local waiter = CreateFrame("Frame")
    waiter.elapsed = 0
    waiter:SetScript("OnUpdate", function()
        this.elapsed = this.elapsed + arg1
        if this.elapsed < 0.08 then
            return
        end
        this:Hide()
        if ConsoleUI.config and ConsoleUI.config.RefreshDebugLog then
            ConsoleUI.config:RefreshDebugLog()
        end
        local box = ConsoleUI.config and ConsoleUI.config.debugEditBox
        if box then
            box:SetFocus()
            box:HighlightText()
        end
    end)
    waiter:Show()
end

function ConsoleUI:RunAudit()
    local pass = 0
    local fail = 0
    local warn = 0
    local oldMax = self.debugLogMax
    self.debugLogMax = 800
    if ConsoleUI_ClearDebugLog then
        ConsoleUI_ClearDebugLog()
    else
        self.debugLog = {}
    end

    -- WoW treats |n |r |h |c as chat escapes. Never put | in this log.
    local function clean(s)
        return string.gsub(tostring(s), "|", "/")
    end

    local function line(msg)
        if ConsoleUI_Log then
            ConsoleUI_Log(clean(msg))
        end
    end

    local function ok(name, cond, detail)
        local extra = ""
        if detail ~= nil then
            extra = "  " .. clean(detail)
        end
        if cond then
            pass = pass + 1
            line("PASS  " .. name .. extra)
        else
            fail = fail + 1
            line("FAIL  " .. name .. extra)
        end
    end

    local function soft(name, detail)
        warn = warn + 1
        line("WARN  " .. name .. "  " .. clean(detail))
    end

    local function info(name, detail)
        line("INFO  " .. name .. "  " .. clean(detail))
    end

    local function run(name, fn)
        local good, err = pcall(fn)
        if not good then
            fail = fail + 1
            line("FAIL  " .. name .. "  error=" .. clean(err))
        end
    end

    line("CUI-AUDIT BEGIN")
    line("CUI-AUDIT COPY_START")

    run("core", function()
        local addonVersion = "1.0.0-RC5"
        if GetAddOnMetadata then
            addonVersion = GetAddOnMetadata("ConsoleUI", "Version") or addonVersion
        end
        local version, build, date, toc = "?", "?", "?", "?"
        if GetBuildInfo then
            version, build, date, toc = GetBuildInfo()
        end
        info("addon", addonVersion)
        info("client", tostring(version) .. "|build=" .. tostring(build) .. "|toc=" .. tostring(toc) .. "|date=" .. tostring(date))
        local tocOk = toc == 11200 or tostring(toc) == "11200"
        if not tocOk and (toc == nil or toc == "" or toc == "?") then
            tocOk = string.find(tostring(version), "^1%.1") ~= nil
        end
        ok("interface", tocOk, "toc=" .. tostring(toc) .. " ver=" .. tostring(version))
        local locale = GetLocale and GetLocale() or "?"
        info("locale", locale)
        local class = "?"
        if UnitClass then
            local _, token = UnitClass("player")
            class = token or "?"
        end
        info("player", tostring(UnitName and UnitName("player")) .. "|class=" .. class .. "|level=" .. tostring(UnitLevel and UnitLevel("player")))
        info("combat", tostring(UnitAffectingCombat and UnitAffectingCombat("player")))
        info("shift", tostring(IsShiftKeyDown and IsShiftKeyDown()))
        info("ctrl", tostring(IsControlKeyDown and IsControlKeyDown()))
        if IsShiftKeyDown and (IsShiftKeyDown() or IsControlKeyDown()) then
            soft("modifiers held", "release LT/LB before reading page-1 fire")
        end
        local dual = false
        if IsAddOnLoaded then
            if IsAddOnLoaded("ConsoleExperienceClassic") or IsAddOnLoaded("ConsoleExperience") then
                dual = true
            end
        end
        if getglobal("ConsoleExperience") then
            dual = true
        end
        ok("solo addon", not dual, dual and "ConsoleExperience also loaded" or "ok")
        local cfg = self.config
        info("layout", tostring(cfg and cfg:Get("barLayout")))
        info("appearance", tostring(cfg and cfg:Get("barAppearance")))
        info("gold", tostring(cfg and cfg:Get("barGoldBorder")))
        info("glyphs", tostring(cfg and cfg:Get("barActionGlyphs")))
        info("controller", tostring(cfg and cfg:Get("controllerType")))
        info("debug", tostring(cfg and cfg:Get("debugEnabled")))
        info("bind set", tostring(GetCurrentBindingSet and GetCurrentBindingSet()))
        ok("binds ready", not ConsoleUI_BindingsReady or ConsoleUI_BindingsReady(), "GetCurrentBindingSet")
    end)

    run("modules", function()
        ok("module bars", self.actionbars ~= nil)
        ok("module cursor", self.cursor ~= nil)
        ok("module radial", self.radial ~= nil)
        ok("module rings", self.rings ~= nil)
        ok("module loot", self.loot ~= nil)
        ok("module unit", self.unit ~= nil)
        ok("module hint", self.cursor and self.cursor.hintbar ~= nil)
        ok("module xpbar", self.xpbar ~= nil)
        ok("module castbar", self.castbar ~= nil)
        ok("module extra", self.actionbars and self.actionbars.extra ~= nil)
        ok("module placement", self.placement ~= nil)
        ok("module hooks", self.hooks ~= nil)
        ok("module proxied", self.proxied ~= nil)
        ok("fn ActionButton", ConsoleUI_ActionButton ~= nil)
        ok("fn ParkPad", ConsoleUI_ParkTransientPadKeys ~= nil)
        ok("fn RepairPad", ConsoleUIKeybindings and ConsoleUIKeybindings.RepairPadGameplay ~= nil)
        ok("fn ModifierKey", ConsoleUI_ModifierKeyForSlot ~= nil)
        local i
        for i = 1, 10 do
            local button = getglobal("ConsoleActionButton" .. i)
            ok("button " .. i, Exists(button), button and ("shown=" .. tostring(Shown(button))) or "MISSING")
        end
        if self.rings and self.rings.CreateFrame then
            self.rings:CreateFrame()
        end
        if self.unit and self.unit.Ensure then
            self.unit:Ensure()
        end
        ok("frame radial", Exists(getglobal("ConsoleUIRadialMenu")))
        ok("frame ring", Exists(getglobal("ConsoleUIUserRing")) or (self.rings and self.rings.CreateFrame ~= nil))
        ok("frame loot", Exists(getglobal("ConsoleUILootFrame")))
        ok("frame unit", Exists(getglobal("ConsoleUIUnitMenu")) or (self.unit and self.unit.Ensure ~= nil))
        ok("frame hint", Exists(getglobal("ConsoleUIHintBar")))
        ok("frame xp", Exists(getglobal("ConsoleUIExperienceBar")) or (self.config and self.config:Get("xpBarEnabled") == false), "disabled ok")
        ok("frame cast", Exists(getglobal("ConsoleUICastBar")) or (self.config and self.config:Get("castbarEnabled") == false), "disabled ok")
        ok("frame stance", Exists(getglobal("ConsoleUIStanceBar")))
        ok("frame pet", Exists(getglobal("ConsoleUIPetBar")))
    end)

    run("bindings", function()
        local function wanted(slot)
            if ConsoleUI_PadWantedAction then
                return ConsoleUI_PadWantedAction(slot)
            end
            return "ConsoleUI_ACTION_" .. slot
        end
        local function keyFor(slot)
            if slot >= 11 then
                return ConsoleUI_ModifierKeyForSlot(slot)
            end
            if slot == 10 then
                return "0"
            end
            return tostring(slot)
        end
        ok("modkey 11", ConsoleUI_ModifierKeyForSlot(11) == "SHIFT-1", ConsoleUI_ModifierKeyForSlot(11))
        ok("modkey 15", ConsoleUI_ModifierKeyForSlot(15) == "SHIFT-5", ConsoleUI_ModifierKeyForSlot(15))
        ok("modkey 21", ConsoleUI_ModifierKeyForSlot(21) == "CTRL-1", ConsoleUI_ModifierKeyForSlot(21))
        ok("modkey 25", ConsoleUI_ModifierKeyForSlot(25) == "CTRL-5", ConsoleUI_ModifierKeyForSlot(25))
        ok("modkey 31", ConsoleUI_ModifierKeyForSlot(31) == "CTRL-SHIFT-1", ConsoleUI_ModifierKeyForSlot(31))
        ok("modkey 35", ConsoleUI_ModifierKeyForSlot(35) == "CTRL-SHIFT-5", ConsoleUI_ModifierKeyForSlot(35))
        ok("modkey 20", ConsoleUI_ModifierKeyForSlot(20) == "SHIFT-0", ConsoleUI_ModifierKeyForSlot(20))
        ok("modkey 40", ConsoleUI_ModifierKeyForSlot(40) == "CTRL-SHIFT-0", ConsoleUI_ModifierKeyForSlot(40))

        local cursorOn = self.cursor and self.cursor.keybindings
            and self.cursor.keybindings.IsCursorModeActive
            and self.cursor.keybindings:IsCursorModeActive()
        info("cursor mode", tostring(cursorOn))
        local leftovers = 0
        local slot
        for slot = 1, 40 do
            local key = keyFor(slot)
            local bind = (key and GetBindingAction and GetBindingAction(key)) or ""
            local want = wanted(slot)
            local proxy = ConsoleUIDB and ConsoleUIDB.proxiedActions and ConsoleUIDB.proxiedActions[slot]
            local transient = ConsoleUI_IsTransientPadAction and ConsoleUI_IsTransientPadAction(bind)
            local cursorBind = string.find(bind, "^ConsoleUI_CURSOR")
            if transient and cursorOn and cursorBind then
                info("bind " .. key, "cursor owns " .. bind)
            elseif transient then
                leftovers = leftovers + 1
                ok("bind " .. key, false, "leftover=" .. bind)
            else
                local bindOk = bind == want or (proxy and bind == proxy)
                if slot <= 4 and not bindOk and bind ~= "" then
                    bindOk = not string.find(bind, "^ConsoleUI_")
                end
                if slot >= 5 then
                    ok("bind " .. key, bindOk, "got=" .. bind .. " want=" .. want .. " proxy=" .. tostring(proxy))
                else
                    info("bind " .. key, bind)
                end
            end
            local has = HasAction and HasAction(slot)
            local tex = GetActionTexture and GetActionTexture(slot)
            info("slot " .. slot, "has=" .. tostring(has) .. " tex=" .. tostring(tex) .. " bind=" .. bind)
            if slot == 11 or slot == 15 or slot == 21 or slot == 25 or slot == 31 or slot == 35 then
                if not has then
                    soft("empty " .. key, "place a spell to test a live cast")
                end
            end
        end
        ok("no leftover pad", leftovers == 0, leftovers)
        info("move W", tostring(GetBindingAction("W")))
        info("move A", tostring(GetBindingAction("A")))
        info("move S", tostring(GetBindingAction("S")))
        info("move D", tostring(GetBindingAction("D")))
        info("mouse1", tostring(GetBindingAction("BUTTON1")))
        info("mouse2", tostring(GetBindingAction("BUTTON2")))
        info("cam", tostring(GetBindingKey and GetBindingKey("CAMERAORSELECTORMOVE")))
        info("turn", tostring(GetBindingKey and GetBindingKey("TURNORACTION")))
    end)

    run("gates", function()
        local chat = ConsoleUI_ChatBlocksActions and ConsoleUI_ChatBlocksActions()
        local lootBusy = self.loot and self.loot.Busy and self.loot:Busy()
        local unitBusy = self.unit and self.unit.Busy and self.unit:Busy()
        local radialOpen = self.radial and self.radial.IsOpen and self.radial:IsOpen()
        local ringOpen = self.rings and self.rings.IsVisible and self.rings:IsVisible()
        local kbOpen = ConsoleUIKeyboard and ConsoleUIKeyboard.IsShown and ConsoleUIKeyboard:IsShown()
        info("gate chat", tostring(chat))
        info("gate loot", tostring(lootBusy))
        info("gate unit", tostring(unitBusy))
        info("gate radial", tostring(radialOpen))
        info("gate ring", tostring(ringOpen))
        info("gate keyboard", tostring(kbOpen))
        info("keystate", tostring(keystate))
        local busy = chat or lootBusy or unitBusy or radialOpen or ringOpen or kbOpen
        if busy then
            soft("overlay open", "close it and run /cui test again for fire probes")
        else
            ok("gates idle", true)
        end
        local hint = self.cursor and self.cursor.hintbar
        if hint and hint.OverlayBusy then
            ok("hint overlay includes keyboard", not kbOpen or hint:OverlayBusy(), "OverlayBusy=" .. tostring(hint:OverlayBusy()))
        end
    end)

    run("fire", function()
        if not UseAction or not ConsoleUI_ActionButton then
            ok("fire ready", false, "UseAction or ActionButton missing")
            return
        end
        local chat = ConsoleUI_ChatBlocksActions and ConsoleUI_ChatBlocksActions()
        local lootBusy = self.loot and self.loot.Busy and self.loot:Busy()
        local unitBusy = self.unit and self.unit.Busy and self.unit:Busy()
        if chat or lootBusy or unitBusy then
            soft("fire skipped", "chat or overlay owns the pad")
            return
        end
        local oldUse = UseAction
        local oldSpell = SpellTargetUnit
        local oldKey = keystate
        local function Probe(slot, ks)
            local got = {}
            keystate = ks
            UseAction = function(id)
                table.insert(got, id)
            end
            if SpellTargetUnit then
                SpellTargetUnit = function() end
            end
            local good, err = pcall(ConsoleUI_ActionButton, slot)
            UseAction = oldUse
            if SpellTargetUnit then
                SpellTargetUnit = oldSpell
            end
            local expect = slot
            if slot >= 1 and slot <= 10 and self.actionbars and self.actionbars.GetActionOffset then
                expect = (self.actionbars:GetActionOffset() or 0) + slot
            end
            local n = Count(got)
            local first = got[1]
            local tag = "fire " .. slot
            if ks == "up" then
                tag = "fire-up " .. slot
            end
            ok(tag, good and n == 1 and first == expect,
                "ok=" .. tostring(good) .. "|n=" .. n .. "|got=" .. tostring(first) .. "|expect=" .. expect .. "|has=" .. tostring(HasAction and HasAction(expect)) .. "|keystate=" .. tostring(ks) .. "|err=" .. tostring(err))
        end
        local i
        for i = 1, Count(FIRE_SLOTS) do
            Probe(FIRE_SLOTS[i], "down")
        end
        local upSlots = { 11, 15, 21, 25, 31, 35 }
        for i = 1, Count(upSlots) do
            Probe(upSlots[i], "up")
        end
        UseAction = oldUse
        if SpellTargetUnit then
            SpellTargetUnit = oldSpell
        end
        keystate = oldKey
    end)

    run("layout", function()
        local bars = self.actionbars
        if bars and bars.SelfCheckLayout then
            ok("selfcheck layout", bars:SelfCheckLayout())
        else
            ok("selfcheck layout", false, "missing")
        end
        if bars and bars.GetActionID then
            local side = { actionSlot = 43, sideBarIndex = 3 }
            ok("GetActionID side", bars:GetActionID(side) == 43, bars:GetActionID(side))
            local clone = { actionSlot = 11, GetID = function() return 1 end }
            ok("GetActionID clone", bars:GetActionID(clone) == 11, bars:GetActionID(clone))
        end
        if bars and bars.GetCurrentModifierPage and bars.GetActionOffset then
            local page = bars:GetCurrentModifierPage()
            local offset = bars:GetActionOffset()
            info("page", tostring(page) .. "|offset=" .. tostring(offset) .. "|stale=" .. tostring(bars.currentPage))
            if page > 1 then
                ok("live offset", offset == (bars.PAGE_OFFSETS and bars.PAGE_OFFSETS[page]), offset)
            end
        end
        local kind = bars and bars.BarLayoutKind and bars:BarLayoutKind()
        info("bar kind", tostring(kind))
        local fullL = getglobal("ConsoleActionButtonFullL1")
        local fullR = getglobal("ConsoleActionButtonFullR1")
        if fullL or fullR then
            ok("full L1", not fullL or (bars:GetActionID(fullL) == 21 or bars:GetActionID(fullL) == 20 + 1), fullL and bars:GetActionID(fullL))
            ok("full R1", not fullR or bars:GetActionID(fullR) == 11, fullR and bars:GetActionID(fullR))
        else
            info("full clones", "absent (not Full layout)")
        end
        local lay = bars and bars.Layout
        if lay then
            ok("pet hub 132", lay.PET_HUB == 132, lay.PET_HUB)
            ok("hit 56", lay.HIT == 56, lay.HIT)
        end
    end)

    run("loot", function()
        local loot = self.loot
        ok("loot module", loot ~= nil)
        if loot then
            ok("loot wash scale", loot.WASH_SCALE == 1.1, loot.WASH_SCALE)
            ok("loot wash a", loot.WASH_A == 0.70, loot.WASH_A)
            ok("loot wash deep", loot.WASH_DEEP_A == 0.10, loot.WASH_DEEP_A)
            ok("loot restore", loot.RestorePad ~= nil)
            ok("loot consume", loot.ConsumePad ~= nil)
            info("loot enabled", tostring(self.config and self.config:Get("lootFrameEnabled")))
            info("roll enabled", tostring(self.config and self.config:Get("lootRollEnabled")))
            info("loot busy", tostring(loot.Busy and loot:Busy()))
        end
        local unit = self.unit
        if unit then
            ok("unit wash a", unit.WASH_A == 0.70, unit.WASH_A)
            ok("unit wash deep", unit.WASH_DEEP_A == 0.10, unit.WASH_DEEP_A)
        end
        local hint = self.cursor and self.cursor.hintbar
        if hint then
            ok("hint wash a", hint.WASH_A == 0.70, hint.WASH_A)
            ok("hint wash deep", hint.WASH_DEEP_A == 0.10, hint.WASH_DEEP_A)
        end
    end)

    run("unit", function()
        local unit = self.unit
        ok("unit module", unit ~= nil)
        if not unit then
            return
        end
        ok("unit restore", unit.RestorePad ~= nil)
        ok("unit consume", unit.ConsumePad ~= nil)
        ok("unit build", unit.BuildTarget ~= nil and unit.BuildPlayer ~= nil)
        local hasTarget = UnitExists and UnitExists("target")
        info("target", tostring(hasTarget) .. "|name=" .. tostring(UnitName and UnitName("target")) .. "|player=" .. tostring(UnitIsPlayer and hasTarget and UnitIsPlayer("target")) .. "|friend=" .. tostring(UnitIsFriend and hasTarget and UnitIsFriend("player", "target")))
        if unit.BuildTarget and hasTarget then
            unit.unit = "target"
            local rows = unit:BuildTarget()
            local names = ""
            local i
            for i = 1, Count(rows) do
                if i > 1 then
                    names = names .. ","
                end
                names = names .. tostring(rows[i].text)
            end
            info("unit rows", Count(rows) .. "|" .. names)
            if UnitIsPlayer and UnitIsPlayer("target") and UnitIsFriend and UnitIsFriend("player", "target") then
                ok("unit social rows", Count(rows) > 0, Count(rows))
            end
        elseif unit.BuildPlayer then
            local rows = unit:BuildPlayer()
            info("unit self rows", Count(rows))
            if not unit:InGroup() then
                ok("unit empty self", Count(rows) == 0, Count(rows))
            end
        end
    end)

    run("rings", function()
        local rings = self.rings
        local radial = self.radial
        ok("rings module", rings ~= nil)
        if rings and rings.SelfCheck then
            ok("selfcheck rings", rings:SelfCheck())
        else
            ok("selfcheck rings", false, "missing")
        end
        if radial and radial.SLICE_MIDS then
            local expect = { 90, 45, 0, 315, 270, 225, 180, 135 }
            local i
            local good = true
            for i = 1, 8 do
                if radial.SLICE_MIDS[i] ~= expect[i] then
                    good = false
                end
            end
            ok("slice mids", good)
        end
        local cfg = self.config
        ok("ring clear chip", ConsoleUI.BuildRingsSection ~= nil)
        info("radial open", tostring(radial and radial.IsOpen and radial:IsOpen()))
        info("ring open", tostring(rings and rings.IsVisible and rings:IsVisible()))
        if rings and rings.List then
            local list = rings:List()
            info("ring count", Count(list))
        end
    end)

    run("extra", function()
        local extra = self.actionbars and self.actionbars.extra
        ok("extra module", extra ~= nil)
        if not extra then
            return
        end
        local forms = GetNumShapeshiftForms and (GetNumShapeshiftForms() or 0) or 0
        local petBar = PetHasActionBar and PetHasActionBar()
        local stanceShown = Shown(extra.stanceHost)
        local petShown = Shown(extra.petHost)
        info("forms", forms)
        info("pet bar", tostring(petBar))
        info("stance shown", tostring(stanceShown))
        info("pet shown", tostring(petShown))
        if extra.stanceHost then
            ok("stance vis", (forms > 0) == stanceShown, "forms=" .. forms .. " shown=" .. tostring(stanceShown))
        else
            soft("stance host", "not created yet")
        end
        if extra.petHost then
            ok("pet vis", (petBar and true or false) == (petShown and true or false), "api=" .. tostring(petBar) .. " shown=" .. tostring(petShown))
        else
            soft("pet host", "not created yet")
        end
        ok("pet commands", extra.RunPetCommand ~= nil and extra.FollowAndDismiss ~= nil and extra.FireStockPetSlot ~= nil and extra.ClickPetHub ~= nil)
        if extra.InstallPetFollowHook then
            extra:InstallPetFollowHook()
        end
        ok("follow hook", extra._petFollowHooked == true or not PetFollow, "hooked=" .. tostring(extra._petFollowHooked))
        local followKey = GetBindingKey and GetBindingKey("ConsoleUI_PET_FOLLOW")
        local nativeFollow = GetBindingKey and GetBindingKey("PETFOLLOW")
        info("follow bind", tostring(followKey))
        if nativeFollow then
            soft("native PETFOLLOW", nativeFollow)
        end
        if petBar and (not followKey or followKey == "") then
            soft("follow bind missing", "LT+B must be ConsoleUI_PET_FOLLOW")
        end
        if GetPetActionInfo and petBar then
            local name2, _, tex2, token2 = GetPetActionInfo(2)
            local kind = extra.PetKindOf and extra:PetKindOf(2)
            info("pet follow slot", "name=" .. tostring(name2) .. " tex=" .. tostring(tex2) .. " token=" .. tostring(token2) .. " kind=" .. tostring(kind))
            if kind then
                ok("follow kind", kind == "follow", tostring(kind))
            end
        end
        ok("tooltips", extra.StanceTooltip ~= nil and extra.PetTooltip ~= nil)
    end)

    run("hud", function()
        local cfg = self.config
        info("xp on", tostring(cfg and cfg:Get("xpBarAlways")))
        info("rep on", tostring(cfg and cfg:Get("repBarAlways")))
        info("cast on", tostring(cfg and cfg:Get("castbarEnabled")))
        info("xp y", tostring(cfg and cfg:Get("xpBarOffsetY")))
        info("cast y", tostring(cfg and cfg:Get("castbarOffsetY")))
        info("cast h", tostring(cfg and cfg:Get("castbarHeight")))
        local xp = getglobal("ConsoleUIExperienceBar")
        local cast = getglobal("ConsoleUICastBar")
        if xp then
            info("xp size", tostring(xp:GetWidth()) .. "x" .. tostring(xp:GetHeight()) .. " shown=" .. tostring(Shown(xp)))
        end
        if cast then
            info("cast size", tostring(cast:GetWidth()) .. "x" .. tostring(cast:GetHeight()) .. " shown=" .. tostring(Shown(cast)))
        end
        local staleSell = ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.autoSellGreys
        local staleRepair = ConsoleUIDB and ConsoleUIDB.config and ConsoleUIDB.config.autoRepair
        if ConsoleUIDB and ConsoleUIDB.config then
            ConsoleUIDB.config.autoSellGreys = nil
            ConsoleUIDB.config.autoRepair = nil
        end
        if staleSell then
            soft("stale auto sell", "cleared leftover saved var")
        else
            ok("no auto sell", true)
        end
        if staleRepair then
            soft("stale auto repair", "cleared leftover saved var")
        else
            ok("no auto repair", true)
        end
        ok("vendor bags fn", self.hooks and self.hooks.OnVendorInteraction ~= nil)
        ok("all bags fn", self.hooks and self.hooks.ToggleAllBags ~= nil)
    end)

    run("keyboard", function()
        if not ConsoleUIKeyboard then
            soft("keyboard", "addon not loaded")
            return
        end
        ok("keyboard frame", true, "shown=" .. tostring(Shown(ConsoleUIKeyboard)))
        if ConsoleUIKeyboard.RunSelfCheck then
            local good, fails = ConsoleUIKeyboard:RunSelfCheck(false)
            ok("selfcheck keyboard", good, good and "ok" or Count(fails) .. " fails")
            if not good and fails then
                local i
                for i = 1, Count(fails) do
                    line("FAIL  keyboard  " .. tostring(fails[i]))
                end
            end
        else
            ok("selfcheck keyboard", false, "missing")
        end
        ok("steal 69", ConsoleUIKeyboard.StealCount == 69, ConsoleUIKeyboard.StealCount)
    end)

    run("cursor", function()
        local cursor = self.cursor
        ok("cursor module", cursor ~= nil)
        ok("scroll into view", cursor and cursor.ScrollParentsToShow ~= nil)
        local hooks = self.hooks
        ok("hooks listed", hooks and hooks.frames ~= nil)
        if hooks and hooks.frames then
            local found = {}
            local i
            for i = 1, Count(hooks.frames) do
                local row = hooks.frames[i]
                if row then
                    found[row.frame] = true
                end
            end
            for i = 1, Count(NEED_HOOKS) do
                local name = NEED_HOOKS[i]
                ok("hook " .. name, found[name] == true)
            end
        end
        info("cursor mode", tostring(self.cursor and self.cursor.keybindings and self.cursor.keybindings.IsCursorModeActive and self.cursor.keybindings:IsCursorModeActive()))
        info("hint on", tostring(self.config and self.config:Get("hintBarEnabled")))
        info("hint pos", tostring(self.config and self.config:Get("hintBarPosition")))
        info("hint scale", tostring(self.config and self.config:Get("hintBarScale")))
    end)

    run("compat", function()
        if IsAddOnLoaded then
            info("Quiver", tostring(IsAddOnLoaded("Quiver")))
            info("SAS", tostring(IsAddOnLoaded("SimpleActionSets")))
            info("MMM", tostring(IsAddOnLoaded("ModernMapMarkers")))
            info("CEC", tostring(IsAddOnLoaded("ConsoleExperienceClassic")))
            info("pfUI", tostring(IsAddOnLoaded("pfUI")))
            info("keyboard addon", tostring(IsAddOnLoaded("ConsoleUIKeyboard")))
        end
        ok("optional deps listed", true, "Quiver SAS MMM")
    end)

    line("CUI-AUDIT RESULT pass=" .. pass .. " fail=" .. fail .. " warn=" .. warn)
    local result = "PASS"
    if fail > 0 then
        result = "FAIL"
    end
    line("CUI-AUDIT RESULT=" .. result)
    line("CUI-AUDIT COPY_END")
    line("CUI-AUDIT END")

    if ConsoleUIDB then
        ConsoleUIDB.auditReport = ConsoleUI_GetDebugLog and ConsoleUI_GetDebugLog() or nil
        ConsoleUIDB.auditResult = result
        ConsoleUIDB.auditPass = pass
        ConsoleUIDB.auditFail = fail
        ConsoleUIDB.auditWarn = warn
    end
    self.debugLogMax = oldMax or 400

    ConsoleUI_Print("Audit " .. result .. "  pass=" .. pass .. " fail=" .. fail .. " warn=" .. warn .. ". Select All, copy, paste here.")
    local castHint = {}
    local labels = {
        [11] = "LT+A",
        [15] = "LT+Down",
        [21] = "LB+A",
        [25] = "LB+Down",
        [31] = "LT+LB+A",
        [35] = "LT+LB+Down",
    }
    local liveSlots = { 11, 15, 21, 25, 31, 35 }
    local si
    for si = 1, 6 do
        local slot = liveSlots[si]
        if HasAction and HasAction(slot) then
            table.insert(castHint, labels[slot])
        end
    end
    if table.getn(castHint) > 0 then
        ConsoleUI_Print("Close settings. Cast: " .. table.concat(castHint, ", "))
    else
        ConsoleUI_Print("Close settings. Place spells on LT/LB slots, then cast them.")
    end
    if PetHasActionBar and PetHasActionBar() then
        local followKey = GetBindingKey and GetBindingKey("ConsoleUI_PET_FOLLOW")
        if followKey and followKey ~= "" then
            ConsoleUI_Print("Pet out. Attack then Follow (" .. followKey .. "). Pet must drop the target.")
        else
            ConsoleUI_Print("Pet Follow pad bind missing. Click Follow on the pet bar.")
        end
    end
    ConsoleUI_Print("Open Unit Menu. Wash must be 70 percent black.")
    self:ShowAuditLog()
    return fail == 0, pass, fail, warn
end
