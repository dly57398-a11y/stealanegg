-- ==================================================
-- YOKUDO HUB | FEATURE | Manual Fast Click
-- Enable Click Egg Fast by hand
-- Set ProximityPrompt HoldDuration = 0
-- ==================================================

local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

-- ==================================================
-- STATE
-- ==================================================
local ManualFastClickEnabled = false
local PromptConnection = nil
local HeartbeatConnection = nil

-- ==================================================
-- SET HOLD DURATION = 0
-- ==================================================
local function ApplyHoldDuration(prompt)
    if not prompt then return end
    pcall(function()
        prompt.HoldDuration = 0
    end)
end

-- ==================================================
-- SCAN ALL EXISTING PROMPTS
-- ==================================================
local function ScanAllPrompts()
    -- រក ProximityPrompt ទាំងអស់ក្នុង workspace
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            ApplyHoldDuration(descendant)
        end
    end

    -- រកក្នុង PlayerGui ដែរ (បើមាន)
    local Player = game.Players.LocalPlayer
    if Player then
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        if PlayerGui then
            for _, descendant in ipairs(PlayerGui:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    ApplyHoldDuration(descendant)
                end
            end
        end
    end
end

-- ==================================================
-- ENABLE
-- ==================================================
local function EnableManualFastClick()
    if ManualFastClickEnabled then return end
    ManualFastClickEnabled = true

    -- 1. Apply ភ្លាមទៅ prompt ដែលមានស្រាប់
    ScanAllPrompts()

    -- 2. ចាប់ព្រឹត្តិការណ៍ PromptShown សម្រាប់ prompt ថ្មី
    if PromptConnection then
        PromptConnection:Disconnect()
        PromptConnection = nil
    end
    PromptConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if not ManualFastClickEnabled then return end
        ApplyHoldDuration(prompt)
    end)

    -- 3. Heartbeat Scan ជាប់ៗ ដើម្បីធានាថា prompt ថ្មីៗត្រូវបានកែ
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
    local Counter = 0
    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not ManualFastClickEnabled then return end
        Counter = Counter + 1
        if Counter >= 30 then -- រាល់ ~0.5s
            Counter = 0
            ScanAllPrompts()
        end
    end)

    print("[YOKUDO] Manual Fast Click: ON")
end

-- ==================================================
-- DISABLE
-- ==================================================
local function DisableManualFastClick()
    if not ManualFastClickEnabled then return end
    ManualFastClickEnabled = false

    if PromptConnection then
        PromptConnection:Disconnect()
        PromptConnection = nil
    end
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end

    print("[YOKUDO] Manual Fast Click: OFF")
end

-- ==================================================
-- TOGGLE
-- ==================================================
local function ToggleManualFastClick()
    if ManualFastClickEnabled then
        DisableManualFastClick()
    else
        EnableManualFastClick()
    end
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_ManualFastClick = {
    Enable = EnableManualFastClick,
    Disable = DisableManualFastClick,
    Toggle = ToggleManualFastClick,
    IsEnabled = function() return ManualFastClickEnabled end,
    ScanAllPrompts = ScanAllPrompts,
    ApplyHoldDuration = ApplyHoldDuration
}

print("✅ ManualFastClick Feature Loaded")
