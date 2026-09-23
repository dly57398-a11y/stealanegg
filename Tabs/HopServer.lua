-- ==================================================
-- YOKUDO HUB | TAB | Hop Server
-- Feature: Check Hop Server Low Player
-- ==================================================

local TabsManager = _G.YOKUDO_TabsManager
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local PLACE_ID = 107778070777162

local HopServerTab, HopServerPage = TabsManager:RegisterTab("Hop Server", 6, "HOP_SERVER")

-- ==================================================
-- CONTENT
-- ==================================================
CreateSectionTitle(HopServerPage, "Hop Server", 1)

-- ==================================================
-- FEATURE: Check Hop Server Low Player
-- ==================================================
local FeatureHolder = Instance.new("Frame")
FeatureHolder.Size = UDim2.new(1, 0, 0, 60)
FeatureHolder.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
FeatureHolder.BorderSizePixel = 0
FeatureHolder.LayoutOrder = 2
FeatureHolder.Parent = HopServerPage

local FeatureCorner = Instance.new("UICorner")
FeatureCorner.CornerRadius = UDim.new(0, 8)
FeatureCorner.Parent = FeatureHolder

local FeatureStroke = Instance.new("UIStroke")
FeatureStroke.Color = Color3.fromRGB(105, 90, 190)
FeatureStroke.Thickness = 1.5
FeatureStroke.Transparency = 0.4
FeatureStroke.Parent = FeatureHolder

local FeatureName = Instance.new("TextLabel")
FeatureName.Size = UDim2.new(1, -100, 0, 20)
FeatureName.Position = UDim2.new(0, 12, 0, 10)
FeatureName.BackgroundTransparency = 1
FeatureName.Text = "Check Hop Server Low Player"
FeatureName.TextColor3 = Color3.fromRGB(255, 255, 255)
FeatureName.TextSize = 13
FeatureName.TextXAlignment = Enum.TextXAlignment.Left
FeatureName.Font = Enum.Font.GothamBold
FeatureName.Parent = FeatureHolder

local FeatureStatus = Instance.new("TextLabel")
FeatureStatus.Size = UDim2.new(1, -100, 0, 16)
FeatureStatus.Position = UDim2.new(0, 12, 0, 32)
FeatureStatus.BackgroundTransparency = 1
FeatureStatus.Text = "Click to search servers"
FeatureStatus.TextColor3 = Color3.fromRGB(150, 150, 170)
FeatureStatus.TextSize = 10
FeatureStatus.TextXAlignment = Enum.TextXAlignment.Left
FeatureStatus.Font = Enum.Font.Gotham
FeatureStatus.Parent = FeatureHolder

local ClickBtn = Instance.new("TextButton")
ClickBtn.Size = UDim2.new(0, 70, 0, 30)
ClickBtn.Position = UDim2.new(1, -82, 0.5, -15)
ClickBtn.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
ClickBtn.BorderSizePixel = 0
ClickBtn.Text = "Click"
ClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickBtn.TextSize = 12
ClickBtn.Font = Enum.Font.GothamBold
ClickBtn.AutoButtonColor = false
ClickBtn.Parent = FeatureHolder

local ClickCorner = Instance.new("UICorner")
ClickCorner.CornerRadius = UDim.new(0, 6)
ClickCorner.Parent = ClickBtn

local ClickStroke = Instance.new("UIStroke")
ClickStroke.Color = Color3.fromRGB(140, 125, 240)
ClickStroke.Thickness = 1.5
ClickStroke.Transparency = 0.3
ClickStroke.Parent = ClickBtn

ClickBtn.MouseEnter:Connect(function()
    TweenService:Create(ClickBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(125, 110, 220)
    }):Play()
end)

ClickBtn.MouseLeave:Connect(function()
    TweenService:Create(ClickBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    }):Play()
end)

-- ==================================================
-- SERVER LIST (Scroll)
-- ==================================================
local ServerScroll = Instance.new("ScrollingFrame")
ServerScroll.Size = UDim2.new(1, 0, 0, 220)
ServerScroll.BackgroundTransparency = 1
ServerScroll.BorderSizePixel = 0
ServerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ServerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ServerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
ServerScroll.ScrollBarThickness = 4
ServerScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
ServerScroll.ScrollBarImageTransparency = 0.1
ServerScroll.LayoutOrder = 3
ServerScroll.Parent = HopServerPage

local ServerListLayout = Instance.new("UIListLayout")
ServerListLayout.Padding = UDim.new(0, 4)
ServerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ServerListLayout.Parent = ServerScroll

