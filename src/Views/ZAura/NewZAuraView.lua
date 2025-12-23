local ZA = ZAuras
local NewZAuraView = {}
ZA.Views.ZAura.NewZAuraView = NewZAuraView

function NewZAuraView:new()
    local BaseView = ZA.Views.BaseView
    local public = BaseView:new()

    local FrameComponent = ZA.Container:resolve("FrameComponent")
    local ZAuraFormComponent = ZA.Container:resolve("ZAuraFormComponent")
    local ViewController = ZA.Container:resolve("ViewController")

    local ApplicationFrame = ZA.Container:resolve("ApplicationView"):getFrame()
    local FrameContent = FrameComponent:CreateApplicationFrameContent(ApplicationFrame)
    public:setFrame(FrameContent)

    local form = ZAuraFormComponent:CreateForm(FrameContent, {
        onSave = function(data)
            ViewController:saveZAura(data)
        end
    })

    FrameContent:SetHeight(form.grid:GetTotalHeight())

    public:setFrame(FrameContent)

    return public
end
