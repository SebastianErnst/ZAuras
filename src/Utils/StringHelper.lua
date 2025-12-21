local ZA = ZAuras
local StringHelper = {}
ZA.Utils.StringHelper = StringHelper

function StringHelper:new()
    local public = {}

    function public:split(str, sep)
        local parts = {}
        local start = 1

        while true do
            local pos = string.find(str, sep, start, true)
            if not pos then
                table.insert(parts, string.sub(str, start))
                break
            end
            table.insert(parts, string.sub(str, start, pos - 1))
            start = pos + 1
        end

        return parts
    end

    return public
end

return StringUtils
