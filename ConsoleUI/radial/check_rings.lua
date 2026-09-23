--[[
    One self-check for user rings. Call ConsoleUI.rings:SelfCheck().
    lua radial/check_rings.lua also runs the headless source checks.
]]

local function Fail(name, detail)
    ConsoleUI_Debug("Rings check FAIL: " .. name .. " " .. tostring(detail))
end

local function AttachSelfCheck()
    local Rings = ConsoleUI and ConsoleUI.rings
    if not Rings then
        return
    end
    function Rings:SelfCheck()
    local ok = true
    local i
    for i = 1, 8 do
        if self:BindingID(i) ~= ("ConsoleUI_RING_" .. i) then
            Fail("BindingID", i)
            ok = false
        end
        if self:ParseBindingID("ConsoleUI_RING_" .. i) ~= i then
            Fail("ParseBindingID", i)
            ok = false
        end
    end
    if self:ParseBindingID("JUMP") ~= nil then
        Fail("ParseBindingID junk", "JUMP")
        ok = false
    end
    if self:UseEntry(nil) ~= false then
        Fail("UseEntry nil", "expected false")
        ok = false
    end
    if self:UseEntry({}) ~= false then
        Fail("UseEntry empty", "expected false")
        ok = false
    end
    if self:CountItem(nil) ~= 0 then
        Fail("CountItem nil", "expected 0")
        ok = false
    end
    if self:CountItem({ kind = "spell", name = "Fireball" }) ~= 0 then
        Fail("CountItem spell", "expected 0")
        ok = false
    end
    local Radial = ConsoleUI.radial
    if Radial and Radial.SLICE_MIDS then
        local expect = { 90, 45, 0, 315, 270, 225, 180, 135 }
        for i = 1, 8 do
            if Radial.SLICE_MIDS[i] ~= expect[i] then
                Fail("SLICE_MIDS", i)
                ok = false
            end
        end
    end

    local created = self:CreateRing("CheckRing")
    if created then
        if not ConsoleUIDB.proxiedActions then
            ConsoleUIDB.proxiedActions = {}
        end
        ConsoleUIDB.proxiedActions[99] = self:BindingID(created)
        self:DeleteRing(created)
        if ConsoleUIDB.proxiedActions[99] ~= nil then
            Fail("DeleteRing unbind", tostring(ConsoleUIDB.proxiedActions[99]))
            ok = false
        end
        ConsoleUIDB.proxiedActions[99] = nil
    end

    local Proxied = ConsoleUI.proxied
    if not Proxied or not Proxied.AddRingDropdownButtons or not Proxied.FillSlotDropdown then
        Fail("dropdown", "ring menu helpers missing")
        ok = false
    end
    if not self.HookPickups or not self.EntryFromCursor or not self.CursorLooksHeld then
        Fail("pickup", "cursor hooks missing")
        ok = false
    end
    if self:UseEntry({ kind = "macro" }) ~= false then
        Fail("UseEntry macro empty", "expected false")
        ok = false
    end
    if self.MacroLineKind then
        local kind, rest = self:MacroLineKind("/cast Shadow Bolt")
        if kind ~= "cast" or rest ~= "Shadow Bolt" then
            Fail("MacroLineKind cast", tostring(kind) .. " " .. tostring(rest))
            ok = false
        end
        kind = self:MacroLineKind("#showtooltip")
        if kind ~= "skip" then
            Fail("MacroLineKind skip", tostring(kind))
            ok = false
        end
    else
        Fail("MacroLineKind", "missing")
        ok = false
    end

    if ok then
        ConsoleUI_Debug("Rings check OK")
    end
    return ok
    end
end

if CreateFrame then
    AttachSelfCheck()
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

local function FailPrint(ok, name, detail)
    if not ok then
        print("Rings check FAIL: " .. name .. " " .. tostring(detail))
        return false
    end
    return true
end

