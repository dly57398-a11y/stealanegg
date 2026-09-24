--==================================================
-- YOKUDO HUB | FEATURE | Anti AFK
-- Prevent AFK Kick/Hop using 3 Methods
-- Method 1: Mouse Move
-- Method 2: Camera Rotation
-- Method 3: Camera Zoom
-- ✅ Register ជាមួយ CharacterSystem
--==================================================

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local MOUSE_INTERVAL_MIN = 45
local MOUSE_INTERVAL_MAX = 120

local CAMERA_INTERVAL_MIN = 60
local CAMERA_INTERVAL_MAX = 180

local ZOOM_INTERVAL_MIN = 90
local ZOOM_INTERVAL_MAX = 240

--==================================================
-- STATE
--==================================================

local AntiAFKEnabled = false
local MouseThread = nil
local CameraThread = nil
local ZoomThread = nil

--==================================================
-- METHOD 1: MOUSE MOVE
--==================================================

local function DoMouseMove()
    pcall(function()
        mousemoverel(math.random(-15, 15), math.random(-15, 15))
    end)
end

--==================================================
-- METHOD 2: CAMERA ROTATION
--==================================================

local function DoCameraRotation()
    pcall(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.Angles(
                math.rad(math.random(-2, 2)),
                math.rad(math.random(-3, 3)),
                0
            )
        end
    end)
end

--==================================================
-- METHOD 3: CAMERA ZOOM
--==================================================

local function DoCameraZoom()
    pcall(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            local Original = Camera.FieldOfView
            Camera.FieldOfView = Original + math.random(-5, 5)
            task.wait(0.3)
            Camera.FieldOfView = Original
        end
    end)
end

--==================================================
-- ENABLE / DISABLE
--==================================================

local function EnableAntiAFK()
    if AntiAFKEnabled then return end
    AntiAFKEnabled = true

    -- ✅ Method 1: Mouse Move
    MouseThread = task.spawn(function()
        while AntiAFKEnabled do
            local WaitTime = math.random(MOUSE_INTERVAL_MIN, MOUSE_INTERVAL_MAX)
            task.wait(WaitTime)
            if not AntiAFKEnabled then break end
            DoMouseMove()
            print("[YOKUDO] Anti AFK: Mouse Move")
        end
    end)

    -- ✅ Method 2: Camera Rotation
    CameraThread = task.spawn(function()
        while AntiAFKEnabled do
            local WaitTime = math.random(CAMERA_INTERVAL_MIN, CAMERA_INTERVAL_MAX)
            task.wait(WaitTime)
            if not AntiAFKEnabled then break end
            DoCameraRotation()
            print("[YOKUDO] Anti AFK: Camera Rotation")
        end
    end)

    -- ✅ Method 3: Camera Zoom
    ZoomThread = task.spawn(function()
        while AntiAFKEnabled do
            local WaitTime = math.random(ZOOM_INTERVAL_MIN, ZOOM_INTERVAL_MAX)
            task.wait(WaitTime)
            if not AntiAFKEnabled then break end
            DoCameraZoom()
            print("[YOKUDO] Anti AFK: Camera Zoom")
        end
    end)

    print("[YOKUDO] Anti AFK: ON (3 Methods)")
end

local function DisableAntiAFK()
    if not AntiAFKEnabled then return end
    AntiAFKEnabled = false

    if MouseThread then
        pcall(function() task.cancel(MouseThread) end)
        MouseThread = nil
    end
    if CameraThread then
        pcall(function() task.cancel(CameraThread) end)
        CameraThread = nil
    end
    if ZoomThread then
        pcall(function() task.cancel(ZoomThread) end)
        ZoomThread = nil
    end

    print("[YOKUDO] Anti AFK: OFF")
end

local function ToggleAntiAFK()
    if AntiAFKEnabled then
        DisableAntiAFK()
    else
        EnableAntiAFK()
    end
end

--==================================================
-- EXPORT
--==================================================

_G.YOKUDO_AntiAFK = {
    Enable = EnableAntiAFK,
    Disable = DisableAntiAFK,
    Toggle = ToggleAntiAFK,
    IsEnabled = function() return AntiAFKEnabled end,

    -- ✅ Settings
    MOUSE_INTERVAL_MIN = MOUSE_INTERVAL_MIN,
    MOUSE_INTERVAL_MAX = MOUSE_INTERVAL_MAX,
    CAMERA_INTERVAL_MIN = CAMERA_INTERVAL_MIN,
    CAMERA_INTERVAL_MAX = CAMERA_INTERVAL_MAX,
    ZOOM_INTERVAL_MIN = ZOOM_INTERVAL_MIN,
    ZOOM_INTERVAL_MAX = ZOOM_INTERVAL_MAX
}


print("✅ AntiAFK Feature Loaded (3 Methods + Register)")
