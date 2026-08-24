--[[
    Stance + pet extra-bar self-check.
    lua actionbars/check_extra.lua
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}
if math and not math.mod then
    math.mod = math.fmod
end

local function Fail(ok, name, detail)
    if not ok then
        local msg = "Extra check FAIL: " .. name .. " " .. tostring(detail)
        if ConsoleUI_Debug then
            ConsoleUI_Debug(msg)
        else
            print(msg)
        end
        return false
    end
    return true
end

local function Read(path)
    local fh = io.open(path, "r")
    if not fh then
        return nil
    end
    local src = fh:read("*a")
    fh:close()
    return src
end

local function Run(dir)
    local ok = true
    local extra = Read(dir .. "extra.lua")
    local binds = Read(dir .. "../Bindings.xml")
    local keys = Read(dir .. "../keybindings.lua")
    if not Fail(extra ~= nil, "extra.lua", "missing") then
        return false
    end
    if not Fail(string.find(extra, "TEST_ALWAYS_SHOW") == nil, "no test flag", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "FAKE_STANCE") == nil, "no fake stance", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "UseFake") == nil, "no fake helpers", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "SliceMask:Ensure") == nil, "no slicemask", "found") then
        ok = false
    end
    if not Fail(string.find(extra, 'SetBinding("1"') == nil, "no claim 1", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "ApplySquareAppearance") ~= nil, "square paint", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "UPDATE_BONUS_ACTIONBAR") ~= nil, "bonus bar event", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PaintStanceState") ~= nil, "fast stance paint", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PaintStanceIcon") ~= nil, "stance icon", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "function Extra:HasStanceClass", 1, true) ~= nil, "stance class gate", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "pcall(GetShapeshiftFormInfo", 1, true) ~= nil, "safe stance info", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "UpdateAllButtons") ~= nil, "bar icons with stance", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "diamondRing:Show") ~= nil, "active gold ring", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "GetPetActionCooldown") ~= nil, "pet cooldown", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetSpellBusy") ~= nil, "pet cast busy", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "StartCircularCooldown") ~= nil, "reuse bar cooldown", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "getglobal(texture)", 1, true) ~= nil, "token texture", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, 'Interface\\\\Icons\\\\" .. texture', 1, true) == nil, "no icon prefix", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "TogglePetAutocast") ~= nil, "right click autocast", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, 'TargetUnit("pet")', 1, true) ~= nil, "hub targets pet", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "ClickPetHub") ~= nil, "hub click", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetFollow") ~= nil, "follow command", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetWait") ~= nil, "stay command", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetAttack") ~= nil, "attack command", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PET_ACTION_FOLLOW") ~= nil, "follow token", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "FollowAndDismiss") ~= nil, "follow dismiss", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "function ConsoleUI_PetFollow") ~= nil, "follow fn", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "RunProxiedPetBind") ~= nil, "proxied follow", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "FireStockPetSlot") ~= nil, "stock pet click", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "ModifierHeld") == nil, "no follow wait for LT", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "ArmPendingFollow") == nil, "no deferred follow", "found") then
        ok = false
    end
    if not Fail(string.find(extra, 'GetScript("OnClick")', 1, true) == nil, "no stock OnClick pickup", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "PetActionButtonDown", 1, true) == nil, "no stock button down", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "PickupPetAction", 1, true) == nil, "no pet pickup", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "InstallPetFollowHook") ~= nil, "follow hook", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "_stockPetFollow") ~= nil, "stock follow kept", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "ClassifyPetBlob") ~= nil, "pet kind blob", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "CastPetAction") ~= nil, "stock pet action", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetPassiveMode") ~= nil, "passive mode", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "AutoCastShineTemplate", 1, true) == nil, "no tbc shine template", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "UI-AutoCastableOverlay", 1, true) ~= nil, "blizz overlay", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "UI-AutoCastButton.mdx", 1, true) == nil, "no unscaled autocast model", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "AutoCastDot", 1, true) ~= nil, "autocast dot", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "AUTOCAST_DOTS", 1, true) ~= nil, "four dots", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "textures\\\\hud\\\\White.tga", 1, true) ~= nil, "white dot texture", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, 'SetBlendMode("ADD")', 1, true) ~= nil, "dot blend", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "extraAutoRing") == nil, "no custom auto ring", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "extraGlow") == nil, "no custom glow", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "GetCursorPosition") ~= nil, "cursor drag", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "EnsureMover") ~= nil, "mover overlay", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "StartMoving") == nil, "no StartMoving", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "SetClampedToScreen") == nil, "no screen clamp", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "OnDragStart") == nil, "no OnDragStart", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "RegisterForDrag") == nil, "no RegisterForDrag", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "WireDrag") == nil, "no WireDrag", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "HudOffsetFromText") == nil, "no 500 save", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "ScreenClamp") == nil, "no screen clamp", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "ScreenHalf") == nil, "no screen half", "found") then
        ok = false
    end
    local cfg = Read(dir .. "../config/config.lua")
    if cfg then
        if not Fail(string.find(cfg, "stanceBarScale = 1.0", 1, true) ~= nil, "stance default", "missing") then
            ok = false
        end
        if not Fail(string.find(cfg, "petBarScale = 1.0", 1, true) ~= nil, "pet default", "missing") then
            ok = false
        end
    end
    if binds then
        if not Fail(string.find(binds, "ConsoleUI_STANCE_1", 1, true) ~= nil, "stance bind", "missing") then
            ok = false
        end
        if not Fail(string.find(binds, "ConsoleUI_PET_10", 1, true) ~= nil, "pet bind", "missing") then
            ok = false
        end
        if not Fail(string.find(binds, "ConsoleUI_PET_FOLLOW", 1, true) ~= nil, "follow bind", "missing") then
            ok = false
        end
        if not Fail(string.find(binds, "ConsoleUI_PetFollow()", 1, true) ~= nil, "follow handler", "missing") then
            ok = false
        end
    end
    if keys then
        if not Fail(string.find(keys, "SHIFT-" , 1, true) ~= nil, "shift claim exists", "missing") then
            ok = false
        end
        if not Fail(string.find(keys, 'claim("1", "ConsoleUI_STANCE') == nil, "no stance on 1", "found") then
            ok = false
        end
    end
    if not Fail(string.find(extra, "PetGroupPoint") ~= nil, "bar point", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetPickerPoint") ~= nil, "picker point", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, 'extraKind == "pet"') ~= nil, "no pet gold ring", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "petPicker") ~= nil, "one command stance", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetGroupOf(i)", 1, true) ~= nil, "group by kind", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetSlotGroup") ~= nil, "slot group", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "return a > b") ~= nil, "stance order", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "PetPoint(", 1, true) == nil, "no ring point", "found") then
        ok = false
    end
    if not Fail(string.find(extra, "petBarGrow") ~= nil, "grow setting", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "ClearLines", 1, true) ~= nil, "tip clear", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "GameTooltip:SetPetAction", 1, true) ~= nil, "pet tip api", "missing") then
        ok = false
    end
    if not Fail(string.find(extra, "GameTooltip:SetShapeshift", 1, true) ~= nil, "stance tip api", "missing") then
        ok = false
    end
    local Layout = ConsoleUI.actionbars.Layout
    if Layout and Layout.PetGroupPoint then
        local x, y = Layout.PetGroupPoint("spell", 1, "right")
        if not Fail(math.abs(x - Layout.PetBarFirst()) < 0.2 and math.abs(y) < 0.2, "pet spell first", tostring(x) .. "," .. tostring(y)) then
            ok = false
        end
        local x2, y2 = Layout.PetGroupPoint("spell", 2, "right")
        if not Fail(math.abs(x2 - (x + Layout.PetSquareStep())) < 0.2 and math.abs(y2) < 0.2, "pet spell second", tostring(x2) .. "," .. tostring(y2)) then
            ok = false
        end
        x, y = Layout.PetGroupPoint("action", 1, "right")
        if not Fail(math.abs(x + Layout.PetBarFirst()) < 0.2 and math.abs(y - Layout.PetCommandY()) < 0.2, "pet action first", tostring(x) .. "," .. tostring(y)) then
            ok = false
        end
        x, y = Layout.PetGroupPoint("stance", 1, "right")
        if not Fail(math.abs(x + Layout.PetBarFirst()) < 0.2 and math.abs(y - Layout.PetStanceY()) < 0.2, "pet stance first", tostring(x) .. "," .. tostring(y)) then
            ok = false
        end
        if Layout.PetPickerPoint then
            x, y = Layout.PetPickerPoint("action", 1, "right")
            if not Fail(math.abs(x - (-Layout.PetBarFirst() + Layout.PetSquareStep())) < 0.2 and math.abs(y - Layout.PetCommandY()) < 0.2, "pet action picker", tostring(x) .. "," .. tostring(y)) then
                ok = false
            end
        end
        if not Fail(Layout.SquareIconSize(132) == 118, "hub icon", Layout.SquareIconSize(132)) then
            ok = false
        end
        if not Fail(Layout.AUTOCAST_PULSE == 3.2, "pulse period", Layout.AUTOCAST_PULSE) then
            ok = false
        end
        if not Fail(Layout.AUTOCAST_DOTS == 4, "dot count", tostring(Layout.AUTOCAST_DOTS)) then
            ok = false
        end
        local sx, sy = Layout.SquarePathPoint(0, 24)
        if not Fail(sx == -24 and sy == 24, "dot path start", tostring(sx) .. "," .. tostring(sy)) then
            ok = false
        end
        sx, sy = Layout.SquarePathPoint(0.25, 24)
        if not Fail(sx == 24 and sy == 24, "dot path corner", tostring(sx) .. "," .. tostring(sy)) then
            ok = false
        end
        sx, sy = Layout.SquarePathPoint(0.5, 24)
        if not Fail(sx == 24 and sy == -24, "dot path half", tostring(sx) .. "," .. tostring(sy)) then
            ok = false
        end
        sx, sy = Layout.SquarePathPoint(0.75, 24)
        if not Fail(sx == -24 and sy == -24, "dot path last", tostring(sx) .. "," .. tostring(sy)) then
            ok = false
        end
        if not Fail(Layout.STANCE_BASE == 0.8, "stance base", Layout.STANCE_BASE) then
            ok = false
        end
        if not Fail(Layout.PET_BASE == 0.6, "pet base", Layout.PET_BASE) then
            ok = false
        end
    end
    if not CreateFrame then
        if not ConsoleUI.actionbars.extra then
            dofile(dir .. "extra.lua")
        end
        local Extra = ConsoleUI.actionbars.extra
        if Extra and Extra.ClassifyPetBlob then
            if not Fail(Extra:ClassifyPetBlob("PET_ACTION_FOLLOW") == "follow", "blob follow token", Extra:ClassifyPetBlob("PET_ACTION_FOLLOW")) then
                ok = false
            end
            if not Fail(Extra:ClassifyPetBlob("Follow") == "follow", "blob follow name", Extra:ClassifyPetBlob("Follow")) then
                ok = false
            end
            if not Fail(Extra:ClassifyPetBlob("PET_MODE_AGGRESSIVE") == "aggressive", "blob mode not attack", Extra:ClassifyPetBlob("PET_MODE_AGGRESSIVE")) then
                ok = false
            end
            if not Fail(Extra:ClassifyPetBlob("PET_ACTION_ATTACK") == "attack", "blob attack", Extra:ClassifyPetBlob("PET_ACTION_ATTACK")) then
                ok = false
            end
            if not Fail(Extra:ClassifyPetBlob("Firebolt") == nil, "blob spell", Extra:ClassifyPetBlob("Firebolt")) then
                ok = false
            end
            if not Fail(Extra:ClassifyPetBlob("GROWL") == nil, "blob growl spell", Extra:ClassifyPetBlob("GROWL")) then
                ok = false
            end
            if Extra.GroupOfKind then
                if not Fail(Extra:GroupOfKind("follow") == "action", "kind action", Extra:GroupOfKind("follow")) then
                    ok = false
                end
                if not Fail(Extra:GroupOfKind("aggressive") == "stance", "kind stance", Extra:GroupOfKind("aggressive")) then
                    ok = false
                end
                if not Fail(Extra:GroupOfKind(nil) == "spell", "kind spell", Extra:GroupOfKind(nil)) then
                    ok = false
                end
            end
        else
            if not Fail(false, "blob classifier", "missing") then
                ok = false
            end
        end
    end
    if ok then
        if ConsoleUI_Debug then
            ConsoleUI_Debug("Extra check OK")
        else
            print("Extra check OK")
        end
    end
    return ok
end

if not CreateFrame then
    local path = arg and arg[0]
    local dir = ""
    if path then
        dir = string.gsub(path, "[^/]+$", "")
        if dir == path then
            dir = ""
        end
    end
    if not ConsoleUI.actionbars.Layout then
        dofile(dir .. "layout.lua")
    end
    if not Run(dir) then
        os.exit(1)
    end
end
