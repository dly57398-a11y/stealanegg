--==================================================
-- YOKUDO HUB | TAB | Setting
--==================================================

local TabsManager = _G.YOKUDO_TabsManager
local TweenService = game:GetService("TweenService")

local SettingTab, SettingPage = TabsManager:RegisterTab("Setting", 7, "SETTING")

--==================================================
-- SETTING CONTENT
--==================================================
CreateSectionTitle(SettingPage, "Settings", 1)

--==================================================
-- FEATURE 1: SELECT METHOD TELEPORT (DROPDOWN)
--==================================================
local MethodHolder = Instance.new("Frame")
MethodHolder.Size = UDim2.new(1, 0, 0, 52)
MethodHolder.BackgroundTransparency = 1
MethodHolder.LayoutOrder = 2
MethodHolder.ZIndex = 100
MethodHolder.Parent = SettingPage

local MethodLabel = Instance.new("TextLabel")
MethodLabel.Size = UDim2.new(1, -120, 0, 20)
MethodLabel.Position = UDim2.new(0, 0, 0, 2)
MethodLabel.BackgroundTransparency = 1
MethodLabel.Text = "Select Method Teleport"
MethodLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MethodLabel.TextSize = 13
MethodLabel.TextXAlignment = Enum.TextXAlignment.Left
MethodLabel.TextYAlignment = Enum.TextYAlignment.Center
MethodLabel.Font = Enum.Font.GothamBold
MethodLabel.ZIndex = 101
MethodLabel.Parent = MethodHolder

local MethodTitle = Instance.new("TextLabel")
MethodTitle.Size = UDim2.new(1, -120, 0, 18)
MethodTitle.Position = UDim2.new(0, 0, 0, 24)
MethodTitle.BackgroundTransparency = 1
MethodTitle.Text = "TeleportFly or InstantTeleport"
MethodTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
MethodTitle.TextSize = 10
MethodTitle.TextXAlignment = Enum.TextXAlignment.Left
MethodTitle.Font = Enum.Font.Gotham
MethodTitle.ZIndex = 101
MethodTitle.Parent = MethodHolder

local SelectedMethod = _G.YOKUDO_SelectedMethod or "TeleportFly"

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(0, 110, 0, 28)
DropdownBtn.Position = UDim2.new(1, -110, 0.5, -14)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
DropdownBtn.BorderSizePixel = 0
DropdownBtn.Text = SelectedMethod .. " ▼"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.TextSize = 11
DropdownBtn.Font = Enum.Font.GothamBold
DropdownBtn.AutoButtonColor = false
DropdownBtn.ZIndex = 101
DropdownBtn.Parent = MethodHolder

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownBtn

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(200, 200, 220)
DropdownStroke.Thickness = 1
DropdownStroke.Transparency = 0.3
DropdownStroke.Parent = DropdownBtn

local DropdownList = Instance.new("Frame")
DropdownList.Size = UDim2.new(0, 110, 0, 60)
DropdownList.Position = UDim2.new(1, -110, 1, 2)
DropdownList.BackgroundColor3 = Color3.fromRGB(25, 26, 38)
DropdownList.BorderSizePixel = 0
DropdownList.Visible = false
DropdownList.ZIndex = 200
DropdownList.Parent = MethodHolder

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = DropdownList

local ListStroke = Instance.new("UIStroke")
ListStroke.Color = Color3.fromRGB(200, 200, 220)
ListStroke.Thickness = 1
ListStroke.Transparency = 0.3
ListStroke.Parent = DropdownList

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = DropdownList

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 4)
ListPadding.PaddingBottom = UDim.new(0, 4)
ListPadding.PaddingLeft = UDim.new(0, 4)
ListPadding.PaddingRight = UDim.new(0, 4)
ListPadding.Parent = DropdownList

local function CreateOption(Name, Order)
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

    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 4)
    OptionCorner.Parent = Option

    Option.MouseButton1Click:Connect(function()
        SelectedMethod = Name
        DropdownBtn.Text = Name .. " ▼"
        DropdownList.Visible = false

        _G.YOKUDO_SelectedMethod = Name

        if _G.YOKUDO_ConfigSystem then
            _G.YOKUDO_ConfigSystem.Save()
        end

        print("[YOKUDO] Method Teleport Selected: " .. Name)
    end)

    Option.MouseEnter:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 46, 60)
        }):Play()
    end)

    Option.MouseLeave:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 31, 45)
        }):Play()
    end)
