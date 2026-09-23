-- ==================================================
-- YOKUDO HUB | FEATURE | Manager Drone
-- គ្រប់គ្រង Event → ហៅ Attack ឬ AFK
-- ✅ Event ចេញ → Stop AFK → Jump Out → Call Attack
--    (AttackDrone គ្រប់គ្រង Fly TP ទៅ Safe Zone ខ្លួនឯង)
-- ✅ Event Sec <= 10 → Stop Attack → Call AFK
-- ✅ Stop ពេល Disable
-- ✅ Restart ពេល Character Added
-- ==================================================

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

-- ==================================================
-- SETTINGS
-- ==================================================
local EVENT_CHECK_INTERVAL = 1
local EVENT_STOP_ATTACK_THRESHOLD = 10
local SAFE_WAIT_TIME = 1
local SAFE_ZONE = Vector3.new(533, 70, -366)
local AFK_JUMP_WAIT = 0.5

-- ==================================================
-- STATE
-- ==================================================
local ManagerEnabled = false
local LastEventSec = 0
local LastEventText = ""
local ManagerThread = nil

-- ==================================================
-- GET EVENT INFO
-- ==================================================
local function GetEventInfo()
    local Success, Value = pcall(function()
        return game:GetService("Players").LocalPlayer.PlayerGui
            .HUD.GameHUD.BottomRight.ExperimentTimer.Value.Text
    end)
    if not Success or not Value then
        return 0, "", false
    end

    local Text = tostring(Value)

    local HasEventEnds = string.find(Text, "Event ends") ~= nil
    local IsEventActive = HasEventEnds

    local M = tonumber(string.match(Text, "(%d+)m")) or 0
    local S = tonumber(string.match(Text, "(%d+)s")) or 0
    local TotalSec = M * 60 + S

    return TotalSec, Text, IsEventActive
end

-- ==================================================
-- FORCE STOP ALL FEATURES
-- ==================================================
local function ForceStopAll()
    print("[ManagerDrone] Force Stop All Features")

    if _G.YOKUDO_AttackDrone then
        pcall(function() _G.YOKUDO_AttackDrone.Stop() end)
    end
    if _G.YOKUDO_AFKSystem then
        pcall(function() _G.YOKUDO_AFKSystem.Disable() end)
    end
end

-- ==================================================
-- SWITCH FROM AFK TO ATTACK
-- Event ចេញ → Stop AFK → Jump Out → Call Attack
-- AttackDrone គ្រប់គ្រង Fly TP ទៅ Safe Zone ខ្លួនឯង
-- ==================================================
local function SwitchAFKToAttack()
    print("[ManagerDrone] Event Detected → Switch AFK to Attack")

    -- 1. រក Treadmill Pos
    local TreadmillPos = nil
    if _G.YOKUDO_AFKSystem then
        TreadmillPos = _G.YOKUDO_AFKSystem.GetMyTreadmillPos()
    end

    if not TreadmillPos and _G.YOKUDO_AFKSystem then
        local _, Treadmill = _G.YOKUDO_AFKSystem.FindMyPlotAndTreadmill()
        if Treadmill then
            TreadmillPos = Treadmill.Position
        end
    end

    if not TreadmillPos then
        print("[ManagerDrone] No Treadmill → Stop AFK → Call Attack")
        if _G.YOKUDO_AFKSystem then
            _G.YOKUDO_AFKSystem.Disable()
        end
        task.wait(0.5)
        if _G.YOKUDO_AttackDrone then
            _G.YOKUDO_AttackDrone.Start()
        end
        return
    end

    -- 2. Jump ចេញពី Treadmill រហូតដល់ Dist > 5
    print("[ManagerDrone] Jumping out of Treadmill...")
    _G.YOKUDO_AFKSystem.JumpOutTreadmill(TreadmillPos, function()
        print("[ManagerDrone] ✅ Jumped out!")

        -- 3. Stop AFK (បិទ AFKEnabled → FlyTP របស់ AFKSystem ឈប់)
        if _G.YOKUDO_AFKSystem then
            _G.YOKUDO_AFKSystem.Disable()
        end

        task.wait(AFK_JUMP_WAIT)

        -- 4. ហៅ Attack Drone (AttackDrone គ្រប់គ្រង Fly TP ទៅ Safe Zone ខ្លួនឯង)
        print("[ManagerDrone] Call Attack Drone → Fly TP to Safe Zone → Spawn Loop")
        if _G.YOKUDO_AttackDrone then
            _G.YOKUDO_AttackDrone.Start()
        end
    end)
