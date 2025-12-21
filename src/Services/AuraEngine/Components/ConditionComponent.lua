local ZA = ZAuras

-- Component for storing condition evaluation state
local ConditionComponent = {}

function ConditionComponent:new(data)
    local component = {
        shouldShow = data.shouldShow,
        lastEvaluated = data.lastEvaluated
    }
    
    return component
end

ZA.Services.AuraEngine.Components.ConditionComponent = ConditionComponent