local ZA = ZAuras
local FormBuilder = {}
ZA.Services.FormBuilder = FormBuilder

function FormBuilder:new()
    local public = {}
    local fields = {}

    function public:registerField(name, widget, getValue)
        fields[name] = {
            widget = widget,
            getValue = getValue
        }
    end

    function public:getAllData()
        local data = {}
        for name, field in pairs(fields) do
            local value = nil
            if field.getValue then
                value = field.getValue()
            elseif field.getText then
                value = field.getText()
            elseif field.widget.GetValue then
                value = field.widget:GetValue()
            elseif field.widget.GetText then
                value = field.widget:GetText()
            elseif field.widget.GetNumber then
                value = field.widget:GetNumber()
            end
            -- Only add to data if value is not nil or empty string
            if value ~= nil and value ~= "" then
                data[name] = value
            else
                print(name .. " is nil or empty")
            end
        end

        print("Form Data:")
        for k, v in pairs(data) do
            print(k, v)
        end

        return data
    end

    function public:reset()
        for name, field in pairs(fields) do
            if field.widget.SetText then
                field.widget:SetText("")
            end
        end
    end

    function public:setFieldValue(name, value)
        local field = fields[name]
        if not field then
            return
        end

        local widget = field.widget

        if widget.SetValue then
            widget:SetValue(tonumber(value) or value)
        elseif widget.SetText then
            widget:SetText(value)
        end
    end

    return public
end
