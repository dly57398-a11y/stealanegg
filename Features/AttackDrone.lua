-- ==================================================
-- YOKUDO HUB | FEATURE | Attack Drone
-- Attack ONLY Top1 | Top2 | Top3
-- ✅ Logic ចាស់ទាំងស្រុង — InitialFlyAndStartLoop (Signed X)
-- ✅ Fly TP មិន Lock + Stop ភ្លាម + Reset CFrame
-- ✅ Lock CFrame តែពេល Follow Mob
-- ✅ Register ជាមួយ CharacterSystem
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- ==================================================
-- SETTINGS
-- ==================================================
local ATTACK_RANGE = 16
local ATTACK_INTERVAL = 0.05
local FOLLOW_SPEED = 500
local FOLLOW_BEHIND_DISTANCE = 3
local SHORT_TP_DISTANCE = 20
local SPAWN_POSITION_1 = Vector3.new(2140, 77, -367)
local SPAWN_POSITION_2 = Vector3.new(5723, 77, -376)
local SAFE_ZONE = Vector3.new(533, 70, -366)
local POINT_1 = Vector3.new(559, 70, -370)
local SAFE_WAIT_TIME = 1
local SPAWN_WAIT_TIME = 2
local ARRIVE_TIMEOUT = 15
local CONTAINER_NAME = "ScrambleLocalVisuals"
local SEARCH_PREFIXES = { "DroneVisual_", "PersonalDrone_" }

local TIER_PRIORITY = {
    ["AugmentedDrone"] = 1,
    ["ReactorDrone"] = 2,
    ["ScrapDrone"] = 3,
}
local MAX_ALLOWED_PRIORITY = 3

-- ==================================================
-- STATE
-- ==================================================
local AttackDroneEnabled = false
local AttackConnection = nil
local FollowConnection = nil
local LockConnection = nil
local BodyVelocity = nil
local BodyGyro = nil
local CurrentTarget = nil
local CurrentTargetPriority = nil
local LastFire = 0
local TraceSequence = 0
local IsLocked = false
local LockCFrame = nil
local Phase = "idle"
local CurrentSpawnIndex = 1
local IsFlying = false
local SpawnLoopRunning = false

local SavedStats = {
    WalkSpeed = nil,
    JumpPower = nil,
    JumpHeight = nil,
    UseJumpPower = nil,
    Humanoid = nil,
}

local StartFollow
local FlyTPToPosition
local StartAttackLoop
local SpawnLoop
local StopAttack
local InitialFlyAndStartLoop

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
-- GET BAT SWING REMOTE
-- ==================================================
local function GetBatSwingRemote()
    local Success, Remote = pcall(function()
        return ReplicatedStorage.Packages.Networking["RE/BatSwing/Trigger"]
    end)
    if Success and Remote then return Remote end
    return nil
end

-- ==================================================
-- SAVE / RESTORE STATS
-- ==================================================
local function SaveLiveStats()
    local Hum = GetHumanoid()
    if not Hum then return end
    SavedStats.Humanoid = Hum
    SavedStats.WalkSpeed = Hum.WalkSpeed
    SavedStats.JumpPower = Hum.JumpPower
    SavedStats.JumpHeight = Hum.JumpHeight
    SavedStats.UseJumpPower = Hum.UseJumpPower
end

local function RestoreLiveStats()
    local Hum = GetHumanoid()
    if not Hum then return end
    if SavedStats.WalkSpeed ~= nil then pcall(function() Hum.WalkSpeed = SavedStats.WalkSpeed end) end
    if SavedStats.JumpPower ~= nil then pcall(function() Hum.JumpPower = SavedStats.JumpPower end) end
    if SavedStats.JumpHeight ~= nil then pcall(function() Hum.JumpHeight = SavedStats.JumpHeight end) end
    if SavedStats.UseJumpPower ~= nil then pcall(function() Hum.UseJumpPower = SavedStats.UseJumpPower end) end
end

local function EnsureStatsAlive()
    local Hum = GetHumanoid()
    if not Hum then return end
    if SavedStats.Humanoid ~= Hum then
        SavedStats.Humanoid = Hum
        SavedStats.WalkSpeed = Hum.WalkSpeed
        SavedStats.JumpPower = Hum.JumpPower
        SavedStats.JumpHeight = Hum.JumpHeight
        SavedStats.UseJumpPower = Hum.UseJumpPower
    end
