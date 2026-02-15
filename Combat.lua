-- ============================================
-- COMBAT.LUA - MÓDULO DE COMBATE
-- ============================================

local Combat = {}

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
-- BUTTON
-- ============================================
local function CreateButton(parent, label, callback)
    local btn = mk("TextButton",{
        Text=label, Font=Enum.Font.GothamSemibold, TextSize=9,
        TextColor3=C.WHITE, BackgroundColor3=Color3.fromRGB(28,28,28),
        BorderSizePixel=0, Size=UDim2.new(1,0,0,26), ZIndex=5,
        AutoButtonColor=false, LayoutOrder=SO()
    }, parent)
    rnd(5, btn)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.4}, btn)
    
    btn.MouseEnter:Connect(function()
        tw(btn, .1, {BackgroundColor3=Color3.fromRGB(35,35,35)})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, .1, {BackgroundColor3=Color3.fromRGB(28,28,28)})
    end)
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    return btn
end

-- ============================================
-- INIT COMBAT PAGE
-- ============================================
function Combat.init(page)
    init()
    
    -- Panel 1: Aimbots
    local aimbotPanel = MiniPanel(page, "Aimbots")
    CreateToggle(aimbotPanel, "Silent Aim", false, function(state)
        print("Silent Aim:", state)
    end)
    CreateToggle(aimbotPanel, "Aimbot", false, function(state)
        print("Aimbot:", state)
    end)
    CreateToggle(aimbotPanel, "Triggerbot", false, function(state)
        print("Triggerbot:", state)
    end)
    
    -- Panel 2: Combat
    local combatPanel = MiniPanel(page, "Combat")
    CreateToggle(combatPanel, "No Recoil", false, function(state)
        print("No Recoil:", state)
    end)
    CreateToggle(combatPanel, "No Spread", false, function(state)
        print("No Spread:", state)
    end)
    CreateToggle(combatPanel, "Infinite Ammo", false, function(state)
        print("Infinite Ammo:", state)
    end)
    
    -- Panel 3: Actions
    local actionsPanel = MiniPanel(page, "Quick Actions")
    CreateButton(actionsPanel, "Kill All", function()
        print("Kill All pressed!")
    end)
    CreateButton(actionsPanel, "Teleport to Player", function()
        print("Teleport pressed!")
    end)
    
    print("[Combat] ✓ Página Combat cargada")
end

return Combat