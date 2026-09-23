-- Standalone: lua ConsoleUI/config/check_frame_restore.lua
local path=arg and arg[0] or "ConsoleUI/config/check_frame_restore.lua"
local dir=string.gsub(path,"[^/]+$","")
local saved={buffXOffset=-120,buffYOffset=-40,debuffXOffset=-30,debuffYOffset=-55,
    minimapXOffset=-50,minimapYOffset=-25,petFrameXOffset=10,petFrameYOffset=-20,
    buffScale=1.3,debuffScale=1.2,unitFrameScalePlayer=1.3,unitFrameScalePet=1.1}
local frames={}
local function Frame(parent)
    return {parent=parent,scale=1,scripts={},GetParent=function(self)return self.parent end,
        GetScale=function(self)return self.scale end,SetScale=function(self,v)self.scale=v end,
        SetPoint=function(self,...)self.point={...}end,ClearAllPoints=function(self)self.point=nil end,
        GetPoint=function(self)return (unpack or table.unpack)(self.point or {})end,
        GetScript=function(self,k)return self.scripts[k]end,SetScript=function(self,k,v)self.scripts[k]=v end,
        RegisterEvent=function()end}
end
getglobal=function(name)return frames[name]end
CreateFrame=function()return Frame()end
local function Boot()
    UIParent=Frame(); frames={}
    for _,name in ipairs({"PlayerFrame","MinimapCluster","TemporaryEnchantFrame","BuffButton0","BuffButton16"}) do
        frames[name]=Frame(UIParent)
    end
    frames.PetFrame=Frame(frames.PlayerFrame)
    frames.PetFrame:SetPoint("TOPLEFT",frames.PlayerFrame,"TOPLEFT",80,-47)
    frames.Minimap=Frame(frames.MinimapCluster)
    BuffButtons_UpdatePositions=nil; PetFrame_Update=nil; UIParent_ManageFramePositions=nil
    ConsoleUI={config={Get=function(_,key)return saved[key]end}}
    dofile(dir.."unitframes.lua")
    ConsoleUI.config:InitializeUnitFrameScales()
    return ConsoleUI.config
end
local function Tick(cfg)
    local watcher=cfg.unitFrameScaleEvents
    local fn=watcher:GetScript("OnUpdate")
    assert(fn,"expected deferred restoration")
    fn()
    assert(not watcher:GetScript("OnUpdate"),"must stop after one deferred update")
end
local function Check()
    local buff=frames.TemporaryEnchantFrame.point
    assert(buff[2]==frames.MinimapCluster and buff[4]==-120 and buff[5]==-53,"buff offsets")
    local debuff=frames.BuffButton16.point
    assert(debuff[2]==frames.TemporaryEnchantFrame and debuff[4]==-30 and debuff[5]==-125,"debuff offsets")
    assert(frames.MinimapCluster.point[4]==-50 and frames.MinimapCluster.point[5]==-25,"minimap offsets")
    assert(frames.PetFrame.point[4]==90 and frames.PetFrame.point[5]==-67,"pet offsets")
    assert(math.abs(frames.PetFrame.scale*frames.PlayerFrame.scale-1.1)<.00001,"independent child scale")
end
local function BlizzardLayout()
    frames.TemporaryEnchantFrame:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT",0,0)
    frames.BuffButton16:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT",0,0)
    frames.MinimapCluster:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT",0,0)
    frames.PetFrame:SetPoint("TOPLEFT",frames.PlayerFrame,"TOPLEFT",80,-47)
