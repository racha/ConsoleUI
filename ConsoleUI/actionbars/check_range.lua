-- Standalone regression test; never loaded by the addon TOC.
-- lua ConsoleUI/actionbars/check_range.lua
local path = arg and arg[0] or "ConsoleUI/actionbars/check_range.lua"
local dir = string.gsub(path, "[^/]+$", "")
ConsoleUI = {}
dofile(dir .. "bars.lua")
dofile(dir .. "slicemask.lua")
local bars = ConsoleUI.actionbars
local now, pageOffset, rangeCalls, usableCalls = 10, 0, 0, 0
local slots, proxies, regions = {}, {}, {}
local function nop() end
local function Region()
    return {rgb={1,1,1}, shown=true, SetVertexColor=function(self,r,g,b) self.rgb={r,g,b} end,
        GetVertexColor=function(self) return self.rgb[1],self.rgb[2],self.rgb[3] end,
        SetTexture=function(self,v) self.texture=v end, GetTexture=function(self) return self.texture end,
        Show=function(self) self.shown=true end, Hide=function(self) self.shown=false end,
        IsShown=function(self) return self.shown end, IsVisible=function(self) return self.shown end,
        SetText=function(self,v) self.text=v end, ClearAllPoints=nop,SetPoint=nop,SetAlpha=nop}
end
getglobal=function(name) return regions[name] end
GameTooltip={IsOwned=function() return false end}
GetTime=function() return now end
HasAction=function(slot) return slots[slot] and slots[slot].texture and 1 end
ActionHasRange=function(slot) return slots[slot].hasRange end
IsActionInRange=function(slot) rangeCalls=rangeCalls+1; return slots[slot].range end
IsUsableAction=function(slot) usableCalls=usableCalls+1; return slots[slot].usable,slots[slot].mana end
GetActionTexture=function(slot) return slots[slot] and slots[slot].texture end
GetActionCooldown=function(slot) local s=slots[slot]; return s.start or 0,s.duration or 0,1 end
GetActionCount=function() return 1 end
IsConsumableAction=function() return nil end
IsCurrentAction=function() return nil end
IsAutoRepeatAction=function() return nil end
IsAttackAction=function() return nil end
ConsoleUI.proxied={IsSlotProxied=function(_,slot) return proxies[slot]~=nil end,
    GetSlotActionInfo=function(_,slot) return proxies[slot] end}
bars.GetActionOffset=function() return pageOffset end
bars.HasPlate=function() return false end
bars.ApplyButtonAppearance=nop
bars.IdleDiamond=nop
local function Button(name,slot)
    local b=Region()
    b.GetName=function() return name end
    b.GetID=function() return 1 end
    b.GetWidth=function() return 40 end
    b.GetButtonState=function() return "NORMAL" end
    b.SetChecked=nop
    b.actionSlot=slot
    b.flashing=0
    for _, suffix in ipairs({"Icon","NormalTexture","Overlay","Cooldown","Count","Flash","HotKey"}) do
        regions[name..suffix]=Region()
    end
    b.icon=regions[name.."Icon"]; b.cooldown=regions[name.."Cooldown"]; b.count=regions[name.."Count"]
    b._sliceMask=Region(); b._sliceMask._n=3; b._sliceMask._tex={Region(),Region(),Region()}
    b.circularCooldown=Region(); b.circularCooldown.GetParent=function() return b end
    b.circularCooldown.icon=b.icon; b.circularCooldown.text=Region(); b.circularCooldown.enabled=false
    return b
end
local function RGB(region,color,brightness)
    for i=1,3 do assert(math.abs(region.rgb[i]-color[i]*(brightness or 1))<0.000001,
        "color mismatch: "..table.concat(region.rgb,",")) end
end
local function Icon(b,color,brightness)
    RGB(b.icon,color,brightness)
    for i=1,3 do RGB(b._sliceMask._tex[i],color,brightness) end
