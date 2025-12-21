local ZA = ZAuras
local ZAuraModel = {}
ZA.Models.ZAuraModel = ZAuraModel

function ZAuraModel:new()
    local public = {}
    local Log = ZA.Container:resolve("Log")
    local UUID = ZA.Container:resolve("UUID")

    function public:save(data)
        local newId = UUID:generate()
        data.id = newId
        ZAurasDB.ZAuras[newId] = data

        Log:info("Created aura with ID: " .. newId)
        return newId
    end

    function public:update(id, data)
        if ZAurasDB.ZAuras[id] then
            ZAurasDB.ZAuras[id] = data
            Log:info("Updated aura with ID: " .. id)
            return true
        end
        Log:warn("Aura with ID " .. id .. " not found for update.")
        return false
    end

    function public:delete(id)
        if ZAurasDB.ZAuras[id] then
            ZAurasDB.ZAuras[id] = nil
            Log:info("Deleted aura with ID: " .. id)
            return true
        end
        Log:warn("Aura with ID " .. id .. " not found for deletion.")
        return false
    end

    function public:validate(data)
    local errors = {}

    if not data.name or data.name == "" then
        table.insert(errors, "Name is required")
    end

    if not data.auraName or data.auraName == "" then
        table.insert(errors, "Aura Name is required")
    end

    if not data.displayType or data.displayType == "" then
        table.insert(errors, "Display Type is required")
    end

    if not data.auraType or data.auraType == "" then
        table.insert(errors, "Aura Type is required")
    end

    if not data.condition or data.condition == "" then
        table.insert(errors, "Condition is required")
    end

    local widthNum = tonumber(data.iconWidth)
    if not widthNum or widthNum <= 0 then
        table.insert(errors, "Icon Width must be a positive number")
    end

    local heightNum = tonumber(data.iconHeight)
    if not heightNum or heightNum <= 0 then
        table.insert(errors, "Icon Height must be a positive number")
    end

    local posX = tonumber(data.positionX)
    if not posX then
        table.insert(errors, "Icon Position X must be a positive number")
    end

    local posY = tonumber(data.positionY)
    if not posY then
        table.insert(errors, "Icon Position Y must be a positive number")
    end

    local anchorPoint = data.anchorPoint
    local validAnchorPoints = {
        "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
        "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER"
    }

    local isValidAnchorPoint = false
    for i = 1, table.getn(validAnchorPoints) do
        if validAnchorPoints[i] == anchorPoint then
            isValidAnchorPoint = true
            break
        end
    end

    if not anchorPoint or not isValidAnchorPoint then
        table.insert(errors, "Anchor Point must be one of: " .. table.concat(validAnchorPoints, ", "))
    end

    local alphaNum = tonumber(data.alpha)
    if not alphaNum or alphaNum < 1 or alphaNum > 100 then
        table.insert(errors, "Alpha must be between 1 and 100")
    end

        return table.getn(errors) == 0, errors
    end

    function public:getAll()
        return ZAurasDB.ZAuras
    end

    function public:getById(id)
        local aura = ZAurasDB.ZAuras[id]
        if not aura then
            return nil
        end
        
        -- Return a copy to prevent direct mutation
        local copy = {}
        for key, value in pairs(aura) do
            copy[key] = value
        end
        return copy
    end

    function public:printAll()
        Log:info("Listing all Auras:")
        for id, aura in pairs(ZAurasDB.ZAuras) do
            Log:info(string.format(
                "ID: %s, Name: %s, AuraName: %s, DisplayType: %s, AuraType: %s, Condition: %s, IconWidth: %s, IconHeight: %s, Alpha: %s",
                aura.id or "nil",
                aura.name or "nil",
                aura.auraName or "nil",
                aura.displayType or "nil",
                aura.auraType or "nil",
                aura.condition or "nil",
                tostring(aura.iconWidth),
                tostring(aura.iconHeight),
                tostring(aura.positionX),
                tostring(aura.positionY),
                aura.anchorPoint or "nil",
                tostring(aura.alpha)
            ))
        end
    end
    
    return public
end