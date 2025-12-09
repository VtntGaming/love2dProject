local UDim = require "Helpers.UDim"
---@class UDim2
local UDim2 = {}

---@param u1 UDim
---@param u2 UDim
---@return UDim2
function UDim2.fromUDim(u1, u2)
    assert(u1.__type == "UDim" and u2.__type == "UDim", "Both u1 and u2 must be UDim")

    ---@class UDim2
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
        end,
        __tostring = function()
            return string.format("UDim2: {{%f, %f}, {%f, %f}}", init.X.Scale, init.X.Offset, init.Y.Scale, init.Y.Offset)
        end
    }

    return setmetatable(init, metatableSetup)
end

---@param sx number?
---@param ox number?
---@param sy number?
---@param oy number?
---@return UDim2
function UDim2.new(sx, ox, sy, oy)
    return UDim2.fromUDim(UDim.new(sx, ox), UDim.new(sy, oy))
end

---@param x number
---@param y number
---@return UDim2
function UDim2.fromScale(x, y)
    return UDim2.new(x, 0, y, 0)
end

---@param x number
---@param y number
---@return UDim2
function UDim2.fromOffset(x, y)
    return UDim2.new(0, x, 0, y)    
end

---@param a number
---@param b number
---@param t number
local function lerp(a, b, t)
    return a + (b - a) * t
end

---@param self UDim2
---@param u2 UDim2
---@param t number
---@return UDim2
function UDim2:Lerp(u2, t)
    local newSX = lerp(self.X.Scale, u2.X.Offset, t)
    local newSY = lerp(self.Y.Scale, u2.Y.Scale, t)
    local newOX = lerp(self.X.Offset, u2.X.Offset, t)
    local newOY =lerp( self.Y.Offset, u2.Y.Offset, t)

    return UDim2.new(newSX, newOX, newSY, newOY)
end

getfenv()["UDim2"] = UDim2

return UDim2