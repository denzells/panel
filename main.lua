-- main.lua – PanelBase | checktheprint (Restyled)
-- ══════════════════════════════════════════════════════════════
--  CONFIGURACIÓN CENTRAL — edita sólo aquí
-- ══════════════════════════════════════════════════════════════
local CONFIG = {
    -- Nombres de los tabs (en orden: 1=Combat, 2=Visuals, 3=Settings)
    TAB_NAMES = { "Combat", "General", "Settings" },

    -- Archivos de cada módulo (relativos a RAW_BASE)
    TAB_FILES = { "combat.lua", "general.lua", "settings.lua" },

    -- Íconos de cada tab
    TAB_ICONS = {
        "rbxassetid://125925976660286",
        "rbxassetid://104472360810017",
        "rbxassetid://105322951498375",
    },

    -- Versión del panel
    VERSION = "v1.0.0",

    -- Título en la barra superior
    TITLE = "checktheprint",
}
-- ══════════════════════════════════════════════════════════════

local _loadstring = loadstring
    or (syn and syn.loadstring)
    or (fluxus and fluxus.loadstring)
    or (getfenv and getfenv(0).loadstring)

local RAW_BASE = "https://raw.githubusercontent.com/denzells/panel/main/"

local function fetchContent(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and res and res ~= "" and res:sub(1,1) ~= "<" then return res end
    ok, res = pcall(function()
        local r = request({ Url = url, Method = "GET" })
        return r and r.Body
    end)
    if ok and res and res ~= "" and res:sub(1,1) ~= "<" then return res end
    return nil
end

local function loadModule(path)
    print("[BrutalityPanel] Cargando: " .. path)
    local content
    for attempt = 1, 3 do
        content = fetchContent(RAW_BASE .. path)
        if content then break end
        if attempt < 3 then task.wait(0.5) end
    end
    if not content then
        warn("[BrutalityPanel] ✗ No se pudo descargar '" .. path .. "'")
        return nil
    end
    if not _loadstring then
        warn("[BrutalityPanel] ✗ loadstring no disponible")
        return nil
    end
    local fn, compErr = _loadstring(content, "@" .. path)
    if not fn then
        warn("[BrutalityPanel] ✗ Error compilando '" .. path .. "': " .. tostring(compErr))
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("[BrutalityPanel] ✗ Error ejecutando '" .. path .. "': " .. tostring(result))
        return nil
    end
    print("[BrutalityPanel] ✓ " .. path)
    return result
end

-- Cargar módulos usando los nombres de archivo de CONFIG
local Animations = loadModule("animations.lua")
local Settings   = loadModule(CONFIG.TAB_FILES[3])
local Combat     = loadModule(CONFIG.TAB_FILES[1])
local Visuals    = loadModule(CONFIG.TAB_FILES[2])

if not Animations or not Settings then
    warn("[BrutalityPanel] Falló la carga de módulos. Abortando.")
    return
end

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("BrutalityPanel")
if old then old:Destroy() end

local C = Settings.C
local W = Settings.Layout

-- ── Paleta ────────────────────────────────────────────────────────────────
C.WIN    = Color3.fromRGB(6,  6,  6)
C.TBAR   = Color3.fromRGB(18, 18, 18)
C.NAV    = Color3.fromRGB(12, 12, 12)
C.NAVPIL = Color3.fromRGB(32, 32, 32)
C.LINE   = Color3.fromRGB(60, 60, 60)
C.MUTED  = Color3.fromRGB(90, 90, 90)
C.GRAY   = Color3.fromRGB(130,130,130)
C.WHITE  = Color3.fromRGB(230,230,230)
C.RED    = Color3.fromRGB(255,255,255)

W.NW = 3 * 68 + (98 - 68) + 2 * 2 + 8

-- ── Helpers ───────────────────────────────────────────────────────────────
local function mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    if parent then obj.Parent = parent end
    return obj
end

local CORNER = { WIN=8, TBAR=8, NAV=8, PILL=6, BADGE=4, DOT=5 }

local function rnd(r, p)
    mk("UICorner", { CornerRadius = UDim.new(0, r) }, p)
end

local function tw(obj, t, props, es, ed, cb)
    local ti = TweenInfo.new(t, es or Enum.EasingStyle.Quint, ed or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, ti, props)
    if cb then tween.Completed:Once(cb) end
    tween:Play()
    return tween
end

-- ── Expiry ────────────────────────────────────────────────────────────────
local function readSavedExpiry()
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return nil end
    local ok, result = pcall(function()
        if not isfile("serios_saved.json") then return nil end
        return HttpService:JSONDecode(readfile("serios_saved.json"))
    end)
    if ok and result then return result.expiry end
    return nil
end

local savedExpiry = readSavedExpiry()
local isAdmin     = savedExpiry == "lifetime"

local BADGE = isAdmin and {
    bg=Color3.fromRGB(22,22,22), stroke=Color3.fromRGB(160,160,160),
    stAlpha=0.35, text="⭐ Admin", col=Color3.fromRGB(220,220,220),
} or {
    bg=Color3.fromRGB(12,36,14), stroke=Color3.fromRGB(40,170,65),
    stAlpha=0.3, text="✓ Verified", col=Color3.fromRGB(55,200,80),
}

-- ── ScreenGui ─────────────────────────────────────────────────────────────
local SG = mk("ScreenGui", {
    Name="BrutalityPanel", ResetOnSpawn=false,
    IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local Win, NavBar, BodyClip

local function applyPos(wx, wy)
    Win.Position    = UDim2.new(0.5, wx, 0.5, wy)
    NavBar.Position = UDim2.new(0.5, wx+(W.WW-W.NW)/2, 0.5, wy+W.WH+W.NGAP)
end

-- ── Ventana ───────────────────────────────────────────────────────────────
Win = mk("Frame", {
    Size=UDim2.new(0,W.WW,0,W.WH), Position=UDim2.new(0.5,-W.WW/2,0.5,-W.WH/2),
    BackgroundColor3=C.WIN, BorderSizePixel=0, ClipsDescendants=false, ZIndex=3,
}, SG)
rnd(CORNER.WIN, Win)

local WinStroke = mk("UIStroke", { Color=C.LINE, Thickness=1, Transparency=1 }, Win)

-- ── TitleBar ──────────────────────────────────────────────────────────────
local TBar = mk("Frame", {
    Size=UDim2.new(1,0,0,W.TH), BackgroundColor3=C.TBAR,
    BorderSizePixel=0, ZIndex=6, ClipsDescendants=false, Active=true,
}, Win)
mk("UICorner", { CornerRadius=UDim.new(0,CORNER.TBAR) }, TBar)
mk("Frame", {
    Size=UDim2.new(1,0,0,CORNER.TBAR), Position=UDim2.new(0,0,1,-CORNER.TBAR),
    BackgroundColor3=C.TBAR, BorderSizePixel=0, ZIndex=5,
}, TBar)
mk("Frame", {
    Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,0),
    BackgroundColor3=C.LINE, BorderSizePixel=0, ZIndex=7, BackgroundTransparency=0.6,
}, TBar)

local rdot = mk("Frame", {
    Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,14,0.5,-4),
    BackgroundColor3=C.RED, BorderSizePixel=0, ZIndex=8,
}, TBar)
rnd(CORNER.DOT, rdot)

local function tlbl(txt, font, sz, col, x, w)
    return mk("TextLabel", {
        Text=txt, Font=font, TextSize=sz, TextColor3=col,
        BackgroundTransparency=1, Size=UDim2.new(0,w,0,W.TH),
        Position=UDim2.new(0,x,0,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
    }, TBar)
end

local title1 = tlbl(CONFIG.TITLE,   Enum.Font.GothamBold, 13, C.WHITE, 30, 92)
local title2 = tlbl("|",            Enum.Font.GothamBold, 16, C.RED,  125, 14)

local verifiedBadge = mk("Frame", {
    Size=UDim2.new(0,84,0,20), Position=UDim2.new(0,141,0.5,-10),
    BackgroundColor3=BADGE.bg, BorderSizePixel=0, ZIndex=8,
}, TBar)
rnd(CORNER.BADGE, verifiedBadge)
mk("UIStroke", { Color=BADGE.stroke, Thickness=1, Transparency=BADGE.stAlpha }, verifiedBadge)
mk("TextLabel", {
    Text=BADGE.text, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=BADGE.col,
    BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=9,
    TextXAlignment=Enum.TextXAlignment.Center,
}, verifiedBadge)

local title4 = tlbl("|",            Enum.Font.GothamBold, 14, C.MUTED, 237, 14)
local title5 = tlbl(CONFIG.VERSION, Enum.Font.Code,       11, C.MUTED, 253, 60)

-- ── Botón minimizar ───────────────────────────────────────────────────────
local MinB = mk("TextButton", {
    Text="─", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=C.GRAY,
    BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.new(0,36,0,W.TH), Position=UDim2.new(0,W.WW-72,0,0),
    ZIndex=8, AutoButtonColor=false, Visible=true,
}, TBar)

-- ── Botón maximizar ───────────────────────────────────────────────────────
local MaxB = mk("TextButton", {
    Text="", BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.new(0,36,0,W.TH), Position=UDim2.new(0,W.WW-72,0,0),
    ZIndex=8, AutoButtonColor=false, Visible=false,
}, TBar)
local MaxIcon = mk("ImageLabel", {
    Image="rbxassetid://94257904931438",
    Size=UDim2.new(0,10,0,10), Position=UDim2.new(0.5,-5,0.5,-5),
    BackgroundTransparency=1, ImageColor3=C.GRAY, ZIndex=9,
}, MaxB)

-- ── Botón cerrar ──────────────────────────────────────────────────────────
local ClsB = mk("TextButton", {
    Text="×", Font=Enum.Font.GothamBold, TextSize=20, TextColor3=C.GRAY,
    BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.new(0,36,0,W.TH), Position=UDim2.new(0,W.WW-36,0,0),
    ZIndex=8, AutoButtonColor=false,
}, TBar)

-- Hovers
ClsB.MouseEnter:Connect(function() tw(ClsB,    .12, { TextColor3  = Color3.fromRGB(220,60,60) }) end)
ClsB.MouseLeave:Connect(function() tw(ClsB,    .18, { TextColor3  = C.GRAY  }) end)
MinB.MouseEnter:Connect(function() tw(MinB,    .12, { TextColor3  = C.WHITE }) end)
MinB.MouseLeave:Connect(function() tw(MinB,    .18, { TextColor3  = C.GRAY  }) end)
MaxB.MouseEnter:Connect(function() tw(MaxIcon, .12, { ImageColor3 = C.WHITE }) end)
MaxB.MouseLeave:Connect(function() tw(MaxIcon, .18, { ImageColor3 = C.GRAY  }) end)

-- ── Body ──────────────────────────────────────────────────────────────────
BodyClip = mk("Frame", {
    Size=UDim2.new(0,W.WW,0,W.BH), Position=UDim2.new(0,0,0,W.TH),
    BackgroundColor3=C.WIN, BorderSizePixel=0, ZIndex=2, ClipsDescendants=true,
}, Win)
rnd(CORNER.WIN, BodyClip)

local function makePage()
    local scr = mk("ScrollingFrame", {
        Size=UDim2.new(1,0,0,W.BH), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=3,
    }, BodyClip)
    local pg = mk("Frame", {
        Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,12),
        AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1,
    }, scr)
    mk("UIListLayout", { Padding=UDim.new(0,12), SortOrder=Enum.SortOrder.LayoutOrder }, pg)
    return pg
end

-- ── NavBar ────────────────────────────────────────────────────────────────
NavBar = mk("Frame", {
    Size=UDim2.new(0,W.NW,0,W.NH),
    Position=UDim2.new(0.5,-W.WW/2+(W.WW-W.NW)/2, 0.5,-W.WH/2+W.WH+W.NGAP),
    BackgroundColor3=C.NAV, BorderSizePixel=0, ZIndex=8, ClipsDescendants=true,
}, SG)
rnd(CORNER.NAV, NavBar)

local NavStroke = mk("UIStroke", { Color=C.LINE, Thickness=1, Transparency=1 }, NavBar)

-- ── Tabs ──────────────────────────────────────────────────────────────────
-- Los nombres y archivos se toman de CONFIG.TAB_NAMES y CONFIG.TAB_ICONS
local TDEFS = {}
for i = 1, #CONFIG.TAB_NAMES do
    TDEFS[i] = { img = CONFIG.TAB_ICONS[i], lbl = CONFIG.TAB_NAMES[i] }
end

local NT, GAP, TBW, TBW_EXP, IMGS = #TDEFS, 2, 68, 98, 18
local navT, tPages, actNav = {}, {}, 1

local function getActNav() return actNav end

local function updateTabPositions(idx)
    local cx = 4
    for i = 1, NT do
        local t = navT[i]
        local w = (i == idx) and TBW_EXP or TBW
        t.targetX = cx; t.targetW = w; cx = cx + w + GAP
    end
end

for i = 1, NT do
    local pg = makePage()
    pg.Parent.Visible = (i == 1)
    tPages[i] = pg
end

local function slidePageIn(pg)
    local scr = pg.Parent
    scr.Position = UDim2.new(0, 18, 0, 0)
    tw(scr, .28, { Position=UDim2.new(0,0,0,0) }, Enum.EasingStyle.Quint)
end

for i, td in ipairs(TDEFS) do
    local isF = (i == 1)
    local pill = mk("Frame", {
        Size=UDim2.new(0, isF and TBW_EXP or TBW, 0, W.NH-8),
        Position=UDim2.new(0,0,0,4),
        BackgroundColor3=isF and C.NAVPIL or C.NAV,
        BorderSizePixel=0, ZIndex=isF and 15 or 10,
    }, NavBar)
    rnd(CORNER.PILL, pill)

    local pillStroke = mk("UIStroke", { Color=C.LINE, Thickness=1, Transparency=1 }, pill)

    local img = mk("ImageLabel", {
        Size=UDim2.new(0,IMGS,0,IMGS),
        Position=isF and UDim2.new(0,11,0.5,-IMGS/2) or UDim2.new(0.5,-IMGS/2,0.5,-IMGS/2),
        BackgroundTransparency=1, Image=td.img,
        ImageColor3=isF and C.WHITE or C.MUTED, ZIndex=11,
    }, pill)

    local lbl = mk("TextLabel", {
        Text=td.lbl, Font=Enum.Font.GothamSemibold, TextSize=10, TextColor3=C.WHITE,
        BackgroundTransparency=1, Size=UDim2.new(0,62,1,0), Position=UDim2.new(0,36,0,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTransparency=isF and 0 or 1, ZIndex=11,
    }, pill)

    local hit = mk("TextButton", {
        Text="", BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0), ZIndex=16, AutoButtonColor=false,
    }, pill)

    navT[i] = { pill=pill, pillStroke=pillStroke, img=img, lbl=lbl,
        targetX=0, targetW=isF and TBW_EXP or TBW,
        -- Guardamos el nombre original para que nadie lo pise
        name = CONFIG.TAB_NAMES[i],
    }

    hit.MouseButton1Click:Connect(function()
        if actNav == i then return end
        local pv = navT[actNav]
        pv.pill.ZIndex = 10
        tw(pv.pill, .3, { BackgroundColor3=C.NAV }, Enum.EasingStyle.Quint)
        tw(pv.img,  .3, { Position=UDim2.new(0.5,-IMGS/2,0.5,-IMGS/2), ImageColor3=C.MUTED }, Enum.EasingStyle.Quint)
        tw(pv.lbl,  .15, { TextTransparency=1 })
        tPages[actNav].Parent.Visible = false
        actNav = i
        tPages[i].Parent.Visible = true
        slidePageIn(tPages[i])
        pill.ZIndex = 15
        updateTabPositions(i)
        for j = 1, NT do
            local nt = navT[j]
            tw(nt.pill, .3, {
                Size=UDim2.new(0,nt.targetW,0,W.NH-8),
                Position=UDim2.new(0,nt.targetX,0,4),
            }, Enum.EasingStyle.Quint)
        end
        tw(pill, .3, { BackgroundColor3=C.NAVPIL }, Enum.EasingStyle.Quint)
        tw(img,  .3, { Position=UDim2.new(0,11,0.5,-IMGS/2), ImageColor3=C.WHITE }, Enum.EasingStyle.Quint)
        task.delay(.12, function() tw(lbl, .22, { TextTransparency=0 }) end)
    end)

    hit.MouseEnter:Connect(function()
        if actNav ~= i then
            tw(img,  .12, { ImageColor3=C.GRAY })
            tw(pill, .12, { BackgroundColor3=Color3.fromRGB(20,20,20) })
        end
    end)
    hit.MouseLeave:Connect(function()
        if actNav ~= i then
            tw(img,  .18, { ImageColor3=C.MUTED })
            tw(pill, .18, { BackgroundColor3=C.NAV })
        end
    end)
end

updateTabPositions(1)
for i = 1, NT do
    navT[i].pill.Position = UDim2.new(0, navT[i].targetX, 0, 4)
end

-- ── Drag ──────────────────────────────────────────────────────────────────
do
    local dragging, mStart, wStart = false, Vector2.new(), Vector2.new()
    local DragHit = mk("TextButton", {
        Text="", BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,-72,1,0), ZIndex=50, AutoButtonColor=false,
    }, TBar)

    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true
        mStart   = mp
        wStart   = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local d  = UIS:GetMouseLocation() - mStart
        local tx, ty = wStart.X+d.X, wStart.Y+d.Y
        local cx, cy = Win.Position.X.Offset, Win.Position.Y.Offset
        local nx = cx+(tx-cx)*0.4
        local ny = cy+(ty-cy)*0.4
        if math.abs(nx-tx)<0.5 then nx=tx end
        if math.abs(ny-ty)<0.5 then ny=ty end
        applyPos(nx, ny)
    end)
