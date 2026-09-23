--==================================================
-- YOKUDO HUB | FEATURE | Auto Farm
-- Check Egg + Display Card + Select + Send to Teleport
-- ✅ Register ជាមួយ CharacterSystem
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Container = workspace:WaitForChild("AreaEggSlotsClient")

--==================================================
-- VARIABLES
--==================================================
local AutoFarmEnabled = false
local SelectedEgg = nil
local EggList = {}

--==================================================
-- ASSETS
--==================================================
local Assets = ReplicatedStorage:WaitForChild("Data"):WaitForChild("Assets")
local Configs = Assets:WaitForChild("Configs")
local EggModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Eggs")

--==================================================
-- MESHID MAP
--==================================================
local MeshIdToCategory = {}

local function BuildMeshIdMap()
    for _, Config in ipairs(Configs:GetChildren()) do
        local Success, Module = pcall(function()
            return require(Config)
        end)
        if Success and Module and Module.Egg then
            local ModelName = Module.Egg.ModelName or Config.Name
            local EggTemplate = EggModels:FindFirstChild(ModelName)
            if EggTemplate then
                for _, descendant in ipairs(EggTemplate:GetDescendants()) do
                    if descendant:IsA("MeshPart") and descendant.MeshId ~= "" then
                        MeshIdToCategory[descendant.MeshId] = Config.Name
                    end
                    if descendant:IsA("SpecialMesh") and descendant.MeshId ~= "" then
                        MeshIdToCategory[descendant.MeshId] = Config.Name
                    end
                end
            end
        end
    end
end

BuildMeshIdMap()

--==================================================
-- GET PET DATA
--==================================================
local function GetPetData(AssetCategory)
    local Config = Configs:FindFirstChild(AssetCategory)
    if not Config then return nil end
    
    local Data = {
        Name = AssetCategory,
        DisplayName = AssetCategory,
        EarningRate = 0,
        Icon = nil
    }
    
    local Success, Module = pcall(function()
        return require(Config)
    end)
    
    if Success and Module then
        Data.DisplayName = Module.DisplayName or AssetCategory
        Data.EarningRate = Module.EarningRate or 0
        Data.Icon = Module.Icon
    end
    
    return Data
end

--==================================================
-- FORMAT MONEY
--==================================================
local function FormatMoney(Amount)
    if type(Amount) ~= "number" then return tostring(Amount) end
    if Amount >= 1e12 then
        return string.format("%.2fT", Amount / 1e12)
    elseif Amount >= 1e9 then
        return string.format("%.2fB", Amount / 1e9)
    elseif Amount >= 1e6 then
        return string.format("%.2fM", Amount / 1e6)
    elseif Amount >= 1e3 then
        return string.format("%.2fK", Amount / 1e3)
    else
        return tostring(math.floor(Amount))
    end
end

--==================================================
-- CALCULATE REAL RATE
--==================================================
local function CalculateRatePerSecond(EarningRate, Scale, Mutations)
    local PayoutFactor
    if Scale <= 5 then
        PayoutFactor = Scale ^ 1.85
    else
        PayoutFactor = (Scale / 5) ^ 1.2 * 19.637875755794113
    end
    
    local MutationMultiplier = 1
    if Mutations and #Mutations > 0 then
        local Success, MutationsModule = pcall(function()
            return require(ReplicatedStorage.Shared.Modules.Mutations)
        end)
        if Success and MutationsModule then
            MutationMultiplier = MutationsModule.EarningsFor(Mutations)
        end
    end
    
    return math.round(EarningRate * PayoutFactor * MutationMultiplier)
end

--==================================================
-- FIND ASSET CATEGORY
--==================================================
local function FindAssetCategory(EggModel)
    for _, descendant in ipairs(EggModel:GetDescendants()) do
        if descendant:IsA("MeshPart") and descendant.MeshId ~= "" then
            local Category = MeshIdToCategory[descendant.MeshId]
            if Category then return Category end
        end
        if descendant:IsA("SpecialMesh") and descendant.MeshId ~= "" then
            local Category = MeshIdToCategory[descendant.MeshId]
            if Category then return Category end
        end
    end
    return nil
end

