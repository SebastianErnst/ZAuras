local ZA = ZAuras
local BaseView = {}
ZA.Views.BaseView = BaseView

function BaseView:new()
    local public = {}
    local Frame = nil
    local Log = ZA.Container:resolve("Log")
    
    function public:setFrame(frame)
        Frame = frame
    end
    
    function public:show()
        if Frame then
            Frame:Show()
        else 
            Log:error("Frame is not set for this view.")
        end
    end

    function public:hide()
        if Frame then
            Frame:Hide()
        else 
            Log:error("Frame is not set for this view.")
        end
    end
    
    return public
end
