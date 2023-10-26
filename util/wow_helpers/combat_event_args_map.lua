local ipairs = ipairs
local strfind = string.find
local strsub = string.sub

scope()
setModule('wow_helpers')

CombatEventArgsMap = util.CreateClass({})
local CombatEventArgsMap = CombatEventArgsMap

function CombatEventArgsMap.create(subevent)
    local map = CombatEventArgsMap:new()
    map.subevent = subevent
    return map
end

function CombatEventArgsMap:getInd(argKey)
    if CombatEventArgsMap.COMMON_ARGS[argKey] then
        return CombatEventArgsMap.COMMON_ARGS[argKey]
    end
    if not CombatEventArgsMap.NOT_COMMON_ARG_KEYS[argKey] then
        return nil -- bad argKey, matches no events
    end
    return self:getFlatMap()[argKey]
end

function spec.Tests:CombatEventArgsMap_getIndTest()
    local CombatEventArgsMap = wow_helpers.CombatEventArgsMap
    local map = CombatEventArgsMap.create('SPELL_DAMAGE')
    spec.AreEqual(map:getInd('sourceName'), 5)
    spec.AreEqual(map:getInd('fakey'), nil) -- doesn't trigger a build
    spec.AreEqual(map.flatmap, nil)
    spec.AreEqual(map:getInd('amount'), 15)
    spec.AreEqual(map.suffix, '_DAMAGE')
end

function CombatEventArgsMap:keyIter()
    return self:getFlatMap():iterator()
end

function spec.Tests:CombatEventArgsMap_keyIterTest()
    local CombatEventArgsMap = wow_helpers.CombatEventArgsMap
    local map = CombatEventArgsMap.create('SPELL_INTERRUPT')
    local collector = {}
    for k, v in map:keyIter() do
        collector[k] = v
    end
    spec.AreEqual(collector.extraSpellName, 16)
    spec.AreEqual(collector.spellId, 12)
    spec.AreEqual(collector.sourceName, 5)
end

-- we want to be lazy here. only build the map when we have to.
-- most of the time, we can probably get by with just COMMON_ARGS
function CombatEventArgsMap:getFlatMap()
    if self.flatmap then return self.flatmap end

    self:buildMap()
    return self.flatmap
end

CombatEventArgsMap.NOT_COMMON_ARG_KEYS = { overkill = true, school = true, resisted = true, blocked = true,
    glancing = true, crushing = true, isOffHand = true, missType = true,amountMissed = true,
    overhealing = true, absorbed = true, critical = true, extraGUID = true, extraName = true,
    extraFlags = true, extraRaidFlags = true, extraSpellID = true, extraSpellName = true, extraSchool = true,
    absorbedAmount = true, totalAmount = true, amount = true, overEnergize = true, powerType = true,
    maxPower = true, extraAmount = true, extraSpellId = true, auraType = true, failedType = true,
    unconsciousOnDeath = true, spellName = true, itemID = true, itemName = true, recapID = true,
    spellId = true, spellSchool = true, environmentalType = true }

CombatEventArgsMap.SUBEVENT_CATEGORIES = {
    STANDARD = 'standard',
    SPECIAL_EVENTS_REUSE = 'special events reuse',  -- these events work by declaring a pre-existing prefix/suffix that gives appropriate args
    SPECIAL_EVENTS_NEW = 'special events new',  -- these ones just declare new args, but they don't split by prefix/suffix
}
local SUBEVENT_CATEGORIES = CombatEventArgsMap.SUBEVENT_CATEGORIES

local ENVIRONMENTAL = 'ENVIRONMENTAL'
local SPELL_BUILDING = 'SPELL_BUILDING'
local SPELL_PERIODIC = 'SPELL_PERIODIC'
local SPELL = 'SPELL'
local RANGE = 'RANGE'
local SWING = 'SWING'

