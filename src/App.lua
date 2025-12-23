local ZA = ZAuras
local App = {}
ZA.App = App

function App:init()
    function onDBInitialized()
        -- Initialize global singleton container
        ZA.Container = ZA.Container:new()
        local ServiceProvider = ZA.ServiceProvider
        ServiceProvider:registerAll(ZA.Container)

        local SpellCache = ZA.Container:resolve("SpellCache")
        SpellCache:buildCache()

        local SlashCommands = ZA.Container:resolve("SlashCommands")
        SlashCommands:init()

        local Log = ZA.Container:resolve("Log")
        local ViewController = ZA.Container:resolve("ViewController")
        local AuraEngine = ZA.Container:resolve("AuraEngine")
        
        Log:SetDevMode()
        -- Log:SetProdMode()

        Log:info("Initializing ZAuras Application")
        
        -- Initialize AuraEngine with container
        AuraEngine:init()
        AuraEngine:start()

        ViewController:goToCloseAddonState()
        ViewController:goToMainZAuraState()
        -- ViewController:goToNewZAuraState()

    end 

    ZA.DB:init(onDBInitialized)
end

App:init()
