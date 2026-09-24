-- ==================================================
-- MOSCOW & FAQOURI HUB | UI.lua (Full Rainbow)
-- ==================================================

local UI = {}
local CoreGui = game:GetService("CoreGui")

function UI.Init()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoscowMainUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- تأثير الرينبو المتحرك للنافذة
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 128, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 128, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(128, 0, 255))
    })
    Gradient.Parent = MainFrame

    task.spawn(function()
        local offset = 0
        while MainFrame and MainFrame.Parent do
            offset = (offset + 0.005) % 1
            Gradient.Offset = Vector2.new(offset, 0)
            task.wait(0.03)
        end
    end)

    print("✅ Moscow Full Rainbow UI Loaded Successfully!")
end

return UI
