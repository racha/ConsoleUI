local ns = ConsoleUIKeyboardNS
local U = ns.Util
local Language = ns
local Keyboard = ConsoleUIKeyboard

local function Fail(list, msg)
    table.insert(list, msg)
end

function Keyboard:RunSelfCheck(printResult)
    local fails = {}

    local ok, why = U.LayoutOk(Language.English)
    if not ok then Fail(fails, "English layout: " .. tostring(why)) end

    if U.SelectDir(true, false, false, false) ~= 1 then Fail(fails, "SelectDir up") end
    if U.SelectDir(true, false, false, true) ~= 2 then Fail(fails, "SelectDir up+right") end
    if U.SelectDir(false, false, false, true) ~= 3 then Fail(fails, "SelectDir right") end
    if U.SelectDir(false, true, false, true) ~= 4 then Fail(fails, "SelectDir down+right") end
    if U.SelectDir(false, true, false, false) ~= 5 then Fail(fails, "SelectDir down") end
    if U.SelectDir(false, true, true, false) ~= 6 then Fail(fails, "SelectDir down+left") end
    if U.SelectDir(false, false, true, false) ~= 7 then Fail(fails, "SelectDir left") end
    if U.SelectDir(true, false, true, false) ~= 8 then Fail(fails, "SelectDir up+left") end
    if U.SelectDir(false, false, false, false) ~= 9 then Fail(fails, "SelectDir center") end

    if U.ModifierIndex(false, false) ~= 2 then Fail(fails, "layer none") end
    if U.ModifierIndex(true, false) ~= 1 then Fail(fails, "layer shift") end
    if U.ModifierIndex(false, true) ~= 3 then Fail(fails, "layer ctrl") end
    if U.ModifierIndex(true, true) ~= 4 then Fail(fails, "layer shift+ctrl") end

    if U.utf8len("abc") ~= 3 then Fail(fails, "utf8len abc") end
    if U.utf8sub("abcdef", 2, 3) ~= "bcd" then Fail(fails, "utf8sub") end
    if U.byteToChars("abc", 2) ~= 2 then Fail(fails, "byteToChars") end
    if U.charsToByte("abc", 2) ~= 2 then Fail(fails, "charsToByte") end
    if U.trim("  hi  ") ~= "hi" then Fail(fails, "trim") end

    local u, n = U.Union("banana")
    if n ~= 3 then Fail(fails, "Union count") end
    if not string.find(u, "b") or not string.find(u, "a") or not string.find(u, "n") then
        Fail(fails, "Union chars")
    end

    if not U.IsWordChar("a") then Fail(fails, "IsWordChar a") end
    if U.IsWordChar(" ") then Fail(fails, "IsWordChar space") end
    if not U.IsOurBinding("CONSOLEUIK_FACE_A") then Fail(fails, "IsOurBinding") end
    if U.IsOurBinding("ConsoleUI_ACTION_1") then Fail(fails, "IsOurBinding false positive") end

    if Language.English[1][1][2] ~= "a" then Fail(fails, "English A lowercase") end
    if Language.English[1][1][1] ~= "A" then Fail(fails, "English A uppercase") end
    if Language.English[1][1][4] ~= "/s " then Fail(fails, "English A slash") end
    if Language.English[4][1][4] ~= "Thank you" then Fail(fails, "English phrase layer") end
    if Language.English[8][1][2] ~= "!" then Fail(fails, "letter layer missing common symbols") end
    local si, sj, sk
    for si = 1, 8 do
        for sj = 1, 4 do
            for sk = 1, 4 do
                if string.find(Language.English[si][sj][sk], "{rt") then
                    Fail(fails, "raid marker still in English")
                end
            end
        end
    end

    if not Keyboard.CreateCharset then Fail(fails, "CreateCharset missing") end
    if not Keyboard.AUTOCOMPLETE then Fail(fails, "AUTOCOMPLETE missing") end
    if not Keyboard.PickGuess or not Keyboard.CycleGuess then Fail(fails, "PickGuess missing") end
    if not Keyboard.GenerateDictionary then Fail(fails, "GenerateDictionary missing") end
    if not Keyboard.HookEditBoxes then Fail(fails, "HookEditBoxes missing") end
    if not Keyboard.StealKeys then Fail(fails, "StealKeys missing") end
    if Keyboard.StealCount ~= 69 then
        Fail(fails, "steal list should be 17 keys x 4 modifiers + Escape, got " .. tostring(Keyboard.StealCount))
    end
    if not CONSOLEUIK_Pad or not CONSOLEUIK_Face or not CONSOLEUIK_Accept or not CONSOLEUIK_Guess or not CONSOLEUIK_Close then
        Fail(fails, "binding globals missing")
    end

    if Keyboard.Sets and table.getn(Keyboard.Sets) ~= 9 then
        Fail(fails, "expected 9 charsets, got " .. tostring(table.getn(Keyboard.Sets)))
    end
    if Keyboard.Sets and Keyboard.Sets[1] and table.getn(Keyboard.Sets[1].Buttons) ~= 4 then
        Fail(fails, "cluster 1 button count")
    end

    local copied = U.CopyLayout(Language.English)
    copied[1][1][2] = "changed"
    if Language.English[1][1][2] == "changed" then
        Fail(fails, "CopyLayout mutated source")
    end

    local count = table.getn(fails)
    if printResult then
        if count == 0 then
            U.Print("self-check passed")
        else
            U.Print("self-check FAILED (" .. count .. ")")
            local i
            for i = 1, count do
                U.Print("  " .. fails[i])
            end
        end
    else
        local i
        for i = 1, count do
            U.Debug("self-check " .. fails[i])
        end
    end
    return count == 0, fails
end

local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_ENTERING_WORLD")
boot:SetScript("OnEvent", function()
    this:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if Keyboard.RunSelfCheck then
        Keyboard:RunSelfCheck(false)
    end
end)
