local ZA = ZAuras
local Frame = {}
ZA.Components.Frame = Frame

function Frame:new()
    local public = {}

    function public:CreateApplicationFrame(title, width, height)
        local ButtonComponent = ZA.Container:resolve("ButtonComponent")
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetWidth(width)
        frame:SetHeight(height)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("LOW")
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        frame:Hide()

        -- Backdrop
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            -- tileSize = 12,
            edgeSize = 18,
            insets = { left = 6, right = 6, top = 6, bottom = 6 }
        })
        frame:SetBackdropColor(0, 0, 0, 1)

        -- Dragging
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", function() frame:StartMoving() end)
        frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

        -- Title
        if title then
            frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.titleText:SetPoint("TOP", frame, "TOP", 0, -15)
            frame.titleText:SetText(title)
        end

        -- Close button
        frame.closeBtn = ButtonComponent:CreateClose(frame)
        frame.closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

        local closeCallback = nil
        frame.closeBtn:SetScript("OnClick", function()
            if closeCallback then
                closeCallback()
            end
        end)

        function frame:onClose(func)
            closeCallback = func
            return self
        end

        frame.backBtn = ButtonComponent:CreateBack(frame)
        frame.backBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
        frame.backBtn:Hide()

        local backCallback = nil
        frame.backBtn:SetScript("OnClick", function()
            if backCallback then
                backCallback()
            end
        end)

        function frame:onBack(func)
            backCallback = func
            return self
        end

        return frame
    end

    function public:CreateApplicationFrameContent(parent)
        local content = CreateFrame("Frame", nil, parent)
        content:SetPoint("TOPLEFT", parent, "TOPLEFT", ZA.UI.FRAME_PADDING_LEFT, -ZA.UI.FRAME_PADDING_TOP)
        content:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -ZA.UI.FRAME_PADDING_RIGHT, ZA.UI.FRAME_PADDING_BOTTOM)
        content:SetFrameLevel(parent:GetFrameLevel() + 1)

        -- content:SetBackdrop({
        --     bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        -- })
        -- content:SetBackdropColor(1, 1, 1, 1)

        return content
    end

    -- Create a scroll frame with a child content frame
    function public:CreateScrollFrame(parent, width, height)
        local frameName = "ZAurasScrollFrame" .. math.random(1, 999999)
        local scrollFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
        local scrollFrameWidth = width

        scrollFrame:SetWidth(scrollFrameWidth)
        scrollFrame:SetHeight(height)
        scrollFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        })
        scrollFrame:SetBackdropColor(0, 0, 0, 0.8)

        -- Create content frame that holds the actual scrollable content
        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetWidth(width - 20)
        content:SetHeight(1)
        content:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)

        scrollFrame:SetScrollChild(content)

        return scrollFrame, content
    end

    -- Create a confirmation dialog with Yes/No buttons
    function public:CreateConfirmFrame(title, message)
        local ButtonComponent = ZA.Container:resolve("ButtonComponent")
        local frameWidth = 300
        local frameHeight = 150

        local frame, content = public:CreateBaseFrame(title, frameWidth, frameHeight)
        frame:hideCloseButton()
        frame:SetFrameStrata("DIALOG")

        -- Message text
        frame.messageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.messageText:SetPoint("TOP", frame, "TOP", 0, -50)
        frame.messageText:SetWidth(frameWidth - 40)
        frame.messageText:SetJustifyH("CENTER")
        frame.messageText:SetText(message or "Are you sure?")

        -- Callback storage
        local confirmCallback = nil
        local cancelCallback = nil

        -- Yes button
        local yesBtn = ButtonComponent:Create(frame, "Yes", 80, 25)
        yesBtn:SetPoint("BOTTOM", frame, "BOTTOM", -45, 15)
        yesBtn:onClick(function()
            frame:Hide()
            if confirmCallback then
                confirmCallback()
            end
        end)

        -- No button
        local noBtn = ButtonComponent:Create(frame, "No", 80, 25)
        noBtn:SetPoint("BOTTOM", frame, "BOTTOM", 45, 15)
        noBtn:onClick(function()
            frame:Hide()
            if cancelCallback then
                cancelCallback()
            end
        end)

        -- API methods
        function frame:onConfirm(func)
            confirmCallback = func
            return self
        end

        function frame:onCancel(func)
            cancelCallback = func
            return self
        end

        return frame
    end

    return public
end
