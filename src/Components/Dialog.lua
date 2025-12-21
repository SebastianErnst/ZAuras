local ZA = ZAuras
local Dialog = {}
ZA.Components.Dialog = Dialog

function Dialog:new()
    local public = {}

    function public:CreateConfirmDialog(title, message)
        local ApplicationView = ZA.Container:resolve("ApplicationView")
        local ButtonComponent = ZA.Container:resolve("ButtonComponent")
        local parentFrame = ApplicationView:getFrame()

        -- Create backdrop frame
        local backdrop = CreateFrame("Frame", "ZAurasDialogBackdrop", parentFrame)
        backdrop:SetFrameStrata("DIALOG")
        backdrop:SetAllPoints(parentFrame)
        backdrop:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            tile = true,
            tileSize = 32
        })
        backdrop:SetBackdropColor(0, 0, 0, 0.8)
        backdrop:EnableMouse(true)

        -- Create dialog frame
        local dialog = CreateFrame("Frame", "ZAurasDialog", backdrop)
        dialog:SetFrameStrata("DIALOG")
        dialog:SetWidth(300)
        dialog:SetHeight(150)
        dialog:SetPoint("CENTER", parentFrame, "CENTER", 0, 0)
        dialog:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })

        -- Title
        local titleText = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        titleText:SetPoint("TOP", dialog, "TOP", 0, -15)
        titleText:SetText(title)

        -- Message
        local messageText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        messageText:SetPoint("TOP", dialog, "TOP", 0, -50)
        messageText:SetWidth(360)
        messageText:SetText(message)

        -- Confirm button
        local confirmBtn = ButtonComponent:Create(dialog, "Confirm")
        confirmBtn:SetPoint("BOTTOM", dialog, "BOTTOM", -55, 20)

        function dialog:onConfirm(func)
            confirmBtn:SetScript("OnClick", function()
                backdrop:Hide()
                if func then
                    func()
                end
            end)
            return self
        end

        -- Dismiss button
        local dismissBtn = ButtonComponent:Create(dialog, "Cancel")
        dismissBtn:SetPoint("BOTTOM", dialog, "BOTTOM", 55, 20)

        function dialog:onDismiss(func)            
            dismissBtn:SetScript("OnClick", function()
                backdrop:Hide()
                if func then
                    func()
                end
            end)
            return self
        end

        backdrop:Show()
        
        return dialog
    end

    return public
end
