-- ============================================
-- COMMANDS.LUA - MÓDULO DE COMANDOS
-- ============================================

local Commands = {}

local cfg, C, mk, rnd, tw
local so = 0

-- ============================================
-- INICIALIZACIÓN
-- ============================================
local function init()
    cfg = _G.PanelConfig
    C = cfg.C
    mk = cfg.mk
    rnd = cfg.rnd
    tw = cfg.Animations.tw
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
-- COMMAND BUTTON
-- ============================================
local function CreateCommand(parent, label, description, callback)
    local container = mk("Frame",{
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    
    local btn = mk("TextButton",{
        Text="", BackgroundColor3=Color3.fromRGB(24,24,24),
        BorderSizePixel=0, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=5, AutoButtonColor=false
    }, container)
    rnd(5, btn)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.5}, btn)
    
    local content = mk("Frame",{
        Size=UDim2.new(1,-12,0,0), Position=UDim2.new(0,6,0,6),
        AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, ZIndex=6
    }, btn)
    mk("UIListLayout",{Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, content)
    mk("UIPadding",{PaddingBottom=UDim.new(0,6)}, content)
    
    mk("TextLabel",{
        Text=label, Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,14), TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=7, LayoutOrder=1
    }, content)
    
    if description then
        mk("TextLabel",{
            Text=description, Font=Enum.Font.Gotham, TextSize=8,
            TextColor3=C.GRAY, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,12), TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=7, LayoutOrder=2, TextWrapped=true
        }, content)
    end
    
    btn.MouseEnter:Connect(function()
        tw(btn, .1, {BackgroundColor3=Color3.fromRGB(30,30,30)})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, .1, {BackgroundColor3=Color3.fromRGB(24,24,24)})
    end)
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    return btn
end

-- ============================================
-- INPUT FIELD
-- ============================================
local function CreateInput(parent, label, placeholder, callback)
    local container = mk("Frame",{
        Size=UDim2.new(1,0,0,48), BackgroundTransparency=1, LayoutOrder=SO()
    }, parent)
    
    mk("TextLabel",{
        Text=label, Font=Enum.Font.GothamSemibold, TextSize=9,
        TextColor3=C.WHITE, BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5
    }, container)
    
    local inputBg = mk("Frame",{
        Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0,20),
        BackgroundColor3=Color3.fromRGB(20,20,20), BorderSizePixel=0, ZIndex=5
    }, container)
    rnd(5, inputBg)
    mk("UIStroke",{Color=C.LINE, Thickness=1, Transparency=0.6}, inputBg)
    
    local input = mk("TextBox",{
        Text="", PlaceholderText=placeholder or "",
        Font=Enum.Font.Gotham, TextSize=9,
        TextColor3=C.WHITE, PlaceholderColor3=C.MUTED,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,6,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, ZIndex=6
    }, inputBg)
    
    if callback then
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                callback(input.Text)
            end
        end)
    end
    
    return input
end

-- ============================================
-- INIT COMMANDS PAGE
-- ============================================
function Commands.init(page)
    init()
    
    -- Panel 1: Teleport
    local teleportPanel = MiniPanel(page, "Teleport")
    CreateInput(teleportPanel, "Player Name", "Enter player name", function(text)
        print("Teleport to:", text)
    end)
    CreateCommand(teleportPanel, "Teleport to Spawn", "Return to the spawn point", function()
        print("Teleporting to spawn...")
    end)
    
    -- Panel 2: Player Actions
    local playerPanel = MiniPanel(page, "Player Actions")
    CreateCommand(playerPanel, "Heal Self", "Restore your health to 100%", function()
        print("Healing self...")
    end)
    CreateCommand(playerPanel, "Reset Character", "Reset your character (respawn)", function()
        print("Resetting character...")
    end)
    CreateCommand(playerPanel, "Suicide", "Kill your character instantly", function()
        print("Suicide...")
    end)
    
    -- Panel 3: Server
    local serverPanel = MiniPanel(page, "Server")
    CreateCommand(serverPanel, "Rejoin Server", "Leave and rejoin the current server", function()
        print("Rejoining server...")
    end)
    CreateCommand(serverPanel, "Server Hop", "Join a different server", function()
        print("Server hopping...")
    end)
    CreateCommand(serverPanel, "Copy Job ID", "Copy the current server's Job ID", function()
        print("Copying Job ID...")
    end)
    
    -- Panel 4: Misc Commands
    local miscPanel = MiniPanel(page, "Miscellaneous")
    CreateInput(miscPanel, "Walk Speed", "Enter speed (default: 16)", function(text)
        local speed = tonumber(text)
        if speed then
            print("Setting walk speed to:", speed)
        end
    end)
    CreateInput(miscPanel, "Jump Power", "Enter power (default: 50)", function(text)
        local power = tonumber(text)
        if power then
            print("Setting jump power to:", power)
        end
    end)
    
    print("[Commands] ✓ Página Commands cargada")
end

return Commands