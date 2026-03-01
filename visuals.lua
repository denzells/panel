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

    -- ── Utilidades de layout (igual que settings.lua) ──────────────────

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

    -- ── Lógica ESP Esqueleto ────────────────────────────────────────────

    local ESP_ENABLED = false
    local espHighlights = {}  -- [player] = { highlights }

    -- Partes del esqueleto que queremos resaltar (omitimos HumanoidRootPart)
    local SKELETON_PARTS = {
        "Head",
        "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        -- R6 fallback
        "Torso",
        "Left Arm", "Right Arm",
        "Left Leg", "Right Leg",
    }

    local function removeESP(player)
        if espHighlights[player] then
            for _, hl in ipairs(espHighlights[player]) do
                if hl and hl.Parent then hl:Destroy() end
            end
            espHighlights[player] = nil
        end
    end

    local function applyESP(player)
        if player == Players.LocalPlayer then return end
        removeESP(player)

        local char = player.Character
        if not char then return end

        local list = {}

        for _, partName in ipairs(SKELETON_PARTS) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                -- Ocultamos meshes/acccesorios del part para que solo se vea el highlight
                local hl = Instance.new("SelectionBox")
                hl.Name        = "_ESP_SkeletonHL"
                hl.Adornee     = part
                hl.Color3      = Color3.fromRGB(255, 255, 255)   -- blanco
                hl.LineThickness = 0.03
                hl.SurfaceTransparency = 1                        -- sin relleno
                hl.SurfaceColor3 = Color3.fromRGB(0, 0, 0)
                hl.Parent      = part
                table.insert(list, hl)
            end
        end

        espHighlights[player] = list
    end

    local function enableESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                applyESP(player)
                -- Reaplica si el personaje cambia
                if not player:GetAttribute("_espConn") then
                    player.CharacterAdded:Connect(function()
                        if ESP_ENABLED then
                            task.wait(0.5)
                            applyESP(player)
                        end
                    end)
                end
            end
        end
        -- Nuevos jugadores que entren
        Players.PlayerAdded:Connect(function(player)
            if ESP_ENABLED then
                player.CharacterAdded:Connect(function()
                    if ESP_ENABLED then
                        task.wait(0.5)
                        applyESP(player)
                    end
                end)
                task.wait(0.5)
                applyESP(player)
            end
        end)
    end

    local function disableESP()
        for player, _ in pairs(espHighlights) do
            removeESP(player)
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)

    -- ── Construcción del panel UI ───────────────────────────────────────

    task.delay(1, function()
        mk("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        mk("UIPadding", {
            PaddingTop    = UDim.new(0,10),
            PaddingBottom = UDim.new(0,10),
            PaddingLeft   = UDim.new(0,10),
            PaddingRight  = UDim.new(0,10),
        }, page)

        -- ── Panel: Character Vision ─────────────────────────────────────
        local visionPanel = MiniPanel(page, "Character Vision")

        -- Ícono decorativo en esquina del panel
        mk("ImageLabel", {
            Image = "rbxassetid://79986513204084",
            Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-26,0,7),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(70,70,70), ZIndex = 6,
        }, visionPanel.Parent)

        makeSectionLabel(visionPanel, "ESP", SO())

        -- ── Fila: ESP Character ─────────────────────────────────────────
        local espRow = makeRow(visionPanel, "ESP Character", SO())

        local espChkBg, espChkMark, espChkBtn = makeCheckbox(espRow, 5)
        espChkBg.Position = UDim2.new(1,-18,0.5,-9)

        -- Estado visual del checkbox
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

        -- ── Descripción informativa ─────────────────────────────────────
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
            Text = "Muestra el esqueleto blanco de todos los jugadores.",
            Font = Enum.Font.Gotham, TextSize = 8,
            TextColor3 = C.GRAY, BackgroundTransparency = 1,
            Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,8,0,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 5,
        }, descBox)
    end)
end

return Visuals