end

CreateOption("TeleportFly", 1)
CreateOption("InstantTeleport", 2)

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

if _G.YOKUDO_SelectedMethod == nil then
    _G.YOKUDO_SelectedMethod = "TeleportFly"
end

--==================================================
-- FEATURE 2: TELEPORT SPEED (TEXTBOX)
--==================================================
local SpeedHolder = Instance.new("Frame")
SpeedHolder.Size = UDim2.new(1, 0, 0, 52)
SpeedHolder.BackgroundTransparency = 1
SpeedHolder.LayoutOrder = 3
SpeedHolder.ZIndex = 1
SpeedHolder.Parent = SettingPage

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -120, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 2)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Teleport Speed"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 13
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.ZIndex = 2
SpeedLabel.Parent = SpeedHolder

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, -120, 0, 18)
SpeedTitle.Position = UDim2.new(0, 0, 0, 24)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "Range: 50 - 1100 (Default: 300)"
SpeedTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedTitle.TextSize = 10
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Font = Enum.Font.Gotham
SpeedTitle.ZIndex = 2
SpeedTitle.Parent = SpeedHolder

local InitialSpeed = _G.YOKUDO_TeleportSpeed or 300

local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Size = UDim2.new(0, 80, 0, 28)
SpeedTextBox.Position = UDim2.new(1, -80, 0.5, -14)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.Text = tostring(InitialSpeed)
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.TextSize = 12
SpeedTextBox.TextXAlignment = Enum.TextXAlignment.Center
SpeedTextBox.Font = Enum.Font.GothamBold
SpeedTextBox.ZIndex = 2
SpeedTextBox.Parent = SpeedHolder

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedTextBox

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(200, 200, 220)
SpeedStroke.Thickness = 1
SpeedStroke.Transparency = 0.3
SpeedStroke.Parent = SpeedTextBox

-- ✅ Flag: User កំពុង Edit
local IsEditingSpeed = false

SpeedTextBox.Focused:Connect(function()
    IsEditingSpeed = true
end)

SpeedTextBox.FocusLost:Connect(function()
    IsEditingSpeed = false

    local Value = tonumber(SpeedTextBox.Text)

    if Value then
        Value = math.clamp(Value, 50, 1100)
        SpeedTextBox.Text = tostring(Value)

        _G.YOKUDO_TeleportSpeed = Value

        if _G.YOKUDO_TeleportSystem then
            _G.YOKUDO_TeleportSystem.SetSpeed(Value)
        end

        if _G.YOKUDO_ConfigSystem then
            _G.YOKUDO_ConfigSystem.Save()
        end

        print("[YOKUDO] Teleport Speed: " .. tostring(Value))
    else
        SpeedTextBox.Text = "300"
        _G.YOKUDO_TeleportSpeed = 300

        if _G.YOKUDO_TeleportSystem then
            _G.YOKUDO_TeleportSystem.SetSpeed(300)
        end

        if _G.YOKUDO_ConfigSystem then
            _G.YOKUDO_ConfigSystem.Save()
        end
    end
end)

if _G.YOKUDO_TeleportSpeed == nil then
    _G.YOKUDO_TeleportSpeed = 300
end

--==================================================
-- FEATURE 3: WALK SPEED
--==================================================
local WalkSpeedHolder = Instance.new("Frame")
WalkSpeedHolder.Size = UDim2.new(1, 0, 0, 32)
WalkSpeedHolder.BackgroundTransparency = 1
WalkSpeedHolder.LayoutOrder = 4
WalkSpeedHolder.Parent = SettingPage

local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Size = UDim2.new(0, 100, 1, 0)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text = "Walk Speed"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedLabel.TextSize = 12
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
WalkSpeedLabel.Font = Enum.Font.GothamMedium
WalkSpeedLabel.Parent = WalkSpeedHolder

