-- ==================================================
-- YOKUDO HUB | TAB | Farming
-- ✅ ភ្ជាប់ជាមួយ EggCheckPremium
-- ✅ ភ្ជាប់ជាមួយ FarmingManager
-- ✅ Dropdown Select Rarity
-- ✅ Checkbox Auto AFK Farming
-- ==================================================

local TabsManager = _G.YOKUDO_TabsManager
local TweenService = game:GetService("TweenService")

local FarmingTab, FarmingPage = TabsManager:RegisterTab("Farming", 2, "FARMING")

-- ==================================================
-- CONTENT
-- ==================================================
CreateSectionTitle(FarmingPage, "Farming", 1)

-- ==================================================
-- SELECT EGG TYPE (DROPDOWN)
-- ==================================================
local RarityHolder = Instance.new("Frame")
RarityHolder.Size = UDim2.new(1, 0, 0, 52)
RarityHolder.BackgroundTransparency = 1
RarityHolder.LayoutOrder = 2
RarityHolder.ZIndex = 100
RarityHolder.Parent = FarmingPage

local RarityLabel = Instance.new("TextLabel")
RarityLabel.Size = UDim2.new(1, -120, 0, 20)
RarityLabel.Position = UDim2.new(0, 0, 0, 2)
RarityLabel.BackgroundTransparency = 1
RarityLabel.Text = "Select Egg Type"
RarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RarityLabel.TextSize = 13
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.TextYAlignment = Enum.TextYAlignment.Center
RarityLabel.Font = Enum.Font.GothamBold
RarityLabel.ZIndex = 101
RarityLabel.Parent = RarityHolder

local RarityTitle = Instance.new("TextLabel")
RarityTitle.Size = UDim2.new(1, -120, 0, 18)
RarityTitle.Position = UDim2.new(0, 0, 0, 24)
RarityTitle.BackgroundTransparency = 1
RarityTitle.Text = "Select Rarity to Farm"
RarityTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
RarityTitle.TextSize = 10
RarityTitle.TextXAlignment = Enum.TextXAlignment.Left
RarityTitle.Font = Enum.Font.Gotham
RarityTitle.ZIndex = 101
RarityTitle.Parent = RarityHolder

-- Selected Rarities
local SelectedRarities = { Secret = true, Eternal = true, Divine = true }

local function GetSelectedText()
    local List = {}
    if SelectedRarities.Secret then table.insert(List, "Secret") end
    if SelectedRarities.Eternal then table.insert(List, "Eternal") end
    if SelectedRarities.Divine then table.insert(List, "Divine") end
    if #List == 0 then return "None" end
    if #List == 3 then return "All" end
    return table.concat(List, ", ")
end

-- Dropdown Button
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(0, 120, 0, 28)
DropdownBtn.Position = UDim2.new(1, -120, 0.5, -14)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
DropdownBtn.BorderSizePixel = 0
DropdownBtn.Text = GetSelectedText() .. " ▼"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.TextSize = 11
DropdownBtn.Font = Enum.Font.GothamBold
DropdownBtn.AutoButtonColor = false
DropdownBtn.ZIndex = 101
DropdownBtn.Parent = RarityHolder

local DdCorner = Instance.new("UICorner")
DdCorner.CornerRadius = UDim.new(0, 6)
DdCorner.Parent = DropdownBtn

local DdStroke = Instance.new("UIStroke")
DdStroke.Color = Color3.fromRGB(200, 200, 220)
DdStroke.Thickness = 1
DdStroke.Transparency = 0.3
DdStroke.Parent = DropdownBtn

-- Dropdown List
local DropdownList = Instance.new("Frame")
DropdownList.Size = UDim2.new(0, 120, 0, 80)
DropdownList.Position = UDim2.new(1, -120, 1, 2)
DropdownList.BackgroundColor3 = Color3.fromRGB(25, 26, 38)
DropdownList.BorderSizePixel = 0
DropdownList.Visible = false
DropdownList.ZIndex = 200
DropdownList.Parent = RarityHolder

local DlCorner = Instance.new("UICorner")
DlCorner.CornerRadius = UDim.new(0, 6)
DlCorner.Parent = DropdownList

local DlStroke = Instance.new("UIStroke")
DlStroke.Color = Color3.fromRGB(200, 200, 220)
DlStroke.Thickness = 1
DlStroke.Transparency = 0.3
DlStroke.Parent = DropdownList

local DlLayout = Instance.new("UIListLayout")
DlLayout.Padding = UDim.new(0, 2)
DlLayout.SortOrder = Enum.SortOrder.LayoutOrder
DlLayout.Parent = DropdownList

