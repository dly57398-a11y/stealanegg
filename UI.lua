-- ==================================================
-- MOSCOW & FAQOURI HUB | Complete UI.lua (Full Rainbow)
-- ==================================================

local UI = {}

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    ContentProvider = game:GetService("ContentProvider"),
}

local Player = Services.Players.LocalPlayer
local CoreGui = Services.CoreGui

function UI.Init()
    -- تنظيف الواجهات القديمة لمنع التكرار
    pcall(function()
        local Old = CoreGui:FindFirstChild("YOKUDO_HUB")
        if Old then Old:Destroy() end
        local OldToggle = CoreGui:FindFirstChild("ToggleGUI")
        if OldToggle then OldToggle:Destroy() end
    end)

    -- إنشاء الشاشة الأساسية
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YOKUDO_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = CoreGui

    -- إطار النافذة الرئيسي
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 14)
    UICorner.Parent = Main

    -- تأثير الرينبو المتحرك الفخم
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 128, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 128, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(128, 0, 255))
    })
    RainbowGradient.Parent = Main

    task.spawn(function()
        local offset = 0
        while Main and Main.Parent do
            offset = (offset + 0.005) % 1
            RainbowGradient.Offset = Vector2.new(offset, 0)
            task.wait(0.03)
        end
    end)

    -- شريط العناوين العلوي الخاص بالهب
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TopBar.BackgroundTransparency = 0.5
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = "Moscow & Faqouri Hub | Full Rainbow UI"
    Title.Parent = TopBar

    print("✅ Moscow Full Rainbow Complete UI Loaded Successfully!")
end

return UI
