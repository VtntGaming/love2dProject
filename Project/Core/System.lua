-- system.lua
-- A small, opinionated "system" module for LÖVE (love2d)
-- Usage (in main.lua):
--   local system = require 'system'
--   function love.load() system.load() end
--   function love.update(dt) system.update(dt) end
--   function love.draw() system.draw() end
--   function love.keypressed(k, sc, isrepeat) system.keypressed(k, sc, isrepeat) end
--   function love.mousepressed(x,y,b,istouch,presses) system.mousepressed(x,y,b,istouch,presses) end
--   function love.resize(w,h) system.resize(w,h) end

local System = {}

-- Default configuration
local defaultConfig = {
    width = 1280,
    height = 720,
    title = "LÖVE Game",
    fullscreen = false,
    vsync = true,
    resizable = true,
    msaa = 0,
    bgColor = {0.06, 0.06, 0.06}, -- normalized 0..1
    filter = {min = "nearest", mag = "nearest"},
    virtualWidth = 1280,
    virtualHeight = 720,
    defaultFont = nil, -- path to font or nil for builtin
    defaultFontSize = 14,
    showFPS = true,
    seed = os.time()
}

-- current state
System.config = {}
System.states = {}
System._stack = {}
System.current = nil
System._scale = {1,1}
System._offset = {0,0}
System._keysPressed = {}
System._mousePressed = {}

-- simple util: shallow merge
local function shallow_merge(a,b)
    local out = {}
    for k,v in pairs(a) do out[k] = v end
    if b then for k,v in pairs(b) do out[k] = v end end
    return out
end

-- setup config and apply window mode
function System.setup(userConfig)
    System.config = shallow_merge(defaultConfig, userConfig)

    love.window.setMode(System.config.width, System.config.height, {
        fullscreen = System.config.fullscreen,
        vsync = System.config.vsync and 1 or 0,
        resizable = System.config.resizable,
        msaa = System.config.msaa
    })
    love.window.setTitle(System.config.title)
end

-- call in love.load
function System.load(userConfig)
    System.setup(userConfig)

    -- RNG
    math.randomseed(System.config.seed)
    -- graphics defaults
    love.graphics.setDefaultFilter(System.config.filter.min, System.config.filter.mag)

    -- load default font
    if System.config.defaultFont then
        success, font = pcall(love.graphics.newFont, System.config.defaultFont, System.config.defaultFontSize)
        if success and font then
            love.graphics.setFont(font)
            System.font = font
        end
    else
        System.font = love.graphics.getFont() or love.graphics.newFont(System.config.defaultFontSize)
        love.graphics.setFont(System.font)
    end

    -- compute initial scale
    System.resize(love.graphics.getWidth(), love.graphics.getHeight())

    -- hook love callbacks by forwarding (user still must call System.keypressed etc. from love callbacks)
end

-- State management
function System.registerState(name, stateTable)
    System.states[name] = stateTable
end

function System.switchState(name, ...)
    if System.current and System.current.exit then
        System.current.exit()
    end
    System.current = System.states[name]
    if System.current and System.current.enter then
        System.current.enter(...)
    end
end

function System.pushState(name, ...)
    if System.current then table.insert(System._stack, System.current) end
    System.current = System.states[name]
    if System.current and System.current.enter then System.current.enter(...) end
end

function System.popState()
    if #System._stack > 0 then
        if System.current and System.current.exit then System.current.exit() end
        System.current = table.remove(System._stack)
        if System.current and System.current.enter then System.current.enter() end
    end
end

-- input helpers
function System.keypressed(key, sc, isrepeat)
    System._keysPressed[key] = true
    if System.current and System.current.keypressed then System.current.keypressed(key, sc, isrepeat) end
end

function System.mousepressed(x,y,b,istouch,presses)
    System._mousePressed[b] = {x=x,y=y}
    if System.current and System.current.mousepressed then System.current.mousepressed(x,y,b,istouch,presses) end
end

function System.isKeyPressed(key)
    return System._keysPressed[key]
end

function System.clearInput()
    System._keysPressed = {}
    System._mousePressed = {}
end

-- resize handling and virtual scaling (letterbox)
function System.resize(w,h)
    local vw, vh = System.config.virtualWidth, System.config.virtualHeight
    local sx = w / vw
    local sy = h / vh
    local scale = math.min(sx, sy)
    System._scale[1] = scale
    System._scale[2] = scale
    System._offset[1] = math.floor((w - vw * scale) / 2)
    System._offset[2] = math.floor((h - vh * scale) / 2)

    if System.current and System.current.resize then
        System.current.resize(w,h)
    end
end

-- convert coordinates from window -> virtual and vice versa
function System.windowToVirtual(x,y)
    return (x - System._offset[1]) / System._scale[1], (y - System._offset[2]) / System._scale[2]
end

function System.virtualToWindow(x,y)
    return x * System._scale[1] + System._offset[1], y * System._scale[2] + System._offset[2]
end

-- update and draw (user should call these from love.update / love.draw)
function System.update(dt)
    if System.current and System.current.update then
        System.current.update(dt)
    end
    -- clear one-frame input trackers at end of update
    System._keysPressed = {}
    System._mousePressed = {}
end

function System.draw()
    -- clear background
    love.graphics.clear(System.config.bgColor)

    -- apply letterbox transform
    love.graphics.push()
    love.graphics.translate(System._offset[1], System._offset[2])
    love.graphics.scale(System._scale[1], System._scale[2])

    if System.current and System.current.draw then
        System.current.draw()
    end

    love.graphics.pop()

    -- debug overlays (in window coordinates)
    if System.config.showFPS then
        local fps = love.timer.getFPS()
        love.graphics.setColor(1,1,1)
        love.graphics.print(string.format("FPS: %d", fps), 8, 8)
        love.graphics.setColor(1,1,1,1)
    end
end

-- convenience: switch to a random seed
function System.seedRandom(s)
    s = s or os.time()
    System.config.seed = s
    math.randomseed(s)
end

-- expose some useful values
function System.getScale() return System._scale[1], System._scale[2] end
function System.getOffset() return System._offset[1], System._offset[2] end

-- small utility to create a simple state
function System.newState(t)
    t = t or {}
    t.enter = t.enter or function() end
    t.exit = t.exit or function() end
    t.update = t.update or function() end
    t.draw = t.draw or function() end
    t.keypressed = t.keypressed or function() end
    t.mousepressed = t.mousepressed or function() end
    t.resize = t.resize or function() end
    return t
end

return System
