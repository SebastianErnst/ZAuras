local ZA = ZAuras
local Form = {}
ZA.Components.Form = Form

function Form:new()
    local public = {}
    local UUID = ZA.Container:resolve("UUID")
    local allFlyOuts = {}

    

    function public:CreateTextInput(parent)
        local input = CreateFrame("EditBox", "ZAuras" .. UUID:generate(), parent, "InputBoxTemplate")
        input:SetHeight(20)
        input:SetAutoFocus(false)
        input:SetNumeric(false)
        input:SetMaxLetters(64)
        input:Show()
        input:SetScript("OnEnter", function()
            input:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                insets = { left = -3, right = 2, top = 2, bottom = 1 }
            })
            input:SetBackdropColor(1, 1, 1, 0.15)
        end)

        input:SetScript("OnLeave", function()
            input:SetBackdrop(nil)
        end)

        return input
    end

    function public:CreateNumberInput(parent, labelText, minValue, maxValue)
        local input = public:CreateTextInput(parent)
        input:SetMaxLetters(10)
        input:SetNumeric(false)

        input:SetScript("OnChar", function()
            local text = input:GetText()
            -- Allow only numbers and minus sign at the start
            local cleaned = string.gsub(text, "[^%d%-]", "")
            -- Allow only one minus and only at the start
            if string.find(cleaned, "%-") then
                cleaned = string.gsub(cleaned, "%-", "", 1)
                cleaned = "-" .. string.gsub(cleaned, "%-", "")
            end
            if text ~= cleaned then
                input:SetText(cleaned)
            end
        end)

        input:SetScript("OnEditFocusLost", function()
            local val = tonumber(input:GetText())
            if minValue or maxValue then
                if val then
                    if minValue and val < minValue then
                        input:SetText(tostring(minValue))
                    elseif maxValue and val > maxValue then
                        input:SetText(tostring(maxValue))
                    end
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
        local slider = CreateFrame("Slider", "ZAurasSlider" .. UUID:generate(), parent, "OptionsSliderTemplate")
        slider:SetOrientation("HORIZONTAL")
        slider:SetWidth(200)
        slider:SetHeight(15)
        slider:SetMinMaxValues(minValue or 0, maxValue or 100)
        slider:SetValueStep(step or 1)
        slider:SetValue((maxValue or 100))

        -- Set text labels
        getglobal(slider:GetName() .. "Low"):SetText(minValue or 0)
        getglobal(slider:GetName() .. "High"):SetText(maxValue or 100)

        -- Update text on value change
        slider:SetScript("OnValueChanged", function()
            getglobal(this:GetName() .. "Text"):SetText(labelText .. ": " .. this:GetValue())
        end)

        return slider
    end

    function public:CreateSpellSearchDropdown(parent)
        local spellsMappedByName = ZA.Container:resolve("SpellCache"):getAllMappedByName()
        return public:CreateTextInputWithSearchDropdown(parent, spellsMappedByName)
    end

    return public
end