local function RunHeadless(dir)
    local ok = true
    local rings = Read(dir .. "rings.lua")
    local radial = Read(dir .. "radial.lua")
    local editor = Read(dir .. "editor.lua")
    if not FailPrint(rings ~= nil, "rings.lua", "missing") then
        return false
    end
    if not FailPrint(string.find(rings, "ChatEdit_ParseText", 1, true) ~= nil, "macro parse", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "ChatFrameEditBox", 1, true) ~= nil, "real chat box", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "function Rings:MacroLineKind", 1, true) ~= nil, "macro kind", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "CastSpellByName", 1, true) ~= nil, "cast no chat", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "ReleaseChatBox", 1, true) ~= nil, "release chat", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "setmetatable(edit", 1, true) == nil, "no fake edit", "found") then
        ok = false
    end
    if not FailPrint(string.find(rings, "RunMacroText(", 1, true) == nil, "no RunMacroText call", "found") then
        ok = false
    end
    if not FailPrint(string.find(rings, "function Rings:HookPickups", 1, true) ~= nil, "pickup hook", "missing") then
        ok = false
    end
    if not FailPrint(string.find(rings, "function Rings:CountItem", 1, true) ~= nil, "item count", "missing") then
        ok = false
    end
    if radial then
        if not FailPrint(string.find(radial, "SLICE_MIDS = { 90, 45, 0, 315, 270, 225, 180, 135 }", 1, true) ~= nil, "slice mids", "missing") then
            ok = false
        end
        if not FailPrint(string.find(radial, "RepairPadGameplay", 1, true) ~= nil, "repair after menu", "missing") then
            ok = false
        end
        if not FailPrint(string.find(radial, 'alternateAction = "STRAFELEFT"', 1, true) ~= nil, "turn/strafe left", "missing") then
            ok = false
        end
        if not FailPrint(string.find(radial, 'alternateAction = "STRAFERIGHT"', 1, true) ~= nil, "turn/strafe right", "missing") then
            ok = false
        end
    end
    if not FailPrint(string.find(rings, "RepairPadGameplay", 1, true) ~= nil, "repair after ring", "missing") then
        ok = false
    end
    if not CreateFrame then
        ConsoleUI = ConsoleUI or {}
        dofile(dir .. "rings.lua")
        local R = ConsoleUI.rings
        if R and R.MacroLineKind then
            local kind, rest = R:MacroLineKind("/cast Shadow Bolt")
            if not FailPrint(kind == "cast" and rest == "Shadow Bolt", "kind cast", tostring(kind) .. " " .. tostring(rest)) then
                ok = false
            end
            kind, rest = R:MacroLineKind("/CAST Shadow Bolt(Rank 1)")
            if not FailPrint(kind == "cast" and rest == "Shadow Bolt(Rank 1)", "kind cast rank", tostring(rest)) then
                ok = false
            end
            kind, rest = R:MacroLineKind("/use Minor Healthstone")
            if not FailPrint(kind == "use" and rest == "Minor Healthstone", "kind use", tostring(rest)) then
                ok = false
            end
            kind = R:MacroLineKind("#showtooltip")
            if not FailPrint(kind == "skip", "kind skip", tostring(kind)) then
                ok = false
            end
            kind, rest = R:MacroLineKind("/dance")
            if not FailPrint(kind == "slash" and rest == "/dance", "kind slash", tostring(kind) .. " " .. tostring(rest)) then
                ok = false
            end
        else
            if not FailPrint(false, "macro kind fn", "missing") then
                ok = false
            end
        end
    end
    if editor then
        if not FailPrint(string.find(editor, "function Config:ShowRingClearFor", 1, true) ~= nil, "ring clear chip", "missing") then
            ok = false
        end
        if not FailPrint(string.find(editor, "X or Clear", 1, true) ~= nil, "ring clear hint", "missing") then
            ok = false
        end
    end
    if ok then
        print("Rings check OK")
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
    if not RunHeadless(dir) then
        os.exit(1)
    end
end
