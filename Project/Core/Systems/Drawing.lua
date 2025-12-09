local Drawing = {}

---@type UIComponent[]
local instances = {}

---@param item UIComponent
function Drawing.AddObject(item)
    instances[#instances+1] = item
    print(item.AbsolutePosition)
    print(item.AbsoluteSize)
end

function Drawing.Draw()
    for _, item in ipairs(instances) do
        local drawingPos = item.AbsolutePosition
        local drawingSize = item.AbsoluteSize
        love.graphics.rectangle("fill", drawingPos.X, drawingPos.Y, drawingSize.X, drawingSize.Y)
    end
end

return Drawing