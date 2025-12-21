local ZA = ZAuras

-- System for evaluating whether auras should be shown based on conditions
local ConditionEvaluationSystem = {
    priority = 3
}

function ConditionEvaluationSystem:update(entityManager)
    local ConditionComponent = ZA.Services.AuraEngine.Components.ConditionComponent
    
    -- Get all entities with AuraConfig and BuffData, but not marked for deletion
    local entities = entityManager:newQuery()
        :include({ "AuraConfigComponent", "BuffTypeComponent", "BuffDataComponent" })
        :exclude({ "RemoveBuffDataComponent" })
        :execute()
    
    for _, entityId in ipairs(entities) do
        local auraConfig = entityManager:getComponent(entityId, "AuraConfigComponent")
        local buffData = entityManager:getComponent(entityId, "BuffDataComponent")
        local condition = entityManager:getComponent(entityId, "ConditionComponent")
        
        -- Create ConditionComponent if it doesn't exist
        if not condition then
            condition = ConditionComponent:new({ shouldShow = false })
            entityManager:addComponent(entityId, "ConditionComponent", condition)
        end
        
        -- Evaluate condition
        local shouldShow = false
        
        if auraConfig.condition == "Active" then
            -- Show when buff is active
            shouldShow = buffData ~= nil
        elseif auraConfig.condition == "NotActive" then
            -- Show when buff is NOT active
            shouldShow = buffData == nil
        end
        
        -- Update condition component
        condition.shouldShow = shouldShow
        condition.lastEvaluated = GetTime()
    end
end

ZA.Services.AuraEngine.Systems.ConditionEvaluationSystem = ConditionEvaluationSystem
return ConditionEvaluationSystem
