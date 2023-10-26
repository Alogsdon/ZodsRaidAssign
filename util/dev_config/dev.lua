local AddonName, private = ...
private.dev = {}
local dev = private.dev
dev._module = nil
dev._tempglobals = {} --set

local getfenv = getfenv
local setfenv = setfenv
local setmetatable = setmetatable
local pairs = pairs
local downcase = function(obj)
    if type(obj) == 'string' then
        return string.lower(obj)
    end
end

-- I might use this for debugging in game
function dev.leakglobal(key, value)
    local _g = getfenv(0)
    _g[key] = value
end

-- I like to do this just for convenience while my addon loads
function dev.tempglobal(key, value)
    dev.leakglobal(key, value)
    dev._tempglobals[key] = true
end

function dev.cleanup()
    local _g = getfenv(0)
    for key in pairs(dev._tempglobals) do
        _g[key] = nil
    end
end

-- sets the current module by name, (initializes it if nil), and returns it
function dev.setModule(name)
    dev._module = name
    return dev.currentModule()
end

-- gets the current module by name, (initializes it if nil)
function dev.getModule(name)
    if name then
        if not private[name] then private[name] = {} end
        return private[name]
    else
        return private
    end
end

function dev.currentModule()
    return dev.getModule(dev._module)
end

do  -- closures for our "scope" env table
    local _g = getfenv(0)
    local exports = _g[AddonName] or {}
    _g[AddonName] = exports
    local globalProxy = {}
    local globalMT = {
        __index = function(_,k)
            local stringkey = downcase(k)
            if stringkey == 'exports' then return exports end
            if stringkey == 'private' then return private end
            if stringkey == 'addonname' then return AddonName end
            if dev.currentModule()[k] then return dev.currentModule()[k] end
            if private[k] then return private[k] end
            return _g[k]
        end,
        __newindex = function(_,k,v)
            dev.currentModule()[k] = v
        end
    }
    setmetatable(globalProxy, globalMT)
    local ENV = globalProxy

    -- when using scope
    -- we only leak globals when writing to "exports" table
    -- and even then, it's AddonNamed in our own addon's global table
    -- otherwise we just write to the private table
    -- module is just a key within the private table
    --
    -- WRITING global (k,v)
    -- (k == 'exports') ? => _G[AddonName][k] = v
    -- modTable = module and private[module] or private
    -- => modTable[k] = v
    --
    -- scope also provides some convenient importing
    -- we've stood a few tables in front of the actual global
    -- ['exports'] || ['private'] || ['AddonName'] || modTable || private || _G
    function dev.scope()
        setfenv(2, ENV)
    end
end


dev.tempglobal('setModule', dev.setModule)
dev.tempglobal('replaceModule', dev.replaceModule)
dev.tempglobal('getModule', dev.getModule)
dev.tempglobal('scope', dev.scope)
dev.tempglobal('cleanup', dev.cleanup)
