--[[
    Diamond icon clip for 1.12. No MaskTexture. No ScrollFrame.
    One texture per row. Size = diamond width at that Y. SetTexCoord
    samples that band of the icon. ScrollFrame was a miss: pinning the
    child made every strip show the same top pixels.
]]

ConsoleUI = ConsoleUI or {}
ConsoleUI.actionbars = ConsoleUI.actionbars or {}

local ActionBars = ConsoleUI.actionbars
local Layout = ActionBars.Layout
local SliceMask = {}
ActionBars.SliceMask = SliceMask

local function IconOf(button)
    if not button or not button.GetName then
        return nil
    end
    return getglobal(button:GetName() .. "Icon") or button.icon
end

local function PlaceStrip(tex, i, n, clip)
    local row = Layout.SliceRow(i, n, clip)
    if not row then
        tex:Hide()
        return
    end
    tex:SetWidth(row.width)
    tex:SetHeight(row.height)
    tex:ClearAllPoints()
    tex:SetPoint("TOPLEFT", tex:GetParent(), "TOPLEFT", row.left, -row.top)
    local u0, u1, v0, v1 = Layout.SliceTexCoord(i, n, clip)
    if u0 then
        tex:SetTexCoord(u0, u1, v0, v1)
    end
    tex:Show()
end

local function LayoutStrips(container, clip)
    local n = container._n
    local i
    for i = 1, n do
        PlaceStrip(container._tex[i], i, n, clip)
    end
    container:SetWidth(clip)
    container:SetHeight(clip)
    container._clip = clip
end

function SliceMask:Ensure(button, buttonSize)
    if not button or not Layout then
        return nil
    end
    local clip = Layout.SliceClipSize(buttonSize or button:GetWidth())
    local container = button._sliceMask
    if container and container._tex then
        if container._clip ~= clip then
            LayoutStrips(container, clip)
        end
        container:SetFrameLevel(button:GetFrameLevel() + 1)
        container:Show()
        return container
    end
    if container then
        container:Hide()
        button._sliceMask = nil
    end

    local n = Layout.SLICE_N
    local name = button:GetName() .. "SliceMask"
    container = CreateFrame("Frame", name, button)
    container:SetWidth(clip)
    container:SetHeight(clip)
    container:SetPoint("CENTER", button, "CENTER", 0, 0)
    container:SetFrameLevel(button:GetFrameLevel() + 1)
    if container.EnableMouse then
        container:EnableMouse(false)
    end
    container._tex = {}
    container._n = n

    local i
    for i = 1, n do
        local tex = container:CreateTexture(name .. i, "ARTWORK")
        container._tex[i] = tex
    end

    LayoutStrips(container, clip)
    button._sliceMask = container
    return container
end

function SliceMask:Remove(button)
    if not button then
        return
    end
    local container = button._sliceMask
    if container then
        container:Hide()
    end
    local icon = IconOf(button)
    if icon then
        icon:SetAlpha(1)
    end
    local flash = button.GetName and getglobal(button:GetName() .. "Flash")
    if flash then
        flash:SetAlpha(1)
    end
end

function SliceMask:Sync(button)
    local container = button and button._sliceMask
    if not container or not container._tex then
        return
    end
    local icon = IconOf(button)
    local path = icon and icon:GetTexture()
    if not icon or not path or not icon:IsShown() then
        container:Hide()
        return
    end
    container:Show()
    local r, g, b = icon:GetVertexColor()
    if not r then
        r, g, b = 1, 1, 1
    end
    local clip = container._clip
    local n = container._n
    local i
    for i = 1, n do
        local tex = container._tex[i]
        tex:SetTexture(path)
        PlaceStrip(tex, i, n, clip)
        tex:SetVertexColor(r, g, b)
    end
end

function SliceMask:SyncColor(button)
    local container = button and button._sliceMask
    if not container or not container._tex or not container:IsShown() then
        return
    end
    local icon = IconOf(button)
    if not icon then
        return
    end
    local r, g, b = icon:GetVertexColor()
    if not r then
        return
    end
    local i
    for i = 1, container._n do
        container._tex[i]:SetVertexColor(r, g, b)
    end
end