end

-- ==================================================
-- MAIN LOOP
-- ==================================================
local function MainLoop()
    while ManagerEnabled do
        local EventSec, EventText, IsEventActive = GetEventInfo()

        local EventNotActive = not IsEventActive
        local EventStopAttack = IsEventActive and EventSec > 0 and EventSec <= EVENT_STOP_ATTACK_THRESHOLD
        local EventActive = IsEventActive and EventSec > EVENT_STOP_ATTACK_THRESHOLD

        print("[ManagerDrone] Text:", EventText, "| Sec:", EventSec, "| IsActive:", IsEventActive, "| NotActive:", EventNotActive, "| StopAttack:", EventStopAttack, "| Active:", EventActive)

        -- ==================================================
        -- Event មិនទាន់ចេញ (Text = "in Xm Ys") → AFK System
        -- ==================================================
        if EventNotActive then
            if _G.YOKUDO_AttackDrone and _G.YOKUDO_AttackDrone.IsEnabled() then
                print("[ManagerDrone] Event Not Active → Stop Attack")
                _G.YOKUDO_AttackDrone.Stop()
            end

            if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                print("[ManagerDrone] Event Not Active → AFK System")
                _G.YOKUDO_AFKSystem.Enable()
            end
        -- ==================================================
        -- Event ជិតចប់ (Sec <= 10) → Stop Attack → AFK
        -- ==================================================
        elseif EventStopAttack then
            if _G.YOKUDO_AttackDrone and _G.YOKUDO_AttackDrone.IsEnabled() then
                print("[ManagerDrone] Event <= 10s → Stop Attack → AFK System")
                _G.YOKUDO_AttackDrone.Stop()
            end

            if _G.YOKUDO_AFKSystem and not _G.YOKUDO_AFKSystem.IsEnabled() then
                _G.YOKUDO_AFKSystem.Enable()
            end
        -- ==================================================
        -- Event ចេញ (Sec > 10) → Switch AFK → Attack
        -- ==================================================
        elseif EventActive then
            if _G.YOKUDO_AFKSystem and _G.YOKUDO_AFKSystem.IsEnabled() then
                print("[ManagerDrone] Event Active → Switch AFK to Attack")
                SwitchAFKToAttack()
            elseif _G.YOKUDO_AttackDrone and not _G.YOKUDO_AttackDrone.IsEnabled() then
                print("[ManagerDrone] Event Active → Attack Drone")
                _G.YOKUDO_AttackDrone.Start()
            end
        end

        LastEventSec = EventSec
        LastEventText = EventText
        task.wait(EVENT_CHECK_INTERVAL)
    end

    ForceStopAll()
    print("[ManagerDrone] MainLoop Stopped")
end

-- ==================================================
-- ENABLE / DISABLE
-- ==================================================
local function EnableManager()
    if ManagerEnabled then return end
    ManagerEnabled = true

    if ManagerThread then
        pcall(function() task.cancel(ManagerThread) end)
        ManagerThread = nil
    end

    ManagerThread = task.spawn(function() MainLoop() end)

    print("[ManagerDrone] Manager Drone: ON")
end

local function DisableManager()
    if not ManagerEnabled then return end
    ManagerEnabled = false

    if ManagerThread then
        pcall(function() task.cancel(ManagerThread) end)
        ManagerThread = nil
    end

    ForceStopAll()

    print("[ManagerDrone] Manager Drone: OFF")
end

local function ToggleManager()
    if ManagerEnabled then
        DisableManager()
    else
        EnableManager()
    end
end

-- ==================================================
-- AUTO RE-APPLY ON CHARACTER ADDED
-- ==================================================
Player.CharacterAdded:Connect(function(Char)
    if ManagerEnabled then
        print("[ManagerDrone] Character Added → Restarting Manager...")
        task.wait(1)

        LastEventSec = 0
        LastEventText = ""

        if ManagerThread then
            pcall(function() task.cancel(ManagerThread) end)
            ManagerThread = nil
        end

        ManagerThread = task.spawn(function() MainLoop() end)

        print("[ManagerDrone] ✅ Re-applied on new Character")
    end
end)

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_ManagerDrone = {
    Enable = EnableManager,
    Disable = DisableManager,
    Toggle = ToggleManager,
    IsEnabled = function() return ManagerEnabled end,
    GetEventInfo = GetEventInfo,
    ForceStopAll = ForceStopAll,
    SwitchAFKToAttack = SwitchAFKToAttack,
}

print("✅ ManagerDrone Feature Loaded (Switch AFK to Attack)")
