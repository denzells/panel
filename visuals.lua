-- ============================================================
-- visuals.lua  -  PanelBase | checktheblox
-- Pestaña: Visuals
-- ============================================================
local Visuals = {}

function Visuals.build(page, r)
    local C   = r.C
    local mk  = r.mk
    local rnd = r.rnd
    local tw  = r.tw

    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local so = 0
    local function SO() so = so + 1; return so end

    -- ── Utilidades de layout (igual que settings.lua) ──────────────

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

    -- ── Lógica ESP Esqueleto (Drawing API) ─────────────────────────

    local camera = workspace.CurrentCamera

    local SkeletonSettings = {
        Color        = Color3.new(1, 1, 1),   -- blanco
        Thickness    = 2,
        Transparency = 0,                      -- 0 = totalmente opaco
    }

    local ESP_ENABLED = false
    local skeletons   = {}   -- [player] = { lines={}, conn=RBXScriptConnection }

    local function createLine()
        local line = Drawing.new("Line")
        line.Visible = false
        return line
    end

    local function removeLines(lines)
        for _, line in pairs(lines) do
            pcall(function() line:Remove() end)
        end
    end

    local function untrackPlayer(plr)
        local data = skeletons[plr]
        if not data then return end
        removeLines(data.lines)
        if data.conn then data.conn:Disconnect() end
        skeletons[plr] = nil
    end

    local function trackPlayer(plr)
        if plr == Players.LocalPlayer then return end
        untrackPlayer(plr)

        local lines = {}
        local renderConn

        renderConn = RunService.RenderStepped:Connect(function()
            -- Si ESP se desactivó o el jugador salió, limpiamos y desconectamos
            if not ESP_ENABLED or not plr or not plr.Parent then
                removeLines(lines)
                renderConn:Disconnect()
                skeletons[plr] = nil
                return
            end

            local character = plr.Character
            if not character then
                for _, l in pairs(lines) do l.Visible = false end
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                for _, l in pairs(lines) do l.Visible = false end
                return
            end

            local joints, connections

            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                joints = {
                    Head          = character:FindFirstChild("Head"),
                    UpperTorso    = character:FindFirstChild("UpperTorso"),
                    LowerTorso    = character:FindFirstChild("LowerTorso"),
                    LeftUpperArm  = character:FindFirstChild("LeftUpperArm"),
                    LeftLowerArm  = character:FindFirstChild("LeftLowerArm"),
                    LeftHand      = character:FindFirstChild("LeftHand"),
                    RightUpperArm = character:FindFirstChild("RightUpperArm"),
                    RightLowerArm = character:FindFirstChild("RightLowerArm"),
                    RightHand     = character:FindFirstChild("RightHand"),
                    LeftUpperLeg  = character:FindFirstChild("LeftUpperLeg"),
                    LeftLowerLeg  = character:FindFirstChild("LeftLowerLeg"),
                    RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
                    RightLowerLeg = character:FindFirstChild("RightLowerLeg"),
                }
                connections = {
                    { "Head",          "UpperTorso"    },
                    { "UpperTorso",    "LowerTorso"    },
                    { "LowerTorso",    "LeftUpperLeg"  },
                    { "LeftUpperLeg",  "LeftLowerLeg"  },
                    { "LowerTorso",    "RightUpperLeg" },
                    { "RightUpperLeg", "RightLowerLeg" },
                    { "UpperTorso",    "LeftUpperArm"  },
                    { "LeftUpperArm",  "LeftLowerArm"  },
                    { "LeftLowerArm",  "LeftHand"      },
                    { "UpperTorso",    "RightUpperArm" },
                    { "RightUpperArm", "RightLowerArm" },
                    { "RightLowerArm", "RightHand"     },
                }
            else  -- R6
                joints = {
                    Head     = character:FindFirstChild("Head"),
                    Torso    = character:FindFirstChild("Torso"),
                    LeftArm  = character:FindFirstChild("Left Arm"),
                    RightArm = character:FindFirstChild("Right Arm"),
                    LeftLeg  = character:FindFirstChild("Left Leg"),
                    RightLeg = character:FindFirstChild("Right Leg"),
                }
                connections = {
                    { "Head",    "Torso"    },
                    { "Torso",   "LeftArm"  },
                    { "Torso",   "RightArm" },
                    { "Torso",   "LeftLeg"  },
                    { "Torso",   "RightLeg" },
                }
            end

            for index, conn in ipairs(connections) do
                local jA = joints[conn[1]]
                local jB = joints[conn[2]]

                if jA and jB then
                    local pA, onA = camera:WorldToViewportPoint(jA.Position)
                    local pB, onB = camera:WorldToViewportPoint(jB.Position)

                    local line = lines[index]
                    if not line then
                        line = createLine()
                        lines[index] = line
                    end

                    line.Color        = SkeletonSettings.Color
                    line.Thickness    = SkeletonSettings.Thickness
                    line.Transparency = SkeletonSettings.Transparency

                    if onA and onB then
                        line.From    = Vector2.new(pA.X, pA.Y)
                        line.To      = Vector2.new(pB.X, pB.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                elseif lines[index] then
                    lines[index].Visible = false
                end
            end
        end)

        skeletons[plr] = { lines = lines, conn = renderConn }
    end

    local function enableESP()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                trackPlayer(plr)
            end
        end
    end

    local function disableESP()
        for plr, _ in pairs(skeletons) do
            untrackPlayer(plr)
        end
        skeletons = {}
    end

    -- Jugador entra a la partida mientras el ESP está activo
    Players.PlayerAdded:Connect(function(plr)
        if ESP_ENABLED then trackPlayer(plr) end
    end)

    -- Jugador sale de la partida: limpiar sus lineas
    Players.PlayerRemoving:Connect(function(plr)
        untrackPlayer(plr)
    end)

    -- ── Construcción del panel UI ───────────────────────────────────

    task.delay(1, function()
        mk("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        mk("UIPadding", {
            PaddingTop    = UDim.new(0,10),
            PaddingBottom = UDim.new(0,10),
            PaddingLeft   = UDim.new(0,10),
            PaddingRight  = UDim.new(0,10),
        }, page)

        -- Panel: Character Vision
        local visionPanel = MiniPanel(page, "Character Vision")

        mk("ImageLabel", {
            Image = "rbxassetid://79986513204084",
            Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-26,0,7),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(70,70,70), ZIndex = 6,
        }, visionPanel.Parent)

        makeSectionLabel(visionPanel, "ESP", SO())

        -- Fila: ESP Character
        local espRow = makeRow(visionPanel, "ESP Character", SO())

        local espChkBg, espChkMark, espChkBtn = makeCheckbox(espRow, 5)
        espChkBg.Position = UDim2.new(1,-18,0.5,-9)

        local espActive = false

        espChkBtn.MouseButton1Click:Connect(function()
            espActive = not espActive

            tw(espChkMark, 0.15, { BackgroundTransparency = espActive and 0 or 1 })
            tw(espChkBg,   0.15, {
                BackgroundColor3 = espActive
                    and Color3.fromRGB(28,28,28)
                    or  Color3.fromRGB(22,22,22)
            })

            ESP_ENABLED = espActive

            if espActive then
                enableESP()
            else
                disableESP()
            end
        end)

        -- Descripción informativa
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
    end)
end

return Visuals