local WalkSpeedTextBox = Instance.new("TextBox")
WalkSpeedTextBox.Size = UDim2.new(0, 40, 1, -6)
WalkSpeedTextBox.Position = UDim2.new(0, 105, 0, 3)
WalkSpeedTextBox.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
WalkSpeedTextBox.BorderSizePixel = 0
WalkSpeedTextBox.Text = "50"
WalkSpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedTextBox.TextSize = 12
WalkSpeedTextBox.TextXAlignment = Enum.TextXAlignment.Center
WalkSpeedTextBox.TextYAlignment = Enum.TextYAlignment.Center
WalkSpeedTextBox.Font = Enum.Font.GothamMedium
WalkSpeedTextBox.Parent = WalkSpeedHolder

local WalkSpeedBoxCorner = Instance.new("UICorner")
WalkSpeedBoxCorner.CornerRadius = UDim.new(0, 4)
WalkSpeedBoxCorner.Parent = WalkSpeedTextBox

local WalkSpeedBoxStroke = Instance.new("UIStroke")
WalkSpeedBoxStroke.Color = Color3.fromRGB(200, 200, 220)
WalkSpeedBoxStroke.Thickness = 0.5
WalkSpeedBoxStroke.Transparency = 0.2
WalkSpeedBoxStroke.Parent = WalkSpeedTextBox

local WalkSpeedCheckButton = Instance.new("TextButton")
WalkSpeedCheckButton.Size = UDim2.new(0, 26, 0, 26)
WalkSpeedCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
WalkSpeedCheckButton.BorderSizePixel = 0
WalkSpeedCheckButton.Text = ""
WalkSpeedCheckButton.AutoButtonColor = false
WalkSpeedCheckButton.Parent = WalkSpeedHolder

local WalkSpeedCorner = Instance.new("UICorner")
WalkSpeedCorner.CornerRadius = UDim.new(0, 6)
WalkSpeedCorner.Parent = WalkSpeedCheckButton

local WalkSpeedStroke = Instance.new("UIStroke")
WalkSpeedStroke.Color = Color3.fromRGB(200, 200, 220)
WalkSpeedStroke.Thickness = 1.5
WalkSpeedStroke.Parent = WalkSpeedCheckButton

local WalkSpeedCheck = Instance.new("TextLabel")
WalkSpeedCheck.Size = UDim2.new(1, 0, 1, 0)
WalkSpeedCheck.BackgroundTransparency = 1
WalkSpeedCheck.Text = "✓"
WalkSpeedCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedCheck.TextSize = 18
WalkSpeedCheck.Font = Enum.Font.GothamBold
WalkSpeedCheck.Visible = false
WalkSpeedCheck.Parent = WalkSpeedCheckButton

local WalkSpeedEnabled = false
local WalkSpeedValue = 50

local function ToggleWalkSpeed()
    WalkSpeedEnabled = not WalkSpeedEnabled
    WalkSpeedCheck.Visible = WalkSpeedEnabled
    if WalkSpeedEnabled then
        WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        WalkSpeedStroke.Color = Color3.fromRGB(135, 120, 225)
        if _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.SetValue(WalkSpeedValue)
            _G.YOKUDO_WalkSpeed.Enable()
        end
    else
        WalkSpeedCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        WalkSpeedStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.Disable()
        end
    end
end

WalkSpeedCheckButton.MouseButton1Click:Connect(function()
    ToggleWalkSpeed()
end)

WalkSpeedTextBox.FocusLost:Connect(function()
    local val = tonumber(WalkSpeedTextBox.Text)
    if val then
        WalkSpeedValue = math.clamp(val, 50, 1000)
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
        if WalkSpeedEnabled and _G.YOKUDO_WalkSpeed then
            _G.YOKUDO_WalkSpeed.SetValue(WalkSpeedValue)
        end
    else
        WalkSpeedTextBox.Text = tostring(WalkSpeedValue)
    end
end)

--==================================================
-- FEATURE 4: ANTI TRAP
--==================================================
local AntiTrapHolder = Instance.new("Frame")
AntiTrapHolder.Size = UDim2.new(1, 0, 0, 52)
AntiTrapHolder.BackgroundTransparency = 1
AntiTrapHolder.LayoutOrder = 5
AntiTrapHolder.Parent = SettingPage

