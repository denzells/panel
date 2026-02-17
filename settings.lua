-- settings.lua - PanelBase

local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Settings = {}

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

Settings.Layout = {
    WW   = 540,
    WH   = 440,
    TH   = 42,
    NW   = 320,
    NH   = 46,
    NGAP = 14,
    BH   = 440 - 42,
}

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

    local accentEls = {}
    local so = 0
    local function SO() so = so + 1; return so end

    local function makeCheckbox(parent, zBase)
        zBase = zBase or 5
        local bg = mk("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            BorderSizePixel = 0, ZIndex = zBase,
        }, parent)
        rnd(3, bg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, bg)
        local mark = mk("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundColor3 = C.RED,
            BorderSizePixel = 0, ZIndex = zBase + 1,
            BackgroundTransparency = 1,
        }, bg)
        rnd(2, mark)
        table.insert(accentEls, { el = mark, prop = "BackgroundColor3" })
        local btn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = zBase + 2, AutoButtonColor = false,
        }, bg)
        return bg, mark, btn
    end

    local function makeSectionLabel(parent, text, lo)
        local row = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1, LayoutOrder = lo or SO(),
        }, parent)
        mk("TextLabel", {
            Text = text, Font = Enum.Font.GothamBold, TextSize = 9,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row)
        return row
    end

    local function makeRow(parent, labelText, lo)
        local row = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1, LayoutOrder = lo or SO(),
        }, parent)
        mk("TextLabel", {
            Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row)
        return row
    end

    local function MiniPanel(parent, title, fixedW)
        local panel = mk("Frame", {
            Size             = fixedW and UDim2.new(0, fixedW, 0, 0) or UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.PANEL,
            BorderSizePixel  = 0,
            LayoutOrder      = SO(),
        }, parent)
        rnd(8, panel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, panel)
        mk("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, panel)
        mk("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 32),
            BackgroundColor3 = C.LINE, BackgroundTransparency = 0.4,
            BorderSizePixel = 0, ZIndex = 4,
        }, panel)
        local content = mk("Frame", {
            Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 40),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        }, panel)
        mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, content)
        mk("UIPadding", { PaddingBottom = UDim.new(0, 10) }, panel)
        return content
    end

    local function applyAccent(col)
        C.RED = col
        rdot.BackgroundColor3 = col
        title2.TextColor3     = col
        for i, t in ipairs(navT) do
            if i == actNavFn() then tw(t.img, .2, { ImageColor3 = col }) end
        end
        for _, e in ipairs(accentEls) do
            pcall(function() e.el[e.prop] = col end)
        end
    end

    local function CreateAccentPicker(parent)
        makeSectionLabel(parent, "ACCENT COLOR", SO())
        local originalColor = C.RED
        local currentH, currentS, currentV = Color3.toHSV(C.RED)
        local pickerOpen, pickerAnim = false, false
        local PW, SV, HW, PAD = 228, 118, 12, 8
        local PREVW, APPH = PW - SV - HW - PAD * 3, 20
        local CONTENTH, TOTALH = SV + PAD + APPH, SV + PAD + APPH + PAD * 2

        local root = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, parent)
        mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, root)

        local row1 = makeRow(root, "Accent Color", 1)
        local chkBg, chkMark, chkBtn = makeCheckbox(row1, 5)
        chkBg.Position = UDim2.new(1, -18, 0.5, -9)
        local checked = false

        local rgbModeOn, rgbHue, rgbConn = false, 0, nil
        local function stopRGBMode()
            if rgbConn then rgbConn:Disconnect(); rgbConn = nil end
        end
        local function startRGBMode()
            stopRGBMode()
            rgbConn = RunService.RenderStepped:Connect(function(dt)
                rgbHue = (rgbHue + dt * 0.4) % 1
                applyAccent(Color3.fromHSV(rgbHue, 1, 1))
            end)
        end

        local row2 = makeRow(root, "RGB Mode", 2)
        local ledBadge = mk("Frame", {
            Size = UDim2.new(0, 28, 0, 13), Position = UDim2.new(0, 76, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(22, 22, 22), BorderSizePixel = 0, ZIndex = 6,
        }, row2)
        rnd(4, ledBadge)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, ledBadge)
        mk("TextLabel", {
            Text = "LED", Font = Enum.Font.GothamBold, TextSize = 7,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 7,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, ledBadge)

        local rgbChkBg, rgbChkMark, rgbChkBtn = makeCheckbox(row2, 5)
        rgbChkBg.Position = UDim2.new(1, -18, 0.5, -9)

        rgbChkBtn.MouseButton1Click:Connect(function()
            rgbModeOn = not rgbModeOn
            tw(rgbChkMark, .15, { BackgroundTransparency = rgbModeOn and 0 or 1 })
            tw(rgbChkBg, .15, { BackgroundColor3 = rgbModeOn and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22) })
            if rgbModeOn then
                checked = false
                tw(chkMark, .15, { BackgroundTransparency = 1 })
                tw(chkBg, .15, { BackgroundColor3 = Color3.fromRGB(22,22,22) })
                startRGBMode()
            else
                stopRGBMode()
                applyAccent(originalColor)
            end
        end)

        local palBtn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28), BorderSizePixel = 0,
            ZIndex = 5, AutoButtonColor = false, LayoutOrder = 3,
        }, root)
        local palBg = mk("Frame", {
            Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderSizePixel = 0, ZIndex = 4,
        }, palBtn)
        rnd(6, palBg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, palBg)

        local prevDot = mk("Frame", {
            Size = UDim2.new(0,12,0,12), Position = UDim2.new(0,8,0.5,-6),
            BackgroundColor3 = C.RED, BorderSizePixel = 0, ZIndex = 6,
        }, palBg)
        rnd(6, prevDot)
        table.insert(accentEls, { el = prevDot, prop = "BackgroundColor3" })

        mk("TextLabel", {
            Text = "Color Palette", Font = Enum.Font.GothamSemibold, TextSize = 9,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1, -46, 1, 0), Position = UDim2.new(0, 26, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, palBg)

        local arrowC = mk("TextLabel", {
            Text = "▼", Font = Enum.Font.Code, TextSize = 7,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(0,14,1,0), Position = UDim2.new(1,-16,0,0),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
        }, palBg)

        palBtn.MouseEnter:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(25,25,25)}) end)
        palBtn.MouseLeave:Connect(function() tw(palBg,.1,{BackgroundColor3=Color3.fromRGB(20,20,20)}) end)

        local pickerPanel = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(16,16,16),
            BorderSizePixel = 0, ZIndex = 5, ClipsDescendants = true, LayoutOrder = 4,
        }, root)
        rnd(8, pickerPanel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, pickerPanel)

        local inner = mk("Frame", {
            Size = UDim2.new(0, PW - PAD*2, 0, CONTENTH),
            Position = UDim2.new(0, PAD, 0, PAD),
            BackgroundTransparency = 1, ZIndex = 6,
        }, pickerPanel)

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

        local rx = SV + HW + PAD*2
        local bigPrev = mk("Frame", {
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

        local applyBtn = mk("TextButton", {
            Text="Apply Color", Font=Enum.Font.GothamSemibold, TextSize=9,
            TextColor3=Color3.fromHSV(currentH,currentS,currentV),
            BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0, ZIndex=7,
            Size=UDim2.new(1,0,0,APPH), Position=UDim2.new(0,0,0,SV+PAD), AutoButtonColor=false,
        }, inner)
        rnd(5,applyBtn); mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.3},applyBtn)
        applyBtn.MouseEnter:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(36,36,36)}) end)
        applyBtn.MouseLeave:Connect(function() tw(applyBtn,.1,{BackgroundColor3=Color3.fromRGB(28,28,28)}) end)

        local function refreshPicker()
            local col = Color3.fromHSV(currentH, currentS, currentV)
            svSq.BackgroundColor3    = Color3.fromHSV(currentH,1,1)
            bigPrev.BackgroundColor3 = col
            prevDot.BackgroundColor3 = col
            hexLbl.Text              = toHex(col)
            applyBtn.TextColor3      = col
            svCur.Position  = UDim2.new(0, currentS*SV - 5, 0, (1-currentV)*SV - 5)
            hueCur.Position = UDim2.new(0, SV+PAD-2, 0, currentH*SV - 1)
        end

        chkBtn.MouseButton1Click:Connect(function()
            checked = not checked
            tw(chkMark,.15,{BackgroundTransparency = checked and 0 or 1})
            tw(chkBg,.15,{BackgroundColor3 = checked and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22)})
            if checked then
                if rgbModeOn then
                    rgbModeOn = false; stopRGBMode()
                    tw(rgbChkMark,.15,{BackgroundTransparency=1})
                    tw(rgbChkBg,.15,{BackgroundColor3=Color3.fromRGB(22,22,22)})
                end
                applyAccent(Color3.fromHSV(currentH,currentS,currentV))
            else
                applyAccent(originalColor)
            end
        end)

        applyBtn.MouseButton1Click:Connect(function()
            if not checked then
                tw(chkBg,.1,{BackgroundColor3=Color3.fromRGB(80,40,40)})
                task.delay(.2,function() tw(chkBg,.1,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end)
                return
            end
            if rgbModeOn then
                rgbModeOn=false; stopRGBMode()
                tw(rgbChkMark,.15,{BackgroundTransparency=1})
                tw(rgbChkBg,.15,{BackgroundColor3=Color3.fromRGB(22,22,22)})
            end
            local newCol = Color3.fromHSV(currentH,currentS,currentV)
            applyAccent(newCol)
            tw(applyBtn,.08,{TextColor3=Color3.fromRGB(80,220,80)})
            task.delay(.6,function() tw(applyBtn,.25,{TextColor3=newCol}) end)
        end)

        local svDrag = false
        svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
        RunService.RenderStepped:Connect(function()
            if not svDrag then return end
            local mp = UIS:GetMouseLocation()
            currentS = math.clamp((mp.X - svHit.AbsolutePosition.X)/svHit.AbsoluteSize.X,0,1)
            currentV = 1-math.clamp((mp.Y - svHit.AbsolutePosition.Y)/svHit.AbsoluteSize.Y,0,1)
            refreshPicker()
        end)

        local hueDrag = false
        hueHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
        RunService.RenderStepped:Connect(function()
            if not hueDrag then return end
            local mp = UIS:GetMouseLocation()
            currentH = math.clamp((mp.Y - hueHit.AbsolutePosition.Y)/hueHit.AbsoluteSize.Y,0,1)
            refreshPicker()
        end)

        palBtn.MouseButton1Click:Connect(function()
            if pickerAnim then return end
            pickerAnim=true; pickerOpen=not pickerOpen
            if pickerOpen then
                arrowC.Text="▲"
                tw(pickerPanel,.3,{Size=UDim2.new(1,0,0,TOTALH)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            else
                arrowC.Text="▼"
                tw(pickerPanel,.25,{Size=UDim2.new(1,0,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
            end
            task.delay(.3,function() pickerAnim=false end)
        end)

        refreshPicker()
    end

    local FONTS = {
        { name="Gotham",     font=Enum.Font.Gotham     },
        { name="GothamBold", font=Enum.Font.GothamBold },
        { name="Code",       font=Enum.Font.Code       },
        { name="Ubuntu",     font=Enum.Font.Ubuntu     },
        { name="Arcade",     font=Enum.Font.Arcade     },
        { name="Bangers",    font=Enum.Font.Bangers    },
    }

    local function CreateFontPicker(parent)
        makeSectionLabel(parent, "FONT", SO())
        local PW, ITEMH, GAPF = 228, 26, 3
        local selFont, checked, panOpen, panAnim = 1, false, false, false
        local LISTHTOTAL, PAD = #FONTS * ITEMH + (#FONTS-1)*GAPF + 16, 8

        local root = mk("Frame", {
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, LayoutOrder=SO(),
        }, parent)
        mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},root)

        local row1 = makeRow(root, "Custom Font", 1)
        local chkBg, chkMark, chkBtn = makeCheckbox(row1, 5)
        chkBg.Position = UDim2.new(1, -18, 0.5, -9)

        local selBtn = mk("TextButton",{
            Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),
            BorderSizePixel=0,ZIndex=5,AutoButtonColor=false,LayoutOrder=2,
        },root)
        local selBg = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,ZIndex=4},selBtn)
        rnd(6,selBg)
        mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.4},selBg)

        local fontIcon = mk("TextLabel",{
            Text="Aa",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.RED,
            BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,8,0,0),
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6,
        },selBg)
        table.insert(accentEls,{el=fontIcon,prop="TextColor3"})

        local selLbl = mk("TextLabel",{
            Text=FONTS[selFont].name,Font=FONTS[selFont].font,TextSize=10,
            TextColor3=C.WHITE,BackgroundTransparency=1,
            Size=UDim2.new(1,-46,1,0),Position=UDim2.new(0,30,0,0),
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },selBg)

        local arrowF = mk("TextLabel",{
            Text="▼",Font=Enum.Font.Code,TextSize=7,TextColor3=C.GRAY,
            BackgroundTransparency=1,Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-16,0,0),
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6,
        },selBg)

        selBtn.MouseEnter:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(25,25,25)}) end)
        selBtn.MouseLeave:Connect(function() tw(selBg,.1,{BackgroundColor3=Color3.fromRGB(20,20,20)}) end)

        local listPanel = mk("Frame",{
            Size=UDim2.new(1,0,0,0),BackgroundColor3=Color3.fromRGB(16,16,16),
            BorderSizePixel=0,ZIndex=5,ClipsDescendants=true,LayoutOrder=3,
        },root)
        rnd(8,listPanel)
        mk("UIStroke",{Color=C.LINE,Thickness=1,Transparency=0.5},listPanel)

        local listInner = mk("Frame",{
            Size=UDim2.new(1,-PAD*2,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            Position=UDim2.new(0,PAD,0,PAD/2),BackgroundTransparency=1,ZIndex=6,
        },listPanel)
        mk("UIListLayout",{Padding=UDim.new(0,GAPF),SortOrder=Enum.SortOrder.LayoutOrder},listInner)

        local itemRefs = {}
        for i, fd in ipairs(FONTS) do
            local isSel = (i==selFont)
            local item = mk("Frame",{
                Size=UDim2.new(1,0,0,ITEMH),
                BackgroundColor3=isSel and Color3.fromRGB(28,28,28) or Color3.fromRGB(20,20,20),
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
                if i~=selFont then tw(item,.1,{BackgroundColor3=Color3.fromRGB(24,24,24)}); tw(lbl,.1,{TextColor3=C.WHITE}) end
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
                selFont=i
                tw(item,.15,{BackgroundColor3=Color3.fromRGB(28,28,28)})
                tw(stroke,.15,{Color=C.RED,Transparency=0.3})
                tw(lbl,.15,{TextColor3=C.WHITE})
                dot.BackgroundTransparency=0
                selLbl.Text=fd.name; selLbl.Font=fd.font
                if checked then
                    title1.Font=fd.font; title3.Font=fd.font
                    for _,t in ipairs(navT) do t.lbl.Font=fd.font end
                end
            end)
        end

        chkBtn.MouseButton1Click:Connect(function()
            checked=not checked
            tw(chkMark,.15,{BackgroundTransparency=checked and 0 or 1})
            tw(chkBg,.15,{BackgroundColor3=checked and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22)})
            if checked then
                local fd=FONTS[selFont]
                title1.Font=fd.font; title3.Font=fd.font
                for _,t in ipairs(navT) do t.lbl.Font=fd.font end
            else
                title1.Font=Enum.Font.GothamBold; title3.Font=Enum.Font.Gotham
                for _,t in ipairs(navT) do t.lbl.Font=Enum.Font.GothamSemibold end
            end
        end)

        selBtn.MouseButton1Click:Connect(function()
            if panAnim then return end
            panAnim=true; panOpen=not panOpen
            if panOpen then
                arrowF.Text="▲"
                tw(listPanel,.3,{Size=UDim2.new(1,0,0,LISTHTOTAL)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
            else
                arrowF.Text="▼"
                tw(listPanel,.25,{Size=UDim2.new(1,0,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
            end
            task.delay(.3,function() panAnim=false end)
        end)
    end

    local function CreateKeybinds(parent)
        local root = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, parent)
        mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, root)

        local justAssignedMin, justAssignedClose = false, false

        local function keyName(kc)
            local names = {
                [Enum.KeyCode.LeftControl]  = "L.Ctrl",
                [Enum.KeyCode.RightControl] = "R.Ctrl",
                [Enum.KeyCode.LeftShift]    = "L.Shft",
                [Enum.KeyCode.RightShift]   = "R.Shft",
                [Enum.KeyCode.LeftAlt]      = "L.Alt",
                [Enum.KeyCode.RightAlt]     = "R.Alt",
                [Enum.KeyCode.Tab]          = "Tab",
                [Enum.KeyCode.CapsLock]     = "Caps",
                [Enum.KeyCode.Insert]       = "Ins",
                [Enum.KeyCode.Home]         = "Home",
                [Enum.KeyCode.Delete]       = "Del",
                [Enum.KeyCode.End]          = "End",
                [Enum.KeyCode.Backspace]    = "Back",
                [Enum.KeyCode.Return]       = "Enter",
                [Enum.KeyCode.Escape]       = "Esc",
                [Enum.KeyCode.Space]        = "Space",
                [Enum.KeyCode.PageUp]       = "PgUp",
                [Enum.KeyCode.PageDown]     = "PgDn",
            }
            if names[kc] then return names[kc] end
            local raw = tostring(kc):gsub("Enum%.KeyCode%.", "")
            if raw:match("^[A-Z]$") or raw:match("^[0-9]$") then return raw end
            if #raw <= 6 then return raw else return raw:sub(1,5).."." end
        end

        local function makeKeyRow(parent, labelText, defaultKey, lo)
            local row = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1, LayoutOrder = lo or SO(),
            }, parent)

            mk("TextLabel", {
                Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 10,
                TextColor3 = C.WHITE, BackgroundTransparency = 1,
                Size = UDim2.new(1, -52, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
            }, row)

            local keyBg = mk("Frame", {
                Size = UDim2.new(0, 46, 0, 20),
                Position = UDim2.new(1, -46, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                BorderSizePixel = 0, ZIndex = 5,
            }, row)
            rnd(5, keyBg)
            mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, keyBg)

            local keyLbl = mk("TextLabel", {
                Text = keyName(defaultKey), Font = Enum.Font.GothamBold, TextSize = 9,
                TextColor3 = C.WHITE, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0), ZIndex = 6,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, keyBg)

            local keyBtn = mk("TextButton", {
                Text = "", BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0), ZIndex = 7, AutoButtonColor = false,
            }, keyBg)

            keyBtn.MouseEnter:Connect(function() tw(keyBg, .1, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }) end)
            keyBtn.MouseLeave:Connect(function() tw(keyBg, .1, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }) end)

            return keyBg, keyLbl, keyBtn
        end

        makeSectionLabel(root, "TOGGLE VISIBILITY", 1)
        local minKeyBg, minKeyLbl, minKeyBtn = makeKeyRow(root, "Minimize Key", Enum.KeyCode.LeftControl, 2)
        local minListening, currentMinKey, minListenConn = false, Enum.KeyCode.LeftControl, nil

        local function startMinListening()
            if minListenConn then minListenConn:Disconnect() end
            minListenConn = UIS.InputBegan:Connect(function(input, gpe)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                minListening = false
                currentMinKey = input.KeyCode
                justAssignedMin = true
                task.delay(0.1, function() justAssignedMin = false end)
                if minListenConn then minListenConn:Disconnect(); minListenConn = nil end
                minKeyLbl.Text = keyName(currentMinKey)
                minKeyLbl.TextColor3 = C.WHITE
                tw(minKeyBg, .08, { BackgroundColor3 = Color3.fromRGB(20, 50, 20) })
                task.delay(.35, function() tw(minKeyBg, .2, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }) end)
            end)
        end

        minKeyBtn.MouseButton1Click:Connect(function()
            if minListening then return end
            minListening = true
            tw(minKeyBg, .1, { BackgroundColor3 = Color3.fromRGB(50, 35, 10) })
            minKeyLbl.Text = "···"
            minKeyLbl.TextColor3 = C.GRAY
            startMinListening()
        end)

        makeSectionLabel(root, "CLOSE PANEL", 3)
        local closeKeyBg, closeKeyLbl, closeKeyBtn = makeKeyRow(root, "Close Key", Enum.KeyCode.LeftAlt, 4)
        local closeListening, currentCloseKey, closeListenConn = false, Enum.KeyCode.LeftAlt, nil

        local function startCloseListening()
            if closeListenConn then closeListenConn:Disconnect() end
            closeListenConn = UIS.InputBegan:Connect(function(input, gpe)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                closeListening = false
                currentCloseKey = input.KeyCode
                justAssignedClose = true
                task.delay(0.1, function() justAssignedClose = false end)
                if closeListenConn then closeListenConn:Disconnect(); closeListenConn = nil end
                closeKeyLbl.Text = keyName(currentCloseKey)
                closeKeyLbl.TextColor3 = C.WHITE
                tw(closeKeyBg, .08, { BackgroundColor3 = Color3.fromRGB(20, 50, 20) })
                task.delay(.35, function() tw(closeKeyBg, .2, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }) end)
            end)
        end

        closeKeyBtn.MouseButton1Click:Connect(function()
            if closeListening then return end
            closeListening = true
            tw(closeKeyBg, .1, { BackgroundColor3 = Color3.fromRGB(50, 35, 10) })
            closeKeyLbl.Text = "···"
            closeKeyLbl.TextColor3 = C.GRAY
            startCloseListening()
        end)

        local toggleConn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe or minListening or closeListening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == currentMinKey and not justAssignedMin then
                    if r.anim and r.anim.toggleMinimize then r.anim.toggleMinimize() end
                end
                if input.KeyCode == currentCloseKey and not justAssignedClose then
                    if r.anim and r.anim.doClose then r.anim.doClose() end
                end
            end
        end)

        root.Destroying:Connect(function()
            if minListenConn then minListenConn:Disconnect() end
            if closeListenConn then closeListenConn:Disconnect() end
            if toggleConn then toggleConn:Disconnect() end
        end)
    end

    local function CreateSessionInfo(parent)
        local SAVE_FILE = "serios_saved.json"
        local canRead = typeof(readfile) == "function" and typeof(isfile) == "function"

        local function loadSessionInfo()
            if not canRead then return "N/A", "N/A", "N/A" end
            local ok, result = pcall(function()
                if not isfile(SAVE_FILE) then return nil end
                return HttpService:JSONDecode(readfile(SAVE_FILE))
            end)
            if ok and result and result.username and result.key then
                return result.username, result.key, result.expiry or "N/A"
            end
            return "Not Found", "Not Found", "N/A"
        end

        local username, key, expiry = loadSessionInfo()
        
        local function formatExpiry(exp)
            if exp == "N/A" or exp == "Not Found" then return "N/A" end
            if type(exp) == "number" then
                local date = os.date("*t", exp)
                return string.format("%02d/%02d/%04d", date.day, date.month, date.year)
            end
            return tostring(exp)
        end
        
        local expiryText = formatExpiry(expiry)
        makeSectionLabel(parent, "SESSION INFORMATION", SO())
        
        local root = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, parent)
        mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, root)

        local gridRow = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, LayoutOrder = 1,
        }, root)
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        }, gridRow)

        local function makeCompactField(parent, label, value, icon, isPassword, lo)
            local container = mk("Frame", {
                Size = UDim2.new(0.33, -4, 1, 0),
                BackgroundTransparency = 1, LayoutOrder = lo,
            }, parent)

            mk("TextLabel", {
                Text = label, Font = Enum.Font.GothamBold, TextSize = 8,
                TextColor3 = C.GRAY, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
            }, container)

            local box = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 12),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                BorderSizePixel = 0, ZIndex = 5,
            }, container)
            rnd(5, box)
            mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, box)

            if icon then
                local img = mk("ImageLabel", {
                    Image = icon, Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 7, 0.5, -7),
                    BackgroundTransparency = 1, ImageColor3 = C.RED, ZIndex = 6,
                }, box)
                table.insert(accentEls, { el = img, prop = "ImageColor3" })
            end

            local displayText = isPassword and string.rep("•", math.min(#value, 16)) or value
            local textLbl = mk("TextLabel", {
                Text = displayText, Font = Enum.Font.Code, TextSize = 8,
                TextColor3 = C.WHITE, BackgroundTransparency = 1,
                Size = UDim2.new(1, icon and -50 or -12, 1, 0),
                Position = UDim2.new(0, icon and 26 or 6, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
            }, box)

            if isPassword then
                local showKey = false
                local eyeBtn = mk("TextButton", {
                    Text = "👁", Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = C.GRAY, BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -22, 0.5, -10),
                    ZIndex = 7, AutoButtonColor = false,
                }, box)

                eyeBtn.MouseButton1Click:Connect(function()
                    showKey = not showKey
                    textLbl.Text = showKey and value or displayText
                    tw(eyeBtn, 0.1, { TextColor3 = showKey and C.RED or C.GRAY })
                end)

                eyeBtn.MouseEnter:Connect(function() 
                    if not showKey then tw(eyeBtn, 0.1, { TextColor3 = C.WHITE }) end
                end)
                eyeBtn.MouseLeave:Connect(function() 
                    if not showKey then tw(eyeBtn, 0.1, { TextColor3 = C.GRAY }) end
                end)
            end
        end

        makeCompactField(gridRow, "USERNAME", username, "rbxassetid://75066739039083", false, 1)
        makeCompactField(gridRow, "KEY", key, "rbxassetid://126448589402910", true, 2)
        makeCompactField(gridRow, "EXPIRY", expiryText, nil, false, 3)

        local statusBadge = mk("Frame", {
            Size = UDim2.new(0, 80, 0, 18),
            BackgroundColor3 = Color3.fromRGB(18, 45, 18),
            BorderSizePixel = 0, ZIndex = 5, LayoutOrder = 2,
        }, root)
        rnd(5, statusBadge)
        mk("UIStroke", { Color = Color3.fromRGB(50, 200, 80), Thickness = 1, Transparency = 0.4 }, statusBadge)
        mk("TextLabel", {
            Text = "✓ Verified", Font = Enum.Font.GothamBold, TextSize = 8,
            TextColor3 = Color3.fromRGB(50, 200, 80),
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6, TextXAlignment = Enum.TextXAlignment.Center,
        }, statusBadge)
    end

    task.delay(1, function()
        local topRow = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, page)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, topRow)
        mk("UIListLayout", {
            FillDirection       = Enum.FillDirection.Horizontal,
            Padding             = UDim.new(0, 10),
            SortOrder           = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, topRow)

        local customPanel = MiniPanel(topRow, "Custom Panel", 248)
        CreateAccentPicker(customPanel)
        CreateFontPicker(customPanel)

        local keybindPanel = MiniPanel(topRow, "Keybinds", 248)
        CreateKeybinds(keybindPanel)

        local bottomRow = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = SO(),
        }, page)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, bottomRow)

        local sessionPanel = MiniPanel(bottomRow, "Info Sesion", nil)
        CreateSessionInfo(sessionPanel)
    end)
end

return Settings
