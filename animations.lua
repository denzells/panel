-- ============================================================
-- animations.lua  –  Animaciones de PanelBase
-- ============================================================

local Animations = {}

function Animations.init(r)
    local C    = r.C
    local W    = r.W
    local tw   = r.tw

    local Win      = r.Win
    local NavBar   = r.NavBar
    local BodyClip = r.BodyClip
    local WinStroke= r.WinStroke
    local NavStroke= r.NavStroke
    local navT     = r.navT
    local actNavFn = r.actNavFn
    local rdot     = r.rdot
    local title1   = r.title1
    local title2   = r.title2
    local title3   = r.title3  -- puede ser nil
    local title4   = r.title4
    local title5   = r.title5
    local MinB     = r.MinB
    local ClsB     = r.ClsB
    local SG       = r.SG

    local minimized = false
    local animating = false
    local hidden    = false

    -- ── Helpers internos ─────────────────────────────────────
    local function hideAllTabs(fast)
        local t = fast and 0.12 or 0.15
        for _, tab in ipairs(navT) do
            tw(tab.pill, t, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
            tw(tab.img,  t, { ImageTransparency      = 1 }, Enum.EasingStyle.Sine)
            tw(tab.lbl,  t, { TextTransparency       = 1 }, Enum.EasingStyle.Sine)
        end
    end

    local function showAllTabs(delay0)
        task.delay(delay0 or 0, function()
            for i, tab in ipairs(navT) do
                local isActive = (i == actNavFn())
                task.delay(i * 0.025, function()
                    tw(tab.pill, 0.2, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
                    tw(tab.img,  0.2, { ImageTransparency      = 0 }, Enum.EasingStyle.Sine)
                    if isActive then
                        tw(tab.lbl, 0.2, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                    end
                end)
            end
        end)
    end

    -- ── OPEN ─────────────────────────────────────────────────
    function Animations.playOpen()
        Win.Size                      = UDim2.new(0, W.WW/3, 0, W.TH)
        Win.BackgroundTransparency    = 1
        WinStroke.Transparency        = 1
        NavBar.Size                   = UDim2.new(0, 0, 0, 0)
        NavBar.BackgroundTransparency = 1
        NavStroke.Transparency        = 1
        BodyClip.Size                 = UDim2.new(0, W.WW, 0, 0)
        BodyClip.Position             = UDim2.new(0, 0, 0, W.TH)
        rdot.BackgroundTransparency   = 1

        -- Ocultar títulos (title3 puede ser nil)
        for _, el in ipairs({ title1, title2, title4, title5, MinB, ClsB }) do
            el.TextTransparency = 1
        end
        if title3 then title3.TextTransparency = 1 end

        for _, tab in ipairs(navT) do
            tab.pill.BackgroundTransparency = 1
            tab.img.ImageTransparency       = 1
            tab.lbl.TextTransparency        = 1
        end

        tw(Win, 0.4, { Size = UDim2.new(0, W.WW, 0, W.TH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
        tw(WinStroke, 0.35, { Transparency = 0.2 })

        task.delay(0.1, function()
            tw(rdot, 0.3, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
            local lbls = { title1, title2, title4, title5 }
            for idx, el in ipairs(lbls) do
                task.delay(0.05 + (idx - 1) * 0.03, function()
                    tw(el, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                end)
            end
            if title3 then
                task.delay(0.11, function()
                    tw(title3, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                end)
            end
            task.delay(0.2, function()
                tw(MinB, 0.25, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
                tw(ClsB, 0.25, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
            end)
        end)

        task.delay(0.25, function()
            tw(Win,      0.45, { Size = UDim2.new(0, W.WW, 0, W.WH) }, Enum.EasingStyle.Quint)
            tw(BodyClip, 0.45, { Size = UDim2.new(0, W.WW, 0, W.BH) }, Enum.EasingStyle.Quint)
        end)

        task.delay(0.5, function()
            tw(NavBar,    0.4,  { Size = UDim2.new(0, W.NW, 0, W.NH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
            tw(NavStroke, 0.35, { Transparency = 0.2 })
            showAllTabs(0.25)
        end)
    end

    -- ── MINIMIZE / RESTORE ───────────────────────────────────
    function Animations.toggleMinimize()
        if animating then return end
        animating = true
        minimized = not minimized

        if minimized then
            hideAllTabs(true)
            tw(BodyClip,  0.3,  { Size = UDim2.new(0, W.WW, 0, 0)    }, Enum.EasingStyle.Quint)
            tw(Win,       0.3,  { Size = UDim2.new(0, W.WW, 0, W.TH) }, Enum.EasingStyle.Quint)
            tw(WinStroke, 0.25, { Transparency = 0.5 })
            tw(title1, 0.2, { TextTransparency = 0.5 })
            if title3 then tw(title3, 0.2, { TextTransparency = 0.7 }) end
            tw(title5, 0.2, { TextTransparency = 0.8 })
            task.delay(0.1, function()
                tw(NavBar,    0.25, { Size = UDim2.new(0, W.NW, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint)
                tw(NavStroke, 0.2,  { Transparency = 1 })
            end)
            task.delay(0.35, function() NavBar.Visible = false; animating = false end)
        else
            NavBar.Visible                = true
            NavBar.Size                   = UDim2.new(0, W.NW, 0, 0)
            NavBar.BackgroundTransparency = 1
            NavStroke.Transparency        = 1
            for _, tab in ipairs(navT) do
                tab.pill.BackgroundTransparency = 1
                tab.img.ImageTransparency       = 1
                tab.lbl.TextTransparency        = 1
            end
            tw(Win,       0.35, { Size = UDim2.new(0, W.WW, 0, W.WH) }, Enum.EasingStyle.Quint)
            tw(BodyClip,  0.35, { Size = UDim2.new(0, W.WW, 0, W.BH) }, Enum.EasingStyle.Quint)
            tw(WinStroke, 0.3,  { Transparency = 0.2 })
            task.delay(0.05, function()
                tw(NavBar,    0.35, { Size = UDim2.new(0, W.NW, 0, W.NH), BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
                tw(NavStroke, 0.3,  { Transparency = 0.2 })
                tw(title1, 0.25, { TextTransparency = 0 })
                if title3 then tw(title3, 0.25, { TextTransparency = 0 }) end
                tw(title5, 0.25, { TextTransparency = 0 })
            end)
            showAllTabs(0.3)
            task.delay(0.5, function() animating = false end)
        end

        MinB.Text = minimized and "□" or "─"
    end

    -- ── CLOSE ────────────────────────────────────────────────
    function Animations.doClose()
        if animating then return end
        animating     = true
        Win.Active    = false
        NavBar.Active = false

        hideAllTabs(true)

        task.delay(0.08, function()
            tw(NavBar,    0.25, { Size = UDim2.new(0, W.NW, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tw(NavStroke, 0.2,  { Transparency = 1 })
        end)
        task.delay(0.2, function()
            tw(BodyClip, 0.3, {
                Size     = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0, W.WW/2, 0, W.TH),
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tw(rdot, 0.2, { BackgroundTransparency = 1 })
            -- Animar títulos (title3 puede ser nil)
            for _, el in ipairs({ title1, title2, title4, title5, MinB, ClsB }) do
                tw(el, 0.2, { TextTransparency = 1 })
            end
            if title3 then tw(title3, 0.2, { TextTransparency = 1 }) end
        end)
        task.delay(0.4, function()
            tw(Win,       0.35, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tw(WinStroke, 0.3,  { Transparency = 1 })
        end)
        task.delay(0.8, function() SG:Destroy() end)
    end

    -- ── HIDE / SHOW ──────────────────────────────────────────
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

    function Animations.isMinimized() return minimized end

    return Animations
end

return Animations
