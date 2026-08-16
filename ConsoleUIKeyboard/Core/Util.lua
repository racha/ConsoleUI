local ns = ConsoleUIKeyboardNS

local Util = {}
ns.Util = Util

Util.gfind = string.gfind or string.gmatch

function Util.trim(s)
    if not s then return "" end
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

function Util.wipe(t)
    if not t then return t end
    local k
    for k in pairs(t) do
        t[k] = nil
    end
    -- Lua 5.0 table.getn reads t.n. Leave it and the next scan walks nil holes.
    t.n = nil
    if table.setn then
        table.setn(t, 0)
    end
    return t
end

function Util.chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    end
    return 1
end

function Util.utf8len(str)
    if not str then return 0 end
    local i = 1
    local n = 0
    local len = string.len(str)
    while i <= len do
        i = i + Util.chsize(string.byte(str, i))
        n = n + 1
    end
    return n
end

function Util.utf8sub(str, startChar, numChars)
    if not str then return "" end
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + Util.chsize(char)
        startChar = startChar - 1
    end
    local currentIndex = startIndex
    while numChars > 0 and currentIndex <= string.len(str) do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + Util.chsize(char)
        numChars = numChars - 1
    end
    return string.sub(str, startIndex, currentIndex - 1)
end

-- bytePos is 0-based EditBox:GetCursorPosition()
function Util.byteToChars(str, bytePos)
    if not str or not bytePos or bytePos <= 0 then return 0 end
    local i = 1
    local chars = 0
    local limit = bytePos
    local len = string.len(str)
    while i <= limit and i <= len do
        i = i + Util.chsize(string.byte(str, i))
        chars = chars + 1
    end
    return chars
end

-- charPos is 0-based glyph count; returns 0-based byte offset
function Util.charsToByte(str, charPos)
    if not str or not charPos or charPos <= 0 then return 0 end
    local i = 1
    local cur = 0
    local len = string.len(str)
    while cur < charPos and i <= len do
        i = i + Util.chsize(string.byte(str, i))
        cur = cur + 1
    end
    return i - 1
end

function Util.SelectDir(up, down, left, right)
    if up and left then return 8 end
    if up and right then return 2 end
    if down and left then return 6 end
    if down and right then return 4 end
    if left then return 7 end
    if right then return 3 end
    if up then return 1 end
    if down then return 5 end
    return 9
end

function Util.ModifierIndex(shift, ctrl)
    if shift and ctrl then return 4 end
    if shift then return 1 end
    if ctrl then return 3 end
    return 2
end

function Util.Union(str)
    local out = ""
    if not str then return out, 0 end
    local i
    for i = 1, string.len(str) do
        local s = string.sub(str, i, i)
        if not string.find(out, s, 1, true) then
            out = out .. s
        end
    end
    return out, string.len(out)
end

function Util.IsWordChar(ch)
    if not ch or ch == "" then return false end
    return string.find(ch, "[%a']") ~= nil
end

function Util.CopyLayout(src)
    local dst = {}
    if not src then return dst end
    local i
    for i = 1, 8 do
        dst[i] = {}
        local j
        for j = 1, 4 do
            dst[i][j] = {}
            local k
            for k = 1, 4 do
                dst[i][j][k] = src[i] and src[i][j] and src[i][j][k] or ""
            end
        end
    end
    return dst
end

function Util.LayoutOk(layout)
    if type(layout) ~= "table" then return false, "not a table" end
    local i
    for i = 1, 8 do
        if type(layout[i]) ~= "table" then
            return false, "missing set " .. i
        end
        local j
        for j = 1, 4 do
            if type(layout[i][j]) ~= "table" then
                return false, "missing button " .. i .. "." .. j
            end
            local k
            for k = 1, 4 do
                if type(layout[i][j][k]) ~= "string" then
                    return false, "missing glyph " .. i .. "." .. j .. "." .. k
                end
            end
        end
    end
    return true
end

function Util.IsOurBinding(action)
    if not action or action == "" then return false end
    return string.find(action, "^CONSOLEUIK_") ~= nil
end

function Util.Debug(msg)
    if ConsoleUI_Debug then
        ConsoleUI_Debug("Keyboard: " .. tostring(msg))
    end
end

function Util.Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[ConsoleUI Keyboard]|r " .. tostring(msg))
    end
end
