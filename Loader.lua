-- ==================================================
-- YOKUDO HUB | STEAL AN EGG | Loader
-- ✅ Load CharacterSystem មុន Features
-- ==================================================

local BASE_URL = "https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/"

_G.YOKUDO_EnablePrint = false

local oldPrint = print
print = function(...)
    if _G.YOKUDO_EnablePrint then
        oldPrint(...)
    end
end

print("🔵 Loading YOKUDO HUB...")

-- ==================================================
-- CACHE SYSTEM
-- ==================================================
_G.YOKUDO_Cache = _G.YOKUDO_Cache or {}

local function GetScript(path)
    local fullPath = BASE_URL .. path
    if _G.YOKUDO_Cache[fullPath] then
        return _G.YOKUDO_Cache[fullPath]
    end
    local script = game:HttpGet(fullPath)
    _G.YOKUDO_Cache[fullPath] = script
    return script
end

-- ==================================================
-- WAIT UNTIL GAME IS LOADED
-- ==================================================
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

print("✅ Game loaded, Player: " .. Player.Name)

-- ==================================================
-- CREATE LOADING SCREEN
-- ==================================================
local function CreateLoadingScreen()
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.IgnoreGuiInset = true
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingGui.DisplayOrder = 9999
    LoadingGui.Parent = CoreGui

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 280, 0, 110)
    Container.Position = UDim2.new(0.5, -140, 0.5, -55)
    Container.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
    Container.BackgroundTransparency = 0.1
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = LoadingGui

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 14)
    ContainerCorner.Parent = Container

    local ContainerBorder = Instance.new("UIStroke")
    ContainerBorder.Color = Color3.fromRGB(105, 90, 190)
    ContainerBorder.Thickness = 2
    ContainerBorder.Transparency = 0.2
    ContainerBorder.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -30, 0, 28)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "YOKUDO HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Container

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -30, 0, 14)
    Subtitle.Position = UDim2.new(0, 15, 0, 36)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Steal An Egg"
    Subtitle.TextColor3 = Color3.fromRGB(145, 145, 175)
    Subtitle.TextSize = 9
    Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    Subtitle.TextYAlignment = Enum.TextYAlignment.Center
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Parent = Container

    local BarBg = Instance.new("Frame")
    BarBg.Name = "BarBg"
    BarBg.Size = UDim2.new(0.75, 0, 0, 4)
    BarBg.Position = UDim2.new(0.125, 0, 0.5, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    BarBg.BorderSizePixel = 0
    BarBg.Parent = Container

    local BarBgCorner = Instance.new("UICorner")
    BarBgCorner.CornerRadius = UDim.new(1, 0)
    BarBgCorner.Parent = BarBg

    local Bar = Instance.new("Frame")
    Bar.Name = "Bar"
    Bar.Size = UDim2.new(0, 0, 1, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    Bar.BorderSizePixel = 0
    Bar.Parent = BarBg

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Percent = Instance.new("TextLabel")
    Percent.Name = "Percent"
    Percent.Size = UDim2.new(1, -30, 0, 22)
    Percent.Position = UDim2.new(0, 15, 0.7, 0)
    Percent.BackgroundTransparency = 1
    Percent.Text = "0%"
    Percent.TextColor3 = Color3.fromRGB(105, 90, 190)
    Percent.TextSize = 18
    Percent.TextXAlignment = Enum.TextXAlignment.Center
    Percent.TextYAlignment = Enum.TextYAlignment.Center
    Percent.Font = Enum.Font.GothamBold
    Percent.Parent = Container

    local function UpdateProgress(percent)
        percent = math.clamp(percent, 0, 100)
        Bar.Size = UDim2.new(percent / 100, 0, 1, 0)
        Percent.Text = math.floor(percent) .. "%"
    end

    return {
        Gui = LoadingGui,
        Update = UpdateProgress,
        Destroy = function()
            LoadingGui:Destroy()
        end
    }
end

-- ==================================================
-- CREATE LOADING SCREEN
-- ==================================================
local Loading = CreateLoadingScreen()
Loading.Update(5)

-- ==================================================
-- LOAD CORE FILES
-- ==================================================
Loading.Update(10)
loadstring(GetScript("Config.lua"))()

Loading.Update(15)
loadstring(GetScript("UI.lua"))()

Loading.Update(20)
loadstring(GetScript("Components.lua"))()

-- ==================================================
-- LOAD TABS MANAGER
-- ==================================================
Loading.Update(25)
loadstring(GetScript("Tabs/Init.lua"))()

-- ==================================================
-- ✅ LOAD CHARACTER SYSTEM (មុន Features)
-- ==================================================
Loading.Update(26)
loadstring(GetScript("Features/CharacterSystem.lua"))()

if _G.YOKUDO_CharacterSystem then
    _G.YOKUDO_CharacterSystem:Init()
end

-- ==================================================
-- LOAD FEATURES
-- ==================================================
Loading.Update(28)
loadstring(GetScript("Features/AntiAFK.lua"))()

Loading.Update(30)
loadstring(GetScript("Features/WalkSpeed.lua"))()

Loading.Update(33)
loadstring(GetScript("Features/AntiTrap.lua"))()

Loading.Update(36)
loadstring(GetScript("Features/GodMode.lua"))()

Loading.Update(39)
loadstring(GetScript("Features/TeleportSystem.lua"))()

Loading.Update(42)
loadstring(GetScript("Features/AutoFarm.lua"))()

Loading.Update(45)
loadstring(GetScript("Features/AutoAttack.lua"))()

Loading.Update(48)
loadstring(GetScript("Features/AFKSystem.lua"))()

-- ✅ EggCheckPremium (មុន FarmingManager)
Loading.Update(50)
loadstring(GetScript("Features/EggCheckPremium.lua"))()

Loading.Update(51)
loadstring(GetScript("Features/AttackDrone.lua"))()

Loading.Update(54)
loadstring(GetScript("Features/ManagerDrone.lua"))()

Loading.Update(57)
loadstring(GetScript("Features/ManualFastClick.lua"))()

-- ✅ FarmingManager (ប្រើ TeleportSystem + EggCheckPremium)
Loading.Update(59)
loadstring(GetScript("Features/FarmingManager.lua"))()

-- ✅ ConfigSystem
Loading.Update(60)
loadstring(GetScript("Features/ConfigSystem.lua"))()

-- ==================================================
-- LOAD TABS
-- ==================================================
Loading.Update(62)
loadstring(GetScript("Tabs/Info.lua"))()

Loading.Update(65)
loadstring(GetScript("Tabs/Farming.lua"))()

Loading.Update(70)
loadstring(GetScript("Tabs/Combat.lua"))()

Loading.Update(75)
loadstring(GetScript("Tabs/AutoFarming.lua"))()

Loading.Update(80)
loadstring(GetScript("Tabs/Event.lua"))()

Loading.Update(85)
loadstring(GetScript("Tabs/HopServer.lua"))()

Loading.Update(90)
loadstring(GetScript("Tabs/Setting.lua"))()

-- ==================================================
-- SELECT DEFAULT TAB
-- ==================================================
Loading.Update(92)
if _G.YOKUDO_TabsManager then
    _G.YOKUDO_TabsManager:SelectTabByName("Info")
end

Loading.Update(95)

-- ==================================================
-- LOAD ANTI CHEAT
-- ==================================================
Loading.Update(98)
loadstring(GetScript("Features/BypassAntiCheat.lua"))()

-- ==================================================
-- ✅ WAIT 2 SECONDS THEN APPLY CONFIG
-- ==================================================
print("⏳ Waiting 2s before applying config...")
task.wait(2)

if _G.YOKUDO_ConfigSystem then
    print("🔧 Applying Config...")
    _G.YOKUDO_ConfigSystem.Load()
end

Loading.Update(100)

task.wait(0.3)
Loading.Destroy()
print("✅ Loading Screen Closed!")
print("🚀 YOKUDO HUB | Ready!")
