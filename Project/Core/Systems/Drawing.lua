local Drawing = {}

---@type UIComponent[]
local instances = {}

---@param item UIComponent
function Drawing.AddObject(item)
    instances[#instances+1] = item
end

---@param item UIComponent
function Drawing.RemoveObject(item)
    local index = table.find(instances)
    if index then
        table.remove(instances, index)
    end
end

-- Render from most advanced to less advanced
local SUPPORT_ORDER = {
    "UIComponent",
    "TextLabel",
}

---@param instance Instance
---@return number, string?
local function getLatestDrawSupport(instance)
    local highestLevel = 0
    local highestClass = nil
    for i, item in ipairs(SUPPORT_ORDER) do
        if instance:IsA("UIComponent") then
            highestLevel = i
            highestClass = item
        end
    end

    return highestLevel, highestClass
end

function Drawing.Draw()
    for _, item in ipairs(instances) do
        local drawingPos = item.AbsolutePosition
        local drawingSize = item.AbsoluteSize
        local bgColor = item.BackgroundColor
        local bgOpacity = item.BackgroundOpacity

        local highestLevel, highestClass = getLatestDrawSupport(item)
        if highestLevel >= 1 then
            -- Draw a basic rectangle
            love.graphics.setColor(bgColor.R*255, bgColor.G*255, bgColor.B*255, bgOpacity)
            love.graphics.rectangle("fill", drawingPos.X, drawingPos.Y, drawingSize.X, drawingSize.Y)
            love.graphics.reset()
            -- Draw text
            if highestClass == "TextLabel" then
                ---@class TextLabel
                local txt = item
                local font = love.graphics.newFont(drawingSize.Y, "normal", 15)
                local text = love.graphics.newText(font, txt.Text)
                if txt.IsScaled then
                    local width, height = text:getDimensions()
                    local ratio = width/height
                    local ratioW = drawingSize.X/width
                    local ratioH = drawingSize.Y/height
                    local newSize = drawingSize.Y

                    -- get the smallest
                    if ratioW * drawingSize.X / ratio < ratioH * drawingSize.Y then
                        newSize = drawingSize.X * ratioW
                    else
                        newSize = drawingSize.Y * ratioH
                    end
                    local font = love.graphics.newFont(math.max(1, newSize), "normal", 15)
                    text = love.graphics.newText(font, txt.Text)    -- rescale
                end
                love.graphics.draw(text, drawingPos.X, drawingPos.Y, 0, 1, 1)                
                love.graphics.reset()
            end
        end
    end
end

return Drawing