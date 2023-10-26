scope()
local spec = setModule('spec')
local WoWUnit = WoWUnit

-- stub these badboys for when we don't have WoWUnit loaded
-- I'm still gonna call em
Tests = {}
AreEqual = function(x, y) end
IsTrue = function(x) end
Exists = function(x) end
IsFalse = function(x) end
Replace = function(table, name, replace) end
ClearReplaces = function() end
Enable = function() end
Disable = function() end
Raises = function(x, mess) end
AreDifferent = function(x, y) end
Receives = function(x, ...) end

if not WoWUnit then return end

Tests = WoWUnit(AddonName)

local pcall = pcall
local error = error
local format = format
local tostring = tostring
local tinsert = tinsert
local getfenv = getfenv
local strmatch = strmatch
local debugstack = debugstack
local setmetatable = setmetatable
local setfenv = setfenv


WoWUnit.Raises = function(func, mess, stackoffset)
    stackoffset = stackoffset or 2
    mess = mess or 'func was supposed to raise but did not'
    local retOk = pcall(function()
        func()
    end)
    if retOk then
        error(mess, stackoffset)
    end
end

WoWUnit.AreDifferent = function(x, y)
    WoWUnit.Raises(function()
        WoWUnit.AreEqual(x, y)
    end,
        format('Expected difference but matched %s|nGot %s', tostring(x), tostring(y)),
        3
    )
end

WoWUnit.Receives = function(obj, key, options)
    local count = 0
    local value = options.stub ~= nil and options.stub or obj[key]
    local _obj = util.innerCopy({}, obj)
    local p = util.proxy(_obj, {
        __index = function(t, k)
            if k == key then
                count = count + 1
                return value
            end
            return t[k]
        end
    })
    util.innerCopy(obj, p)
    local _afters = getfenv(2)._afters
    local testLocation = strmatch(debugstack(2), "@(.-:%d+):")
    if options.count then
        tinsert(_afters, 1, function()
            if count ~= options.count then
                error(format(
                    'Receive count error: "%s" was expected to be read %s times but was actually read %s times. %s',
                    key, options.count, count, testLocation), 0)
            end
        end)
    end

    tinsert(_afters, 1, function()
        util.innerCopy(obj, _obj)
    end)
end

function Tests:ReceivesTest()
    local x = { a = 1, b = 2 }
    spec.Receives(x, 'a', { count = 2 })
    util.see(x.a)
    util.see(x.a)

    -- stub works, and counts
    local y = { a = 1 }
    spec.Receives(y, 'a', { count = 1, stub = 'v' })
    spec.AreEqual(y.a, 'v')

    local z = { 1, 2, 3 }
    function z:foo() end

    spec.Receives(z, 'a', { count = 0 })
    spec.Receives(z, 'foo', { count = 1 }) -- chainable, works on functions
    spec.Receives(z, 'b', { count = 1 }) -- counts missed indexes
    spec.Receives(z, 'c', { count = 0 })
    spec.Receives(z, 'd', { stub = 'y' }) -- leave count off, and it just stubs
    z:foo()
    util.see(z.b)
    z.c = 'x' -- doesn't count assignments
    spec.AreEqual(z.d, 'y')
    -- we iterating doesn't work while the Receives is up
    -- because of the proxy. could probably handle, but idc rn
    spec.AreEqual(z, x)
    -- its not verifiable until after the test but
    -- but I checked, and z gets put back together

    -- we can stub an essentially private method
    local c = { money = 0, energy = 10 }
    function c:earn()
        self.money = self.money + 1
    end

    function c:work()
        self.energy = self.energy - 1
        self:earn()
    end

    spec.Receives(c, 'earn', { count = 1, stub = function() end })
    c:work()
    spec.AreEqual(c.money, 0) -- work() called our 'earn' stub instead
    spec.AreEqual(c.energy, 9)
end

-- monkey patching to set test environment variable
-- so we can do _afters
-- roughly the same, but we added setup, asserting, cleanup
function WoWUnit.Test:setup()
    local _G = getfenv(1)
    self._g = { _afters = {} }
    setmetatable(self._g, {
        __index = _G
    })
    setfenv(self.func, self._g)
end

function WoWUnit.Test:asserting(func)
    local success, message = pcall(func)
    if success then
        self.enabled = 1
    else
        tinsert(self.errors, 1, message)
        self._g._failed = true
        self.enabled = WoWUnit.Enabled()
    end
end

function WoWUnit.Test:cleanup()
    for _, func in ipairs(self._g._afters) do
        self:asserting(func)
    end
    if not self._g._failed then
        self.numOk = self.numOk + 1
    end
    WoWUnit.ClearReplaces()
    WoWUnit.Enable()
end

function WoWUnit.Test:__call()
    self:setup()
    self:asserting(self.func)
    self:cleanup()
end

--re-export these over the stubs
AreEqual = WoWUnit.AreEqual
IsTrue = WoWUnit.IsTrue
Exists = WoWUnit.Exists
IsFalse = WoWUnit.IsFalse
Replace = WoWUnit.Replace
ClearReplaces = WoWUnit.ClearReplaces
Enable = WoWUnit.Enable
Disable = WoWUnit.Disable
Raises = WoWUnit.Raises
AreDifferent = WoWUnit.AreDifferent
Receives = WoWUnit.Receives

