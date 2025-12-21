local ZA = ZAuras

-- System for positioning icons in a grid layout
local IconPositionSystem = {
    priority = 5,
    config = {
        iconsPerRow = 10,
        spacing = 5,
        startX = -300,
        startY = 200
    }
}

function IconPositionSystem:update(entityManager)
    local PositionComponent = ZA.Services.AuraEngine.Components.PositionComponent
    local AuraEngine = ZA.Container:resolve("AuraEngine")
    local inMoveMode = AuraEngine.moveMode and AuraEngine.moveMode.enabled or false
    
    -- Get all visible entities
    local entities = entityManager:newQuery()
        :include({ "AuraConfigComponent", "BuffTypeComponent", "BuffDataComponent", "ConditionComponent", "IconComponent" })
        :exclude({ "RemoveBuffDataComponent" })
        :execute()
    
    local visibleEntities = {}
    for _, entityId in ipairs(entities) do
        local icon = entityManager:getComponent(entityId, "IconComponent")
        local condition = entityManager:getComponent(entityId, "ConditionComponent")
        
        -- In move mode, include all icons. Otherwise only visible ones
        if inMoveMode or (condition.shouldShow and icon.isVisible) then
            table.insert(visibleEntities, entityId)
        end
    end
    
    -- Position visible icons in a grid
    for index, entityId in ipairs(visibleEntities) do
        local icon = entityManager:getComponent(entityId, "IconComponent")
        local position = entityManager:getComponent(entityId, "PositionComponent")
        local auraConfig = entityManager:getComponent(entityId, "AuraConfigComponent")
        
        -- Create or update position component
        if not position then
            position = PositionComponent:new({
                x = auraConfig.positionX,
                y = auraConfig.positionY,
                anchorPoint = auraConfig.anchorPoint,
                relativePoint = "CENTER"
            })
            entityManager:addComponent(entityId, "PositionComponent", position)
        else
            position.x = auraConfig.positionX
            position.y = auraConfig.positionY
            position.anchorPoint = auraConfig.anchorPoint
            position.relativePoint = "CENTER"
        end
        
        -- Apply position to frame
        if icon.frame then
            icon.frame:ClearAllPoints()
            icon.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", position.x, position.y)
        end
    end
end

function IconPositionSystem:setMovable(icon, enabled, auraId)
    local frame = icon.frame
    
    if enabled then
        -- Enable dragging
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:Show()
        
        -- Green background with inset to indicate move mode
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = -2, right = -2, top = -2, bottom = -2 }
        })
        frame:SetBackdropColor(0, 1, 0, 0.3)
        frame:SetBackdropBorderColor(0, 1, 0, 1)
        
        
        frame:SetScript("OnDragStart", function()
            this:StartMoving()
        end)
        
        frame:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
            -- Save position to database
            local point, relativeTo, relativePoint, xOfs, yOfs = this:GetPoint()
            local AuraEngine = ZA.Container:resolve("AuraEngine")
            local ZAuraModel = AuraEngine.zauraModel
            local auraData = ZAuraModel:getById(auraId)
            if auraData then
                auraData.positionX = xOfs
                auraData.positionY = yOfs
                auraData.anchorPoint = point
                ZAuraModel:update(auraId, auraData)
                AuraEngine.log:info("Saved position for aura " .. auraId .. ": " .. point .. " (" .. xOfs .. ", " .. yOfs .. ")")
                
                -- Update AuraConfigComponent in the entity
                local entities = AuraEngine.entityManager:query({"AuraConfigComponent"})
                for _, entityId in ipairs(entities) do
                    local config = AuraEngine.entityManager:getComponent(entityId, "AuraConfigComponent")
                    if config.auraId == auraId then
                        config.positionX = xOfs
                        config.positionY = yOfs
                        config.anchorPoint = point
                        break
                    end
                end
            end
        end)
    else
        -- Disable dragging
        frame:SetMovable(false)
        frame:EnableMouse(false)
        frame:RegisterForDrag()
        frame:SetScript("OnDragStart", nil)
        frame:SetScript("OnDragStop", nil)
        
        -- Reset backdrop to original
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16
        })
        frame:SetBackdropColor(0, 0, 0, 1)
        frame:SetBackdropBorderColor(0, 0, 0, 1)
    end
end

ZA.Services.AuraEngine.Systems.IconPositionSystem = IconPositionSystem