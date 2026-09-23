-- ==================================================
-- YOKUDO HUB | FEATURE | Egg Check Premium
-- ជ្រើសរើស Egg តាម Rarity (Divine > Eternal > Secret) និង $/s
-- ✅ Register ជាមួយ CharacterSystem
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- ==================================================
-- STATE
-- ==================================================
local SelectedRarities = {}

-- ==================================================
-- MESHID MAP
-- ==================================================
local MeshIdMap = {}
local MeshIdMapBuilt = false

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
    print("[EggCheckPremium] MeshId Map Built: " .. tostring(#Configs:GetChildren()) .. " Configs")
end

-- ==================================================
-- GET PET DATA
-- ==================================================
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

-- ==================================================
-- FIND ASSET CATEGORY
-- ==================================================
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

-- ==================================================
-- SORT EGG (Divine > Eternal > Secret > $/s)
-- ==================================================
local RARITY_PRIORITY = {
    Divine = 1,
    Eternal = 2,
    Secret = 3
}

local function SortEggs(EggList)
    table.sort(EggList, function(a, b)
        local Pa = RARITY_PRIORITY[a.Rarity] or 999
        local Pb = RARITY_PRIORITY[b.Rarity] or 999
        if Pa ~= Pb then return Pa < Pb end
        return a.EarningRate > b.EarningRate
    end)
end

-- ==================================================
-- FIND BEST EGG
-- ==================================================
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

-- ==================================================
-- FIND ALL EGGS
-- ==================================================
local function FindAllEggs()
    local Container = workspace:FindFirstChild("AreaEggSlotsClient")
    if not Container then return {} end

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

    SortEggs(EggList)
    return EggList
end

-- ==================================================
-- CHECK EGG BY RARITY
-- ==================================================
local function GetEggsByRarity(Rarity)
    local AllEggs = FindAllEggs()
    local Filtered = {}
    
    for _, Egg in ipairs(AllEggs) do
        if Egg.Rarity == Rarity then
            table.insert(Filtered, Egg)
        end
    end
    
    return Filtered
end

-- ==================================================
-- SET RARITIES
-- ==================================================
local function SetRarities(List)
    SelectedRarities = {}
    for _, r in ipairs(List) do
        SelectedRarities[r] = true
    end
    print("[EggCheckPremium] Rarities: " .. table.concat(List, ", "))
end

local function GetRarities()
    local List = {}
    for r, _ in pairs(SelectedRarities) do
        table.insert(List, r)
    end
    return List
end

-- ==================================================
-- BUILD MESHID MAP ON LOAD
-- ==================================================
task.spawn(function()
    task.wait(1)
    BuildMeshIdMap()
end)

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_EggCheckPremium = {
    SetRarities = SetRarities,
    GetRarities = GetRarities,
    FindBestEgg = FindBestEgg,
    FindAllEggs = FindAllEggs,
    GetEggsByRarity = GetEggsByRarity,
    SortEggs = SortEggs,
    GetPetData = GetPetData,
    FindAssetCategory = FindAssetCategory,
    BuildMeshIdMap = BuildMeshIdMap,
    RARITY_PRIORITY = RARITY_PRIORITY
}

print("✅ EggCheckPremium Feature Loaded (Register)")