local AntiTrapLabel = Instance.new("TextLabel")
AntiTrapLabel.Size = UDim2.new(1, -50, 0, 20)
AntiTrapLabel.Position = UDim2.new(0, 0, 0, 2)
AntiTrapLabel.BackgroundTransparency = 1
AntiTrapLabel.Text = "Anti Trap"
AntiTrapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiTrapLabel.TextSize = 13
AntiTrapLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiTrapLabel.TextYAlignment = Enum.TextYAlignment.Center
AntiTrapLabel.Font = Enum.Font.GothamBold
AntiTrapLabel.Parent = AntiTrapHolder

local AntiTrapTitle = Instance.new("TextLabel")
AntiTrapTitle.Size = UDim2.new(1, -50, 0, 18)
AntiTrapTitle.Position = UDim2.new(0, 0, 0, 24)
AntiTrapTitle.BackgroundTransparency = 1
AntiTrapTitle.Text = "click for remove Trap"
AntiTrapTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
AntiTrapTitle.TextSize = 10
AntiTrapTitle.TextXAlignment = Enum.TextXAlignment.Left
AntiTrapTitle.Font = Enum.Font.Gotham
AntiTrapTitle.Parent = AntiTrapHolder

local AntiTrapCheckButton = Instance.new("TextButton")
AntiTrapCheckButton.Size = UDim2.new(0, 26, 0, 26)
AntiTrapCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
AntiTrapCheckButton.BorderSizePixel = 0
AntiTrapCheckButton.Text = ""
AntiTrapCheckButton.AutoButtonColor = false
AntiTrapCheckButton.Parent = AntiTrapHolder

local AntiTrapCorner = Instance.new("UICorner")
AntiTrapCorner.CornerRadius = UDim.new(0, 6)
AntiTrapCorner.Parent = AntiTrapCheckButton

local AntiTrapStroke = Instance.new("UIStroke")
AntiTrapStroke.Color = Color3.fromRGB(200, 200, 220)
AntiTrapStroke.Thickness = 1.5
AntiTrapStroke.Parent = AntiTrapCheckButton

local AntiTrapCheck = Instance.new("TextLabel")
AntiTrapCheck.Size = UDim2.new(1, 0, 1, 0)
AntiTrapCheck.BackgroundTransparency = 1
AntiTrapCheck.Text = "✓"
AntiTrapCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiTrapCheck.TextSize = 18
AntiTrapCheck.Font = Enum.Font.GothamBold
AntiTrapCheck.Visible = false
AntiTrapCheck.Parent = AntiTrapCheckButton

local AntiTrapEnabled = false

local function ToggleAntiTrap()
    AntiTrapEnabled = not AntiTrapEnabled
    AntiTrapCheck.Visible = AntiTrapEnabled
    if AntiTrapEnabled then
        AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        AntiTrapStroke.Color = Color3.fromRGB(135, 120, 225)
        if _G.YOKUDO_AntiTrap then
            _G.YOKUDO_AntiTrap.Enable()
        end
    else
        AntiTrapCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        AntiTrapStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_AntiTrap then
            _G.YOKUDO_AntiTrap.Disable()
        end
    end
end

AntiTrapCheckButton.MouseButton1Click:Connect(function()
    ToggleAntiTrap()
end)

--==================================================
-- FEATURE 5: GOD MODE
--==================================================
local GodModeHolder = Instance.new("Frame")
GodModeHolder.Size = UDim2.new(1, 0, 0, 52)
GodModeHolder.BackgroundTransparency = 1
GodModeHolder.LayoutOrder = 6
GodModeHolder.Parent = SettingPage

local GodModeLabel = Instance.new("TextLabel")
GodModeLabel.Size = UDim2.new(1, -90, 0, 20)
GodModeLabel.Position = UDim2.new(0, 0, 0, 2)
GodModeLabel.BackgroundTransparency = 1
GodModeLabel.Text = "God Mode"
GodModeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeLabel.TextSize = 13
GodModeLabel.TextXAlignment = Enum.TextXAlignment.Left
GodModeLabel.TextYAlignment = Enum.TextYAlignment.Center
GodModeLabel.Font = Enum.Font.GothamBold
GodModeLabel.Parent = GodModeHolder

