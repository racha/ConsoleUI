-- Standalone: lua ConsoleUI/config/check_profile_copy.lua
local dir=string.gsub(arg and arg[0] or "ConsoleUI/config/check_profile_copy.lua","[^/]+$","")
table.getn=table.getn or function(t)return #t end
SlashCmdList={};ConsoleUI_Debug=function()end;ConsoleUI_Print=function()end
local combat=false
UnitAffectingCombat=function()return combat end
HasAction=function()return nil end
CreateFrame=function()return {SetScript=function()end,Show=function()end,Hide=function()end}end
ConsoleUI={config={DEFAULTS={swingBarOffsetX=0}}}
local cfg=ConsoleUI.config
ConsoleUIDB={profileKey="Current",config={barXOffset=20,buffXOffset=10,barSizeV2=true},rings={},proxiedActions={}}
local source={key="Source",displayName="Source",class="HUNTER",config={barXOffset=-150,barYOffset=120,
    sideBarLeftOffset=45,xpBarOffsetY=35,castbarOffsetY=25,swingBarOffsetX=-10,
    minimapXOffset=-60,buffXOffset=-130,debuffYOffset=-70,unitFrameScalePlayer=1.3,petFrameXOffset=40},
    rings={custom={1,2}},proxiedActions={[30]="JUMP"},actionBars={}}
ConsoleUIProfileDB={characters={Current={key="Current",displayName="Current",class="HUNTER",config={}},Source=source}}
dofile(dir.."profiles.lua")
local profiles=ConsoleUI.profiles
local function Read(path)local f=assert(io.open(path));local s=f:read("*a");f:close();return s end
local src=Read(dir.."config.lua")
local function LoadSlice(first,last,preamble)
    local a=assert(string.find(src,first,1,true));local b=assert(string.find(src,last,a+1,true))
    assert((loadstring or load)((preamble or "local Config=ConsoleUI.config\n")..string.sub(src,a,b-1)))()
end
LoadSlice("function Config:RefreshSettingInputs()","function Config:CreateEditBox(")
local writes=0
local box={text="999",scripts={}}
box.GetScript=function(self,k)return self.scripts[k]end
box.SetScript=function(self,k,v)self.scripts[k]=v end
box.SetText=function(self,v)self.text=v;if self.scripts.OnTextChanged then self.scripts.OnTextChanged()end end
box.cuiGetValue=function()return tostring(ConsoleUIDB.config.barXOffset)end
box.scripts.OnTextChanged=function()writes=writes+1;ConsoleUIDB.config.barXOffset=999 end
cfg.settingEditBoxes={box}
local applied={}
local function Watch(name)
    return function()applied[name]=profiles.DeepCopy(ConsoleUIDB.config)end
end
cfg.UpdateActionBarLayout=Watch("main")
cfg.ApplyUnitFrameScales=Watch("blizzard")
cfg.QueueUnitFrameLayout=Watch("deferred")
ConsoleUI.actionbars={UpdateSideBars=Watch("touch"),UpdateAllButtons=function()end}
ConsoleUI.xpbar={UpdateAllBars=Watch("xp")}
ConsoleUI.castbar={ReloadConfig=Watch("cast")}
ConsoleUI.swingbar={ReloadConfig=Watch("swing")}
StaticPopupDialogs={}
local popupError
StaticPopup_Show=function(which,message)popupError={which,message}end
-- A different popup can occupy StaticPopup1; never use its data accidentally.
getglobal=function()return {data="Wrong profile"}end
LoadSlice('StaticPopupDialogs["ConsoleUI_COPY_CHARACTER_PROFILE"] = {','-- Helper function to trim whitespace')
this={GetParent=function()return {data="Source"}end} -- actual clicked button has no .data
StaticPopupDialogs.ConsoleUI_COPY_CHARACTER_PROFILE.OnAccept("Source")
assert(not popupError,"valid vanilla callback must not fail")
assert(ConsoleUIDB.config.barXOffset==-150 and ConsoleUIDB.config.buffXOffset==-130,"copy was a no-op")
assert(ConsoleUIDB.profileKey=="Current","copy must not switch character ownership")
assert(ConsoleUIDB.config.barSizeV2==true,"preserve this character's migration metadata")
assert(box.text=="-150" and writes==0,"refresh inputs without writing stale values")
assert(box.scripts.OnTextChanged,"restore editor handler")
for _,name in ipairs({"main","touch","xp","cast","swing","blizzard","deferred"}) do
    assert(applied[name] and applied[name].barXOffset==-150 and applied[name].buffXOffset==-130,
        name.." must apply copied values, not the previous profile")
end
local db=profiles:EnsureAccountDB()
assert(db.backups.Current.latest.config.barXOffset==20,"backup previous settings")
assert(db.characters.Current.config.barXOffset==-150,"save copied config in character snapshot")
ConsoleUIDB.rings.custom[1]=99
assert(source.rings.custom[1]==1,"source must not share mutable tables")
ConsoleUIDB.config.barXOffset=-200
assert(source.config.barXOffset==-150,"source config must remain untouched")
-- Subsequent focus loss would commit the refreshed text, not the pre-copy 999.
assert(tonumber(box.text)==-150)
combat=true
local ok=profiles:CopyFrom("Source");assert(not ok and ConsoleUIDB.config.barXOffset==-200,"combat must not partially copy")
combat=false
local restore=profiles.LoadActionBars
profiles.LoadActionBars=function()return false,"simulated restore failure"end
ok=profiles:CopyFrom("Source")
assert(not ok and ConsoleUIDB.config.barXOffset==-200,"failed restore must roll back config")
assert(applied.main.barXOffset==-200 and applied.blizzard.barXOffset==-200,"rollback must reapply positions")
assert(box.text=="-200" and writes==0,"rollback must refresh fields without callbacks")
profiles.LoadActionBars=restore
popupError=nil
StaticPopupDialogs.ConsoleUI_COPY_CHARACTER_PROFILE.OnAccept(nil)
assert(popupError and popupError[1]=="ConsoleUI_PROFILE_ERROR","missing source must not silently return")
print("Profile copy check OK: vanilla popup, live layouts, Blizzard offsets, editors, backups, source isolation, rollback")
