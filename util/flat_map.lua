local setmetatable = setmetatable
local next = next
local tinsert = table.insert

scope()
setModule('util')

-- the use case for this came from combat log event args
-- the args mapping is formed by merging 2-3 tables from a selection of probably 20 or so constant tables
-- combat log events can be incredibly spammy so this is sensitive to performance
-- rather than fully rebuilding the resulting table in the "merge", I think it'd be much less expensive
-- to just push the 2-3 table pointers into a table (FlatMap), and use the metatable to make them behave as if merged.
FlatMap = {}
local FlatMap = FlatMap

FlatMap.__index = function(o, k)
    for _, tableFragment in ipairs(o._tableFragments) do
        if tableFragment[k] then
            return tableFragment[k]
        end
    end
    return FlatMap[k]
end

function FlatMap:new(initialMap)
    local flatmap = {}
    flatmap._tableFragments = {}
    setmetatable(flatmap, FlatMap)
    flatmap:mergeMap(initialMap)
    return flatmap
end

function FlatMap:iterator()
    local tableFragments = self._tableFragments
    local fragInd, fragment, element, elInd
    return function()
        repeat
            if not elInd then -- first pass, or previous pass drew a blank
                fragInd, fragment = next(tableFragments, fragInd)
                if not fragInd then return end -- we are out of fragments and elements
            end
            elInd, element = next(fragment, elInd)
        until elInd -- do another pass if we drew a blank

        return elInd, element
    end
end

function FlatMap:mergeMap(map)
    if not map then return end

    tinsert(self._tableFragments, map)
end

function spec.Tests:FlatMapTest()
    local flatmap = FlatMap:new()
    local abc = { 'a', 'b', 'c' }
    local de = { [4] = 'd',[5] = 'e' }
    flatmap:mergeMap({})
    flatmap:mergeMap(abc)
    flatmap:mergeMap(de)


    spec.AreEqual(flatmap[1], 'a')
    spec.AreEqual(flatmap[3], 'c')
    spec.AreEqual(flatmap[5], 'e')
    spec.AreEqual(flatmap[6], nil)

    local collector = {}
    for k, v in flatmap:iterator() do
        collector[k] = v
    end
    spec.AreEqual(collector, { 'a', 'b', 'c', 'd', 'e' })

    local empty = FlatMap:new()
    local collector2 = {}
    for k, v in empty:iterator() do
        collector2[k] = v
    end

    spec.AreEqual(collector2, {})
    spec.AreEqual(empty[1], nil)
end
