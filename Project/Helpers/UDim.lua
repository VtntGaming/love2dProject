---@class UDim
---@field Scale number
---@field Offset number
local UDim = {}

---@param scale number?
---@param offset number?
---@return UDim
function UDim.new(scale, offset)    
    ---@class UDim
    local init = {
        __type = "UDim",
        Scale = tonumber(scale) or 0,
        Offset = tonumber(offset) or 0
    }

    local metatableSetup = {
        __index = UDim,
        __add = function(u2)
            assert(u2.__type == "UDim", "Must be a UDim")
            return UDim.new(init.Scale + u2.Scale, init.Offset + u2.Offset)
        end,
        __sub = function(u2)
            assert(u2.__type == "UDim", "Must be a UDim")
            return UDim.new(init.Scale - u2.Scale, init.Offset - u2.Offset)
        end,
        __tostring = function()
            return string.format("UDim: {%f, %f}", init.Scale, init.Offset)
        end
    }

    return setmetatable(init, metatableSetup)
end

getfenv()["UDim"] = UDim

return UDim