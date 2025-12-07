local Vector2 = {}

local function v2Math(v1, v2, method)
    if type(v2) == "number" then
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

function Vector2.new(x, y)
    if not tonumber(x) then
        x = 0
    end

    if not tonumber(y) then
        y = 0
    end

    local init = {
        __type = "Vector2",
        X = x,
        Y = y
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

function Vector2:Magniture(v2)
    assert(v2 and v2.__type == "Vector2", "Must be a vector2")


end

getfenv()["Vector2"] = Vector2

return Vector2