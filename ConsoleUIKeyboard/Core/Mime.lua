local ns = ConsoleUIKeyboardNS
local Keyboard = ConsoleUIKeyboard

local Mime = {}
Mime.last = ""

function Mime:GetText()
    return self.last or ""
end

function Mime:SetText(text)
    self.last = text or ""
    -- Chat already shows the line. Do not echo it on the guess panel.
    if Keyboard.SetSuggestions then
        Keyboard:SetSuggestions()
    end
end

function Mime:Sync()
    if not Keyboard.Focus then
        if self.last ~= "" then
            self:SetText("")
        end
        return
    end
    local text = Keyboard.Focus:GetText() or ""
    if text ~= self.last then
        self:SetText(text)
    end
end

Keyboard.Mime = Mime
