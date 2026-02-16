-- ============================================================
-- main.lua  –  PanelBase | dzanity.gg
-- ============================================================

local RAW_BASE = "https://raw.githubusercontent.com/dzanity-gg/dzanity.gg/main/"

local function loadModule(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(RAW_BASE .. path))()
    end)
    if not ok then
        warn("[PanelBase] Error cargando " .. path .. ": " .. tostring(result))
        return nil
    end
    return result
end

local Animations = loadModule("animations.lua")
local Settings   = loadModule("settings.lua")
local Combat     = loadModule("combat.lua")
local Visuals    = loadModule("visuals.lua")
local Commands   = loadModule("commands.lua")

if not Animations or not Settings then
    warn("[PanelBase] Falló la carga de módulos. Abortando.")
    return
end

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui", 10)
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

local C = Settings.C
local W = Settings.Layout

local function mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    if parent then obj.Parent = parent end
    return obj
end

local function rnd(r, p)
    mk("UICorner", { CornerRadius = UDim.new(0, r) }, p)
end

local function tw(obj, t, props, es, ed)
    TweenService:Create(obj,
        TweenInfo.new(t, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out),
        props):Play()
end

-- ── SCREENGUI ────────────────────────────────────────────────
local SG = mk("ScreenGui", {
    Name           = "PanelBase",
    ResetOnSpawn   = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local Win, NavBar, BodyClip

local function applyPos(wx, wy)
    Win.Position    = UDim2.new(0.5, wx, 0.5, wy)
    NavBar.Position = UDim2.new(0.5, wx + (W.WW - W.NW) / 2, 0.5, wy + W.WH + W.NGAP)
end

-- ── MAIN WINDOW ──────────────────────────────────────────────
Win = mk("Frame", {
    Size             = UDim2.new(0, W.WW, 0, W.WH),
    Position         = UDim2.new(0.5, -W.WW/2, 0.5, -W.WH/2),
    BackgroundColor3 = C.WIN,
    BorderSizePixel  = 0, ClipsDescendants = false, ZIndex = 3,
}, SG)
rnd(14, Win)
local WinStroke = mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, Win)

-- ══════════════════════════════════════════════════════════════
-- ── PARTÍCULAS ESTILO STARSPACE ───────────────────────────────
-- Pequeñas, rojas, flotando por todo el panel sin dirección fija
-- ══════════════════════════════════════════════════════════════
do
    local CFG = {
        COUNT      = 22,          -- total de partículas vivas al mismo tiempo
        IMG        = "rbxassetid://120297604949715",
        SIZE_MIN   = 5,
        SIZE_MAX   = 13,
        -- Colores: rojo intenso, rojo oscuro, rojo rosado, naranja rojizo
        COLORS = {
            Color3.fromRGB(255,  40,  40),
            Color3.fromRGB(200,  20,  20),
            Color3.fromRGB(255,  80,  80),
            Color3.fromRGB(220,  55,  55),
            Color3.fromRGB(180,  15,  15),
        },
        -- Transparencia: la mayoría semi-invisibles, pocas muy brillantes
        ALPHA = { 0.25, 0.45, 0.55, 0.65, 0.30 },
        -- Velocidad de movimiento (píxeles por segundo, muy lento)
        SPEED_MIN  = 6,
        SPEED_MAX  = 22,
        -- Duración del ciclo de vida completo de cada partícula
        LIFE_MIN   = 5.0,
        LIFE_MAX   = 10.0,
        -- Fade in / fade out
        FADE_DUR   = 1.2,
    }

    local function rng(a, b) return a + (b - a) * math.random() end
    local function pick(t)   return t[math.random(#t)] end

    local function stw(obj, dur, props, es, ed)
        TweenService:Create(obj,
            TweenInfo.new(dur,
                es or Enum.EasingStyle.Sine,
                ed or Enum.EasingDirection.InOut),
            props):Play()
    end

    -- Contenedor que cubre todo el Win, detrás del contenido
    local StarContainer = mk("Frame", {
        Name                   = "StarParticles",
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        ZIndex                 = 1,
    }, Win)

    local function spawnParticle()
        local sz    = rng(CFG.SIZE_MIN, CFG.SIZE_MAX)
        local life  = rng(CFG.LIFE_MIN, CFG.LIFE_MAX)
        local color = pick(CFG.COLORS)
        local alpha = pick(CFG.ALPHA)
        local speed = rng(CFG.SPEED_MIN, CFG.SPEED_MAX)

        -- Posición inicial: aleatoria dentro del panel
        local startX = rng(4, W.WW - sz - 4)
        local startY = rng(4, W.WH - sz - 4)

        -- Dirección de movimiento: ángulo completamente aleatorio
        local angle  = rng(0, math.pi * 2)
        local dx     = math.cos(angle) * speed * life
        local dy     = math.sin(angle) * speed * life

        -- Destino final (puede salirse del borde, el clip lo oculta)
        local endX = startX + dx
        local endY = startY + dy

        local p = mk("ImageLabel", {
            Size                   = UDim2.new(0, sz, 0, sz),
            Position               = UDim2.new(0, startX, 0, startY),
            BackgroundTransparency = 1,
            Image                  = CFG.IMG,
            ImageColor3            = color,
            ImageTransparency      = 1,           -- empieza invisible
            Rotation               = rng(0, 360),
            ZIndex                 = 2,
        }, StarContainer)

        -- Fade IN
        stw(p, CFG.FADE_DUR,
            { ImageTransparency = alpha },
            Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

        -- Movimiento suave durante toda la vida
        TweenService:Create(p,
            TweenInfo.new(life, Enum.EasingStyle.Linear),
            { Position = UDim2.new(0, endX, 0, endY) }):Play()

        -- Pulso de brillo suave (parpadeo lento)
        local pulseOn = true
        task.spawn(function()
            while pulseOn and p.Parent do
                local pd = rng(1.0, 2.5)
                -- se oscurece un poco
                stw(p, pd,
                    { ImageTransparency = math.min(0.92, alpha + rng(0.20, 0.45)) },
                    Enum.EasingStyle.Sine)
                task.wait(pd)
                if not p.Parent then break end
                -- vuelve al brillo base
                stw(p, pd,
                    { ImageTransparency = alpha },
                    Enum.EasingStyle.Sine)
                task.wait(pd)
            end
        end)

        -- Fade OUT antes de morir
        task.delay(life - CFG.FADE_DUR, function()
            pulseOn = false
            if not p.Parent then return end
            stw(p, CFG.FADE_DUR,
                { ImageTransparency = 1 },
                Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        end)

        -- Destruir y re-spawnear (loop infinito)
        task.delay(life + 0.05, function()
            if p.Parent then p:Destroy() end
            -- respawnea inmediatamente para mantener COUNT constante
            task.spawn(spawnParticle)
        end)
    end

    -- Spawn inicial escalonado para que no aparezcan todas juntas
    for i = 1, CFG.COUNT do
        task.delay(rng(0, 2.5), spawnParticle)
    end
end
-- ══════════════════════════════════════════════════════════════

-- ── TITLEBAR ─────────────────────────────────────────────────
local TBar = mk("Frame", {
    Size             = UDim2.new(1, 0, 0, W.TH),
    BackgroundColor3 = C.TBAR,
    BorderSizePixel  = 0, ZIndex = 6, ClipsDescendants = false, Active = true,
}, Win)
mk("UICorner", { CornerRadius = UDim.new(0, 14) }, TBar)
mk("Frame", {
    Size             = UDim2.new(1, 0, 0, 14),
    Position         = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = C.TBAR,
    BorderSizePixel  = 0, ZIndex = 5,
}, TBar)

local rdot = mk("Frame", {
    Size             = UDim2.new(0, 10, 0, 10),
    Position         = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = C.RED,
    BorderSizePixel  = 0, ZIndex = 8,
}, TBar)
rnd(5, rdot)

local function tlbl(txt, font, sz, col, x, w)
    return mk("TextLabel", {
        Text = txt, Font = font, TextSize = sz, TextColor3 = col,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, w, 0, W.TH), Position = UDim2.new(0, x, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, TBar)
end

local title1 = tlbl("dzanity.gg",  Enum.Font.GothamBold,  13, C.WHITE, 30,  80)
local title2 = tlbl("|",           Enum.Font.GothamBold,  16, C.RED,  113,  14)
local title3 = tlbl("Base Panel",  Enum.Font.Gotham,      12, C.GRAY, 129, 110)
local title4 = tlbl("|",           Enum.Font.GothamBold,  14, C.MUTED,241,  14)
local title5 = tlbl("v1.0.0",      Enum.Font.Code,        11, C.MUTED,257,  60)

local MinB = mk("TextButton", {
    Text = "─", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, W.TH), Position = UDim2.new(0, W.WW - 72, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

local ClsB = mk("TextButton", {
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 22,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, W.TH), Position = UDim2.new(0, W.WW - 36, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

ClsB.MouseEnter:Connect(function() tw(ClsB, .1, { TextColor3 = C.RED   }) end)
ClsB.MouseLeave:Connect(function() tw(ClsB, .1, { TextColor3 = C.GRAY  }) end)
MinB.MouseEnter:Connect(function() tw(MinB, .1, { TextColor3 = C.WHITE }) end)
MinB.MouseLeave:Connect(function() tw(MinB, .1, { TextColor3 = C.GRAY  }) end)

-- ── BODY CLIP ────────────────────────────────────────────────
BodyClip = mk("Frame", {
    Size             = UDim2.new(0, W.WW, 0, W.BH),
    Position         = UDim2.new(0, 0, 0, W.TH),
    BackgroundColor3 = C.WIN,
    BorderSizePixel  = 0, ZIndex = 2, ClipsDescendants = true,
}, Win)
rnd(14, BodyClip)

-- ── PÁGINA HELPER ────────────────────────────────────────────
local function makePage()
    local scr = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, W.BH), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
    }, BodyClip)
    local pg = mk("Frame", {
        Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 12),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    }, scr)
    mk("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, pg)
    return pg
end

-- ── NAVBAR ───────────────────────────────────────────────────
NavBar = mk("Frame", {
    Size     = UDim2.new(0, W.NW, 0, W.NH),
    Position = UDim2.new(0.5, -W.WW/2 + (W.WW - W.NW)/2, 0.5, -W.WH/2 + W.WH + W.NGAP),
    BackgroundColor3 = C.NAV,
    BorderSizePixel = 0, ZIndex = 8, ClipsDescendants = true,
}, SG)
rnd(14, NavBar)
local NavStroke = mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, NavBar)

-- ── TABS ─────────────────────────────────────────────────────
local TDEFS = {
    { img = "rbxassetid://125925976660286", lbl = "Combat"   },
    { img = "rbxassetid://79653542226069",  lbl = "Visuals"  },
    { img = "rbxassetid://75066739039083",  lbl = "Commands" },
    { img = "rbxassetid://105322951498375", lbl = "Settings" },
}

local NT      = 4
local GAP     = 2
local TBW     = 68
local TBW_EXP = 98
local IMGS    = 20
local navT    = {}
local tPages  = {}
local actNav  = 1

local function getActNav() return actNav end

local function updateTabPositions(activeIndex)
    local cx = 4
    for i = 1, NT do
        local t = navT[i]
        local w = (i == activeIndex) and TBW_EXP or TBW
        t.targetX = cx; t.targetW = w
        cx = cx + w + GAP
    end
end

for i = 1, NT do
    local pg = makePage()
    pg.Parent.Visible = (i == 1)
    tPages[i] = pg
end

for i, td in ipairs(TDEFS) do
    local isF = (i == 1)
    local pill = mk("Frame", {
        Size             = UDim2.new(0, isF and TBW_EXP or TBW, 0, W.NH - 8),
        Position         = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = isF and C.NAVPIL or C.NAV,
        BorderSizePixel  = 0, ZIndex = isF and 15 or 10,
    }, NavBar)
    rnd(10, pill)

    local img = mk("ImageLabel", {
        Size                   = UDim2.new(0, IMGS, 0, IMGS),
        Position               = isF
            and UDim2.new(0, 10, 0.5, -IMGS/2)
            or  UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2),
        BackgroundTransparency = 1,
        Image                  = td.img,
        ImageColor3            = isF and C.RED or C.MUTED,
        ZIndex                 = 11,
    }, pill)

    local lbl = mk("TextLabel", {
        Text = td.lbl, Font = Enum.Font.GothamSemibold, TextSize = 10,
        TextColor3 = C.WHITE, BackgroundTransparency = 1,
        Size = UDim2.new(0, 64, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = isF and 0 or 1, ZIndex = 11,
    }, pill)

    local hit = mk("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 16, AutoButtonColor = false,
    }, pill)

    navT[i] = {
        pill = pill, img = img, lbl = lbl,
        targetX = 0, targetW = isF and TBW_EXP or TBW,
    }

    hit.MouseButton1Click:Connect(function()
        if actNav == i then return end
        local pv = navT[actNav]; pv.pill.ZIndex = 10
        tw(pv.pill, .25, { BackgroundColor3 = C.NAV },  Enum.EasingStyle.Quint)
        tw(pv.img,  .25, {
            Position    = UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2),
            ImageColor3 = C.MUTED,
        }, Enum.EasingStyle.Quint)
        tw(pv.lbl, .15, { TextTransparency = 1 })
        tPages[actNav].Parent.Visible = false

        actNav = i
        tPages[i].Parent.Visible = true
        pill.ZIndex = 15
        updateTabPositions(i)

        for j = 1, NT do
            local nt = navT[j]
            tw(nt.pill, .25, {
                Size     = UDim2.new(0, nt.targetW, 0, W.NH - 8),
                Position = UDim2.new(0, nt.targetX, 0, 4),
            }, Enum.EasingStyle.Quint)
        end
        tw(pill, .25, { BackgroundColor3 = C.NAVPIL }, Enum.EasingStyle.Quint)
        tw(img,  .25, {
            Position    = UDim2.new(0, 10, 0.5, -IMGS/2),
            ImageColor3 = C.RED,
        }, Enum.EasingStyle.Quint)
        task.delay(.1, function() tw(lbl, .2, { TextTransparency = 0 }) end)
    end)

    hit.MouseEnter:Connect(function()
        if actNav ~= i then tw(img, .1, { ImageColor3 = C.GRAY  }) end
    end)
    hit.MouseLeave:Connect(function()
        if actNav ~= i then tw(img, .1, { ImageColor3 = C.MUTED }) end
    end)
end

updateTabPositions(1)
for i = 1, NT do local t = navT[i]; t.pill.Position = UDim2.new(0, t.targetX, 0, 4) end

-- ── DRAG ─────────────────────────────────────────────────────
do
    local dragging = false
    local mStart, wStart = Vector2.new(), Vector2.new()
    local DragHit = mk("TextButton", {
        Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -72, 1, 0), ZIndex = 50, AutoButtonColor = false,
    }, TBar)
    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true; mStart = mp
        wStart = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation(); local d = mp - mStart
        local tx = wStart.X + d.X; local ty = wStart.Y + d.Y
        local cx = Win.Position.X.Offset; local cy = Win.Position.Y.Offset
        local nx = cx + (tx - cx) * 0.5;  local ny = cy + (ty - cy) * 0.5
        if math.abs(nx - tx) < 0.3 then nx = tx end
        if math.abs(ny - ty) < 0.3 then ny = ty end
        applyPos(nx, ny)
    end)
end

-- ── ANIMACIONES ──────────────────────────────────────────────
local anim = Animations.init({
    C         = C,
    W         = W,
    Win       = Win,       NavBar    = NavBar,    BodyClip  = BodyClip,
    WinStroke = WinStroke, NavStroke = NavStroke,
    navT      = navT,      actNavFn  = getActNav,
    rdot      = rdot,
    title1    = title1,    title2    = title2,    title3    = title3,
    title4    = title4,    title5    = title5,
    MinB      = MinB,      ClsB      = ClsB,
    SG        = SG,
    tw        = tw,
})

MinB.MouseButton1Click:Connect(function() anim.toggleMinimize() end)
ClsB.MouseButton1Click:Connect(function() anim.doClose()        end)

-- ── KEYBINDS ─────────────────────────────────────────────────
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then anim.toggleHide() end
    if i.KeyCode == Enum.KeyCode.End        then anim.doClose()    end
end)

-- ── PÁGINAS ──────────────────────────────────────────────────
Combat.build(tPages[1],   { C = C, mk = mk, rnd = rnd, tw = tw })
Visuals.build(tPages[2],  { C = C, mk = mk, rnd = rnd, tw = tw })
Commands.build(tPages[3], { C = C, mk = mk, rnd = rnd, tw = tw })

Settings.build(tPages[4], {
    navT     = navT,
    actNavFn = getActNav,
    rdot     = rdot,
    title1   = title1, title2 = title2, title3 = title3,
    tw       = tw,
    mk       = mk,
    rnd      = rnd,
    Win      = Win,
    anim     = anim,
})

-- ── OPEN ANIMATION ───────────────────────────────────────────
anim.playOpen()

print("[PanelBase] ✨ Loaded — dzanity.gg v1.0.0")
