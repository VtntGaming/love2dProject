---@class Color3
--A color value comprised of red, green, and blue components.
local Color3 = {}

---@param r number 
---@param g number 
---@param b number 
---@return Color3
---Returns a Color3 with the given red, green, and blue values. The parameters should be within the range of 0 to 1.
function Color3.new(r, g, b)
    r = r or 0
    g = g or 0
    b = b or 0
    ---@class Color3
    local init = {
        __type = "Color3",
        R = r,
        G = g,
        B = b
    }

    local metatableSetup = {
        __index = Color3,
        __tostring = function(self)
            return string.format("Color3: {%f, %f, %f}", self.R, self.G, self.B)
        end
    }

    return setmetatable(init, metatableSetup)
end

---@param r number
---@param g number
---@param b number
---@return Color3
--[[
Creates Color3 with the given red, green, and blue components. 
Unlike most other Color3 functions, the parameters for this function should be within the range of 0 to 255.]]
function Color3.fromRGB(r, g, b)
    return Color3.new(r/ 255, g/255, b/255)
end


---@param h number
---@param s number
---@param v number
---@return Color3
--Creates a Color3 with the given hue, saturation, and value. The parameters should be within the range of 0 to 1.
function Color3.fromHSV(h, s, v)
    if s == 0 then
        return Color3.new(v, v, v)
    elseif v == 0 then
        return Color3.new(0, 0, 0)
    end

    h = (h * 360) % 360 -- đề phòng >360 hoặc <0
    local sector = h / 60
    local i = math.floor(sector)
    local f = sector - i

    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))

    if i == 0 then
        return Color3.new(v, t, p)
    elseif i == 1 then
        return Color3.new(q, v, p)
    elseif i == 2 then
        return Color3.new(p, v, t)
    elseif i == 3 then
        return Color3.new(p, q, v)
    elseif i == 4 then
        return Color3.new(t, p, v)
    else
        return Color3.new(v, p, q)
    end
end

---@param hex string
---@return Color3
--[[
Returns a new Color3 from a six- or three-character hexadecimal format, case insensitive. A preceding hashtag (#) is ignored, if present. This function interprets the given string as a typical web hex color in the format RRGGBB or RGB (shorthand for RRGGBB). For example, #FFAA00 produces an orange color and is the same as #FA0.]]
function Color3.fromHex(hex)
    hex = hex:gsub("#", "")
    local colorValue = tonumber(hex, 16)
    if not colorValue then return Color3.new(0, 0, 0) end
    local r,g,b
    if #hex == 6 then
        r = bit.band(bit.rshift(colorValue, 16), 0xFF)
        g = bit.band(bit.rshift(colorValue, 8),  0xFF)
        b = bit.band(colorValue, 0xFF)
    elseif #hex == 3 then
        local r1 = bit.band(bit.rshift(colorValue, 8), 0xF)
        local g1 = bit.band(bit.rshift(colorValue, 4), 0xF)
        local b1 = bit.band(colorValue, 0xF)

        r = r1 * 17
        g = g1 * 17
        b = b1 * 17
    else
        return Color3.new(0, 0, 0)
    end

    return Color3.fromRGB(r, g, b)
end

---@param color Color3
---@param alpha number
---@return Color3
--Returns a Color3 interpolated between two colors. The alpha value should be within the range of 0 to 1.
function Color3:Lerp(color, alpha)
    local r = math.lerp(self.R, color.R, alpha)
    local g = math.lerp(self.G, color.G, alpha)
    local b = math.lerp(self.B, color.B, alpha)

    return Color3.new(r, g, b)
end

---@return number, number, number
--Returns the hue, saturation, and value of a Color3. This function is the inverse operation of the Color3.fromHSV() constructor.
function Color3:ToHSV()
    local r, g, b = self.R, self.G, self.B

    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min

    local h, s, v

    -- Value
    v = max

    -- Saturation
    if max == 0 then
        s = 0
    else
        s = delta / max
    end

    -- Hue
    if delta == 0 then
        h = 0
    else
        if max == r then
            h = (g - b) / delta
        elseif max == g then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end

        h = h * 60
        if h < 0 then
            h = h + 360
        end
    end

    return h, s, v
end

--[[
Converts the color to a six-character hexadecimal string representing the color in the format RRGGBB. It is not prefixed with an octothorpe (#).

The returned string can be provided to Color3.fromHex() to produce the original color.]]
---@return string
function Color3:ToHex()
    local r = math.floor(self.R * 255)
    local g = math.floor(self.G * 255)
    local b = math.floor(self.B * 255)

    return string.format("#%02X%02X%02X", r, g, b)
end

return Color3