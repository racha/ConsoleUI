--[[
    Layout self-check. ConsoleUI.actionbars:SelfCheckLayout()
    Also runnable with: lua actionbars/check_layout.lua
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}

local ActionBars = ConsoleUI.actionbars
local Layout = ActionBars.Layout
local activeFailures = nil

local function Fail(ok, name, detail)
    if not ok then
        local msg = "Bars check FAIL: " .. name .. " " .. tostring(detail)
        if activeFailures then table.insert(activeFailures, name .. "=" .. tostring(detail)) end
        if ConsoleUI_Debug then
            ConsoleUI_Debug(msg)
        else
            print(msg)
        end
        return false
    end
    return true
end

local function Almost(a, b, eps)
    if not a or not b then return false end
    local d = a - b
    if d < 0 then d = -d end
    return d <= (eps or 0.02)
end

local function CheckOnce(size, pad, gap, starPad)
    local ok = true
    local m = Layout.Metrics(size, gap)
    if not Fail(Almost(m.inner, Layout.INNER * size / Layout.HIT), "inner", m.inner) then
        ok = false
    end
    if not Fail(Almost(m.flankOut, m.half + gap + m.half), "flankOut", m.flankOut) then
        ok = false
    end

    local i
    local split = {}
    local flat = {}
    for i = 1, 10 do
        split[i] = Layout.Local(i, "controller", m, pad)
        flat[i] = Layout.Local(i, "flat", m, pad)
        if not Fail(split[i] ~= nil, "split missing", i) then ok = false end
        if not Fail(flat[i] ~= nil, "flat missing", i) then ok = false end
        if not Fail(Layout.STAR[i] ~= nil, "star", i) then ok = false end
    end

    local modLB = Layout.ModifierLocal("lb", "controller", m, pad)
    local modLT = Layout.ModifierLocal("lt", "controller", m, pad)
    if not Fail(split[10].y == split[3].y, "RT height", split[10].y) then ok = false end
    if not Fail(split[9].y == split[1].y, "RB height", split[9].y) then ok = false end
    if not Fail(Almost(split[10].x - split[3].x, m.flankOut), "RT gap", split[10].x - split[3].x) then
        ok = false
    end
    if not Fail(Almost(split[9].x - split[1].x, m.flankOut), "RB gap", split[9].x - split[1].x) then
        ok = false
    end
    if not Fail(split[7].y > 0, "7 up", split[7].y) then ok = false end
    if not Fail(split[5].y < 0, "5 down", split[5].y) then ok = false end
    if not Fail(split[6].x < 0, "6 left", split[6].x) then ok = false end
    if not Fail(split[8].x > 0, "8 right", split[8].x) then ok = false end
    if not Fail(modLB.x < split[6].x and modLT.x == modLB.x, "modifiers outside left", modLB.x) then ok = false end
    if not Fail(modLT.y > modLB.y, "LT above LB", modLT.y) then ok = false end
    if not Fail(split[10].x > split[4].x, "RT outside", split[10].x) then ok = false end
    if not Fail(split[9].x > split[4].x, "RB outside", split[9].x) then ok = false end
    if not Fail(split[10].y > split[9].y, "RT above RB", split[10].y) then ok = false end

    local _, yPipX, yPipY = Layout.PipAnchor(3, size)
    local _, aPipX, aPipY = Layout.PipAnchor(1, size)
    local _, xPipX, xPipY = Layout.PipAnchor(2, size)
    local _, bPipX, bPipY = Layout.PipAnchor(4, size)
    if not Fail(yPipY < 0 and Almost(yPipX, 0), "Y pip inward", yPipY) then ok = false end
    if not Fail(aPipY > 0 and Almost(aPipX, 0), "A pip inward", aPipY) then ok = false end
    if not Fail(xPipX > 0 and Almost(xPipY, 0), "X pip inward", xPipX) then ok = false end
    if not Fail(bPipX < 0 and Almost(bPipY, 0), "B pip inward", bPipX) then ok = false end
    if not Fail(Layout.PIP_SIZE == 22, "pip size", Layout.PIP_SIZE) then ok = false end
    if Layout.PipSize then
        if not Fail(Layout.PipSize(82) == 22, "pip default hud", Layout.PipSize(82)) then
            ok = false
        end
        if not Fail(Layout.PipSize(20) <= 20, "pip capped to button", Layout.PipSize(20)) then
            ok = false
        end
        if not Fail(Layout.PipSize(82, "full") < Layout.PipSize(82), "full pip smaller", Layout.PipSize(82, "full")) then
            ok = false
        end
        local prevGlyph = nil
        if ConsoleUI.config then
            prevGlyph = ConsoleUI.config.GetGlyphSize
        else
            ConsoleUI.config = {}
        end
        ConsoleUI.config.GetGlyphSize = function() return 22 end
        local pipS = Layout.PipSize(80, "full")
        ConsoleUI.config.GetGlyphSize = function() return 32 end
        local pipM = Layout.PipSize(80, "full")
        ConsoleUI.config.GetGlyphSize = function() return 44 end
        local pipL = Layout.PipSize(80, "full")
        ConsoleUI.config.GetGlyphSize = prevGlyph
        if not Fail(pipS < pipM and pipM < pipL, "full pip small/med/large", tostring(pipS) .. "/" .. tostring(pipM) .. "/" .. tostring(pipL)) then
            ok = false
        end
    end

    local flatPoint, flatX, flatY = Layout.PipAnchor(3, size, "flat")
    if not Fail(flatPoint == "BOTTOM" and Almost(flatX, 0) and flatY > 0, "flat pip", flatPoint) then
        ok = false
    end

    local expectDir = {
        [7] = "N", [3] = "N",
        [6] = "W", [2] = "W",
        [5] = "S", [1] = "S",
        [8] = "E", [4] = "E", [9] = "E", [10] = "E",
    }
    for i = 1, 10 do
        if not Fail(split[i].dir == expectDir[i], "dir", i .. "=" .. tostring(split[i].dir)) then
            ok = false
        end
        if not Fail(flat[i].dir == "O", "flat dir", i) then ok = false end
        if not Fail(flat[i].y == 0, "flat y", i) then ok = false end
    end

    local left = { 6, 7, 5, 8 }
    local right = { 2, 3, 1, 4, 9, 10 }
    for i = 2, 4 do
        if not Fail(flat[left[i]].x > flat[left[i - 1]].x, "flat left order", left[i]) then
            ok = false
        end
    end
    for i = 2, 6 do
        if not Fail(flat[right[i]].x > flat[right[i - 1]].x, "flat right order", right[i]) then
            ok = false
        end
    end
    local sqStep = Layout.SquareStep(size, pad)
    if not Fail(sqStep >= size + Layout.GOLD_OUT * 2 + Layout.SQUARE_GAP, "square step", sqStep) then
        ok = false
    end
    if not Fail(Almost(flat[left[2]].x - flat[left[1]].x, sqStep), "flat step", flat[left[2]].x - flat[left[1]].x) then
        ok = false
    end
    local flatLB = Layout.ModifierLocal("lb", "flat", m, pad)
    local flatLT = Layout.ModifierLocal("lt", "flat", m, pad)
    if not Fail(Almost(flatLT.x - flatLB.x, sqStep), "flat modifier step", flatLT.x - flatLB.x) then
        ok = false
    end
    if not Fail(Almost(flat[left[1]].x - flatLT.x, sqStep), "flat modifier to dpad", flat[left[1]].x - flatLT.x) then
        ok = false
    end

    if not Fail(Layout.FullSlot(-1, 1) == 21, "full left A", Layout.FullSlot(-1, 1)) then
        ok = false
    end
    if not Fail(Layout.FullSlot(1, 1) == 11, "full right A", Layout.FullSlot(1, 1)) then
        ok = false
    end
    if not Fail(Layout.FullSlot(0, 1) == 1, "full mid A", Layout.FullSlot(0, 1)) then
        ok = false
    end
    if not Fail(Layout.FullSlot(0, 1, true) == 31, "full both A", Layout.FullSlot(0, 1, true)) then
        ok = false
    end
    if not Fail(Layout.Dir(1, "full") == "S", "full dir", Layout.Dir(1, "full")) then
        ok = false
    end
    local fullL = Layout.World(1, "full", m, pad, starPad, 0, 70, -1)
    local fullM = Layout.World(1, "full", m, pad, starPad, 0, 70, 0)
    local fullR = Layout.World(1, "full", m, pad, starPad, 0, 70, 1)
    if not Fail(fullL.x < fullM.x, "full col left", fullL.x) then
        ok = false
    end
    if not Fail(fullR.x > fullM.x, "full col right", fullR.x) then
        ok = false
    end
    if not Fail(fullM.dir == "S", "full world dir", fullM.dir) then
        ok = false
    end
    local fullUp = Layout.World(7, "full", m, pad, starPad, 0, 0, 0)
    if not Fail(fullUp.y > 0, "full plus up", fullUp.y) then
        ok = false
    end
    local fm = Layout.FullMetrics(m.size, gap)
    local dpadU = Layout.World(7, "full", m, pad, starPad, 0, 0, 0)
    local dpadD = Layout.World(5, "full", m, pad, starPad, 0, 0, 0)
    local dpadL = Layout.World(6, "full", m, pad, starPad, 0, 0, 0)
    local dpadR = Layout.World(8, "full", m, pad, starPad, 0, 0, 0)
    local vis = Layout.FullChrome(fm)
    if not Fail(Almost(dpadU.x, dpadD.x), "full mid col x", dpadU.x) then
        ok = false
    end
    if not Fail(Almost(dpadL.y, dpadR.y), "full side row y", dpadL.y) then
        ok = false
    end
    if not Fail(dpadL.x < dpadU.x and dpadR.x > dpadU.x, "full plus x", dpadL.x) then
        ok = false
    end
    if not Fail(dpadU.y > dpadL.y and dpadD.y < dpadL.y, "full plus y", dpadU.y) then
        ok = false
    end
    if not Fail(Almost(fm.inner, m.inner), "full inner is diamond", fm.inner) then
        ok = false
    end
    if not Fail(Almost(dpadU.y - dpadD.y, fm.inner * 2), "full plus U/D", dpadU.y - dpadD.y) then
        ok = false
    end
    local faceX = Layout.World(2, "full", m, pad, starPad, 0, 0, 0)
    if not Fail(faceX.x - dpadR.x >= vis * 2 - 0.05, "full stars apart", faceX.x - dpadR.x) then
        ok = false
    end
    local pts = {}
    local n = 0
    local col
    for col = -1, 1 do
        local bi
        for bi = 1, 10 do
            n = n + 1
            pts[n] = Layout.World(bi, "full", m, pad, starPad, 0, 0, col)
        end
        n = n + 1
        pts[n] = Layout.ModifierWorld("lb", "full", m, pad, starPad, 0, 0, col)
        n = n + 1
        pts[n] = Layout.ModifierWorld("lt", "full", m, pad, starPad, 0, 0, col)
    end
    local sameCenter = false
    local a
    for a = 1, n - 1 do
        local b
        for b = a + 1, n do
            if Almost(pts[a].x, pts[b].x, 0.5) and Almost(pts[a].y, pts[b].y, 0.5) then
                sameCenter = true
                break
            end
        end
        if sameCenter then
            break
        end
    end
    if not Fail(not sameCenter, "full unique centers", n) then
        ok = false
    end
    local function colBounds(col)
        local minL, maxR
        local bi
        for bi = 1, 10 do
            local w = Layout.World(bi, "full", m, pad, starPad, 0, 70, col)
            local l = w.x - Layout.FullChrome(Layout.FullMetrics(m.size, gap))
            local r = w.x + Layout.FullChrome(Layout.FullMetrics(m.size, gap))
            if not minL or l < minL then
                minL = l
            end
            if not maxR or r > maxR then
                maxR = r
            end
        end
        local mods = { "lb", "lt" }
        for bi = 1, 2 do
            local w = Layout.ModifierWorld(mods[bi], "full", m, pad, starPad, 0, 70, col)
            local l = w.x - Layout.FullChrome(Layout.FullMetrics(m.size, gap))
            local r = w.x + Layout.FullChrome(Layout.FullMetrics(m.size, gap))
            if not minL or l < minL then
                minL = l
            end
            if not maxR or r > maxR then
                maxR = r
            end
        end
        return minL, maxR
    end
    local lL, lR = colBounds(-1)
    local mL, mR = colBounds(0)
    local rL, rR = colBounds(1)
    if not Fail(mL - lR >= (Layout.FULL_AIR or 0) + (Layout.FULL_GLOW or 0) - 1, "full L/M air", mL - lR) then
        ok = false
    end
    if not Fail(rL - mR >= (Layout.FULL_AIR or 0) + (Layout.FULL_GLOW or 0) - 1, "full M/R air", rL - mR) then
        ok = false
    end
    local a200 = Layout.World(10, "full", m, pad, 200, 0, 70, 0)
    local a600 = Layout.World(10, "full", m, pad, 600, 0, 70, 0)
    if not Fail(Almost(a200.x, a600.x), "full ignores starPad", a200.x) then
        ok = false
    end
    if Layout.FullFit then
        local fitted, fittedGap = Layout.FullFit(82, gap, 1920)
        local expect = math.floor(82 * Layout.FULL_SCALE + 0.5)
        if not Fail(fitted <= expect, "full half size", fitted) then
            ok = false
        end
        if not Fail(fittedGap and fittedGap < gap, "full flank scales", fittedGap) then
            ok = false
        end
        local tight = Layout.FullFit(82, gap, 900)
        if not Fail(tight <= fitted, "full shrinks to screen", tight) then
            ok = false
        end
    end

    if not Fail(modLB.dir == "W" and modLT.dir == "W", "modifier direction", modLB.dir) then ok = false end

    local sized, padded, starred, flanked = Layout.ApplyScale(size, pad, starPad, gap, 2)
    if not Fail(Almost(sized, size * 2) and Almost(padded, pad * 2) and Almost(starred, starPad) and Almost(flanked, gap * 2), "apply scale", sized) then
        ok = false
    end
    local m2 = Layout.Metrics(sized, flanked)
    local w1 = Layout.World(7, "controller", m, pad, starPad, 0, 70)
    local w2 = Layout.World(7, "controller", m2, padded, starred, 0, 70)
    if not Fail(Almost(w2.x, w1.x), "scale keeps cluster gap", w2.x) then
        ok = false
    end
    if not Fail(Almost(w2.y - 70, (w1.y - 70) * 2), "scale inner y", w2.y) then
        ok = false
    end
    local l1 = Layout.World(6, "controller", m, pad, starPad, 0, 70)
    local l2 = Layout.World(6, "controller", m2, padded, starred, 0, 70)
    if not Fail(Almost(l2.x - w2.x, (l1.x - w1.x) * 2), "scale inner x", l2.x) then
        ok = false
    end

    local seen = {}
    for i = 1, 10 do
        local key = tostring(split[i].star) .. string.format("%.3f,%.3f", split[i].x, split[i].y)
        if not Fail(seen[key] == nil, "split overlap", i) then ok = false end
        seen[key] = i
    end

    if not Fail(string.find(Layout.KeyPath("N", nil), "KeyN") ~= nil, "path N", Layout.KeyPath("N", nil)) then
        ok = false
    end
    local hiO = Layout.KeyPath("O", 1)
    if not Fail(string.find(hiO, "KeyHi") ~= nil, "path O hi", hiO) then
        ok = false
    end
    if not Fail(string.find(Layout.KeyPath("Q", nil), "KeySq") ~= nil, "path Q", Layout.KeyPath("Q", nil)) then
        ok = false
    end
    if not Fail(string.find(Layout.KeyPath("Q", 1), "KeyHiSq") ~= nil, "path Q hi", Layout.KeyPath("Q", 1)) then
        ok = false
    end
    if not Fail(string.find(Layout.KeyPath("N", "in"), "KeyHiIn") ~= nil, "path N in", Layout.KeyPath("N", "in")) then
        ok = false
    end
    if not Fail(string.find(Layout.KeyPath("Q", "in"), "KeyHiSqIn") ~= nil, "path Q in", Layout.KeyPath("Q", "in")) then
        ok = false
    end
    if not Fail(Layout.RIM_IN == 0, "rim full bounds", Layout.RIM_IN) then
        ok = false
    end
    if not Fail(Layout.ICON_IN == 7, "icon inset", Layout.ICON_IN) then
        ok = false
    end
    if not Fail(Layout.PET_HUB == 132, "pet hub", Layout.PET_HUB) then
        ok = false
    end
    if not Fail(Layout.PET_ORBIT == nil, "no pet orbit", tostring(Layout.PET_ORBIT)) then
        ok = false
    end
    if not Fail(Layout.STANCE_BASE == 0.8, "stance base", Layout.STANCE_BASE) then
        ok = false
    end
    if not Fail(Layout.PET_BASE == 0.6, "pet base", Layout.PET_BASE) then
        ok = false
    end
    if not Fail(Layout.PetHitGap() == Layout.GOLD_OUT * 2 + Layout.PET_SQUARE_GAP, "pet hit gap", Layout.PetHitGap()) then
        ok = false
    end
    if not Fail(Layout.PET_SQUARE_GAP == 2, "pet square gap", tostring(Layout.PET_SQUARE_GAP)) then
        ok = false
    end
    if not Fail(Layout.PetSquareStep() == Layout.HIT + Layout.GOLD_OUT * 2 + Layout.PET_SQUARE_GAP, "pet step", Layout.PetSquareStep()) then
        ok = false
    end
    if not Fail(Layout.PetBarFirst() == Layout.PET_HUB / 2 + Layout.PetHitGap() + Layout.HIT / 2, "pet first", Layout.PetBarFirst()) then
        ok = false
    end
    if not Fail(Layout.PetBarY() == -38, "pet bar y", Layout.PetBarY()) then
        ok = false
    end
    if not Fail(Layout.PetBarTopY() == Layout.PetBarY() + Layout.PetSquareStep(), "pet top y", Layout.PetBarTopY()) then
        ok = false
    end
    if not Fail(Layout.PetCommandY() == Layout.PetSquareStep() / 2, "pet command y", Layout.PetCommandY()) then
        ok = false
    end
    if not Fail(Layout.PetStanceY() == -Layout.PetSquareStep() / 2, "pet stance y", Layout.PetStanceY()) then
        ok = false
    end
    if not Fail(Layout.PetSpellY() == 0, "pet spell y", Layout.PetSpellY()) then
        ok = false
    end
    if not Fail(Layout.PET_GROUP_GAP == 2, "pet group gap", tostring(Layout.PET_GROUP_GAP)) then
        ok = false
    end
    if not Fail(Layout.PetSlotGroup(1) == "action" and Layout.PetSlotGroup(4) == "stance" and Layout.PetSlotGroup(8) == "spell", "pet groups", Layout.PetSlotGroup(4)) then
        ok = false
    end
    if Layout.PetGroupPoint then
        local ax, ay = Layout.PetGroupPoint("action", 1, "right")
        if not Fail(Almost(ax, -Layout.PetBarFirst(), 0.2) and Almost(ay, Layout.PetCommandY(), 0.2), "pet action", tostring(ax) .. "," .. tostring(ay)) then
            ok = false
        end
        local sx, sy = Layout.PetGroupPoint("stance", 1, "right")
        if not Fail(Almost(sx, -Layout.PetBarFirst(), 0.2) and Almost(sy, Layout.PetStanceY(), 0.2), "pet stance", tostring(sx) .. "," .. tostring(sy)) then
            ok = false
        end
        local px, py = Layout.PetGroupPoint("spell", 1, "right")
        if not Fail(Almost(px, Layout.PetBarFirst(), 0.2) and Almost(py, 0, 0.2), "pet spell first", tostring(px) .. "," .. tostring(py)) then
            ok = false
        end
        local p2x, p2y = Layout.PetGroupPoint("spell", 2, "right")
        if not Fail(Almost(p2x, px + Layout.PetSquareStep(), 0.2) and Almost(p2y, 0, 0.2), "pet spell second", tostring(p2x) .. "," .. tostring(p2y)) then
            ok = false
        end
        local p3x, p3y = Layout.PetGroupPoint("spell", 3, "right")
        if not Fail(Almost(p3x, px + Layout.PetSquareStep() * 2, 0.2) and Almost(p3y, 0, 0.2), "pet spell third", tostring(p3x) .. "," .. tostring(p3y)) then
            ok = false
        end
        local lx, ly = Layout.PetGroupPoint("action", 1, "left")
        if not Fail(Almost(lx, Layout.PetBarFirst(), 0.2) and Almost(ly, ay, 0.2), "pet grow left", tostring(lx) .. "," .. tostring(ly)) then
            ok = false
        end
        local lsx, lsy = Layout.PetGroupPoint("spell", 1, "left")
        if not Fail(Almost(lsx, -Layout.PetBarFirst(), 0.2) and Almost(lsy, 0, 0.2), "pet spell grow left", tostring(lsx) .. "," .. tostring(lsy)) then
            ok = false
        end
        local a2x, a2y = Layout.PetGroupPoint("action", 2, "right")
        if not Fail(Almost(a2x, ax, 0.2) and Almost(a2y, ay, 0.2), "pet action parked only", tostring(a2x) .. "," .. tostring(a2y)) then
            ok = false
        end
        if Layout.PetPickerPoint then
            local pkx, pky = Layout.PetPickerPoint("action", 1, "right")
            if not Fail(Almost(pkx, ax + Layout.PetSquareStep(), 0.2) and Almost(pky, ay, 0.2), "pet action picker", tostring(pkx) .. "," .. tostring(pky)) then
                ok = false
            end
            local skx, sky = Layout.PetPickerPoint("stance", 1, "right")
            if not Fail(Almost(skx, sx + Layout.PetSquareStep(), 0.2) and Almost(sky, sy, 0.2), "pet stance picker", tostring(skx) .. "," .. tostring(sky)) then
                ok = false
            end
            local lpkx, lpky = Layout.PetPickerPoint("action", 1, "left")
            if not Fail(Almost(lpkx, Layout.PetBarFirst() - Layout.PetSquareStep(), 0.2) and Almost(lpky, ay, 0.2), "pet action picker left", tostring(lpkx) .. "," .. tostring(lpky)) then
                ok = false
            end
        end
    end
    if not Fail(Layout.SquareIconSize(size) == Layout.SliceClipSize(size), "icon sizes", Layout.SquareIconSize(size)) then
        ok = false
    end

    local w = Layout.World(10, "controller", m, pad, starPad, 0, 70)
    if not Fail(w.star == "right", "world star", w.star) then ok = false end
    if not Fail(w.x > 0, "RT world right", w.x) then ok = false end

    if not Fail(Layout.SLICE_N == 16, "slice n", Layout.SLICE_N) then ok = false end
    if not Fail(Layout.SliceClipSize(56) == 42, "clip 56", Layout.SliceClipSize(56)) then
        ok = false
    end
    local clip = Layout.SliceClipSize(size)
    local n = Layout.SLICE_N
    local si
    for si = 1, n do
        local row = Layout.SliceRow(si, n, clip)
        local mirror = Layout.SliceRow(n + 1 - si, n, clip)
        if not Fail(row ~= nil, "slice row", si) then
            ok = false
        elseif not Fail(mirror ~= nil, "slice mirror", si) then
            ok = false
        else
            if not Fail(Almost(row.width, mirror.width), "slice sym", si) then
                ok = false
            end
            if not Fail(row.left >= 0 and (row.left + row.width) <= clip + 0.01, "slice bounds", si) then
                ok = false
            end
        end
    end
    local mid = Layout.SliceRow(8, n, clip)
    local edge = Layout.SliceRow(1, n, clip)
    if mid and edge then
        if not Fail(mid.width > edge.width, "slice mid wide", mid.width) then
            ok = false
        end
    end
    local u0, u1, v0, v1 = Layout.SliceTexCoord(1, n, clip)
    local mu0, mu1, mv0, mv1 = Layout.SliceTexCoord(8, n, clip)
    if not Fail(u0 and u0 < u1 and v0 < v1, "slice uv", tostring(u0)) then
        ok = false
    end
    if not Fail(u0 >= 0.08 and u1 <= 0.92 and v0 >= 0.08, "slice crop", u0) then
        ok = false
    end
    if mu0 and u0 then
        if not Fail(mu1 - mu0 > u1 - u0, "slice uv mid", mu1 - mu0) then
            ok = false
        end
    end

    return ok
end

function ActionBars:SelfCheckLayout()
    activeFailures = {}
    self.lastSelfCheckFailures = activeFailures
    if not Layout then
        Fail(false, "Layout", "missing")
        activeFailures = nil
        return false
    end
    local ok = true
    local sizes = { 40, 48, 56, 60, 64, 70, 72, 76, 80, 56 }
    local n
    for n = 1, 10 do
        local size = sizes[n]
        if not CheckOnce(size, 65, 50, 600) then
            ok = false
        end
    end
    if ActionBars.GetActionID and ActionBars.DiamondActive then
        local side = { actionSlot = 43, sideBarIndex = 3 }
        if not Fail(ActionBars:GetActionID(side) == 43, "side slot", ActionBars:GetActionID(side)) then
            ok = false
        end
        local clone = { actionSlot = 11, GetID = function() return 1 end }
        if not Fail(ActionBars:GetActionID(clone) == 11, "full clone slot", ActionBars:GetActionID(clone)) then
            ok = false
        end
        if not Fail(ActionBars:DiamondActive(side) == false, "side active", "true") then
            ok = false
        end
        local jump = { isProxiedAction = { id = "JUMP" }, actionSlot = 2 }
        if not Fail(ActionBars:DiamondActive(jump) == false, "jump idle", "true") then
            ok = false
        end
    end
    if ConsoleUI.config and ConsoleUI.config.DEFAULTS then
        local d = ConsoleUI.config.DEFAULTS
        if not Fail(d.barGoldBorder == false, "default gold", tostring(d.barGoldBorder)) then
            ok = false
        end
        if not Fail(d.barGoldColorR == 1 and d.barGoldColorG == 0.82 and d.barGoldColorB == 0.18, "default tint", tostring(d.barGoldColorR) .. "," .. tostring(d.barGoldColorG) .. "," .. tostring(d.barGoldColorB)) then
            ok = false
        end
        if not Fail(d.barLayout == "controller", "default layout", tostring(d.barLayout)) then
            ok = false
        end
        if not Fail((d.barFlankGap or 50) == 50, "default flank", tostring(d.barFlankGap)) then
            ok = false
        end
        if not Fail((d.barStarPadding or 0) == 600, "default cluster gap", tostring(d.barStarPadding)) then
            ok = false
        end
    end
    if ok then
        if ConsoleUI_Debug then
            ConsoleUI_Debug("Bars check OK x10")
        else
            print("Bars check OK x10")
        end
    end
    activeFailures = nil
    return ok
end

if not CreateFrame then
    local path = arg and arg[0]
    local dir = ""
    if path then
        dir = string.gsub(path, "[^/]+$", "")
        if dir == path then dir = "" end
        if not Layout then
            dofile(dir .. "layout.lua")
            Layout = ConsoleUI.actionbars.Layout
        end
    end
    local pass = ActionBars:SelfCheckLayout()
    local fh = io.open(dir .. "bars.lua", "r")
    if not Fail(fh ~= nil, "bars source", "missing") then
        pass = false
    elseif fh then
        local src = fh:read("*a")
        fh:close()
        if not Fail(string.find(src, "function ActionBars:EnsureModifierButtons", 1, true) ~= nil, "modifier frames", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "IsControlKeyDown", 1, true) ~= nil, "LB state", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "IsShiftKeyDown", 1, true) ~= nil, "LT state", "missing") then
            pass = false
        end
        if not Fail(string.find(src, 'Get("barActionGlyphs") == false', 1, true) ~= nil, "glyph hide", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "local actionID = self:GetActionID(button)", 1, true) ~= nil, "click uses GetActionID", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "local actionID = offset + buttonID", 1, true) == nil, "click ignores clone slot", "found") then
            pass = false
        end
        if not Fail(string.find(src, "if self.currentPage > 1 then", 1, true) == nil, "live offset", "stale currentPage") then
            pass = false
        end
        if not Fail(string.find(src, "function ActionBars:GetActionOffset", 1, true) ~= nil and string.find(src, "GetCurrentModifierPage", 1, true) ~= nil, "live modifier offset", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "PinStayHidden", 1, true) ~= nil, "pet/stance stay hidden", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "PetActionBarFrame = true", 1, true) ~= nil, "pin pet bar", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "StanceBarFrame = true", 1, true) ~= nil, "pin stance bar", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "UnregisterAllEvents", 1, true) ~= nil, "unpin stock events", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "StayHiddenParent", 1, true) ~= nil, "hidden parent", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "ShapeshiftBar_Update = function() end", 1, true) ~= nil, "mute stance update", "missing") then
            pass = false
        end
        if not Fail(string.find(src, "_cuiStayHiddenShow", 1, true) == nil, "OnShow hide hook", "found") then
            pass = false
        end
        if not Fail(string.find(src, "RunProxiedPetBind", 1, true) ~= nil, "follow click bind", "missing") then
            pass = false
        end
    end
    if not pass then
        os.exit(1)
    end
end