local DlPadding = Instance.new("UIPadding")
DlPadding.PaddingTop = UDim.new(0, 4)
DlPadding.PaddingBottom = UDim.new(0, 4)
DlPadding.PaddingLeft = UDim.new(0, 4)
DlPadding.PaddingRight = UDim.new(0, 4)
DlPadding.Parent = DropdownList

-- ==================================================
-- CREATE DROPDOWN OPTION
-- ==================================================
local OptionButtons = {}

local function UpdateOptionVisual(Name)
    local Option = OptionButtons[Name]
    if not Option then return end

    if SelectedRarities[Name] then
        Option.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        Option.Text = "✓ " .. Name
    else
        Option.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
        Option.Text = Name
    end
end

local function CreateDropdownOption(Name, Order)
    local Option = Instance.new("TextButton")
    Option.Size = UDim2.new(1, 0, 0, 22)
    Option.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
    Option.BorderSizePixel = 0
    Option.Text = Name
    Option.TextColor3 = Color3.fromRGB(255, 255, 255)
    Option.TextSize = 11
    Option.Font = Enum.Font.GothamMedium
    Option.AutoButtonColor = false
    Option.LayoutOrder = Order
    Option.ZIndex = 201
    Option.Parent = DropdownList

    local OptCorner = Instance.new("UICorner")
    OptCorner.CornerRadius = UDim.new(0, 4)
    OptCorner.Parent = Option

    OptionButtons[Name] = Option

    Option.MouseButton1Click:Connect(function()
        SelectedRarities[Name] = not SelectedRarities[Name]
        UpdateOptionVisual(Name)
        DropdownBtn.Text = GetSelectedText() .. " ▼"

        -- ✅ Update EggCheckPremium
        if _G.YOKUDO_EggCheckPremium then
            local List = {}
            if SelectedRarities.Secret then table.insert(List, "Secret") end
            if SelectedRarities.Eternal then table.insert(List, "Eternal") end
            if SelectedRarities.Divine then table.insert(List, "Divine") end
            _G.YOKUDO_EggCheckPremium.SetRarities(List)
        end

        -- ✅ Update FarmingManager
        if _G.YOKUDO_FarmingManager then
            local List = {}
            if SelectedRarities.Secret then table.insert(List, "Secret") end
            if SelectedRarities.Eternal then table.insert(List, "Eternal") end
            if SelectedRarities.Divine then table.insert(List, "Divine") end
            _G.YOKUDO_FarmingManager.SetRarities(List)
        end

        print("[Farming] Rarity Toggled: " .. Name .. " = " .. tostring(SelectedRarities[Name]))
    end)

    Option.MouseEnter:Connect(function()
        if not SelectedRarities[Name] then
            TweenService:Create(Option, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(45, 46, 60)
            }):Play()
        end
    end)

    Option.MouseLeave:Connect(function()
        UpdateOptionVisual(Name)
    end)

    UpdateOptionVisual(Name)
end

CreateDropdownOption("Secret", 1)
CreateDropdownOption("Eternal", 2)
CreateDropdownOption("Divine", 3)

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

-- ==================================================
-- FEATURE: AUTO AFK FARMING EGG
-- ==================================================
local FarmHolder = Instance.new("Frame")
FarmHolder.Size = UDim2.new(1, 0, 0, 52)
FarmHolder.BackgroundTransparency = 1
FarmHolder.LayoutOrder = 3
FarmHolder.Parent = FarmingPage

local FarmLabel = Instance.new("TextLabel")
FarmLabel.Size = UDim2.new(1, -50, 0, 20)
FarmLabel.Position = UDim2.new(0, 0, 0, 2)
FarmLabel.BackgroundTransparency = 1
FarmLabel.Text = "Auto AFK Farming Egg"
FarmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmLabel.TextSize = 13
FarmLabel.TextXAlignment = Enum.TextXAlignment.Left
FarmLabel.TextYAlignment = Enum.TextYAlignment.Center
FarmLabel.Font = Enum.Font.GothamBold
FarmLabel.Parent = FarmHolder

-- ✅ Subtitle ដែលកែហើយ
local FarmSub = Instance.new("TextLabel")
FarmSub.Size = UDim2.new(1, -50, 0, 18)
FarmSub.Position = UDim2.new(0, 0, 0, 24)
FarmSub.BackgroundTransparency = 1
FarmSub.Text = "No farm egg noob2"
FarmSub.TextColor3 = Color3.fromRGB(150, 150, 170)
FarmSub.TextSize = 10
FarmSub.TextXAlignment = Enum.TextXAlignment.Left
FarmSub.Font = Enum.Font.Gotham
FarmSub.Parent = FarmHolder

