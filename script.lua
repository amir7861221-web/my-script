local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local FFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
    LargeReplicatorWrite5 = true,
    LargeReplicatorEnabled9 = true,
    AngularVelociryLimit = 360,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    S2PhysicsSenderRate = 15000,
    DisableDPIScale = true,
    MaxDataPacketPerSend = 2147483647,
    PhysicsSenderMaxBandwidthBps = 20000,
    TimestepArbiterHumanoidLinearVelThreshold = 21,
    MaxMissedWorldStepsRemembered = -2147483648,
    PlayerHumanoidPropertyUpdateRestrict = true,
    SimDefaultHumanoidTimestepMultiplier = 0,
    StreamJobNOUVolumeLengthCap = 2147483647,
    DebugSendDistInSteps = -2147483648,
    GameNetDontSendRedundantNumTimes = 1,
    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
    LargeReplicatorSerializeRead3 = true,
    ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
    CheckPVCachedVelThresholdPercent = 10,
    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
    GameNetDontSendRedundantDeltaPositionMillionth = 1,
    InterpolationFrameVelocityThresholdMillionth = 5,
    StreamJobNOUVolumeCap = 2147483647,
    InterpolationFrameRotVelocityThresholdMillionth = 5,
    CheckPVCachedRotVelThresholdPercent = 10,
    WorldStepMax = 30,
    InterpolationFramePositionThresholdMillionth = 5,
    TimestepArbiterHumanoidTurningVelThreshold = 1,
    SimOwnedNOUCountThresholdMillionth = 2147483647,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
    NextGenReplicatorEnabledWrite4 = true,
    TimestepArbiterOmegaThou = 1073741823,
    MaxAcceptableUpdateDelay = 1,
    LargeReplicatorSerializeWrite4 = true
}

local defaultFFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = 8,
    LargeReplicatorWrite5 = false,
    LargeReplicatorEnabled9 = false,
    AngularVelociryLimit = 180,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 100,
    S2PhysicsSenderRate = 60,
    DisableDPIScale = false,
    MaxDataPacketPerSend = 1024,
    PhysicsSenderMaxBandwidthBps = 10000,
    TimestepArbiterHumanoidLinearVelThreshold = 10,
    MaxMissedWorldStepsRemembered = 10,
    PlayerHumanoidPropertyUpdateRestrict = false,
    SimDefaultHumanoidTimestepMultiplier = 1,
    StreamJobNOUVolumeLengthCap = 1000,
    DebugSendDistInSteps = 10,
    GameNetDontSendRedundantNumTimes = 10,
    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 50,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 100,
    LargeReplicatorSerializeRead3 = false,
    ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 100,
    CheckPVCachedVelThresholdPercent = 50,
    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 100,
    GameNetDontSendRedundantDeltaPositionMillionth = 100,
    InterpolationFrameVelocityThresholdMillionth = 100,
    StreamJobNOUVolumeCap = 1000,
    InterpolationFrameRotVelocityThresholdMillionth = 100,
    CheckPVCachedRotVelThresholdPercent = 50,
    WorldStepMax = 60,
    InterpolationFramePositionThresholdMillionth = 100,
    TimestepArbiterHumanoidTurningVelThreshold = 10,
    SimOwnedNOUCountThresholdMillionth = 1000,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = 8,
    NextGenReplicatorEnabledWrite4 = false,
    TimestepArbiterOmegaThou = 1000,
    MaxAcceptableUpdateDelay = 10,
    LargeReplicatorSerializeWrite4 = false
}

local currentBox = nil
local noAnimConnection = nil

-- UI Setup
local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("KakySinc") then coreGui.KakySinc:Destroy() end

local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "KakySinc"

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 160, 0, 100)
main.Position = UDim2.new(0, 20, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 1.8
mainStroke.Color = Color3.fromRGB(140, 90, 255)

-- STABILES DRAG SYSTEM
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "⚡️no tool desync⚡️"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 11

local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 130, 0, 24)
    btn.Position = UDim2.new(0.5, -65, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 6, 0, 6)
    status.Position = UDim2.new(1, -14, 0.5, -3)
    status.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        status.BackgroundColor3 = active and Color3.fromRGB(40, 220, 80) or Color3.fromRGB(220, 40, 40)
        btn.TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
        callback(active)
    end)
end

-- Desync: Normale Viereck-Box (Höhe angepasst)
createToggle("Desync", 35, function(val)
    if val then 
        for n, v in pairs(FFlags) do pcall(function() setfflag(tostring(n), tostring(v)) end) end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if currentBox then currentBox:Destroy() end
            currentBox = Instance.new("Part", workspace)
            currentBox.Shape = Enum.PartType.Block
            currentBox.Size = Vector3.new(5, 5, 5) -- RICHTIGES VIERECK (5x5x5)
            currentBox.CFrame = player.Character.HumanoidRootPart.CFrame
            currentBox.Anchored = true
            currentBox.CanCollide = false
            currentBox.Material = Enum.Material.Neon
            currentBox.Color = Color3.new(1, 1, 1)
            currentBox.Transparency = 0.5
        end
    else 
        for n, v in pairs(defaultFFlags) do pcall(function() setfflag(tostring(n), tostring(v)) end) end
        if currentBox then currentBox:Destroy(); currentBox = nil end
    end
end)

-- No Anim
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
