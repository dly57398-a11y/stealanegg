-- ==================================================
-- YOKUDO HUB | NEW PROJECT | Components
-- ==================================================

local TweenService = game:GetService("TweenService")

-- ==================================================
-- GET TAB TEXT SIZE
-- ==================================================
local function GetTabTextSize(Name)
    local Length = #Name
    if Length >= 16 then return 10
    elseif Length >= 13 then return 11
    elseif Length >= 9 then return 12
    elseif Length >= 6 then return 13
    else return 14 end
end

-- ==================================================
-- CREATE TAB
-- ==================================================
function CreateTab(Name, Order)
    local TabScroll = _G.YOKUDO_TabScroll
    local Tab = Instance.new("TextButton")
    Tab.Name = Name:gsub("%s+", "_") .. "_Tab"
    Tab.Size = UDim2.new(1, 0, 0, 32)
    Tab.BackgroundColor3 = Color3.fromRGB(38, 40, 52)
    Tab.BackgroundTransparency = 1
    Tab.BorderSizePixel = 0
    Tab.Text = ""
    Tab.AutoButtonColor = false
    Tab.LayoutOrder = Order or 1
    Tab.ZIndex = 7
    Tab.Parent = TabScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Tab

    local TabBorder = Instance.new("UIStroke")
    TabBorder.Color = Color3.fromRGB(200, 200, 220)
    TabBorder.Thickness = 1
    TabBorder.Transparency = 0.2
    TabBorder.Parent = Tab

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0, 18)
    Indicator.Position = UDim2.new(0, 2, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    Indicator.BackgroundTransparency = 1
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 8
    Indicator.Parent = Tab

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    local Text = Instance.new("TextLabel")
    Text.Name = "TabText"
    Text.Size = UDim2.new(1, -10, 1, 0)
    Text.Position = UDim2.new(0, 8, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = Name
    Text.TextColor3 = Color3.fromRGB(155, 155, 175)
    Text.TextSize = GetTabTextSize(Name)
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Center
    Text.Font = Enum.Font.GothamMedium
    Text.TextTruncate = Enum.TextTruncate.AtEnd
    Text.Active = false
    Text.Selectable = false
    Text.ZIndex = 8
    Text.Parent = Tab

    return Tab
end

-- ==================================================
-- CREATE PAGE
-- ==================================================
function CreatePage(Name)
    local Content = _G.YOKUDO_Content
    local Page = Instance.new("ScrollingFrame")
    Page.Name = Name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
    Page.ScrollBarImageTransparency = 0.1
    Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    Page.HorizontalScrollBarInset = Enum.ScrollBarInset.None
    Page.Active = true
    Page.Selectable = true
    Page.ZIndex = 6
    Page.Parent = Content

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 12)
    Padding.PaddingBottom = UDim.new(0, 14)
    Padding.PaddingLeft = UDim.new(0, 14)
    Padding.PaddingRight = UDim.new(0, 12)
    Padding.Parent = Page

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 4)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Page

    return Page
end

-- ==================================================
-- CREATE SECTION TITLE
-- ==================================================
function CreateSectionTitle(Parent, TextValue, Order)
    local Label = Instance.new("TextLabel")
    Label.Name = "SectionTitle"
    Label.Size = UDim2.new(1, 0, 0, 23)
    Label.BackgroundTransparency = 1
    Label.Text = TextValue
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Font = Enum.Font.GothamBold
    Label.LayoutOrder = Order or 1
    Label.Active = false
    Label.Selectable = false
    Label.ZIndex = 8
    Label.Parent = Parent
    return Label
end

