local mathExtended = {}

--[[
Returns the linear interpolation between a and b based on the factor t.

This function uses the formula `a+(b-a)*t`. t is typically between `0` and `1` but values outside this range are acceptable.]]
---@param a number
---@param b number
---@param t number
---@return number
function mathExtended.lerp(a, b, t)
    return a + (b - a) * t
end

--Returns a number between `min` and `max`, inclusive.
---@param x number
---@param min number
---@param max number
---@return number
function mathExtended.clamp(x, min, max)
    return math.min(max, math.max(x, min))
end

---@param x number
--Returns -1 if x is less than 0, 0 if x equals 0, or 1 if x is greater than 0.
function mathExtended.sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

local permutation = {
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,
    23,190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,
    57,177,33,88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,
    139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,
    41,55,46,245,40,244,102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,
    208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,
    3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,
    59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152, 2,44,154,
    163, 70,221,153,101,155,167, 43,172,9,129,22,39,253, 19,98,108,110,79,
    113,224,232,178,185, 112,104,218,246,97,228,251,34,242,193,238,210,
    144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214, 31,
    181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254
}

local p = {}
for i = 1, #permutation * 2 do
    p[i] = permutation[(i - 1) % #permutation + 1]
end

local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function grad(hash, x, y, z)
    local h = hash % 16
    local u = h < 8 and x or y
    local v = h < 4 and y or (h == 12 or h == 14) and x or z
    return ((h % 2 == 0) and u or -u) + ((h % 4 == 0) and v or -v)
end


--[[
Returns a Perlin noise value. The returned value is most often between the
range of `-1` to `1` (inclusive) but sometimes may be outside that range; if the interval is critical to you, use `Library.math.clamp(noise, -1, 1)`
on the output.

If you leave arguments out, they will be interpreted as zero, so
`Library.math.noise(1.158)` is equivalent to
`Library.math.noise(1.158, 0, 0)` and `Library.math.noise(1.158, 5.723)`
is equivalent to `Library.math.noise(1.158, 5.723, 0)`.

Note that this function uses a Perlin noise algorithm to assign fixed
values to coordinates. For example, `Library.math.noise(1.158, 5.723)`
will always return `0.48397532105446` and `Library.math.noise(1.158, 6)`
will always return `0.15315161645412`.

If `x`, `y`, and `z` are all integers, the return value will be `0`. For
fractional values of `x`, `y`, and `z`, the return value will gradually
fluctuate between `-0.5` and `0.5`. For coordinates that are close to each\nother, the return values will also be close to each other.
]]
---@param x number
---@param y number
---@param z number
---@return number
function mathExtended.noise(x, y, z)
    y = y or 0
    z = z or 0

    local X = math.floor(x) % 256
    local Y = math.floor(y) % 256
    local Z = math.floor(z) % 256

    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    local u = fade(x)
    local v = fade(y)
    local w = fade(z)

    local A  = p[X + 1]     + Y
    local AA = p[A + 1]     + Z
    local AB = p[A + 2]     + Z
    local B  = p[X + 2]     + Y
    local BA = p[B + 1]     + Z
    local BB = p[B + 2]     + Z

    return mathExtended.lerp(
        mathExtended.lerp(
            mathExtended.lerp(grad(p[AA+1], x, y, z),
                 grad(p[BA+1], x-1, y, z), u),
            mathExtended.lerp(grad(p[AB+1], x, y-1, z),
                 grad(p[BB+1], x-1, y-1, z), u), v),
        mathExtended.lerp(
            mathExtended.lerp(grad(p[AA+2], x, y, z-1),
                 grad(p[BA+2], x-1, y, z-1), u),
            mathExtended.lerp(grad(p[AB+2], x, y-1, z-1),
                 grad(p[BB+2], x-1, y-1, z-1), u), v),
        w
    )
end


return mathExtended