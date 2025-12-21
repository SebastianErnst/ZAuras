local ZA = ZAuras
local BuffWatcher = {}
ZA.Services.BuffWatcher = BuffWatcher

function BuffWatcher:new()
    local public = {}
    local Log = ZA.Container:resolve("Log")
    local SpellInfo = ZA.Container:resolve("SpellInfo")
    local ZAuraModel = ZA.Container:resolve("ZAuraModel")

    local watcherFrame = CreateFrame("Frame", "ZAurasBuffWatcher", UIParent)
    local activeIcons = {}
    local updateInterval = 0.1
    local timeSinceLastUpdate = 0
    
    local function scanPlayerBuffs()
        local buffs = {}
        
        for i = 0, 32 do
            local buffIndex, untilCancelled = GetPlayerBuff(i, "HELPFUL")

            if buffIndex < 0 then
                break
            end

            local texture = GetPlayerBuffTexture(buffIndex)

            if texture then
                local applications = GetPlayerBuffApplications(buffIndex)
                local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
                local dispelType = GetPlayerBuffDispelType(buffIndex)
                local spellData = SpellInfo:getByIconPath(texture)
                
                if spellData then
                    local name = spellData.name
                    print(name)
                    buffs[name] = {
                        index = buffIndex,
                        name = name,
                        icon = texture,
                        applications = applications,
                        timeLeft = timeLeft,
                        dispelType = dispelType,
                        untilCancelled = untilCancelled
                    }
                end
            end
        end
        return buffs
    end

    local function createIconFrame(aura, buffInfo)
        local icon = CreateFrame("Button", "ZAurasIcon_" .. aura.id, UIParent)
        icon:SetWidth(aura.iconWidth or 36)
        icon:SetHeight(aura.iconHeight or 36)
        icon:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        icon:SetFrameStrata("HIGH")

        -- Icon texture
        local texture = icon:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(buffInfo.icon)
        texture:SetAllPoints(icon)
        icon.texture = texture

        -- Stacks text
        local stackText = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        stackText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
        icon.stackText = stackText

        -- Time left text
        local timeText = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timeText:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        icon.timeText = timeText

        -- Alpha
        icon:SetAlpha((aura.alpha or 100) / 100)
        
        icon:Show()
        return icon
    end
    
    local function updateIconFrame(icon, buffInfo)
        -- Update texture
        if buffInfo.icon then
            icon.texture:SetTexture(buffInfo.icon)
        end
        
        -- Update stacks
        if buffInfo.applications and buffInfo.applications > 1 then
            icon.stackText:SetText(tostring(buffInfo.applications))
            icon.stackText:Show()
        else
            icon.stackText:Hide()
        end
        
        -- Update time left
        if buffInfo.timeLeft and buffInfo.timeLeft > 0 then
            icon.timeText:SetText(string.format("%d s", math.floor(buffInfo.timeLeft)))
            icon.timeText:Show()
        else
            icon.timeText:Hide()
        end
    end

    local function updateAuras()
        local elapsed = arg1
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed

        if timeSinceLastUpdate < updateInterval then
            return
        end
        timeSinceLastUpdate = 0

        -- Get all auras from model
        local allAuras = ZAuraModel:getAll()
        local activeBuffs = scanPlayerBuffs()
        
        local shouldBeVisible = {}

        -- Check each aura and determine which should be visible
        for id, aura in pairs(allAuras) do
            if aura.auraType == "Buff" then
                local buffExists = activeBuffs[aura.auraName] ~= nil
                local shouldShow = false

                if aura.condition == "Active" and buffExists then
                    shouldShow = true
                elseif aura.condition == "Not Active" and not buffExists then
                    shouldShow = true
                end

                if shouldShow then
                    local buffInfo = activeBuffs[aura.auraName]
                    if not buffInfo then
                        local spellInfo = SpellInfo:byName(aura.auraName)
                        buffInfo = spellInfo and { icon = spellInfo.icon }
                    end

                    if buffInfo then
                        shouldBeVisible[id] = { aura = aura, buffInfo = buffInfo }
                    end
                end
            end
        end
        
        -- Remove icons that should no longer be visible
        for id, icon in pairs(activeIcons) do
            if not shouldBeVisible[id] then
                icon:Hide()
                icon:SetParent(nil)
                activeIcons[id] = nil
            end
        end
        
        -- Create or update icons
        for id, data in pairs(shouldBeVisible) do
            if activeIcons[id] then
                -- Update existing icon
                updateIconFrame(activeIcons[id], data.buffInfo)
            else
                -- Create new icon
                activeIcons[id] = createIconFrame(data.aura, data.buffInfo)
            end
        end
    end

    function public:start()
        Log:info("BuffWatcher started")
        watcherFrame:SetScript("OnUpdate", updateAuras)
    end

    function public:stop()
        Log:info("BuffWatcher stopped")
        watcherFrame:SetScript("OnUpdate", nil)

        -- Clear all icons
        for id, icon in pairs(activeIcons) do
            icon:Hide()
            icon:SetParent(nil)
        end
        activeIcons = {}
    end

    return public
end
