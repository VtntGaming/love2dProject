-- improved_errorhandler.lua
local utf8 = require("utf8")

local function safe_tostring(x)
    local ok, s = pcall(tostring, x)
    if ok then return s else return "<tostring error>" end
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. safe_tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", "")))
end

-- Returns a sanitized UTF-8 string (keeps valid utf8 chars)
local function sanitize_utf8(msg)
    local t = {}
    for ch in msg:gmatch(utf8.charpattern) do
        table.insert(t, ch)
    end
    return table.concat(t)
end

-- Approximate number of wrapped lines (used to compute scroll limits).
-- It's an approximation: measures width of each original line and divides by maxWidth.
local function approximate_line_count(text, font, maxWidth)
    local h = font:getHeight()
    local count = 0
    if maxWidth <= 0 then return 1 end
    for line in text:gmatch("[^\n]*") do
        if line == "" then
            count = count + 1
        else
            local w = font:getWidth(line)
            local adds = math.max(1, math.ceil(w / maxWidth))
            count = count + adds
        end
    end
    return count, count * h
end

function love.errorhandler(msg)
    msg = safe_tostring(msg)

    error_printer(msg, 2)

    -- If essential subsystems are missing, bail out.
    if not love.window or not love.graphics or not love.event then
        return
    end

    -- Ensure a window exists
    if not love.graphics.isCreated or not love.graphics.isCreated() or not love.window.isOpen() then
        local success = pcall(function() love.window.setMode(800, 600) end)
        if not success then return end
    end

    -- reset input/audio/joystick state as best we can
    if love.mouse then
        pcall(function()
            love.mouse.setVisible(true)
            love.mouse.setGrabbed(false)
            love.mouse.setRelativeMode(false)
            if love.mouse.isCursorSupported and love.mouse.isCursorSupported() then
                love.mouse.setCursor()
            end
        end)
    end

    if love.joystick then
        pcall(function()
            for i, v in ipairs(love.joystick.getJoysticks()) do
                if v.setVibration then pcall(function() v:setVibration() end) end
            end
        end)
    end

    if love.audio then pcall(function() love.audio.stop() end) end

    -- Try to reset graphics state safely
    pcall(function()
        if love.graphics.reset then
            love.graphics.reset()
        else
            -- fallback: clear transforms and colors
            love.graphics.origin()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    local font = nil
    pcall(function() font = love.graphics.newFont(14) end)
    font = font or love.graphics.getFont() or love.graphics.newFont()

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    -- Build error text
    local sanitizedmsg = sanitize_utf8(msg)
    local trace = debug.traceback()

    local parts = {}
    table.insert(parts, "Error")
    table.insert(parts, "------")
    table.insert(parts, sanitizedmsg)
    if #sanitizedmsg ~= #msg then
        table.insert(parts, "(Invalid UTF-8 sequences were removed from the error message.)")
    end
    table.insert(parts, "")

    -- Add traceback lines, filter boot.lua noise
    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Traceback")
            table.insert(parts, l)
        end
    end

    local fullErrorText = table.concat(parts, "\n")

    -- Provide helpful footer
    local platformHints = {}
    if love.system then
        table.insert(platformHints, "Ctrl+C: Copy to clipboard")
    end
    table.insert(platformHints, "S: Save to error.log")
    table.insert(platformHints, "R: Restart (if supported)")
    table.insert(platformHints, "Esc / Quit button: Quit")
    fullErrorText = fullErrorText .. "\n\n" .. table.concat(platformHints, "    ")

    -- UI state
    local scroll = 0
    local maxScroll = 0
    local wheelDelta = 0
    local copied = false
    local saved = false

    -- Button layout (top-right)
    local buttons = {
        {id = "copy", label = "Copy"},
        {id = "save", label = "Save"},
        {id = "restart", label = "Restart"},
        {id = "quit", label = "Quit"},
    }

    -- compute wrapped size approx
    local padding = 20
    local leftPad = 20
    local rightPad = 20
    local textX = leftPad
    local textWidth = love.graphics.getWidth() - (leftPad + rightPad)
    local _, approxContentH = approximate_line_count(fullErrorText, font, textWidth)
    maxScroll = math.max(0, approxContentH - (love.graphics.getHeight() - 140)) -- leave space for header/buttons

    -- helper actions
    local function copyToClipboard()
        if not love.system then return false end
        local ok, err = pcall(function() love.system.setClipboardText(fullErrorText) end)
        if ok then copied = true end
        return ok, err
    end

    local function saveToFile()
        local ok, err = pcall(function()
            local filename = "error.log"
            -- Use love.filesystem so it works cross-platform
            if love.filesystem then
                love.filesystem.write(filename, fullErrorText)
            else
                local f = io.open(filename, "w")
                if f then
                    f:write(fullErrorText)
                    f:close()
                else
                    error("cannot open file")
                end
            end
        end)
        if ok then saved = true end
        return ok, err
    end

    local function attempt_restart()
        -- many LOVE builds honour love.event.quit("restart")
        if love.event and love.event.quit then
            pcall(function() love.event.quit("restart") end)
            return true
        end
        return false
    end

        -- Draw function
    local function draw()
        -- If love.graphics has isActive, check it (some LOVE versions might not have it)
        if love.graphics.isActive and not love.graphics.isActive() then return end

        local ok, err = pcall(function()
            love.graphics.clear(41/255, 41/255, 41/255) -- dark background

            -- Header
            local headerH = 60
            love.graphics.push()
            love.graphics.origin()
            love.graphics.setColor(0.85, 0.2, 0.2)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), headerH)
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(font)
            love.graphics.printf("An error has occurred", 10, 12, love.graphics.getWidth(), "left")

            -- Draw buttons on top-right (cache rects)
            local bx = love.graphics.getWidth() - 10
            for i = #buttons, 1, -1 do
                local b = buttons[i]
                local label = b.label
                local w = font:getWidth(label) + 16
                local h = headerH - 16
                bx = bx - w
                b.rect = {x = bx, y = 10, w = w, h = h}
                love.graphics.setColor(0.15, 0.15, 0.15)
                love.graphics.rectangle("fill", b.rect.x, b.rect.y, b.rect.w, b.rect.h, 6, 6)
                love.graphics.setColor(1,1,1)
                love.graphics.printf(label, b.rect.x, b.rect.y + (h - font:getHeight())/2, b.rect.w, "center")
                bx = bx - 8
            end
            love.graphics.pop()

            -- Content area
            local contentY = headerH + 10
            local contentH = math.max(0, love.graphics.getHeight() - contentY - 10)

            -- Only set scissor if we have positive area
            if contentH > 0 then
                -- Ensure integer values for scissor (some backends expect integers)
                local sx, sy, sw, sh = 0, math.floor(contentY), math.floor(love.graphics.getWidth()), math.floor(contentH)
                love.graphics.setScissor(sx, sy, sw, sh)
            end

            love.graphics.push()
            -- translate so that y==contentY is the top of the content area, then offset by -scroll
            love.graphics.translate(0, contentY - scroll)

            love.graphics.setFont(font)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(fullErrorText, textX, 0, textWidth) -- draw at y=0 (we already translated)

            -- status hints
            local statusY = approxContentH + 6
            if copied then
                love.graphics.printf("[Copied to clipboard]", textX, statusY, textWidth, "left")
            end
            if saved then
                love.graphics.printf("[Saved to error.log]", textX + 220, statusY, textWidth, "left")
            end

            love.graphics.pop()
            love.graphics.setScissor()
        end)
        if not ok then
            -- If draw itself errors, at least try a minimal fallback so screen isn't black forever
            pcall(function()
                love.graphics.clear(0,0,0)
                love.graphics.origin()
                love.graphics.setColor(1,1,1)
                local s = "Error screen failed to render: "..tostring(err or "?")
                love.graphics.printf(s, 10, 10, love.graphics.getWidth()-20)
            end)
        end

        -- Present buffer if available (some backends need explicit present)
        if love.graphics.present then
            pcall(function() love.graphics.present() end)
        end
    end

    -- Event loop for error screen (robust)
    return function()
        love.event.pump()
        for e, a, b, c, d in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" then
                if a == "escape" then
                    return 1
                elseif (a == "c" or a == "C") and love.keyboard.isDown("lctrl", "rctrl") then
                    copyToClipboard()
                elseif a == "s" or a == "S" then
                    saveToFile()
                elseif a == "r" or a == "R" then
                    attempt_restart()
                elseif a == "up" then
                    scroll = math.max(0, scroll - font:getHeight() * 3)
                elseif a == "down" then
                    scroll = math.min(maxScroll, scroll + font:getHeight() * 3)
                elseif a == "pageup" then
                    scroll = math.max(0, scroll - (love.graphics.getHeight() * 0.8))
                elseif a == "pagedown" then
                    scroll = math.min(maxScroll, scroll + (love.graphics.getHeight() * 0.8))
                elseif a == "home" then
                    scroll = 0
                elseif a == "end" then
                    scroll = maxScroll
                end
            elseif e == "mousepressed" then
                local mx, my, button = a, b, c
                for _, btn in ipairs(buttons) do
                    if btn.rect and mx >= btn.rect.x and mx <= btn.rect.x + btn.rect.w
                            and my >= btn.rect.y and my <= btn.rect.y + btn.rect.h then
                        if btn.id == "copy" then copyToClipboard()
                        elseif btn.id == "save" then saveToFile()
                        elseif btn.id == "quit" then return 1
                        elseif btn.id == "restart" then attempt_restart()
                        end
                    end
                end
            elseif e == "wheelmoved" then
                local wheelX, wheelY = a, b
                local step = font:getHeight() * 4
                if wheelY > 0 then
                    scroll = math.max(0, scroll - step * wheelY)
                elseif wheelY < 0 then
                    scroll = math.min(maxScroll, scroll - step * wheelY)
                end
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttonsBox = {"Quit "..name, "Copy", "Cancel"}
                if love.window.showMessageBox then
                    local pressed = love.window.showMessageBox("App crashed", "What do you want to do?", buttonsBox)
                    if pressed == 1 then
                        return 1
                    elseif pressed == 2 then
                        copyToClipboard()
                    end
                end
            end
        end

        draw()

        if love.timer then love.timer.sleep(0.02) end
    end
end
