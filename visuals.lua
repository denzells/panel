-- ============================================================
-- visuals.lua  -  PanelBase | checktheblox
-- Pestaña: Visuals
-- ESP sin Drawing API — usa ScreenGui (indetectable por anti-cheats)
-- ============================================================
local Visuals = {}

function Visuals.build(page, r)
    local C          = r.C
    local mk         = r.mk
    local rnd        = r.rnd
    local tw         = r.tw

    local Players     = game:GetService("Players")
    local RunService  = game:GetService("RunService")
    local localPlayer = Players.LocalPlayer
    local camera      = workspace.CurrentCamera

    local so = 0
    local function SO() so = so + 1; return so end

    -- ── ESP settings ───────────────────────────────────────────────
    local POLICE_TEAM = "Metropolitan Police"
    local COLOR_ALL   = Color3.fromRGB(255, 255, 255)  -- blanco
    local COLOR_POL   = Color3.fromRGB(0,   140, 255)  -- azul

    local esp_all     = false   -- ESP para todos
    local esp_pol     = false   -- ESP solo policías
    local esp_names   = false   -- ESP nombres

    -- ── ESP Names — BillboardGui clonado de ReplicatedStorage ─────
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local nameTagsActive    = {}  -- [player] = BillboardGui

    local function removeNameTag(plr)
        local tag = nameTagsActive[plr]
        if tag then
            pcall(function() tag:Destroy() end)
            nameTagsActive[plr] = nil
        end
    end

    local function applyNameTag(plr)
        if plr == localPlayer then return end
        removeNameTag(plr)

        local character = plr.Character
        if not character then return end

        local head = character:FindFirstChild("Head")
        if not head then return end

        -- Intentamos clonar el UsernameGui original del juego
        local template = ReplicatedStorage:FindFirstChild("UsernameGui")
        local bill

        if template then
            bill = template:Clone()
            -- Nos aseguramos de que muestre el nombre correcto
            local lbl = bill:FindFirstChildWhichIsA("TextLabel", true)
            if lbl then
                lbl.Text           = plr.DisplayName
                lbl.TextColor3     = Color3.new(1, 1, 1)
                lbl.TextStrokeTransparency = 0.5
            end
        else
            -- Fallback: creamos uno propio si el template no existe
            bill = Instance.new("BillboardGui")
            bill.Size          = UDim2.new(0, 120, 0, 24)
            bill.StudsOffset   = Vector3.new(0, 3, 0)
            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = plr.DisplayName
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = 13
            lbl.TextColor3             = Color3.new(1, 1, 1)
            lbl.TextStrokeTransparency = 0.5
            lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
            lbl.Parent                 = bill
        end

        -- Clave: estas propiedades hacen que se vea siempre,
        -- detrás de paredes y a cualquier distancia
        bill.Name            = "ESP_NameTag"
        bill.AlwaysOnTop     = true          -- traspasa paredes
        bill.MaxDistance     = 9999          -- distancia ilimitada
        bill.LightInfluence  = 0
        bill.ResetOnSpawn    = false
        bill.Enabled         = true
        bill.Adornee         = head
        bill.Parent          = head

        nameTagsActive[plr] = bill
    end

    local function enableNames()
        esp_names = true
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                if plr.Character then
                    applyNameTag(plr)
                end
                -- reconecta si reaparece
                if not plr:FindFirstChild("_espNameConn") then
                    plr.CharacterAdded:Connect(function()
                        if esp_names then
                            task.wait()
                            applyNameTag(plr)
                        end
                    end)
                end
            end
        end
    end

    local function disableNames()
        esp_names = false
        for plr in pairs(nameTagsActive) do
            removeNameTag(plr)
        end
        nameTagsActive = {}
    end

    -- Limpia nombre cuando el jugador sale
    Players.PlayerRemoving:Connect(function(plr)
        removeNameTag(plr)
    end)

    -- ── ScreenGui overlay ──────────────────────────────────────────
    local espGui = Instance.new("ScreenGui")
    espGui.Name           = "ESP_Overlay"
    espGui.ResetOnSpawn   = false
    espGui.IgnoreGuiInset = true
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGui.Enabled        = false
    espGui.Parent         = localPlayer:WaitForChild("PlayerGui")

    local THICKNESS = 2

    local function makeLine(color)
        local f = Instance.new("Frame")
        f.AnchorPoint            = Vector2.new(0.5, 0.5)
        f.BorderSizePixel        = 0
        f.BackgroundColor3       = color or COLOR_ALL
        f.BackgroundTransparency = 0
        f.Visible                = false
        f.ZIndex                 = 10
        f.Parent                 = espGui
        return f
    end

    local function setLine(f, ax, ay, bx, by, color)
        local dx  = bx - ax
        local dy  = by - ay
        local len = math.sqrt(dx*dx + dy*dy)
        if len < 1 then f.Visible = false; return end
        f.Position         = UDim2.fromOffset((ax+bx)/2, (ay+by)/2)
        f.Size             = UDim2.fromOffset(len, THICKNESS)
        f.Rotation         = math.deg(math.atan2(dy, dx))
        f.BackgroundColor3 = color
        f.Visible          = true
    end

    local function hideLine(f)
        if f then f.Visible = false end
    end

    -- isPolice: determina si un jugador está en el equipo de policía
    local function isPolice(player)
        return player.Team ~= nil and player.Team.Name == POLICE_TEAM
    end

    -- ── Función de dibujo (acepta color) ──────────────────────────
    local function draw(player, character)
        local lines = {}

        -- pre-crea 14 líneas (suficiente para R15)
        for i = 1, 14 do lines[i] = makeLine(COLOR_ALL) end

        local connection
        connection = RunService.RenderStepped:Connect(function()

            -- Determinar qué color y si este jugador debe verse
            local police    = isPolice(player)
            local showAll   = esp_all  and not police   -- todos los NO-policías
            local showPol   = esp_pol  and police        -- solo policías
            local shouldDraw = showAll or showPol
            local lineColor  = police and COLOR_POL or COLOR_ALL

            -- Limpiar si no debe dibujarse o el personaje ya no existe
            if not shouldDraw
            or not workspace:FindFirstChild(character.Name)
            or not character
            or not character:FindFirstChild("HumanoidRootPart")
            or not character:FindFirstChild("Humanoid")
            or character.Humanoid.Health == 0 then

                for _, l in ipairs(lines) do hideLine(l) end

                if not player or not player.Parent then
                    connection:Disconnect()
                    for _, l in ipairs(lines) do l:Destroy() end
                end
                return
            end

            local rig = character.Humanoid.RigType
            local _, onScreen = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)

            if not onScreen then
                for _, l in ipairs(lines) do hideLine(l) end
                return
            end

            if rig == Enum.HumanoidRigType.R6 then
                local head     = camera:WorldToViewportPoint(character.Head.Position)
                local torso_up = camera:WorldToViewportPoint(character.Torso.Position + Vector3.new(0, 1, 0))
                local torso_dn = camera:WorldToViewportPoint(character.Torso.Position + Vector3.new(0,-1, 0))
                local leftarm  = camera:WorldToViewportPoint(character["Left Arm"].Position  + Vector3.new(0,-1,0))
                local rightarm = camera:WorldToViewportPoint(character["Right Arm"].Position + Vector3.new(0,-1,0))
                local leftleg  = camera:WorldToViewportPoint(character["Left Leg"].Position  + Vector3.new(0,-1,0))
                local rightleg = camera:WorldToViewportPoint(character["Right Leg"].Position + Vector3.new(0,-1,0))

                setLine(lines[1], head.X,     head.Y,     torso_up.X, torso_up.Y, lineColor)
                setLine(lines[2], torso_up.X, torso_up.Y, torso_dn.X, torso_dn.Y, lineColor)
                setLine(lines[3], torso_up.X, torso_up.Y, leftarm.X,  leftarm.Y,  lineColor)
                setLine(lines[4], torso_up.X, torso_up.Y, rightarm.X, rightarm.Y, lineColor)
                setLine(lines[5], torso_dn.X, torso_dn.Y, leftleg.X,  leftleg.Y,  lineColor)
                setLine(lines[6], torso_dn.X, torso_dn.Y, rightleg.X, rightleg.Y, lineColor)
                for i = 7, 14 do hideLine(lines[i]) end

            elseif rig == Enum.HumanoidRigType.R15 then
                local function v2(partName)
                    local part = character:FindFirstChild(partName)
                    if not part then return nil end
                    local p = camera:WorldToViewportPoint(part.Position)
                    return Vector2.new(p.X, p.Y)
                end

                local segs = {
                    { v2("Head"),          v2("UpperTorso")    },
                    { v2("UpperTorso"),    v2("LowerTorso")    },
                    { v2("LowerTorso"),    v2("LeftUpperLeg")  },
                    { v2("LeftUpperLeg"),  v2("LeftLowerLeg")  },
                    { v2("LeftLowerLeg"),  v2("LeftFoot")      },
                    { v2("LowerTorso"),    v2("RightUpperLeg") },
                    { v2("RightUpperLeg"), v2("RightLowerLeg") },
                    { v2("RightLowerLeg"), v2("RightFoot")     },
                    { v2("UpperTorso"),    v2("LeftUpperArm")  },
                    { v2("LeftUpperArm"),  v2("LeftLowerArm")  },
                    { v2("LeftLowerArm"),  v2("LeftHand")      },
                    { v2("UpperTorso"),    v2("RightUpperArm") },
                    { v2("RightUpperArm"), v2("RightLowerArm") },
                    { v2("RightLowerArm"), v2("RightHand")     },
                }

                for i, seg in ipairs(segs) do
                    local a, b = seg[1], seg[2]
                    if a and b then
                        setLine(lines[i], a.X, a.Y, b.X, b.Y, lineColor)
                    else
                        hideLine(lines[i])
                    end
                end
            end
        end)
    end

    -- ── Track jugadores ────────────────────────────────────────────
    local function playerAdded(player)
        if player == localPlayer then return end

        if player.Character then
            coroutine.wrap(draw)(player, player.Character)
        end

        player.CharacterAdded:Connect(function(character)
            coroutine.wrap(draw)(player, character)
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        playerAdded(plr)
    end

    Players.PlayerAdded:Connect(playerAdded)

    -- ── Construcción del panel UI ──────────────────────────────────

    -- Dimensiones idénticas a settings.lua
    local function makeSectionLabel(parent, text, lo)
        local row = mk("Frame", { Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, LayoutOrder = lo or SO() }, parent)
        mk("TextLabel", {
            Text = text, Font = Enum.Font.GothamBold, TextSize = 9,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row)
        return row
    end

    local function makeRow(parent, labelText, lo)
        local row = mk("Frame", { Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1, LayoutOrder = lo or SO() }, parent)
        mk("TextLabel", {
            Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1,-30,1,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, row)
        return row
    end

    local function makeCheckbox(parent, zBase)
        zBase = zBase or 5
        local bg = mk("Frame", {
            Size = UDim2.new(0,18,0,18), BackgroundColor3 = Color3.fromRGB(22,22,22),
            BorderSizePixel = 0, ZIndex = zBase,
        }, parent)
        rnd(3, bg)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.2 }, bg)
        local mark = mk("Frame", {
            Size = UDim2.new(0,10,0,10), Position = UDim2.new(0.5,-5,0.5,-5),
            BackgroundColor3 = C.RED, BorderSizePixel = 0, ZIndex = zBase+1,
            BackgroundTransparency = 1,
        }, bg)
        rnd(2, mark)
        local btn = mk("TextButton", {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0), ZIndex = zBase+2, AutoButtonColor = false,
        }, bg)
        return bg, mark, btn
    end

    -- MiniPanel idéntico al de settings.lua
    local function MiniPanel(parent, title)
        local panel = mk("Frame", {
            Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.PANEL, BorderSizePixel = 0, LayoutOrder = SO(),
        }, parent)
        rnd(8, panel)
        mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, panel)
        mk("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = C.WHITE, BackgroundTransparency = 1,
            Size = UDim2.new(1,-16,0,32), Position = UDim2.new(0,10,0,0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        }, panel)
        mk("Frame", {
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,32),
            BackgroundColor3 = C.LINE, BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 4,
        }, panel)
        local content = mk("Frame", {
            Size = UDim2.new(1,-20,0,0), Position = UDim2.new(0,10,0,40),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        }, panel)
        mk("UIListLayout", { Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder }, content)
        mk("UIPadding", { PaddingBottom = UDim.new(0,10) }, panel)
        return content
    end

    -- Layout igual que settings.lua
    if not page:FindFirstChildOfClass("UIListLayout") then
        mk("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    end
    if not page:FindFirstChildOfClass("UIPadding") then
        mk("UIPadding", {
            PaddingTop    = UDim.new(0,10),
            PaddingBottom = UDim.new(0,10),
            PaddingLeft   = UDim.new(0,10),
            PaddingRight  = UDim.new(0,10),
        }, page)
    end

    -- topRow horizontal igual que settings.lua → panel ocupa 50% del ancho
    local topRow = mk("Frame", {
        Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = SO(),
    }, page)
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0,10),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, topRow)

    local visionPanel = MiniPanel(topRow, "Character Vision")
    -- Mismo tamaño que Custom Panel en settings.lua
    visionPanel.Parent.Size             = UDim2.new(0.5,-5,0,0)
    visionPanel.Parent.AutomaticSize    = Enum.AutomaticSize.Y

    mk("ImageLabel", {
        Image = "rbxassetid://79986513204084",
        Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-26,0,7),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(70,70,70), ZIndex = 6,
    }, visionPanel.Parent)

    makeSectionLabel(visionPanel, "ESP", SO())

    -- Fila: ESP ALL (todos los jugadores, sigue el color accent)
    local espAllRow = makeRow(visionPanel, "ESP All", SO())
    local espAllBg, espAllMark, espAllBtn = makeCheckbox(espAllRow, 5)
    espAllBg.Position = UDim2.new(1,-18,0.5,-9)
    espAllMark.BackgroundColor3 = C.RED

    -- Sincroniza el color del mark con el accent de settings sin tocar otros scripts
    RunService.Heartbeat:Connect(function()
        espAllMark.BackgroundColor3 = C.RED
    end)

    espAllBtn.MouseButton1Click:Connect(function()
        esp_all = not esp_all
        espGui.Enabled = esp_all or esp_pol
        tw(espAllMark, 0.15, { BackgroundTransparency = esp_all and 0 or 1 })
        tw(espAllBg,   0.15, { BackgroundColor3 = esp_all and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22) })
    end)

    -- Fila: ESP Polices (Metropolitan Police, esqueleto azul)
    local espPolRow = makeRow(visionPanel, "ESP Polices", SO())

    local espPolBg, espPolMark, espPolBtn = makeCheckbox(espPolRow, 5)
    espPolBg.Position = UDim2.new(1,-18,0.5,-9)
    espPolMark.BackgroundColor3 = C.RED

    RunService.Heartbeat:Connect(function()
        espPolMark.BackgroundColor3 = C.RED
    end)

    espPolBtn.MouseButton1Click:Connect(function()
        esp_pol = not esp_pol
        espGui.Enabled = esp_all or esp_pol
        tw(espPolMark, 0.15, { BackgroundTransparency = esp_pol and 0 or 1 })
        tw(espPolBg,   0.15, { BackgroundColor3 = esp_pol and Color3.fromRGB(18,28,45) or Color3.fromRGB(22,22,22) })
    end)

    -- Fila: ESP Names
    local espNamesRow = makeRow(visionPanel, "ESP Names", SO())
    local espNamesBg, espNamesMark, espNamesBtn = makeCheckbox(espNamesRow, 5)
    espNamesBg.Position = UDim2.new(1,-18,0.5,-9)
    espNamesMark.BackgroundColor3 = C.RED

    RunService.Heartbeat:Connect(function()
        espNamesMark.BackgroundColor3 = C.RED
    end)

    espNamesBtn.MouseButton1Click:Connect(function()
        esp_names = not esp_names
        tw(espNamesMark, 0.15, { BackgroundTransparency = esp_names and 0 or 1 })
        tw(espNamesBg,   0.15, { BackgroundColor3 = esp_names and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22) })
        if esp_names then enableNames() else disableNames() end
    end)

    -- Descripción
    local descRow = mk("Frame", {
        Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, LayoutOrder = SO()
    }, visionPanel)

    local descBox = mk("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(16,16,16),
        BorderSizePixel = 0, ZIndex = 4,
    }, descRow)
    rnd(6, descBox)
    mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.5 }, descBox)
    mk("TextLabel", {
        Text = "Dibuja el esqueleto de todos los jugadores en pantalla.",
        Font = Enum.Font.Gotham, TextSize = 8,
        TextColor3 = C.GRAY, BackgroundTransparency = 1,
        Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,8,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 5,
    }, descBox)

    -- ── Panel derecho: Custom Values ───────────────────────────────
    local customPanel = MiniPanel(topRow, "Custom Values")
    customPanel.Parent.Size          = UDim2.new(0.5,-5,0,0)
    customPanel.Parent.AutomaticSize = Enum.AutomaticSize.Y

    makeSectionLabel(customPanel, "PLAYER", SO())

    -- Fila: Custom First Name (checkbox)
    local fnRow = makeRow(customPanel, "Custom First Name", SO())
    local fnBg, fnMark, fnBtn = makeCheckbox(fnRow, 5)
    fnBg.Position = UDim2.new(1,-18,0.5,-9)
    fnMark.BackgroundColor3 = C.RED
    RunService.Heartbeat:Connect(function()
        fnMark.BackgroundColor3 = C.RED
    end)

    local fnActive = false

    -- TextBox para ingresar el nombre
    local tbRow = mk("Frame", {
        Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, LayoutOrder = SO()
    }, customPanel)

    local tbBg = mk("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(16,16,16),
        BorderSizePixel = 0, ZIndex = 4,
    }, tbRow)
    rnd(6, tbBg)
    mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, tbBg)

    -- Placeholder label
    local placeholder = mk("TextLabel", {
        Text = "Enter first name...",
        Font = Enum.Font.Gotham, TextSize = 9,
        TextColor3 = C.GRAY, BackgroundTransparency = 1,
        Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,8,0,0),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
    }, tbBg)

    local tbInput = mk("TextBox", {
        Text = "", Font = Enum.Font.GothamSemibold, TextSize = 9,
        TextColor3 = C.WHITE, BackgroundTransparency = 1,
        PlaceholderText = "", ClearTextOnFocus = false,
        Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,8,0,0),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
    }, tbBg)

    -- Oculta placeholder cuando hay texto
    tbInput:GetPropertyChangedSignal("Text"):Connect(function()
        placeholder.Visible = tbInput.Text == ""
    end)

    -- Botón Apply dentro del textbox
    local applyBtn = mk("TextButton", {
        Text = "✓", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.GRAY, BackgroundColor3 = Color3.fromRGB(22,22,22),
        BorderSizePixel = 0, ZIndex = 7, AutoButtonColor = false,
        Size = UDim2.new(0,24,0,20), Position = UDim2.new(1,-28,0.5,-10),
    }, tbBg)
    rnd(4, applyBtn)
    mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0.4 }, applyBtn)

    applyBtn.MouseEnter:Connect(function() tw(applyBtn, 0.1, { TextColor3 = C.WHITE }) end)
    applyBtn.MouseLeave:Connect(function() tw(applyBtn, 0.1, { TextColor3 = C.GRAY }) end)

    -- Función que aplica el nombre al StringValue del LocalPlayer
    local function applyFirstName(name)
        if not fnActive then return end
        if name == "" then return end

        -- Busca directamente en el Player: localPlayer > Characterstats > FirstName
        local stats = localPlayer:FindFirstChild("Characterstats")

        if stats then
            local fv = stats:FindFirstChild("FirstName")
            if fv and fv:IsA("StringValue") then
                fv.Value = name
                tw(applyBtn, 0.08, { TextColor3 = Color3.fromRGB(80,220,80) })
                task.delay(0.6, function() tw(applyBtn, 0.25, { TextColor3 = C.GRAY }) end)
                return
            end
        end

        warn("[FirstName] No se encontró Players."..localPlayer.Name..".Characterstats.FirstName")
        tw(applyBtn, 0.08, { TextColor3 = Color3.fromRGB(220,60,60) })
        task.delay(0.6, function() tw(applyBtn, 0.25, { TextColor3 = C.GRAY }) end)
    end

    -- Apply al hacer clic en ✓
    applyBtn.MouseButton1Click:Connect(function()
        applyFirstName(tbInput.Text)
    end)

    -- Apply también al presionar Enter en el TextBox
    tbInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then applyFirstName(tbInput.Text) end
    end)

    -- Checkbox activa/desactiva la funcionalidad
    fnBtn.MouseButton1Click:Connect(function()
        fnActive = not fnActive
        tw(fnMark, 0.15, { BackgroundTransparency = fnActive and 0 or 1 })
        tw(fnBg,   0.15, { BackgroundColor3 = fnActive and Color3.fromRGB(28,28,28) or Color3.fromRGB(22,22,22) })
        -- Tinta el borde del textbox cuando está activo
        tw(tbBg, 0.15, { BackgroundColor3 = fnActive and Color3.fromRGB(20,20,20) or Color3.fromRGB(16,16,16) })
        if not fnActive then
            -- Restaura el nombre original al desactivar (optional: deja el value como está)
            tw(tbInput, 0.1, { TextColor3 = C.GRAY })
        else
            tw(tbInput, 0.1, { TextColor3 = C.WHITE })
        end
    end)
end

return Visuals
