local tbl = {}

---@param t any[]
---@param k any
---@return number?
---Find for a haystack inside an array table
function tbl.find(t, k)
    for i, v in ipairs(t) do
        if v == k then
            return i
        end
    end

    return nil
end

---@param t {[any]: any}
---@return {[any]: any}
function tbl.clone(t)
    local newT = {}

    for k, v in pairs(t) do
        newT[k] = v
    end
    return newT
end

return tbl