--==================================================
-- SCAN EGGS
--==================================================
local function ScanEggs()
    EggList = {}
    
    for _, child in ipairs(Container:GetChildren()) do
        if child:IsA("Model") then
            local AssetCategory = FindAssetCategory(child)
            if AssetCategory then
                local Data = GetPetData(AssetCategory)
                if Data then
                    local Scale = child:GetAttribute("AssetScale") or 1
                    local Mutations = child:GetAttribute("Mutations") or {}
                    local RealRate = CalculateRatePerSecond(Data.EarningRate, Scale, Mutations)
                    
                    table.insert(EggList, {
                        Id = child.Name,
                        Category = AssetCategory,
                        DisplayName = Data.DisplayName,
                        Icon = Data.Icon,
                        EarningRate = RealRate,
                        Model = child
                    })
                end
            end
        end
    end
    
    table.sort(EggList, function(a, b)
        return a.EarningRate > b.EarningRate
    end)
    
    return EggList
end

--==================================================
-- ENABLE / DISABLE
--==================================================
local function EnableAutoFarm()
    AutoFarmEnabled = true
    print("[YOKUDO] Auto Farm: ON")
end

local function DisableAutoFarm()
    AutoFarmEnabled = false
    print("[YOKUDO] Auto Farm: OFF")
end

--==================================================
-- SELECT EGG (Save only, NO Teleport)
--==================================================
local function SelectEgg(EggData)
    SelectedEgg = EggData
    print("[YOKUDO] Selected Egg: " .. EggData.DisplayName .. " ($" .. FormatMoney(EggData.EarningRate) .. "/s)")
end

--==================================================
-- START TELEPORT (Called on Start button)
--==================================================
local function StartTeleport()
    if not SelectedEgg then
        warn("[YOKUDO] No Egg Selected")
        return
    end

    local Method = _G.YOKUDO_SelectedMethod or "TeleportFly"
    local Speed = _G.YOKUDO_TeleportSpeed or 300

    print("[YOKUDO] Start Teleport | Method: " .. Method .. " | Speed: " .. tostring(Speed) .. " | Target: " .. SelectedEgg.Id)

    if _G.YOKUDO_TeleportSystem then
        _G.YOKUDO_TeleportSystem.SetMethod(Method)
        _G.YOKUDO_TeleportSystem.SetSpeed(Speed)
        _G.YOKUDO_TeleportSystem.SetTargetId(SelectedEgg.Id)
        _G.YOKUDO_TeleportSystem.Enable()
    end
end

--==================================================
-- STOP TELEPORT (Called on Stop button)
--==================================================
local function StopTeleport()
    if _G.YOKUDO_TeleportSystem then
        _G.YOKUDO_TeleportSystem.Disable()
    end
    print("[YOKUDO] Stop Teleport")
end

--==================================================
-- EXPORT
--==================================================
_G.YOKUDO_AutoFarm = {
    Enable = EnableAutoFarm,
    Disable = DisableAutoFarm,
    IsEnabled = function() return AutoFarmEnabled end,
    ScanEggs = ScanEggs,
    GetEggList = function() return EggList end,
    SelectEgg = SelectEgg,
    StartTeleport = StartTeleport,
    StopTeleport = StopTeleport,
    GetSelectedEgg = function() return SelectedEgg end,
    FormatMoney = FormatMoney
}

--==================================================
-- REGISTER WITH CHARACTER SYSTEM
--==================================================
if _G.YOKUDO_CharacterSystem then
    _G.YOKUDO_CharacterSystem:RegisterFeature({
        Name = "AutoFarm",
        Enable = EnableAutoFarm,
        Disable = DisableAutoFarm,
        IsEnabled = function() return AutoFarmEnabled end,
        OnCharacterAdded = function(Char, Hum, Root)
            -- ✅ AutoFarm មិនត្រូវការ Re-Apply ពិសេស
            -- ព្រោះវាគ្រាន់តែ Scan Eggs និង Select
            -- TeleportSystem ជាអ្នកធ្វើការ
            if AutoFarmEnabled and SelectedEgg then
                task.wait(2)
                pcall(function()
                    -- Restart Teleport បើកំពុងប្រើ
                    if _G.YOKUDO_TeleportSystem and _G.YOKUDO_TeleportSystem.IsEnabled() then
                        StartTeleport()
                    end
                end)
            end
        end
    })
end

print("✅ AutoFarm Feature Loaded (Register)")