-- ==================================================
-- CREATE CHECKBOX
-- ==================================================
function CreateCheckbox(Parent, TextValue, Order)
    local Holder = Instance.new("Frame")
    Holder.Name = TextValue:gsub("%s+", "_")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.LayoutOrder = Order or 1
    Holder.Active = false
    Holder.ZIndex = 9
    Holder.Parent = Parent

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -38, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = TextValue
    Label.TextColor3 = Color3.fromRGB(205, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Font = Enum.Font.GothamMedium
    Label.Active = false
    Label.Selectable = false
    Label.ZIndex = 10
    Label.Parent = Holder

    local CheckButton = Instance.new("TextButton")
    CheckButton.Name = "CheckBox"
    CheckButton.Size = UDim2.new(0, 26, 0, 26)
    CheckButton.Position = UDim2.new(1, -26, 0.5, -13)
    CheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
    CheckButton.BorderSizePixel = 0
    CheckButton.Text = ""
    CheckButton.AutoButtonColor = false
    CheckButton.Active = true
    CheckButton.ZIndex = 20
    CheckButton.Parent = Holder

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = CheckButton

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(200, 200, 220)
    BoxStroke.Thickness = 1.5
    BoxStroke.Parent = CheckButton

    local Check = Instance.new("TextLabel")
    Check.Name = "Check"
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = "✓"
    Check.TextColor3 = Color3.fromRGB(255, 255, 255)
    Check.TextSize = 18
    Check.Font = Enum.Font.GothamBold
    Check.Visible = false
    Check.Active = false
    Check.Selectable = false
    Check.ZIndex = 21
    Check.Parent = CheckButton

    local Enabled = false

    local function Toggle()
        Enabled = not Enabled
        Check.Visible = Enabled
        if Enabled then
            CheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            BoxStroke.Color = Color3.fromRGB(135, 120, 225)
        else
            CheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
            BoxStroke.Color = Color3.fromRGB(200, 200, 220)
        end
    end

    CheckButton.MouseButton1Click:Connect(function()
        Toggle()
    end)

    return Holder, CheckButton, function() return Enabled end
end

-- ==================================================
-- CREATE TEXTBOX WITH CHECKBOX
-- ==================================================
function CreateTextBoxWithCheckbox(Parent, TextValue, Order, DefaultValue, MinValue, MaxValue)
    DefaultValue = DefaultValue or 50
    MinValue = MinValue or 0
    MaxValue = MaxValue or 1000

    local Holder = Instance.new("Frame")
    Holder.Name = TextValue:gsub("%s+", "_")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.LayoutOrder = Order or 1
    Holder.Active = false
    Holder.ZIndex = 9
    Holder.Parent = Parent

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = TextValue
    Label.TextColor3 = Color3.fromRGB(205, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Font = Enum.Font.GothamMedium
    Label.Active = false
    Label.Selectable = false
    Label.ZIndex = 10
    Label.Parent = Holder

    local TextBox = Instance.new("TextBox")
    TextBox.Name = "TextBox"
    TextBox.Size = UDim2.new(0, 60, 1, -6)
    TextBox.Position = UDim2.new(0, 105, 0, 3)
    TextBox.BackgroundColor3 = Color3.fromRGB(30, 31, 45)
    TextBox.BorderSizePixel = 0
    TextBox.Text = tostring(DefaultValue)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 12
    TextBox.TextXAlignment = Enum.TextXAlignment.Center
    TextBox.TextYAlignment = Enum.TextYAlignment.Center
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.ZIndex = 11
    TextBox.Parent = Holder

    local TBoxCorner = Instance.new("UICorner")
    TBoxCorner.CornerRadius = UDim.new(0, 4)
    TBoxCorner.Parent = TextBox

    local TBoxStroke = Instance.new("UIStroke")
    TBoxStroke.Color = Color3.fromRGB(200, 200, 220)
    TBoxStroke.Thickness = 0.5
    TBoxStroke.Transparency = 0.2
    TBoxStroke.Parent = TextBox

    local CheckButton = Instance.new("TextButton")
    CheckButton.Name = "CheckBox"
    CheckButton.Size = UDim2.new(0, 26, 0, 26)
    CheckButton.Position = UDim2.new(1, -26, 0.5, -13)
    CheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
    CheckButton.BorderSizePixel = 0
    CheckButton.Text = ""
    CheckButton.AutoButtonColor = false
    CheckButton.Active = true
    CheckButton.ZIndex = 20
    CheckButton.Parent = Holder

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = CheckButton

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(200, 200, 220)
    BoxStroke.Thickness = 1.5
    BoxStroke.Parent = CheckButton

    local Check = Instance.new("TextLabel")
    Check.Name = "Check"
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = "✓"
    Check.TextColor3 = Color3.fromRGB(255, 255, 255)
    Check.TextSize = 18
    Check.Font = Enum.Font.GothamBold
    Check.Visible = false
    Check.Active = false
    Check.Selectable = false
    Check.ZIndex = 21
    Check.Parent = CheckButton

    local Enabled = false
    local CurrentValue = DefaultValue

    local function UpdateValue()
        local val = tonumber(TextBox.Text)
        if val then
            CurrentValue = math.clamp(val, MinValue, MaxValue)
            TextBox.Text = tostring(CurrentValue)
        else
            TextBox.Text = tostring(CurrentValue)
        end
    end

    local function Toggle()
        Enabled = not Enabled
        Check.Visible = Enabled
        if Enabled then
            CheckButton.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            BoxStroke.Color = Color3.fromRGB(135, 120, 225)
        else
            CheckButton.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
            BoxStroke.Color = Color3.fromRGB(200, 200, 220)
        end
    end

    CheckButton.MouseButton1Click:Connect(function()
        Toggle()
    end)

    TextBox.FocusLost:Connect(function()
        UpdateValue()
    end)

    return Holder, CheckButton, function() return Enabled end, TextBox, function() return CurrentValue end
end

-- ==================================================
-- SMART CHECKBOX
-- ==================================================
function CreateSmartCheckbox(Parent, LabelText, Order, ToggleFunction, GetStateFunction)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundTransparency = 1
    Holder.LayoutOrder = Order or 1
    Holder.Parent = Parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -38, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = LabelText
    Label.TextColor3 = Color3.fromRGB(205, 205, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Font = Enum.Font.GothamMedium
    Label.Parent = Holder

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 26, 0, 26)
    Button.Position = UDim2.new(1, -26, 0.5, -13)
    Button.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = Holder

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = Button

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(200, 200, 220)
    BoxStroke.Thickness = 1.5
    BoxStroke.Parent = Button

    local Check = Instance.new("TextLabel")
    Check.Size = UDim2.new(1, 0, 1, 0)
    Check.BackgroundTransparency = 1
    Check.Text = "✓"
    Check.TextColor3 = Color3.fromRGB(255, 255, 255)
    Check.TextSize = 18
    Check.Font = Enum.Font.GothamBold
    Check.Visible = false
    Check.Parent = Button

    local Enabled = false
    if GetStateFunction then
        Enabled = GetStateFunction()
        Check.Visible = Enabled
        if Enabled then
            Button.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            BoxStroke.Color = Color3.fromRGB(135, 120, 225)
        end
    end

    local function UpdateUI(state)
        Enabled = state
        Check.Visible = state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
            BoxStroke.Color = Color3.fromRGB(135, 120, 225)
        else
            Button.BackgroundColor3 = Color3.fromRGB(28, 29, 39)
            BoxStroke.Color = Color3.fromRGB(200, 200, 220)
        end
    end

    Button.MouseButton1Click:Connect(function()
        if ToggleFunction then
            local currentState = GetStateFunction and GetStateFunction() or Enabled
            local newState = not currentState
            UpdateUI(newState)
            task.spawn(function()
                ToggleFunction()
            end)
        end
    end)

    return {
        Holder = Holder,
        Button = Button,
        GetState = function() return Enabled end,
        SetState = UpdateUI,
        Update = UpdateUI,
    }
end

print("✅ Components Loaded")
