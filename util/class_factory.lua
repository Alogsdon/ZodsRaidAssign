scope()
setModule('util')

local baseClass = {
    class = function(self)
        return getmetatable(self)
    end,
}
-- TODO be nice to let ancestors declare initializers
-- for example, in lazy props class, if we dont have _props set, we get an infinite loop looking it up
-- workaround is hacking some extra logic into the __index of said classes
function CreateClass(Class, ...)
    Class = Class or {}
    local parents = { baseClass, ... }

    local classMt = {
        __index = function(o, k) -- this isn't awesome. we lose the context of the actual object
            for _, parent in ipairs(parents) do
                if parent[k] then
                    return parent[k]
                end
            end
        end
    }
    setmetatable(Class, classMt)

    Class.__index = Class -- look in Class for missing methods

    function Class:new(o)
        o = o or {}
        setmetatable(o, Class)
        return o
    end

    return Class
end


function spec.Tests:CreateClassTest()
    local CreateClass = util.CreateClass
    local C = CreateClass({lname = 'c'})
    local c1 = C:new()
    local c2 = C:new()
    local B = CreateClass({lname = 'b', fname = 'b'})
    local b1 = B:new()
    spec.IsTrue(c1.lname == c2.lname)
    spec.IsTrue(c1.lname == 'c')
    spec.IsTrue(b1.lname == 'b')
    spec.IsTrue(c1:class() == c2:class())
    spec.IsFalse(c1:class() == b1:class())
    c2.lname = 'g'
    spec.IsFalse(c2.lname == c1.lname)
    local D = CreateClass({fname = 'd'}, B)
    local d1 = D:new({middle = 'm'})
    spec.IsTrue(d1.lname == 'b')
    spec.IsTrue(d1.fname == 'd')
    spec.IsTrue(d1.middle == 'm')
end
