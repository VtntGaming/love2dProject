local Object = {}
Object.__index = Object



function Object.new()
    local obj = setmetatable({}, Object)

    return obj
end

function Object:TestAbc()

end

return Object