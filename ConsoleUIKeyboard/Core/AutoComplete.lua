local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Keyboard = ConsoleUIKeyboard

local suggestions = {}
local ROW_COUNT = 8
local ROW_H = 20
local ROW_W = 128
local PAD = 12
local GAP = 8
local TEX = "Interface\\AddOns\\ConsoleUIKeyboard\\Textures\\"
local GOLD = { 1.00, 0.82, 0.18 }

local function ColorTex(tex, r, g, b, a)
    if not tex then return end
    tex:SetVertexColor(r, g, b)
    if tex.SetAlpha then
        tex:SetAlpha(a or 1)
    end
end

local Panel = CreateFrame("Frame", "$parentGuess", Keyboard)
Panel:SetPoint("LEFT", Keyboard, "RIGHT", 170, 0)
Panel:SetWidth(PAD + ROW_W + PAD)
Panel:SetHeight(PAD + ROW_H + PAD)
Panel:SetFrameLevel(1)
Panel:SetAlpha(0)

local fill = Panel:CreateTexture(nil, "BACKGROUND")
fill:SetAllPoints(Panel)
fill:SetTexture(TEX .. "Panel.tga")
ColorTex(fill, 0.12, 0.12, 0.12, 0.75)
Panel.Fill = fill

local ring = Panel:CreateTexture(nil, "BORDER")
ring:SetPoint("TOPLEFT", Panel, "TOPLEFT", -1, 1)
ring:SetPoint("BOTTOMRIGHT", Panel, "BOTTOMRIGHT", 1, -1)
ring:SetTexture(TEX .. "PanelHi.tga")
ColorTex(ring, GOLD[1], GOLD[2], GOLD[3], 0.9)
Panel.Ring = ring

