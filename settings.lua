-- ============================================================
-- settings.lua  –  PanelBase | dzanity.gg
-- Dueño de: paleta de colores, constantes de layout,
--           y todo el contenido de la pestaña Settings.
-- ============================================================

local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Settings = {}

-- ════════════════════════════════════════════════════════════
-- PALETA DE COLORES  (fuente de verdad del panel)
-- ════════════════════════════════════════════════════════════
Settings.C = {
    WIN    = Color3.fromRGB(18,  18,  18),
    TBAR   = Color3.fromRGB(13,  13,  13),
    LINE   = Color3.fromRGB(42,  42,  42),
    RED    = Color3.fromRGB(205, 30,  30),
    NAV    = Color3.fromRGB(11,  11,  11),
    NAVPIL = Color3.fromRGB(28,  28,  28),
    WHITE  = Color3.fromRGB(235, 235, 235),
    GRAY   = Color3.fromRGB(110, 110, 110),
    MUTED  = Color3.fromRGB(55,  55,  55),
    PANEL  = Color3.fromRGB(14,  14,  14),
}

-- ════════════════════════════════════════════════════════════
-- CONSTANTES DE LAYOUT
-- ════════════════════════════════════════════════════════════
Settings.Layout = {
    WW   = 540,
    WH   = 440,
    TH   = 42,
    NW   = 320,
    NH   = 46,
    NGAP = 14,
    BH   = 440 - 42,   -- WH - TH
}

