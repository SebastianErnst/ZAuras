local ZA = ZAuras
local EditZAuraState = {}
ZA.States.ZAura.EditZAuraState = EditZAuraState

function EditZAuraState:new()
    local public = {}
    public.name = "EditZAuraState"
    local EditZAuraView = ZA.Container:resolve("EditZAuraView")
    local ZAuraModel = ZA.Container:resolve("ZAuraModel")
    local selectedAuraId = nil

    function public:setAuraId(auraId)
        selectedAuraId = auraId
    end

    function public:onEnter()
        if selectedAuraId then
            local auraData = ZAuraModel:getById(selectedAuraId)
            if auraData then
                EditZAuraView:setAuraData(auraData, selectedAuraId)
            end
        end
        EditZAuraView:show()
    end

    function public:onExit()
        EditZAuraView:hide()
    end

    function public:onUpdate()

    end

    return public
end
