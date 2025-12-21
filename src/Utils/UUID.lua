local ZA = ZAuras
local UUID = {}
ZA.Utils.UUID = UUID

function UUID:new()
    local public = {}

    function public:generate()
        local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
        return string.gsub(template, "[xy]", function(c)
            local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
            return string.format("%x", v)
        end)
    end

    return public
end
