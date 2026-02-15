-- ============================================================
-- main.lua  –  Entry point de PanelBase
-- Uso:  loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/main.lua"))()
-- ============================================================

-- ── CONFIG: cambia estas URLs cuando subas a GitHub ─────────
local RAW_BASE = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/"

-- ── Loader seguro ────────────────────────────────────────────
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

-- ── Importar módulos ─────────────────────────────────────────
local Style      = loadModule("style.lua")
local Animations = loadModule("animations.lua")
local Settings   = loadModule("settings.lua")

if not Style or not Animations or not Settings then
    warn("[PanelBase] Falló la carga de uno o más módulos. Abortando.")
    return
end

-- ── Servicios ────────────────────────────────────────────────
local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui", 10)
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then
    warn("[PanelBase] No se encontró PlayerGui.")
    return
end

-- Destruir instancia previa
local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

-- ── Alias de estilo ──────────────────────────────────────────
local C   = Style.C
local mk  = Style.mk
local rnd = Style.rnd
local tw  = Style.tw
local WW  = Style.WW; local WH = Style.WH
local TH  = Style.TH; local BH = Style.BH
local NW  = Style.NW; local NH = Style.NH
local NGAP= Style.NGAP

-- Tabla de elementos que siguen el color acento
local accentTextElements = {}

-- ── SCREENGUI ────────────────────────────────────────────────
local SG = mk("ScreenGui", {
    Name              = "PanelBase",
    ResetOnSpawn      = false,
    IgnoreGuiInset    = true,
    ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

-- ── Posicionado relativo ─────────────────────────────────────
local Win, NavBar, BodyClip

local function applyPos(wx, wy)
    Win.Position    = UDim2.new(0.5, wx, 0.5, wy)
    NavBar.Position = UDim2.new(0.5, wx + (WW - NW) / 2, 0.5, wy + WH + NGAP)
end

-- ── MAIN WINDOW ──────────────────────────────────────────────
Win = mk("Frame", {
    Size             = UDim2.new(0, WW, 0, WH),
    Position         = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
    BackgroundColor3 = C.WIN,
    BorderSizePixel  = 0,
    ClipsDescendants = false,
    ZIndex           = 3,
}, SG)
rnd(14, Win)
local WinStroke = mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, Win)

-- ── TITLEBAR ─────────────────────────────────────────────────
local TBar = mk("Frame", {
    Size             = UDim2.new(1, 0, 0, TH),
    BackgroundColor3 = C.TBAR,
    BorderSizePixel  = 0, ZIndex = 6, ClipsDescendants = false, Active = true,
}, Win)
mk("UICorner", { CornerRadius = UDim.new(0, 14) }, TBar)
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = C.TBAR, BorderSizePixel = 0, ZIndex = 5, Active = false,
}, TBar)

local rdot = mk("Frame", {
    Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = C.RED, BorderSizePixel = 0, ZIndex = 8,
}, TBar)
rnd(5, rdot)

local function tlbl(txt, font, sz, col, x, w)
    return mk("TextLabel", {
        Text = txt, Font = font, TextSize = sz, TextColor3 = col,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, w, 0, TH), Position = UDim2.new(0, x, 0, 0),
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
    Size = UDim2.new(0, 36, 0, TH), Position = UDim2.new(0, WW - 72, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

local ClsB = mk("TextButton", {
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 22,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, TH), Position = UDim2.new(0, WW - 36, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

ClsB.MouseEnter:Connect(function() tw(ClsB, .1, { TextColor3 = C.RED }) end)
ClsB.MouseLeave:Connect(function() tw(ClsB, .1, { TextColor3 = C.GRAY }) end)
MinB.MouseEnter:Connect(function() tw(MinB, .1, { TextColor3 = C.WHITE }) end)
MinB.MouseLeave:Connect(function() tw(MinB, .1, { TextColor3 = C.GRAY }) end)

-- ── BODY CLIP ────────────────────────────────────────────────
BodyClip = mk("Frame", {
    Size = UDim2.new(0, WW, 0, BH), Position = UDim2.new(0, 0, 0, TH),
    BackgroundColor3 = C.WIN, BorderSizePixel = 0, ZIndex = 2, ClipsDescendants = true,
}, Win)
rnd(14, BodyClip)

-- ── Página helper ────────────────────────────────────────────
local function makePage()
    local scr = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, BH), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
    }, BodyClip)
    local pg = mk("Frame", {
        Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 12),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    }, scr)
    mk("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, pg)
    return pg
end

-- ── NAVBAR ───────────────────────────────────────────────────
NavBar = mk("Frame", {
    Size = UDim2.new(0, NW, 0, NH),
    Position = UDim2.new(0.5, -WW/2 + (WW-NW)/2, 0.5, -WH/2 + WH + NGAP),
    BackgroundColor3 = C.NAV, BorderSizePixel = 0, ZIndex = 8, ClipsDescendants = true,
}, SG)
rnd(14, NavBar)
local NavStroke = mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, NavBar)

-- ── TABS ─────────────────────────────────────────────────────
local TDEFS = {
    { img = "rbxassetid://125925976660286", lbl = "Combat" },
    { img = "rbxassetid://79653542226069",  lbl = "Visuals" },
    { img = "rbxassetid://75066739039083",  lbl = "Commands" },
    { img = "rbxassetid://105322951498375", lbl = "Settings" },
}
local NT = 4; local GAP = 2; local TBW = 68; local TBW_EXPANDED = 98
local navT   = {}
local tPages = {}
local actNav = 1

