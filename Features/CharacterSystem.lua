-- ==================================================
-- YOKUDO HUB | CORE | Character System
-- គ្រប់គ្រង Character/Humanoid ទាំងអស់
-- ✅ Features Register ជាមួយ System
-- ✅ Auto Restart Features ពេល Character ថ្មី
-- ✅ Logic Features ដូចដើមទាំងអស់
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ==================================================
-- CHARACTER SYSTEM
-- ==================================================
local CharacterSystem = {}
CharacterSystem.Features = {}
CharacterSystem.CurrentCharacter = nil
CharacterSystem.CurrentHumanoid = nil
CharacterSystem.CurrentRoot = nil
CharacterSystem.Initialized = false
CharacterSystem.Restarting = false

-- ==================================================
-- GET HUMANOID
-- ==================================================
function CharacterSystem:GetHumanoid()
    local Char = Player.Character
    if not Char then return nil, nil end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    return Hum, Root
end

-- ==================================================
-- REGISTER FEATURE
-- ==================================================
-- Feature ត្រូវផ្តល់:
--   Name = "AntiAFK"
--   Enable = function() end
--   Disable = function() end
--   IsEnabled = function() return bool end
--   OnCharacterAdded = function(Char, Hum, Root) end (optional)
--   OnCharacterRemoving = function(Char, Hum, Root) end (optional)
-- ==================================================
function CharacterSystem:RegisterFeature(Feature)
    if not Feature or not Feature.Name then
        warn("[CharacterSystem] Invalid Feature")
        return
    end

    self.Features[Feature.Name] = Feature
    print("[CharacterSystem] Registered: " .. Feature.Name)

    -- ✅ បើ Character មានស្រាប់ ហើយ Feature កំពុងប្រើ → Re-Apply
    if self.CurrentCharacter and Feature.IsEnabled and Feature.IsEnabled() then
        if Feature.OnCharacterAdded then
            task.spawn(function()
                pcall(function()
                    Feature.OnCharacterAdded(self.CurrentCharacter, self.CurrentHumanoid, self.CurrentRoot)
                end)
            end)
        end
    end
end

-- ==================================================
-- UNREGISTER FEATURE
-- ==================================================
function CharacterSystem:UnregisterFeature(Name)
    if self.Features[Name] then
        self.Features[Name] = nil
        print("[CharacterSystem] Unregistered: " .. Name)
    end
end

-- ==================================================
-- RESTART ALL FEATURES
-- ==================================================
function CharacterSystem:RestartAllFeatures()
    if self.Restarting then return end
    self.Restarting = true

    print("[CharacterSystem] ========================================")
    print("[CharacterSystem] Restarting All Features...")
    print("[CharacterSystem] ========================================")

    for name, Feature in pairs(self.Features) do
        local IsEnabled = false
        if Feature.IsEnabled then
            pcall(function()
                IsEnabled = Feature.IsEnabled()
            end)
        end

        if IsEnabled then
            task.spawn(function()
                print("[CharacterSystem] Restarting: " .. name)

                -- ✅ Disable ចាស់
                if Feature.Disable then
                    pcall(function()
                        Feature.Disable()
                    end)
                end

                task.wait(0.3)

                -- ✅ Enable ថ្មី (Logic ដូច User ធីកដំបូង)
                if Feature.Enable then
                    pcall(function()
                        Feature.Enable()
                    end)
                end

                task.wait(0.2)

                -- ✅ OnCharacterAdded (Custom Logic)
                if Feature.OnCharacterAdded and self.CurrentCharacter then
                    pcall(function()
                        Feature.OnCharacterAdded(self.CurrentCharacter, self.CurrentHumanoid, self.CurrentRoot)
                    end)
                end

                print("[CharacterSystem] ✅ Restarted: " .. name)
            end)

            task.wait(0.2)
        end
    end

    task.wait(1)
    self.Restarting = false
    print("[CharacterSystem] All Features Restarted")
end

-- ==================================================
-- ON CHARACTER ADDED
-- ==================================================
function CharacterSystem:OnCharacterAdded(Char)
    print("[CharacterSystem] ========================================")
    print("[CharacterSystem] Character Added")
    print("[CharacterSystem] ========================================")

    self.CurrentCharacter = Char

    -- រង់ចាំ Humanoid
    local Hum = Char:WaitForChild("Humanoid", 10)
    local Root = Char:WaitForChild("HumanoidRootPart", 10)

    self.CurrentHumanoid = Hum
    self.CurrentRoot = Root

    if not Hum or not Root then
        warn("[CharacterSystem] Humanoid/Root not found")
        return
    end

    -- ✅ រង់ចាំ BypassAntiCheat Replace Humanoid
    task.wait(2)

    -- ✅ Update Humanoid/Root ថ្មី (បើ BypassAntiCheat Replace)
    Hum = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
    self.CurrentHumanoid = Hum
    self.CurrentRoot = Root

    if not Hum then
        warn("[CharacterSystem] Humanoid not found after wait")
        return
    end

    -- ✅ Restart Features ទាំងអស់
    self:RestartAllFeatures()
end

-- ==================================================
-- ON CHARACTER REMOVING
-- ==================================================
function CharacterSystem:OnCharacterRemoving(Char)
    print("[CharacterSystem] Character Removing")

    for name, Feature in pairs(self.Features) do
        if Feature.OnCharacterRemoving then
            pcall(function()
                Feature.OnCharacterRemoving(Char, self.CurrentHumanoid, self.CurrentRoot)
            end)
        end
    end

    self.CurrentCharacter = nil
    self.CurrentHumanoid = nil
    self.CurrentRoot = nil
end

-- ==================================================
-- INIT
-- ==================================================
function CharacterSystem:Init()
    if self.Initialized then return end
    self.Initialized = true

    -- ✅ Character បច្ចុប្បន្ន
    if Player.Character then
        task.spawn(function()
            self:OnCharacterAdded(Player.Character)
        end)
    end

    -- ✅ ចាប់ Character ថ្មី
    Player.CharacterAdded:Connect(function(Char)
        self:OnCharacterAdded(Char)
    end)

    -- ✅ ចាប់ Character Removing
    Player.CharacterRemoving:Connect(function(Char)
        self:OnCharacterRemoving(Char)
    end)

    print("[CharacterSystem] Initialized")
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_CharacterSystem = CharacterSystem

print("✅ CharacterSystem Loaded")
