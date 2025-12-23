local ZA = ZAuras
local MainZAuraState = {}
ZA.States.ZAura.MainZAuraState = MainZAuraState

function MainZAuraState:new()
    local public = {}
    public.name = "MainZAuraState"
    local MainZAuraView = ZA.Container:resolve("MainZAuraView")
    local aurasModel = ZA.Container:resolve("ZAuraModel")

    function public:onEnter()
        -- Reload auras in engine to create entity
        local AuraEngine = ZA.Container:resolve("AuraEngine")
        AuraEngine:reloadAuras()

        local auras = aurasModel:getAll()
        MainZAuraView:refreshIconList(auras)
        MainZAuraView:show()
    end

    function public:onExit()
        MainZAuraView:hide()
    end

    function public:onUpdate()
        local auras = aurasModel:getAll()
        MainZAuraView:refreshIconList(auras)
    end

    return public
end