local GodModeTitle = Instance.new("TextLabel")
GodModeTitle.Size = UDim2.new(1, -90, 0, 18)
GodModeTitle.Position = UDim2.new(0, 0, 0, 24)
GodModeTitle.BackgroundTransparency = 1
GodModeTitle.Text = "When Character Dead click God Mode"
GodModeTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
GodModeTitle.TextSize = 10
GodModeTitle.TextXAlignment = Enum.TextXAlignment.Left
GodModeTitle.Font = Enum.Font.Gotham
GodModeTitle.Parent = GodModeHolder

local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0, 70, 0, 26)
GodModeButton.Position = UDim2.new(1, -70, 0.5, -13)
GodModeButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
GodModeButton.BorderSizePixel = 0
GodModeButton.Text = "Click"
GodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeButton.TextSize = 12
GodModeButton.Font = Enum.Font.GothamBold
GodModeButton.AutoButtonColor = false
GodModeButton.Parent = GodModeHolder

local GodModeCorner = Instance.new("UICorner")
GodModeCorner.CornerRadius = UDim.new(0, 6)
GodModeCorner.Parent = GodModeButton

local GodModeStroke = Instance.new("UIStroke")
GodModeStroke.Color = Color3.fromRGB(140, 125, 240)
GodModeStroke.Thickness = 1.5
GodModeStroke.Transparency = 0.3
GodModeStroke.Parent = GodModeButton

GodModeButton.MouseEnter:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(125, 110, 220)
    }):Play()
end)

GodModeButton.MouseLeave:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
local function ShowNotification(Text)
    local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "YokudoNotify"
    NotifyGui.ResetOnSpawn = false
    NotifyGui.DisplayOrder = 999
    NotifyGui.Parent = PlayerGui

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 220, 0, 50)
    NotifyFrame.Position = UDim2.new(0, -250, 0, 20)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotifyFrame.BackgroundTransparency = 0.85
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = NotifyGui

    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 10)
    NotifyCorner.Parent = NotifyFrame

    local NotifyStroke = Instance.new("UIStroke")
    NotifyStroke.Color = Color3.fromRGB(255, 255, 255)
    NotifyStroke.Thickness = 1
    NotifyStroke.Transparency = 0.7
    NotifyStroke.Parent = NotifyFrame

    local NotifyText = Instance.new("TextLabel")
    NotifyText.Size = UDim2.new(1, -20, 1, 0)
    NotifyText.Position = UDim2.new(0, 10, 0, 0)
    NotifyText.BackgroundTransparency = 1
    NotifyText.Text = Text
    NotifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyText.TextSize = 13
    NotifyText.TextXAlignment = Enum.TextXAlignment.Left
    NotifyText.TextYAlignment = Enum.TextYAlignment.Center
    NotifyText.Font = Enum.Font.GothamBold
    NotifyText.Parent = NotifyFrame

    TweenService:Create(NotifyFrame, TweenInfo.new(0.4), {
        Position = UDim2.new(0, 20, 0, 20)
    }):Play()

    task.wait(5)

    TweenService:Create(NotifyFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(0, -250, 0, 20),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(NotifyText, TweenInfo.new(0.3), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(NotifyStroke, TweenInfo.new(0.3), {
        Transparency = 1
    }):Play()

    task.wait(0.3)
    NotifyGui:Destroy()
end

GodModeButton.MouseButton1Down:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 62, 0, 23),
        BackgroundColor3 = Color3.fromRGB(85, 70, 170)
    }):Play()
end)