end

-- ── Animations ────────────────────────────────────────────────────────────
local anim = Animations.init({
    C=C, W=W, Win=Win, NavBar=NavBar, BodyClip=BodyClip,
    WinStroke=WinStroke, NavStroke=NavStroke, navT=navT,
    actNavFn=getActNav, rdot=rdot,
    title1=title1, title2=title2, title3=nil, title4=title4, title5=title5,
    MinB=MinB, ClsB=ClsB, SG=SG, tw=tw,
})

-- ── Minimize / Maximize state ─────────────────────────────────────────────
local isMinimized = false

local function syncMinMaxButtons()
    MinB.Visible = not isMinimized
    MaxB.Visible = isMinimized
end

syncMinMaxButtons()

MinB.MouseButton1Click:Connect(function()
    isMinimized = true
    syncMinMaxButtons()
    anim.toggleMinimize()
end)

MaxB.MouseButton1Click:Connect(function()
    isMinimized = false
    syncMinMaxButtons()
    anim.toggleMinimize()
end)

ClsB.MouseButton1Click:Connect(function()
    anim.doClose()
end)

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        isMinimized = not isMinimized
        syncMinMaxButtons()
        anim.toggleHide()
    end
    if inp.KeyCode == Enum.KeyCode.End then anim.doClose() end
