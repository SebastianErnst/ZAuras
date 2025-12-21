local ZA = ZAuras

-- System for creating and updating icon frames
local IconRenderSystem = {
    priority = 4,
    framePool = {} -- Reuse frames instead of destroying
}

function IconRenderSystem:update(entityManager)    
    local AuraEngine = ZA.Container:resolve("AuraEngine")
    local inMoveMode = AuraEngine.moveMode and AuraEngine.moveMode.enabled or false
    
    -- Get all entities that should be shown
    local entities = entityManager:newQuery()
        :include({ "AuraConfigComponent", "BuffTypeComponent", "BuffDataComponent", "ConditionComponent" })
        :exclude({ "RemoveBuffDataComponent" })
        :execute()
    
    for _, entityId in ipairs(entities) do
        local auraConfig = entityManager:getComponent(entityId, "AuraConfigComponent")
        local condition = entityManager:getComponent(entityId, "ConditionComponent")
        local buffData = entityManager:getComponent(entityId, "BuffDataComponent")
        local icon = entityManager:getComponent(entityId, "IconComponent")
        
        -- In move mode, show all icons. Otherwise only show if condition is met
        local shouldShowIcon = inMoveMode or (condition.shouldShow and buffData)
        
        if shouldShowIcon then
            -- Get or create icon frame
            if not icon or not icon.frame then
                icon = self:createIconFrame(auraConfig)
                entityManager:addComponent(entityId, "IconComponent", icon)
            end
            
            -- Update icon frame
            local frame = icon.frame            
            local texture = icon.texture
            local stackText = icon.stackText
            local timeText = icon.timeText
            
            -- Set size
            frame:SetWidth(auraConfig.iconWidth)
            frame:SetHeight(auraConfig.iconHeight)
            frame:SetAlpha(auraConfig.alpha)
            
            -- Update texture
            if buffData and buffData.icon then
                texture:SetTexture(buffData.icon)
            else
                -- Show placeholder for NotActive condition
                texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            
            -- Update stack count
            if buffData and buffData.applications and buffData.applications > 1 then
                stackText:SetText(buffData.applications)
                stackText:Show()
            else
                stackText:Hide()
            end
            
            -- Update time remaining
            if buffData and buffData.timeLeft and buffData.timeLeft > 0 then
                local timeStr = self:formatTime(buffData.timeLeft)
                timeText:SetText(timeStr)
                timeText:Show()
            else
                timeText:Hide()
            end
            
            icon.isVisible = true
            frame:Show()
        else
            -- Hide icon if condition is not met
            if icon and icon.frame  and icon.isVisible then
                icon.frame:Hide()
                icon.isVisible = false
            end
        end
    end
end

function IconRenderSystem:createIconFrame(auraConfig)
    local IconComponent = ZA.Services.AuraEngine.Components.IconComponent
    local frameName = "ZAuras_Icon_" .. auraConfig.auraId
    local frame = CreateFrame("Frame", frameName, UIParent)
    
    frame:SetWidth(auraConfig.iconWidth)
    frame:SetHeight(auraConfig.iconHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Create texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    
    -- Create stack text
    local stackText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    stackText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    stackText:SetTextColor(1, 1, 1)
    stackText:Hide()
    
    -- Create time text
    local timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeText:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    timeText:SetTextColor(1, 1, 1)
    timeText:Hide()

    return IconComponent:new({
        frame = frame,
        texture = texture,
        stackText = stackText,
        timeText = timeText,
        isVisible = false
    })
end

function IconRenderSystem:formatTime(seconds)
    if seconds >= 3600 then
        return string.format("%dh", math.floor(seconds / 3600))
    elseif seconds >= 60 then
        return string.format("%dm", math.floor(seconds / 60))
    else
        return string.format("%ds", math.floor(seconds))
    end
end

ZA.Services.AuraEngine.Systems.IconRenderSystem = IconRenderSystem