-- Standalone mock regression check; not loaded by the addon TOC.
-- Run from the workspace: lua ConsoleUI/swingbar/check_performance.lua
-- Optional first argument: folder containing pre-change swingbar.lua,
-- castbar.lua and config.lua, to compare visible output and API call counts.
local baseline = arg and arg[1]
local script = arg and arg[0] or "ConsoleUI/swingbar/check_performance.lua"
local root = string.gsub(script, "swingbar/check_performance.lua$", "")
table.getn = table.getn or function(t) return #t end
math.mod = math.mod or math.fmod
local unpack = unpack or table.unpack
local counts, regions, now, position, offSpeed, inventory, settings
local function count(key) counts[key] = (counts[key] or 0) + 1 end
local methods = {}
local function Region(parent)
    local r = setmetatable({parent = parent, shown = true, alpha = 1, points = {}, scripts = {}, id = #regions + 1}, {__index = methods})
    regions[#regions + 1] = r
    return r
end
function methods:GetParent() return self.parent end
function methods:GetWidth() return self.width or (self.parent and self.parent:GetWidth()) or 400 end
function methods:GetHeight() return self.height or (self.parent and self.parent:GetHeight()) or 4 end
function methods:GetAlpha() return self.alpha end
function methods:IsShown() return self.shown end
function methods:IsVisible() return self.shown and self.alpha > 0 and (not self.parent or self.parent:IsVisible()) end
function methods:Show() count("Show"); self.shown = true end
function methods:Hide() count("Hide"); self.shown = false end
function methods:ClearAllPoints() count("ClearAllPoints"); self.points = {} end
function methods:SetPoint(point, target, relative, x, y)
    count("SetPoint"); self.points[point] = {target.id, relative, x, y}
end
function methods:SetAllPoints(target) self.allPoints = target end
function methods:SetScript(key, value) count("SetScript"); self.scripts[key] = value end
function methods:GetScript(key) return self.scripts[key] end
function methods:CreateTexture(_, layer) local r = Region(self); r.layer = layer; return r end
function methods:CreateFontString() return Region(self) end
function methods:RegisterEvent() end
function methods:UnregisterAllEvents() end
function methods:GetStatusBarTexture() return self.stock end
function methods:SetStatusBarTexture(texture)
    if not self.stock then self.stock = Region(self) end
    self.stock:SetTexture(texture); self.stock:SetAlpha(1); self.stock:Show()
end
function methods:GetMinMaxValues() return 0, 100 end
function methods:GetValue() return self.value or 50 end
function methods:GetStatusBarColor() return unpack(self.color or {0.2, 0.6, 1, 1}) end
local setters = {SetWidth="width", SetHeight="height", SetAlpha="alpha", SetTexture="texture", SetText="text", SetDrawLayer="layer"}
for method, field in pairs(setters) do
    local key, name = method, field
    methods[key] = function(self, value) count(key); self[name] = value end
end
for _, method in ipairs({"SetVertexColor", "SetTexCoord", "SetStatusBarColor"}) do
    local key = method
    methods[key] = function(self, ...) count(key); self[string.lower(key)] = {...} end
end
for _, method in ipairs({"SetFrameStrata", "SetFont", "SetJustifyH", "SetTextColor", "SetBlendMode"}) do methods[method] = function() end end
local function reset()
    counts, regions, now, position, offSpeed, inventory = {}, {}, 0, 0.5, 0, "Weapon"
    settings = {swingBarCombatOnly=false, swingBarFadeDuration=0.25}
    ConsoleUI = {config = {Get=function(_, key) return settings[key] end,
        HudOffset=function(_, key, fallback) return settings[key] or fallback end}}
    UIParent = Region()
    CreateFrame = function(_, name, parent) local r = Region(parent); if name then _G[name] = r end; return r end
    GetTime = function() return now end
    GetPlayerMapPosition = function() count("GetPlayerMapPosition"); return position, 0.5 end
    UnitAttackSpeed = function() return 2, offSpeed end
    UnitRangedDamage = function() return 2.8 end
    GetInventoryItemLink = function(_, slot) count("GetInventoryItemLink"); return "[" .. inventory .. slot .. "]" end
    GetNetStats = function() return 0, 0, 100 end
    UnitAffectingCombat = function() return false end
    ConsoleUI_Debug = function() end
end
local function encode(value)
    if type(value) == "number" then return string.format("%.7f", value) end
    if type(value) ~= "table" then return tostring(value) end
    local keys, result = {}, {}
    for k in pairs(value) do keys[#keys + 1] = k end
    table.sort(keys)
    for _, k in ipairs(keys) do result[#result + 1] = tostring(k) .. "=" .. encode(value[k]) end
    return "{" .. table.concat(result, ",") .. "}"
end
local function snapshot()
    local result = {}
    for _, r in ipairs(regions) do
        if r:IsVisible() then
            result[r.id] = encode({width=r:GetWidth(), height=r:GetHeight(), alpha=r.alpha,
                text=r.text, color=r.setvertexcolor, coords=r.settexcoord,
                points=r.points, texture=r.texture, layer=r.layer})
        end
    end
    return result
end
local function same(a, b, context)
    for id, value in pairs(a) do assert(b[id] == value, context .. " region " .. id .. "\nbefore: " .. value .. "\nafter: " .. tostring(b[id])) end
    for id in pairs(b) do assert(a[id], context .. " unexpected visible region " .. id) end
end
local function swing(path, optimized)
    reset(); dofile(path)
    local bar = ConsoleUI.swingbar
    bar:Initialize()
    local captures = {}
    local function tick(dt)
        now = now + dt
        if bar.eventFrame:GetScript("OnUpdate") then
            count("OnUpdate"); arg1 = dt; bar.eventFrame:GetScript("OnUpdate")()
        end
        captures[#captures + 1] = snapshot()
    end
    if optimized then assert(not bar.eventFrame:GetScript("OnUpdate"), "idle updater must sleep") end
    for i=1,60 do tick(1/60) end
    bar:StartMelee()
    assert(bar.eventFrame:GetScript("OnUpdate"), "melee must wake updater")
    for i=1,130 do tick(1/60) end
    offSpeed = 2.4; bar:StartMelee()
    for i=1,30 do tick(1/60) end
    assert(bar.frame.left:IsShown() and bar.frame.right:IsShown(), "DW lanes")
    inventory = "NewWeapon"; bar:OnEvent("UNIT_INVENTORY_CHANGED", "player")
    tick(1/60); assert(bar.frame.left.label.text == "NewWeapon16", "weapon label refresh")
    bar:StopMelee()
    for i=1,20 do tick(1/60) end
    if optimized then assert(not bar.eventFrame:GetScript("OnUpdate"), "faded idle updater must sleep") end
    bar:StartRanged()
    for i=1,240 do tick(1/60) end
    bar:SetRangedPhase("draw", now); position = 0.6; tick(0.01)
    assert(bar.frame.ranged.draw.fill.setvertexcolor[2] == 0.08, "cancel must flash red")
    for i=1,50 do tick(1/60) end
    bar:RecordRangedShot(now, "test"); tick(0.01)
    assert(bar.frame.ranged.fire.fill.setvertexcolor[2] == 1, "shot must flash white")
    settings.swingBarColorR, settings.swingBarColorG, settings.swingBarColorB = 0.3, 0.4, 0.8
    settings.swingBarWidth, settings.swingBarHeight, settings.swingBarGap = 620, 7, 12
    settings.swingBarOffsetX = 40
    bar:ReloadConfig()
    if optimized then
        local lane = bar.frame.ranged
        assert(lane.fire.points.TOPLEFT[3] == 3 and lane.cooldown.points.TOPLEFT[3] == 3,
            "ranged gaps must stay at 3 pixels regardless of DW gap setting")
        assert(lane.draw:GetWidth() + lane.fire:GetWidth() + lane.cooldown:GetWidth() + 6 == 620,
            "ranged total width must be preserved")
        assert(bar.frame.left:GetWidth() == 304, "DW gap setting must remain unchanged")
    end
    for i=1,30 do tick(1/60) end
    assert(bar.frame.ranged.draw.fill.setvertexcolor[2] == 0.4, "flash restores current selected color")
    settings.swingBarShowTimer, settings.swingBarShowSpark = false, false
    bar:ReloadConfig(); tick(1/60)
    assert(not bar.frame.ranged.timer:IsShown() and not bar.frame.ranged.spark:IsShown(), "hide timer/spark")
    settings.swingBarShowTimer, settings.swingBarShowSpark = true, true
    settings.swingBarCombatOnly = true; bar:ReloadConfig()
    for i=1,20 do tick(1/60) end
    if optimized then
        assert(bar.eventFrame:GetScript("OnUpdate"), "hidden active ranged state must keep ticking")
        counts = {}; tick(1/60)
        assert(not counts.SetWidth and not counts.SetText, "hidden bar must not paint")
    else tick(1/60) end
    bar:OnEvent("PLAYER_REGEN_DISABLED")
    for i=1,20 do tick(1/60) end
    assert(bar.frame:GetAlpha() == 1, "combat must restore faded bar")
    bar:StopRanged()
    for i=1,20 do tick(1/60) end
    if optimized then assert(not bar.eventFrame:GetScript("OnUpdate"), "stop ranged must sleep") end
    settings.swingBarEnabled = false; bar:ReloadConfig(); bar:StartMelee()
    for i=1,20 do tick(1/60) end
    if optimized then assert(not bar.eventFrame:GetScript("OnUpdate"), "disabled melee must not wake updater") end
    settings.swingBarEnabled, settings.swingBarFadeDuration = true, 0
    bar:ReloadConfig(); tick(1/60)
    assert(bar.frame:IsShown() and bar.frame:GetAlpha() == 1, "enable while attacking, instant fade")
    bar:StopMelee(); tick(1/60)
    if optimized then assert(not bar.eventFrame:GetScript("OnUpdate"), "instant hide must sleep") end
    bar:StartRanged(); settings.swingBarEnabled = false; bar:ReloadConfig()
    for i=1,240 do
        if i == 30 then position = 0.7 end
        tick(1/60)
    end
    settings.swingBarEnabled = true; bar:ReloadConfig(); tick(1/60)
    assert(bar.ranged.phaseEnd > now, "re-enabled ranged timer must not replay stale cycles")
    bar:StopRanged()
    -- Separate repeatable work sample. Counts are mock API calls, not FPS.
    bar:StartRanged(); counts = {}
    for i=1,240 do tick(1/60) end
    local active = counts
    if optimized then
        assert(not active.GetInventoryItemLink, "animation must not look up weapon names")
        assert((active.SetText or 0) < 100, "timer text must only update at displayed precision")
        assert((active.ClearAllPoints or 0) < 12, "spark anchors must only reset on segment changes")
    end
    bar:StopRanged(); counts = {}
    for i=1,240 do tick(1/60) end
    if optimized then assert(not counts.OnUpdate, "fully idle swing bar must do no frame work") end
    return captures, active, counts
end
local function watchConfig(path)
    local f = assert(io.open(path, "r")); local source = f:read("*a"); f:close()
    local start = assert(string.find(source, "function Config:HideStockFill", 1, true))
    local finish = assert(string.find(source, "function Config:PaintStatusBarFill", start, true))
    local loadchunk = loadstring or load
    assert(loadchunk("local Config = ConsoleUI.config\n" .. string.sub(source, start, finish - 1)))()
    local config = ConsoleUI.config
    config.STATUS_BAR_WATCH_FILL, config.STATUS_BAR_WHITE = "WatchFillShade", "White"
    config.WatchTexV = function(_, host) if host.barType == "REP" then return 0, 1 end; return 1, 0 end
    return config
end
local function hud(configPath, castPath, optimized)
    reset(); local config = watchConfig(configPath); dofile(castPath)
    local host = Region(UIParent); host:SetWidth(400); host.barType = "XP"
    local status = Region(host); status:SetStatusBarTexture("stock")
    local cast = Region(UIParent); cast.bar = Region(cast); cast.cuiStrip = Region(cast)
    cast.cuiStrip:SetWidth(400); cast.bar:SetStatusBarTexture("stock")
    local captures = {}
    for i=1,120 do
        status.value = i <= 60 and 50 or 75
        if i == 20 then host:SetWidth(600); cast.cuiStrip:SetWidth(600) end
        if i == 30 then host.barType = "REP"; host.restedbar = status end
        if i == 40 then status.color = {1, 0.3, 0.5, 1}; cast.cuiFillR = 0.3 end
        if i == 45 then GetNetStats = function() return 0, 0, 250 end end
        if i == 50 then status.value = 0 end
        if i == 55 then status.value = 100 end
        if i == 65 then cast.cuiStrip = Region(cast); cast.cuiStrip:SetWidth(500) end
        -- Native SetValue can revive the rectangular stock fill every time.
        status.stock:Show(); status.stock:SetAlpha(1)
        cast.bar.stock:Show(); cast.bar.stock:SetAlpha(1)
        config:SyncWatchFill(status)
        ConsoleUI.castbar:SyncFill(cast, i / 120)
        ConsoleUI.castbar:SyncLag(cast, i == 50 and 0 or 2)
        assert(not status.stock:IsShown() and not cast.bar.stock:IsShown(), "stock fill must stay suppressed")
        captures[#captures + 1] = snapshot()
    end
    counts = {}
    for i=1,240 do config:SyncWatchFill(status) end
    local watchCounts = counts
    if optimized then
        assert(not counts.SetPoint and not counts.SetTexture and not counts.SetWidth,
            "unchanged XP/Rep fill must not rebuild geometry or texture")
    end
    counts = {}
    for i=1,240 do ConsoleUI.castbar:SyncFill(cast, i/240); ConsoleUI.castbar:SyncLag(cast, 2) end
    if optimized then
        assert(not counts.SetPoint and not counts.SetTexture, "cast animation must not rebuild texture anchors")
    end
    return captures, watchCounts, counts
end
local swingShots, active, idle = swing(root .. "swingbar/swingbar.lua", true)
local hudShots, watch, cast = hud(root .. "config/config.lua", root .. "castbar/castbar.lua", true)
print("PASS: swing lifecycle, DW, ranged phases/flashes, settings, and HUD fill regression checks")
if baseline then
    local oldSwing, oldActive, oldIdle = swing(baseline .. "/swingbar.lua", false)
    local oldHud, oldWatch, oldCast = hud(baseline .. "/config.lua", baseline .. "/castbar.lua", false)
    assert(#swingShots == #oldSwing and #hudShots == #oldHud, "snapshot count")
    for i=1,#swingShots do same(oldSwing[i], swingShots[i], "swing tick " .. i) end
    for i=1,#hudShots do same(oldHud[i], hudShots[i], "HUD tick " .. i) end
    print("PASS: visible mock output matches baseline at every sampled tick")
    for _, sample in ipairs({{"ranged",oldActive,active}, {"idle",oldIdle,idle}, {"XP/Rep",oldWatch,watch}, {"cast",oldCast,cast}}) do
        local before, after = 0, 0
        for _, n in pairs(sample[2]) do before = before + n end
        for _, n in pairs(sample[3]) do after = after + n end
        print(sample[1] .. " / 240 ticks: counted calls " .. before .. " -> " .. after)
    end
end
