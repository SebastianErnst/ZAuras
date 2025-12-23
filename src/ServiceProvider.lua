local ZA = ZAuras
local ServiceProvider = {}
ZA.ServiceProvider = ServiceProvider

function ServiceProvider:registerAll(container)
    -- Register Utils
    container:register("Log", function()
        return ZA.Utils.Log:new()
    end, "util")
    
    container:register("SpellInfo", function()
        return ZA.Utils.SpellInfo:new()
    end, "util")
    
    container:register("StringHelper", function()
        return ZA.Utils.StringHelper:new()
    end, "util")
    
    container:register("UUID", function()
        return ZA.Utils.UUID:new()
    end, "util")
    
    -- Register Services
    container:register("SpellCache", function()
        return ZA.Services.SpellCache:new()
    end, "service")
    
    container:register("BuffWatcher", function()
        return ZA.Services.BuffWatcher:new()
    end, "service")
    
    container:register("AuraEngine", function()
        return ZA.Services.AuraEngine.Engine
    end, "service")

    container:register("FormBuilder", function()
        return ZA.Services.FormBuilder:new()
    end, "service")
    
    -- Register Components
    container:register("FrameComponent", function()
        return ZA.Components.Frame:new()
    end, "component")
    
    container:register("ButtonComponent", function()
        return ZA.Components.Button:new()
    end, "component")
    
    container:register("FormComponent", function()
        return ZA.Components.Form:new()
    end, "component")
    
    container:register("GridComponent", function()
        return ZA.Components.Grid:new()
    end, "component")

    container:register("DialogComponent", function()
        return ZA.Components.Dialog:new()
    end, "component")

    container:register("ZAuraFormComponent", function()
        return ZA.Components.ZAuraForm:new()
    end, "component")
    
    
    -- Register Models
    container:register("ZAuraModel", function()
        return ZA.Models.ZAuraModel:new()
    end, "model")
    
    -- Register Views
    container:register("MainZAuraView", function()
        return ZA.Views.ZAura.MainZAuraView:new()
    end, "view")
    
    container:register("NewZAuraView", function()
        return ZA.Views.ZAura.NewZAuraView:new()
    end, "view")
    
    container:register("EditZAuraView", function()
        return ZA.Views.ZAura.EditZAuraView:new()
    end, "view")
    
    -- Register States
    container:register("MainZAuraState", function()
        local state = ZA.States.ZAura.MainZAuraState:new()
        state.view = container:resolve("MainZAuraView")
        return state
    end, "state")
    
    container:register("NewZAuraState", function()
        local state = ZA.States.ZAura.NewZAuraState:new()
        state.view = container:resolve("NewZAuraView")
        return state
    end, "state")
    
    container:register("EditZAuraState", function()
        local state = ZA.States.ZAura.EditZAuraState:new()
        state.view = container:resolve("EditZAuraView")
        return state
    end, "state")
    
    container:register("CloseAddonState", function()
        return ZA.States.CloseAddonState:new()
    end, "state")
    
    -- Register Controllers
    container:register("ViewController", function()
        return ZA.Controller.ViewController:new()
    end, "controller")
    
    -- Register Commands
    container:register("ZAuraCommands", function()
        return ZA.Commands.ZAuraCommands
    end)

    --Register Frames
    container:register("ApplicationView", function()        
        return ZA.Views.ApplicationView:new()
    end)

    --Register Slash Commands
    container:register("SlashCommands", function()
        return ZA.SlashCommands:new()
    end)    
end