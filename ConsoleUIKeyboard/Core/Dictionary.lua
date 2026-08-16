local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Keyboard = ConsoleUIKeyboard

local escapes = {
    "|c%x%x%x%x%x%x%x%x",
    "[0-9]+",
    "\124T.-\124t",
    "|T.-|t",
    "|H.-|h",
    "|n",
    "|r",
    "/[%w]+",
}

local function Unescape(str)
    if not str then return str end
    local i
    for i = 1, table.getn(escapes) do
        str = string.gsub(str, escapes[i], " ")
    end
    return str
end

local WORDPAT = "[%a][%w']*[%w]+"

function Keyboard:GenerateDictionary()
    local dictionary = {}
    local env = getfenv(0)
    local _, object
    for _, object in pairs(env) do
        if type(object) == "string" then
            object = Unescape(object)
            local word
            for word in U.gfind(object, WORDPAT) do
                word = string.lower(word)
                if not dictionary[word] then
                    dictionary[word] = 1
                else
                    dictionary[word] = dictionary[word] + 1
                end
            end
        end
    end
    return dictionary
end

function Keyboard:UpdateDictionary()
    if not self.Dictionary or not self.Mime then return end
    local text = self.Mime:GetText()
    if not text or text == "" then return end
    local word
    for word in U.gfind(text, WORDPAT) do
        word = string.lower(word)
        if not self.Dictionary[word] then
            self.Dictionary[word] = 1
        else
            self.Dictionary[word] = self.Dictionary[word] + 1
        end
    end
    ConsoleUIKeyboardDictionary = self.Dictionary
end

function Keyboard:NormalizeDictionary()
    local dictionary = self.Dictionary
    if not dictionary then return end
    local ceiling = 0
    local word, freq
    for word, freq in pairs(dictionary) do
        if freq > ceiling then
            ceiling = freq
        end
    end
    if ceiling < 2 then return end

    local weights = {}
    local i
    for i = 1, ceiling do
        weights[i] = {}
    end
    for word, freq in pairs(dictionary) do
        if weights[freq] then
            table.insert(weights[freq], word)
        end
    end
    for i = 1, ceiling do
        if weights[i] and table.getn(weights[i]) == 0 then
            weights[i] = nil
        end
    end

    local newDictionary = {}
    local weight = 0
    for i = 1, ceiling do
        local words = weights[i]
        if words then
            weight = weight + 1
            local w
            for w = 1, table.getn(words) do
                newDictionary[words[w]] = weight
            end
        end
    end
    ConsoleUIKeyboardDictionary = newDictionary
    self.Dictionary = newDictionary
end