-- ════════════════════════════════════════════════════════════
-- BUILD  –  construye el contenido de la pestaña Settings
-- ════════════════════════════════════════════════════════════
function Settings.build(page, r)
    local C   = Settings.C
    local mk  = r.mk
    local rnd = r.rnd
    local tw  = r.tw

    local navT     = r.navT
    local actNavFn = r.actNavFn
    local rdot     = r.rdot
    local title2   = r.title2
    local title1   = r.title1
    local title3   = r.title3

    -- Elementos que cambian de color junto al acento
    local accentEls = {}   -- { el=instance, prop="TextColor3"|"ImageColor3"|"BackgroundColor3" }

    -- ── Layout order ────────────────────────────────────────
    local so = 0
    local function SO() so = so + 1; return so end

    -- ── MiniPanel ────────────────────────────────────────────
    local function MiniPanel(parent, title, fixedW)
        local panel = mk("Frame", {
            Size             = fixedW and UDim2.new(0, fixedW, 0, 0) or UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.PANEL,
            BorderSizePixel  = 0,
            LayoutOrder      = SO(),
        }, parent)
        rnd(6, panel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.7 }, panel)
        mk("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, panel)
        local content = mk("Frame", {
            Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 0, 28),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        }, panel)
        mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, content)
        mk("UIPadding", { PaddingBottom = UDim.new(0, 8) }, panel)
        return content
    end

    -- ────────────────────────────────────────────────────────
    -- FUNCIÓN COMPARTIDA: aplica un color a todo el panel
    -- ────────────────────────────────────────────────────────
    local function applyAccent(col)
        C.RED = col
        rdot.BackgroundColor3 = col
        title2.TextColor3     = col
        for i, t in ipairs(navT) do
            if i == actNavFn() then
                tw(t.img, .2, { ImageColor3 = col })
            end
        end
        for _, e in ipairs(accentEls) do
            pcall(function() e.el[e.prop] = col end)
        end
    end

    -- ════════════════════════════════════════════════════════
    -- ACCENT COLOR PICKER
    -- ════════════════════════════════════════════════════════
    local function CreateAccentPicker(parent)
        local originalColor           = C.RED
        local currentH, currentS, currentV = Color3.toHSV(C.RED)
        local pickerOpen              = false
        local pickerAnim              = false

        local PW      = 200
        local SV      = 118
        local HW      = 12
        local PAD     = 8
        local PREVW   = PW - SV - HW - PAD * 3
        local APPH    = 20
        local CONTENTH= SV + PAD + APPH
        local TOTALH  = CONTENTH + PAD * 2

        local root = mk("Frame", {
            Size = UDim2.new(0, PW, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, parent)
        mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, root)

        -- ── Row 1: label + checkbox ──────────────────────────
        local row1 = mk("Frame", { Size = UDim2.new(0, PW, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1 }, root)
        mk("TextLabel", {
            Text = "Accent Color", Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(0, PW - 26, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row1)

        local chkBg = mk("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, PW - 16, 0.5, -8),
            BackgroundColor3 = C.MUTED, BorderSizePixel = 0, ZIndex = 5,
        }, row1)
        rnd(4, chkBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, chkBg)

        local chkMark = mk("TextLabel", {
            Text = "✓", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.RED, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 6,
            TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
        }, chkBg)
        table.insert(accentEls, { el = chkMark, prop = "TextColor3" })

        local checked  = false
        local chkBtn   = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 7, AutoButtonColor = false }, chkBg)

        -- ── Row 1b: RGB Mode checkbox ────────────────────────
        local rgbModeRow = mk("Frame", { Size = UDim2.new(0, PW, 0, 22), BackgroundTransparency = 1, LayoutOrder = 2 }, root)
        mk("TextLabel", {
            Text = "RGB Mode", Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(0, PW - 26, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, rgbModeRow)

        -- pequeño badge "LED" decorativo
        local ledBadge = mk("Frame", {
            Size = UDim2.new(0, 28, 0, 13), Position = UDim2.new(0, 68, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(22, 22, 22), BorderSizePixel = 0, ZIndex = 6,
        }, rgbModeRow)
        rnd(4, ledBadge)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, ledBadge)
        mk("TextLabel", {
            Text = "LED", Font = Enum.Font.GothamBold, TextSize = 7,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 7,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, ledBadge)

        local rgbChkBg = mk("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, PW - 16, 0.5, -8),
            BackgroundColor3 = C.MUTED, BorderSizePixel = 0, ZIndex = 5,
        }, rgbModeRow)
        rnd(4, rgbChkBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, rgbChkBg)

        local rgbChkMark = mk("TextLabel", {
            Text = "✓", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.RED, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 6,
            TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
        }, rgbChkBg)
        table.insert(accentEls, { el = rgbChkMark, prop = "TextColor3" })

        local rgbChkBtn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 7, AutoButtonColor = false,
        }, rgbChkBg)

        -- Estado y loop del RGB Mode
        local rgbModeOn   = false
        local rgbHue      = 0
        local rgbConn     = nil   -- conexión RenderStepped

        local function stopRGBMode()
            if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
        end

        local function startRGBMode()
            stopRGBMode()
            rgbConn = RunService.RenderStepped:Connect(function(dt)
                rgbHue = (rgbHue + dt * 0.4) % 1   -- velocidad: 0.4 = una vuelta ~2.5 seg
                local col = Color3.fromHSV(rgbHue, 1, 1)
                applyAccent(col)
            end)
        end

        rgbChkBtn.MouseButton1Click:Connect(function()
            rgbModeOn = not rgbModeOn
            tw(rgbChkBg, .15, { BackgroundColor3 = rgbModeOn and Color3.fromRGB(28,28,28) or C.MUTED })
            tw(rgbChkMark, .15, { TextTransparency = rgbModeOn and 0 or 1 })
            if rgbModeOn then
                -- desactivar el otro checkbox si estaba activo
                checked = false
                tw(chkBg, .15, { BackgroundColor3 = C.MUTED })
                tw(chkMark, .15, { TextTransparency = 1 })
                startRGBMode()
            else
                stopRGBMode()
                applyAccent(originalColor)   -- restaurar color original
            end
        end)

        -- ── Row 2: botón desplegable ─────────────────────────
        local palBtn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(0, PW, 0, 26), BorderSizePixel = 0, ZIndex = 5, AutoButtonColor = false, LayoutOrder = 2,
        }, root)
        local palBg = mk("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(22,22,22), BorderSizePixel = 0, ZIndex = 4 }, palBtn)
        rnd(6, palBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, palBg)

        local prevDot = mk("Frame", {
            Size = UDim2.new(0,12,0,12), Position = UDim2.new(0,8,0.5,-6),
            BackgroundColor3 = C.RED, BorderSizePixel = 0, ZIndex = 6,
        }, palBg)
        rnd(6, prevDot)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, prevDot)

        mk("TextLabel", { Text = "Color Palette", Font = Enum.Font.GothamSemibold, TextSize = 9,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(0, PW - 46, 1, 0), Position = UDim2.new(0, 26, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 }, palBg)

        local arrowC = mk("TextLabel", { Text = "▼", Font = Enum.Font.Code, TextSize = 7,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(0,14,1,0), Position = UDim2.new(0, PW-16, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6 }, palBg)

        palBtn.MouseEnter:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(27,27,27)}) end)
        palBtn.MouseLeave:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)

        -- ── Row 3: panel colapsable ──────────────────────────
        local pickerPanel = mk("Frame", {
            Size = UDim2.new(0, PW, 0, 0),
            BackgroundColor3 = Color3.fromRGB(16,16,16),
            BorderSizePixel = 0, ZIndex = 5, ClipsDescendants = true, LayoutOrder = 3,
        }, root)
        rnd(8, pickerPanel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, pickerPanel)

        local inner = mk("Frame", {
            Size = UDim2.new(0, PW - PAD*2, 0, CONTENTH),
            Position = UDim2.new(0, PAD, 0, PAD),
            BackgroundTransparency = 1, ZIndex = 6,
        }, pickerPanel)

        -- SV Square
        local svSq = mk("Frame", {
            Size = UDim2.new(0, SV, 0, SV),
            BackgroundColor3 = Color3.fromHSV(currentH,1,1),
            BorderSizePixel = 0, ZIndex = 7,
        }, inner)
        rnd(4, svSq)

        local wL = mk("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=8}, svSq)
        local wG = Instance.new("UIGradient")
        wG.Rotation=0; wG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); wG.Parent=wL

        local bL = mk("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(0,0,0), BorderSizePixel=0, ZIndex=9}, svSq)
        local bG = Instance.new("UIGradient")
        bG.Rotation=90; bG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); bG.Parent=bL

        local svCur = mk("Frame", {Size=UDim2.new(0,10,0,10), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=12}, inner)
        rnd(5,svCur); mk("UIStroke",{Color=Color3.new(0,0,0),Thickness=1.5},svCur)

        local svHit = mk("TextButton", {Text="", BackgroundTransparency=1, Size=UDim2.new(0,SV,0,SV), ZIndex=13, AutoButtonColor=false}, inner)

        -- Hue bar
        local hueBg = mk("Frame", {
            Size=UDim2.new(0,HW,0,SV), Position=UDim2.new(0,SV+PAD,0,0),
            BackgroundColor3=Color3.new(1,0,0), BorderSizePixel=0, ZIndex=7,
        }, inner)
        rnd(4,hueBg)
        local hG = Instance.new("UIGradient")
        hG.Rotation=90
        hG.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,  0,  0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,  0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(  0,255,  0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0,  0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,  0,255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,  0,  0)),
        })
        hG.Parent=hueBg

        local hueCur = mk("Frame", {Size=UDim2.new(0,HW+4,0,3), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=9}, inner)
        rnd(2,hueCur); mk("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},hueCur)

        local hueHit = mk("TextButton", {
            Text="", BackgroundTransparency=1,
            Size=UDim2.new(0,HW,0,SV), Position=UDim2.new(0,SV+PAD,0,0),
            ZIndex=13, AutoButtonColor=false,
        }, inner)

        -- Preview + hex
        local rx       = SV + HW + PAD*2
        local bigPrev  = mk("Frame", {
            Size=UDim2.new(0,PREVW,0,SV-20), Position=UDim2.new(0,rx,0,0),
            BackgroundColor3=Color3.fromHSV(currentH,currentS,currentV),
            BorderSizePixel=0, ZIndex=7,
        }, inner)
        rnd(5,bigPrev); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.4},bigPrev)

        local function toHex(c)
            return string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
        end

        local hexLbl = mk("TextLabel", {
            Text=toHex(C.RED), Font=Enum.Font.Code, TextSize=7, TextColor3=C.GRAY,
            BackgroundTransparency=1, Size=UDim2.new(0,PREVW,0,14),
            Position=UDim2.new(0,rx,0,SV-18),
            TextXAlignment=Enum.TextXAlignment.Center, ZIndex=7,
        }, inner)

        -- Apply button
        local applyBtn = mk("TextButton", {
            Text="Apply Color", Font=Enum.Font.GothamSemibold, TextSize=9,
            TextColor3=Color3.fromHSV(currentH,currentS,currentV),
            BackgroundColor3=Color3.fromRGB(30,30,30), BorderSizePixel=0, ZIndex=7,
            Size=UDim2.new(0,PW-PAD*2,0,APPH), Position=UDim2.new(0,0,0,SV+PAD), AutoButtonColor=false,
        }, inner)
        rnd(5,applyBtn); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.3},applyBtn)
        applyBtn.MouseEnter:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(38,38,38)}) end)
        applyBtn.MouseLeave:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(30,30,30)}) end)

        -- Refresh visual
        local function refreshPicker()
            local col = Color3.fromHSV(currentH, currentS, currentV)
            svSq.BackgroundColor3  = Color3.fromHSV(currentH,1,1)
            bigPrev.BackgroundColor3 = col
            prevDot.BackgroundColor3 = col
            hexLbl.Text            = toHex(col)
            applyBtn.TextColor3    = col
            svCur.Position         = UDim2.new(0, currentS*SV - 5, 0, (1-currentV)*SV - 5)
            hueCur.Position        = UDim2.new(0, SV+PAD-2, 0, currentH*SV - 1)
        end

        -- Checkbox
        chkBtn.MouseButton1Click:Connect(function()
            checked = not checked
            tw(chkBg,.15,{BackgroundColor3=checked and Color3.fromRGB(28,28,28) or C.MUTED})
            tw(chkMark,.15,{TextTransparency=checked and 0 or 1})
            if checked then
                -- desactivar RGB Mode si estaba encendido
                if rgbModeOn then
                    rgbModeOn = false
                    stopRGBMode()
                    tw(rgbChkBg, .15, { BackgroundColor3 = C.MUTED })
                    tw(rgbChkMark, .15, { TextTransparency = 1 })
                end
                applyAccent(Color3.fromHSV(currentH,currentS,currentV))
            else
                applyAccent(originalColor)
            end
        end)

        -- Apply
        applyBtn.MouseButton1Click:Connect(function()
            if not checked then
                tw(chkBg,.1,{BackgroundColor3=Color3.fromRGB(80,40,40)})
                task.delay(.2,function() tw(chkBg,.1,{BackgroundColor3=C.MUTED}) end)
                return
            end
            -- detener RGB Mode si estaba activo
            if rgbModeOn then
                rgbModeOn = false
                stopRGBMode()
                tw(rgbChkBg, .15, { BackgroundColor3 = C.MUTED })
                tw(rgbChkMark, .15, { TextTransparency = 1 })
            end
            local newCol = Color3.fromHSV(currentH,currentS,currentV)
            applyAccent(newCol)
            tw(applyBtn,.08,{TextColor3=Color3.fromRGB(80,220,80)})
            task.delay(.6,function() tw(applyBtn,.25,{TextColor3=newCol}) end)
        end)

        -- SV drag
        local svDrag = false
        svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
        UIS.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
        RunService.RenderStepped:Connect(function()
            if not svDrag then return end
            local mp = UIS:GetMouseLocation()
            currentS = math.clamp((mp.X - svHit.AbsolutePosition.X) / svHit.AbsoluteSize.X, 0, 1)
            currentV = 1 - math.clamp((mp.Y - svHit.AbsolutePosition.Y) / svHit.AbsoluteSize.Y, 0, 1)
            refreshPicker()
        end)

        -- Hue drag
        local hueDrag = false
        hueHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
        UIS.InputEnded:Connect(function(i)   if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
        RunService.RenderStepped:Connect(function()
            if not hueDrag then return end
            local mp = UIS:GetMouseLocation()
            currentH = math.clamp((mp.Y - hueHit.AbsolutePosition.Y) / hueHit.AbsoluteSize.Y, 0, 1)
            refreshPicker()
        end)

        -- Toggle
        palBtn.MouseButton1Click:Connect(function()
            if pickerAnim then return end
            pickerAnim = true; pickerOpen = not pickerOpen
            if pickerOpen then
                arrowC.Text = "▲"
                tw(pickerPanel,.3,{Size=UDim2.new(0,PW,0,TOTALH)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            else
                arrowC.Text = "▼"
                tw(pickerPanel,.25,{Size=UDim2.new(0,PW,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
            end
            task.delay(.3,function() pickerAnim=false end)
        end)

        refreshPicker()
    end

    -- ════════════════════════════════════════════════════════
    -- ACENTO RGB  –  sliders R / G / B
    -- ════════════════════════════════════════════════════════
    local function CreateRGBPicker(parent)
        local PW       = 200
        local PAD      = 8
        local SLIDERH  = 14   -- altura de cada barra de slider
        local ROWH     = 32   -- alto total de cada fila (label + slider)
        local APPH     = 20
        -- Panel colapsable: 3 filas + separador + apply + paddings
        local INNERH   = ROWH * 3 + 6 + APPH + PAD
        local TOTALH   = INNERH + PAD * 2

        -- Valores iniciales desde C.RED actual
        local rVal = math.floor(C.RED.R * 255)
        local gVal = math.floor(C.RED.G * 255)
        local bVal = math.floor(C.RED.B * 255)

        local rgbOpen  = false
        local rgbAnim  = false
        local checked  = false

        local root = mk("Frame", {
            Size = UDim2.new(0, PW, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, parent)
        mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, root)

        -- ── Row 1: label + checkbox ──────────────────────────
        local row1 = mk("Frame", { Size = UDim2.new(0, PW, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1 }, root)
        mk("TextLabel", {
            Text = "Acento RGB", Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(0, PW - 26, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row1)

        local chkBg = mk("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, PW - 16, 0.5, -8),
            BackgroundColor3 = C.MUTED, BorderSizePixel = 0, ZIndex = 5,
        }, row1)
        rnd(4, chkBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, chkBg)

        local chkMark = mk("TextLabel", {
            Text = "✓", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.RED, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 6,
            TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
        }, chkBg)
        table.insert(accentEls, { el = chkMark, prop = "TextColor3" })

        local chkBtn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 7, AutoButtonColor = false,
        }, chkBg)

        -- ── Row 2: botón desplegable ─────────────────────────
        local rgbBtn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(0, PW, 0, 26), BorderSizePixel = 0,
            ZIndex = 5, AutoButtonColor = false, LayoutOrder = 2,
        }, root)
        local rgbBtnBg = mk("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            BorderSizePixel = 0, ZIndex = 4,
        }, rgbBtn)
        rnd(6, rgbBtnBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, rgbBtnBg)

        -- Dot de preview del color actual
        local prevDotRGB = mk("Frame", {
            Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 8, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(rVal, gVal, bVal), BorderSizePixel = 0, ZIndex = 6,
        }, rgbBtnBg)
        rnd(6, prevDotRGB)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, prevDotRGB)

        mk("TextLabel", {
            Text = "RGB Sliders", Font = Enum.Font.GothamSemibold, TextSize = 9,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(0, PW - 46, 1, 0), Position = UDim2.new(0, 26, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, rgbBtnBg)

        local arrowRGB = mk("TextLabel", {
            Text = "▼", Font = Enum.Font.Code, TextSize = 7,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, PW - 16, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
        }, rgbBtnBg)

        rgbBtn.MouseEnter:Connect(function() tw(rgbBtnBg, .1, { BackgroundColor3 = Color3.fromRGB(27,27,27) }) end)
        rgbBtn.MouseLeave:Connect(function() tw(rgbBtnBg, .1, { BackgroundColor3 = Color3.fromRGB(22,22,22) }) end)

        -- ── Row 3: panel colapsable ──────────────────────────
        local rgbPanel = mk("Frame", {
            Size = UDim2.new(0, PW, 0, 0),
            BackgroundColor3 = Color3.fromRGB(16, 16, 16),
            BorderSizePixel = 0, ZIndex = 5,
            ClipsDescendants = true, LayoutOrder = 3,
        }, root)
        rnd(8, rgbPanel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, rgbPanel)

        local inner = mk("Frame", {
            Size = UDim2.new(0, PW - PAD * 2, 0, INNERH),
            Position = UDim2.new(0, PAD, 0, PAD),
            BackgroundTransparency = 1, ZIndex = 6,
        }, rgbPanel)

        -- ── Helper: crear una fila de slider ─────────────────
        -- Devuelve una función setVal(0-255) y conecta el drag
        local applyBtnRGB  -- referencia anticipada

        local sliderDrags = {}  -- para evitar solapamientos

        local function makeSlider(yPos, labelTxt, initVal, trackCol, onChanged)
            local SW = PW - PAD * 2   -- ancho total disponible
            local LW = 10             -- ancho del label R/G/B
            local NW = 22             -- ancho del número
            local BAR = SW - LW - NW - 6  -- ancho de la barra

            -- Label (R / G / B)
            mk("TextLabel", {
                Text = labelTxt, Font = Enum.Font.GothamBold, TextSize = 9,
                TextColor3 = C.GRAY, BackgroundTransparency = 1,
                Size = UDim2.new(0, LW, 0, ROWH), Position = UDim2.new(0, 0, 0, yPos),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
            }, inner)

            -- Track (barra de fondo)
            local track = mk("Frame", {
                Size = UDim2.new(0, BAR, 0, SLIDERH),
                Position = UDim2.new(0, LW + 2, 0, yPos + (ROWH - SLIDERH) / 2),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0, ZIndex = 7,
            }, inner)
            rnd(4, track)
            mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, track)

            -- Fill (parte coloreada)
            local fill = mk("Frame", {
                Size = UDim2.new(initVal / 255, 0, 1, 0),
                BackgroundColor3 = trackCol,
                BorderSizePixel = 0, ZIndex = 8,
            }, track)
            rnd(4, fill)

            -- Número
            local numLbl = mk("TextLabel", {
                Text = tostring(initVal), Font = Enum.Font.Code, TextSize = 8,
                TextColor3 = C.GRAY, BackgroundTransparency = 1,
                Size = UDim2.new(0, NW, 0, ROWH), Position = UDim2.new(0, LW + BAR + 4, 0, yPos),
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
            }, inner)

            -- Hit zone (botón invisible sobre la barra)
            local hit = mk("TextButton", {
                Text = "", BackgroundTransparency = 1,
                Size = UDim2.new(0, BAR, 0, SLIDERH + 8),
                Position = UDim2.new(0, LW + 2, 0, yPos + (ROWH - SLIDERH) / 2 - 4),
                ZIndex = 10, AutoButtonColor = false,
            }, inner)

            local dragging = false
            local function updateDrag()
                if not dragging then return end
                local mp = UIS:GetMouseLocation()
                local pct = math.clamp(
                    (mp.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                    0, 1
                )
                local val = math.floor(pct * 255)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                numLbl.Text = tostring(val)
                onChanged(val)
            end

            hit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateDrag()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then updateDrag() end
            end)

            -- Función pública para actualizar visualmente desde fuera
            local function setVal(v)
                fill.Size   = UDim2.new(v / 255, 0, 1, 0)
                numLbl.Text = tostring(v)
            end

            return setVal
        end

        -- Actualizar el preview dot y el apply button cuando cambia cualquier canal
        local function onAnyChange()
            local col = Color3.fromRGB(rVal, gVal, bVal)
            prevDotRGB.BackgroundColor3 = col
            if applyBtnRGB then
                applyBtnRGB.TextColor3 = col
            end
        end

        local setR = makeSlider(0,         "R", rVal, Color3.fromRGB(200, 60,  60),  function(v) rVal = v; onAnyChange() end)
        local setG = makeSlider(ROWH + 3,  "G", gVal, Color3.fromRGB(60,  200, 60),  function(v) gVal = v; onAnyChange() end)
        local setB = makeSlider(ROWH*2+6,  "B", bVal, Color3.fromRGB(60,  100, 220), function(v) bVal = v; onAnyChange() end)

        -- Apply button
        applyBtnRGB = mk("TextButton", {
            Text = "Apply RGB", Font = Enum.Font.GothamSemibold, TextSize = 9,
            TextColor3 = Color3.fromRGB(rVal, gVal, bVal),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, ZIndex = 7,
            Size = UDim2.new(0, PW - PAD * 2, 0, APPH),
            Position = UDim2.new(0, 0, 0, ROWH * 3 + 6),
            AutoButtonColor = false,
        }, inner)
        rnd(5, applyBtnRGB)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.3 }, applyBtnRGB)
        applyBtnRGB.MouseEnter:Connect(function() tw(applyBtnRGB, .1, { BackgroundColor3 = Color3.fromRGB(38,38,38) }) end)
        applyBtnRGB.MouseLeave:Connect(function() tw(applyBtnRGB, .1, { BackgroundColor3 = Color3.fromRGB(30,30,30) }) end)

        -- Checkbox toggle
        chkBtn.MouseButton1Click:Connect(function()
            checked = not checked
            tw(chkBg, .15, { BackgroundColor3 = checked and Color3.fromRGB(28,28,28) or C.MUTED })
            tw(chkMark, .15, { TextTransparency = checked and 0 or 1 })
            if checked then
                applyAccent(Color3.fromRGB(rVal, gVal, bVal))
            end
        end)

        -- Apply button click
        applyBtnRGB.MouseButton1Click:Connect(function()
            if not checked then
                tw(chkBg, .1, { BackgroundColor3 = Color3.fromRGB(80,40,40) })
                task.delay(.2, function() tw(chkBg, .1, { BackgroundColor3 = C.MUTED }) end)
                return
            end
            local newCol = Color3.fromRGB(rVal, gVal, bVal)
            applyAccent(newCol)
            tw(applyBtnRGB, .08, { TextColor3 = Color3.fromRGB(80,220,80) })
            task.delay(.6, function() tw(applyBtnRGB, .25, { TextColor3 = newCol }) end)
        end)

        -- Sincronizar sliders cuando cambia C.RED desde otro picker
        -- (llamado externamente si se necesita; aquí solo inicializamos)
        local function syncFromAccent()
            rVal = math.floor(C.RED.R * 255)
            gVal = math.floor(C.RED.G * 255)
            bVal = math.floor(C.RED.B * 255)
            setR(rVal); setG(gVal); setB(bVal)
            prevDotRGB.BackgroundColor3 = Color3.fromRGB(rVal, gVal, bVal)
            if applyBtnRGB then applyBtnRGB.TextColor3 = Color3.fromRGB(rVal, gVal, bVal) end
        end

        -- Toggle desplegable
        rgbBtn.MouseButton1Click:Connect(function()
            if rgbAnim then return end
            rgbAnim = true; rgbOpen = not rgbOpen
            if rgbOpen then
                arrowRGB.Text = "▲"
                tw(rgbPanel, .3, { Size = UDim2.new(0, PW, 0, TOTALH) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            else
                arrowRGB.Text = "▼"
                tw(rgbPanel, .25, { Size = UDim2.new(0, PW, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            end
            task.delay(.3, function() rgbAnim = false end)
        end)
    end

    -- ════════════════════════════════════════════════════════
    -- FONT PICKER
    -- ════════════════════════════════════════════════════════
    local FONTS = {
        { name="Gotham",     font=Enum.Font.Gotham     },
        { name="GothamBold", font=Enum.Font.GothamBold },
        { name="Code",       font=Enum.Font.Code       },
        { name="Ubuntu",     font=Enum.Font.Ubuntu     },
        { name="Arcade",     font=Enum.Font.Arcade     },
        { name="Bangers",    font=Enum.Font.Bangers    },
    }

    local function CreateFontPicker(parent)
        local PW       = 200
        local ITEMH    = 26
        local GAPF     = 3
        local selFont  = 1
        local checked  = false
        local panOpen  = false
        local panAnim  = false
        local LISTHTOTAL = #FONTS * ITEMH + (#FONTS-1)*GAPF + 16
        local PAD      = 8

        local root = mk("Frame", {
            Size=UDim2.new(0,PW,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, LayoutOrder=SO(),
        }, parent)
        mk("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},root)

        -- Row 1
        local row1 = mk("Frame",{Size=UDim2.new(0,PW,0,22),BackgroundTransparency=1,LayoutOrder=1},root)
        mk("TextLabel",{
            Text="Font", Font=Enum.Font.GothamSemibold, TextSize=10,
            TextColor3=C.WHITE, BackgroundTransparency=1,
            Size=UDim2.new(0,PW-26,1,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
        },row1)

        local chkBg = mk("Frame",{
            Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,PW-16,0.5,-8),
            BackgroundColor3=C.MUTED, BorderSizePixel=0, ZIndex=5,
        },row1)
        rnd(4,chkBg); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.3},chkBg)

        local chkMark = mk("TextLabel",{
            Text="✓", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=C.RED,
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=6,
            TextXAlignment=Enum.TextXAlignment.Center, TextTransparency=1,
        },chkBg)
        table.insert(accentEls,{el=chkMark,prop="TextColor3"})

        local chkBtn = mk("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=7,AutoButtonColor=false},chkBg)

        -- Row 2
        local selBtn = mk("TextButton",{
            Text="",BackgroundTransparency=1,Size=UDim2.new(0,PW,0,26),
            BorderSizePixel=0,ZIndex=5,AutoButtonColor=false,LayoutOrder=2,
        },root)
        local selBg = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0,ZIndex=4},selBtn)
        rnd(6,selBg); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.5},selBg)

        local fontIcon = mk("TextLabel",{
            Text="Aa",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.RED,
            BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,8,0,0),
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6,
        },selBg)
        table.insert(accentEls,{el=fontIcon,prop="TextColor3"})

        local selLbl = mk("TextLabel",{
            Text=FONTS[selFont].name,Font=FONTS[selFont].font,TextSize=10,
            TextColor3=C.WHITE,BackgroundTransparency=1,
            Size=UDim2.new(0,PW-56,1,0),Position=UDim2.new(0,30,0,0),
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },selBg)

        local arrowF = mk("TextLabel",{
            Text="▼",Font=Enum.Font.Code,TextSize=7,TextColor3=C.GRAY,
            BackgroundTransparency=1,Size=UDim2.new(0,14,1,0),Position=UDim2.new(0,PW-16,0,0),
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6,
        },selBg)

        selBtn.MouseEnter:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(27,27,27)}) end)
        selBtn.MouseLeave:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)

        -- Row 3: lista
        local listPanel = mk("Frame",{
            Size=UDim2.new(0,PW,0,0),BackgroundColor3=Color3.fromRGB(16,16,16),
            BorderSizePixel=0,ZIndex=5,ClipsDescendants=true,LayoutOrder=3,
        },root)
        rnd(8,listPanel); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.5},listPanel)

        local listInner = mk("Frame",{
            Size=UDim2.new(0,PW-PAD*2,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            Position=UDim2.new(0,PAD,0,PAD/2),BackgroundTransparency=1,ZIndex=6,
        },listPanel)
        mk("UIListLayout",{Padding=UDim.new(0,GAPF),SortOrder=Enum.SortOrder.LayoutOrder},listInner)

        local itemRefs = {}
        for i, fd in ipairs(FONTS) do
            local isSel = (i==selFont)
            local item = mk("Frame",{
                Size=UDim2.new(0,PW-PAD*2,0,ITEMH),
                BackgroundColor3=isSel and Color3.fromRGB(30,30,30) or Color3.fromRGB(20,20,20),
                BorderSizePixel=0,ZIndex=7,LayoutOrder=i,
            },listInner)
            rnd(5,item)
            local stroke = mk("UIStroke",{Color=isSel and C.RED or C.LINE,Thickness=1,Transparency=isSel and 0.3 or 0.7},item)
            local lbl = mk("TextLabel",{
                Text=fd.name,Font=fd.font,TextSize=10,
                TextColor3=isSel and C.WHITE or C.GRAY,BackgroundTransparency=1,
                Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,8,0,0),
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8,
            },item)
            local dot = mk("Frame",{
                Size=UDim2.new(0,5,0,5),Position=UDim2.new(1,-12,0.5,-2),
                BackgroundColor3=C.RED,BorderSizePixel=0,ZIndex=8,
            },item)
            rnd(3,dot)
            dot.BackgroundTransparency = isSel and 0 or 1
            table.insert(accentEls,{el=dot,prop="BackgroundColor3"})

            local hitBtn = mk("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=9,AutoButtonColor=false},item)
            itemRefs[i] = {item=item,lbl=lbl,dot=dot,stroke=stroke}

            hitBtn.MouseEnter:Connect(function()
                if i~=selFont then tw(item,.1,{BackgroundColor3=Color3.fromRGB(25,25,25)}); tw(lbl,.1,{TextColor3=C.WHITE}) end
            end)
            hitBtn.MouseLeave:Connect(function()
                if i~=selFont then tw(item,.1,{BackgroundColor3=Color3.fromRGB(20,20,20)}); tw(lbl,.1,{TextColor3=C.GRAY}) end
            end)
            hitBtn.MouseButton1Click:Connect(function()
                local prev = itemRefs[selFont]
                tw(prev.item,.15,{BackgroundColor3=Color3.fromRGB(20,20,20)})
                tw(prev.stroke,.15,{Color=C.LINE,Transparency=0.7})
                tw(prev.lbl,.15,{TextColor3=C.GRAY})
                prev.dot.BackgroundTransparency = 1

                selFont = i
                tw(item,.15,{BackgroundColor3=Color3.fromRGB(30,30,30)})
                tw(stroke,.15,{Color=C.RED,Transparency=0.3})
                tw(lbl,.15,{TextColor3=C.WHITE})
                dot.BackgroundTransparency = 0
                selLbl.Text = fd.name; selLbl.Font = fd.font

                if checked then
                    title1.Font = fd.font; title3.Font = fd.font
                    for _, t in ipairs(navT) do t.lbl.Font = fd.font end
                end
            end)
        end

        chkBtn.MouseButton1Click:Connect(function()
            checked = not checked
            tw(chkBg,.15,{BackgroundColor3=checked and Color3.fromRGB(28,28,28) or C.MUTED})
            tw(chkMark,.15,{TextTransparency=checked and 0 or 1})
            if checked then
                local fd = FONTS[selFont]
                title1.Font=fd.font; title3.Font=fd.font
                for _, t in ipairs(navT) do t.lbl.Font=fd.font end
            else
                title1.Font=Enum.Font.GothamBold; title3.Font=Enum.Font.Gotham
                for _, t in ipairs(navT) do t.lbl.Font=Enum.Font.GothamSemibold end
            end
        end)

        selBtn.MouseButton1Click:Connect(function()
            if panAnim then return end
            panAnim=true; panOpen=not panOpen
            if panOpen then
                arrowF.Text="▲"
                tw(listPanel,.3,{Size=UDim2.new(0,PW,0,LISTHTOTAL)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            else
                arrowF.Text="▼"
                tw(listPanel,.25,{Size=UDim2.new(0,PW,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
            end
            task.delay(.3,function() panAnim=false end)
        end)
    end

    -- ── Construir la página ──────────────────────────────────
    task.delay(1, function()
        local colorPanel = MiniPanel(page, "Accent Color", 216)
        CreateAccentPicker(colorPanel)

        local rgbPanel = MiniPanel(page, "Acento RGB", 216)
        CreateRGBPicker(rgbPanel)

        local fontPanel = MiniPanel(page, "Font", 216)
        CreateFontPicker(fontPanel)
    end)
end

return Settings
