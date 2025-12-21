local ZA = ZAuras

-- System for removing RemoveBuffDataComponent markers after cleanup
local FlagCleanupSystem = {
    priority = 7 -- Runs after CleanupSystem
}

function FlagCleanupSystem:update(entityManager)
    -- Get all entities with RemoveBuffDataComponent marker
    local entities = entityManager:query({ "RemoveBuffDataComponent" })
    
    for _, entityId in ipairs(entities) do
        -- Remove the marker component (BuffData was already removed by CleanupSystem)
        entityManager:removeComponent(entityId, "RemoveBuffDataComponent")
    end
end

ZA.Services.AuraEngine.Systems.FlagCleanupSystem = FlagCleanupSystem
return FlagCleanupSystem
