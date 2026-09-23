-- ==================================================
-- YOKUDO HUB | FEATURE | Farming Manager
-- ✅ SelfFlyTP ទៅ Safe Zone ប្រើ Speed 500
-- ✅ មិន Lock ពេលដល់ Safe Zone
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- ==================================================
-- AREA EGG CYCLE
-- ==================================================
local AreaEggCycle = nil

pcall(function()
    AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
end)

if not AreaEggCycle then
    warn("[FarmingManager] AreaEggCycle not found! Using fallback.")
end

-- ==================================================
-- FIXED SETTINGS
-- ==================================================
local NIGHT_CHECK_INTERVAL = 0.05
local DAY_CHECK_INTERVAL = 0.5
local SAFE_ZONE = Vector3.new(533, 70, -366)
local SAFE_ZONE_DIST = 5
local SAFE_WAIT_AFTER_REACH = 5

local FLY_SPEED = 1000       -- ✅ សម្រាប់ TeleportSystem
local SAFE_FLY_SPEED = 500   -- ✅ សម្រាប់ Fly ទៅ Safe Zone (ថ្មី)
local RETURN_SPEED = 800
local FLY_OFFSET = 10
local METHOD = "InstantTeleport"

-- ==================================================
-- STATE
-- ==================================================
local FarmingEnabled = false
local CurrentState = "IDLE"
local CurrentPhase = "UNKNOWN"
local FarmingThread = nil
local IsAtSafeZone = false
local WaitingForDay = false
local AFKStarted = false
local PendingEggUid = nil

-- ==================================================
-- FLY TP STATE
-- ==================================================
local FlyConnection = nil
local BodyVelocity = nil
local BodyGyro = nil

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
-- CLEANUP FLY
-- ==================================================
local function CleanupFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
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
end

-- ==================================================
-- ✅ SELF FLY TP (មាន Speed Parameter)
-- ==================================================
local function SelfFlyTP(Destination, Speed, Callback)
    CleanupFly()

    local Hum, Root = GetHumanoid()
    if not Hum or not Root then
        if Callback then Callback() end
        return
    end
    if Hum.Health <= 0 then
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
        if not FarmingEnabled then
            CleanupFly()
            return
        end

        local Hum2, Root2 = GetHumanoid()
        if not Hum2 or not Root2 then
            CleanupFly()
            return
        end
        if Hum2.Health <= 0 then return end
        if not BodyVelocity or not BodyGyro then CleanupFly() return end

        local CurrentPos = Root2.Position
        local Direction = Destination - CurrentPos
        local TotalDist = Direction.Magnitude

        if TotalDist <= 3 then
            CleanupFly()
            Root2.CFrame = CFrame.new(Destination)
            Root2.AssemblyLinearVelocity = Vector3.zero
            Root2.AssemblyAngularVelocity = Vector3.zero
            if Callback then Callback() end
            return
        end

        if tick() - StartTime > 30 then
            CleanupFly()
            if Callback then Callback() end
            return
        end

        BodyVelocity.Velocity = Direction.Unit * Speed
        BodyGyro.CFrame = CFrame.new(CurrentPos, Destination)
    end)
end

-- ==================================================
-- GET PHASE
-- ==================================================
local function GetPhase()
    if AreaEggCycle then
        local Success, IsNight = pcall(function()
            return AreaEggCycle.IsNightPhase(Workspace:GetServerTimeNow())
        end)
        
        if Success then
            if IsNight then
                return "Night"
            else
                return "Day"
            end
        end
    end
    
    local Success, Text = pcall(function()
        return Player.PlayerGui.HUD.GameHUD.BottomRight.NightTimer.Value.Text
    end)
    
    if Success and Text then
        local M = tonumber(string.match(Text, "(%d+)m")) or 0
        local S = tonumber(string.match(Text, "(%d+)s")) or 0
        local Sec = M * 60 + S
        if Sec > 10 then
            return "Day"
        else
            return "Night"
        end
    end
    
    return "UNKNOWN"
end

local function GetSecondsUntilReset()
    if AreaEggCycle then
        local Success, Sec = pcall(function()
            return AreaEggCycle.SecondsUntilReset(Workspace:GetServerTimeNow())
        end)
        if Success then return Sec end
    end
    return 0
end

-- ==================================================
-- FIND BEST EGG
-- ==================================================
local function FindBestEgg()
    if _G.YOKUDO_EggCheckPremium then
        return _G.YOKUDO_EggCheckPremium.FindBestEgg()
    end
    return nil
end

