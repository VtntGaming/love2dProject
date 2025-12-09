local Vector2 = {}

local function v2Math(v1, v2, method)
    if type(v2) == "number" then
        if method == "add" or "sub" then
            error(string.format("Could not apply method: %s of number to vector2", method))
        end
        v2 = Vector2.new(v2, v2)
    end
    assert(v2 and v2.__type == "Vector2", "Must be a vector2")

    if method == "add" then
        return Vector2.new(v1.X + v2.X, v1.X + v2.Y)
    elseif method == "sub" then        
        return Vector2.new(v1.X - v2.X, v1.X - v2.Y)
    elseif method == "mul" then
        return Vector2.new(v1.X * v2.X, v1.X * v2.Y)
    elseif method == "div" then
        return Vector2.new(v1.X / v2.X, v1.X / v2.Y)
    else
        error("Invalid or unsupported method")
    end
end

-- Constructor

function Vector2.new(x, y)
    if not tonumber(x) then
        x = 0
    end

    if not tonumber(y) then
        y = 0
    end

    local magnitude = math.sqrt(x ^ 2 + y ^ 2)

    local init = {
        __type = "Vector2",
        X = x,
        Y = y,
        Magnitude = magnitude,
        Unit = Vector2.new(x/magnitude, y/magnitude)
    }

    local metatableSetup = {
        __index = Vector2,
        __add = function(v2)
            return v2Math(init, v2, "add")
        end,
        __sub = function(v2)
            return v2Math(init, v2, "sub")
        end,
        __mul = function(v2)
            return v2Math(init, v2, "mul")
        end,
        __div = function(v2)
            return v2Math(init, v2, "div")
        end,
        __tostring = function ()
            return string.format("Vector2: {%f, %f}", init.X, init.Y)
        end
    }
    
    return setmetatable(init, metatableSetup)
end

Vector2.one = Vector2.new(1, 1)
Vector2.zero = Vector2.new(0, 0)
Vector2.xAxis = Vector2.new(1, 0)
Vector2.yAxis = Vector2.new(0, 1)

-- Method
function Vector2:Abs()
    return Vector2.new(math.abs(self.X), math.abs(self.Y))
end

function Vector2:Cell()
    return Vector2.new(math.ceil(self.X), math.ceil(self.Y))
end

function Vector2:Floor()
    return Vector2.new(math.floor(self.X), math.floor(self.Y))
end

function Vector2.max(...)
    local maxX = -math.huge
    local maxY = -math.huge
    for _, v in ipairs(table.unpack(...)) do
       assert(v.__type == "Vector2", "Must be a vector2")
       maxX = math.max(maxX, v.X)
       maxY = math.max(maxY, v.Y)
    end

    return Vector2.new(maxX, maxY)
end

function Vector2.min(...)
    local minX = math.huge
    local minY = math.huge
    for _, v in ipairs(table.unpack(...)) do
       assert(v.__type == "Vector2", "Must be a vector2")
       minX = math.min(minX, v.X)
       minY = math.min(minY, v.Y)
    end

    return Vector2.new(minX, minY)
end

getfenv()["Vector2"] = Vector2

return Vector2