local ZA = ZAuras

-- System for scanning player buffs/debuffs via WoW API
local BuffScanSystem = {
    priority = 1,
    spellInfo = nil -- Injected by AuraEngine
}

function BuffScanSystem:update(entityManager)
    local SpellInfo = self.spellInfo

    -- Build a lookup of active buffs on player
    local activeBuffs = {}
    local i = 1
    while true do
        local buffIndex, untilCancelled = GetPlayerBuff(i - 1, "HELPFUL")
        if buffIndex < 0 then
            break
        end

        -- Get buff name via tooltip
        if not ZATooltip then
            CreateFrame("GameTooltip", "ZATooltip", nil, "GameTooltipTemplate")
        end

        local tooltip = ZATooltip
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:ClearLines()
        tooltip:SetPlayerBuff(buffIndex)
        local buffName = ZATooltipTextLeft1:GetText()

        if buffName then
            local spellData = SpellInfo:getByName(buffName)
            if spellData then
                local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
                local applications = GetPlayerBuffApplications(buffIndex)
                activeBuffs[buffName] = {
                    name = buffName,
                    icon = GetPlayerBuffTexture(buffIndex),
                    applications = applications,
                    timeLeft = timeLeft,
                    dispelType = spellData.dispelType,
                    buffIndex = buffIndex
                }
            end
        end

        i = i + 1
    end

    -- Store active buffs for use by AuraMatchSystem
    self.activeBuffs = activeBuffs
end

ZA.Services.AuraEngine.Systems.BuffScanSystem = BuffScanSystem
