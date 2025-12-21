local ZA = ZAuras
local EditZAuraView = {}
ZA.Views.ZAura.EditZAuraView = EditZAuraView

function EditZAuraView:new()
    local BaseView = ZA.Views.BaseView
    local public = BaseView:new()
    local ViewController = ZA.Container:resolve("ViewController")
    local FrameComponent = ZA.Container:resolve("FrameComponent")

    local ApplicationFrame = ZA.Container:resolve("ApplicationView"):getFrame()
    local FrameContent = FrameComponent:CreateApplicationFrameContent(ApplicationFrame)
    public:setFrame(FrameContent)

    return public
end