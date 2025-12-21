local ZA = ZAuras
local NewZAuraView = {}
ZA.Views.ZAura.NewZAuraView = NewZAuraView

function NewZAuraView:new()
    local BaseView = ZA.Views.BaseView
    local public = BaseView:new()

    local FrameComponent = ZA.Container:resolve("FrameComponent")
    local FormComponent = ZA.Container:resolve("FormComponent")
    local ButtonComponent = ZA.Container:resolve("ButtonComponent")
    local Log = ZA.Container:resolve("Log")
    local GridComponent = ZA.Container:resolve("GridComponent")
    local ViewController = ZA.Container:resolve("ViewController")

    local ApplicationFrame = ZA.Container:resolve("ApplicationView"):getFrame()
    local FrameContent = FrameComponent:CreateApplicationFrameContent(ApplicationFrame)
    public:setFrame(FrameContent)

    local formGrid = GridComponent:Create(FrameContent, 2, 10, 20)
    formGrid:SetColumnWidths({
        [1] = 100
    })

    local nameLabel = FormComponent:CreateLabel(formGrid.parent, "Name:")
    local nameInput = FormComponent:CreateTextInput(formGrid.parent, "Name")
    FormComponent:registerField("name", nameInput)
    formGrid:AddRow(nameLabel, nameInput)

    local auraNameLabel = FormComponent:CreateLabel(formGrid.parent, "Aura Name:")
    local auraNameInput = FormComponent:CreateTextInput(formGrid.parent, "AuraName")
    FormComponent:registerField("auraName", auraNameInput)
    formGrid:AddRow(auraNameLabel, auraNameInput)

    local displayTypeLabel = FormComponent:CreateLabel(formGrid.parent, "Display Type:")
    local displayTypeDropdown, displayTypeGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Icon" })
    FormComponent:registerField("displayType", displayTypeDropdown, displayTypeGetValue)
    formGrid:AddRow(displayTypeLabel, displayTypeDropdown)

    local auraTypeLabel = FormComponent:CreateLabel(formGrid.parent, "Aura Type:")
    local auraTypeDropdown, auraTypeGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Buff" })
    FormComponent:registerField("auraType", auraTypeDropdown, auraTypeGetValue)
    formGrid:AddRow(auraTypeLabel, auraTypeDropdown)

    local conditionLabel = FormComponent:CreateLabel(formGrid.parent, "Condition:")
    local conditionDropdown, conditionGetValue = FormComponent:CreateDropdown(formGrid.parent, { "Active", "Not Active" })
    FormComponent:registerField("condition", conditionDropdown, conditionGetValue)
    formGrid:AddRow(conditionLabel, conditionDropdown)

    local iconSizeLabel = FormComponent:CreateLabel(formGrid.parent, "Icon Size:")
    local iconHeightInput = FormComponent:CreateNumberInput(formGrid.parent, "IconHeight")
    FormComponent:registerField("iconHeight", iconHeightInput)
    local iconWidthInput = FormComponent:CreateNumberInput(formGrid.parent, "IconWidth")
    FormComponent:registerField("iconWidth", iconWidthInput)
    formGrid:AddRow(iconSizeLabel, iconWidthInput, iconHeightInput)

    local positionLabel = FormComponent:CreateLabel(formGrid.parent, "Position:")
    local positionXInput = FormComponent:CreateNumberInput(formGrid.parent, "PositionX")
    FormComponent:registerField("positionX", positionXInput)
    local positionYInput = FormComponent:CreateNumberInput(formGrid.parent, "PositionY")
    FormComponent:registerField("positionY", positionYInput)
    formGrid:AddRow(positionLabel, positionXInput, positionYInput)

    local anchorPointLabel = FormComponent:CreateLabel(formGrid.parent, "Anchor Point:")
    local anchorPointDropdown, anchorPointGetValue = FormComponent:CreateDropdown(formGrid.parent, {
        "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
        "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER"
    })
    FormComponent:registerField("anchorPoint", anchorPointDropdown, anchorPointGetValue)
    formGrid:AddRow(anchorPointLabel, anchorPointDropdown)

    local alphaLabel = FormComponent:CreateLabel(formGrid.parent, "Alpha:")
    local alphaSlider = FormComponent:CreateSlider(formGrid.parent, "Alpha", 1, 100, 1)
    FormComponent:registerField("alpha", alphaSlider)
    formGrid:AddRow(alphaLabel, alphaSlider)

    local saveBtn = ButtonComponent:Create(formGrid.parent, "Save")
    saveBtn:onClick(function()
        Log:info("Save button clicked!")
        ViewController:saveZAura(FormComponent:getAllData())
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

    FrameContent:SetHeight(formGrid:GetTotalHeight())

    public:setFrame(FrameContent)

    -- Set dummy data
    FormComponent:setFieldValue("name", "Test Aura")
    FormComponent:setFieldValue("auraName", "Devotion Aura")
    FormComponent:setFieldValue("displayType", "Icon")
    FormComponent:setFieldValue("auraType", "Buff")
    FormComponent:setFieldValue("condition", "Active")
    FormComponent:setFieldValue("iconWidth", "64")
    FormComponent:setFieldValue("iconHeight", "64")
    FormComponent:setFieldValue("positionX", "0")
    FormComponent:setFieldValue("positionY", "0")
    FormComponent:setFieldValue("anchorPoint", "CENTER")
    FormComponent:setFieldValue("alpha", "100")

    return public
end