end
local function Shot() return {texture="Shot",hasRange=1,range=0,usable=1} end
local main,side=Button("ConsoleActionButton1"),Button("ConsoleUILeftSideButton1",51)
for _, b in ipairs({main,side}) do
    local slot=b.actionSlot or 1
    slots[slot]=Shot()
    local function refresh() if b==main then bars:UpdateButton(b) else bars:UpdateSideBarButton(b) end end
    local function poll() if b==main then bars:ButtonOnUpdate(b,.21) else bars:SideBarButtonOnUpdate(b,.21) end end
    refresh(); Icon(b,bars.RANGE_COLOR)
    slots[slot].start=now; slots[slot].duration=2
    refresh(); Icon(b,bars.RANGE_COLOR,.3)
    now=now+1
    local priorRange,priorUsable=rangeCalls,usableCalls
    bars:UpdateCircularCooldown(b.circularCooldown)
    Icon(b,bars.RANGE_COLOR,.5)
    assert(rangeCalls==priorRange and usableCalls==priorUsable,"cooldown frames must not poll action APIs")
    RGB(regions[b:GetName().."NormalTexture"],bars.RANGE_COLOR)
    -- Enter shooting range while the cooldown is still active.
    slots[slot].range=1; poll(); Icon(b,bars.NORMAL_COLOR,.5)
    -- Leave it again (same API result for too close and too far).
    slots[slot].range=0; poll(); Icon(b,bars.RANGE_COLOR,.5)
    now=now+1; bars:UpdateCircularCooldown(b.circularCooldown)
    Icon(b,bars.RANGE_COLOR); poll(); Icon(b,bars.RANGE_COLOR)
    -- Losing a target must clear red; mana/unusable colors must survive cooldowns too.
    slots[slot].range=nil; slots[slot].usable=nil; slots[slot].mana=1
    poll(); Icon(b,bars.OOM_COLOR)
    bars:StartCircularCooldown(b,now,2); Icon(b,bars.OOM_COLOR,.3)
    bars:StopCircularCooldown(b); Icon(b,bars.OOM_COLOR)
    slots[slot].mana=nil; bars:UpdateButtonUsable(b); Icon(b,bars.NA_COLOR)
    RGB(regions[b:GetName().."NormalTexture"],bars.NORMAL_COLOR)
    bars:StartCircularCooldown(b,now,2); Icon(b,bars.NA_COLOR,.3)
    bars:StopCircularCooldown(b); Icon(b,bars.NA_COLOR)
    -- Replacing a red shot with a non-range action must clear and stop polling.
    slots[slot]=Shot(); refresh(); Icon(b,bars.RANGE_COLOR)
    slots[slot]={texture="Aspect",usable=1}; refresh()
    Icon(b,bars.NORMAL_COLOR); assert(not b.outofrange and not b.rangeTimer)
    RGB(regions[b:GetName().."HotKey"],{.6,.6,.6})
    -- Proxied bindings must not inherit the previous slot's cooldown or red tint.
    slots[slot]=Shot(); slots[slot].start=now; slots[slot].duration=2; refresh()
    proxies[slot]={icon="Jump",name="Jump",id="JUMP"}; refresh()
    Icon(b,bars.NORMAL_COLOR)
    assert(not b.outofrange and not b.rangeTimer and not b.circularCooldown.enabled)
    if b==main then bars:ButtonOnEvent(b,"ACTIONBAR_UPDATE_COOLDOWN")
    else bars:SideBarButtonOnEvent(b,"ACTIONBAR_UPDATE_COOLDOWN") end
    Icon(b,bars.NORMAL_COLOR); assert(not b.circularCooldown.enabled,"proxy must ignore underlying cooldown events")
    proxies[slot]=nil; slots[slot]=Shot(); refresh(); Icon(b,bars.RANGE_COLOR)
    slots[slot]={}; refresh()
    assert(not b.icon:IsShown() and not b.outofrange and not b.rangeTimer and not b.circularCooldown.enabled)
end
-- Modifier-page changes must query the displayed action, not the prior page.
slots[1]=Shot(); slots[11]={texture="Other page",hasRange=1,range=1,usable=1}
pageOffset=0; bars:UpdateButton(main); Icon(main,bars.RANGE_COLOR)
pageOffset=10; bars:UpdateButton(main); Icon(main,bars.NORMAL_COLOR)
slots[11].range=0; bars:ButtonOnUpdate(main,.21); Icon(main,bars.RANGE_COLOR)
slots[11].range=nil; bars:ButtonOnEvent(main,"PLAYER_TARGET_CHANGED"); Icon(main,bars.NORMAL_COLOR)
slots[51]=Shot(); bars:UpdateSideBarButton(side); Icon(side,bars.RANGE_COLOR)
slots[51].range=nil; bars:SideBarButtonOnEvent(side,"PLAYER_TARGET_CHANGED"); Icon(side,bars.NORMAL_COLOR)
-- Preserve the 200ms polling limit.
local priorRange=rangeCalls
for i=1,10 do bars:ButtonOnUpdate(main,.01) end
assert(rangeCalls==priorRange,"range polling must remain throttled")
-- Pet cooldowns use no action slot or usability/range queries.
local pet=Button("ConsoleUIPetButton7")
local priorUsable=usableCalls
bars:StartCircularCooldown(pet,now,2); Icon(pet,bars.NORMAL_COLOR,.3)
now=now+1; bars:UpdateCircularCooldown(pet.circularCooldown); Icon(pet,bars.NORMAL_COLOR,.5)
now=now+1; bars:UpdateCircularCooldown(pet.circularCooldown); Icon(pet,bars.NORMAL_COLOR)
assert(usableCalls==priorUsable and rangeCalls==priorRange,"pet cooldown must not query player actions")
print("Range check OK: main/touch, cooldowns, masks, target/page/slot swaps, proxy, mana, pet, polling")
