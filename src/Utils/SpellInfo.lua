local ZA = ZAuras
local SpellInfo = {}
ZA.Utils.SpellInfo = SpellInfo

function SpellInfo:new()
    local public = {}
    local Log = ZA.Container:resolve("Log")
    local SpellCache = ZA.Container:resolve("SpellCache")

    function public:getByName(name, rank, class)
        if not rank then
            rank = "max"
        end

        if not class then
            local playerClass, _ = UnitClass("player")
            class = playerClass
        end

        local spellInfo = nil

        if not ZA.AbilitiesByNameMapping[name] then
            -- Log:warn("Spell info not found for spell: " .. name .. " for class: " .. class)
            return nil
        end

        local multipleClassesHaveSpell = ZA.AbilitiesByNameMapping[name].multiClass

        if multipleClassesHaveSpell then
            spellInfo = ZA.AbilitiesByNameMapping[name][class]
        else
            spellInfo = ZA.AbilitiesByNameMapping[name]
        end

        local icon = spellInfo.icon

        if rank == "max" then
            rank = spellInfo.ranks.maxRank
        end

        local currentRank = spellInfo.ranks[rank]

        local id = currentRank.id
        local castTime = currentRank.castTime
        local duration = currentRank.duration
        local minRange = currentRank.minRange
        local maxRange = currentRank.maxRange
        local cost = currentRank.cost
        local resource = currentRank.resource
        local cooldown = currentRank.cooldown
        local school = currentRank.school
        local dispelType = currentRank.dispelType

        return {
            id = id,
            icon = icon,
            castTime = castTime,
            duration = duration,
            minRange = minRange,
            maxRange = maxRange,
            cost = cost,
            resource = resource,
            cooldown = cooldown,
            school = school,
            dispelType = dispelType,
            rank = rank
        }
    end

    function public:getByIcon(iconPath)
        return SpellCache:getByIcon(iconPath)
    end

    function public:getBySpellId(spellId)
        return SpellCache:getBySpellId(spellId)
    end

    return public
end
