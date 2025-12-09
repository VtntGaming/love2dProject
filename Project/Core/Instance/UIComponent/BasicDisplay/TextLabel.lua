local UIComponent = require "Core.Instance.UIComponent.UIComponent"
---@class TextLabel: UIComponent
local TextLabel = {}

function TextLabel.new()
    local prototype = UIComponent.new()
    local __class = "TextLabel"
    local __subclass = prototype.__subclass
    __subclass[#__subclass+1] = __class

    ---@class TextLabel: UIComponent
    ---@field SourceText string
    local init = {        
        __class = __class,
        __subclass = __subclass,
        Name = "TextLabel",
        Text = "Sample text",
        IsScaled = false
    }

    local metatableSetup = {}
    local originIndex = getmetatable(prototype).__index
    metatableSetup.__tostring = getmetatable(prototype).__tostring

    metatableSetup.__index = function(self, key)
        return originIndex(self, key) or prototype[key]
    end


    return setmetatable(init, metatableSetup)
end



return TextLabel