---@param item any
---@return string
function TypeOf(item)
    if type(item) == "table" then
        return item.__type
    else
        return type(item)
    end
end