-- ==================================================
-- STOP ALL
-- ==================================================
local function StopAll()
    if _G.YOKUDO_AFKSystem and _G.YOKUDO_AFKSystem.IsEnabled() then
        local TreadmillPos = _G.YOKUDO_AFKSystem.GetMyTreadmillPos()
        if not TreadmillPos then
            local _, Treadmill = _G.YOKUDO_AFKSystem.FindMyPlotAndTreadmill()
            if Treadmill then
                TreadmillPos = Treadmill.Position
            end
        end

        if TreadmillPos then
            _G.YOKUDO_AFKSystem.JumpOutTreadmill(TreadmillPos, function()
                _G.YOKUDO_AFKSystem.Disable()
                AFKStarted = false
                print("[FarmingManager] ✅ AFK Stopped + Jumped out!")
            end)
        else
            _G.YOKUDO_AFKSystem.Disable()
            AFKStarted = false
        end
    end

    if _G.YOKUDO_TeleportSystem and _G.YOKUDO_TeleportSystem.IsEnabled() then
        _G.YOKUDO_TeleportSystem.Disable()
        print("[FarmingManager] ✅ TeleportSystem Stopped")
    end

    CleanupFly()
end

-- ==================================================
-- ✅ FLY TO SAFE ZONE AND WAIT (ប្រើ Speed 500)
-- ==================================================
local function FlyToSafeZoneAndWait()
    local Hum, Root = GetHumanoid()
    if not Root then return false end

    local DistToSafe = (Root.Position - SAFE_ZONE).Magnitude

    if DistToSafe <= SAFE_ZONE_DIST then
        IsAtSafeZone = true
        print("[FarmingManager] ✅ Already at Safe Zone")
        return true
    end

    print("[FarmingManager] Fly to Safe Zone (Speed: " .. SAFE_FLY_SPEED .. ")...")

    -- ✅ ប្រើ SelfFlyTP ជាមួយ Speed 500
    SelfFlyTP(SAFE_ZONE, SAFE_FLY_SPEED, function()
        IsAtSafeZone = true
        print("[FarmingManager] ✅ At Safe Zone")
    end)

    -- រង់ចាំដល់ Safe Zone ពិតប្រាកដ
    local WaitTime = 0
    while FarmingEnabled and WaitTime < 10 do
        local Hum2, Root2 = GetHumanoid()
        if Root2 then
            local Dist = (Root2.Position - SAFE_ZONE).Magnitude
            if Dist <= SAFE_ZONE_DIST then
                IsAtSafeZone = true
                print("[FarmingManager] ✅ Reached Safe Zone (Dist: " .. math.floor(Dist) .. ")")
                return true
            end
        end
        task.wait(0.1)
        WaitTime = WaitTime + 0.1
    end

    print("[FarmingManager] ⚠️ Safe Zone Wait Timeout")
    return false
end

-- ==================================================
-- START TELEPORT
-- ==================================================
local function StartTeleport(EggUid)
    if not _G.YOKUDO_TeleportSystem then
        warn("[FarmingManager] TeleportSystem not loaded!")
        return
    end

    print("[FarmingManager] Starting Teleport:")
    print("  - Target UID: " .. tostring(EggUid))
    print("  - Method: " .. METHOD)

    _G.YOKUDO_TeleportSystem.SetMethod(METHOD)
    _G.YOKUDO_TeleportSystem.SetSpeed(FLY_SPEED)
    _G.YOKUDO_TeleportSystem.SetTargetId(EggUid)
    _G.YOKUDO_TeleportSystem.Enable()
end

-- ==================================================
-- WAIT FOR DAY
-- ==================================================
local function WaitForDay()
    print("[FarmingManager] Waiting for Day...")

    while FarmingEnabled do
        local Phase = GetPhase()
        CurrentPhase = Phase

        if Phase == "Day" then
            print("[FarmingManager] ✅ Day Started!")
            return true
        end

        task.wait(DAY_CHECK_INTERVAL)
    end

    return false
end

-- ==================================================
-- NIGHT LOOP
-- ==================================================
local function NightLoop()
    print("[FarmingManager] NightLoop Started (0.05s)")

    while FarmingEnabled do
        local Phase = GetPhase()
        CurrentPhase = Phase

        if Phase == "Day" then
            print("[FarmingManager] Day Started → Break NightLoop")
            return
        end

        local BestEgg = FindBestEgg()

        if BestEgg then
            print("[FarmingManager] ✅ Night + Egg Spawn: " .. BestEgg.DisplayName)

            PendingEggUid = BestEgg.Uid

            StopAll()
            task.wait(0.5)

            local ReachedSafe = FlyToSafeZoneAndWait()

            if ReachedSafe then
                print("[FarmingManager] Waiting 5s at Safe Zone...")
                task.wait(SAFE_WAIT_AFTER_REACH)

                local IsDay = WaitForDay()

                if IsDay and PendingEggUid then
                    print("[FarmingManager] ✅ Day Reached → Start Teleport")
                    StartTeleport(PendingEggUid)

                    while _G.YOKUDO_TeleportSystem and _G.YOKUDO_TeleportSystem.IsEnabled() do
                        task.wait(0.5)
                        if not FarmingEnabled then break end
                    end

                    PendingEggUid = nil
                end
            end

            return
        else
            if not AFKStarted then
                if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                    _G.YOKUDO_AFKSystem.Enable()
                    AFKStarted = true
                    print("[FarmingManager] AFK Started")
                end
            end
        end

        task.wait(NIGHT_CHECK_INTERVAL)
    end
