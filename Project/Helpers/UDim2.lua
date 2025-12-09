local UDim = require "Helpers.UDim"
local UDim2 = {}

function UDim2.fromUDim(u1, u2)
    assert(u1.__type == "UDim" and u2.__type == "UDim", "Both u1 and u2 must be UDim")

    local init = {
        __type = "UDim2",
        X = u1,
        Y = u2,
    }

    local metatableSetup = {
        __index = UDim2,
        __add = function(u2)
           assert(u2.__type == "UDim2", "Must be UDim2")

           local x = init.X + u2.X
           local y = init.Y + u2.Y

           return UDim2.fromUDim(x, y)
        end,
        __sub = function(u2)            
           assert(u2.__type == "UDim2", "Must be UDim2")

           local x = init.X - u2.X
           local y = init.Y - u2.Y

           return UDim2.fromUDim(x, y)
        end
    }

    return setmetatable(init, metatableSetup)
end

function UDim2.new(sx, sy, ox, oy)
    return UDim2.fromUDim(UDim.new(sx, ox), UDim.new(sy, oy))
end

function UDim2.fromScale(x, y)
    return UDim2.new(x, 0, y, 0)
end

function UDim2.fromOffset(x, y)
    return UDim2.new(0, x, 0, y)    
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function UDim2:Lerp(u2, t)
    local newSX = lerp(self.X.Scale, u2.X.Scale, t)
    local newSY = lerp(self.Y.Scale, u2.Y.Scale, t)
    local newOX = lerp(self.X.Offset, u2.X.Offset, t)
    local newOY =lerp( self.Y.Offset, u2.Y.Offset, t)

    return UDim2.new(newSX, newOX, newSY, newOY)
end

return UDim2