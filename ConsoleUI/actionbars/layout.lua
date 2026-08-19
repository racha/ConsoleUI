--[[
    Action-bar diamond layout. Pure math. No frames.
    controller = Controller Style. flat = Flat (one row).
    Slot 10 = RT. Slot 9 = RB. LB is Ctrl, not a diamond.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}

local Layout = {}
ConsoleUI.actionbars.Layout = Layout

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
    [10] = { 1, 0 },
    [9] = { -1, 0 },
}
Layout.TEX = "Interface\\AddOns\\ConsoleUI\\textures\\radial\\"
Layout.GOLD = { 1.00, 0.82, 0.18 }

Layout.STAR = {
    [1] = "right", [2] = "right", [3] = "right", [4] = "right", [9] = "right",
    [5] = "left", [6] = "left", [7] = "left", [8] = "left", [10] = "left",
}

Layout.FLAT_LEFT = { 6, 7, 5, 8, 10 }
Layout.FLAT_RIGHT = { 2, 3, 1, 4, 9 }
Layout.SLICE_N = 16
Layout.SQUARE_GAP = 8

function Layout.SquareStep(buttonSize, padding)
    buttonSize = buttonSize or Layout.HIT
    local minStep = buttonSize + Layout.GOLD_OUT * 2 + Layout.SQUARE_GAP
    if not padding or padding < minStep then
        return minStep
    end
    return padding
end

function Layout.SliceClipSize(buttonSize)
    buttonSize = buttonSize or Layout.HIT
    local clip = buttonSize - Layout.ICON_IN * 2
    if clip < 8 then
        clip = 8
    end
    return clip
end

function Layout.SquareIconSize(buttonSize)
    buttonSize = buttonSize or Layout.HIT
    local icon = buttonSize - Layout.ICON_IN * 2
    if icon < 8 then
        icon = 8
    end
    return icon
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

local SPLIT = {
    [7]  = { ax =  0, ay =  1, dir = "N" },
    [6]  = { ax = -1, ay =  0, dir = "W" },
    [5]  = { ax =  0, ay = -1, dir = "S" },
    [8]  = { ax =  1, ay =  0, dir = "E" },
    [10] = { ax =  0, ay = -1, dir = "W", flank = -1 },
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
    return "CENTER", v[1] * dist, v[2] * dist
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
        local row = Layout.FLAT_LEFT
        if Layout.STAR[id] == "right" then
            row = Layout.FLAT_RIGHT
        end
        local slot = 0
        local i
        for i = 1, 5 do
            if row[i] == id then
                slot = i - 1
                break
            end
        end
        local step = Layout.SquareStep(metrics.size, padding)
        return {
            x = (slot - 2) * step,
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

function Layout.World(id, kind, metrics, padding, starPad, xOff, yOff)
    local loc = Layout.Local(id, kind, metrics, padding)
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