-- ==================================================
-- CLEAR LIST
-- ==================================================
local function ClearList()
    for _, child in ipairs(ServerScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- ==================================================
-- CREATE SERVER ENTRY
-- ==================================================
local function CreateEntry(index, server)
    local Entry = Instance.new("Frame")
    Entry.Size = UDim2.new(1, -6, 0, 52)
    Entry.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
    Entry.BorderSizePixel = 0
    Entry.LayoutOrder = index
    Entry.Parent = ServerScroll

    local EntryCorner = Instance.new("UICorner")
    EntryCorner.CornerRadius = UDim.new(0, 6)
    EntryCorner.Parent = Entry

    local EntryStroke = Instance.new("UIStroke")
    EntryStroke.Color = Color3.fromRGB(105, 90, 190)
    EntryStroke.Thickness = 1
    EntryStroke.Transparency = 0.6
    EntryStroke.Parent = Entry

    -- លេខរៀង
    local IndexLabel = Instance.new("TextLabel")
    IndexLabel.Size = UDim2.new(0, 26, 1, 0)
    IndexLabel.Position = UDim2.new(0, 6, 0, 0)
    IndexLabel.BackgroundTransparency = 1
    IndexLabel.Text = tostring(index)
    IndexLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    IndexLabel.TextSize = 14
    IndexLabel.Font = Enum.Font.GothamBold
    IndexLabel.TextXAlignment = Enum.TextXAlignment.Center
    IndexLabel.TextYAlignment = Enum.TextYAlignment.Center
    IndexLabel.Parent = Entry

    -- Jobid
    local JobLabel = Instance.new("TextLabel")
    JobLabel.Size = UDim2.new(1, -110, 1, 0)
    JobLabel.Position = UDim2.new(0, 36, 0, 0)
    JobLabel.BackgroundTransparency = 1
    JobLabel.Text = "Jobid : " .. server.id
    JobLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    JobLabel.TextSize = 11
    JobLabel.Font = Enum.Font.GothamMedium
    JobLabel.TextXAlignment = Enum.TextXAlignment.Left
    JobLabel.TextYAlignment = Enum.TextYAlignment.Center
    JobLabel.TextTruncate = Enum.TextTruncate.AtEnd
    JobLabel.Parent = Entry

    -- Join Button
    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Size = UDim2.new(0, 60, 0, 30)
    JoinBtn.Position = UDim2.new(1, -68, 0.5, -15)
    JoinBtn.BackgroundColor3 = Color3.fromRGB(105, 90, 190)
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "Join"
    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    JoinBtn.TextSize = 12
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.AutoButtonColor = false
    JoinBtn.Parent = Entry

    local JoinCorner = Instance.new("UICorner")
    JoinCorner.CornerRadius = UDim.new(0, 6)
    JoinCorner.Parent = JoinBtn

    local JoinStroke = Instance.new("UIStroke")
    JoinStroke.Color = Color3.fromRGB(140, 125, 240)
    JoinStroke.Thickness = 1.5
    JoinStroke.Transparency = 0.3
    JoinStroke.Parent = JoinBtn

    JoinBtn.MouseEnter:Connect(function()
        TweenService:Create(JoinBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(125, 110, 220)
        }):Play()
    end)

    JoinBtn.MouseLeave:Connect(function()
        TweenService:Create(JoinBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(105, 90, 190)
        }):Play()
    end)

    JoinBtn.MouseButton1Click:Connect(function()
        FeatureStatus.Text = "Teleporting to server..."
        FeatureStatus.TextColor3 = Color3.fromRGB(0, 255, 105)

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, game.Players.LocalPlayer)
        end)

        if not success then
            FeatureStatus.Text = "Failed: " .. tostring(err)
            FeatureStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

-- ==================================================
-- FETCH SERVERS (ASC ONLY, PLAYER = 1)
-- ==================================================
local function FetchServers()
    local allServers = {}
    local seen = {}
    local cursor = ""
    local pageCount = 0
    local maxPages = 5

    repeat
        pageCount = pageCount + 1

        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s",
            PLACE_ID,
            cursor
        )

        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if not success or not response or not response.data then
            break
        end

        for _, server in ipairs(response.data) do
            if server.playing == 1
               and server.id ~= game.JobId
               and server.maxPlayers > 1
               and server.playing < server.maxPlayers then
                if not seen[server.id] then
                    seen[server.id] = true
                    table.insert(allServers, server)
                end
            end
        end

        cursor = response.next_cursor or ""
        task.wait(0.15)

    until cursor == "" or pageCount >= maxPages

    return allServers
end

-- ==================================================
-- SEARCH FUNCTION
-- ==================================================
ClickBtn.MouseButton1Click:Connect(function()
    FeatureStatus.Text = "Searching fresh servers..."
    FeatureStatus.TextColor3 = Color3.fromRGB(150, 150, 170)
    ClearList()

    local servers = FetchServers()

    if #servers == 0 then
        FeatureStatus.Text = "No servers with 1 player found."
        FeatureStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end

    table.sort(servers, function(a, b)
        return a.id < b.id
    end)

    for i, server in ipairs(servers) do
        CreateEntry(i, server)
    end

    FeatureStatus.Text = "Found " .. #servers .. " server(s) with 1 player."
    FeatureStatus.TextColor3 = Color3.fromRGB(0, 255, 105)
end)

print("✅ Hop Server Tab Loaded")
