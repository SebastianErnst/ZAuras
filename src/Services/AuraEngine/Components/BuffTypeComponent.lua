local ZA = ZAuras

-- Marker component for buff-type auras
local BuffTypeComponent = {}

function BuffTypeComponent:new()
    return {}
end

ZA.Services.AuraEngine.Components.BuffTypeComponent = BuffTypeComponent
return BuffTypeComponent
