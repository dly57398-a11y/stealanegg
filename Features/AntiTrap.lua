-- ==================================================
-- YOKUDO HUB | FEATURE | Anti Trap
-- Auto Remove Children in workspace.__DEBRIS
-- ==================================================

local AntiTrapEnabled = false

-- ==================================================
-- REMOVE CHILDREN
-- ==================================================
local function RemoveDebrisChildren()
    local Folder = workspace:FindFirstChild("__DEBRIS")
    if not Folder then return end

    for _, child in ipairs(Folder:GetChildren()) do
        pcall(function()
            child:Destroy()
        end)
    end
end

-- ==================================================
-- ENABLE
-- ==================================================
local function EnableAntiTrap()
    if AntiTrapEnabled then return end
    AntiTrapEnabled = true

    -- លុបភ្លាមម្តង
    RemoveDebrisChildren()

    -- Loop ធម្មតា រាល់ 1 វិនាទី
    task.spawn(function()
        while AntiTrapEnabled do
            task.wait(1)
            if AntiTrapEnabled then
                RemoveDebrisChildren()
            end
        end
    end)

    print("[YOKUDO] Anti Trap: ON")
end

-- ==================================================
-- DISABLE
-- ==================================================
local function DisableAntiTrap()
    AntiTrapEnabled = false
    print("[YOKUDO] Anti Trap: OFF")
end

-- ==================================================
-- TOGGLE
-- ==================================================
local function ToggleAntiTrap()
    if AntiTrapEnabled then
        DisableAntiTrap()
    else
        EnableAntiTrap()
    end
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_AntiTrap = {
    Toggle = ToggleAntiTrap,
    Enable = EnableAntiTrap,
    Disable = DisableAntiTrap,
    IsEnabled = function() return AntiTrapEnabled end
}

print("✅ AntiTrap Feature Loaded")
