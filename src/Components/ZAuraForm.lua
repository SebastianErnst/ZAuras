local ZA = ZAuras
local ZAuraForm = {}
ZA.Components.ZAuraForm = ZAuraForm

function ZAuraForm:new()
    local public = {}
    
    function public:CreateForm(parent, options)
        options = options or {}
        local onSave = options.onSave
        
        local FormBuilder = ZA.Container:resolve("FormBuilder")
        local FormComponent = ZA.Container:resolve("FormComponent")
        local ButtonComponent = ZA.Container:resolve("ButtonComponent")
        local GridComponent = ZA.Container:resolve("GridComponent")
        local Log = ZA.Container:resolve("Log")
        
        local formGrid = GridComponent:Create(parent, 2, 10, 20)
        formGrid:SetColumnWidths({
            [1] = 100
        })
        
        -- Name field
        local nameLabel = FormComponent:CreateLabel(formGrid.parent, "Name:")
        local nameInput = FormComponent:CreateTextInput(formGrid.parent, "Name")
        FormBuilder:registerField("name", nameInput)
        formGrid:AddRow(nameLabel, nameInput)
        
        -- ZAura Type field
        local auraTypeLabel = FormComponent:CreateLabel(formGrid.parent, "ZAura Type:")
        local auraTypeDropdown, auraTypeGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Buff" })
        FormBuilder:registerField("auraType", auraTypeDropdown, auraTypeGetValue)
        formGrid:AddRow(auraTypeLabel, auraTypeDropdown)
        
        -- Buff Name field
        -- local auraNameLabel = FormComponent:CreateLabel(formGrid.parent, "Buff Name:")
        -- local auraNameSearchDropdown, auraNameGetValue = FormComponent:CreateSpellSearchDropdown(formGrid.parent)
        -- FormBuilder:registerField("auraName", auraNameSearchDropdown, auraNameGetValue)
        -- formGrid:AddRow(auraNameLabel, auraNameSearchDropdown)
        
        -- Display Type field
        local displayTypeLabel = FormComponent:CreateLabel(formGrid.parent, "Display Type:")
        local displayTypeDropdown, displayTypeGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Icon" })
        FormBuilder:registerField("displayType", displayTypeDropdown, displayTypeGetValue)
        formGrid:AddRow(displayTypeLabel, displayTypeDropdown)
        
        -- Condition field
        local conditionLabel = FormComponent:CreateLabel(formGrid.parent, "Condition:")
        local conditionDropdown, conditionGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Active", "Not Active" })
        FormBuilder:registerField("condition", conditionDropdown, conditionGetValue)
        formGrid:AddRow(conditionLabel, conditionDropdown)
        
        -- Icon Size fields
        local iconSizeLabel = FormComponent:CreateLabel(formGrid.parent, "Icon Size:")
        local iconHeightInput = FormComponent:CreateNumberInput(formGrid.parent, "IconHeight")
        FormBuilder:registerField("iconHeight", iconHeightInput)
        local iconWidthInput = FormComponent:CreateNumberInput(formGrid.parent, "IconWidth")
        FormBuilder:registerField("iconWidth", iconWidthInput)
        formGrid:AddRow(iconSizeLabel, iconWidthInput, iconHeightInput)
        
        -- Position fields
        local positionLabel = FormComponent:CreateLabel(formGrid.parent, "Position:")
        local positionXInput = FormComponent:CreateNumberInput(formGrid.parent, "PositionX")
        FormBuilder:registerField("positionX", positionXInput)
        local positionYInput = FormComponent:CreateNumberInput(formGrid.parent, "PositionY")
        FormBuilder:registerField("positionY", positionYInput)
        formGrid:AddRow(positionLabel, positionXInput, positionYInput)
        
        -- Alpha slider
        local alphaLabel = FormComponent:CreateLabel(formGrid.parent, "Alpha:")
        local alphaSlider = FormComponent:CreateSlider(formGrid.parent, "Alpha", 1, 100, 1)
        FormBuilder:registerField("alpha", alphaSlider)
        formGrid:AddRow(alphaLabel, alphaSlider)
        
        -- Buttons
        local saveBtn = ButtonComponent:Create(formGrid.parent, "Save")
        saveBtn:onClick(function()
            if onSave then
                onSave(FormComponent:getAllData())
            end
        end)
        
        local testBtn = ButtonComponent:Create(formGrid.parent, "Test")
        testBtn:onClick(function()
            Log:info("Test button clicked!")
        end)
        
        local moveBtn = ButtonComponent:Create(formGrid.parent, "Move")
        moveBtn:onClick(function()
            Log:info("Move button clicked - implement move logic here")
        end)
        
        local buttonGroup = ButtonComponent:CreateGroup(formGrid.parent, {saveBtn, testBtn, moveBtn})
        buttonGroup:SetPoint("BOTTOMLEFT", formGrid.parent, "BOTTOMLEFT", 0, 0)
        
        return {
            grid = formGrid,
            formBuilder = FormBuilder,
            formComponent = FormComponent,
            saveButton = saveBtn,
            testButton = testBtn,
            moveButton = moveBtn
        }
    end
    
    return public
end
