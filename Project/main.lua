require("Core.Systems.ErrorHandler")
require("conf")
Vector2 = require("Helpers.Vector2")
SceneManager = require("Core.Scene.SceneManager")
local Drawing= require("Core.Systems.Drawing")
---@class table
local table = table

---@param t any[]
---@param k any
---@return number?
table.find = function(t, k)
    for i, v in ipairs(t) do
        if v == k then
            return i
        end
    end

    return nil
end

function love.load()
    SceneManager.Init()
end

function love.update(dt)
end

function love.draw()
    Drawing.Draw()
end

function love.keypressed(key)

end