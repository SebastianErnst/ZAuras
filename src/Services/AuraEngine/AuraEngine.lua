local ZA = ZAuras

-- Main AuraEngine service
local AuraEngine = {
    world = nil,
    entityManager = nil,
    updateFrame = nil,
    isRunning = false,
    updateInterval = 1,
    timeSinceUpdate = 0,
    container = nil,
    log = nil,
    zauraModel = nil,
    spellInfo = nil,
    moveMode = {
        enabled = false,
        auraIds = {}
    }
}

function AuraEngine:init()
    local container = ZA.Container
    -- Store container reference
    self.container = container
    self.log = container:resolve("Log")
    self.zauraModel = container:resolve("ZAuraModel")
    self.spellInfo = container:resolve("SpellInfo")
    
    -- Initialize core components
    self.entityManager = ZA.Services.AuraEngine.Core.EntityManager
    self.world = ZA.Services.AuraEngine.Core.World
    self.world:init(self.entityManager)
    
    -- Register systems in priority order
    local BuffScanSystem = ZA.Services.AuraEngine.Systems.BuffScanSystem
    local AuraMatchSystem = ZA.Services.AuraEngine.Systems.AuraMatchSystem
    local ConditionEvaluationSystem = ZA.Services.AuraEngine.Systems.ConditionEvaluationSystem
    local IconRenderSystem = ZA.Services.AuraEngine.Systems.IconRenderSystem
    local IconPositionSystem = ZA.Services.AuraEngine.Systems.IconPositionSystem
    local CleanupSystem = ZA.Services.AuraEngine.Systems.CleanupSystem
    local FlagCleanupSystem = ZA.Services.AuraEngine.Systems.FlagCleanupSystem
    local DebugPrintSystem = ZA.Services.AuraEngine.Systems.DebugPrintSystem
    
    -- Initialize systems with required services
    BuffScanSystem.spellInfo = self.spellInfo
    
    self.world:addSystem(BuffScanSystem, 1) -- Scans active buffs from WoW API
    self.world:addSystem(AuraMatchSystem, 2) -- Matches buffs with configured auras
    self.world:addSystem(ConditionEvaluationSystem, 3) -- Evaluates display conditions
    self.world:addSystem(IconRenderSystem, 4) -- Creates/updates icon frames
    self.world:addSystem(IconPositionSystem, 5) -- Positions icons
    self.world:addSystem(CleanupSystem, 6) -- Removes BuffData marked with RemoveBuffDataComponent
    self.world:addSystem(FlagCleanupSystem, 7) -- Removes RemoveBuffDataComponent markers
    self.world:addSystem(DebugPrintSystem, 100) -- Prints all entities and components (debugging)

    return self
end

function AuraEngine:start()
    if self.isRunning then
        self.log:info("AuraEngine already running")
        return
    end
    
    self.log:info("Starting AuraEngine...")
    -- Load configured auras from DB
    self:loadAuras()
    
    -- Create update frame
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
    end
    
    self.updateFrame:SetScript("OnUpdate", function()
        local elapsed = arg1
        self:onUpdate(elapsed)
    end)
    
    self.isRunning = true
    self.log:info("AuraEngine started")
end

function AuraEngine:stop()
    if not self.isRunning then
        return
    end
    
    self.log:info("Stopping AuraEngine...")
    
    -- Stop update loop
    if self.updateFrame then
        self.updateFrame:SetScript("OnUpdate", nil)
    end
    
    -- Clear all entities and cleanup frames
    self:clearAllAuras()
    
    self.isRunning = false
    self.log:info("AuraEngine stopped")
end

function AuraEngine:onUpdate(elapsed)
    -- Don't update systems when in move mode
    if self.moveMode.enabled then
        return
    end
    
    self.timeSinceUpdate = self.timeSinceUpdate + elapsed
    
    if self.timeSinceUpdate >= self.updateInterval then
        self.world:update()
        self.timeSinceUpdate = 0
    end
end