-- being careful with the ordering, so we match the longest first via ipairs
CombatEventArgsMap.SUBEVENT_PREFIXES = {
    ENVIRONMENTAL,
    SPELL_BUILDING,
    SPELL_PERIODIC,
    SPELL,
    RANGE,
    SWING
}
local SUBEVENT_PREFIXES = CombatEventArgsMap.SUBEVENT_PREFIXES

-- I painstakingly copied these from wowpedia. updating this could be hell.. I gave up on making it tidy
-- empty nodes are commented to save overhead.

CombatEventArgsMap.COMMON_ARGS = {
    timestamp = 1, subevent = 2, hideCaster = 3, sourceGUID = 4, sourceName = 5, sourceFlags = 6,
    sourceRaidFlags = 7, destGUID = 8, destName = 9, destFlags = 10, destRaidFlags = 11
}
local COMMON_ARGS = CombatEventArgsMap.COMMON_ARGS

local SUBEVENT_PREFIX_ARGS = {
    --SWING = {},
    ENVIRONMENTAL = { environmentalType = 12 },
    RANGE = { spellId = 12, spellName = 13, spellSchool = 14 },
}
SUBEVENT_PREFIX_ARGS[SPELL] =           SUBEVENT_PREFIX_ARGS[RANGE]
SUBEVENT_PREFIX_ARGS[SPELL_PERIODIC] =  SUBEVENT_PREFIX_ARGS[RANGE]
SUBEVENT_PREFIX_ARGS[SPELL_BUILDING] =  SUBEVENT_PREFIX_ARGS[RANGE]
CombatEventArgsMap.SUBEVENT_PREFIX_ARGS = SUBEVENT_PREFIX_ARGS

local SUBEVENT_SUFFIX_ARGS = {
    ['_DAMAGE'] = { amount = 15, overkill = 16, school = 17, resisted = 18, blocked = 19, absorbed = 20,
        critical = 21, glancing = 22, crushing = 23, isOffHand = 24 },
    ['_MISSED'] = { missType = 15, isOffHand = 16, amountMissed = 17, critical = 18 },
    ['_HEAL'] = { amount = 15, overhealing = 16, absorbed = 17, critical = 18 },
    ['_HEAL_ABSORBED'] = { extraGUID = 15, extraName = 16, extraFlags = 17, extraRaidFlags = 18, extraSpellID = 19,
        extraSpellName = 20, extraSchool = 21, absorbedAmount = 22, totalAmount = 23 },
    --['_ABSORBED'] = {},
    ['_ENERGIZE'] = { amount = 15, overEnergize = 16, powerType = 17, maxPower = 18 },
    ['_DRAIN'] = { amount = 15, powerType = 16, extraAmount = 17, maxPower = 18 },
    ['_INTERRUPT'] = { extraSpellId = 15, extraSpellName = 16, extraSchool = 17, auraType = 18 },
    ['_EXTRA_ATTACKS'] = { amount = 15 },
    ['_AURA_APPLIED'] = { auraType = 15, amount = 16 },
    --['_CAST_START'] = {},
    --['_CAST_SUCCESS'] = {},
    ['_CAST_FAILED'] = { failedType = 15 },
    ['_INSTAKILL'] = { unconsciousOnDeath = 15 },
    --['_DURABILITY_DAMAGE'] = {},
    --['_DURABILITY_DAMAGE_ALL'] = {},
    --['_CREATE'] = {},
    --['_SUMMON'] = {},
    --['_RESURRECT'] = {},
}
SUBEVENT_SUFFIX_ARGS['_LEECH'] =                SUBEVENT_SUFFIX_ARGS['_DRAIN']
SUBEVENT_SUFFIX_ARGS['_DISPEL'] =               SUBEVENT_SUFFIX_ARGS['_INTERRUPT']
SUBEVENT_SUFFIX_ARGS['_DISPEL_FAILED'] =        SUBEVENT_SUFFIX_ARGS['_INTERRUPT']
SUBEVENT_SUFFIX_ARGS['_STOLEN'] =               SUBEVENT_SUFFIX_ARGS['_INTERRUPT']
SUBEVENT_SUFFIX_ARGS['_AURA_BROKEN_SPELL'] =    SUBEVENT_SUFFIX_ARGS['_INTERRUPT']
SUBEVENT_SUFFIX_ARGS['_AURA_REMOVED'] =         SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED']
SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED_DOSE'] =    SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED']
SUBEVENT_SUFFIX_ARGS['_AURA_REMOVED_DOSE'] =    SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED']
SUBEVENT_SUFFIX_ARGS['_AURA_REFRESH'] =         SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED']
SUBEVENT_SUFFIX_ARGS['_AURA_BROKEN'] =          SUBEVENT_SUFFIX_ARGS['_AURA_APPLIED']
CombatEventArgsMap.SUBEVENT_SUFFIX_ARGS = SUBEVENT_SUFFIX_ARGS

