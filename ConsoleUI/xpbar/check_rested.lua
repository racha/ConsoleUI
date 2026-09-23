-- Standalone: lua ConsoleUI/xpbar/check_rested.lua (not loaded by the TOC).
local dir=string.gsub(arg and arg[0] or "ConsoleUI/xpbar/check_rested.lua","[^/]+$","")
local function Read(path)
    local f=assert(io.open(path));local s=f:read("*a");f:close();return s
end
local methods={}
local function Frame(parent)
    return setmetatable({parent=parent,shown=true,alpha=1,width=400,value=0,max=100},{__index=methods})
end
function methods:GetParent()return self.parent end
function methods:CreateTexture()return Frame(self)end
function methods:Show()self.shown=true end
function methods:Hide()self.shown=false end
function methods:IsShown()return self.shown end
function methods:GetAlpha()return self.alpha end
function methods:SetAlpha(v)self.alpha=v end
function methods:SetWidth(v)self.width=v end
function methods:GetWidth()return self.width end
function methods:SetMinMaxValues(a,b)self.min,self.max=a,b end
function methods:GetMinMaxValues()return self.min or 0,self.max end
function methods:SetValue(v)self.value=v end
function methods:GetValue()return self.value end
function methods:GetStatusBarColor()return .2,.6,1,1 end
for _,name in ipairs({"SetTexture","SetPoint","ClearAllPoints","SetDrawLayer","SetTexCoord","SetVertexColor",
    "SetStatusBarColor","SetStatusBarTexture","RegisterEvent","SetScript"}) do methods[name]=function()end end
local xp,maxxp,rest,clock=90,100,10,1
GetTime=function()return clock end
UnitXP=function()return xp end
UnitXPMax=function()return maxxp end
GetXPExhaustion=function()return rest end
UnitClass=function()return "Hunter","HUNTER" end
CreateFrame=function()return Frame()end
FACTION_STANDING_INCREASED="Reputation with %s increased by %d."
ConsoleUI={config={Get=function()end,WatchTexV=function()return 1,0 end}}
dofile(dir.."xpbar.lua")
local src=Read(dir.."../config/config.lua")
local a=assert(string.find(src,"function Config:HideStockFill",1,true))
local b=assert(string.find(src,"function Config:PaintStatusBarFill",a,true))
local compile=loadstring or load
assert(compile("local Config=ConsoleUI.config\n"..string.sub(src,a,b-1)))()
-- Execute the production event handler without constructing the whole settings UI.
src=Read(dir.."xpbar.lua")
a=assert(string.find(src,"local function OnEvent()",1,true))
b=assert(string.find(src,"-- Bar Creation",a,true))
local onEvent=assert(compile("local XPBar=ConsoleUI.xpbar\nlocal GetPlayerClassColor=function()return .2,.6,.3 end\n"
    ..string.sub(src,a,b-1).."\nreturn OnEvent"))()
local host=Frame();host.display="XP";host.barType="XP";host.timeout=5
host.bar=Frame(host);host.restedbar=Frame(host)
local function Fire(ev)this=host;event=ev;onEvent()end
local function Width(expected)
    local fill=host.restedbar.cuiWatchFill
    assert(fill:IsShown(),"rested fill should be visible")
    assert(math.abs(fill:GetWidth()-expected)<.00001,"wrong rested width")
end
local function NoRest()
    assert(host.restedbar:GetValue()==0,"stale rested value")
    assert(not host.restedbar:IsShown(),"rested status bar should be hidden")
    assert(not host.restedbar.cuiWatchFill:IsShown(),"host-owned texture must hide immediately")
    for i=1,60 do ConsoleUI.config:SyncWatchFill(host.restedbar) end
    assert(not host.restedbar.cuiWatchFill:IsShown(),"frame sync revived rested fill")
end
Fire("PLAYER_XP_UPDATE");Width(400)
xp,maxxp,rest=5,150,nil;Fire("PLAYER_LEVEL_UP");NoRest()
assert(host.restedbar.max==150,"rested maximum must follow new level even when empty")
-- Inn/rested updates repaint immediately, without restarting the auto-hide timer.
clock=2;rest=30;local tick=host.tick;Fire("UPDATE_EXHAUSTION")
Width(400*35/150);assert(host.tick==tick,"passive rested update reset timeout")
rest=0;Fire("UPDATE_EXHAUSTION");NoRest()
rest=300;Fire("UPDATE_EXHAUSTION");Width(400)
-- A level-up with remaining rested XP must use the new XP/max, not clear it.
xp,maxxp,rest=12,200,20;Fire("PLAYER_LEVEL_UP");Width(64)
-- Switching away from XP clears both representations.
ConsoleUI.xpbar:ClearRestedFill(host);NoRest()
-- Hidden status bars cannot revive an old positive custom fill.
host.restedbar:SetValue(100);ConsoleUI.config:SyncWatchFill(host.restedbar)
assert(not host.restedbar.cuiWatchFill:IsShown(),"hidden positive value must not paint")
-- A new data update can show the same cached width/color again.
Fire("UPDATE_EXHAUSTION");Width(64)
-- Main XP continues to render even while the rested layer is absent.
rest=nil;Fire("UPDATE_EXHAUSTION");NoRest()
assert(host.bar.cuiWatchFill:IsShown(),"rested clearing hid normal XP")
print("Rested XP check OK: level-up, nil/zero, inn refresh, clamping, cached visibility, auto-hide")
