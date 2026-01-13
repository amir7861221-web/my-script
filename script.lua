local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- FFlags für Desync
local FFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
    LargeReplicatorWrite5 = true,
    LargeReplicatorEnabled9 = true,
    AngularVelociryLimit = 360,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    S2PhysicsSenderRate = 15000,
    MaxDataPacketPerSend = 2147483647,
    PhysicsSenderMaxBandwidthBps = 20000,
    MaxMissedWorldStepsRemembered = -2147483648,
    SimDefaultHumanoidTimestepMultiplier = 0,
    StreamJobNOUVolumeLengthCap = 2147483647,
    DebugSendDistInSteps = -2147483648,
    StreamJobNOUVolumeCap = 2147483647,
    WorldStepMax = 30,
    SimOwnedNOUCountThresholdMillionth = 2147483647,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
    NextGenReplicatorEnabledWrite4 = true,
    LargeReplicatorSerializeWrite4 = true
}

local defaultFFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = 8,
    LargeReplicatorWrite5 = false,
    LargeReplicatorEnabled9 = false,
    AngularVelociryLimit = 180,
    S2PhysicsSenderRate = 60,
    MaxDataPacketPerSend = 1024,
    PhysicsSenderMaxBandwidthBps = 10000,
    MaxMissedWorldStepsRemembered = 10,
    SimDefaultHumanoidTimestepMultiplier = 1,
    StreamJobNOUVolumeLengthCap = 1000,
    DebugSendDistInSteps = 10,
    StreamJobNOUVolumeCap = 1000,
    WorldStepMax = 60,
    SimOwnedNOUCountThresholdMillionth = 1000,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = 8,
    NextGenReplicatorEnabledWrite4 = false,
    LargeReplicatorSerializeWrite4 = false
}

local desyncActive = false
local noanimActive = false
local firstActivation = true
local visualBox = nil

-- Hilfsfunktionen
local function applyFFlags(flags)
    for name, value in pairs(flags) do
        pcall(function() setfflag(tostring(name), tostring(value)) end)
    end
end

local function respawn(plr)
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()
        local newChar = Instance.new("Model")
        newChar.Parent = workspace
        plr.Character = newChar
        task.wait()
        plr.Character = char
        newChar:Destroy()
    end
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "v0id_Final_Blue"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 95)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(80, 50, 255)
stroke.Parent = mainFrame

-- GRIFF (Header)
local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1, 0, 0, 30)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "v0id desync"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.Parent = dragHandle

-- Button Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 1, -30)
buttonContainer.Position = UDim2.new(0, 0, 0, 30)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local list = Instance.new("UIListLayout")
list.Parent = buttonContainer
list.Padding = UDim.new(0, 4)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createRow(text, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 125, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = buttonContainer

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.Parent = row
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(0, 112, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    indicator.Parent = row

    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator

    return btn, indicator
end

local desyncBtn, desyncInd = createRow("Desync", 1)
local noanimBtn, noanimInd = createRow("noanim", 2)

--- DRAG LOGIK (Nur Header) ---
local dragging, dragStart, startPos

dragHandle.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local screenX = screenGui.AbsoluteSize.X
        local screenY = screenGui.AbsoluteSize.Y
        
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, screenX - mainFrame.AbsoluteSize.X)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, screenY - mainFrame.AbsoluteSize.Y)
        
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Box Logik (3x3x3 HELLBLAU)
local function toggleVisualBox(state)
    if state then
        if not visualBox then
            visualBox = Instance.new("Part")
            visualBox.Size = Vector3.new(3, 3, 3)
            visualBox.Transparency = 0.5
            visualBox.Color = Color3.fromRGB(0, 220, 255) -- Hellblau
            visualBox.CanCollide = false
            visualBox.Anchored = true
            visualBox.Material = Enum.Material.SmoothPlastic
            visualBox.Parent = workspace
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            visualBox.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    else
        if visualBox then visualBox:Destroy() visualBox = nil end
    end
end

-- Button Logik
desyncBtn.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    if desyncActive then
        applyFFlags(FFlags)
        if firstActivation then respawn(player) firstActivation = false end
        desyncInd.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        toggleVisualBox(true)
    else
        applyFFlags(defaultFFlags)
        desyncInd.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        toggleVisualBox(false)
    end
end)

noanimBtn.MouseButton1Click:Connect(function()
    noanimActive = not noanimActive
    if noanimActive then
        noanimInd.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    else
        noanimInd.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

RunService.Stepped:Connect(function()
    if noanimActive and player.Character then
        local anim = player.Character:FindFirstChild("Animate")
        if anim then
            anim.Disabled = true
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
            end
        end
    elseif not noanimActive and player.Character then
        local anim = player.Character:FindFirstChild("Animate")
        if anim then anim.Disabled = false end
    end
end)
