--==================================================
-- YOKUDO HUB | TAB | Auto Farming
--==================================================

local TabsManager = _G.YOKUDO_TabsManager
local TweenService = game:GetService("TweenService")

local AutoFarmingTab, AutoFarmingPage = TabsManager:RegisterTab("Auto Farming", 4, "AUTO_FARMING")

--==================================================
-- CONTENT
--==================================================
CreateSectionTitle(AutoFarmingPage, "Auto Farming", 1)

--==================================================
-- FEATURE 1: Click Get Egg
--==================================================
local GetEggBox = Instance.new("Frame")
GetEggBox.Size = UDim2.new(1, 0, 0, 60)
GetEggBox.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
GetEggBox.BorderSizePixel = 0
GetEggBox.LayoutOrder = 2
GetEggBox.Parent = AutoFarmingPage

local GetEggBoxCorner = Instance.new("UICorner")
GetEggBoxCorner.CornerRadius = UDim.new(0, 8)
GetEggBoxCorner.Parent = GetEggBox

local GetEggBoxStroke = Instance.new("UIStroke")
GetEggBoxStroke.Color = Color3.fromRGB(105, 90, 190)
GetEggBoxStroke.Thickness = 1.5
GetEggBoxStroke.Transparency = 0.4
GetEggBoxStroke.Parent = GetEggBox

local GetEggIcon = Instance.new("ImageLabel")
GetEggIcon.Size = UDim2.new(0, 40, 0, 40)
GetEggIcon.Position = UDim2.new(0, 10, 0.5, -20)
GetEggIcon.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
GetEggIcon.BorderSizePixel = 0
GetEggIcon.Image = ""
GetEggIcon.Parent = GetEggBox

local GetEggIconCorner = Instance.new("UICorner")
GetEggIconCorner.CornerRadius = UDim.new(0, 6)
GetEggIconCorner.Parent = GetEggIcon

local GetEggName = Instance.new("TextLabel")
GetEggName.Size = UDim2.new(1, -140, 0, 16)
GetEggName.Position = UDim2.new(0, 58, 0, 10)
GetEggName.BackgroundTransparency = 1
GetEggName.Text = "No Egg Selected"
GetEggName.TextColor3 = Color3.fromRGB(255, 255, 255)
GetEggName.TextSize = 12
GetEggName.TextXAlignment = Enum.TextXAlignment.Left
GetEggName.Font = Enum.Font.GothamBold
GetEggName.Parent = GetEggBox

local GetEggRate = Instance.new("TextLabel")
GetEggRate.Size = UDim2.new(1, -140, 0, 16)
GetEggRate.Position = UDim2.new(0, 58, 0, 30)
GetEggRate.BackgroundTransparency = 1
GetEggRate.Text = "$0/s"
GetEggRate.TextColor3 = Color3.fromRGB(100, 255, 100)
GetEggRate.TextSize = 11
GetEggRate.TextXAlignment = Enum.TextXAlignment.Left
GetEggRate.Font = Enum.Font.Gotham
GetEggRate.Parent = GetEggBox

local GetEggCheckButton = Instance.new("TextButton")
GetEggCheckButton.Size = UDim2.new(0, 34, 0, 34)
GetEggCheckButton.Position = UDim2.new(1, -44, 0.5, -17)
GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GetEggCheckButton.BackgroundTransparency = 0.85
GetEggCheckButton.BorderSizePixel = 0
GetEggCheckButton.Text = ""
GetEggCheckButton.AutoButtonColor = false
GetEggCheckButton.Parent = GetEggBox

local GetEggCheckCorner = Instance.new("UICorner")
GetEggCheckCorner.CornerRadius = UDim.new(0, 8)
GetEggCheckCorner.Parent = GetEggCheckButton

local GetEggCheckStroke = Instance.new("UIStroke")
GetEggCheckStroke.Color = Color3.fromRGB(255, 255, 255)
GetEggCheckStroke.Thickness = 2
GetEggCheckStroke.Parent = GetEggCheckButton

local GetEggCheck = Instance.new("TextLabel")
GetEggCheck.Size = UDim2.new(1, 0, 1, 0)
GetEggCheck.BackgroundTransparency = 1
GetEggCheck.Text = "✓"
GetEggCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
GetEggCheck.TextSize = 20
GetEggCheck.Font = Enum.Font.GothamBold
GetEggCheck.Visible = false
GetEggCheck.Parent = GetEggCheckButton

local SelectedEggId = nil
local SelectedEggData = nil
local GetEggEnabled = false