end

-- ==================================================
-- CLEANUP
-- ==================================================
local function CleanupMovers()
    if FollowConnection then FollowConnection:Disconnect() FollowConnection = nil end
    if LockConnection then LockConnection:Disconnect() LockConnection = nil end
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

    IsLocked = false
    LockCFrame = nil
end

-- ==================================================
-- GET POSITION / LOOK VECTOR
-- ==================================================
local function GetPosition(Object)
    if not Object then return nil end
    if Object:IsA("Model") then
        if Object.PrimaryPart then return Object.PrimaryPart.Position end
        local Part = Object:FindFirstChildWhichIsA("BasePart")
        if Part then return Part.Position end
        for _, Desc in ipairs(Object:GetDescendants()) do
            if Desc:IsA("BasePart") then return Desc.Position end
        end
    elseif Object:IsA("BasePart") then
        return Object.Position
    end
    return nil
end

local function GetLookVector(Object)
    if not Object then return Vector3.new(0, 0, -1) end
    local Part = nil
    if Object:IsA("Model") then
        Part = Object.PrimaryPart or Object:FindFirstChildWhichIsA("BasePart")
        if not Part then
            for _, Desc in ipairs(Object:GetDescendants()) do
                if Desc:IsA("BasePart") then Part = Desc break end
            end
        end
    elseif Object:IsA("BasePart") then
        Part = Object
    end
    if Part then return Part.CFrame.LookVector end
    return Vector3.new(0, 0, -1)
end

