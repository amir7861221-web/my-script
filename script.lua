-- VOID ALLOW - Sleek Edition (v2.0)
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidAllow_ChatPos"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame (Positioniert unter dem Standard-Chat)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 70)
-- Position: Etwas Platz unter dem Chat-Bereich (ca. y=220)
MainFrame.Position = UDim2.new(0, 15, 0, 230) 
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

-- Glow Effekt (UIStroke für den Premium Look)
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(0, 120, 255)
Glow.Thickness = 2.5
Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Glow.Parent = MainFrame

-- Titel Label (Oben links klein)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 20)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "VOID // ALLOW"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Button Design
local ActionButton = Instance.new("TextButton")
ActionButton.Size = UDim2.new(0, 200, 0, 35)
ActionButton.Position = UDim2.new(0.5, -100, 0, 28)
ActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ActionButton.Text = "ALLOW FRIENDS"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.Font = Enum.Font.GothamBold
ActionButton.TextSize = 13
ActionButton.AutoButtonColor = false
ActionButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ActionButton

-- Logik & Timer
local lastClick = 0
local cooldownTime = 1.0 -- Jetzt 1 Sekunde
local toggled = false

-- Pulse Animation für den Glow
task.spawn(function()
    while true do
        local tween = TweenService:Create(Glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color = Color3.fromRGB(0, 200, 255)})
        tween:Play()
        break
    end
end)

RunService.RenderStepped:Connect(function()
    local timeLeft = math.max(0, cooldownTime - (tick() - lastClick))
    
    if timeLeft > 0 then
        local status = toggled and "DISALLOW" or "ALLOW"
        ActionButton.Text = string.format("%s [%.2fs]", status, timeLeft)
        ActionButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ActionButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        Glow.Color = Color3.fromRGB(255, 50, 50) -- Rot während Cooldown
    else
        ActionButton.Text = toggled and "DISALLOW FRIENDS" or "ALLOW FRIENDS"
        ActionButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        Glow.Color = Color3.fromRGB(0, 200, 255) -- Blau wenn bereit
    end
end)

ActionButton.MouseButton1Click:Connect(function()
    if tick() - lastClick >= cooldownTime then
        lastClick = tick()
        toggled = not toggled
        
        -- Klick Animation
        ActionButton:TweenSize(UDim2.new(0, 190, 0, 32), "Out", "Quad", 0.1, true)
        task.wait(0.1)
        ActionButton:TweenSize(UDim2.new(0, 200, 0, 35), "Out", "Quad", 0.1, true)

        -- Remote Ausführung
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/PlotService/ToggleFriends")
        if remote then
            remote:FireServer()
        end
    end
end)