GodModeButton.MouseButton1Up:Connect(function()
    TweenService:Create(GodModeButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 70, 0, 26),
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

GodModeButton.MouseButton1Click:Connect(function()
    if _G.YOKUDO_GodMode then
        _G.YOKUDO_GodMode.Enable()
    end
    ShowNotification("God Mode Start")
end)

--==================================================
-- FEATURE 6: MANUAL FAST CLICK
--==================================================
local FastClickHolder = Instance.new("Frame")
FastClickHolder.Size = UDim2.new(1, 0, 0, 52)
FastClickHolder.BackgroundTransparency = 1
FastClickHolder.LayoutOrder = 7
FastClickHolder.Parent = SettingPage

local FastClickLabel = Instance.new("TextLabel")
FastClickLabel.Size = UDim2.new(1, -90, 0, 20)
FastClickLabel.Position = UDim2.new(0, 0, 0, 2)
FastClickLabel.BackgroundTransparency = 1
FastClickLabel.Text = "Manual Fast Click"
FastClickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FastClickLabel.TextSize = 13
FastClickLabel.TextXAlignment = Enum.TextXAlignment.Left
FastClickLabel.TextYAlignment = Enum.TextYAlignment.Center
FastClickLabel.Font = Enum.Font.GothamBold
FastClickLabel.Parent = FastClickHolder

local FastClickTitle = Instance.new("TextLabel")
FastClickTitle.Size = UDim2.new(1, -90, 0, 18)
FastClickTitle.Position = UDim2.new(0, 0, 0, 24)
FastClickTitle.BackgroundTransparency = 1
FastClickTitle.Text = "Enable Click Egg Fast by hand"
FastClickTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
FastClickTitle.TextSize = 10
FastClickTitle.TextXAlignment = Enum.TextXAlignment.Left
FastClickTitle.Font = Enum.Font.Gotham
FastClickTitle.Parent = FastClickHolder

local FastClickButton = Instance.new("TextButton")
FastClickButton.Size = UDim2.new(0, 70, 0, 26)
FastClickButton.Position = UDim2.new(1, -70, 0.5, -13)
FastClickButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
FastClickButton.BorderSizePixel = 0
FastClickButton.Text = "Click"
FastClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FastClickButton.TextSize = 12
FastClickButton.Font = Enum.Font.GothamBold
FastClickButton.AutoButtonColor = false
FastClickButton.Parent = FastClickHolder

local FastClickCorner = Instance.new("UICorner")
FastClickCorner.CornerRadius = UDim.new(0, 6)
FastClickCorner.Parent = FastClickButton

local FastClickStroke = Instance.new("UIStroke")
FastClickStroke.Color = Color3.fromRGB(140, 125, 240)
FastClickStroke.Thickness = 1.5
FastClickStroke.Transparency = 0.3
FastClickStroke.Parent = FastClickButton

FastClickButton.MouseEnter:Connect(function()
    TweenService:Create(FastClickButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(125, 110, 220)
    }):Play()
end)

FastClickButton.MouseLeave:Connect(function()
    TweenService:Create(FastClickButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

FastClickButton.MouseButton1Down:Connect(function()
    TweenService:Create(FastClickButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 62, 0, 23),
        BackgroundColor3 = Color3.fromRGB(85, 70, 170)
    }):Play()
end)