local function getActNav() return actNav end

local function updateTabPositions(activeIndex)
    local cx = 4
    for i = 1, NT do
        local t = navT[i]
        local w = (i == activeIndex) and TBW_EXPANDED or TBW
        t.targetX = cx; t.targetW = w; cx = cx + w + GAP
    end
end

for i = 1, NT do
    local page = makePage()
    page.Parent.Visible = (i == 1)
    tPages[i] = page
end

local IMGS = 20
for i, td in ipairs(TDEFS) do
    local isF = (i == 1)
    local pill = mk("Frame", {
        Size = UDim2.new(0, isF and TBW_EXPANDED or TBW, 0, NH - 8),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = isF and C.NAVPIL or C.NAV,
        BorderSizePixel = 0, ZIndex = isF and 15 or 10,
    }, NavBar)
    rnd(10, pill)

    local img = mk("ImageLabel", {
        Size = UDim2.new(0, IMGS, 0, IMGS),
        Position = isF and UDim2.new(0, 10, 0.5, -IMGS/2) or UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2),
        BackgroundTransparency = 1, Image = td.img,
        ImageColor3 = isF and C.RED or C.MUTED, ZIndex = 11,
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

    navT[i] = { pill = pill, img = img, lbl = lbl, targetX = 0, targetW = isF and TBW_EXPANDED or TBW }

    hit.MouseButton1Click:Connect(function()
        if actNav == i then return end
        local pv = navT[actNav]; pv.pill.ZIndex = 10
        tw(pv.pill, .25, { BackgroundColor3 = C.NAV }, Enum.EasingStyle.Quint)
        tw(pv.img,  .25, { Position = UDim2.new(0.5, -IMGS/2, 0.5, -IMGS/2), ImageColor3 = C.MUTED }, Enum.EasingStyle.Quint)
        tw(pv.lbl,  .15, { TextTransparency = 1 })
        tPages[actNav].Parent.Visible = false

        actNav = i
        tPages[i].Parent.Visible = true
        pill.ZIndex = 15
        updateTabPositions(i)

        for j = 1, NT do
            local nt = navT[j]
            tw(nt.pill, .25, { Size = UDim2.new(0, nt.targetW, 0, NH-8), Position = UDim2.new(0, nt.targetX, 0, 4) }, Enum.EasingStyle.Quint)
        end
        tw(pill, .25, { BackgroundColor3 = C.NAVPIL }, Enum.EasingStyle.Quint)
        tw(img,  .25, { Position = UDim2.new(0, 10, 0.5, -IMGS/2), ImageColor3 = C.RED }, Enum.EasingStyle.Quint)
        task.delay(.1, function() tw(lbl, .2, { TextTransparency = 0 }) end)
    end)

    hit.MouseEnter:Connect(function() if actNav ~= i then tw(img, .1, { ImageColor3 = C.GRAY }) end end)
    hit.MouseLeave:Connect(function() if actNav ~= i then tw(img, .1, { ImageColor3 = C.MUTED }) end end)
end

updateTabPositions(1)
for i = 1, NT do local t = navT[i]; t.pill.Position = UDim2.new(0, t.targetX, 0, 4) end

-- ── DRAG ─────────────────────────────────────────────────────
do
    local dragging = false
    local mStart   = Vector2.new()
    local wStart   = Vector2.new()
    local DragHit  = mk("TextButton", {
        Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -72, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 50, AutoButtonColor = false,
    }, TBar)
    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true; mStart = mp
        wStart   = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation(); local d = mp - mStart
        local tx = wStart.X + d.X; local ty = wStart.Y + d.Y
        local cx = Win.Position.X.Offset; local cy = Win.Position.Y.Offset
        local nx = cx + (tx - cx) * 0.5; local ny = cy + (ty - cy) * 0.5
        if math.abs(nx - tx) < 0.3 then nx = tx end
        if math.abs(ny - ty) < 0.3 then ny = ty end
        applyPos(nx, ny)
    end)
end

-- ── INICIALIZAR ANIMACIONES ──────────────────────────────────
local anim = Animations.init({
    Style     = Style,
    Win       = Win,   NavBar    = NavBar,   BodyClip  = BodyClip,
    WinStroke = WinStroke, NavStroke = NavStroke, TBar = TBar,
    navT      = navT,  actNav    = getActNav,
    rdot      = rdot,
    title1    = title1, title2 = title2, title3 = title3,
    title4    = title4, title5 = title5,
    MinB      = MinB,  ClsB   = ClsB,
    SG        = SG,
})

MinB.MouseButton1Click:Connect(function() anim.toggleMinimize() end)
ClsB.MouseButton1Click:Connect(function() anim.doClose() end)

-- ── KEYBINDS ─────────────────────────────────────────────────
local currentToggleKey = Enum.KeyCode.RightShift
local currentCloseKey  = Enum.KeyCode.End

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == currentToggleKey then anim.toggleHide() end
    if i.KeyCode == currentCloseKey  then anim.doClose()   end
end)

-- ── SETTINGS PAGE ────────────────────────────────────────────
Settings.build(tPages[4], {
    Style            = Style,
    accentTextElements = accentTextElements,
    navT             = navT,
    actNavGetter     = getActNav,
    rdot             = rdot,
    title1           = title1, title2 = title2, title3 = title3,
    title4           = title4, title5 = title5,
})

-- ── ANIMACIÓN DE APERTURA ────────────────────────────────────
anim.playOpen()

print("[PanelBase] ✨ Cargado correctamente — v1.0.0")
