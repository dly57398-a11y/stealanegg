-- ==================================================
-- YOKUDO HUB | FEATURE | AFK System
-- រក Plot + Treadmill → Fly TP → Jump Out
-- ✅ Fly ធម្មតា → Stop ភ្លាម → មិន Lock
-- ✅ JumpOut រហូតដល់ Dist > 5
-- ✅ Register ជាមួយ CharacterSystem
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ==================================================
-- SETTINGS
-- ==================================================
local FLY_SPEED = 350
local ARRIVE_TIMEOUT = 15
local JUMP_DISTANCE_THRESHOLD = 5
local JUMP_MAX_ATTEMPTS = 50
local JUMP_ATTEMPT_WAIT = 0.2
local DIST_TREADMILL_THRESHOLD = 5
local DIST_CHECK_INTERVAL = 4
local SAFE_WAIT_TIME = 1
local SAFE_ZONE = Vector3.new(533, 70, -366)

-- ==================================================
-- STATE
-- ==================================================
local AFKEnabled = false
local MyPlot = nil
local MyTreadmill = nil
local MyTreadmillPos = nil
local FlyConnection = nil
local BodyVelocity = nil
local BodyGyro = nil
local IsFlying = false
local DistCheckThread = nil

-- ==================================================
-- GET HUMANOID
-- ==================================================
local function GetHumanoid()
    local Char = Player.Character
    if not Char then return nil, nil end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    return Hum, Root
end

-- ==================================================
-- CLEANUP
-- ==================================================
local function CleanupMovers()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if BodyVelocity then
        pcall(function()
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.zero
        end)
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        pcall(function() BodyGyro.MaxTorque = Vector3.zero end)
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    local Hum, Root = GetHumanoid()
    if Root then
        for _, Child in ipairs(Root:GetChildren()) do
            if Child.Name == "YokudoBV" or Child.Name == "YokudoBG" then
                pcall(function() Child:Destroy() end)
            end
        end
    end
    if Hum then
        pcall(function()
            Hum.PlatformStand = false
            Hum.Sit = false
        end)
    end
    if Root then
        pcall(function()
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    IsFlying = false
end

-- ==================================================
-- FIND MY PLOT AND TREADMILL
-- ==================================================
local function FindMyPlotAndTreadmill()
    local Plots = workspace:FindFirstChild("Plots")
    if not Plots then return nil, nil end

    for _, plot in ipairs(Plots:GetChildren()) do
        if plot:IsA("Model") then
            local PlotSign = plot:FindFirstChild("PlotSign")
            if PlotSign then
                local PlayerPlotSign = PlotSign:FindFirstChild("PlayerPlotSign")
                if PlayerPlotSign then
                    local Frame = PlayerPlotSign:FindFirstChild("Frame")
                    if Frame then
                        local PlayerName = Frame:FindFirstChild("PlayerName")
                        if PlayerName and PlayerName:IsA("TextLabel") then
                            if PlayerName.Text == Player.Name
                            or PlayerName.Text == Player.DisplayName then
                                local Treadmill = plot:FindFirstChild("TreadmillBottom")
                                return plot, Treadmill
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

-- ==================================================
-- FLY TP (✅ Fly ធម្មតា → Stop ភ្លាម → មិន Lock)
-- ==================================================
local function FlyTP(Destination, Callback)
    CleanupMovers()
    IsFlying = true

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then
        IsFlying = false
        if Callback then Callback() end
        return
    end
    if Hum.Health <= 0 then
        IsFlying = false
        if Callback then Callback() end
        return
    end

    Hum.PlatformStand = true

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "YokudoBV"
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.P = 1250
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = Root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "YokudoBG"
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.P = 3000
    BodyGyro.D = 500
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root

    local StartTime = tick()

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not AFKEnabled then
            CleanupMovers()
            return
        end

        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then
            CleanupMovers()
            return
        end
        if Hum2.Health <= 0 then return end
        if not BodyVelocity or not BodyGyro then CleanupMovers() return end

        local CurrentPos = Root2.Position
        local Direction = Destination - CurrentPos
        local TotalDist = math.floor(Direction.Magnitude)

        if TotalDist <= 2 then
            CleanupMovers()
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero
            if Callback then Callback() end
            return
        end

        if tick() - StartTime > ARRIVE_TIMEOUT then
            CleanupMovers()
            if Callback then Callback() end
            return
        end

        BodyVelocity.Velocity = Direction.Unit * FLY_SPEED
        BodyGyro.CFrame = CFrame.new(CurrentPos, Destination)
    end)
end

