local ZA = ZAuras
local MainZAuraView = {}
ZA.Views.ZAura.MainZAuraView = MainZAuraView

function MainZAuraView:new()
    local public = ZA.Views.BaseView:new()
    local ViewController = ZA.Container:resolve("ViewController")

    local Log = ZA.Container:resolve("Log")
    local FrameComponent = ZA.Container:resolve("FrameComponent")
    local ButtonComponent = ZA.Container:resolve("ButtonComponent")
    local SpellInfo = ZA.Container:resolve("SpellInfo")

    -- Initialize the main frame
    local ApplicationFrame = ZA.Container:resolve("ApplicationView"):getFrame()
    local FrameContent = FrameComponent:CreateApplicationFrameContent(ApplicationFrame)
    public:setFrame(FrameContent)

    -- Track selected icon
    local selectedIcon = nil
    local selectedAuraId = nil

    -- Initialize buttons
    local buttonNew = ButtonComponent:Create(FrameContent, "New")
    buttonNew:SetPoint("BOTTOMLEFT", FrameContent, "BOTTOMLEFT", 0, 0)
    buttonNew:onClick(function()
        ViewController:goToNewZAuraState()
    end)

    local buttonEdit = ButtonComponent:Create(FrameContent, "Edit")
    buttonEdit:SetPoint("BOTTOMLEFT", buttonNew, "BOTTOMRIGHT", ZA.UI.BUTTON_SPACING, 0)
    buttonEdit:onClick(function()
        if selectedAuraId then
            ViewController:goToEditZAuraState(selectedAuraId)
        end
    end)

    local buttonDelete = ButtonComponent:Create(FrameContent, "Delete")
    buttonDelete:SetPoint("BOTTOMLEFT", buttonEdit, "BOTTOMRIGHT", ZA.UI.BUTTON_SPACING, 0)
    buttonDelete:onClick(function()
        if selectedAuraId then
            ViewController:deleteAura(selectedAuraId)
        end
    end)

    local buttonMoveAll = ButtonComponent:Create(FrameContent, "Move All")
    buttonMoveAll:SetPoint("BOTTOMLEFT", buttonDelete, "BOTTOMRIGHT", ZA.UI.BUTTON_SPACING, 0)
    buttonMoveAll:onClick(function()
        ViewController:toggleMoveAllMode()
    end)

    local scrollbarHeight = ZA.UI.MAINFRAME_HEIGHT - ZA.UI.FRAME_PADDING_TOP - ZA.UI.BUTTON_HEIGHT -
        ZA.UI.FRAME_PADDING_BOTTOM - ZA.UI.BUTTON_SPACING
    local scrollFrameWidth = ZA.UI.MAINFRAME_WIDTH - ZA.UI.FRAME_PADDING_LEFT - ZA.UI.FRAME_PADDING_RIGHT
    local scrollFrame = {}
    local scrollFrameContent
    scrollFrame, scrollFrameContent = FrameComponent:CreateScrollFrame(FrameContent, scrollFrameWidth,
        scrollbarHeight)
    scrollFrame:SetPoint("TOPLEFT", FrameContent, "TOPLEFT", 0, 0)

    local function createIconList(data)
        local auras = data
        local i = 1
        for k, v in pairs(auras) do
            local id = k
            local aura = v
            local spellInfo = SpellInfo:getByName(aura.auraName)
            local iconTexture = nil

            if spellInfo then
                iconTexture = spellInfo.icon
            end

            local icon = ButtonComponent:CreateIcon(scrollFrameContent, iconTexture)

            icon:SetScript("OnEnter", function()
                GameTooltip:SetOwner(icon, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:AddLine("Name: " .. aura.name, 1, 1, 1)
                GameTooltip:AddLine("\nAura Name " .. aura.auraName, 1, 1, 0)
                GameTooltip:AddLine("\n\nDouble Click to Edit", 0.5, 0.5, 0.5)
                GameTooltip:Show()
            end)

            icon:onClick(function()
                -- Unhighlight previous selection
                if selectedIcon then
                    selectedIcon:unhighlight()
                end

                -- Highlight current icon
                icon:highlight()
                selectedIcon = icon
                selectedAuraId = id
            end)

            icon:onDoubleClick(function()
                if selectedAuraId then
                    ViewController:goToEditZAuraState(selectedAuraId)
                end
            end)

            -- -- Calculate position
            local row = math.floor((i - 1) / ZA.UI.ICONS_PER_ROW)
            local col = (i - 1) - (row * ZA.UI.ICONS_PER_ROW)
            local xOffset = col * (ZA.UI.ICON_SIZE + ZA.UI.ICON_SPACING) + 5
            local yOffset = -row * (ZA.UI.ICON_SIZE + ZA.UI.ICON_SPACING) - 5

            icon:SetPoint("TOPLEFT", scrollFrameContent, "TOPLEFT", xOffset, yOffset)
            i = i + 1
        end

        -- Update content height for scrolling
        local totalRows = math.ceil((i - 1) / ZA.UI.ICONS_PER_ROW)
        local totalHeight = totalRows * (ZA.UI.ICON_SIZE + ZA.UI.ICON_SPACING) + 10
        scrollFrameContent:SetHeight(totalHeight)
    end

    function public:refreshIconList(data)
        Log:info("Refreshing icon list in MainZAuraView...")
        -- Remove all existing icons
        local children = { scrollFrameContent:GetChildren() }
        for i = 1, table.getn(children) do
            children[i]:Hide()
            children[i]:SetParent(nil)
        end

        -- Recreate icon list
        createIconList(data)
    end

    return public
end