-- ==================================================
-- FIND ALL DRONES
-- ==================================================
local function FindAllDrones()
    local Container = workspace:FindFirstChild(CONTAINER_NAME)
    if not Container then return {} end
    local Drones = {}
    for _, obj in ipairs(Container:GetChildren()) do
        for _, prefix in ipairs(SEARCH_PREFIXES) do
            if string.sub(obj.Name, 1, #prefix) == prefix then
                table.insert(Drones, obj)
                break
            end
        end
    end
    return Drones
end

-- ==================================================
-- GET DRONE TIER / PRIORITY
-- ==================================================
local function GetDroneTier(Drone)
    if not Drone then return nil end
    local Tier = nil
    pcall(function() Tier = Drone:GetAttribute("ScrambleTier") end)
    return Tier
end

local function GetDronePriority(Drone)
    local Tier = GetDroneTier(Drone)
    if not Tier then return nil end
    return TIER_PRIORITY[Tier]
end

-- ==================================================
-- FIND BEST DRONE
-- ==================================================
local function FindBestDrone()
    local Drones = FindAllDrones()
    if #Drones == 0 then return nil end
    local CurrentSpawn = (CurrentSpawnIndex == 1) and SPAWN_POSITION_1 or SPAWN_POSITION_2
    local Best = nil
    local BestPriority = math.huge
    local BestDist = math.huge

    for _, Drone in ipairs(Drones) do
        local Priority = GetDronePriority(Drone)
        if Priority and Priority <= MAX_ALLOWED_PRIORITY then
            local Pos = GetPosition(Drone)
            if Pos then
                local Dist = math.floor((Pos - CurrentSpawn).Magnitude)
                if Priority < BestPriority or (Priority == BestPriority and Dist < BestDist) then
                    BestPriority = Priority
                    BestDist = Dist
                    Best = Drone
                end
            end
        end
    end
    return Best, BestPriority, BestDist
end

-- ==================================================
-- GET BEHIND POSITION
-- ==================================================
local function GetBehindPosition(Target)
    local TargetPos = GetPosition(Target)
    if not TargetPos then return nil end
    local LookVector = GetLookVector(Target)
    local BehindPos = TargetPos - (LookVector * FOLLOW_BEHIND_DISTANCE)
    BehindPos = Vector3.new(BehindPos.X, TargetPos.Y + 1, BehindPos.Z)
    return BehindPos
end

-- ==================================================
-- START LOCK
-- ==================================================
local function StartLock(Position, LookAt)
    LockCFrame = CFrame.new(Position, LookAt or (Position + Vector3.new(0, 0, -1)))
    if LockConnection then LockConnection:Disconnect() end
    IsLocked = true

    LockConnection = RunService.Heartbeat:Connect(function()
        if not AttackDroneEnabled then
            if LockConnection then LockConnection:Disconnect() LockConnection = nil end
            IsLocked = false
            return
        end
        local Hum, Root = GetHumanoid()
        if not Root then return end
        if CurrentTarget and CurrentTarget.Parent then
            local NewBehind = GetBehindPosition(CurrentTarget)
            local NewTargetPos = GetPosition(CurrentTarget)
            if NewBehind and NewTargetPos then
                LockCFrame = CFrame.new(NewBehind, NewTargetPos)
            end
        end
        Root.CFrame = LockCFrame
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- ==================================================
-- FOLLOW BEHIND
-- ==================================================
function StartFollow()
    CleanupMovers()
    local Hum, Root = GetHumanoid()
    if not Hum or not Root then return end
    if Hum.Health <= 0 then return end

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

    FollowConnection = RunService.Heartbeat:Connect(function()
        if not AttackDroneEnabled then CleanupMovers() return end
        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then CleanupMovers() return end
        if Hum2.Health <= 0 then return end
        if not BodyVelocity or not BodyGyro then CleanupMovers() return end
        if not CurrentTarget or not CurrentTarget.Parent then CleanupMovers() return end

        local TargetPos = GetPosition(CurrentTarget)
        if not TargetPos then CleanupMovers() return end
        local BehindPos = GetBehindPosition(CurrentTarget)
        if not BehindPos then CleanupMovers() return end

        local CurrentPos = Root2.Position
        local Direction = BehindPos - CurrentPos
        local TotalDist = math.floor(Direction.Magnitude)

        if TotalDist <= SHORT_TP_DISTANCE then
            if BodyVelocity then
                BodyVelocity.Velocity = Vector3.zero
                BodyVelocity.MaxForce = Vector3.zero
            end
            if BodyGyro then
                BodyGyro.MaxTorque = Vector3.zero
            end

            task.wait(0.1)
            CleanupMovers()

            Root2.CFrame = CFrame.new(BehindPos, TargetPos)
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero
            StartLock(BehindPos, TargetPos)
            return
        end

        BodyVelocity.Velocity = Direction.Unit * FOLLOW_SPEED
        BodyGyro.CFrame = CFrame.new(CurrentPos, TargetPos)
    end)
end

-- ==================================================
-- FLY TP TO POSITION
-- ==================================================
function FlyTPToPosition(Destination, Callback)
    CleanupMovers()
    IsFlying = true

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then IsFlying = false if Callback then Callback() end return end
    if Hum.Health <= 0 then IsFlying = false if Callback then Callback() end return end

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

    FollowConnection = RunService.Heartbeat:Connect(function()
        if not AttackDroneEnabled then CleanupMovers() IsFlying = false return end
        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then CleanupMovers() IsFlying = false return end
        if Hum2.Health <= 0 then return end
        if not BodyVelocity or not BodyGyro then CleanupMovers() IsFlying = false return end

        local CurrentPos = Root2.Position
        local Direction = Destination - CurrentPos
        local TotalDist = math.floor(Direction.Magnitude)

        if TotalDist <= 2 then
            if BodyVelocity then
                BodyVelocity.Velocity = Vector3.zero
                BodyVelocity.MaxForce = Vector3.zero
            end
            if BodyGyro then
                BodyGyro.MaxTorque = Vector3.zero
            end

            task.wait(0.1)
            CleanupMovers()
            IsFlying = false

            Root2.CFrame = CFrame.new(Destination)
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero

            if Callback then Callback() end
            return
        end

        if tick() - StartTime > ARRIVE_TIMEOUT then
            CleanupMovers()
            IsFlying = false
            if Callback then Callback() end
            return
        end

        BodyVelocity.Velocity = Direction.Unit * FOLLOW_SPEED
        BodyGyro.CFrame = CFrame.new(CurrentPos, Destination)
    end)
end

-- ==================================================
-- STOP ATTACK
-- ==================================================
function StopAttack()
    print("[AttackDrone] Stop Attack")
    CleanupMovers()
    CurrentTarget = nil
    CurrentTargetPriority = nil
    SpawnLoopRunning = false
end

-- ==================================================
-- SPAWN LOOP
-- ==================================================
function SpawnLoop()
    if SpawnLoopRunning then return end
    SpawnLoopRunning = true

    task.spawn(function()
        while AttackDroneEnabled do
            local CurrentSpawn = (CurrentSpawnIndex == 1) and SPAWN_POSITION_1 or SPAWN_POSITION_2

            if CurrentTarget and CurrentTarget.Parent then
                task.wait(0.5)
                continue
            end

            print("[AttackDrone] Flying to Spawn " .. CurrentSpawnIndex)

            local Arrived = false
            FlyTPToPosition(CurrentSpawn, function() Arrived = true end)

            local WaitTime = 0
            while AttackDroneEnabled and not Arrived and WaitTime < ARRIVE_TIMEOUT do
                task.wait(0.1)
                WaitTime = WaitTime + 0.1
            end

            if not AttackDroneEnabled then break end
            task.wait(SPAWN_WAIT_TIME)
            if not AttackDroneEnabled then break end

            local Found = FindBestDrone()
            if Found and Found.Parent then
                print("[AttackDrone] Found Mob Top " .. tostring(GetDronePriority(Found)) .. " at Spawn " .. CurrentSpawnIndex)
                CurrentTarget = Found
                StartFollow()
                while AttackDroneEnabled and CurrentTarget and CurrentTarget.Parent do
                    task.wait(0.5)
                end
                print("[AttackDrone] Mob Cleared → Return to Spawn 1")
                CurrentSpawnIndex = 1
            else
                print("[AttackDrone] No Top 1/2/3 Mob at Spawn " .. CurrentSpawnIndex .. " → Switch")
                CurrentSpawnIndex = (CurrentSpawnIndex == 1) and 2 or 1
            end

            task.wait(0.2)
        end
        SpawnLoopRunning = false
    end)
end

-- ==================================================
-- FIRE REMOTE
-- ==================================================
local function FireAtDrone(Drone)
    if not Drone or not Drone.Parent then return end

    local isDrone = false
    for _, prefix in ipairs(SEARCH_PREFIXES) do
        if string.sub(Drone.Name, 1, #prefix) == prefix then
            isDrone = true
            break
        end
    end
    if not isDrone then return end

    local Remote = GetBatSwingRemote()
    if not Remote then return end

    local Hum, Root = GetHumanoid()
    if not Root then return end

    local DronePos = GetPosition(Drone)
    if not DronePos then return end

    local Dist = math.floor((DronePos - Root.Position).Magnitude)
    if Dist > ATTACK_RANGE then return end

    TraceSequence = TraceSequence + 1
    local TraceId = tostring(Player.UserId) .. ":" .. tostring(TraceSequence) .. ":" .. tostring(math.floor(workspace:GetServerTimeNow() * 1000))

    pcall(function() Remote:FireServer(Drone, TraceId) end)
end

-- ==================================================
-- MAIN ATTACK LOOP
-- ==================================================
function StartAttackLoop()
    if AttackConnection then AttackConnection:Disconnect() AttackConnection = nil end

    AttackConnection = RunService.Heartbeat:Connect(function()
        if not AttackDroneEnabled then return end
        if IsFlying then return end

        local Hum, Root = GetHumanoid()
        if not Hum or not Root then return end
        if Hum.Health <= 0 then return end

        EnsureStatsAlive()

        if not CurrentTarget or not CurrentTarget.Parent then
            local NewTarget, NewPriority = FindBestDrone()
            if NewTarget then
                CurrentTarget = NewTarget
                CurrentTargetPriority = NewPriority
                StartFollow()
            end
            return
        end

        local CurrentPriority = GetDronePriority(CurrentTarget)
        local BestDrone, BestPriority = FindBestDrone()

        if BestDrone and BestPriority and CurrentPriority and BestPriority < CurrentPriority then
            print("[AttackDrone] Higher Priority Detected! Switching...")
            CurrentTarget = BestDrone
            CurrentTargetPriority = BestPriority
            StartFollow()
            return
        end

        local now = tick()
        if now - LastFire >= ATTACK_INTERVAL then
            LastFire = now
            FireAtDrone(CurrentTarget)
        end
    end)
end

-- ==================================================
-- INITIAL FLY (Logic ចាស់ — Signed X Distance)
-- ==================================================
function InitialFlyAndStartLoop()
    local Hum, Root = GetHumanoid()
    if not Root then return end

    local PlayerPos = Root.Position
    local PlayerToPoint1Signed = math.floor(PlayerPos.X - POINT_1.X)

    print("========================================")
    print("[AttackDrone] Initial Fly Decision (Signed X)")
    print("  Player Pos:                       ", PlayerPos)
    print("  Signed (Player.X - Point1.X):     ", PlayerToPoint1Signed)
    print("========================================")

    if PlayerToPoint1Signed > 0 then
        print("[AttackDrone] → Signed > 0 (Player in FRONT) → Fly to Spawn 1")
        CurrentSpawnIndex = 1
        SpawnLoop()
    else
        print("[AttackDrone] → Signed <= 0 (Player at/behind) → Fly to Safe first")
        local SafeArrived = false
        FlyTPToPosition(SAFE_ZONE, function()
            SafeArrived = true
            print("[AttackDrone] ✅ Arrived at Safe Zone")
        end)

        local WaitTime = 0
        while AttackDroneEnabled and not SafeArrived and WaitTime < ARRIVE_TIMEOUT do
            task.wait(0.1)
            WaitTime = WaitTime + 0.1
        end

        if not AttackDroneEnabled then return end
        task.wait(SAFE_WAIT_TIME)
        print("[AttackDrone] Safe Zone Reached → Start Spawn Loop")
        CurrentSpawnIndex = 1
        SpawnLoop()
    end
end

-- ==================================================
-- START / STOP
-- ==================================================
local function StartAttack()
    if AttackDroneEnabled then return end
    AttackDroneEnabled = true

    SaveLiveStats()

    if _G.YOKUDO_AutoAttack then
        _G.YOKUDO_AutoAttack.EnableAutoEquip()
    end

    StartAttackLoop()

    print("[AttackDrone] Attack Drone: ON (Initial Fly Logic — Signed X)")

    task.spawn(function()
        InitialFlyAndStartLoop()
    end)
end

local function StopAttackDrone()
    if not AttackDroneEnabled then return end
    AttackDroneEnabled = false

    if AttackConnection then AttackConnection:Disconnect() AttackConnection = nil end

    CleanupMovers()
    CurrentTarget = nil
    CurrentTargetPriority = nil
    CurrentSpawnIndex = 1
    IsFlying = false
    SpawnLoopRunning = false

    RestoreLiveStats()

    if _G.YOKUDO_AutoAttack then
        _G.YOKUDO_AutoAttack.DisableAutoEquip()
    end

    local Hum, Root = GetHumanoid()
    if Root then
        pcall(function()
            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    print("[AttackDrone] Attack Drone: OFF")
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AttackDrone = {
    Start = StartAttack,
    Stop = StopAttackDrone,
    Enable = StartAttack,
    Disable = StopAttackDrone,
    Toggle = function()
        if AttackDroneEnabled then StopAttackDrone() else StartAttack() end
    end,
    IsEnabled = function() return AttackDroneEnabled end,
    StopAttack = StopAttack,
    SpawnLoop = SpawnLoop,
    InitialFlyAndStartLoop = InitialFlyAndStartLoop,
    FindAllDrones = FindAllDrones,
    FindBestDrone = FindBestDrone,
    GetDronePriority = GetDronePriority,
    GetBatSwingRemote = GetBatSwingRemote,
    GetSavedStats = function() return SavedStats end,
    SPAWN_POSITION_1 = SPAWN_POSITION_1,
    SPAWN_POSITION_2 = SPAWN_POSITION_2,
    SAFE_ZONE = SAFE_ZONE,
    POINT_1 = POINT_1,
    TIER_PRIORITY = TIER_PRIORITY,
    MAX_ALLOWED_PRIORITY = MAX_ALLOWED_PRIORITY,
    FOLLOW_SPEED = FOLLOW_SPEED
}

print("✅ AttackDrone Feature Loaded (Logic ចាស់ទាំងស្រុង + Register)")
