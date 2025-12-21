local ZA = ZAuras
local EntityManager = {
    entities = {},
    nextId = 1
}

-- Create a new entity and return its ID
function EntityManager:createEntity()
    local id = self.nextId
    self.nextId = self.nextId + 1
    self.entities[id] = { components = {} }
    return id
end

-- Destroy an entity and all its components
function EntityManager:destroyEntity(entityId)
    if not self.entities[entityId] then
        return false
    end
    self.entities[entityId] = nil
    return true
end

-- Add or update a component for an entity
function EntityManager:addComponent(entityId, componentType, componentData)
    if not self.entities[entityId] then
        return false
    end
    self.entities[entityId].components[componentType] = componentData
    return true
end

-- Get a component from an entity
function EntityManager:getComponent(entityId, componentType)
    if not self.entities[entityId] then
        return nil
    end
    return self.entities[entityId].components[componentType]
end

-- Check if entity has a component
function EntityManager:hasComponent(entityId, componentType)
    if not self.entities[entityId] then
        return false
    end
    return self.entities[entityId].components[componentType] ~= nil
end

-- Remove a component from an entity
function EntityManager:removeComponent(entityId, componentType)
    if not self.entities[entityId] then
        return false
    end
    
    local component = self.entities[entityId].components[componentType]
    
    -- Call lifecycle method if it exists
    if component and type(component) == "table" and component.onRemove then
        component:onRemove()
    end
    
    self.entities[entityId].components[componentType] = nil
    return true
end

-- Query entities that have all specified components
-- Optional: exclude entities that have any of the excluded components
function EntityManager:query(componentTypes, excludeTypes)
    local results = {}
    
    for entityId, entity in pairs(self.entities) do
        local hasAll = true
        for _, componentType in ipairs(componentTypes) do
            if not entity.components[componentType] then
                hasAll = false
                break
            end
        end
        
        -- Check exclusions
        if hasAll and excludeTypes then
            for _, excludeType in ipairs(excludeTypes) do
                if entity.components[excludeType] then
                    hasAll = false
                    break
                end
            end
        end
        
        if hasAll then
            table.insert(results, entityId)
        end
    end
    
    return results
end

-- Create a new query builder
function EntityManager:newQuery()
    local builder = {
        includeComponents = {},
        excludeComponents = {}
    }
    
    function builder:include(componentTypes)
        for _, componentType in ipairs(componentTypes) do
            table.insert(self.includeComponents, componentType)
        end
        return self
    end
    
    function builder:exclude(componentTypes)
        for _, componentType in ipairs(componentTypes) do
            table.insert(self.excludeComponents, componentType)
        end
        return self
    end
    
    function builder:execute()
        return EntityManager:query(self.includeComponents, self.excludeComponents)
    end
    
    return builder
end

-- Clear all entities
function EntityManager:clear()
    self.entities = {}
    self.nextId = 1
end

-- Get total entity count
function EntityManager:getEntityCount()
    local count = 0
    for _ in pairs(self.entities) do
        count = count + 1
    end
    return count
end

-- Print all entities and their components (for debugging)
function EntityManager:printAllEntities()
    print("=== EntityManager: All Entities ===")
    print("Total entities: " .. self:getEntityCount())
    
    for entityId, entity in pairs(self.entities) do
        print("Entity ID: " .. entityId)
        for componentType, componentData in pairs(entity.components) do
            print("  Component: " .. tostring(componentType))
            if type(componentData) == "table" then
                for k, v in pairs(componentData) do
                    print("    " .. tostring(k) .. " = " .. tostring(v))
                end
            else
                print("    Value: " .. tostring(componentData))
            end
        end
    end
    
    print("===================================")
end

ZA.Services.AuraEngine.Core.EntityManager = EntityManager
return EntityManager