local function UpdateGetEggBox(Icon, Name, Rate, EggId)
    GetEggIcon.Image = Icon or ""
    GetEggName.Text = Name or "No Egg Selected"
    GetEggRate.Text = "$" .. (_G.YOKUDO_AutoFarm and _G.YOKUDO_AutoFarm.FormatMoney(Rate or 0) or tostring(Rate or 0)) .. "/s"
    SelectedEggId = EggId

    GetEggIcon.ImageTransparency = 1
    GetEggName.TextTransparency = 1
    GetEggRate.TextTransparency = 1

    TweenService:Create(GetEggIcon, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
    TweenService:Create(GetEggName, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    TweenService:Create(GetEggRate, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
end

local function ToggleGetEgg()
    GetEggEnabled = not GetEggEnabled
    GetEggCheck.Visible = GetEggEnabled
    if GetEggEnabled then
        GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        GetEggCheckButton.BackgroundTransparency = 0
        GetEggCheckStroke.Color = Color3.fromRGB(135, 120, 225)

        -- ✅ Call StartTeleport (reads Method from Setting)
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.StartTeleport()
        end
    else
        GetEggCheckButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        GetEggCheckButton.BackgroundTransparency = 0.85
        GetEggCheckStroke.Color = Color3.fromRGB(255, 255, 255)

        -- ✅ Call StopTeleport
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.StopTeleport()
        end
    end
end

GetEggCheckButton.MouseButton1Click:Connect(function()
    ToggleGetEgg()
end)

--==================================================
-- FEATURE 2: Start Check Egg
--==================================================
local CheckEggHolder = Instance.new("Frame")
CheckEggHolder.Size = UDim2.new(1, 0, 0, 44)
CheckEggHolder.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
CheckEggHolder.BorderSizePixel = 0
CheckEggHolder.LayoutOrder = 3
CheckEggHolder.Parent = AutoFarmingPage

local CheckEggHolderCorner = Instance.new("UICorner")
CheckEggHolderCorner.CornerRadius = UDim.new(0, 8)
CheckEggHolderCorner.Parent = CheckEggHolder

local CheckEggHolderStroke = Instance.new("UIStroke")
CheckEggHolderStroke.Color = Color3.fromRGB(105, 90, 190)
CheckEggHolderStroke.Thickness = 1.5
CheckEggHolderStroke.Transparency = 0.4
CheckEggHolderStroke.Parent = CheckEggHolder

local CheckEggLabel = Instance.new("TextLabel")
CheckEggLabel.Size = UDim2.new(1, -140, 1, 0)
CheckEggLabel.Position = UDim2.new(0, 12, 0, 0)
CheckEggLabel.BackgroundTransparency = 1
CheckEggLabel.Text = "Start Check Egg"
CheckEggLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
CheckEggLabel.TextSize = 13
CheckEggLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckEggLabel.TextYAlignment = Enum.TextYAlignment.Center
CheckEggLabel.Font = Enum.Font.GothamBold
CheckEggLabel.Parent = CheckEggHolder

local CheckEggCount = Instance.new("TextLabel")
CheckEggCount.Size = UDim2.new(0, 80, 1, 0)
CheckEggCount.Position = UDim2.new(1, -150, 0, 0)
CheckEggCount.BackgroundTransparency = 1
CheckEggCount.Text = "Egg: 0"
CheckEggCount.TextColor3 = Color3.fromRGB(100, 255, 100)
CheckEggCount.TextSize = 10
CheckEggCount.TextXAlignment = Enum.TextXAlignment.Right
CheckEggCount.TextYAlignment = Enum.TextYAlignment.Center
CheckEggCount.Font = Enum.Font.Gotham
CheckEggCount.Parent = CheckEggHolder

local CheckEggCheckButton = Instance.new("TextButton")
CheckEggCheckButton.Size = UDim2.new(0, 30, 0, 30)
CheckEggCheckButton.Position = UDim2.new(1, -40, 0.5, -15)
CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CheckEggCheckButton.BackgroundTransparency = 0.85
CheckEggCheckButton.BorderSizePixel = 0
CheckEggCheckButton.Text = ""
CheckEggCheckButton.AutoButtonColor = false
CheckEggCheckButton.Parent = CheckEggHolder

local CheckEggCorner = Instance.new("UICorner")
CheckEggCorner.CornerRadius = UDim.new(0, 8)
CheckEggCorner.Parent = CheckEggCheckButton

local CheckEggStroke = Instance.new("UIStroke")
CheckEggStroke.Color = Color3.fromRGB(255, 255, 255)
CheckEggStroke.Thickness = 2
CheckEggStroke.Parent = CheckEggCheckButton

local CheckEggCheck = Instance.new("TextLabel")
CheckEggCheck.Size = UDim2.new(1, 0, 1, 0)
CheckEggCheck.BackgroundTransparency = 1
CheckEggCheck.Text = "✓"
CheckEggCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckEggCheck.TextSize = 20
CheckEggCheck.Font = Enum.Font.GothamBold
CheckEggCheck.Visible = false
CheckEggCheck.Parent = CheckEggCheckButton

local CheckEggEnabled = false
local EggScrollFrame = nil
local EggEntries = {}

local function CreateEggEntry(EggData)
    local Entry = Instance.new("Frame")
    Entry.Size = UDim2.new(1, -8, 0, 44)
    Entry.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
    Entry.BorderSizePixel = 0
    Entry.Parent = EggScrollFrame

    local EntryCorner = Instance.new("UICorner")
    EntryCorner.CornerRadius = UDim.new(0, 6)
    EntryCorner.Parent = Entry

    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 34, 0, 34)
    IconFrame.Position = UDim2.new(0, 5, 0.5, -17)
    IconFrame.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = Entry

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 6)
    IconCorner.Parent = IconFrame

    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(1, -4, 1, -4)
    IconImage.Position = UDim2.new(0, 2, 0, 2)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = EggData.Icon or ""
    IconImage.Parent = IconFrame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 6)
    ImageCorner.Parent = IconImage

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -140, 0, 16)
    NameLabel.Position = UDim2.new(0, 48, 0, 6)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = EggData.DisplayName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 11
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Parent = Entry

    local RateLabel = Instance.new("TextLabel")
    RateLabel.Size = UDim2.new(1, -140, 0, 14)
    RateLabel.Position = UDim2.new(0, 48, 0, 24)
    RateLabel.BackgroundTransparency = 1
    RateLabel.Text = "$" .. (_G.YOKUDO_AutoFarm and _G.YOKUDO_AutoFarm.FormatMoney(EggData.EarningRate) or tostring(EggData.EarningRate)) .. "/s"
    RateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    RateLabel.TextSize = 10
    RateLabel.TextXAlignment = Enum.TextXAlignment.Left
    RateLabel.Font = Enum.Font.Gotham
    RateLabel.Parent = Entry

    local SelectButton = Instance.new("TextButton")
    SelectButton.Size = UDim2.new(0, 70, 0, 28)
    SelectButton.Position = UDim2.new(1, -75, 0.5, -14)
    SelectButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    SelectButton.BorderSizePixel = 0
    SelectButton.Text = "Select"
    SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectButton.TextSize = 12
    SelectButton.Font = Enum.Font.GothamBold
    SelectButton.AutoButtonColor = false
    SelectButton.Parent = Entry

    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 6)
    SelectCorner.Parent = SelectButton

    local SelectStroke = Instance.new("UIStroke")
    SelectStroke.Color = Color3.fromRGB(140, 125, 240)
    SelectStroke.Thickness = 1.5
    SelectStroke.Transparency = 0.3
    SelectStroke.Parent = SelectButton

    SelectButton.MouseButton1Click:Connect(function()
        UpdateGetEggBox(EggData.Icon, EggData.DisplayName, EggData.EarningRate, EggData.Id)

        -- ✅ Save EggData ទាំងមូល
        SelectedEggData = EggData

        -- ✅ គ្រាន់តែ Save មិន Enable
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.SelectEgg(EggData)
        end
    end)

    return Entry
