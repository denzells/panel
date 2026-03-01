-- ============================================================
-- visuals.lua  -  PanelBase | checktheblox
-- Pestaña: Visuals
-- ESP sin Drawing API — usa ScreenGui (indetectable por anti-cheats)
-- ============================================================
local Visuals = {}

function Visuals.build(page, r)
    local C   = r.C
    local mk  = r.mk
    local rnd = r.rnd
    local tw  = r.tw

    local Players     = game:GetService("Players")
    local RunService  = game:GetService("RunService")
    local localPlayer = Players.LocalPlayer
    local camera      = workspace.CurrentCamera

    local so = 0
    local function SO() so = so + 1; return so end

    -- ── ESP settings ───────────────────────────────────────────────
    local esp_settings = {
        enabled   = false,
        skel      = true,
        skel_col  = Color3.fromRGB(255, 255, 255),
        thickness = 2,
    }

    -- ── ScreenGui overlay (reemplaza Drawing API) ──────────────────
    local espGui = Instance.new("ScreenGui")
    espGui.Name           = "ESP_Overlay"
    espGui.ResetOnSpawn   = false
    espGui.IgnoreGuiInset = true
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGui.Enabled        = false
    espGui.Parent         = localPlayer:WaitForChild("PlayerGui")

    --[[
        Línea 2D usando un Frame rotado:
          - Size.X  = longitud del segmento
          - Size.Y  = grosor
          - Rotation = ángulo en grados
          - Position = punto medio A-B
    ]]
    local function makeLine()
        local f = Instance.new("Frame")
        f.AnchorPoint            = Vector2.new(0.5, 0.5)
        f.BorderSizePixel        = 0
        f.BackgroundColor3       = esp_settings.skel_col
        f.BackgroundTransparency = 0
        f.Visible                = false
        f.ZIndex                 = 10
        f.Parent                 = espGui
        return f
    end

    local function setLine(f, ax, ay, bx, by)
        local dx   = bx - ax
        local dy   = by - ay
        local len  = math.sqrt(dx*dx + dy*dy)
        if len < 1 then f.Visible = false; return end
        f.Position  = UDim2.fromOffset((ax+bx)/2, (ay+by)/2)
        f.Size      = UDim2.fromOffset(len, esp_settings.thickness)
        f.Rotation  = math.deg(math.atan2(dy, dx))
        f.BackgroundColor3 = esp_settings.skel_col
        f.Visible   = true
    end

    local function hideLine(f)
        if f then f.Visible = false end
    end

    -- ── Lógica de dibujo por jugador ───────────────────────────────
    local function draw(player, character)
        -- 6 líneas (mismo esquema que el script original R6)
        local lines = {}
        for i = 1, 6 do lines[i] = makeLine() end

        local skel_head     = lines[1]
        local skel_torso    = lines[2]
        local skel_leftarm  = lines[3]
        local skel_rightarm = lines[4]
        local skel_leftleg  = lines[5]
        local skel_rightleg = lines[6]

        local connection
        connection = RunService.RenderStepped:Connect(function()

            -- Si el ESP se desactivó o el personaje ya no existe, limpiar
            if not esp_settings.enabled
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
                -- ── R6 ─────────────────────────────────────────────
                local head          = camera:WorldToViewportPoint(character.Head.Position)
                local torso_up      = camera:WorldToViewportPoint(character.Torso.Position + Vector3.new(0, 1, 0))
                local torso_dn      = camera:WorldToViewportPoint(character.Torso.Position + Vector3.new(0,-1, 0))
                local leftarm       = camera:WorldToViewportPoint(character["Left Arm"].Position  + Vector3.new(0,-1,0))
                local rightarm      = camera:WorldToViewportPoint(character["Right Arm"].Position + Vector3.new(0,-1,0))
                local leftleg       = camera:WorldToViewportPoint(character["Left Leg"].Position  + Vector3.new(0,-1,0))
                local rightleg      = camera:WorldToViewportPoint(character["Right Leg"].Position + Vector3.new(0,-1,0))

                if esp_settings.skel then
                    setLine(skel_head,     head.X,     head.Y,     torso_up.X, torso_up.Y)
                    setLine(skel_torso,    torso_up.X, torso_up.Y, torso_dn.X, torso_dn.Y)
                    setLine(skel_leftarm,  torso_up.X, torso_up.Y, leftarm.X,  leftarm.Y)
                    setLine(skel_rightarm, torso_up.X, torso_up.Y, rightarm.X, rightarm.Y)
                    setLine(skel_leftleg,  torso_dn.X, torso_dn.Y, leftleg.X,  leftleg.Y)
                    setLine(skel_rightleg, torso_dn.X, torso_dn.Y, rightleg.X, rightleg.Y)
                else
                    for _, l in ipairs(lines) do hideLine(l) end
                end

            elseif rig == Enum.HumanoidRigType.R15 then
                -- ── R15 ────────────────────────────────────────────
                local function v2(partName, offset)
                    local part = character:FindFirstChild(partName)
                    if not part then return nil end
                    local p = camera:WorldToViewportPoint(part.Position + (offset or Vector3.new()))
                    return Vector2.new(p.X, p.Y)
                end

                local head      = v2("Head")
                local upTorso   = v2("UpperTorso")
                local loTorso   = v2("LowerTorso")
                local lUpArm    = v2("LeftUpperArm")
                local lLoArm    = v2("LeftLowerArm")
                local lHand     = v2("LeftHand")
                local rUpArm    = v2("RightUpperArm")
                local rLoArm    = v2("RightLowerArm")
                local rHand     = v2("RightHand")
                local lUpLeg    = v2("LeftUpperLeg")
                local lLoLeg    = v2("LeftLowerLeg")
                local lFoot     = v2("LeftFoot")
                local rUpLeg    = v2("RightUpperLeg")
                local rLoLeg    = v2("RightLowerLeg")
                local rFoot     = v2("RightFoot")

                -- Reutilizamos las 6 líneas base + creamos extra si hacen falta
                -- Para R15 necesitamos 14 segmentos; los guardamos en lines[1..14]
                for i = 7, 14 do
                    if not lines[i] then lines[i] = makeLine() end
                end

                local segs = {
                    {head,    upTorso},
                    {upTorso, loTorso},
                    {loTorso, lUpLeg},
                    {lUpLeg,  lLoLeg},
                    {lLoLeg,  lFoot},
                    {loTorso, rUpLeg},
                    {rUpLeg,  rLoLeg},
                    {rLoLeg,  rFoot},
                    {upTorso, lUpArm},
                    {lUpArm,  lLoArm},
                    {lLoArm,  lHand},
                    {upTorso, rUpArm},
                    {rUpArm,  rLoArm},
                    {rLoArm,  rHand},
                }

                if esp_settings.skel then
                    for i, seg in ipairs(segs) do
                        local a, b = seg[1], seg[2]
                        if a and b then
                            setLine(lines[i], a.X, a.Y, b.X, b.Y)
                        else
                            hideLine(lines[i])
                        end
                    end
                else
                    for _, l in ipairs(lines) do hideLine(l) end
                end
            end
        end)
    end

    -- ── Track / untrack players ────────────────────────────────────
    local function playerAdded(player)
        if player == localPlayer then return end

        if player.Character then
            coroutine.wrap(draw)(player, player.Character)
        end

        player.CharacterAdded:Connect(function(character)
            coroutine.wrap(draw)(player, character)
        end)
    end

    -- Jugadores ya en el servidor
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

    local espRow = makeRow(visionPanel, "ESP Character", SO())
    local espChkBg, espChkMark, espChkBtn = makeCheckbox(espRow, 5)
    espChkBg.Position = UDim2.new(1,-18,0.5,-9)

    local espActive = false

    espChkBtn.MouseButton1Click:Connect(function()
        espActive = not espActive

        tw(espChkMark, 0.15, { BackgroundTransparency = espActive and 0 or 1 })
        tw(espChkBg, 0.15, {
            BackgroundColor3 = espActive
                and Color3.fromRGB(28,28,28)
                or  Color3.fromRGB(22,22,22)
        })

        esp_settings.enabled = espActive
        espGui.Enabled        = espActive
        print("[ESP] Estado:", espActive)
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
end

return Visuals