CombatEventArgsMap.SPECIAL_EVENTS_REUSE = {
    DAMAGE_SPLIT = { prefix = SPELL, suffix = '_DAMAGE' },
    DAMAGE_SHIELD = { prefix = SPELL, suffix = '_DAMAGE' },
    DAMAGE_SHIELD_MISSED = { prefix = SPELL, suffix = '_MISSED' },
}
local SPECIAL_EVENTS_REUSE = CombatEventArgsMap.SPECIAL_EVENTS_REUSE

CombatEventArgsMap.SPECIAL_EVENTS_NEW = {
    ENCHANT_APPLIED = { spellName = 15, itemID = 16, itemName = 17 },
    ENCHANT_REMOVED = { spellName = 15, itemID = 16, itemName = 17 },
    --PARTY_KILL = {},
    UNIT_DIED = { recapID = 15, unconsciousOnDeath = 16 },
    UNIT_DESTROYED = { recapID = 15, unconsciousOnDeath = 16 },
    UNIT_DISSIPATES = { recapID = 15, unconsciousOnDeath = 16 },
}
local SPECIAL_EVENTS_NEW = CombatEventArgsMap.SPECIAL_EVENTS_NEW

function CombatEventArgsMap:trySubeventPrefix()
    for _, sub in ipairs(SUBEVENT_PREFIXES) do
        if strfind(self.subevent, sub) then
            -- if the prefix matches, we know its standard, and the suffix should be valid
            self.prefix = sub
            self:setSubeventSuffix()
            self:mergeArgsByPrefixSuffix()
            self.subeventCategory = SUBEVENT_CATEGORIES.STANDARD
            return true
        end
    end
end

function CombatEventArgsMap:setSubeventSuffix()
    local _, iend = strfind(self.subevent, self.prefix)
    self.suffix = strsub(self.subevent, iend + 1)
end

function CombatEventArgsMap:trySpecialEventsReuse()
    local specialReuse = SPECIAL_EVENTS_REUSE[self.subevent]
    if specialReuse then
        self.prefix = specialReuse.prefix
        self.suffix = specialReuse.suffix
        self:mergeArgsByPrefixSuffix()
        self.subeventCategory = SUBEVENT_CATEGORIES.SPECIAL_EVENTS_REUSE
        return true
    end
end

function CombatEventArgsMap:mergeArgsByPrefixSuffix()
    self.flatmap:mergeMap(SUBEVENT_PREFIX_ARGS[self.prefix])
    self.flatmap:mergeMap(SUBEVENT_SUFFIX_ARGS[self.suffix])
end

function CombatEventArgsMap:trySpecialEventsNew()
    self.flatmap:mergeMap(SPECIAL_EVENTS_NEW[self.subevent])
    self.subeventCategory = SUBEVENT_CATEGORIES.SPECIAL_EVENTS_NEW
end

function CombatEventArgsMap:buildMap()
    self.flatmap = util.FlatMap:new(COMMON_ARGS)
    local found = self:trySubeventPrefix()
    found = found or self:trySpecialEventsReuse()
    found = found or self:trySpecialEventsNew()
end

