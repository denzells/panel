-- ============================================================
-- animations.lua  –  Animaciones del panel
-- Requiere: Style, referencias a Win / NavBar / BodyClip / etc.
-- ============================================================

local Animations = {}

-- Se llama desde main.lua una vez construida la UI.
-- `refs` es una tabla con todos los handles necesarios.
function Animations.init(refs)
    local Style    = refs.Style
    local C        = Style.C
    local tw       = Style.tw

    local Win      = refs.Win
    local NavBar   = refs.NavBar
    local BodyClip = refs.BodyClip
    local WinStroke= refs.WinStroke
    local NavStroke= refs.NavStroke
    local TBar     = refs.TBar
    local navT     = refs.navT
    local actNav   = refs.actNav   -- función getter: actNav()
    local rdot     = refs.rdot
    local title1   = refs.title1
    local title2   = refs.title2
    local title3   = refs.title3
    local title4   = refs.title4
    local title5   = refs.title5
    local MinB     = refs.MinB
    local ClsB     = refs.ClsB
    local SG       = refs.SG

    local WW = Style.WW
    local WH = Style.WH
    local TH = Style.TH
    local NW = Style.NW
    local NH = Style.NH
    local BH = Style.BH

    local minimized = false
    local animating = false
    local hidden    = false

    -- ── Helpers internos ─────────────────────────────────────
    local function hideNavTabs(fast)
        local t = fast and 0.12 or 0.15
        for _, tab in ipairs(navT) do
            tw(tab.pill, t, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
            tw(tab.img,  t, { ImageTransparency     = 1 }, Enum.EasingStyle.Sine)
            tw(tab.lbl,  t, { TextTransparency      = 1 }, Enum.EasingStyle.Sine)
        end
    end

    local function showNavTabs(delay0)
        task.delay(delay0 or 0, function()
            for i, tab in ipairs(navT) do
                local isActive = (i == actNav())
                task.delay(i * 0.025, function()
                    tw(tab.pill, 0.2, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
                    tw(tab.img,  0.2, { ImageTransparency     = 0 }, Enum.EasingStyle.Sine)
                    if isActive then
                        tw(tab.lbl, 0.2, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                    end
                end)
            end
        end)
    end

    -- ── OPEN (llamado al inicio) ─────────────────────────────
    function Animations.playOpen()
        Win.Size                   = UDim2.new(0, WW / 3, 0, TH)
        Win.BackgroundTransparency = 1
        WinStroke.Transparency     = 1
        NavBar.Size                = UDim2.new(0, 0, 0, 0)
        NavBar.BackgroundTransparency = 1
        NavStroke.Transparency     = 1
        BodyClip.Size              = UDim2.new(0, WW, 0, 0)
        BodyClip.Position          = UDim2.new(0, 0, 0, TH)
        rdot.BackgroundTransparency = 1

        for _, lbl in ipairs({ title1, title2, title3, title4, title5, MinB, ClsB }) do
            lbl.TextTransparency = 1
        end
        for _, tab in ipairs(navT) do
            tab.pill.BackgroundTransparency = 1
            tab.img.ImageTransparency       = 1
            tab.lbl.TextTransparency        = 1
        end

        tw(Win, 0.4, { Size = UDim2.new(0, WW, 0, TH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
        tw(WinStroke, 0.35, { Transparency = 0.2 })

        task.delay(0.1, function()
            tw(rdot, 0.3, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
            local lbls = { title1, title2, title3, title4, title5 }
            for idx, lbl in ipairs(lbls) do
                task.delay(0.05 + (idx - 1) * 0.03, function()
                    tw(lbl, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                end)
            end
            task.delay(0.2, function()
                tw(MinB, 0.25, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                tw(ClsB, 0.25, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
            end)
        end)

        task.delay(0.25, function()
            tw(Win,      0.45, { Size = UDim2.new(0, WW, 0, WH) }, Enum.EasingStyle.Quint)
            tw(BodyClip, 0.45, { Size = UDim2.new(0, WW, 0, BH) }, Enum.EasingStyle.Quint)
        end)

        task.delay(0.5, function()
            tw(NavBar,   0.4, { Size = UDim2.new(0, NW, 0, NH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
            tw(NavStroke,0.35, { Transparency = 0.2 })
            showNavTabs(0.25)
        end)
    end

    -- ── MINIMIZE / RESTORE ───────────────────────────────────
    function Animations.toggleMinimize()
        if animating then return end
        animating  = true
        minimized  = not minimized

        if minimized then
            hideNavTabs(true)
            tw(BodyClip, 0.3, { Size = UDim2.new(0, WW, 0, 0) },   Enum.EasingStyle.Quint)
            tw(Win,      0.3, { Size = UDim2.new(0, WW, 0, TH) },  Enum.EasingStyle.Quint)
            tw(WinStroke, 0.25, { Transparency = 0.5 })
            tw(title1, 0.2, { TextTransparency = 0.5 })
            tw(title3, 0.2, { TextTransparency = 0.7 })
            tw(title5, 0.2, { TextTransparency = 0.8 })
            task.delay(0.1, function()
                tw(NavBar,    0.25, { Size = UDim2.new(0, NW, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint)
                tw(NavStroke, 0.2,  { Transparency = 1 })
            end)
            task.delay(0.35, function() NavBar.Visible = false; animating = false end)
        else
            NavBar.Visible                = true
            NavBar.Size                   = UDim2.new(0, NW, 0, 0)
            NavBar.BackgroundTransparency = 1
            NavStroke.Transparency        = 1
            for _, tab in ipairs(navT) do
                tab.pill.BackgroundTransparency = 1
                tab.img.ImageTransparency       = 1
                tab.lbl.TextTransparency        = 1
            end
            tw(Win,      0.35, { Size = UDim2.new(0, WW, 0, WH) }, Enum.EasingStyle.Quint)
            tw(BodyClip, 0.35, { Size = UDim2.new(0, WW, 0, BH) }, Enum.EasingStyle.Quint)
            tw(WinStroke, 0.3, { Transparency = 0.2 })
            task.delay(0.05, function()
                tw(NavBar,    0.35, { Size = UDim2.new(0, NW, 0, NH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
                tw(NavStroke, 0.3,  { Transparency = 0.2 })
                tw(title1, 0.25, { TextTransparency = 0 })
                tw(title3, 0.25, { TextTransparency = 0 })
                tw(title5, 0.25, { TextTransparency = 0 })
            end)
            showNavTabs(0.3)
            task.delay(0.5, function() animating = false end)
        end

        MinB.Text = minimized and "□" or "─"
    end

    -- ── CLOSE ────────────────────────────────────────────────
    function Animations.doClose()
        if animating then return end
        animating           = true
        Win.Active          = false
        NavBar.Active       = false

        hideNavTabs(true)

        task.delay(0.08, function()
            tw(NavBar,    0.25, { Size = UDim2.new(0, NW, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tw(NavStroke, 0.2,  { Transparency = 1 })
        end)
        task.delay(0.2, function()
            tw(BodyClip, 0.3, {
                Size     = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0, WW / 2, 0, TH)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            for _, el in ipairs({ rdot, title1, title2, title3, title4, title5, MinB, ClsB }) do
                pcall(function()
                    if el:IsA("Frame") then
                        tw(el, 0.2, { BackgroundTransparency = 1 })
                    else
                        tw(el, 0.2, { TextTransparency = 1 })
                    end
                end)
            end
        end)
        task.delay(0.4, function()
            tw(Win,       0.35, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tw(WinStroke, 0.3,  { Transparency = 1 })
        end)
        task.delay(0.8, function() SG:Destroy() end)
    end

    -- ── HIDE / SHOW (keybind toggle) ─────────────────────────
    function Animations.toggleHide()
        if animating then return end
        hidden = not hidden
        if hidden then
            tw(Win,       0.2, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
            tw(WinStroke, 0.2, { Transparency = 1 })
            tw(NavBar,    0.2, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
            tw(NavStroke, 0.2, { Transparency = 1 })
            task.delay(0.2, function() Win.Visible = false; NavBar.Visible = false end)
        else
            Win.Visible                   = true
            NavBar.Visible                = not minimized
            Win.BackgroundTransparency    = 1
            WinStroke.Transparency        = 1
            NavBar.BackgroundTransparency = 1
            NavStroke.Transparency        = 1
            tw(Win,       0.25, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
            tw(WinStroke, 0.25, { Transparency = 0.2 })
            if not minimized then
                tw(NavBar,    0.25, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
                tw(NavStroke, 0.25, { Transparency = 0.2 })
            end
        end
    end

    -- Expone el estado de minimizado para que NavBar.Visible sea correcto
    function Animations.isMinimized() return minimized end

    return Animations
end

return Animations
