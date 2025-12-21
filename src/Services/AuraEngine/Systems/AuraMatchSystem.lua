local ZA = ZAuras

-- System for matching configured auras with active buffs
local AuraMatchSystem = {
    priority = 2,
    entityByAuraId = {} -- Track which entity belongs to which auraId
}

function AuraMatchSystem:update(entityManager)
    local BuffDataComponent = ZA.Services.AuraEngine.Components.BuffDataComponent
    local RemoveBuffDataComponent = ZA.Services.AuraEngine.Components.RemoveBuffDataComponent
    local BuffScanSystem = ZA.Services.AuraEngine.Systems.BuffScanSystem

    -- Get active buffs from BuffScanSystem
    local activeBuffs = BuffScanSystem.activeBuffs or {}

    -- Get all configured aura entities
    local configuredEntities = entityManager:query({ "AuraConfigComponent", "BuffTypeComponent" })

    for _, entityId in ipairs(configuredEntities) do
        local auraConfig = entityManager:getComponent(entityId, "AuraConfigComponent")
        local buffData = entityManager:getComponent(entityId, "BuffDataComponent")

        local activeBuff = activeBuffs[auraConfig.auraName]

        if activeBuff then
            -- Buff is active, add or update BuffDataComponent
            if not buffData then
                -- Create new BuffData component
                buffData = BuffDataComponent:new(activeBuff)
                entityManager:addComponent(entityId, "BuffDataComponent", buffData)
            else
                -- Update existing BuffData component
                buffData.name = activeBuff.name
                buffData.icon = activeBuff.icon
                buffData.applications = activeBuff.applications
                buffData.timeLeft = activeBuff.timeLeft
                buffData.dispelType = activeBuff.dispelType
                buffData.buffIndex = activeBuff.buffIndex
                buffData.lastUpdate = GetTime()
            end
            
            -- Remove RemoveBuffDataComponent if it was set (buff came back)
            entityManager:removeComponent(entityId, "RemoveBuffDataComponent")
        else
            -- Buff is not active, mark BuffData for removal
            if buffData then
                entityManager:addComponent(entityId, "RemoveBuffDataComponent", RemoveBuffDataComponent:new())
            end
        end
    end
end

ZA.Services.AuraEngine.Systems.AuraMatchSystem = AuraMatchSystem
return AuraMatchSystem
