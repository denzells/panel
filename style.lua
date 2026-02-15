-- ============================================================
-- style.lua  –  Paleta de colores, constantes y helpers UI
-- Cargado por main.lua via loadstring / rawget del módulo
-- ============================================================

local TweenService = game:GetService("TweenService")

local Style = {}

-- ── PALETTE ──────────────────────────────────────────────────
Style.C = {
    WIN    = Color3.fromRGB(18, 18, 18),
    TBAR   = Color3.fromRGB(13, 13, 13),
    LINE   = Color3.fromRGB(42, 42, 42),
    RED    = Color3.fromRGB(205, 30, 30),
    NAV    = Color3.fromRGB(11, 11, 11),
    NAVPIL = Color3.fromRGB(28, 28, 28),
    WHITE  = Color3.fromRGB(235, 235, 235),
    GRAY   = Color3.fromRGB(110, 110, 110),
    MUTED  = Color3.fromRGB(55,  55,  55),
    PANEL  = Color3.fromRGB(14,  14,  14),
}

-- ── LAYOUT CONSTANTS ─────────────────────────────────────────
Style.WW   = 540
Style.WH   = 440
Style.TH   = 42
Style.NW   = 320
Style.NH   = 46
Style.NGAP = 14
Style.BH   = Style.WH - Style.TH

-- ── HELPERS ──────────────────────────────────────────────────
-- Crea una instancia con propiedades y la empareja a un padre
function Style.mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

-- Agrega un UICorner con radio en pixeles
function Style.rnd(radius, parent)
    Style.mk("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

-- Tween genérico
function Style.tw(obj, t, props, es, ed)
    TweenService:Create(
        obj,
        TweenInfo.new(t, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out),
        props
    ):Play()
end

return Style
