local ZA = ZAuras
local EditZAuraView = {}
ZA.Views.ZAura.EditZAuraView = EditZAuraView

function EditZAuraView:new()
    local BaseView = ZA.Views.BaseView
    local public = BaseView:new()

    local FrameComponent = ZA.Container:resolve("FrameComponent")
    local ZAuraFormComponent = ZA.Container:resolve("ZAuraFormComponent")
    local ViewController = ZA.Container:resolve("ViewController")

    local ApplicationFrame = ZA.Container:resolve("ApplicationView"):getFrame()
    local FrameContent = FrameComponent:CreateApplicationFrameContent(ApplicationFrame)
    public:setFrame(FrameContent)

    local currentAuraId = nil

    local form = ZAuraFormComponent:CreateForm(FrameContent, {
        onSave = function(data)
            ViewController:updateZAura(currentAuraId, data)
        end
    })

    FrameContent:SetHeight(form.grid:GetTotalHeight())

    function public:setAuraData(auraData, auraId)
        currentAuraId = auraId

        for fieldName, value in pairs(auraData) do
            form.formBuilder:setFieldValue(fieldName, value)
        end
    end

    return public
end
