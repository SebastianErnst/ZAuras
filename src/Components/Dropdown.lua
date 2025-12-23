local ZA = ZAuras
local Dropdown = {}
ZA.Components.Dropdown = Dropdown       

function Dropdown:new()
    local public = {}
    local UUID = ZA.Container:resolve("UUID")
    local allFlyOuts = {}

    function public:CreateTextInputWithSearchDropdown(parent, data)
        local suppressNextFilter = false
        local selectedValue = nil
        local allOptions = data
        local filteredOptions = allOptions

        local searchBox = public:CreateTextInput(parent)
        searchBox:SetHeight(20)

        local flyout = public:CreateDropdownFlyout(searchBox, data)
        -- scrollChild:SetWidth(scrollFrame:GetWidth())

        local itemButtons = {}
        -- local function updateList()
        --     local yOffset = 0
        --     local previousButton = nil
        --     local optionHeight = 20
        --     local optionSpacing = optionHeight
        --     local count = 0

        --     for k, btn in pairs(itemButtons) do btn:Hide() end


        --     for spellName, spellInfo in pairs(filteredOptions) do
        --         count = count + 1
        --         local btn = itemButtons[spellName]
        --         if not btn then
        --             btn = CreateFrame("Button", nil, scrollChild)
        --             if previousButton then
        --                 btn:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, 0)
        --                 btn:SetPoint("TOPRIGHT", previousButton, "BOTTOMRIGHT", 0, 0)
        --             else
        --                 btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        --                 btn:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
        --             end
        --             btn:SetHeight(optionHeight)
        --             itemButtons[spellName] = btn
        --             local btnTexture = btn:CreateTexture(nil, "ARTWORK")
        --             btnTexture:SetWidth(optionHeight)
        --             btnTexture:SetHeight(optionHeight)
        --             btnTexture:SetPoint("LEFT", btn, "LEFT", 4, 0)
        --             btnTexture:SetTexture("Interface\\Icons\\" .. spellInfo.icon)
        --             local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        --             btnText:SetPoint("LEFT", btnTexture, "RIGHT", 4, 0)
        --             btnText:SetJustifyH("LEFT")
        --             btn.text = btnText
        --             btn:SetScript("OnEnter",
        --                 function() btn:SetBackdrop({ bgFile = "Interface\\QuestFrame\\UI-QuestTitleHighlight" }) end)
        --             btn:SetScript("OnLeave", function() btn:SetBackdrop(nil) end)
        --         end
        --         previousButton = btn
        --         btn.text:SetText(spellName)
        --         btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
        --         local currentSpellName = spellName
        --         btn:SetScript("OnClick", function()
        --             selectedValue = currentSpellName
        --             suppressNextFilter = true
        --             searchBox:SetText(selectedValue)
        --             searchBox:ClearFocus()
        --             listFrame:Hide()
        --         end)
        --         btn:Show()
        --         yOffset = yOffset + optionSpacing
        --     end
        --     local maxHeight = optionSpacing * 5 + 20
        --     local contentHeight = count * (optionSpacing)
        --     scrollChild:SetHeight(contentHeight)
        --     listFrame:SetHeight(math.min(contentHeight + 20, maxHeight))
        -- end

        -- searchBox:SetScript("OnTextChanged", function()
        --     if suppressNextFilter then
        --         suppressNextFilter = false
        --         return
        --     end
        --     local searchText = searchBox:GetText()
        --     if string.len(searchText) >= 3 then
        --         filteredOptions = {}
        --         local lowerSearch = string.lower(searchText)
        --         for spellName, spellInfo in pairs(allOptions) do
        --             local spellNammeLower = string.lower(spellName)
        --             local searchTextMatchspellNammeLower = string.find(spellNammeLower, lowerSearch, 1, true)
        --             if searchTextMatchspellNammeLower then
        --                 filteredOptions[spellName] = spellInfo
        --             end
        --         end
        --         updateList()
        --         listFrame:Show()
        --     else
        --         listFrame:Hide()
        --     end
        -- end)



        -- container.SetText = function(_, text)
        --     searchBox:SetText(text)
        --     suppressNextFilter = true
        -- end

        return searchBox, function() return selectedValue end
    end

    function public:CreateDropdown(parent, data, searchable)
        local selectedValue = nil

        local dropdownInput = public:CreateTextInput(parent)
        dropdownInput:SetText("Select...")
        dropdownInput:SetHeight(20)

        local dropdownInputArrow = CreateFrame("Button", nil, dropdownInput)
        dropdownInputArrow:SetPoint("RIGHT", dropdownInput, "RIGHT", 2, 0)
        dropdownInputArrow:SetWidth(25)
        dropdownInputArrow:SetHeight(25)
        dropdownInputArrow:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        dropdownInputArrow:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-ScrollDown-Down")

        local flyout = public:CreateDropdownFlyout(dropdownInput)
        flyout:updateList(data)

        dropdownInputArrow:SetScript("OnClick", function()
            dropdownInput:ClearFocus()
            flyout:toggle()
        end)

        dropdownInput:SetScript("OnEditFocusGained", function()
            dropdownInput:ClearFocus()
            flyout:toggle()
        end)

        return dropdownInput, function() return selectedValue end
    end

    function public:CreateDropdownFlyout(parent)
        local listFrame = CreateFrame("Frame", nil, parent)
        local public = {}
        local isOpen = false
        local onClickCallback = nil

        listFrame:SetWidth(200)
        listFrame:SetHeight(150)
        listFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", -3, 3)
        listFrame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", -2, 25)
        listFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        listFrame:SetFrameStrata("DIALOG")
        listFrame:Hide()

        local FrameComponent = ZA.Container:resolve("FrameComponent")
        local scrollFrame, scrollChild = FrameComponent:CreateScrollFrame(listFrame, 180, 130)
        scrollFrame:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 10, -10)
        scrollFrame:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", -32, 8)
        scrollChild:SetAllPoints(scrollFrame)

        -- Helps with setting focus on this hidden element to enable OnEscape flyout closing
        local flyoutFocusHandler = public:CreateTextInput(parent)
        flyoutFocusHandler:SetBackdrop(nil)
        flyoutFocusHandler:SetBackdropColor(0, 0, 0, 0)

        function public:updateList(data)
            local itemButtons = itemButtons or {}
            local yOffset = 0
            local previousButton = nil
            local optionHeight = 20
            local optionSpacing = optionHeight
            local count = 0

            for k, btn in pairs(itemButtons) do
                btn:Hide()
            end

            for key, value in pairs(data) do
                count = count + 1
                local btn = itemButtons[key] or nil
                local currentValue = nil

                if not btn then
                    btn = CreateFrame("Button", nil, scrollChild)
                    if previousButton then
                        btn:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, 0)
                        btn:SetPoint("TOPRIGHT", previousButton, "BOTTOMRIGHT", 0, 0)
                    else
                        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
                        btn:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
                    end

                    btn:SetHeight(optionHeight)
                    itemButtons[key] = btn

                    local btnTexture = nil

                    if type(value) == "table" and value.icon then
                        btnTexture = btn:CreateTexture(nil, "ARTWORK")
                        btnTexture:SetWidth(optionHeight)
                        btnTexture:SetHeight(optionHeight)
                        btnTexture:SetPoint("LEFT", btn, "LEFT", 4, 0)
                        btnTexture:SetTexture("Interface\\Icons\\" .. value.icon)
                    end

                    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    btnText:SetAllPoints(btn)
                    btnText:SetJustifyH("LEFT")
                    btn.text = btnText

                    btn:SetScript("OnEnter", function()
                        btn:SetBackdrop({
                            bgFile = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
                        })
                    end)
                    btn:SetScript("OnLeave", function()
                        btn:SetBackdrop(nil)
                    end)
                end

                previousButton = btn

                btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)

                if type(value) == "table" and value.name then
                    currentValue = value.name
                else
                    currentValue = value
                end

                btn.text:SetText(currentValue)

                btn:SetScript("OnClick", function()
                    parent:SetText(currentValue)
                    if onClickCallback then
                        onClickCallback(currentValue)
                    end
                end)

                btn:Show()
                yOffset = yOffset + optionSpacing
            end

            local maxHeight = optionSpacing * 5 + 20
            local contentHeight = count * (optionSpacing)
            scrollChild:SetHeight(contentHeight)
            listFrame:SetHeight(math.min(contentHeight + 20, maxHeight))
        end

        scrollFrame:SetScript("OnVerticalScroll", function()
            scrollChild:SetWidth(parent:GetWidth() - 45)
        end)
        scrollChild:SetWidth(scrollFrame:GetWidth())

        flyoutFocusHandler:SetScript("OnEscapePressed", function()
            parent:ClearFocus()
            listFrame:Hide()
        end)

        function public:onClick(cb)
            onClickCallback = cb
        end

        function public:toggle()
            for _, flyout in pairs(allFlyOuts) do
                if flyout ~= public and flyout:isOpen() then
                    flyout:toggle()
                end
            end
            if isOpen then
                listFrame:Hide()
                isOpen = false
            else
                listFrame:Show()
                isOpen = true
            end
        end

        function public:isOpen()
            return isOpen
        end

        allFlyOuts[UUID:generate()] = public

        return public
    end
end