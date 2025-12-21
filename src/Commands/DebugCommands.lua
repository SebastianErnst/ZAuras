local ZA = ZAuras

-- Command for toggling ECS debug output
local ToggleECSDebugCommand = {}
ZA.Commands.ToggleECSDebugCommand = ToggleECSDebugCommand

function ToggleECSDebugCommand:execute(enabled)
    local DebugPrintSystem = ZA.Services.AuraEngine.Systems.DebugPrintSystem
    
    if enabled == nil then
        -- Toggle current state
        enabled = not DebugPrintSystem.enabled
    end
    
    DebugPrintSystem:setEnabled(enabled)
    
    if enabled then
        print("ZAuras ECS Debug: ENABLED - Printing all entities and components each frame")
    else
        print("ZAuras ECS Debug: DISABLED")
    end
end

-- Global function for easy access via /run
function ZAuras.ToggleECSDebug(enabled)
    ToggleECSDebugCommand:execute(enabled)
end

return ToggleECSDebugCommand
