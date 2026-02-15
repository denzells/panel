-- ============================================
-- VISUALS.LUA - MÓDULO DE VISUALES
-- ============================================

local Visuals = {}

local cfg, C, mk, rnd, tw
local so = 0

-- ============================================
-- INICIALIZACIÓN
-- ============================================
local function init()
    cfg = _G.PanelConfig
    C = cfg.C
    mk = cfg.mk
    rnd = cfg.rnd
    tw = cfg.Animations.tw
end

local function SO() so = so + 1; return so end

-- ============================================
-- MINI PANEL BUILDER
-- ============================================
local function MiniPanel(pg, title, fixedWidth)
    local PW = fixedWidth or nil
    local panel = mk("Frame",{
        Size=PW and UDim2.new(0,PW,0,0) or UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=C.PANEL, BorderSizePixel=0, LayoutOrder=SO()
    }, pg)
    rnd(6, panel)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.7}, panel)
    mk("TextLabel",{
        Text=title, Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,0,28), Position=UDim2.new(0,8,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, panel)
    local content = mk("Frame",{
        Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,28),
        AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1
    }, panel)
    mk("UIListLayout",{Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, content)
    mk("UIPadding",{PaddingBottom=UDim.new(0,8)}, panel)
    return content
end

-- ============================================
-- TOGGLE BUTTON
-- ============================================
local function CreateToggle(parent, label, defaultState, callback)
    local enabled = defaultState or false
    
    local row = mk("Frame",{
        Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    
    mk("TextLabel",{
        Text=label, Font=Enum.Font.Gotham, TextSize=9,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,0,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, row)
    
    local toggleBg = mk("Frame",{
        Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-36,0.5,-9),
        BackgroundColor3=enabled and C.RED or C.MUTED,
        BorderSizePixel=0, ZIndex=5
    }, row)
    rnd(9, toggleBg)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.3}, toggleBg)
    
    local toggleCircle = mk("Frame",{
        Size=UDim2.new(0,14,0,14),
        Position=enabled and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7),
        BackgroundColor3=C.WHITE, BorderSizePixel=0, ZIndex=6
    }, toggleBg)
    rnd(7, toggleCircle)
    
    local btn = mk("TextButton",{
        Text="", BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0), ZIndex=7, AutoButtonColor=false
    }, toggleBg)
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        tw(toggleBg, .2, {BackgroundColor3=enabled and C.RED or C.MUTED})
        tw(toggleCircle, .2, {Position=enabled and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        if callback then callback(enabled) end
    end)
    
    return {enabled=enabled, toggle=toggleBg}
end

-- ============================================
-- SLIDER
-- ============================================
local function CreateSlider(parent, label, min, max, default, callback)
    local value = default or min
    
    local row = mk("Frame",{
        Size=UDim2.new(1,0,0,34), BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    
    local lbl = mk("TextLabel",{
        Text=label, Font=Enum.Font.Gotham, TextSize=9,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(0.7,0,0,16), Position=UDim2.new(0,0,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, row)
    
    local valueLbl = mk("TextLabel",{
        Text=tostring(value), Font=Enum.Font.Code, TextSize=8,
        TextColor3=C.GRAY, BackgroundTransparency=1,
        Size=UDim2.new(0.3,0,0,16), Position=UDim2.new(0.7,0,0,0),
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=5
    }, row)
    
    local sliderBg = mk("Frame",{
        Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,1,-8),
        BackgroundColor3=C.MUTED, BorderSizePixel=0, ZIndex=5
    }, row)
    rnd(2, sliderBg)
    
    local sliderFill = mk("Frame",{
        Size=UDim2.new((value-min)/(max-min),0,1,0),
        BackgroundColor3=C.RED, BorderSizePixel=0, ZIndex=6
    }, sliderBg)
    rnd(2, sliderFill)
    
    table.insert(cfg.accentElements, {el=sliderFill, prop="BackgroundColor3"})
    
    local dragBtn = mk("TextButton",{
        Text="", BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,10), Position=UDim2.new(0,0,0,-5),
        ZIndex=7, AutoButtonColor=false
    }, sliderBg)
    
    local dragging = false
    
    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    cfg.Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    cfg.Services.RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mouse = cfg.Services.UIS:GetMouseLocation()
        local relativeX = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)
        valueLbl.Text = tostring(value)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        if callback then callback(value) end
    end)
    
    return {value=value, slider=sliderBg}
end

-- ============================================
-- INIT VISUALS PAGE
-- ============================================
function Visuals.init(page)
    init()
    
    -- Panel 1: ESP
    local espPanel = MiniPanel(page, "ESP")
    CreateToggle(espPanel, "Box ESP", false, function(state)
        print("Box ESP:", state)
    end)
    CreateToggle(espPanel, "Name ESP", false, function(state)
        print("Name ESP:", state)
    end)
    CreateToggle(espPanel, "Health ESP", false, function(state)
        print("Health ESP:", state)
    end)
    CreateToggle(espPanel, "Distance ESP", false, function(state)
        print("Distance ESP:", state)
    end)
    
    -- Panel 2: Visual Tweaks
    local visualPanel = MiniPanel(page, "Visual Tweaks")
    CreateToggle(visualPanel, "Fullbright", false, function(state)
        print("Fullbright:", state)
    end)
    CreateToggle(visualPanel, "Remove Fog", false, function(state)
        print("Remove Fog:", state)
    end)
    CreateSlider(visualPanel, "FOV", 70, 120, 90, function(val)
        print("FOV:", val)
    end)
    CreateSlider(visualPanel, "Brightness", 0, 100, 50, function(val)
        print("Brightness:", val)
    end)
    
    -- Panel 3: Tracers
    local tracersPanel = MiniPanel(page, "Tracers")
    CreateToggle(tracersPanel, "Player Tracers", false, function(state)
        print("Player Tracers:", state)
    end)
    CreateToggle(tracersPanel, "Item Tracers", false, function(state)
        print("Item Tracers:", state)
    end)
    
    print("[Visuals] ✓ Página Visuals cargada")
end

return Visuals