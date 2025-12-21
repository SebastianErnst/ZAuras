local ZA = ZAuras

-- Marker component to indicate that a buff is no longer active
-- Used to mark entities for cleanup in the next frame
local NoBuffActiveComponent = {}
NoBuffActiveComponent.__index = NoBuffActiveComponent

function NoBuffActiveComponent:new()
    local instance = {
        markedAt = GetTime()
    }
    setmetatable(instance, NoBuffActiveComponent)
    return instance
end

ZA.Services.AuraEngine.Components.NoBuffActiveComponent = NoBuffActiveComponent
return NoBuffActiveComponent
