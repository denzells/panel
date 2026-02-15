-- ============================================
-- PANEL.LUA - ARCHIVO PRINCIPAL
-- ============================================

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui",10)
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end
local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

-- ============================================
-- CARGAR MÓDULOS (Cambia estas URLs por las tuyas)
-- ============================================
local BASE_URL = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/"

local function loadModule(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. name .. ".lua"))()
    end)
    if success then
        print("[PanelBase] ✓ Módulo cargado:", name)
        return result
    else
        warn("[PanelBase] ✗ Error cargando", name, ":", result)
        return nil
    end
end

-- Cargar módulos
local Animations = loadModule("Animations")
local Combat     = loadModule("Combat")
local Visuals    = loadModule("Visuals")
local Commands   = loadModule("Commands")
local Settings   = loadModule("Settings")

if not Animations then error("No se pudo cargar Animations") end

-- ============================================
-- CONFIGURACIÓN GLOBAL
-- ============================================
_G.PanelConfig = {
    -- Colores (paleta)
    C = {
        WIN    = Color3.fromRGB(18, 18, 18),
        TBAR   = Color3.fromRGB(13, 13, 13),
        LINE   = Color3.fromRGB(42, 42, 42),
        RED    = Color3.fromRGB(205, 30, 30),
        NAV    = Color3.fromRGB(11, 11, 11),
        NAVPIL = Color3.fromRGB(28, 28, 28),
        WHITE  = Color3.fromRGB(235, 235, 235),
        GRAY   = Color3.fromRGB(110, 110, 110),
        MUTED  = Color3.fromRGB(55,  55,  55),
        PANEL  = Color3.fromRGB(14, 14, 14),
    },
    
    -- Dimensiones
    WW = 540, WH = 440, TH = 42,
    NW = 320, NH = 46, NGAP = 14,
    
    -- Referencias
    Services = {
        Players = Players,
        UIS = UIS,
        TweenService = TweenService,
        RunService = RunService,
    },
    
    -- Módulo de animaciones
    Animations = Animations,
    
    -- Elementos que siguen el color acento
    accentElements = {},
    
    -- Tabs
    navT = {},
    tPages = {},
    activeTab = 1,
    
    -- Keybinds
    toggleKey = Enum.KeyCode.RightShift,
    closeKey  = Enum.KeyCode.End,
}

local C = _G.PanelConfig.C
local WW, WH, TH = _G.PanelConfig.WW, _G.PanelConfig.WH, _G.PanelConfig.TH
local NW, NH, NGAP = _G.PanelConfig.NW, _G.PanelConfig.NH, _G.PanelConfig.NGAP
local BH = WH - TH

-- ============================================
-- UTILIDADES
-- ============================================
local function mk(cls, p, par)
    local o = Instance.new(cls)
    for k,v in pairs(p) do pcall(function() o[k]=v end) end
    if par then o.Parent = par end
    return o
end

local function rnd(r, p) mk("UICorner",{CornerRadius=UDim.new(0,r)},p) end

_G.PanelConfig.mk = mk
_G.PanelConfig.rnd = rnd

-- ============================================
-- SCREENGUI Y VENTANA PRINCIPAL
-- ============================================
local SG = mk("ScreenGui",{
    Name="PanelBase", ResetOnSpawn=false,
    IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Win = mk("Frame",{
    Size=UDim2.new(0,WW,0,WH),
    Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),
    BackgroundColor3=C.WIN,
    BorderSizePixel=0, ClipsDescendants=false, ZIndex=3,
}, SG)
rnd(14, Win)
local WinStroke = mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.2}, Win)

_G.PanelConfig.Win = Win
_G.PanelConfig.WinStroke = WinStroke

-- ============================================
-- TITLEBAR
-- ============================================
local TBar = mk("Frame",{
    Size=UDim2.new(1,0,0,TH),
    BackgroundColor3=C.TBAR,
    BorderSizePixel=0, ZIndex=6, ClipsDescendants=false, Active=true,
}, Win)
mk("UICorner",{CornerRadius=UDim.new(0,14)},TBar)
mk("Frame",{
    Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=C.TBAR, BorderSizePixel=0, ZIndex=5, Active=false,
},TBar)

local rdot = mk("Frame",{
    Size=UDim2.new(0,10,0,10), Position=UDim2.new(0,14,0.5,-5),
    BackgroundColor3=C.RED, BorderSizePixel=0, ZIndex=8
}, TBar)
rnd(5, rdot)

_G.PanelConfig.rdot = rdot

