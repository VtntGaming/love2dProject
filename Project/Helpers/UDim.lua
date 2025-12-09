local UDim = {}

function UDim.new(scale, offset)
    local init = {
        __type = "UDim",
        Scale = tonumber(scale) or 0,
        Offset = tonumber(scale) or 0
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
        end
    }

    return setmetatable(init, metatableSetup)
end

return UDim