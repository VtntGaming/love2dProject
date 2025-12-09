---@class Instance
---@field Parent Instance?
local Instance = {}

function Instance.new()
    ---@class Instance
    ---@field __super Instance
    local class = {
        __type = "Instance",
        __class = "Instance",
        __subclass = {"Instance"},
        Name = "Instance",
        Parent = nil
    }

    local metatableSetup = {
        __index = function (_, key)
            return Instance[key]
        end,
        __tostring = function(self)
            return string.format("Instance: %s (%s)", self.__class, self.Name)
        end
    }

    return setmetatable(class, metatableSetup)
end

---@param self Instance
---@param className string
---@return boolean
function Instance:IsA(className)
    for _, class in ipairs(self.__subclass) do
        if class == className then
            return true
        end
    end

    return false
end

return Instance