end
for restart=1,2 do
    local cfg=Boot(); Check(); Tick(cfg)
    assert(not cfg._auraLayoutHooked and not cfg._petFrameHooked,"missing functions must remain hookable")
    -- Functions may appear later during startup. Retry without duplicate wrapping.
    BuffButtons_UpdatePositions=BlizzardLayout; PetFrame_Update=BlizzardLayout
    UIParent_ManageFramePositions=BlizzardLayout
    cfg:HookUnitFrameLayout()
    local wrapped=UIParent_ManageFramePositions
    cfg:HookUnitFrameLayout(); assert(UIParent_ManageFramePositions==wrapped,"duplicate hook")
    UIParent_ManageFramePositions(); Tick(cfg); Check()
    -- Simulate Blizzard processing the same login event after ConsoleUI.
    event="PLAYER_ENTERING_WORLD"; cfg.unitFrameScaleEvents:GetScript("OnEvent")()
    BlizzardLayout(); Tick(cfg); Check()
    -- Aura events also need to win over later handlers in the same frame.
    event="PLAYER_AURAS_CHANGED"; cfg.unitFrameScaleEvents:GetScript("OnEvent")()
    frames.TemporaryEnchantFrame:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT",0,0)
    Tick(cfg); Check()
    event="UNIT_AURA"; arg1="target"; cfg.unitFrameScaleEvents:GetScript("OnEvent")()
    assert(not cfg.unitFrameScaleEvents:GetScript("OnUpdate"),"ignore other units' aura events")
    arg1=nil
    -- Coalesce bursts and don't downgrade a full update to an aura-only update.
    cfg:QueueUnitFrameLayout(); cfg:QueueUnitFrameLayout(true)
    assert(cfg.unitFrameLayoutPending=="all"); Tick(cfg)
end
print("Frame restore check OK: startup/restart, late hooks, layout ordering, coalescing, offsets/scales")

-- A scaled map with DEFAULT aura offsets must also restore on a fresh login.
-- The previous check only covered nonzero offsets and missed this regression.
saved.buffXOffset,saved.buffYOffset,saved.debuffXOffset,saved.debuffYOffset=0,0,0,0
saved.minimapScale=1.6
for restart=1,2 do
    local cfg=Boot()
    local function CheckDefaultAuras()
        local buff=frames.TemporaryEnchantFrame.point
        assert(buff and buff[2]==frames.MinimapCluster and buff[3]=="TOPLEFT"
            and buff[4]==0 and buff[5]==-13,"zero-offset buffs must follow the map edge")
        local debuff=frames.BuffButton16.point
        assert(debuff and debuff[2]==frames.TemporaryEnchantFrame and debuff[4]==0
            and debuff[5]==-70,"zero-offset debuffs must follow the aura host")
        assert(frames.MinimapCluster.scale==saved.minimapScale,"map scale must persist")
    end
    CheckDefaultAuras(); Tick(cfg)
    event="PLAYER_ENTERING_WORLD";cfg.unitFrameScaleEvents:GetScript("OnEvent")()
    BlizzardLayout();Tick(cfg);CheckDefaultAuras()
    -- The minimap settings callback applies only the minimap, not every frame.
    saved.minimapScale=1.8;BlizzardLayout();cfg:ApplyMinimapScale();CheckDefaultAuras()
    saved.minimapScale=1;cfg:ApplyMinimapScale();CheckDefaultAuras()
    saved.minimapScale=1.6
end
print("Default aura restore OK: scaled map, zero offsets, fresh reload, live resize and reset")

-- Check the shared offset-row geometry without a WoW rendering dependency.
local f=assert(io.open(dir.."config.lua")); local src=f:read("*a"); f:close()
local a=assert(string.find(src,"function Config:AddOffsetRow",1,true))
local b=assert(string.find(src,"function Config:Set(",a,true))
assert((loadstring or load)("local Config=ConsoleUI.config\n"..string.sub(src,a,b-1)))()
local cfg=ConsoleUI.config
local function Widget()
    local w=Frame()
    w.SetWidth=function(self,v)self.width=v end
    w.SetHeight=function(self,v)self.height=v end
    w.SetText=function()end; w.SetJustifyH=function()end
    return w
end
cfg.CreateEditBox=function() local w=Widget();w.width=56;w.height=20;return w end
local box={contentLeft=12,contentTop=-28,CreateFontString=function()return Widget()end}
local x,y=cfg:AddOffsetRow(box,Widget(),"x","y",nil,nil,-102)
assert(x.point[1]=="TOPLEFT" and x.point[3]=="TOPRIGHT" and x.point[5]==0)
assert(y.point[1]=="TOPLEFT" and y.point[5]==0)
local label=x.point[2]
assert(label.height==20 and label.point[2]==box and label.point[5]==-102)
-- Above row's inputs: top -66, bottom -86. Offset row begins -102: 16px gap.
assert((-66-20)-label.point[5]>=12,"numeric rows need breathing room")
for _,id in ipairs({"xp","rep","swing"}) do
    assert(string.find(src,id.."Box.contentTop - 74)",1,true),id.." fixed offset row")
end
print("Settings row check OK: full-height labels, top-aligned inputs, fixed HUD row spacing")
