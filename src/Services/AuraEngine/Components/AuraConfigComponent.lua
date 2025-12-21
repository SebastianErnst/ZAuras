local ZA = ZAuras

-- Component for storing user-configured aura data from DB
local AuraConfigComponent = {}

function AuraConfigComponent:new(data)
    local component = {
        auraId = data.auraId,
        auraName = data.auraName ,
        auraType = data.auraType, 
        condition = data.condition,
        iconWidth = data.iconWidth,
        iconHeight = data.iconHeight,
        positionX = data.positionX,
        positionY = data.positionY,
        anchorPoint = data.anchorPoint,
        alpha = data.alpha 
    }
    
    return component
end

ZA.Services.AuraEngine.Components.AuraConfigComponent = AuraConfigComponent