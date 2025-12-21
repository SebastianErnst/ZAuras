local ZA = ZAuras
local SlashCommands = {}
ZA.SlashCommands = SlashCommands

function SlashCommands:new()
    SLASH_ZAURAS1 = "/zauras"
    SLASH_ZAURAS2 = "/za"
    local ViewController = ZA.Container:resolve("ViewController")
    local public = {}

    function public:init()
        SlashCmdList["ZAURAS"] = function(msg)
            if msg == "help" then
                print("ZAuras commands:")
                print("/za - Open main window")
            else 
                ViewController:goToMainZAuraState()
            end
        end
    end

    return public
end
