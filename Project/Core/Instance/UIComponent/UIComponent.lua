local Instance = require "Core.Instance.Instance"
local UDim2    = require "Helpers.UDim2"
---@class UIComponent: Instance
local UIComponent = {}

---@param u UDim2
---@return Vector2
local function udim2ToVector2(u)
    local width, height = love.graphics.getDimensions()

    local scale = Vector2.new(width * u.X.Scale, height * u.Y.Scale)
    local offset = Vector2.new(u.X.Offset, u.Y.Offset)

    return scale + offset
end

---@param pos UDim2
---@param size UDim2
---@param anchor Vector2
---@return Vector2
local function getRenderPosition(pos, size, anchor)
    local absSize = udim2ToVector2(size)
    local absPos = udim2ToVector2(pos)

    local renderPos = absPos - absSize * anchor
    return renderPos
end

function UIComponent.new()
    local prototype = Instance.new()
    ---@class UIComponent_private: Instance
    ---@field AbsolutePosition Vector2
    ---@field AbsoluteSize Vector2
    
    local __class = "UIComponent"
    local __subclass = prototype.__subclass
    __subclass[#__subclass+1] = __class

    ---@class UIComponent: UIComponent_private
    local init = {
        __class = __class,
        __subclass = __subclass,
        Name = "UIComponent",
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromOffset(100, 100),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor = Color3.new(1, 1, 1),
        BackgroundOpacity = 1
    }

    local metatableSetup = {}
    local originIndex = getmetatable(prototype).__index
    metatableSetup.__tostring = getmetatable(prototype).__tostring

    metatableSetup.__index = function(self, key)
        if key == "AbsolutePosition" then
            return getRenderPosition(self.Position, self.Size, self.AnchorPoint)
        elseif key == "AbsoluteSize" then
            return udim2ToVector2(self.Size)
        elseif UIComponent[key] then
            return UIComponent[key]
        else
            return originIndex(self, key) or prototype[key]
        end
    end
    
    return setmetatable(init, metatableSetup)
end

return UIComponent