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

    return absPos - absSize * anchor
end

local CAN_WRITE = {
    "Position", "Size", "AnchorPoint"
}

local function findForTable(t, k)
    for i, v in ipairs(t) do
        if v == k then
            return i
        end
    end

    return nil
end

function UIComponent.new()
    local prototype = Instance.new()
    ---@class UIComponent_private: Instance
    ---@field AbsolutePosition Vector2
    ---@field AbsoluteSize Vector2

    ---@class UIComponent: UIComponent_private
    local init = {
        __class = "UIComponent",
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromOffset(100, 100),
        AnchorPoint = Vector2.new(0, 0)
    }

    local metatableSetup = {
        __index = function(_, key)
            if key == "AbsolutePosition" then
                return getRenderPosition(init.Position, init.Size, init.AnchorPoint)
            elseif key == "AbsoluteSize" then
                return udim2ToVector2(init.Size)
            end

            if UIComponent[key] then
                return UIComponent[key]
            else
                return prototype[key]
            end
        end,
        __newindex = function(self, key, value)
            assert(findForTable(CAN_WRITE, key), "Cannot write a read-only key to class")
            rawset(self, key, value)
        end
    }
    
    return setmetatable(init, metatableSetup)
end

return UIComponent