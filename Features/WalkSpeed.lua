-- ==================================================
-- YOKUDO HUB | FEATURE | Walk Speed
-- ✅ Register ជាមួយ CharacterSystem
-- ==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ==================================================
-- VARIABLES
-- ==================================================
local WalkSpeedEnabled = false
local WalkSpeedValue = 50
local OriginalWalkSpeed = 16
local Connection = nil

-- ==================================================
-- GET HUMANOID
-- ==================================================
local function GetHumanoid()
    local Char = Player.Character
    if not Char then return nil end
    return Char:FindFirstChildOfClass("Humanoid")
end

-- ==================================================
-- APPLY WALK SPEED
-- ==================================================
local function ApplyWalkSpeed()
    local Hum = GetHumanoid()
    if Hum then
        Hum.WalkSpeed = WalkSpeedValue
    end
end

-- ==================================================
-- STOP WALK SPEED
-- ==================================================
local function StopWalkSpeed()
    local Hum = GetHumanoid()
    if Hum then
        Hum.WalkSpeed = OriginalWalkSpeed
    end
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

-- ==================================================
-- START WALK SPEED
-- ==================================================
local function StartWalkSpeed()
    local Hum = GetHumanoid()
    if Hum then
        OriginalWalkSpeed = Hum.WalkSpeed
    end
    
    ApplyWalkSpeed()
    
    if Connection then
        Connection:Disconnect()
    end
    
    Connection = RunService.Heartbeat:Connect(function()
        if WalkSpeedEnabled then
            ApplyWalkSpeed()
        end
    end)
end

-- ==================================================
-- SET VALUE
-- ==================================================
local function SetWalkSpeedValue(Value)
    WalkSpeedValue = math.clamp(Value, 50, 1000)
    if WalkSpeedEnabled then
        ApplyWalkSpeed()
    end
    print("[YOKUDO] Walk Speed Value: " .. WalkSpeedValue)
end

-- ==================================================
-- TOGGLE FUNCTION
-- ==================================================
local function ToggleWalkSpeed()
    WalkSpeedEnabled = not WalkSpeedEnabled
    
    if WalkSpeedEnabled then
        StartWalkSpeed()
        print("[YOKUDO] Walk Speed: ON (" .. WalkSpeedValue .. ")")
    else
        StopWalkSpeed()
        print("[YOKUDO] Walk Speed: OFF")
    end
end

-- ==================================================
-- ENABLE / DISABLE
-- ==================================================
local function EnableWalkSpeed()
    WalkSpeedEnabled = true
    StartWalkSpeed()
    print("[YOKUDO] Walk Speed: ON (" .. WalkSpeedValue .. ")")
end

local function DisableWalkSpeed()
    WalkSpeedEnabled = false
    StopWalkSpeed()
    print("[YOKUDO] Walk Speed: OFF")
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_WalkSpeed = {
    Toggle = ToggleWalkSpeed,
    Enable = EnableWalkSpeed,
    Disable = DisableWalkSpeed,
    SetValue = SetWalkSpeedValue,
    IsEnabled = function() return WalkSpeedEnabled end,
    GetValue = function() return WalkSpeedValue end
}

-- ==================================================
-- REGISTER WITH CHARACTER SYSTEM
-- ==================================================
if _G.YOKUDO_CharacterSystem then
    _G.YOKUDO_CharacterSystem:RegisterFeature({
        Name = "WalkSpeed",
        Enable = EnableWalkSpeed,
        Disable = DisableWalkSpeed,
        IsEnabled = function() return WalkSpeedEnabled end,
        OnCharacterAdded = function(Char, Hum, Root)
            if WalkSpeedEnabled then
                task.wait(0.5)
                if Hum then
                    pcall(function()
                        OriginalWalkSpeed = Hum.WalkSpeed
                        Hum.WalkSpeed = WalkSpeedValue
                    end)
                end
            end
        end
    })
end

print("✅ WalkSpeed Feature Loaded (Register)")
