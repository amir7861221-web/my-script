local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FFLAGS & SETTINGS
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

-- VARIABLEN
local currentBox = nil
local idleActive = false
local currentIdleTrack = nil
local renderConnection = nil

-- UI
local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("KakySinc") then coreGui.KakySinc:Destroy() end

local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "KakySinc"

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 160, 0, 100)
main.Position = UDim2.new(0, 20, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(140, 90, 255)

-- DRAG SYSTEM
local dragging = false
local activeTouch = nil
local dragStart, startPos

main.InputBegan:Connect(function(input)
    if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        activeTouch = input
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeTouch = nil
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == activeTouch and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - main.Size.X.Offset)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - main.Size.Y.Offset)
        main.Position = UDim2.new(0, newX, 0, newY)
    end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "⚡️no tool desync⚡️"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 11

-- NO ANIM (IDLE) LOGIK
local function getIdleId()
    local anim = player.Character and player.Character:FindFirstChild("Animate")
    if anim and anim:FindFirstChild("idle") then
        local idObj = anim.idle:FindFirstChildWhichIsA("Animation")
        return idObj and idObj.AnimationId
    end
    return nil
end

local function stopIdle()
    if currentIdleTrack then currentIdleTrack:Stop() currentIdleTrack = nil end
    local animScript = player.Character and player.Character:FindFirstChild("Animate")
    if animScript then animScript.Disabled = false end
end

local function playIdle()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local idleId = getIdleId()
    if hum and idleId then
        local anim = Instance.new("Animation")
        anim.AnimationId = idleId
        currentIdleTrack = hum:LoadAnimation(anim)
        currentIdleTrack.Priority = Enum.AnimationPriority.Action
        currentIdleTrack.Looped = true
        currentIdleTrack:Play()
        local animScript = char:FindFirstChild("Animate")
        if animScript then animScript.Disabled = true end
    end
end

-- TOGGLE CREATOR
local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 135, 0, 25)
    btn.Position = UDim2.new(0.5, -67.5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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

-- BUTTONS
createToggle("Desync", 35, function(val)
    if val then 
        for n, v in pairs(FFlags) do pcall(function() setfflag(tostring(n), tostring(v)) end) end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            currentBox = Instance.new("Part", workspace)
            currentBox.Size = Vector3.new(3, 3, 3)
            currentBox.CFrame = hrp.CFrame
            currentBox.Anchored = true; currentBox.CanCollide = false
            currentBox.Material = Enum.Material.Neon
            currentBox.Color = Color3.fromRGB(140, 90, 255)
            currentBox.Transparency = 0.5
        end
    else 
        for n, v in pairs(defaultFFlags) do pcall(function() setfflag(tostring(n), tostring(v)) end) end
        if currentBox then currentBox:Destroy(); currentBox = nil end
    end
end)

createToggle("No Anim", 65, function(val) -- Jetzt "No Anim" benannt
    idleActive = val
    if val then
        playIdle()
        renderConnection = RunService.RenderStepped:Connect(function()
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum and idleActive then
                if currentIdleTrack and not currentIdleTrack.IsPlaying then currentIdleTrack:Play() end
                for _, t in pairs(hum:GetPlayingAnimationTracks()) do
                    if t ~= currentIdleTrack and t.Name ~= "Layer1" then t:Stop(0) end
                end
            end
        end)
    else
        stopIdle()
        if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if idleActive then playIdle() end
end)