end)

-- ── Build pages ───────────────────────────────────────────────────────────
Combat.build(tPages[1],  { C=C, mk=mk, rnd=rnd, tw=tw })
Visuals.build(tPages[2], { C=C, mk=mk, rnd=rnd, tw=tw })
Settings.build(tPages[3], {
    navT=navT, actNavFn=getActNav, rdot=rdot,
    title1=title1, title2=title2, title3=nil,
    tw=tw, mk=mk, rnd=rnd, Win=Win, NavBar=NavBar,
    anim=anim, isAdmin=isAdmin, savedExpiry=savedExpiry,
})

-- ══════════════════════════════════════════════════════════════
--  IMPORTANTE: Re-aplicar nombres desde CONFIG después de que
--  todos los módulos hayan terminado de buildear.
--  Esto evita que cualquier módulo externo pise los textos.
-- ══════════════════════════════════════════════════════════════
local function enforceTabNames()
    for i, t in ipairs(navT) do
        t.lbl.Text = CONFIG.TAB_NAMES[i]
    end
end

-- Aplicar ahora y también tras el delay de settings.lua (1 segundo)
enforceTabNames()
task.delay(1.1, enforceTabNames)   -- corre justo después del task.delay(1) de settings.lua
task.delay(2.0, enforceTabNames)   -- seguro extra

anim.playOpen()
print("[BrutalityPanel] ✨ Loaded — " .. CONFIG.TITLE .. " " .. CONFIG.VERSION)