-- ==================================================
-- JUMP OUT TREADMILL
-- ==================================================
local function JumpOutTreadmill(TreadmillPos, Callback)
    local Hum, Root = GetHumanoid()
    if not Hum or not Root or not TreadmillPos then
        if Callback then Callback() end
        return
    end

    print("[AFK] Starting Jump Out...")

    task.spawn(function()
        local Attempts = 0
        while AFKEnabled and Attempts < JUMP_MAX_ATTEMPTS do
            local Hum2, Root2 = GetHumanoid()
            if not Hum2 or not Root2 then break end
            if Hum2.Health <= 0 then break end

            local DistToTreadmill = math.floor((Root2.Position - TreadmillPos).Magnitude)

            if DistToTreadmill > JUMP_DISTANCE_THRESHOLD then
                print("[AFK] ✅ Jumped out! Distance:", DistToTreadmill)
                if Callback then Callback() end
                return
            end

            pcall(function() Hum2.Jump = true end)
            Attempts = Attempts + 1
            task.wait(JUMP_ATTEMPT_WAIT)
        end

        print("[AFK] JumpOut timeout")
        if Callback then Callback() end
    end)
end

-- ==================================================
-- DISTANCE CHECK LOOP
-- ==================================================
local function StartDistanceCheck()
    if DistCheckThread then
        pcall(function() task.cancel(DistCheckThread) end)
        DistCheckThread = nil
    end

    DistCheckThread = task.spawn(function()
        while AFKEnabled do
            task.wait(DIST_CHECK_INTERVAL)
            if not AFKEnabled then break end

            local Hum, Root = GetHumanoid()
            if not Root or not MyTreadmillPos then continue end

            local DistToTreadmill = math.floor((Root.Position - MyTreadmillPos).Magnitude)

            if DistToTreadmill > DIST_TREADMILL_THRESHOLD then
                print("[AFK] Player jumped out! Fly back to Treadmill")
                FlyTP(MyTreadmillPos)
            end
        end
    end)
end

-- ==================================================
-- ENABLE
-- ==================================================
local function EnableAFK()
    if AFKEnabled then return end
    AFKEnabled = true

    MyPlot, MyTreadmill = FindMyPlotAndTreadmill()
    if MyTreadmill then
        MyTreadmillPos = MyTreadmill.Position
        print("[AFK] Treadmill found:", MyTreadmill:GetFullName())
    else
        warn("[AFK] Treadmill not found!")
        AFKEnabled = false
        return
    end

    print("[AFK] Fly to Safe Zone first")
    FlyTP(SAFE_ZONE, function()
        task.wait(SAFE_WAIT_TIME)
        print("[AFK] Safe Zone Reached → Fly to Treadmill")
        FlyTP(MyTreadmillPos, function()
            print("[AFK] Arrived at Treadmill → Start Distance Check")
            StartDistanceCheck()
        end)
    end)

    print("[AFK] AFK System: ON")
end

-- ==================================================
-- DISABLE
-- ==================================================
local function DisableAFK()
    if not AFKEnabled then return end
    AFKEnabled = false

    if DistCheckThread then
        pcall(function() task.cancel(DistCheckThread) end)
        DistCheckThread = nil
    end

    CleanupMovers()
    MyPlot = nil
    MyTreadmill = nil
    MyTreadmillPos = nil

    print("[AFK] AFK System: OFF")
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AFKSystem = {
    Enable = EnableAFK,
    Disable = DisableAFK,
    IsEnabled = function() return AFKEnabled end,
    FindMyPlotAndTreadmill = FindMyPlotAndTreadmill,
    FlyTP = FlyTP,
    JumpOutTreadmill = JumpOutTreadmill,
    GetMyTreadmillPos = function() return MyTreadmillPos end,
    GetMyTreadmill = function() return MyTreadmill end,
    GetMyPlot = function() return MyPlot end,
    IsFlying = function() return IsFlying end,
    SAFE_ZONE = SAFE_ZONE,
}

-- ==================================================
-- REGISTER WITH CHARACTER SYSTEM
-- ==================================================
if _G.YOKUDO_CharacterSystem then
    _G.YOKUDO_CharacterSystem:RegisterFeature({
        Name = "AFKSystem",
        Enable = EnableAFK,
        Disable = DisableAFK,
        IsEnabled = function() return AFKEnabled end,
        OnCharacterAdded = function(Char, Hum, Root)
            -- ✅ AFKSystem មិនត្រូវការ Re-Apply ពិសេស
            -- ព្រោះវាប្រើ GetHumanoid() រាល់ពេល
            if AFKEnabled then
                task.wait(1)
                pcall(function()
                    -- Restart Distance Check
                    if MyTreadmillPos then
                        StartDistanceCheck()
                    end
                end)
            end
        end
    })
end

print("✅ AFKSystem Feature Loaded (Fly Normal + Stop + Reset + Register)")
