local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Maximierte FFlags für "stärkeren" Desync
local FFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -10000,
    LargeReplicatorWrite5 = true,
    LargeReplicatorEnabled9 = true,
    AngularVelociryLimit = 999999,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    S2PhysicsSenderRate = 20000,
    PhysicsSenderMaxBandwidthBps = 999999,
    MaxDataPacketPerSend = 2147483647,
    SimDefaultHumanoidTimestepMultiplier = 0,
    WorldStepMax = 60,
    NextGenReplicatorEnabledWrite4 = true,
    CheckPVCachedVelThresholdPercent = 0,
    CheckPVCachedRotVelThresholdPercent = 0
}

local currentBox = nil
local noAnimConnection = nil

-- UI Setup
local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("V0idSinc") then coreGui.V0idSinc:Destroy() end

local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "V0idSinc"

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 160, 0, 100)
main.Position = UDim2.new(0.5, -80, 0.4, -50) -- Startet mittig
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(140, 90, 255)

-- STABILES DRAG-SYSTEM (Multi-Touch Safe)
local dragInput, dragStart, startPos
local dragging = false
local currentTouch = nil -- Fixiert das Verschieben auf EINEN Finger

main.InputBegan:Connect(function(input)
    if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        currentTouch = input -- Speichert den Finger, der angefangen hat
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    -- Nur bewegen, wenn es der GLEICHE Finger/Input ist
    if dragging and input == currentTouch then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        
        -- Screen Boundary (Verhindert Rausrutschen aus dem Bildschirm)
        local screenSize = screenGui.AbsoluteSize
        newX = math.clamp(newX, 0, screenSize.X - main.AbsoluteSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - main.AbsoluteSize.Y)
        
        main.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == currentTouch then
        dragging = false
        currentTouch = nil
    end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "V0id No tool desync"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12

local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 135, 0, 25)
    btn.Position = UDim2.new(0.5, -67.5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.TextColor3 = active and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(200, 200, 200)
        callback(active)
    end)
end

createToggle("Desync", 35, function(val)
    if val then 
        for n, v in pairs(FFlags) do pcall(function() setfflag(tostring(n), tostring(v)) end) end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentBox = Instance.new("Part", workspace)
            currentBox.Shape = Enum.PartType.Block
            currentBox.Size = Vector3.new(5, 5, 5)
            currentBox.CFrame = player.Character.HumanoidRootPart.CFrame
            currentBox.Anchored = true
            currentBox.CanCollide = false
            currentBox.Material = Enum.Material.Neon
            currentBox.Color = Color3.new(1, 1, 1)
            currentBox.Transparency = 0.5
        end
    else 
        if currentBox then currentBox:Destroy(); currentBox = nil end
    end
end)

createToggle("No Anim", 65, function(val)
    if val then
        noAnimConnection = RunService.Stepped:Connect(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
        end)
    else
        if noAnimConnection then noAnimConnection:Disconnect(); noAnimConnection = nil end
    end
end)
