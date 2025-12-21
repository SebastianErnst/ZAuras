local ZA = ZAuras

-- Component for storing icon position data
local PositionComponent = {}

function PositionComponent:new(data)
    local component = {
        x = data.x or 0,
        y = data.y or 0,
        anchorPoint = data.anchorPoint or "CENTER",
        relativePoint = data.relativePoint or "CENTER"
    }
    
    return component
end

ZA.Services.AuraEngine.Components.PositionComponent = PositionComponent
return PositionComponent
