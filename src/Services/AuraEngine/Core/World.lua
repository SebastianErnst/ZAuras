local ZA = ZAuras
local World = {
    systems = {},
    entityManager = nil
}

-- Initialize the World with an EntityManager
function World:init(entityManager)
    self.entityManager = entityManager
    self.systems = {}
end

-- Add a system to the World
-- Systems will be executed in priority order (lower priority runs first)
function World:addSystem(system, priority)
    priority = priority or 100
    
    table.insert(self.systems, {
        system = system,
        priority = priority
    })
    
    -- Sort systems by priority
    table.sort(self.systems, function(a, b)
        return a.priority < b.priority
    end)
end

-- Update all systems
function World:update()
    for _, systemEntry in ipairs(self.systems) do
        if systemEntry.system.update then
            systemEntry.system:update(self.entityManager)
        end
    end
end

-- Clear all systems
function World:clear()
    self.systems = {}
end

ZA.Services.AuraEngine.Core.World = World
return World
