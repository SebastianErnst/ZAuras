local ZA = ZAuras
local NewZAuraState = {}
ZA.States.ZAura.NewZAuraState = NewZAuraState

function NewZAuraState:new()
    local public = {}
    public.name = "NewZAuraState"
    local NewZAuraView = ZA.Container:resolve("NewZAuraView")
    local aurasModel = ZA.Container:resolve("ZAuraModel")

    function public:onEnter()
        NewZAuraView:show()
    end

    function public:onExit()
        NewZAuraView:hide()
    end

    function public:onUpdate()
    end

    return public
end
