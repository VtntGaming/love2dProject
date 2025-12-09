---@class Instance
local Instance = {}

function Instance.new()
    local class = {
        __type = "Instance",
        __class = "Instance",
        Name = "Instance",
        Parent = nil
    }

    return class
end

return Instance