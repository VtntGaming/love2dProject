if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Environment setup

-- Game setup
local system = require("Core.System")
system.setup()