local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0, 26, 0, 26)
FarmButton.Position = UDim2.new(1, -26, 0.5, -13)
FarmButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
FarmButton.BorderSizePixel = 0
FarmButton.Text = ""
FarmButton.AutoButtonColor = false
FarmButton.Parent = FarmHolder

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 6)
FarmCorner.Parent = FarmButton

local FarmStroke = Instance.new("UIStroke")
FarmStroke.Color = Color3.fromRGB(200, 200, 220)
FarmStroke.Thickness = 1.5
FarmStroke.Parent = FarmButton

local FarmCheck = Instance.new("TextLabel")
FarmCheck.Size = UDim2.new(1, 0, 1, 0)
FarmCheck.BackgroundTransparency = 1
FarmCheck.Text = "✓"
FarmCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmCheck.TextSize = 18
FarmCheck.Font = Enum.Font.GothamBold
FarmCheck.Visible = false
FarmCheck.Parent = FarmButton

-- ==================================================
-- TOGGLE FARM
-- ==================================================
local FarmEnabled = false

local function ToggleFarm()
    if not _G.YOKUDO_FarmingManager then
        warn("[YOKUDO] FarmingManager not loaded!")
        return
    end

    FarmEnabled = not FarmEnabled
    FarmCheck.Visible = FarmEnabled

    if FarmEnabled then
        FarmButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        FarmStroke.Color = Color3.fromRGB(135, 120, 225)

        -- ✅ Set Rarities ទៅ EggCheckPremium
        if _G.YOKUDO_EggCheckPremium then
            local List = {}
            if SelectedRarities.Secret then table.insert(List, "Secret") end
            if SelectedRarities.Eternal then table.insert(List, "Eternal") end
            if SelectedRarities.Divine then table.insert(List, "Divine") end
            _G.YOKUDO_EggCheckPremium.SetRarities(List)
        end

        -- ✅ Set Rarities ទៅ FarmingManager
        if _G.YOKUDO_FarmingManager then
            local List = {}
            if SelectedRarities.Secret then table.insert(List, "Secret") end
            if SelectedRarities.Eternal then table.insert(List, "Eternal") end
            if SelectedRarities.Divine then table.insert(List, "Divine") end
            _G.YOKUDO_FarmingManager.SetRarities(List)
        end

        _G.YOKUDO_FarmingManager.Enable()
    else
        FarmButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        FarmStroke.Color = Color3.fromRGB(200, 200, 220)
        _G.YOKUDO_FarmingManager.Disable()
    end
end

FarmButton.MouseButton1Click:Connect(function()
    ToggleFarm()
end)

-- ==================================================
-- SYNC ON LOAD
-- ==================================================
task.spawn(function()
    task.wait(1)
    if _G.YOKUDO_FarmingManager then
        local State = _G.YOKUDO_FarmingManager.IsEnabled()
        FarmEnabled = State
        FarmCheck.Visible = State
        if State then
            FarmButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            FarmStroke.Color = Color3.fromRGB(135, 120, 225)
        end
    end
end)

-- ==================================================
-- PERIODIC SYNC (រាល់ 1s)
-- ==================================================
task.spawn(function()
    while task.wait(1) do
        if _G.YOKUDO_FarmingManager then
            local CurrentState = _G.YOKUDO_FarmingManager.IsEnabled()
            local UIState = FarmCheck.Visible

            if CurrentState ~= UIState then
                FarmEnabled = CurrentState
                FarmCheck.Visible = CurrentState

                if CurrentState then
                    FarmButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
                    FarmStroke.Color = Color3.fromRGB(135, 120, 225)
                else
                    FarmButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
                    FarmStroke.Color = Color3.fromRGB(200, 200, 220)
                end

                print("[YOKUDO] Farming UI Sync | State: " .. tostring(CurrentState))
            end
        end
    end
end)

-- ==================================================
-- REFRESH FUNCTION (សម្រាប់ ConfigSystem)
-- ==================================================
_G.YOKUDO_RefreshFarmingUI = function()
    if _G.YOKUDO_FarmingManager then
        local State = _G.YOKUDO_FarmingManager.IsEnabled()
        FarmEnabled = State
        FarmCheck.Visible = State

        if State then
            FarmButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            FarmStroke.Color = Color3.fromRGB(135, 120, 225)
        else
            FarmButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
            FarmStroke.Color = Color3.fromRGB(200, 200, 220)
        end

        print("[YOKUDO] Farming Tab UI Refreshed | State: " .. tostring(State))
    end
end

print("✅ Farming Tab Loaded")
