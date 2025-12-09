local Instance = require "Core.Instance.Instance"
local UDim2    = require "Helpers.UDim2"
local UIComponent = {}

function UIComponent.new()
    local prototype = Instance.new()

    local init = {
        Position = UDim2.new(),
        Size = UDim2.fromScale(0, 0)
    }
    
    
    return setmetatable(init, {_index = prototype})
end

return UIComponent