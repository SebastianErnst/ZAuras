local ZA = ZAuras
local Button = {}
ZA.Components.Button = Button

function Button:new()
    local public = {}

    -- Create a close button (X)
    function public:CreateClose(parent)
        local btn = CreateFrame("Button", nil, parent, "UIPanelCloseButton")

        local clickCallback = nil

        btn:SetScript("OnClick", function()
            parent:Hide()
            if clickCallback then
                clickCallback()
            end
        end)

        function btn:onClick(func)
            clickCallback = func
            return self
        end

        return btn
    end

    function public:CreateBack(parent, text)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        btn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        btn:SetWidth(25)
        btn:SetHeight(25)

        -- Add onClick method for JS-like usage
        function btn:onClick(func)
            self:SetScript("OnClick", func)
            return self
        end

        return btn
    end

    -- Create a standard red Blizzard button
    function public:Create(parent, text, width, height)
        local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        btn:SetText(text or "Button")
        btn:SetWidth(width or ZA.UI.BUTTON_WIDTH)
        btn:SetHeight(height or ZA.UI.BUTTON_HEIGHT)

        -- Add onClick method for JS-like usage
        function btn:onClick(func)
            self:SetScript("OnClick", func)
            return self
        end

        function btn:onDoubleClick(func)
            self:SetScript("OnDoubleClick", func)
            return self
        end

        return btn
    end

    -- Create an icon button
    function public:CreateIcon(parent, icon)
        local buttonName = "ZAurasIconButton" .. math.random(1, 999999)
        local btn = CreateFrame("Button", buttonName, parent, "ActionButtonTemplate")
        btn:SetWidth(ZA.UI.ICON_SIZE)
        btn:SetHeight(ZA.UI.ICON_SIZE)

        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Icon texture
        local texture = btn:CreateTexture(nil, "ARTWORK")
        local icon = "Interface\\Icons\\" .. (icon or "INV_Misc_QuestionMark")
        texture:SetTexture(icon)
        texture:SetAllPoints(btn)

        -- Highlight overlay
        local highlight = btn:CreateTexture(nil, "OVERLAY")
        highlight:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
        highlight:SetAllPoints(btn)
        highlight:Hide()

        function btn:onClick(func)
            self:SetScript("OnClick", func)
            return self
        end

        function btn:onDoubleClick(func)
            self:SetScript("OnDoubleClick", func)
            return self
        end

        function btn:highlight()
            highlight:Show()
            return self
        end

        function btn:unhighlight()
            highlight:Hide()
            return self
        end

        return btn
    end

    -- Create a button group container
    function public:CreateGroup(parent, buttons)
        local group = CreateFrame("Frame", nil, parent)
        
        local totalWidth = 0
        local maxHeight = ZA.UI.BUTTON_HEIGHT
        
        for i = 1, table.getn(buttons) do
            local btn = buttons[i]
            btn:SetParent(group)
            
            if i == 1 then
                btn:SetPoint("LEFT", group, "LEFT", 0, 0)
            else
                btn:SetPoint("LEFT", buttons[i-1], "RIGHT", ZA.UI.BUTTON_SPACING, 0)
            end
            
            totalWidth = totalWidth + btn:GetWidth()
            if i > 1 then
                totalWidth = totalWidth + ZA.UI.BUTTON_SPACING
            end
        end
        
        group:SetWidth(totalWidth)
        group:SetHeight(maxHeight)
        
        return group
    end

    return public
end
