local ZA = ZAuras

-- System for printing all entities and their components (debugging)
local DebugPrintSystem = {
    priority = 8, -- Runs last, after all other systems
    enabled = false -- Set to true to enable debug output
}

function DebugPrintSystem:update(entityManager)
    if not self.enabled then
        return
    end
    
    print("=== DebugPrintSystem: Frame Update ===")
    print("Time: " .. GetTime())
    print("Total Entities: " .. entityManager:getEntityCount())
    print("")
    
    -- Get all entities
    local allEntities = entityManager:query({})
    
    for _, entityId in ipairs(allEntities) do
        print("Entity ID: " .. entityId)
        
        -- Check for each component type
        local components = {
            "AuraConfigComponent",
            "BuffTypeComponent",
            "BuffDataComponent",
            "ConditionComponent",
            "IconComponent",
            "PositionComponent",
            "RemoveBuffDataComponent"
        }
        
        for _, componentType in ipairs(components) do
            local component = entityManager:getComponent(entityId, componentType)
            if component then
                print("  [" .. componentType .. "]")
                
                -- -- Print component data
                -- if type(component) == "table" then
                --     for key, value in pairs(component) do
                --         -- Skip functions and frame objects
                --         if type(value) ~= "function" and type(value) ~= "table" then
                --             print("    " .. tostring(key) .. " = " .. tostring(value))
                --         elseif key == "frame" then
                --             print("    frame = " .. (value and "exists" or "nil"))
                --         end
                --     end
                -- end
            end
        end
        
        print("") -- Empty line between entities
    end
    
    print("======================================")
    print("")
end

-- Helper function to enable/disable debug output
function DebugPrintSystem:setEnabled(enabled)
    self.enabled = enabled
    if enabled then
        print("DebugPrintSystem enabled")
    else
        print("DebugPrintSystem disabled")
    end
end

ZA.Services.AuraEngine.Systems.DebugPrintSystem = DebugPrintSystem
return DebugPrintSystem
