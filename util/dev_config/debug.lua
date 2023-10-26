
scope()
local debug = setModule('debug')
local debugstack = debugstack
local tinsert = tinsert
local IsAddOnLoaded = IsAddOnLoaded
local UIParentLoadAddOn = UIParentLoadAddOn
local geterrorhandler = geterrorhandler


local charName = UnitName('player')
if charName == 'Zodicus' or charName == 'Gahdzira' or charName == 'Zodicoos' or charName == 'Zoder' or charName == 'Charlean' or charName == 'Zods' then
    debug.enabled = true
    if (not IsAddOnLoaded("Blizzard_DebugTools")) then
        UIParentLoadAddOn("Blizzard_DebugTools")
    end
    tinspect = DisplayTableInspectorWindow
    
    dump = function(...)
        local testLocation = strmatch(debugstack(2), "@(.-:%d+):")
        local t = GetTime()
        print(testLocation .. ' t:' .. t)
        DevTools_Dump(...)
    end
    -- expose private variable table
    exports.debugPrivate = private
else
    tinspect = function(x) end
    dump = function(x) end
end
dev.leakglobal('dump', dump)
dev.leakglobal('tinspect', tinspect)

debug.errors = {}
function debug.silentHandler(err)
    tinsert(debug.errors, err)
    if debug.enabled then
        debug.dump('this error would be silenced')
        debug.dump(err)
    end
end

function debug.handler(err)
    return geterrorhandler()(err)
end
