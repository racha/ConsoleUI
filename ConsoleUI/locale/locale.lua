--[[
    ConsoleUI - Locale Module
    
    Handles translations and locale-specific data
]]

if ConsoleUI.locale == nil then
    ConsoleUI.locale = {}
end

local Locale = ConsoleUI.locale

-- Initialize translation tables
if not ConsoleUI_translation then
    ConsoleUI_translation = {}
end

-- Current locale (will be set on initialization)
Locale.current = GetLocale() or "enUS"

-- Translation function - returns translated string or key if not found
function Locale:Translate(key)
    local lang = self.current
    local translation = ConsoleUI_translation[lang]
    
    if translation and translation[key] then
        return translation[key]
    end
    
    -- Fallback to English
    if lang ~= "enUS" then
        local enTranslation = ConsoleUI_translation["enUS"]
        if enTranslation and enTranslation[key] then
            return enTranslation[key]
        end
    end
    
    -- Return key as fallback
    return key
end

-- Short alias for translation function
-- Defined as regular function (not method) so it can be assigned and called directly
Locale.T = function(key)
    return Locale:Translate(key)
end

-- Initialize locale system
function Locale:Initialize()
    -- Get language from config or use game locale
    local config = ConsoleUI.config
    if config then
        local configLang = config:Get("language")
        if configLang and ConsoleUI_translation[configLang] then
            self.current = configLang
        else
            self.current = GetLocale() or "enUS"
        end
    else
        self.current = GetLocale() or "enUS"
    end
    
    ConsoleUI_Debug("Locale initialized: " .. self.current)
end

-- Set language
function Locale:SetLanguage(lang)
    if not lang then
        ConsoleUI_Debug("Language not available: (nil)")
        return false
    end
    
    if ConsoleUI_translation[lang] then
        self.current = lang
        local config = ConsoleUI.config
        if config then
            config:Set("language", lang)
        end
        ConsoleUI_Debug("Language set to: " .. tostring(lang))
        return true
    else
        ConsoleUI_Debug("Language not available: " .. tostring(lang))
        return false
    end
end

-- Get available languages
function Locale:GetAvailableLanguages()
    local languages = {}
    for lang, _ in pairs(ConsoleUI_translation) do
        table.insert(languages, lang)
    end
    table.sort(languages)
    return languages
end

-- Get language display name
function Locale:GetLanguageName(lang)
    local names = {
        ["enUS"] = "English",
        ["deDE"] = "Deutsch",
        ["esES"] = "Español",
        ["frFR"] = "Français",
        ["koKR"] = "한국어",
        ["ruRU"] = "Русский",
        ["zhCN"] = "简体中文",
        ["zhTW"] = "繁體中文",
    }
    return names[lang] or lang
end

