local ZA = ZAuras
local EditZAuraState = {}
ZA.States.ZAura.EditZAuraState = EditZAuraState

function EditZAuraState:new()
    local public = {}
    public.name = "EditZAuraState"
    local EditZAuraView = ZA.Container:resolve("EditZAuraView")

    function public:onEnter()
        EditZAuraView:show()
    end

    function public:onExit()
        EditZAuraView:hide()
    end

    function public:onUpdate()

    end

    return public
end
