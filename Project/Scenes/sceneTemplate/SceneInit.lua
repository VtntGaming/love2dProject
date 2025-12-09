local UIComponent = require "Core.Instance.UIComponent.UIComponent"
local UDim2       = require "Helpers.UDim2"
local Drawing     = require "Core.Systems.Drawing"
local SceneInit = {}

function SceneInit.Init(sceneObj)
    local testObject = UIComponent.new()
    testObject.Size = UDim2.fromOffset(100, 100)
    testObject.Position = UDim2.fromOffset(100, 100)
    testObject.AnchorPoint = Vector2.new(0.5, 0.5)
    Drawing.AddObject(testObject)
end

return SceneInit