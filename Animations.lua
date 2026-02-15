-- ============================================
-- ANIMATIONS.LUA - MÓDULO DE ANIMACIONES
-- ============================================

local Animations = {}

local cfg, C, mk, rnd
local TweenService, UIS, RunService
local IMGS = 20

-- ============================================
-- INICIALIZACIÓN
-- ============================================
local function init()
    cfg = _G.PanelConfig
    C = cfg.C
    mk = cfg.mk
    rnd = cfg.rnd
    TweenService = cfg.Services.TweenService
    UIS = cfg.Services.UIS
    RunService = cfg.Services.RunService
end

-- ============================================
-- FUNCIÓN DE TWEEN
-- ============================================
function Animations.tw(o, t, props, es, ed)
    TweenService:Create(o,
        TweenInfo.new(t, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out),
        props):Play()
end

-- ============================================
-- HOVER EFFECTS
-- ============================================
function Animations.setupButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        Animations.tw(button, .1, {TextColor3=hoverColor})
    end)
    button.MouseLeave:Connect(function()
        Animations.tw(button, .1, {TextColor3=normalColor})
    end)
end

-- ============================================
-- TABS SYSTEM
-- ============================================
function Animations.setupTabs(NavBar, TDEFS, TBW, TBW_EXPANDED, GAP, NT)
    init()
    
    local function updateTabPositions(activeIndex)
        local cx = 4
        for i=1,NT do
            local t = cfg.navT[i]
            local w = (i==activeIndex) and TBW_EXPANDED or TBW
            t.targetX = cx
            t.targetW = w
            cx = cx + w + GAP
        end
    end
    
    for i, td in ipairs(TDEFS) do
        local isF = (i==1)
        local pill = mk("Frame",{
            Size=UDim2.new(0, isF and TBW_EXPANDED or TBW, 0, cfg.NH-8),
            Position=UDim2.new(0, 0, 0, 4),
            BackgroundColor3=isF and C.NAVPIL or C.NAV,
            BorderSizePixel=0, ZIndex=isF and 15 or 10
        }, NavBar)
        rnd(10, pill)
        
        local img = mk("ImageLabel",{
            Size=UDim2.new(0, IMGS, 0, IMGS),
            Position=isF and UDim2.new(0, 10, 0.5, -IMGS/2) or UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2),
            BackgroundTransparency=1, Image=td.img,
            ImageColor3=isF and C.RED or C.MUTED, ZIndex=11
        }, pill)
        
        local lbl = mk("TextLabel",{
            Text=td.lbl, Font=Enum.Font.GothamSemibold, TextSize=10,
            TextColor3=C.WHITE, BackgroundTransparency=1,
            Size=UDim2.new(0, 64, 1, 0), Position=UDim2.new(0, 36, 0, 0),
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTransparency=isF and 0 or 1, ZIndex=11
        }, pill)
        
        local hit = mk("TextButton",{
            Text="", BackgroundTransparency=1,
            Size=UDim2.new(1, 0, 1, 0), ZIndex=16, AutoButtonColor=false
        }, pill)
        
        cfg.navT[i] = {pill=pill, img=img, lbl=lbl, targetX=0, targetW=isF and TBW_EXPANDED or TBW}
        
        hit.MouseButton1Click:Connect(function()
            if cfg.activeTab == i then return end
            
            local pv = cfg.navT[cfg.activeTab]
            pv.pill.ZIndex = 10
            Animations.tw(pv.pill, .25, {BackgroundColor3=C.NAV}, Enum.EasingStyle.Quint)
            Animations.tw(pv.img, .25, {Position=UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2), ImageColor3=C.MUTED}, Enum.EasingStyle.Quint)
            Animations.tw(pv.lbl, .15, {TextTransparency=1})
            cfg.tPages[cfg.activeTab].Parent.Visible = false
            
            cfg.activeTab = i
            cfg.tPages[i].Parent.Visible = true
            pill.ZIndex = 15
            
            updateTabPositions(i)
            for j=1,NT do
                local nt = cfg.navT[j]
                Animations.tw(nt.pill, .25, {Size=UDim2.new(0, nt.targetW, 0, cfg.NH-8), Position=UDim2.new(0, nt.targetX, 0, 4)}, Enum.EasingStyle.Quint)
            end
            
            Animations.tw(pill, .25, {BackgroundColor3=C.NAVPIL}, Enum.EasingStyle.Quint)
            Animations.tw(img, .25, {Position=UDim2.new(0, 10, 0.5, -IMGS/2), ImageColor3=C.RED}, Enum.EasingStyle.Quint)
            task.delay(.1, function()
                Animations.tw(lbl, .2, {TextTransparency=0})
            end)
        end)
        
        hit.MouseEnter:Connect(function()
            if cfg.activeTab ~= i then
                Animations.tw(img, .1, {ImageColor3=C.GRAY})
            end
        end)
        hit.MouseLeave:Connect(function()
            if cfg.activeTab ~= i then
                Animations.tw(img, .1, {ImageColor3=C.MUTED})
            end
        end)
    end
    
    updateTabPositions(1)
    for i=1,NT do
        local t = cfg.navT[i]
        t.pill.Position = UDim2.new(0, t.targetX, 0, 4)
    end
