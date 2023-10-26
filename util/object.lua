scope()
setModule('util')

function fullwipe(t)
    wipe(t)
    setmetatable(t, nil)
end

--- replace inner contents of `t` with `other`.
-- `t` gets wiped, keys are copied, then metatable
---@param t table
---@param other table
---@return table
function innerCopy(t, other)
    util.fullwipe(t)
    local otherMt = getmetatable(other)
    for key, value in pairs(other) do
        t[key] = value
    end
    setmetatable(t, otherMt)
    return t
end


-- stands a proxy table up in front of `table`
-- runs `__index`, and `__newindex` through `mt` if present
-- passes the original table as the `t` arg to those
-- so you don't need a closure on that
-- like inheritance, iterating won't work without some help
function proxy(table, mt)
    local proxyTable = {}
    for _, mtMethod in ipairs({'__index', '__newindex'}) do
        if mt[mtMethod] then
            local hookfunc = mt[mtMethod]
            mt[mtMethod] = function(_t, k, v)
                return hookfunc(table, k, v)
            end
        else
            mt[mtMethod] = table
        end
    end
    setmetatable(proxyTable, mt)
    return proxyTable
end

function spec.Tests:ProxyTest()
    local proxy = util.proxy
    local x = { 1, 2, 3}
    local hits = {}
    local misses = {}
    local proxyMt = {__index = function(t, k)
        local val = t[k]
        if val then hits[k] = true else misses[k] = true end
        return val
    end}
    local _x = util.innerCopy({}, x)
    local p = proxy(_x, proxyMt)
    util.innerCopy(x, p)
    util.see(x[1])
    util.see(x.a)
    spec.AreEqual(util.countBy(hits, util.present), 1)
    spec.AreEqual(util.countBy(misses, util.present), 1)
    x.b = 'bb'
    spec.AreEqual(x.b, 'bb')
    spec.AreEqual(x[3], 3)

    local y = { 1, 2, { 1, 2 }}
end