function AuraEngine:setMoveMode(enabled, auraIds)
    self.moveMode.enabled = enabled
    self.moveMode.auraIds = auraIds or {}
    self.log:info("Move mode " .. (enabled and "enabled" or "disabled") .. " for " .. table.getn(self.moveMode.auraIds) .. " auras")
    
    -- Immediately update all icon frames to be movable/non-movable
    local IconPositionSystem = ZA.Services.AuraEngine.Systems.IconPositionSystem
    local entities = self.entityManager:query({"AuraConfigComponent"})
    
    for _, entityId in ipairs(entities) do
        local icon = self.entityManager:getComponent(entityId, "IconComponent")
        local auraConfig = self.entityManager:getComponent(entityId, "AuraConfigComponent")
        
        if icon and icon.frame and auraConfig then
            local iconInMoveMode = enabled and self:isInMoveMode(auraConfig.auraId)
            IconPositionSystem:setMovable(icon, iconInMoveMode, auraConfig.auraId)
            
            -- Show all icons in move mode
            if enabled then
                icon.frame:Show()
                icon.isVisible = true
            end
        end
    end
end

function AuraEngine:isInMoveMode(auraId)
    if not self.moveMode.enabled then
        return false
    end
    
    -- If auraIds is empty, all auras are in move mode
    if table.getn(self.moveMode.auraIds) == 0 then
        return true
    end
    
    -- Check if specific aura is in move mode
    for i = 1, table.getn(self.moveMode.auraIds) do
        if self.moveMode.auraIds[i] == auraId then
            return true
        end
    end
    
    return false
end

function AuraEngine:loadAuras()
    local auras = self.zauraModel:getAll()
    local AuraConfigComponent = ZA.Services.AuraEngine.Components.AuraConfigComponent
    local IconRenderSystem = ZA.Services.AuraEngine.Systems.IconRenderSystem
    
    -- Clear existing entities
    self.entityManager:clear()
    
    -- Create entities for each configured aura
    for auraId, auraData in pairs(auras) do
        local entityId = self.entityManager:createEntity()
        
        local configComponent = AuraConfigComponent:new({
            auraId = auraId,
            auraName = auraData.auraName,
            auraType = auraData.auraType,
            condition = auraData.condition,
            iconWidth = auraData.iconWidth,
            iconHeight = auraData.iconHeight,
            positionX = auraData.positionX,
            positionY = auraData.positionY,
            anchorPoint = auraData.anchorPoint,
            alpha = auraData.alpha / 100
        })
        
        self.entityManager:addComponent(entityId, "AuraConfigComponent", configComponent)

        -- Add type marker component
        if auraData.auraType == "Buff" then
            local BuffTypeComponent = ZA.Services.AuraEngine.Components.BuffTypeComponent
            self.entityManager:addComponent(entityId, "BuffTypeComponent", BuffTypeComponent:new())
        else
            local DebuffTypeComponent = ZA.Services.AuraEngine.Components.DebuffTypeComponent
            self.entityManager:addComponent(entityId, "DebuffTypeComponent", DebuffTypeComponent:new())
        end
    end
    
    self.log:info("Loaded " .. self.entityManager:getEntityCount() .. " auras")
end

function AuraEngine:reloadAuras()
    if not self.isRunning then
        return
    end
    
    self.log:info("Reloading auras...")
    
    -- First hide all existing icon frames
    self:clearAllAuras()
    
    -- Then load auras from DB (creates new entities and frames)
    self:loadAuras()
end

function AuraEngine:clearAllAuras()
    -- Get all entities with IconComponent
    local entities = self.entityManager:query({"IconComponent"})
    
    for _, entityId in ipairs(entities) do
        local icon = self.entityManager:getComponent(entityId, "IconComponent")
        if icon and icon.frame then
            icon.frame:Hide()
            icon.frame = nil
        end
    end
    
    -- Clear all entities
    self.entityManager:clear()
end

function AuraEngine:getEntityManager()
    return self.entityManager
end

function AuraEngine:getWorld()
    return self.world
end

ZA.Services.AuraEngine.Engine = AuraEngine