-- ==================================================
-- YOKUDO HUB | FEATURE | Farming Manager (NEW)
-- បញ្ចូល Egg Check Logic ពី EggCheckPremium
-- គ្រប់គ្រង Day/Night
-- ហៅ AFKSystem ពេលអត់ឃើញ Egg
-- ហៅ VIPTP ពេលឃើញ Egg + Day
-- Night Check: 0.05s | Day Check: 0.5s
-- ✅ Callback ពី VIPTP ពេល AutoStop
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
-- SETTINGS
-- ==================================================
local NIGHT_CHECK_INTERVAL = 0.05
local DAY_CHECK_INTERVAL = 0.5
local SAFE_ZONE = Vector3.new(533, 70, -366)
local SAFE_ZONE_DIST = 5
local SAFE_WAIT_AFTER_REACH = 1
local FLY_SPEED = 1000
local SAFE_FLY_SPEED = 500
local RETURN_SPEED = 800
local FLY_OFFSET = 15
local METHOD = "InstantTeleport"

-- ==================================================
-- EGG CHECK PREMIUM (បញ្ចូលក្នុង FarmingManager)
-- ==================================================
local SelectedRarities = { Divine = true, Eternal = true, Secret = true }

local MeshIdMap = {}
local MeshIdMapBuilt = false

local RARITY_PRIORITY = {
    Divine = 1,
    Eternal = 2,
    Secret = 3
}