end

-- ==================================================
-- DAY LOOP
-- ==================================================
local function DayLoop()
    print("[FarmingManager] DayLoop Started (0.5s)")

    while FarmingEnabled do
        local Phase = GetPhase()
        CurrentPhase = Phase

        if Phase == "Night" then
            print("[FarmingManager] Night Started → Break DayLoop")
            return
        end

        local BestEgg = FindBestEgg()

        if BestEgg then
            print("[FarmingManager] ✅ Day + Egg: " .. BestEgg.DisplayName)

            StopAll()
            task.wait(0.5)

            FlyToSafeZoneAndWait()
            task.wait(1)

            StartTeleport(BestEgg.Uid)

            while _G.YOKUDO_TeleportSystem and _G.YOKUDO_TeleportSystem.IsEnabled() do
                task.wait(0.5)
                if not FarmingEnabled then break end
            end
        else
            if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                _G.YOKUDO_AFKSystem.Enable()
                AFKStarted = true
            end
        end

        task.wait(DAY_CHECK_INTERVAL)
    end
end

-- ==================================================
-- MAIN LOOP
-- ==================================================
local function MainLoop()
    print("[FarmingManager] MainLoop Started")

    while FarmingEnabled do
        local Phase = GetPhase()
        local Sec = GetSecondsUntilReset()
        CurrentPhase = Phase

        print("[FarmingManager] Phase: " .. Phase .. " | SecUntilReset: " .. math.floor(Sec))

        if Phase == "Day" then
            DayLoop()
        else
            NightLoop()
        end

        task.wait(0.1)
    end
    print("[FarmingManager] MainLoop Stopped")
end

-- ==================================================
-- ENABLE / DISABLE
-- ==================================================
local function Enable()
    if FarmingEnabled then return end
    FarmingEnabled = true
    CurrentState = "CHECK_TIME"
    AFKStarted = false
    PendingEggUid = nil

    if FarmingThread then
        pcall(function() task.cancel(FarmingThread) end)
        FarmingThread = nil
    end
    FarmingThread = task.spawn(function() MainLoop() end)

    print("[YOKUDO] FarmingManager: ON")
end

local function Disable()
    if not FarmingEnabled then return end
    FarmingEnabled = false

    if FarmingThread then
        pcall(function() task.cancel(FarmingThread) end)
        FarmingThread = nil
    end

    StopAll()

    IsAtSafeZone = false
    WaitingForDay = false
    AFKStarted = false
    PendingEggUid = nil
    CurrentState = "IDLE"
    CurrentPhase = "UNKNOWN"
    print("[YOKUDO] FarmingManager: OFF")
end

local function Toggle()
    if FarmingEnabled then Disable() else Enable() end
end

local function SetRarities(List)
    if _G.YOKUDO_EggCheckPremium then
        _G.YOKUDO_EggCheckPremium.SetRarities(List)
    end
    print("[YOKUDO] FarmingManager Rarities: " .. table.concat(List, ", "))
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_FarmingManager = {
    Enable = Enable,
    Disable = Disable,
    Toggle = Toggle,
    IsEnabled = function() return FarmingEnabled end,
    SetRarities = SetRarities,
    GetState = function() return CurrentState end,
    GetPhase = function() return CurrentPhase end,
    GetSecondsUntilReset = GetSecondsUntilReset,
    NIGHT_CHECK_INTERVAL = NIGHT_CHECK_INTERVAL,
    DAY_CHECK_INTERVAL = DAY_CHECK_INTERVAL,
    FLY_SPEED = FLY_SPEED,
    SAFE_FLY_SPEED = SAFE_FLY_SPEED,
    RETURN_SPEED = RETURN_SPEED,
    FLY_OFFSET = FLY_OFFSET,
    METHOD = METHOD
}

-- ==================================================
-- REGISTER WITH CHARACTER SYSTEM
-- ==================================================
if _G.YOKUDO_CharacterSystem then
    _G.YOKUDO_CharacterSystem:RegisterFeature({
        Name = "FarmingManager",
        Enable = Enable,
        Disable = Disable,
        IsEnabled = function() return FarmingEnabled end,
        OnCharacterAdded = function(Char, Hum, Root)
            if FarmingEnabled then
                task.wait(1)
                if FarmingThread then
                    pcall(function() task.cancel(FarmingThread) end)
                end
                FarmingThread = task.spawn(function() MainLoop() end)
            end
        end
    })
end

print("✅ FarmingManager Feature Loaded (Safe Zone Speed 500 + No Lock)")
