local ZA = ZAuras
local CloseAddonState = {}
ZA.States.CloseAddonState = CloseAddonState

function CloseAddonState:new()
    local public = {}
    public.name = "CloseAddonState"    
    local ApplicationView = ZA.Container:resolve("ApplicationView")

    function public:onEnter()
         ApplicationView:hide()
    end

    function public:onExit()
        ApplicationView:show()
    end
    
    return public
end
