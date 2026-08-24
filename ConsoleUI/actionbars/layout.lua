--[[
    Action-bar diamond layout. Pure math. No frames.
    controller = diamonds. flat = one row of squares. full = three
    cloned controller sets (LB | default | LT).
    Twelve-button chrome: LB/LT visual modifiers + 10 action inputs.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}

local Layout = {}
ConsoleUI.actionbars.Layout = Layout

local function Mod(a, b)
    if math.mod then
        return math.mod(a, b)
    end
    return math.fmod(a, b)
end

Layout.HIT = 56
Layout.INNER = 33
Layout.PLATE = 5
Layout.GOLD_OUT = 6
Layout.RIM_IN = 0
Layout.ICON_IN = 7
Layout.FLANK_GAP = 50
Layout.PIP_SIZE = 22
Layout.PIP_IN = {
    [7] = { 0, -1 }, [3] = { 0, -1 },
    [5] = { 0,  1 }, [1] = { 0,  1 },
    [6] = { 1,  0 }, [2] = { 1,  0 },
    [8] = {-1,  0 }, [4] = {-1,  0 },
    [10] = { -1, 0 },
    [9] = { -1, 0 },
}
Layout.TEX = "Interface\\AddOns\\ConsoleUI\\textures\\radial\\"
Layout.GOLD = { 1.00, 0.82, 0.18 }

Layout.STAR = {
    [1] = "right", [2] = "right", [3] = "right", [4] = "right", [9] = "right",
    [5] = "left", [6] = "left", [7] = "left", [8] = "left", [10] = "right",
}

Layout.FLAT_X = {
    [6] = -0.5, [7] = 0.5, [5] = 1.5, [8] = 2.5,
    [2] = -2.5, [3] = -1.5, [1] = -0.5, [4] = 0.5, [9] = 1.5, [10] = 2.5,
}
Layout.SLICE_N = 16
Layout.SQUARE_GAP = 8
Layout.PET_SQUARE_GAP = 2
Layout.PET_SLOTS = 10
Layout.PET_GROUP_GAP = 2
Layout.STANCE_MAX = 8
Layout.STANCE_BASE = 0.8
Layout.PET_BASE = 0.6
Layout.AUTOCAST_PULSE = 3.2
Layout.AUTOCAST_DOT = Layout.GOLD_OUT
Layout.AUTOCAST_DOTS = 4

function Layout.SquareStep(buttonSize, padding)
    buttonSize = buttonSize or Layout.HIT
    local minStep = buttonSize + Layout.GOLD_OUT * 2 + Layout.SQUARE_GAP
    if not padding or padding < minStep then
        return minStep
    end
    return padding
end

-- Two 56 rows + the slot hit gap. Portrait stays the origin.
Layout.PET_HUB = Layout.HIT + Layout.SquareStep(Layout.HIT)

function Layout.SliceClipSize(buttonSize)
    buttonSize = buttonSize or Layout.HIT
    local clip = buttonSize - Layout.ICON_IN * 2
    if clip < 8 then
        clip = 8
    end
    return clip
end

function Layout.PetSquareStep()
    return Layout.HIT + Layout.GOLD_OUT * 2 + Layout.PET_SQUARE_GAP
end

function Layout.PetHitGap()
    return Layout.GOLD_OUT * 2 + Layout.PET_SQUARE_GAP
end

function Layout.PetBarY()
    return -(Layout.PET_HUB - Layout.HIT) / 2
end

function Layout.PetBarTopY()
    return Layout.PetBarY() + Layout.PetSquareStep()
end

function Layout.PetBarFirst()
    return Layout.PET_HUB / 2 + Layout.PetHitGap() + Layout.HIT / 2
end

function Layout.PetSlotGroup(slot)
    slot = tonumber(slot) or 1
    if slot <= 3 then
        return "action"
    end
    if slot <= 6 then
        return "stance"
    end
    return "spell"
end

function Layout.PetGroupStartX(group)
    return Layout.PetBarFirst()
end

function Layout.PetCommandY()
    return Layout.PetSquareStep() / 2
end

function Layout.PetStanceY()
    return -Layout.PetSquareStep() / 2
end

function Layout.PetSpellY()
    return 0
end

function Layout.PetSideX(group, grow)
    local x = Layout.PetBarFirst()
    local flip = grow == "left"
    if group ~= "spell" then
        flip = not flip
    end
    if flip then
        x = -x
    end
    return x
end

function Layout.PetGroupPoint(group, index, grow)
    index = tonumber(index) or 1
    if index < 1 then
        index = 1
    end
    local x = Layout.PetSideX(group, grow)
    if group == "spell" then
        local step = Layout.PetSquareStep()
        if x < 0 then
            x = x - (index - 1) * step
        else
            x = x + (index - 1) * step
        end
        return x, Layout.PetSpellY()
    end
    if group == "stance" then
        return x, Layout.PetStanceY()
    end
    return x, Layout.PetCommandY()
end

function Layout.PetPickerPoint(group, index, grow)
    index = tonumber(index) or 1
    if index < 1 then
        index = 1
    end
    local x, y = Layout.PetGroupPoint(group, 1, grow)
    local step = Layout.PetSquareStep()
    if x < 0 then
        x = x + index * step
    else
        x = x - index * step
    end
    return x, y
end

function Layout.PetBarPoint(i, grow)
    return Layout.PetGroupPoint("spell", i, grow)
end

function Layout.SquareIconSize(buttonSize)
    buttonSize = buttonSize or Layout.HIT
    local icon = buttonSize - Layout.ICON_IN * 2
    if icon < 8 then
        icon = 8
    end
    return icon
end

function Layout.SquarePathPoint(progress, half)
    progress = Mod(tonumber(progress) or 0, 1)
    half = tonumber(half) or 0
    local leg = progress * 4
    local side = math.floor(leg)
    local t = leg - side
    if side == 0 then
        return -half + half * 2 * t, half
    end
    if side == 1 then
        return half, half - half * 2 * t
    end
    if side == 2 then
        return half - half * 2 * t, -half
    end
    return -half, -half + half * 2 * t
end

function Layout.SliceRow(i, n, size)
    n = n or Layout.SLICE_N
    local sliceH = size / n
    local y = (i - 0.5) * sliceH
    local half = size / 2
    local dist = y - half
    if dist < 0 then
        dist = -dist
    end
    local width = size - (2 * dist)
    if width < 1 then
        return nil
    end
    local left = (size - width) / 2
    return {
        left = left,
        width = width,
        top = (i - 1) * sliceH,
        height = sliceH + 0.5,
        bandTop = (i - 1) * sliceH,
        bandBot = i * sliceH,
    }
end

function Layout.SliceTexCoord(i, n, size)
    local row = Layout.SliceRow(i, n, size)
    if not row then
        return nil
    end
    local cropL, cropR, cropT, cropB = 0.08, 0.92, 0.08, 0.92
    local spanU = cropR - cropL
    local spanV = cropB - cropT
    local u0 = cropL + (row.left / size) * spanU
    local u1 = cropL + ((row.left + row.width) / size) * spanU
    local v0 = cropT + (row.bandTop / size) * spanV
    local v1 = cropT + (row.bandBot / size) * spanV
    return u0, u1, v0, v1
end

function Layout.Metrics(buttonSize, flankGap)
    buttonSize = buttonSize or Layout.HIT
    flankGap = flankGap or Layout.FLANK_GAP
    local inner = Layout.INNER * buttonSize / Layout.HIT
    local half = (buttonSize + Layout.PLATE * 2) / 2
    return {
        size = buttonSize,
        inner = inner,
        half = half,
        flankGap = flankGap,
        flankOut = half + flankGap + half,
        icon = 24 * buttonSize / Layout.HIT,
    }
end

-- Scale is a layout multiplier, not Frame:SetScale. SetScale leaves
-- SetPoint gaps in unscaled pixels so buttons overlap or float.
-- starPad is screen pixels between cluster centers. Scale must not
-- move the groups — only the diamonds grow.
function Layout.ApplyScale(size, padding, starPad, flankGap, scale)
    scale = scale or 1
    return (size or Layout.HIT) * scale,
        (padding or 0) * scale,
        starPad or 0,
        (flankGap or Layout.FLANK_GAP) * scale
end

local SPLIT = {
    [7]  = { ax =  0, ay =  1, dir = "N" },
    [6]  = { ax = -1, ay =  0, dir = "W" },
    [5]  = { ax =  0, ay = -1, dir = "S" },
    [8]  = { ax =  1, ay =  0, dir = "E" },
    [10] = { ax =  0, ay =  1, dir = "E", flank = 1 },
    [3]  = { ax =  0, ay =  1, dir = "N" },
    [2]  = { ax = -1, ay =  0, dir = "W" },
    [1]  = { ax =  0, ay = -1, dir = "S" },
    [4]  = { ax =  1, ay =  0, dir = "E" },
    [9]  = { ax =  0, ay = -1, dir = "E", flank = 1 },
}

function Layout.PipAnchor(id, buttonSize, kind)
    if kind == "flat" then
        return "BOTTOM", 0, 2
    end
    local v = Layout.PIP_IN[id] or { 0, -1 }
    local dist = (buttonSize or 60) * 0.28
    if kind == "full" then
        dist = (buttonSize or 60) * 0.22
    end
    return "CENTER", v[1] * dist, v[2] * dist
end

function Layout.PipSize(buttonSize, kind)
    local px = Layout.PIP_SIZE
    if ConsoleUI.config and ConsoleUI.config.GetGlyphSize then
        px = ConsoleUI.config:GetGlyphSize("hud")
    end
    if kind == "full" then
        px = math.floor(px * 0.7 + 0.5)
        if px < 10 then
            px = 10
        end
        if buttonSize and buttonSize > 0 then
            local cap = math.floor(buttonSize * 0.5 + 0.5)
            if cap < 10 then
                cap = 10
            end
            if px > cap then
                px = cap
            end
        end
        return px
    end
    if buttonSize and buttonSize > 0 then
        local cap = math.floor(buttonSize * 0.75 + 0.5)
        if cap < 14 then
            cap = 14
        end
        if px > cap then
            px = cap
        end
    end
    return px
end

function Layout.Dir(id, kind)
    if kind == "flat" then
        return "O"
    end
    local spec = SPLIT[id]
    if spec then
        return spec.dir
    end
    return "N"
end

function Layout.KeyPath(dir, hi)
    local name
    if hi == "in" then
        if dir == "Q" then
            name = "KeyHiSqIn"
        else
            name = "KeyHiIn"
        end
    elseif dir == "Q" then
        name = hi and "KeyHiSq" or "KeySq"
    elseif hi then
        if dir == "O" then
            name = "KeyHi"
        else
            name = "KeyHi" .. dir
        end
    else
        if dir == "O" then
            name = "Key"
        else
            name = "Key" .. dir
        end
    end
    return Layout.TEX .. name
end

function Layout.Local(id, kind, metrics, padding)
    metrics = metrics or Layout.Metrics(Layout.HIT, Layout.FLANK_GAP)
    if kind == "flat" then
        local step = Layout.SquareStep(metrics.size, padding)
        return {
            x = (Layout.FLAT_X[id] or 0) * step,
            y = 0,
            dir = "O",
            star = Layout.STAR[id],
        }
    end
    local spec = SPLIT[id]
    if not spec then
        return { x = 0, y = 0, dir = "N", star = Layout.STAR[id] }
    end
    local x
    if spec.flank then
        x = spec.flank * metrics.flankOut
    else
        x = spec.ax * metrics.inner
    end
    return {
        x = x,
        y = spec.ay * metrics.inner,
        dir = spec.dir,
        star = Layout.STAR[id],
    }
end

function Layout.ModifierLocal(modifier, kind, metrics, padding)
    metrics = metrics or Layout.Metrics(Layout.HIT, Layout.FLANK_GAP)
    if kind == "flat" then
        local x = -2.5
        if modifier == "lt" then
            x = -1.5
        end
        return { x = x * Layout.SquareStep(metrics.size, padding), y = 0, dir = "O", star = "left" }
    end
    local y = -metrics.inner
    if modifier == "lt" then
        y = metrics.inner
    end
    return { x = -metrics.flankOut, y = y, dir = "W", star = "left" }
end

Layout.FULL_AIR = 96
Layout.FULL_GLOW = 16
Layout.FULL_SCALE = 0.75
Layout.FULL_MIN = 24

function Layout.DiamondStep(buttonSize)
    buttonSize = buttonSize or Layout.HIT
    return buttonSize + Layout.PLATE * 2 + Layout.SQUARE_GAP
end

function Layout.FullChrome(metrics)
    local hit = metrics.size / 2 + Layout.GOLD_OUT
    if metrics.half > hit then
        return metrics.half
    end
    return hit
end

function Layout.BoxesOverlap(ax, ay, bx, by, half)
    local dx = ax - bx
    if dx < 0 then
        dx = -dx
    end
    local dy = ay - by
    if dy < 0 then
        dy = -dy
    end
    return dx < half * 2 and dy < half * 2
end

-- Same diamond metrics as Controller Style. RT/RB stay outside the plus.
function Layout.FullMetrics(buttonSize, flankGap)
    local m = Layout.Metrics(buttonSize, flankGap)
    local step = Layout.DiamondStep(m.size)
    local flankOut = m.flankOut
    local needFlank = m.inner + step
    if flankOut < needFlank then
        flankOut = needFlank
    end
    return {
        size = m.size,
        inner = m.inner,
        half = m.half,
        flankGap = m.flankGap,
        flankOut = flankOut,
        icon = m.icon,
    }
end

function Layout.FullPack(metrics, air)
    metrics = Layout.FullMetrics(metrics and metrics.size, metrics and metrics.flankGap)
    air = air or Layout.FULL_AIR
    local chrome = Layout.FullChrome(metrics)
    local step = Layout.DiamondStep(metrics.size)
    local pack = metrics.inner * 2 + step
    local minX, maxX
    local i
    for i = 1, 10 do
        local loc = Layout.Local(i, "controller", metrics)
        local starX = pack / 2
        if loc.star == "left" then
            starX = -pack / 2
        end
        local x = starX + loc.x
        local l = x - chrome
        local r = x + chrome
        if not minX or l < minX then
            minX = l
        end
        if not maxX or r > maxX then
            maxX = r
        end
    end
    local modifiers = { "lb", "lt" }
    for i = 1, 2 do
        local loc = Layout.ModifierLocal(modifiers[i], "controller", metrics)
        local x = -pack / 2 + loc.x
        local l = x - chrome
        local r = x + chrome
        if not minX or l < minX then
            minX = l
        end
        if not maxX or r > maxX then
            maxX = r
        end
    end
    local halfW = maxX
    if minX and -minX > halfW then
        halfW = -minX
    end
    local glow = Layout.FULL_GLOW or 0
    local gap = air + glow
    local minGap = Layout.SQUARE_GAP + Layout.GOLD_OUT * 2 + glow
    if gap < minGap then
        gap = minGap
    end
    local colGap = halfW * 2 + gap
    return pack, colGap, halfW
end

function Layout.FullSpan(metrics, air)
    local pack, colGap, halfW = Layout.FullPack(metrics, air)
    return colGap * 2 + halfW * 2, pack, colGap, halfW
end

function Layout.FullFit(size, flankGap, uiW, air)
    air = air or Layout.FULL_AIR
    size = size or Layout.HIT
    flankGap = flankGap or Layout.FLANK_GAP
    local budget = (uiW or 1920) - 64
    if budget < 400 then
        budget = 400
    end
    local s = math.floor(size * Layout.FULL_SCALE + 0.5)
    if s < Layout.FULL_MIN then
        s = Layout.FULL_MIN
    end
    if s > size then
        s = size
    end
    local n
    for n = 1, 40 do
        local gap = flankGap * s / size
        local m = Layout.FullMetrics(s, gap)
        local span = Layout.FullSpan(m, air)
        if span <= budget then
            return s, gap
        end
        s = s - 2
        if s < Layout.FULL_MIN then
            return Layout.FULL_MIN, flankGap * Layout.FULL_MIN / size
        end
    end
    return s, flankGap * s / size
end

-- column -1 = LB (page 3), 0 = default / LB+LT, 1 = LT (page 2)
function Layout.FullSlot(column, id, bothHeld)
    if column == -1 then
        return 20 + id
    end
    if column == 1 then
        return 10 + id
    end
    if bothHeld then
        return 30 + id
    end
    return id
end

function Layout.World(id, kind, metrics, padding, starPad, xOff, yOff, col)
    if kind == "full" then
        metrics = Layout.FullMetrics(metrics and metrics.size, metrics and metrics.flankGap)
        local loc = Layout.Local(id, "controller", metrics, padding)
        local pack, colGap = Layout.FullPack(metrics)
        col = col or 0
        local starX = pack / 2
        if loc.star == "left" then
            starX = -pack / 2
        end
        return {
            x = col * colGap + starX + loc.x + (xOff or 0),
            y = (yOff or 0) + loc.y,
            dir = loc.dir,
            star = loc.star,
        }
    end
    local locKind = kind
    local loc = Layout.Local(id, locKind, metrics, padding)
    local half = (starPad or 600) / 2
    local starX = half
    if loc.star == "left" then
        starX = -half
    end
    starX = starX + (xOff or 0)
    return {
        x = starX + loc.x,
        y = (yOff or 0) + loc.y,
        dir = loc.dir,
        star = loc.star,
    }
end

function Layout.ModifierWorld(modifier, kind, metrics, padding, starPad, xOff, yOff, col)
    if kind == "full" then
        metrics = Layout.FullMetrics(metrics and metrics.size, metrics and metrics.flankGap)
        local loc = Layout.ModifierLocal(modifier, "controller", metrics, padding)
        local pack, colGap = Layout.FullPack(metrics)
        return {
            x = (col or 0) * colGap - pack / 2 + loc.x + (xOff or 0),
            y = (yOff or 0) + loc.y,
            dir = loc.dir,
            star = loc.star,
        }
    end
    local loc = Layout.ModifierLocal(modifier, kind, metrics, padding)
    return {
        x = -(starPad or 600) / 2 + loc.x + (xOff or 0),
        y = (yOff or 0) + loc.y,
        dir = loc.dir,
        star = loc.star,
    }
end
