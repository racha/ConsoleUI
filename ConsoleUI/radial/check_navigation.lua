local path = arg and arg[0] or "radial/check_navigation.lua"
local dir = string.gsub(path, "[^/]+$", "")

if not table.getn then
    table.getn = function(list)
        local count = 0
        while list[count + 1] ~= nil do
            count = count + 1
        end
        return count
    end
end

ConsoleUI = {}
ConsoleUI_Debug = function() end

local actionByKey = {}
local keyOrder = { "W", "S", "A", "D", "Q", "E", "LEFT", "RIGHT", "1", "2", "3", "4" }

GetBindingAction = function(key)
    return actionByKey[key] or ""
end

GetBindingKey = function(action)
    local first = nil
    local second = nil
    local i
    for i = 1, table.getn(keyOrder) do
        local key = keyOrder[i]
        if actionByKey[key] == action then
            if not first then
                first = key
            elseif not second then
                second = key
            end
        end
    end
    return first, second
end

SetBinding = function(key, action)
    actionByKey[key] = action
    return true
end

dofile(dir .. "radial.lua")

local function Expect(key, action, label)
    if actionByKey[key] ~= action then
        error(label .. " " .. key .. " expected=" .. tostring(action) .. " got=" .. tostring(actionByKey[key]))
    end
end

local function Reset(layout)
    actionByKey = layout
    ConsoleUI.radial.stickBindings = nil
    ConsoleUI.radial.lastMovementBindings = nil
end

local function AddFaceBindings(layout)
    layout["1"] = "ConsoleUI_ACTION_1"
    layout["2"] = "ConsoleUI_ACTION_2"
    layout["3"] = "ConsoleUI_ACTION_3"
    layout["4"] = "ConsoleUI_ACTION_4"
    return layout
end

Reset(AddFaceBindings({
    W = "MOVEFORWARD",
    S = "MOVEBACKWARD",
    A = "TURNLEFT",
    D = "TURNRIGHT",
    Q = "STRAFELEFT",
    E = "STRAFERIGHT",
}))

ConsoleUI.radial:ActivateStickNavigation()
Expect("A", "ConsoleUI_RADIAL_LEFT", "default turn capture")
Expect("D", "ConsoleUI_RADIAL_RIGHT", "default turn capture")
Expect("Q", "ConsoleUI_RADIAL_LEFT", "default strafe capture")
Expect("E", "ConsoleUI_RADIAL_RIGHT", "default strafe capture")
ConsoleUI.radial:RestoreStickNavigation()
Expect("A", "TURNLEFT", "default turn restore")
Expect("D", "TURNRIGHT", "default turn restore")
Expect("Q", "STRAFELEFT", "default strafe restore")
Expect("E", "STRAFERIGHT", "default strafe restore")

Reset(AddFaceBindings({
    W = "MOVEFORWARD",
    S = "MOVEBACKWARD",
    A = "STRAFELEFT",
    D = "STRAFERIGHT",
    LEFT = "TURNLEFT",
    RIGHT = "TURNRIGHT",
}))

ConsoleUI.radial:ActivateStickNavigation()
Expect("A", "ConsoleUI_RADIAL_LEFT", "custom strafe capture")
Expect("D", "ConsoleUI_RADIAL_RIGHT", "custom strafe capture")
Expect("LEFT", "ConsoleUI_RADIAL_LEFT", "custom turn capture")
Expect("RIGHT", "ConsoleUI_RADIAL_RIGHT", "custom turn capture")
ConsoleUI.radial:RestoreStickNavigation()
Expect("A", "STRAFELEFT", "custom strafe restore")
Expect("D", "STRAFERIGHT", "custom strafe restore")
Expect("LEFT", "TURNLEFT", "custom turn restore")
Expect("RIGHT", "TURNRIGHT", "custom turn restore")

print("Radial navigation check OK")
