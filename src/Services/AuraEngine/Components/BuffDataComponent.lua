local ZA = ZAuras

-- Component for storing WoW API buff data
local BuffDataComponent = {}

function BuffDataComponent:new(data)
    local component = {
        name = data.name,
        icon = data.icon,
        applications = data.applications,
        timeLeft = data.timeLeft,
        dispelType = data.dispelType,
        buffIndex = data.buffIndex,
        lastUpdate = GetTime()
    }
    
    return component
end

ZA.Services.AuraEngine.Components.BuffDataComponent = BuffDataComponent