FastClickButton.MouseButton1Up:Connect(function()
    TweenService:Create(FastClickButton, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 70, 0, 26),
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

FastClickButton.MouseButton1Click:Connect(function()
    if not _G.YOKUDO_ManualFastClick then
        warn("[YOKUDO] ManualFastClick feature not loaded")
        ShowNotification("Manual Fast Click Not Loaded")
        return
    end

    if _G.YOKUDO_ManualFastClick.IsEnabled() then
        _G.YOKUDO_ManualFastClick.Disable()
        ShowNotification("Manual Fast Click Stop")
    else
        _G.YOKUDO_ManualFastClick.Enable()
        ShowNotification("Manual Fast Click Start")
    end
end)

task.spawn(function()
    task.wait(0.5)
    if _G.YOKUDO_ManualFastClick then
        if _G.YOKUDO_ManualFastClick.IsEnabled() then
            FastClickButton.Text = "Stop"
        else
            FastClickButton.Text = "Click"
        end
    end
end)

--==================================================
-- FEATURE 7: ANTI AFK
--==================================================
local AntiAFKHolder = Instance.new("Frame")
AntiAFKHolder.Size = UDim2.new(1, 0, 0, 52)
AntiAFKHolder.BackgroundTransparency = 1
AntiAFKHolder.LayoutOrder = 8
AntiAFKHolder.Parent = SettingPage

local AntiAFKLabel = Instance.new("TextLabel")
AntiAFKLabel.Size = UDim2.new(1, -50, 0, 20)
AntiAFKLabel.Position = UDim2.new(0, 0, 0, 2)
AntiAFKLabel.BackgroundTransparency = 1
AntiAFKLabel.Text = "Anti AFK"
AntiAFKLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAFKLabel.TextSize = 13
AntiAFKLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiAFKLabel.TextYAlignment = Enum.TextYAlignment.Center
AntiAFKLabel.Font = Enum.Font.GothamBold
AntiAFKLabel.Parent = AntiAFKHolder

local AntiAFKTitle = Instance.new("TextLabel")
AntiAFKTitle.Size = UDim2.new(1, -50, 0, 18)
AntiAFKTitle.Position = UDim2.new(0, 0, 0, 24)
AntiAFKTitle.BackgroundTransparency = 1
AntiAFKTitle.Text = "Click when AFK"
AntiAFKTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
AntiAFKTitle.TextSize = 10
AntiAFKTitle.TextXAlignment = Enum.TextXAlignment.Left
AntiAFKTitle.Font = Enum.Font.Gotham
AntiAFKTitle.Parent = AntiAFKHolder

local AntiAFKCheckButton = Instance.new("TextButton")
AntiAFKCheckButton.Size = UDim2.new(0, 26, 0, 26)
AntiAFKCheckButton.Position = UDim2.new(1, -26, 0.5, -13)
AntiAFKCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
AntiAFKCheckButton.BorderSizePixel = 0
AntiAFKCheckButton.Text = ""
AntiAFKCheckButton.AutoButtonColor = false
AntiAFKCheckButton.Parent = AntiAFKHolder

local AntiAFKCorner = Instance.new("UICorner")
AntiAFKCorner.CornerRadius = UDim.new(0, 6)
AntiAFKCorner.Parent = AntiAFKCheckButton

local AntiAFKStroke = Instance.new("UIStroke")
AntiAFKStroke.Color = Color3.fromRGB(200, 200, 220)
AntiAFKStroke.Thickness = 1.5
AntiAFKStroke.Parent = AntiAFKCheckButton

local AntiAFKCheck = Instance.new("TextLabel")
AntiAFKCheck.Size = UDim2.new(1, 0, 1, 0)
AntiAFKCheck.BackgroundTransparency = 1
AntiAFKCheck.Text = "✓"
AntiAFKCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAFKCheck.TextSize = 18
AntiAFKCheck.Font = Enum.Font.GothamBold
AntiAFKCheck.Visible = false
AntiAFKCheck.Parent = AntiAFKCheckButton

local AntiAFKEnabled = false

local function ToggleAntiAFK()
    AntiAFKEnabled = not AntiAFKEnabled
    AntiAFKCheck.Visible = AntiAFKEnabled
    if AntiAFKEnabled then
        AntiAFKCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        AntiAFKStroke.Color = Color3.fromRGB(135, 120, 225)
        if _G.YOKUDO_AntiAFK then
            _G.YOKUDO_AntiAFK.Enable()
        end
    else
        AntiAFKCheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
        AntiAFKStroke.Color = Color3.fromRGB(200, 200, 220)
        if _G.YOKUDO_AntiAFK then
            _G.YOKUDO_AntiAFK.Disable()
        end
    end
end

AntiAFKCheckButton.MouseButton1Click:Connect(function()
    ToggleAntiAFK()
end)

--==================================================
-- ✅ SYNC ON LOAD (Only Once - After Setting Load)
--==================================================
task.spawn(function()
    task.wait(0.5)

    -- ✅ Sync Dropdown
    if _G.YOKUDO_SelectedMethod then
        SelectedMethod = _G.YOKUDO_SelectedMethod
        DropdownBtn.Text = SelectedMethod .. " ▼"
    end

    -- ✅ Sync Speed
    if _G.YOKUDO_TeleportSpeed then
        SpeedTextBox.Text = tostring(_G.YOKUDO_TeleportSpeed)
    end

    -- ✅ Sync Anti AFK
    if _G.YOKUDO_AntiAFK then
        if _G.YOKUDO_AntiAFK.IsEnabled() then
            AntiAFKEnabled = true
            AntiAFKCheck.Visible = true
            AntiAFKCheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            AntiAFKStroke.Color = Color3.fromRGB(135, 120, 225)
        end
    end
end)

print("✅ Setting Tab Loaded")
