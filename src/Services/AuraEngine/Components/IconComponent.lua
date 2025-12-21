local ZA = ZAuras

-- Component for storing UI frame references
local IconComponent = {}
IconComponent.__index = IconComponent

function IconComponent:new(data)
    local component = {
        frame = data.frame or nil,
        texture = data.texture or nil,
        stackText = data.stackText or nil,
        timeText = data.timeText or nil,
        isVisible = data.isVisible or false
    }
    setmetatable(component, IconComponent)
    return component
end

-- Lifecycle method: called when component is removed from entity
function IconComponent:onRemove()
    print("IconComponent:onRemove called")
    if self.frame then
        self.frame:Hide()
        self.frame = nil
    end
    self.texture = nil
    self.stackText = nil
    self.timeText = nil
end

ZA.Services.AuraEngine.Components.IconComponent = IconComponent
return IconComponent