local function BuildMeshIdMap()
    if MeshIdMapBuilt then return end

    local Assets = ReplicatedStorage:FindFirstChild("Data")
    if not Assets then return end
    Assets = Assets:FindFirstChild("Assets")
    if not Assets then return end
    local Configs = Assets:FindFirstChild("Configs")
    local EggModels = ReplicatedStorage:FindFirstChild("Assets")
    if EggModels then EggModels = EggModels:FindFirstChild("Models") end
    if EggModels then EggModels = EggModels:FindFirstChild("Eggs") end
    if not Configs or not EggModels then return end

    for _, Config in ipairs(Configs:GetChildren()) do
        local Success, Module = pcall(function() return require(Config) end)
        if Success and Module and Module.Egg then
            local ModelName = Module.Egg.ModelName or Config.Name
            local Template = EggModels:FindFirstChild(ModelName)
            if Template then
                for _, Desc in ipairs(Template:GetDescendants()) do
                    if Desc:IsA("MeshPart") and Desc.MeshId ~= "" then
                        MeshIdMap[Desc.MeshId] = Config.Name
                    end
                    if Desc:IsA("SpecialMesh") and Desc.MeshId ~= "" then
                        MeshIdMap[Desc.MeshId] = Config.Name
                    end
                end
            end
        end
    end

    MeshIdMapBuilt = true
    print("[FarmingManager] MeshId Map Built: " .. tostring(#Configs:GetChildren()) .. " Configs")
end

local function GetPetData(AssetCategory)
    local Assets = ReplicatedStorage:FindFirstChild("Data")
    if not Assets then return nil end
    Assets = Assets:FindFirstChild("Assets")
    if not Assets then return nil end
    local Configs = Assets:FindFirstChild("Configs")
    if not Configs then return nil end

    local Config = Configs:FindFirstChild(AssetCategory)
    if not Config then return nil end

    local Success, Module = pcall(function() return require(Config) end)
    if not Success or not Module then return nil end

    return {
        Rarity = Module.Rarity and (Module.Rarity._id or Module.Rarity.RarityId) or nil,
        EarningRate = Module.EarningRate or 0,
        DisplayName = Module.DisplayName or AssetCategory
    }
end

local function FindAssetCategory(EggModel)
    if not MeshIdMapBuilt then BuildMeshIdMap() end

    for _, Desc in ipairs(EggModel:GetDescendants()) do
        if Desc:IsA("MeshPart") and Desc.MeshId ~= "" then
            local Cat = MeshIdMap[Desc.MeshId]
            if Cat then return Cat end
        end
        if Desc:IsA("SpecialMesh") and Desc.MeshId ~= "" then
            local Cat = MeshIdMap[Desc.MeshId]
            if Cat then return Cat end
        end
    end
    return nil
end

local function SortEggs(EggList)
    table.sort(EggList, function(a, b)
        local Pa = RARITY_PRIORITY[a.Rarity] or 999
        local Pb = RARITY_PRIORITY[b.Rarity] or 999
        if Pa ~= Pb then return Pa < Pb end
        return a.EarningRate > b.EarningRate
    end)
end

local function FindBestEgg()
    local Container = workspace:FindFirstChild("AreaEggSlotsClient")
    if not Container then return nil end

    local EggList = {}

    for _, Slot in ipairs(Container:GetChildren()) do
        if Slot:IsA("Model") then
            local Category = FindAssetCategory(Slot)
            if Category then
                local Data = GetPetData(Category)
                if Data and SelectedRarities[Data.Rarity] then
                    table.insert(EggList, {
                        Slot = Slot,
                        Uid = Slot.Name,
                        Rarity = Data.Rarity,
                        EarningRate = Data.EarningRate,
                        DisplayName = Data.DisplayName
                    })
                end
            end
        end
    end

    if #EggList == 0 then return nil end
    SortEggs(EggList)
    return EggList[1]
end

local function SetRarities(List)
    SelectedRarities = {}
    for _, r in ipairs(List) do
        SelectedRarities[r] = true
    end
    print("[FarmingManager] Rarities: " .. table.concat(List, ", "))
end

-- ==================================================
-- STATE
-- ==================================================
local FarmingEnabled = false
local CurrentState = "IDLE"
local CurrentPhase = "UNKNOWN"
local FarmingThread = nil
local AFKStarted = false
local PendingEggUid = nil
local WaitingForVIPTP = false

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
-- SELF FLY TP
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

    if _G.YOKUDO_VIPTP and _G.YOKUDO_VIPTP.IsEnabled() then
        _G.YOKUDO_VIPTP.Disable()
        print("[FarmingManager] ✅ VIPTP Stopped")
    end

    if _G.YOKUDO_TeleportSystem and _G.YOKUDO_TeleportSystem.IsEnabled() then
        _G.YOKUDO_TeleportSystem.Disable()
        print("[FarmingManager] ✅ TeleportSystem Stopped")
    end

    CleanupFly()
end

-- ==================================================
-- FLY TO SAFE ZONE AND WAIT
-- ==================================================
local function FlyToSafeZoneAndWait()
    local Hum, Root = GetHumanoid()
    if not Root then return false end

    local DistToSafe = (Root.Position - SAFE_ZONE).Magnitude

    if DistToSafe <= SAFE_ZONE_DIST then
        print("[FarmingManager] ✅ Already at Safe Zone")
        return true
    end

    print("[FarmingManager] Fly to Safe Zone (Speed: " .. SAFE_FLY_SPEED .. ")...")

    SelfFlyTP(SAFE_ZONE, SAFE_FLY_SPEED, function()
        print("[FarmingManager] ✅ At Safe Zone")
    end)

    local WaitTime = 0
    while FarmingEnabled and WaitTime < 10 do
        local Hum2, Root2 = GetHumanoid()
        if Root2 then
            local Dist = (Root2.Position - SAFE_ZONE).Magnitude
            if Dist <= SAFE_ZONE_DIST then
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
-- START VIPTP
-- ==================================================
local function StartVIPTP(EggUid)
    if not _G.YOKUDO_VIPTP then
        warn("[FarmingManager] VIPTP not loaded!")
        return
    end

    print("[FarmingManager] Starting VIPTP:")
    print("  - Target UID: " .. tostring(EggUid))

    WaitingForVIPTP = true
    _G.YOKUDO_VIPTP.SetTargetId(EggUid)
    _G.YOKUDO_VIPTP.Enable()
end

-- ==================================================
-- ✅ CALLBACK ពី VIPTP (ពេល AutoStop)
-- ==================================================
local function OnVIPTPComplete()
    if not FarmingEnabled then return end
    if not WaitingForVIPTP then return end

    WaitingForVIPTP = false
    print("[FarmingManager] ✅ VIPTP Completed → Check New Egg")

    -- ពិនិត្យ Egg ថ្មីភ្លាមៗ
    local BestEgg = FindBestEgg()

    if BestEgg then
        print("[FarmingManager] New Egg Found: " .. BestEgg.DisplayName)
        PendingEggUid = BestEgg.Uid

        -- ហោះទៅ Safe Zone ជាមុន រួចចាប់ផ្តើម VIPTP
        task.spawn(function()
            local ReachedSafe = FlyToSafeZoneAndWait()
            if ReachedSafe and PendingEggUid then
                task.wait(SAFE_WAIT_AFTER_REACH)
                StartVIPTP(PendingEggUid)
                PendingEggUid = nil
            end
        end)
    else
        print("[FarmingManager] No New Egg → AFK")
        if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
            _G.YOKUDO_AFKSystem.Enable()
            AFKStarted = true
        end
    end
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
                print("[FarmingManager] Waiting at Safe Zone for Day...")
                task.wait(SAFE_WAIT_AFTER_REACH)

                local IsDay = WaitForDay()

                if IsDay and PendingEggUid then
                    print("[FarmingManager] ✅ Day Reached → Start VIPTP")
                    StartVIPTP(PendingEggUid)
                    PendingEggUid = nil

                    -- រង់ចាំ VIPTP ចប់ (Callback នឹងហៅ OnVIPTPComplete)
                    while WaitingForVIPTP and FarmingEnabled do
                        task.wait(0.5)
                    end
                end
            end

            return
        else
            if not AFKStarted then
                if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                    _G.YOKUDO_AFKSystem.Enable()
                    AFKStarted = true
                    print("[FarmingManager] AFK Started (No Egg)")
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

            StartVIPTP(BestEgg.Uid)

            -- រង់ចាំ VIPTP ចប់ (Callback នឹងហៅ OnVIPTPComplete)
            while WaitingForVIPTP and FarmingEnabled do
                task.wait(0.5)
            end
        else
            if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                _G.YOKUDO_AFKSystem.Enable()
                AFKStarted = true
                print("[FarmingManager] AFK Started (No Egg)")
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
        CurrentPhase = Phase

        print("[FarmingManager] Phase: " .. Phase)

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
    WaitingForVIPTP = false

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

    AFKStarted = false
    PendingEggUid = nil
    WaitingForVIPTP = false
    CurrentState = "IDLE"
    CurrentPhase = "UNKNOWN"
    print("[YOKUDO] FarmingManager: OFF")
end

local function Toggle()
    if FarmingEnabled then Disable() else Enable() end
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
    FindBestEgg = FindBestEgg,
    NIGHT_CHECK_INTERVAL = NIGHT_CHECK_INTERVAL,
    DAY_CHECK_INTERVAL = DAY_CHECK_INTERVAL,
    FLY_SPEED = FLY_SPEED,
    SAFE_FLY_SPEED = SAFE_FLY_SPEED,
    RETURN_SPEED = RETURN_SPEED,
    FLY_OFFSET = FLY_OFFSET,
    METHOD = METHOD,
    -- ✅ Callback សម្រាប់ VIPTP
    OnVIPTPComplete = OnVIPTPComplete,
}


-- ==================================================
-- BUILD MESHID MAP ON LOAD
-- ==================================================
task.spawn(function()
    task.wait(2)
    BuildMeshIdMap()
end)

print("✅ FarmingManager Loaded (Egg Check + Day/Night + AFK + VIPTP + Callback)")
