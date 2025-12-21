local ZA = ZAuras
local Container = {}
ZA.Container = Container

function Container:new()
    local public = {}
    local instances = {}
    local factories = {}
    local types = {}

    function public:register(key, factoryFunction, type)
        if factories[key] then
            error("Container: Key '" .. key .. "' is already registered!")
        end
        
        factories[key] = factoryFunction
        
        -- Type tracking (optional)
        if type then
            if not types[type] then
                types[type] = {}
            end
            table.insert(types[type], key)
        end
    end

    function public:resolve(key)
        if instances[key] then
            return instances[key]
        end
        
        if not factories[key] then
            error("Container: No factory registered for key '" .. key .. "'")
        end
        
        local factory = factories[key]
        local instance = factory()
        
        instances[key] = instance
        
        return instance
    end
    
    function public:resolveByType(type)
        if not types[type] then
            return {}
        end
        
        local results = {}
        for i = 1, table.getn(types[type]) do
            local key = types[type][i]
            table.insert(results, public:resolve(key))
        end
        
        return results
    end
    
    return public
end