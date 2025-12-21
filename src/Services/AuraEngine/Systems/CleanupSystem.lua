local ZA = ZAuras

-- System for cleaning up outdated entities and components
local CleanupSystem = {
    priority = 6,
    cleanupInterval = 1.0, -- Run cleanup every second
    lastCleanupTime = 0
}

function CleanupSystem:update(entityManager)
    -- Remove all display-related components from entities marked with RemoveBuffDataComponent
    local markedEntities = entityManager:query({ "RemoveBuffDataComponent" })
    
    for _, entityId in ipairs(markedEntities) do
        -- Remove all components related to buff display
        -- Lifecycle methods (e.g., IconComponent:onRemove) are called automatically
        entityManager:removeComponent(entityId, "BuffDataComponent")
        entityManager:removeComponent(entityId, "IconComponent")
        entityManager:removeComponent(entityId, "PositionComponent")
        entityManager:removeComponent(entityId, "ConditionComponent")
    end
    
    -- Periodically clean up orphaned entities (without AuraConfig)
    local currentTime = GetTime()
    if currentTime - self.lastCleanupTime >= self.cleanupInterval then
        self.lastCleanupTime = currentTime
        
        local allEntities = entityManager:query({})
        for _, entityId in ipairs(allEntities) do
            local auraConfig = entityManager:getComponent(entityId, "AuraConfigComponent")
            
            -- If entity has no AuraConfig, it's orphaned and should be cleaned up
            if not auraConfig then
                self:cleanupEntity(entityManager, entityId)
                entityManager:destroyEntity(entityId)
            end
        end
    end
end

ZA.Services.AuraEngine.Systems.CleanupSystem = CleanupSystem
return CleanupSystem
