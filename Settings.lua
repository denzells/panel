-- ============================================
-- SETTINGS.LUA - MÓDULO DE CONFIGURACIÓN
-- ============================================

local Settings = {}

local cfg, C, mk, rnd, tw
local UIS, RunService
local so = 0

-- ============================================
-- INICIALIZACIÓN
-- ============================================
local function init()
    cfg = _G.PanelConfig
    C = cfg.C
    mk = cfg.mk
    rnd = cfg.rnd
    tw = require(script.Parent.Animations).tw
    UIS = cfg.Services.UIS
    RunService = cfg.Services.RunService
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
-- ACCENT COLOR PICKER
-- ============================================
local function CreateAccentPicker(parent)
    local originalColor = C.RED
    local currentH, currentS, currentV = Color3.toHSV(C.RED)
    local pickerOpen = false
    local pickerAnimating = false

    local PICK_W = 200
    local SV_SIZE = 118
    local HUE_W = 12
    local PAD = 8
    local PREV_W = PICK_W - SV_SIZE - HUE_W - PAD*3
    local APPLY_H = 20
    local CONTENT_H = SV_SIZE + PAD + APPLY_H
    local TOTAL_H = CONTENT_H + PAD*2

    local root = mk("Frame",{
        Size=UDim2.new(0,PICK_W,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    mk("UIListLayout",{Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, root)

    -- Row 1: checkbox
    local row1 = mk("Frame",{Size=UDim2.new(0,PICK_W,0,22), BackgroundTransparency=1, LayoutOrder=1}, root)
    mk("TextLabel",{
        Text="Change Panel Color", Font=Enum.Font.GothamSemibold, TextSize=10,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(0,PICK_W-26,1,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, row1)

    local checkBg = mk("Frame",{
        Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,PICK_W-16,0.5,-8),
        BackgroundColor3=C.MUTED, BorderSizePixel=0, ZIndex=5
    }, row1)
    rnd(4, checkBg)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.3}, checkBg)
    local checkMark = mk("TextLabel",{
        Text="✓", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=C.RED,
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=6,
        TextXAlignment=Enum.TextXAlignment.Center, TextTransparency=1
    }, checkBg)
    local checked = false
    local checkBtn = mk("TextButton",{Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=7, AutoButtonColor=false}, checkBg)

    -- Row 2: botón Color Palette
    local palBtn = mk("TextButton",{
        Text="", BackgroundTransparency=1, Size=UDim2.new(0,PICK_W,0,26),
        BorderSizePixel=0, ZIndex=5, AutoButtonColor=false, LayoutOrder=2
    }, root)
    local palBg = mk("Frame",{Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(22,22,22), BorderSizePixel=0, ZIndex=4}, palBtn)
    rnd(6, palBg); mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.5}, palBg)

    local previewDot = mk("Frame",{
        Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,8,0.5,-6),
        BackgroundColor3=C.RED, BorderSizePixel=0, ZIndex=6
    }, palBg)
    rnd(6, previewDot); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.3}, previewDot)

    mk("TextLabel",{Text="Color Palette", Font=Enum.Font.GothamSemibold, TextSize=9,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(0,PICK_W-46,1,0), Position=UDim2.new(0,26,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6}, palBg)

    local arrowLbl = mk("TextLabel",{Text="▼", Font=Enum.Font.Code, TextSize=7,
        TextColor3=C.GRAY, BackgroundTransparency=1,
        Size=UDim2.new(0,14,1,0), Position=UDim2.new(0,PICK_W-16,0,0),
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6}, palBg)

    palBtn.MouseEnter:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(27,27,27)}) end)
    palBtn.MouseLeave:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)

    -- Picker panel
    local pickerPanel = mk("Frame",{
        Size=UDim2.new(0,PICK_W,0,0), BackgroundColor3=Color3.fromRGB(16,16,16),
        BorderSizePixel=0, ZIndex=5, ClipsDescendants=true, LayoutOrder=3
    }, root)
    rnd(8, pickerPanel); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.5}, pickerPanel)

    local inner = mk("Frame",{
        Size=UDim2.new(0,PICK_W-PAD*2,0,CONTENT_H),
        Position=UDim2.new(0,PAD,0,PAD),
        BackgroundTransparency=1, ZIndex=6
    }, pickerPanel)

    -- SV Square
    local svSq = mk("Frame",{
        Size=UDim2.new(0,SV_SIZE,0,SV_SIZE),
        BackgroundColor3=Color3.fromHSV(currentH,1,1),
        BorderSizePixel=0, ZIndex=7
    }, inner)
    rnd(4, svSq)

    local wL = mk("Frame",{Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=8}, svSq)
    local wG = Instance.new("UIGradient")
    wG.Rotation = 0
    wG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    wG.Parent = wL

    local bL = mk("Frame",{Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(0,0,0), BorderSizePixel=0, ZIndex=9}, svSq)
    local bG = Instance.new("UIGradient")
    bG.Rotation = 90
    bG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
    bG.Parent = bL

    local svCursor = mk("Frame",{
        Size=UDim2.new(0,10,0,10), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=12
    }, inner)
    rnd(5, svCursor)
    mk("UIStroke",{Color=Color3.new(0,0,0),Thickness=1.5}, svCursor)

    local svHit = mk("TextButton",{Text="", BackgroundTransparency=1, Size=UDim2.new(0,SV_SIZE,0,SV_SIZE), ZIndex=13, AutoButtonColor=false}, inner)

    -- Hue Bar
    local hueBarBg = mk("Frame",{
        Size=UDim2.new(0,HUE_W,0,SV_SIZE),
        Position=UDim2.new(0,SV_SIZE+PAD,0,0),
        BackgroundColor3=Color3.new(1,0,0),
        BorderSizePixel=0, ZIndex=7
    }, inner)
    rnd(4, hueBarBg)

    local hG = Instance.new("UIGradient")
    hG.Rotation = 90
    hG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,   0,   0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255,   0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(  0, 255,   0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0,   0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,   0, 255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,   0,   0)),
    })
    hG.Parent = hueBarBg

    local hueCursor = mk("Frame",{
        Size=UDim2.new(0,HUE_W+4,0,3),
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=9
    }, inner)
    rnd(2, hueCursor)
    mk("UIStroke",{Color=Color3.new(0,0,0),Thickness=1}, hueCursor)

    local hueHit = mk("TextButton",{Text="", BackgroundTransparency=1,
        Size=UDim2.new(0,HUE_W,0,SV_SIZE), Position=UDim2.new(0,SV_SIZE+PAD,0,0),
        ZIndex=13, AutoButtonColor=false}, inner)

    -- Preview
    local rightX = SV_SIZE + HUE_W + PAD*2
    local bigPreview = mk("Frame",{
        Size=UDim2.new(0,PREV_W,0,SV_SIZE-20),
        Position=UDim2.new(0,rightX,0,0),
        BackgroundColor3=Color3.fromHSV(currentH,currentS,currentV),
        BorderSizePixel=0, ZIndex=7
    }, inner)
    rnd(5, bigPreview); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.4}, bigPreview)

    local function toHex(c)
        return string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
    end
    local hexLbl = mk("TextLabel",{
        Text=toHex(C.RED), Font=Enum.Font.Code, TextSize=7, TextColor3=C.GRAY,
        BackgroundTransparency=1, Size=UDim2.new(0,PREV_W,0,14),
        Position=UDim2.new(0,rightX,0,SV_SIZE-18),
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=7
    }, inner)

    -- Apply Button
    local applyBtn = mk("TextButton",{
        Text="Apply Color", Font=Enum.Font.GothamSemibold, TextSize=9,
        TextColor3=Color3.fromHSV(currentH,currentS,currentV),
        BackgroundColor3=Color3.fromRGB(30,30,30), BorderSizePixel=0, ZIndex=7,
        Size=UDim2.new(0,PICK_W-PAD*2,0,APPLY_H),
        Position=UDim2.new(0,0,0,SV_SIZE+PAD), AutoButtonColor=false
    }, inner)
    rnd(5, applyBtn); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.3}, applyBtn)
    applyBtn.MouseEnter:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(38,38,38)}) end)
    applyBtn.MouseLeave:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(30,30,30)}) end)

    local function refreshPicker()
        local col = Color3.fromHSV(currentH, currentS, currentV)
        svSq.BackgroundColor3 = Color3.fromHSV(currentH,1,1)
        bigPreview.BackgroundColor3 = col
        previewDot.BackgroundColor3 = col
        hexLbl.Text = toHex(col)
        applyBtn.TextColor3 = col
        svCursor.Position = UDim2.new(0, currentS*SV_SIZE - 5, 0, (1-currentV)*SV_SIZE - 5)
        hueCursor.Position = UDim2.new(0, SV_SIZE+PAD-2, 0, currentH*SV_SIZE - 1)
    end

    local function applyColor(col)
        C.RED = col
        cfg.rdot.BackgroundColor3 = col
        cfg.titles[2].TextColor3 = col
        checkMark.TextColor3 = col
        previewDot.BackgroundColor3 = col
        applyBtn.TextColor3 = col
        for i,t in ipairs(cfg.navT) do
            if i==cfg.activeTab then tw(t.img,.2,{ImageColor3=col}) end
        end
        for _, entry in ipairs(cfg.accentElements) do
            pcall(function() entry.el[entry.prop] = col end)
        end
    end

    checkBtn.MouseButton1Click:Connect(function()
        checked = not checked
        tw(checkBg,.15,{BackgroundColor3=checked and Color3.fromRGB(28,28,28) or C.MUTED})
        tw(checkMark,.15,{TextTransparency=checked and 0 or 1})
        if checked then
            applyColor(Color3.fromHSV(currentH, currentS, currentV))
        else
            applyColor(originalColor)
        end
    end)

    applyBtn.MouseButton1Click:Connect(function()
        if not checked then
            tw(checkBg,.1,{BackgroundColor3=Color3.fromRGB(80,40,40)})
            task.delay(.2,function() tw(checkBg,.1,{BackgroundColor3=C.MUTED}) end)
            return
        end
        local newColor = Color3.fromHSV(currentH, currentS, currentV)
        applyColor(newColor)
        tw(applyBtn,.08,{TextColor3=Color3.fromRGB(80,220,80)})
        task.delay(.6,function() tw(applyBtn,.25,{TextColor3=newColor}) end)
    end)

    -- SV Drag
    local svDrag=false
    svHit.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end
    end)
    RunService.RenderStepped:Connect(function()
        if not svDrag then return end
        local mp = UIS:GetMouseLocation()
        local ax = svHit.AbsolutePosition.X
        local ay = svHit.AbsolutePosition.Y
        local aw = svHit.AbsoluteSize.X
        local ah = svHit.AbsoluteSize.Y
        currentS = math.clamp((mp.X - ax) / aw, 0, 1)
        currentV = 1 - math.clamp((mp.Y - ay) / ah, 0, 1)
        refreshPicker()
    end)

    -- Hue Drag
    local hueDrag=false
    hueHit.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
    end)
    RunService.RenderStepped:Connect(function()
        if not hueDrag then return end
        local mp = UIS:GetMouseLocation()
        local ay = hueHit.AbsolutePosition.Y
        local ah = hueHit.AbsoluteSize.Y
        currentH = math.clamp((mp.Y - ay) / ah, 0, 1)
        refreshPicker()
    end)

    -- Toggle
    palBtn.MouseButton1Click:Connect(function()
        if pickerAnimating then return end
        pickerAnimating=true; pickerOpen=not pickerOpen
        if pickerOpen then
            arrowLbl.Text="▲"
            tw(pickerPanel,.3,{Size=UDim2.new(0,PICK_W,0,TOTAL_H)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        else
            arrowLbl.Text="▼"
            tw(pickerPanel,.25,{Size=UDim2.new(0,PICK_W,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        end
        task.delay(.3,function() pickerAnimating=false end)
    end)

    refreshPicker()
end

-- ============================================
-- FONT PICKER
-- ============================================
local FONTS = {
    {name="Gotham",      font=Enum.Font.Gotham},
    {name="GothamBold",  font=Enum.Font.GothamBold},
    {name="Code",        font=Enum.Font.Code},
    {name="Ubuntu",      font=Enum.Font.Ubuntu},
    {name="Arcade",      font=Enum.Font.Arcade},
    {name="Bangers",     font=Enum.Font.Bangers},
}

local function CreateFontPicker(parent)
    local PANEL_W = 200
    local ITEM_H = 26
    local GAP = 3
    local selectedFont = 1
    local checked = false
    local panelOpen = false
    local panelAnim = false
    local TOTAL_ITEMS_H = #FONTS * ITEM_H + (#FONTS - 1) * GAP + 16
    local PAD = 8

    local root = mk("Frame",{
        Size=UDim2.new(0,PANEL_W,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    mk("UIListLayout",{Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, root)

    -- Row 1
    local row1 = mk("Frame",{
        Size=UDim2.new(0,PANEL_W,0,22), BackgroundTransparency=1, LayoutOrder=1
    }, root)
    mk("TextLabel",{
        Text="Change Font", Font=Enum.Font.GothamSemibold, TextSize=10,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(0,PANEL_W-26,1,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, row1)

    local checkBg = mk("Frame",{
        Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,PANEL_W-16,0.5,-8),
        BackgroundColor3=C.MUTED, BorderSizePixel=0, ZIndex=5
    }, row1)
    rnd(4, checkBg)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.3}, checkBg)
    local checkMark = mk("TextLabel",{
        Text="✓", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=C.RED,
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=6,
        TextXAlignment=Enum.TextXAlignment.Center, TextTransparency=1
    }, checkBg)
    table.insert(cfg.accentElements, {el=checkMark, prop="TextColor3"})
    local checkBtn = mk("TextButton",{
        Text="", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=7, AutoButtonColor=false
    }, checkBg)

    -- Row 2
    local selBtn = mk("TextButton",{
        Text="", BackgroundTransparency=1,
        Size=UDim2.new(0,PANEL_W,0,26),
        BorderSizePixel=0, ZIndex=5, AutoButtonColor=false, LayoutOrder=2
    }, root)
    local selBg = mk("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(22,22,22),
        BorderSizePixel=0, ZIndex=4
    }, selBtn)
    rnd(6, selBg)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.5}, selBg)

    local fontIcon = mk("TextLabel",{
        Text="Aa", Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=C.RED, BackgroundTransparency=1,
        Size=UDim2.new(0,20,1,0), Position=UDim2.new(0,8,0,0),
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6
    }, selBg)
    table.insert(cfg.accentElements, {el=fontIcon, prop="TextColor3"})

    local selLbl = mk("TextLabel",{
        Text=FONTS[selectedFont].name,
        Font=FONTS[selectedFont].font, TextSize=10,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(0,PANEL_W-56,1,0), Position=UDim2.new(0,30,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6
    }, selBg)

    local arrowLbl = mk("TextLabel",{
        Text="▼", Font=Enum.Font.Code, TextSize=7,
        TextColor3=C.GRAY, BackgroundTransparency=1,
        Size=UDim2.new(0,14,1,0), Position=UDim2.new(0,PANEL_W-16,0,0),
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6
    }, selBg)

    selBtn.MouseEnter:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(27,27,27)}) end)
    selBtn.MouseLeave:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)

    -- Row 3
    local listPanel = mk("Frame",{
        Size=UDim2.new(0,PANEL_W,0,0),
        BackgroundColor3=Color3.fromRGB(16,16,16),
        BorderSizePixel=0, ZIndex=5, ClipsDescendants=true, LayoutOrder=3
    }, root)
    rnd(8, listPanel)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.5}, listPanel)

    local listInner = mk("Frame",{
        Size=UDim2.new(0,PANEL_W-PAD*2,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.new(0,PAD,0,PAD/2),
        BackgroundTransparency=1, ZIndex=6
    }, listPanel)
    mk("UIListLayout",{Padding=UDim.new(0,GAP), SortOrder=Enum.SortOrder.LayoutOrder}, listInner)

    local itemRefs = {}
    for i, fd in ipairs(FONTS) do
        local isSelected = (i == selectedFont)

        local item = mk("Frame",{
            Size=UDim2.new(0,PANEL_W-PAD*2,0,ITEM_H),
            BackgroundColor3=isSelected and Color3.fromRGB(30,30,30) or Color3.fromRGB(20,20,20),
            BorderSizePixel=0, ZIndex=7, LayoutOrder=i
        }, listInner)
        rnd(5, item)
        local stroke = mk("UIStroke",{
            Color=isSelected and C.RED or C.LINE,
            Thickness=1, Transparency=isSelected and 0.3 or 0.7
        }, item)

        local lbl = mk("TextLabel",{
            Text=fd.name, Font=fd.font, TextSize=10,
            TextColor3=isSelected and C.WHITE or C.GRAY,
            BackgroundTransparency=1,
            Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,8,0,0),
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8
        }, item)

        local dot = mk("Frame",{
            Size=UDim2.new(0,5,0,5),
            Position=UDim2.new(1,-12,0.5,-2),
            BackgroundColor3=C.RED, BorderSizePixel=0, ZIndex=8
        }, item)
        rnd(3, dot)
        dot.BackgroundTransparency = isSelected and 0 or 1
        table.insert(cfg.accentElements, {el=dot, prop="BackgroundColor3"})

        local hitBtn = mk("TextButton",{
            Text="", BackgroundTransparency=1,
            Size=UDim2.new(1,0,1,0), ZIndex=9, AutoButtonColor=false
        }, item)

        itemRefs[i] = {item=item, lbl=lbl, dot=dot, stroke=stroke}

        hitBtn.MouseEnter:Connect(function()
            if i ~= selectedFont then
                tw(item,.1,{BackgroundColor3=Color3.fromRGB(25,25,25)})
                tw(lbl,.1,{TextColor3=C.WHITE})
            end
        end)
        hitBtn.MouseLeave:Connect(function()
            if i ~= selectedFont then
                tw(item,.1,{BackgroundColor3=Color3.fromRGB(20,20,20)})
                tw(lbl,.1,{TextColor3=C.GRAY})
            end
        end)

        hitBtn.MouseButton1Click:Connect(function()
            local prev = itemRefs[selectedFont]
            tw(prev.item,.15,{BackgroundColor3=Color3.fromRGB(20,20,20)})
            tw(prev.stroke,.15,{Color=C.LINE, Transparency=0.7})
            tw(prev.lbl,.15,{TextColor3=C.GRAY})
            prev.dot.BackgroundTransparency = 1

            selectedFont = i
            tw(item,.15,{BackgroundColor3=Color3.fromRGB(30,30,30)})
            tw(stroke,.15,{Color=C.RED, Transparency=0.3})
            tw(lbl,.15,{TextColor3=C.WHITE})
            dot.BackgroundTransparency = 0

            selLbl.Text = fd.name
            selLbl.Font = fd.font

            if checked then
                cfg.titles[1].Font = fd.font
                cfg.titles[3].Font = fd.font
                for _, t in ipairs(cfg.navT) do t.lbl.Font = fd.font end
            end
        end)
    end

    checkBtn.MouseButton1Click:Connect(function()
        checked = not checked
        tw(checkBg,.15,{BackgroundColor3=checked and Color3.fromRGB(28,28,28) or C.MUTED})
        tw(checkMark,.15,{TextTransparency=checked and 0 or 1})
        if checked then
            local fd = FONTS[selectedFont]
            cfg.titles[1].Font = fd.font
            cfg.titles[3].Font = fd.font
            for _, t in ipairs(cfg.navT) do t.lbl.Font = fd.font end
        else
            cfg.titles[1].Font = Enum.Font.GothamBold
            cfg.titles[3].Font = Enum.Font.Gotham
            for _, t in ipairs(cfg.navT) do t.lbl.Font = Enum.Font.GothamSemibold end
        end
    end)

    selBtn.MouseButton1Click:Connect(function()
        if panelAnim then return end
        panelAnim = true; panelOpen = not panelOpen
        if panelOpen then
            arrowLbl.Text = "▲"
            tw(listPanel,.3,{Size=UDim2.new(0,PANEL_W,0,TOTAL_ITEMS_H)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        else
            arrowLbl.Text = "▼"
            tw(listPanel,.25,{Size=UDim2.new(0,PANEL_W,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        end
        task.delay(.3,function() panelAnim=false end)
    end)
end

-- ============================================
-- INIT SETTINGS PAGE
-- ============================================
function Settings.init(page)
    init()
    
    local colorPanel = MiniPanel(page, "Panel Color", 216)
    CreateAccentPicker(colorPanel)
    
    local fontPanel = MiniPanel(page, "Font", 216)
    CreateFontPicker(fontPanel)
end

return Settings