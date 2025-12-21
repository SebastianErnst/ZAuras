local ZA = ZAuras

-- Marker component for debuff-type auras
local DebuffTypeComponent = {}

function DebuffTypeComponent:new()
    return {}
end

ZA.Services.AuraEngine.Components.DebuffTypeComponent = DebuffTypeComponent
return DebuffTypeComponent