end

local function RefreshEggList()
    if not CheckEggEnabled then return end
    if not _G.YOKUDO_AutoFarm then return end

    for _, child in ipairs(EggScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    EggEntries = {}

    local Eggs = _G.YOKUDO_AutoFarm.ScanEggs()
    for _, EggData in ipairs(Eggs) do
        local Entry = CreateEggEntry(EggData)
        table.insert(EggEntries, Entry)
    end
    EggScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #Eggs * 48)
    CheckEggCount.Text = "Egg: " .. #Eggs
end

local function ToggleCheckEgg()
    CheckEggEnabled = not CheckEggEnabled
    CheckEggCheck.Visible = CheckEggEnabled
    if CheckEggEnabled then
        CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        CheckEggCheckButton.BackgroundTransparency = 0
        CheckEggStroke.Color = Color3.fromRGB(135, 120, 225)
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.Enable()
        end
        RefreshEggList()
    else
        CheckEggCheckButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CheckEggCheckButton.BackgroundTransparency = 0.85
        CheckEggStroke.Color = Color3.fromRGB(255, 255, 255)
        if _G.YOKUDO_AutoFarm then
            _G.YOKUDO_AutoFarm.Disable()
        end
        for _, child in ipairs(EggScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        CheckEggCount.Text = "Egg: 0"
    end
end

CheckEggCheckButton.MouseButton1Click:Connect(function()
    ToggleCheckEgg()
end)

--==================================================
-- EGG LIST
--==================================================
EggScrollFrame = Instance.new("ScrollingFrame")
EggScrollFrame.Size = UDim2.new(1, 0, 0, 200)
EggScrollFrame.BackgroundTransparency = 1
EggScrollFrame.BorderSizePixel = 0
EggScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
EggScrollFrame.ScrollBarThickness = 4
EggScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
EggScrollFrame.LayoutOrder = 4
EggScrollFrame.Parent = AutoFarmingPage

local EggListLayout = Instance.new("UIListLayout")
EggListLayout.Padding = UDim.new(0, 4)
EggListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EggListLayout.Parent = EggScrollFrame

workspace.AreaEggSlotsClient.ChildAdded:Connect(function()
    task.wait(0.2)
    if CheckEggEnabled then
        RefreshEggList()
    end
end)

workspace.AreaEggSlotsClient.ChildRemoved:Connect(function()
    task.wait(0.2)
    if CheckEggEnabled then
        RefreshEggList()
    end
end)

task.spawn(function()
    while task.wait(3) do
        if CheckEggEnabled then
            RefreshEggList()
        end
    end
end)

print("✅ Auto Farming Tab Loaded")