end

-- ============================================
-- DRAG SYSTEM
-- ============================================
function Animations.setupDrag(TBar, Win, NavBar, WW, WH, NGAP)
    init()
    
    local function applyPos(wx, wy)
        Win.Position = UDim2.new(0.5, wx, 0.5, wy)
        NavBar.Position = UDim2.new(0.5, wx + (WW-cfg.NW)/2, 0.5, wy + WH + NGAP)
    end
    
    local dragging = false
    local mStart = Vector2.new()
    local wStart = Vector2.new()
    
    local DragHit = mk("TextButton",{
        Text="", BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1, -72, 1, 0), Position=UDim2.new(0, 0, 0, 0),
        ZIndex=50, AutoButtonColor=false,
    }, TBar)
    
    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true
        mStart = mp
        wStart = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation()
        local d = mp - mStart
        local tx = wStart.X + d.X
        local ty = wStart.Y + d.Y
        local cx = Win.Position.X.Offset
        local cy = Win.Position.Y.Offset
        local nx = cx + (tx - cx) * 0.5
        local ny = cy + (ty - cy) * 0.5
        if math.abs(nx - tx) < 0.3 then nx = tx end
        if math.abs(ny - ty) < 0.3 then ny = ty end
        applyPos(nx, ny)
    end)
end

