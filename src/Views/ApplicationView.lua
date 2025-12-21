local ZA = ZAuras
local ApplicationView = {}
ZA.Views.ApplicationView = ApplicationView

function ApplicationView:new()
    local public = ZA.Views.BaseView:new()
    local ViewController = ZA.Container:resolve("ViewController")
    local FrameComponent = ZA.Container:resolve("FrameComponent")

    local Frame = FrameComponent:CreateApplicationFrame(
        ZA.ADDON_NAME .. " v" .. ZA.VERSION,
        ZA.UI.MAINFRAME_WIDTH,
        ZA.UI.MAINFRAME_HEIGHT)

    public:setFrame(Frame)

    Frame:onClose(function()
        ViewController:goToCloseAddonState()
    end)

    Frame:onBack(function()
        ViewController:goBack()
    end)

    function public:updateBackButtonVisibility()
        if ViewController:getHistorySize() > 1 then
            Frame.backBtn:Show()
        else
            Frame.backBtn:Hide()
        end
    end

    function public:getFrame()
        return Frame
    end

    return public
end
