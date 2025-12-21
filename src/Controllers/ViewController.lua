local ZA = ZAuras
local ViewController = {}
ZA.Controller.ViewController = ViewController

function ViewController:new()
    local public = {}
    local currentState = nil
    local stateHistory = {}
    local Log = ZA.Container:resolve("Log")

    function public:setState(state, skipHistory)        
        if currentState and currentState.onExit then
            currentState:onExit()
        end

        -- Add current state to history before switching (unless skipHistory is true)
        if currentState and not skipHistory then
            table.insert(stateHistory, currentState)
        end

        currentState = state

        if currentState and currentState.onEnter then
            currentState:onEnter()
        end
        ZA.Container:resolve("ApplicationView"):updateBackButtonVisibility()
        Log:debug("State changed to: " .. tostring(state.name or "unknown"))
    end
    
    function public:goBack()
        if table.getn(stateHistory) == 0 then
            Log:warn("No previous state to go back to")
            return
        end
        
        -- Get last state from history
        local previousState = table.remove(stateHistory)
        
        -- Set state without adding to history (skipHistory = true)
        public:setState(previousState, true)
        
        Log:debug("Went back to: " .. tostring(previousState.name or "unknown"))
    end
    
    function public:clearHistory()
        stateHistory = {}
        Log:debug("State history cleared")
    end
    
    function public:getHistorySize()
        return table.getn(stateHistory)
    end
    
    function public:update()
        if currentState and currentState.onUpdate then
            currentState:onUpdate()
        else
            Log:warn("Current state has no onUpdate method")
        end
    end
    
    function public:goToMainZAuraState()
        local MainZAuraState = ZA.Container:resolve("MainZAuraState")
        public:setState(MainZAuraState)
    end
    
    function public:goToNewZAuraState()
        local NewZAuraState = ZA.Container:resolve("NewZAuraState")
        public:setState(NewZAuraState)
    end
    
    function public:goToEditZAuraState()
        local EditZAuraState = ZA.Container:resolve("EditZAuraState")
        public:setState(EditZAuraState)
    end
    
    function public:goToCloseAddonState()
        local CloseAddonState = ZA.Container:resolve("CloseAddonState")
        public:setState(CloseAddonState)
    end

    function public:saveZAura(data)
        local ZAuraModel = ZA.Container:resolve("ZAuraModel")
        local ok, err = ZAuraModel:validate(data)
        if not ok then
            Log:error("Validation failed: " .. table.concat(err, ", "))
            return
        end
        ZAuraModel:printAll()
        ZAuraModel:save(data)
        ZAuraModel:printAll()
        
        -- Reload auras in engine to create entity
        local AuraEngine = ZA.Container:resolve("AuraEngine")
        AuraEngine:reloadAuras()
        
        public:setState( ZA.Container:resolve("MainZAuraState"), true)        
    end

    function public:deleteAura(id)
        local ZAuraModel = ZA.Container:resolve("ZAuraModel")
        local DialogComponent = ZA.Container:resolve("DialogComponent")
        local auraName = ZAuraModel:getById(id).name
        
        local dialog = DialogComponent:CreateConfirmDialog("Confirm Delete", "Are you sure you want to delete " .. auraName .. "?")
        
        dialog:onConfirm(function()
            local success = ZAuraModel:delete(id)
            if success then
                Log:info("Aura " .. auraName .. " with ID " .. id .. " deleted successfully.")
                local AuraEngine = ZA.Container:resolve("AuraEngine")
                AuraEngine:reloadAuras()
                public:setState( ZA.Container:resolve("MainZAuraState"), true)
            else
                Log:error("Failed to delete aura " .. auraName .. " with ID " .. id .. ".")
            end
        end)
        
        dialog:onDismiss(function()
            Log:info("Deletion of aura " .. auraName .. " with ID " .. id .. " cancelled by user.")
        end)
    end

    function public:toggleMoveAllMode()
        local AuraEngine = ZA.Container:resolve("AuraEngine")
        
        if AuraEngine.moveMode.enabled then
            -- Disable move mode
            AuraEngine:setMoveMode(false, {})
            Log:info("Move All mode disabled")
        else
            -- Enable move mode for all auras
            AuraEngine:setMoveMode(true, {})
            Log:info("Move All mode enabled - drag icons to reposition them")
        end
    end

    return public
end