local ZA = ZAuras
local SpellCache = {}
ZA.Services.SpellCache = SpellCache

function SpellCache:new()
    local public = {}
    local StringHelper = ZA.Container:resolve("StringHelper")

    -- Cache tables for O(1) lookups
    local bySpellId = {}
    local byIcon = {}

    -- Normalize icon path: extract filename after last '/' and convert to lowercase
    local function normalizeIconPath(iconPath)
        if not iconPath then return nil end

        -- Split by '/' and take last part
        local parts = StringHelper:split(iconPath, "\\")
        local filename = parts[3]

        -- Convert to lowercase
        return string.lower(filename)
    end

    -- Build cache from AbilitiesByNameMapping on initialization
    function public:buildCache()
        for spellName, spellData in pairs(ZA.AbilitiesByNameMapping) do
            local icon = spellData.icon

            -- Build byIcon cache
            if icon and not byIcon[icon] then
                byIcon[icon] = {
                    name = spellName,
                    ranks = spellData.ranks
                }
            end

            -- Build bySpellId cache (one entry per rank)
            if spellData.ranks then
                for rankNum = 1, spellData.ranks.maxRank do
                    local rankData = spellData.ranks[rankNum]
                    if rankData and rankData.id then
                        bySpellId[rankData.id] = {
                            name = spellName,
                            icon = icon,
                            rank = rankNum,
                            castTime = rankData.castTime,
                            duration = rankData.duration,
                            cost = rankData.cost,
                            resource = rankData.resource,
                            minRange = rankData.minRange,
                            maxRange = rankData.maxRange,
                            cooldown = rankData.cooldown,
                            school = rankData.school,
                            dispelType = rankData.dispelType
                        }
                    end
                end
            end
        end
    end

    function public:getByIcon(iconPath, rank)
        local normalizedIcon = normalizeIconPath(iconPath)
        local spellData = byIcon[normalizedIcon]
        
        if not spellData then
            return nil
        end
        
        -- If no rank specified, use maxRank
        if not rank then
            rank = spellData.ranks.maxRank
        end
        
        local rankData = spellData.ranks[rank]
        if not rankData then
            return nil
        end
        
        -- Return complete spell info with specific rank data
        return {
            name = spellData.name,
            icon = normalizedIcon,
            rank = rank,
            castTime = rankData.castTime,
            duration = rankData.duration,
            cost = rankData.cost,
            resource = rankData.resource,
            minRange = rankData.minRange,
            maxRange = rankData.maxRange,
            cooldown = rankData.cooldown,
            school = rankData.school,
            dispelType = rankData.dispelType
        }
    end

    function public:getBySpellId(spellId)
        return bySpellId[spellId]
    end

    function public:getAllMappedByName()
        return ZA.AbilitiesByNameMapping
    end

    return public
end

return SpellCache
