-- Standalone: lua clients/wrath/check_securebar.lua
-- Proves the Wrath build wires all ten actions to secure clicks and pages.
local root = "ConsoleUI/"
local override = {}
local drivers = {}
local templates = {}
local combat = true
local methods = {}
methods.__index = methods
local function Region(parent)
    return setmetatable({ parent = parent, attrs = {}, shown = true }, methods)
end
function methods:SetID(v) self.id = v end
function methods:GetID() return self.id end
function methods:GetName() return self.name end
function methods:SetWidth(v) self.width = v end
function methods:SetHeight(v) self.height = v end
function methods:GetWidth() return self.width end
function methods:SetPoint() end
function methods:SetAllPoints() end
function methods:SetFrameLevel(v) self.level = v end
function methods:GetFrameLevel() return self.level or 1 end
function methods:EnableMouse() end
function methods:RegisterForClicks(v) self.clicks = v end
function methods:SetAttribute(k, v)
    self.attrs[k] = v
    if self.attributeHook then self.attributeHook(self, k, v) end
end
function methods:GetAttribute(k) return self.attrs[k] end
function methods:CreateTexture() return Region(self) end
function methods:SetTexture(v) self.texture = v end
function methods:GetTexture() return self.texture end
function methods:SetTexCoord() end
function methods:SetVertexColor() end
function methods:GetVertexColor() return 1, 1, 1 end
function methods:SetAlpha(v) self.alpha = v end
function methods:ClearAllPoints() end
function methods:GetParent() return self.parent end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:HookScript(name, fn)
    if name == "OnAttributeChanged" then self.attributeHook = fn end
end
function methods:SetScript(name, fn) self[name] = fn end
function methods:RegisterEvent() end
function methods:UnregisterEvent() end

UIParent = Region()
CreateFrame = function(kind, name, parent, template)
    local f = Region(parent)
    f.name = name
    if template then templates[#templates + 1] = template end
    return f
end
RegisterStateDriver = function(frame, state, driver)
    drivers[#drivers + 1] = { frame, state, driver }
end
SetOverrideBindingClick = function(owner, priority, key, buttonName, mouseButton)
    override[key] = { owner, priority, buttonName, mouseButton }
end
InCombatLockdown = function() return combat end
HasAction = function(slot) return slot > 0 end
GetActionTexture = function(slot) return "icon:" .. slot end
GameTooltip = { SetOwner = function() end, SetAction = function() end, Hide = function() end }
getglobal = function() return nil end

ConsoleUI = {}
dofile(root .. "actionbars/layout.lua")
dofile(root .. "actionbars/slicemask.lua")
dofile("clients/wrath/ConsoleUI/wrath/securebar.lua")
local bar = ConsoleUI.wrathBar
bar:Initialize()
assert(not bar.initialized and #override == 0, "must not configure secure UI in combat")
combat = false
bar:Initialize()
assert(#bar.buttons == 10 and #drivers == 10, "ten state-driven secure buttons")
assert(#templates == 10, "ten inherited templates")
for i = 1, 10 do
    local button = bar.buttons[i]
    assert(string.find(templates[i], "SecureActionButtonTemplate", 1, true))
    assert(string.find(templates[i], "SecureHandlerStateTemplate", 1, true))
    assert(button.clicks == "AnyUp")
    for page = 1, 4 do
        assert(button:GetAttribute("page" .. page) == (page - 1) * 10 + i)
    end
    assert(drivers[i][2] == "page")
    assert(string.find(drivers[i][3], "mod:shift,mod:ctrl", 1, true))
end
local count = 0
for key, binding in pairs(override) do
    assert(binding[2] == false and binding[4] == "LeftButton")
    assert(key ~= "" and string.find(binding[3], "ConsoleUIWrathAction", 1, true))
    count = count + 1
end
assert(count == 40, "all 1-0 and modifier chords must be secure clicks")
local first = bar.buttons[1]
assert(first.icon.texture == "icon:1")
first:SetAttribute("action", first:GetAttribute("page4"))
assert(first.icon.texture == "icon:31", "secure page change must repaint the icon")
print("Wrath secure bar check OK: ten buttons, four secure pages, forty click bindings")
