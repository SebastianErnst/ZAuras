local ZA = ZAuras
local Form = {}
ZA.Components.Form = Form

function Form:new()
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
            if field.getValue then
                data[name] = field.getValue()
            elseif field.widget.GetValue then
                data[name] = field.widget:GetValue()
            elseif field.widget.GetText then
                data[name] = field.widget:GetText()
            elseif field.widget.GetNumber then
                data[name] = field.widget:GetNumber()
            end
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
        
        if widget.isDropdown then
            UIDropDownMenu_SetSelectedValue(widget, value)
            UIDropDownMenu_SetText(value, widget)
            -- Update the stored selectedValue in the getValue closure
            if field.getValue then
                -- The getValue function is a closure that returns selectedValue
                -- We need to trigger the dropdown's func to update it
                local button = UIDropDownMenu_CreateInfo()
                button.value = value
                button.func = function()
                    UIDropDownMenu_SetSelectedValue(widget, value)
                    UIDropDownMenu_SetText(value, widget)
                end
                if button.func then
                    button.func()
                end
            end
        elseif widget.SetValue then
            widget:SetValue(tonumber(value) or value)
        elseif widget.SetText then
            widget:SetText(tostring(value))
        end
    end

    function public:CreateDropdown(parent, options)
        local dropdown = CreateFrame("Frame", "ZAurasDropdown" .. math.random(1, 999999), parent,
            "UIDropDownMenuTemplate")
        local selectedValue = options and options[1] or nil

        UIDropDownMenu_Initialize(dropdown, function()
            for i = 1, table.getn(options or {}) do
                local info = {}
                local value = options[i]

                info.text = value
                info.value = value
                info.func = function()
                    selectedValue = value
                    UIDropDownMenu_SetSelectedValue(dropdown, value)
                    UIDropDownMenu_SetText(value, dropdown)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)

        if selectedValue then
            UIDropDownMenu_SetSelectedValue(dropdown, selectedValue)
            UIDropDownMenu_SetText(selectedValue, dropdown)
        end

        dropdown.isDropdown = true

        return dropdown, function() return selectedValue end
    end

    function public:CreateTextInput(parent, labelText)
        local input = CreateFrame("EditBox", "ZAuras" .. labelText, parent, "InputBoxTemplate")
        input:SetHeight(30)
        input:SetAutoFocus(false)
        input:SetMaxLetters(64)
        input:Show()

        return input
    end

    function public:CreateNumberInput(parent, labelText, minValue, maxValue)
        local input = CreateFrame("EditBox", "ZAurasNumber" .. labelText, parent, "InputBoxTemplate")
        input:SetHeight(30)
        input:SetAutoFocus(false)
        input:SetMaxLetters(10)
        input:SetNumeric(true)
        input:Show()

        input:SetScript("OnEditFocusLost", function()
            local val = tonumber(input:GetText())
            if val then
                if minValue and val < minValue then
                    input:SetText(tostring(minValue))
                elseif maxValue and val > maxValue then
                    input:SetText(tostring(maxValue))
                end
            end
        end)

        return input
    end

    function public:CreateLabel(parent, labelText)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetJustifyH("LEFT")
        label:SetText(labelText)
        return label
    end

    function public:CreateSlider(parent, labelText, minValue, maxValue, step)
        local slider = CreateFrame("Slider", "ZAurasSlider" .. labelText, parent, "OptionsSliderTemplate")
        slider:SetOrientation("HORIZONTAL")
        slider:SetWidth(200)
        slider:SetHeight(15)
        slider:SetMinMaxValues(minValue or 0, maxValue or 100)
        slider:SetValueStep(step or 1)
        slider:SetValue((minValue or 0) + (maxValue or 100) / 2)
        
        -- Set text labels
        getglobal(slider:GetName() .. "Low"):SetText(minValue or 0)
        getglobal(slider:GetName() .. "High"):SetText(maxValue or 100)
        -- getglobal(slider:GetName() .. "Text"):SetText(labelText .. ": " .. slider:GetValue())
        
        -- Update text on value change
        slider:SetScript("OnValueChanged", function()
            getglobal(this:GetName() .. "Text"):SetText(labelText .. ": " .. this:GetValue())
        end)
        
        return slider
    end

    return public
end