Panel.Rows = {}
local ri
for ri = 1, ROW_COUNT do
    local row = CreateFrame("Frame", "$parentRow" .. ri, Panel)
    row:SetWidth(ROW_W)
    row:SetHeight(ROW_H)
    if ri == 1 then
        row:SetPoint("TOP", Panel, "TOP", 0, -PAD)
    else
        row:SetPoint("TOP", Panel.Rows[ri - 1], "BOTTOM", 0, -GAP)
    end
    row:Hide()

    local hi = row:CreateTexture(nil, "BORDER")
    hi:SetPoint("TOPLEFT", row, "TOPLEFT", -1, 1)
    hi:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 1, -1)
    hi:SetTexture(TEX .. "RowHi.tga")
    ColorTex(hi, GOLD[1], GOLD[2], GOLD[3], 0.9)
    hi:Hide()
    row.Highlight = hi

    local text = row:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
    text:SetPoint("LEFT", row, "LEFT", 4, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    text:SetHeight(ROW_H)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetTextColor(0.93, 0.93, 0.93, 1)
    text:SetText("")
    row.Text = text

    Panel.Rows[ri] = row
end

Keyboard.Complete = Panel
Keyboard.CompleteIndex = 1
Keyboard.GuessWord = nil
Keyboard.lastSuggestWord = nil

local function LayoutPanel(shown)
    if shown == 0 then
        Panel:SetAlpha(0)
        return
    end
    Panel:SetWidth(PAD + ROW_W + PAD)
    local extra = 0
    if shown > 1 then
        extra = (shown - 1) * GAP
    end
    Panel:SetHeight(PAD + shown * ROW_H + extra + PAD)
    Panel:SetAlpha(1)
end

function Keyboard:SetSuggestions(newIndex)
    if newIndex then
        self.CompleteIndex = newIndex
    end
    if self.CompleteIndex < 1 then
        self.CompleteIndex = 1
    end
    local count = table.getn(suggestions)
    if count > ROW_COUNT then
        count = ROW_COUNT
    end
    if count > 0 and self.CompleteIndex > count then
        self.CompleteIndex = count
    end
    local shown = 0
    local i
    for i = 1, ROW_COUNT do
        local item = suggestions[i]
        local row = Panel.Rows[i]
        if item then
            shown = shown + 1
            row.Text:SetText(item.word)
            row:Show()
            if i == self.CompleteIndex then
                row.Text:SetTextColor(GOLD[1], GOLD[2], GOLD[3], 1)
                row.Highlight:Show()
            else
                row.Text:SetTextColor(0.93, 0.93, 0.93, 1)
                row.Highlight:Hide()
            end
        else
            row.Text:SetText("")
            row.Highlight:Hide()
            row:Hide()
        end
    end
    local cur = suggestions[self.CompleteIndex]
    self.GuessWord = cur and cur.word or nil
    LayoutPanel(shown)
end

function Keyboard:GetCurrentWord()
    if not self.Focus then return end
    local text = self.Focus:GetText()
    if not text or text == "" then return end
    local position = self:GetFocusUTF8Pos()
    local length = U.utf8len(text)
    local startPos, endPos
    local i
    for i = position, 1, -1 do
        local ch = U.utf8sub(text, i, 1)
        if not U.IsWordChar(ch) then
            startPos = i + 1
            break
        elseif i == 1 then
            startPos = 1
        end
    end
    for i = position, length do
        local ch = U.utf8sub(text, i, 1)
        if not U.IsWordChar(ch) then
            endPos = i - 1
            break
        elseif i == length then
            endPos = i
        end
    end
    if startPos and endPos and endPos >= startPos then
        local word = U.trim(U.utf8sub(text, startPos, endPos - startPos + 1))
        if word ~= "" and not tonumber(word) then
            return word, startPos, endPos
        end
    end
end

function Keyboard:GetSuggestions()
    local word = self:GetCurrentWord()
    if word == self.lastSuggestWord then
        return
    end
    self.lastSuggestWord = word
    U.wipe(suggestions)
    if not word or not self.Dictionary then
        self:SetSuggestions(1)
        return
    end
    local isCapital = string.upper(string.sub(word, 1, 1)) == string.sub(word, 1, 1)
    local needle = string.lower(word)
    local length = string.len(needle)
    local chars, numChars = U.Union(needle)
    local thisWord, thisWeight
    for thisWord, thisWeight in pairs(self.Dictionary) do
        local valid = true
        if thisWord == needle or numChars * 4 < string.len(thisWord) then
            valid = false
        end
        if valid then
            local c
            for c = 1, string.len(chars) do
                if not string.find(thisWord, string.sub(chars, c, c), 1, true) then
                    valid = false
                    break
                end
            end
        end
        if valid then
            local match = string.find(thisWord, needle, 1, true)
            local item = {
                word = isCapital and (string.upper(string.sub(thisWord, 1, 1)) .. string.sub(thisWord, 2)) or thisWord,
                weight = thisWeight,
                match = match,
                length = math.abs(length - string.len(thisWord)),
            }
            local priority = table.getn(suggestions) + 1
            local index
            for index = 1, math.min(20, table.getn(suggestions)) do
                local compare = suggestions[index]
                if not compare then
                    break
                end
                local better = false
                if item.match and not compare.match then
                    better = true
                elseif (item.match and compare.match and item.match <= compare.match) or (not item.match and not compare.match) then
                    if item.length < compare.length or (item.length == compare.length and item.weight > compare.weight) then
                        better = true
                    end
                end
                if better then
                    priority = index
                    break
                end
            end
            if priority <= 20 then
                table.insert(suggestions, priority, item)
                while table.getn(suggestions) > 20 do
                    table.remove(suggestions)
                end
            end
        end
    end
    self:SetSuggestions(1)
end

function Keyboard:AUTOCOMPLETE(keepList)
    local current, startPos, endPos = self:GetCurrentWord()
    if not current or not self.GuessWord or not self.Focus then return end
    local replacement = self.GuessWord
    if replacement ~= current then
        local text = self.Focus:GetText() or ""
        local first = U.utf8sub(text, 1, startPos - 1)
        local second = U.utf8sub(text, endPos + 1, U.utf8len(text) - endPos)
        local nextText = first .. replacement .. second
        self.Focus:SetText(nextText)
        self:SetFocusUTF8Pos(startPos + U.utf8len(replacement) - 1)
        if self.Mime and self.Mime.SetText then
            self.Mime.last = nil
            self.Mime:SetText(nextText)
        end
    end
    if keepList then
        -- Keep the open list so the next D-pad press can move again.
        self.lastSuggestWord = replacement
        return
    end
    self.lastSuggestWord = nil
    self:GetSuggestions()
end

function Keyboard:VisibleGuessCount()
    local count = table.getn(suggestions)
    if count > ROW_COUNT then
        count = ROW_COUNT
    end
    return count
end

function Keyboard:CycleGuess(delta)
    local count = self:VisibleGuessCount()
    if count == 0 then return end
    local nextIndex = self.CompleteIndex + delta
    if nextIndex < 1 then nextIndex = count end
    if nextIndex > count then nextIndex = 1 end
    self:SetSuggestions(nextIndex)
end

function Keyboard:PickGuess(delta)
    if self:VisibleGuessCount() == 0 then return end
    self:CycleGuess(delta)
    self:AUTOCOMPLETE(true)
end