local function tlbl(txt, font, sz, col, x, w)
    return mk("TextLabel",{
        Text=txt, Font=font, TextSize=sz, TextColor3=col,
        BackgroundTransparency=1,
        Size=UDim2.new(0,w,0,TH), Position=UDim2.new(0,x,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8
    }, TBar)
end

local title1 = tlbl("dzanity.gg",  Enum.Font.GothamBold, 13, C.WHITE, 30,  80)
local title2 = tlbl("|",           Enum.Font.GothamBold, 16, C.RED,  113,  14)
local title3 = tlbl("Base Panel",  Enum.Font.Gotham,     12, C.GRAY, 129, 110)
local title4 = tlbl("|",           Enum.Font.GothamBold, 14, C.MUTED,241,  14)
local title5 = tlbl("v1.0.0",      Enum.Font.Code,       11, C.MUTED,257,  60)

_G.PanelConfig.titles = {title1, title2, title3, title4, title5}

local MinB = mk("TextButton",{
    Text="─", Font=Enum.Font.GothamBold, TextSize=16,
    TextColor3=C.GRAY, BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.new(0,36,0,TH), Position=UDim2.new(0,WW-72,0,0),
    ZIndex=8, AutoButtonColor=false
}, TBar)

local ClsB = mk("TextButton",{
    Text="×", Font=Enum.Font.GothamBold, TextSize=22,
    TextColor3=C.GRAY, BackgroundTransparency=1, BorderSizePixel=0,
    Size=UDim2.new(0,36,0,TH), Position=UDim2.new(0,WW-36,0,0),
    ZIndex=8, AutoButtonColor=false
}, TBar)

_G.PanelConfig.MinB = MinB
_G.PanelConfig.ClsB = ClsB

-- Hover effects con módulo de animaciones
Animations.setupButtonHover(ClsB, C.GRAY, C.RED)
Animations.setupButtonHover(MinB, C.GRAY, C.WHITE)

-- ============================================
-- BODY CLIP (contenedor de páginas)
-- ============================================
local BodyClip = mk("Frame",{
    Size=UDim2.new(0,WW,0,BH), Position=UDim2.new(0,0,0,TH),
    BackgroundColor3=C.WIN, BorderSizePixel=0, ZIndex=2, ClipsDescendants=true,
}, Win)
rnd(14, BodyClip)

_G.PanelConfig.BodyClip = BodyClip

-- ============================================
-- NAVBAR
-- ============================================
local NavBar = mk("Frame",{
    Size=UDim2.new(0,NW,0,NH),
    Position=UDim2.new(0.5,-WW/2+(WW-NW)/2,0.5,-WH/2+WH+NGAP),
    BackgroundColor3=C.NAV, BorderSizePixel=0, ZIndex=8, ClipsDescendants=true,
}, SG)
rnd(14, NavBar)
local NavStroke = mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.2}, NavBar)

_G.PanelConfig.NavBar = NavBar
_G.PanelConfig.NavStroke = NavStroke

-- ============================================
-- FUNCIÓN PARA CREAR PÁGINAS
-- ============================================
local function makePage()
    local scr = mk("ScrollingFrame",{
        Size=UDim2.new(1,0,0,BH), Position=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ZIndex=3
    }, BodyClip)
    local pg = mk("Frame",{
        Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,12),
        AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1
    }, scr)
    mk("UIListLayout",{Padding=UDim.new(0,12), SortOrder=Enum.SortOrder.LayoutOrder}, pg)
    return pg
end

_G.PanelConfig.makePage = makePage

-- ============================================
-- CREAR TABS Y PÁGINAS
-- ============================================
local TDEFS = {
    {img="rbxassetid://125925976660286", lbl="Combat"},
    {img="rbxassetid://79653542226069",  lbl="Visuals"},
    {img="rbxassetid://75066739039083",  lbl="Commands"},
    {img="rbxassetid://105322951498375", lbl="Settings"},
}

local NT = 4
local GAP = 2
local TBW = 68
local TBW_EXPANDED = 98

-- Crear páginas
for i=1,NT do
    local page = makePage()
    page.Parent.Visible = (i==1)
    _G.PanelConfig.tPages[i] = page
end

-- Inicializar tabs con el módulo de Animations
Animations.setupTabs(NavBar, TDEFS, TBW, TBW_EXPANDED, GAP, NT)

-- ============================================
-- DRAG (con módulo de animaciones)
-- ============================================
Animations.setupDrag(TBar, Win, NavBar, WW, WH, NGAP)

-- ============================================
-- MINIMIZE / CLOSE (con módulo de animaciones)
-- ============================================
Animations.setupMinimize()
Animations.setupClose(SG)
Animations.setupKeybinds()

-- ============================================
-- ANIMACIÓN DE APERTURA
-- ============================================
Animations.playOpenAnimation()

-- ============================================
-- CARGAR CONTENIDO DE LAS PÁGINAS
-- ============================================
task.delay(1, function()
    if Combat then Combat.init(_G.PanelConfig.tPages[1]) end
    if Visuals then Visuals.init(_G.PanelConfig.tPages[2]) end
    if Commands then Commands.init(_G.PanelConfig.tPages[3]) end
    if Settings then Settings.init(_G.PanelConfig.tPages[4]) end
    
    print("[PanelBase] ✨ Panel cargado completamente")
end)