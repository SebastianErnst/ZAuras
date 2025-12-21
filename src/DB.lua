local ZA = ZAuras
local DB = {}
ZA.DB = DB

function DB:init(callback)
    local initFrame = CreateFrame("Frame")
    local elapsed = 0
    local maxWaitTime = 5
    local checkInterval = 0.1
    local timeSinceLastCheck = 0
    local initialized = false
    
    local function completeInitialization()
        if initialized then return end
        initialized = true
        
        -- Initialize database if still not available
        if not ZAurasDB or not ZAurasDB.ZAuras then
            ZAurasDB = {
                version = ZA.VERSION,
                ZAuras = {}
            }
        end
        
        -- Stop checking
        initFrame:SetScript("OnUpdate", nil)
        
        -- Execute callback
        if callback then
            callback()
        end
    end
    
    initFrame:SetScript("OnUpdate", function()
        local deltaTime = arg1
        elapsed = elapsed + deltaTime
        timeSinceLastCheck = timeSinceLastCheck + deltaTime
        
        -- Check every 0.1 seconds
        if timeSinceLastCheck >= checkInterval then
            timeSinceLastCheck = 0
            
            -- Check if database is available
            if ZAurasDB and ZAurasDB.ZAuras then
                completeInitialization()
                return
            end
        end
        
        -- Timeout after 5 seconds
        if elapsed >= maxWaitTime then
            completeInitialization()
        end
    end)
end