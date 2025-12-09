local UIComponent = require "Core.Instance.UIComponent.UIComponent"
local UDim2       = require "Helpers.UDim2"
local Drawing     = require "Core.Systems.Drawing"
local TextLabel   = require "Core.Instance.UIComponent.BasicDisplay.TextLabel"
local SceneInit = {}

local objInstance = {}

---@param sceneObj Scene
function SceneInit.Init(sceneObj)
    -- UI Init
    local newLabel = TextLabel.new()
    newLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    newLabel.Position = UDim2.fromScale(0.5, 0.5)
    newLabel.Size = UDim2.fromOffset(100, 100)
    newLabel.BackgroundOpacity = 0.5
    newLabel.IsScaled = true
    objInstance.txt = newLabel
    
    for _, item in pairs(objInstance) do
        -- print("Add to draw ->>> ", item)
        Drawing.AddObject(item)
    end
end

function SceneInit.Cleanup()
    for _, item in pairs(objInstance) do
        Drawing.RemoveObject(item)
    end
end

return SceneInit