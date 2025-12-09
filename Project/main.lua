-- Config
require("Core.Systems.ErrorHandler")
require("conf")
-- Helpers
require("Helpers.typeof")
Vector2 = require("Helpers.Vector2")
UDim2 = require("Helpers.UDim2")
Color3 = require("Helpers.Color3")
math = setmetatable(math, {__index = require("Helpers.MathExtended")})
local SceneManager = require("Core.Scene.SceneManager")
local Drawing = require("Core.Systems.Drawing")
table = setmetatable(table, {__index = require("Helpers.TableExtended")})

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