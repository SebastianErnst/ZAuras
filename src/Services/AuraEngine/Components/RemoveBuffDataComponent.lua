local ZA = ZAuras

-- Marker component to indicate that BuffDataComponent should be removed
-- Used by CleanupSystem to identify entities that need their buff data cleaned up
local RemoveBuffDataComponent = {}
RemoveBuffDataComponent.__index = RemoveBuffDataComponent

function RemoveBuffDataComponent:new()
    local instance = {
        markedAt = GetTime()
    }
    setmetatable(instance, RemoveBuffDataComponent)
    return instance
end

ZA.Services.AuraEngine.Components.RemoveBuffDataComponent = RemoveBuffDataComponent
return RemoveBuffDataComponent