-- ============================================
-- MINIMIZE
-- ============================================
function Animations.setupMinimize()
    init()
    
    local minimized = false
    local animating = false
    
    cfg.MinB.MouseButton1Click:Connect(function()
        if animating then return end
        animating = true
        minimized = not minimized
        
        if minimized then
            for _, t in ipairs(cfg.navT) do
                Animations.tw(t.pill, .15, {BackgroundTransparency=1}, Enum.EasingStyle.Sine)
                Animations.tw(t.img, .15, {ImageTransparency=1}, Enum.EasingStyle.Sine)
                Animations.tw(t.lbl, .12, {TextTransparency=1}, Enum.EasingStyle.Sine)
            end
            Animations.tw(cfg.BodyClip, .3, {Size=UDim2.new(0, cfg.WW, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Animations.tw(cfg.Win, .3, {Size=UDim2.new(0, cfg.WW, 0, cfg.TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Animations.tw(cfg.WinStroke, .25, {Transparency=0.5})
            task.delay(.1, function()
                Animations.tw(cfg.NavBar, .25, {Size=UDim2.new(0, cfg.NW, 0, 0), BackgroundTransparency=1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Animations.tw(cfg.NavStroke, .2, {Transparency=1})
            end)
            for i, title in ipairs(cfg.titles) do
                local trans = {0.5, 0.5, 0.7, 0.8, 0.8}
                Animations.tw(title, .2, {TextTransparency=trans[i]})
            end
            task.delay(.35, function()
                cfg.NavBar.Visible = false
                animating = false
            end)
        else
            cfg.NavBar.Visible = true
            cfg.NavBar.Size = UDim2.new(0, cfg.NW, 0, 0)
            cfg.NavBar.BackgroundTransparency = 1
            cfg.NavStroke.Transparency = 1
            for _, t in ipairs(cfg.navT) do
                t.pill.BackgroundTransparency = 1
                t.img.ImageTransparency = 1
                t.lbl.TextTransparency = 1
            end
            Animations.tw(cfg.Win, .35, {Size=UDim2.new(0, cfg.WW, 0, cfg.WH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Animations.tw(cfg.BodyClip, .35, {Size=UDim2.new(0, cfg.WW, 0, cfg.WH-cfg.TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Animations.tw(cfg.WinStroke, .3, {Transparency=0.2})
            task.delay(.05, function()
                Animations.tw(cfg.NavBar, .35, {Size=UDim2.new(0, cfg.NW, 0, cfg.NH), BackgroundTransparency=0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Animations.tw(cfg.NavStroke, .3, {Transparency=0.2})
                for _, title in ipairs(cfg.titles) do
                    Animations.tw(title, .25, {TextTransparency=0})
                end
            end)
            task.delay(.3, function()
                for i, t in ipairs(cfg.navT) do
                    local isActive = (i == cfg.activeTab)
                    task.delay(i * .025, function()
                        Animations.tw(t.pill, .2, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
                        Animations.tw(t.img, .2, {ImageTransparency=0}, Enum.EasingStyle.Sine)
                        if isActive then
                            Animations.tw(t.lbl, .2, {TextTransparency=0}, Enum.EasingStyle.Sine)
                        end
                    end)
                end
            end)
            task.delay(.5, function()
                animating = false
            end)
        end
        
        cfg.MinB.Text = minimized and "□" or "─"
    end)
end

-- ============================================
-- CLOSE
-- ============================================
function Animations.setupClose(SG)
    init()
    
    local animating = false
    
    local function doClose()
        if animating then return end
        animating = true
        cfg.Win.Active = false
        cfg.NavBar.Active = false
        
        for _, t in ipairs(cfg.navT) do
            Animations.tw(t.pill, .12, {BackgroundTransparency=1}, Enum.EasingStyle.Sine)
            Animations.tw(t.img, .12, {ImageTransparency=1}, Enum.EasingStyle.Sine)
            Animations.tw(t.lbl, .1, {TextTransparency=1}, Enum.EasingStyle.Sine)
        end
        
        task.delay(.08, function()
            Animations.tw(cfg.NavBar, .25, {Size=UDim2.new(0, cfg.NW, 0, 0), BackgroundTransparency=1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            Animations.tw(cfg.NavStroke, .2, {Transparency=1})
        end)
        
        task.delay(.2, function()
            Animations.tw(cfg.BodyClip, .3, {Size=UDim2.new(0, 0, 0, 0), Position=UDim2.new(0, cfg.WW/2, 0, cfg.TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            Animations.tw(cfg.rdot, .2, {BackgroundTransparency=1})
            for _, title in ipairs(cfg.titles) do
                Animations.tw(title, .2, {TextTransparency=1})
            end
            Animations.tw(cfg.MinB, .2, {TextTransparency=1})
            Animations.tw(cfg.ClsB, .2, {TextTransparency=1})
        end)
        
        task.delay(.4, function()
            Animations.tw(cfg.Win, .35, {Size=UDim2.new(0, 0, 0, 0), BackgroundTransparency=1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            Animations.tw(cfg.WinStroke, .3, {Transparency=1})
        end)
        
        task.delay(.8, function()
            SG:Destroy()
        end)
    end
    
    cfg.ClsB.MouseButton1Click:Connect(doClose)
    cfg.doClose = doClose
end

-- ============================================
-- KEYBINDS
-- ============================================
function Animations.setupKeybinds()
    init()
    
    local hidden = false
    local animating = false
    
    UIS.InputBegan:Connect(function(i, gp)
        if gp or animating then return end
        
        -- Toggle visibility
        if i.KeyCode == cfg.toggleKey then
            hidden = not hidden
            if hidden then
                Animations.tw(cfg.Win, .2, {BackgroundTransparency=1}, Enum.EasingStyle.Sine)
                Animations.tw(cfg.WinStroke, .2, {Transparency=1})
                Animations.tw(cfg.NavBar, .2, {BackgroundTransparency=1}, Enum.EasingStyle.Sine)
                Animations.tw(cfg.NavStroke, .2, {Transparency=1})
                task.delay(.2, function()
                    cfg.Win.Visible = false
                    cfg.NavBar.Visible = false
                end)
            else
                cfg.Win.Visible = true
                cfg.NavBar.Visible = true
                cfg.Win.BackgroundTransparency = 1
                cfg.WinStroke.Transparency = 1
                cfg.NavBar.BackgroundTransparency = 1
                cfg.NavStroke.Transparency = 1
                Animations.tw(cfg.Win, .25, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
                Animations.tw(cfg.WinStroke, .25, {Transparency=0.2})
                Animations.tw(cfg.NavBar, .25, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
                Animations.tw(cfg.NavStroke, .25, {Transparency=0.2})
            end
        end
        
        -- Close
        if i.KeyCode == cfg.closeKey then
            cfg.doClose()
        end
    end)
end

-- ============================================
-- ANIMACIÓN DE APERTURA
-- ============================================
function Animations.playOpenAnimation()
    init()
    
    cfg.Win.Size = UDim2.new(0, cfg.WW/3, 0, cfg.TH)
    cfg.Win.BackgroundTransparency = 1
    cfg.WinStroke.Transparency = 1
    cfg.NavBar.Size = UDim2.new(0, 0, 0, 0)
    cfg.NavBar.BackgroundTransparency = 1
    cfg.NavStroke.Transparency = 1
    cfg.BodyClip.Size = UDim2.new(0, cfg.WW, 0, 0)
    cfg.BodyClip.Position = UDim2.new(0, 0, 0, cfg.TH)
    cfg.rdot.BackgroundTransparency = 1
    
    for _, title in ipairs(cfg.titles) do
        title.TextTransparency = 1
    end
    cfg.MinB.TextTransparency = 1
    cfg.ClsB.TextTransparency = 1
    
    for _, t in ipairs(cfg.navT) do
        t.pill.BackgroundTransparency = 1
        t.img.ImageTransparency = 1
        t.lbl.TextTransparency = 1
    end
    
    Animations.tw(cfg.Win, .4, {Size=UDim2.new(0, cfg.WW, 0, cfg.TH), BackgroundTransparency=0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    Animations.tw(cfg.WinStroke, .35, {Transparency=0.2})
    
    task.delay(.1, function()
        Animations.tw(cfg.rdot, .3, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
        task.delay(.05, function() Animations.tw(cfg.titles[1], .3, {TextTransparency=0}, Enum.EasingStyle.Sine) end)
        task.delay(.08, function() Animations.tw(cfg.titles[2], .3, {TextTransparency=0}, Enum.EasingStyle.Sine) end)
        task.delay(.11, function() Animations.tw(cfg.titles[3], .3, {TextTransparency=0}, Enum.EasingStyle.Sine) end)
        task.delay(.14, function() Animations.tw(cfg.titles[4], .3, {TextTransparency=0}, Enum.EasingStyle.Sine) end)
        task.delay(.17, function() Animations.tw(cfg.titles[5], .3, {TextTransparency=0}, Enum.EasingStyle.Sine) end)
        task.delay(.2, function()
            Animations.tw(cfg.MinB, .25, {TextTransparency=0}, Enum.EasingStyle.Sine)
            Animations.tw(cfg.ClsB, .25, {TextTransparency=0}, Enum.EasingStyle.Sine)
        end)
    end)
    
    task.delay(.25, function()
        Animations.tw(cfg.Win, .45, {Size=UDim2.new(0, cfg.WW, 0, cfg.WH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        Animations.tw(cfg.BodyClip, .45, {Size=UDim2.new(0, cfg.WW, 0, cfg.WH-cfg.TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end)
    
    task.delay(.5, function()
        Animations.tw(cfg.NavBar, .4, {Size=UDim2.new(0, cfg.NW, 0, cfg.NH), BackgroundTransparency=0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        Animations.tw(cfg.NavStroke, .35, {Transparency=0.2})
        task.delay(.25, function()
            for i, t in ipairs(cfg.navT) do
                local isActive = (i == cfg.activeTab)
                task.delay(i * .04, function()
                    Animations.tw(t.pill, .3, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
                    Animations.tw(t.img, .3, {ImageTransparency=0}, Enum.EasingStyle.Sine)
                    if isActive then
                        Animations.tw(t.lbl, .3, {TextTransparency=0}, Enum.EasingStyle.Sine)
                    end
                end)
            end
        end)
    end)
end

return Animations