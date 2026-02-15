-- TEST SIMPLE
print("✅ Script cargado correctamente desde GitHub!")
print("✅ Tu repositorio funciona")

-- Crear un Frame de prueba
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TestPanel"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "✅ GITHUB FUNCIONA"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 1, -60)
Info.Position = UDim2.new(0, 10, 0, 50)
Info.BackgroundTransparency = 1
Info.Text = "Si ves esto, significa que:\n\n✅ GitHub funciona\n✅ Tu ejecutor funciona\n✅ loadstring funciona\n\nEl problema es con el código del Panel.lua"
Info.TextColor3 = Color3.fromRGB(255, 255, 255)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.TextWrapped = true
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = Frame

print("✅ Panel de prueba creado")
print("Si ves un cuadro verde en pantalla, GitHub funciona bien")
