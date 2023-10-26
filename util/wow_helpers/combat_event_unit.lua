scope()
setModule('wow_helpers')

CombatEventUnit = util.CreateClass({})
local CombatEventUnit = CombatEventUnit

function CombatEventUnit.create(guid, name, flags)
    local unit = CombatEventUnit:new()
    unit.guid = guid -- guid may be ''
    unit.name = name -- name may be nil
    unit.flags = wow_helpers.Flags.create(flags)

    return unit
end

-- bringing some flags methods forward

function CombatEventUnit:isMe()
    return self.flags:isMe()
end

function CombatEventUnit:isPlayer()
    return self.flags:isPlayer()
end

function CombatEventUnit:isPet()
    return self.flags:isPet()
end

-- 'friendly', 'hostile', 'neutral'
function CombatEventUnit:Reaction()
    return self.flags:Reaction()
end

function CombatEventUnit:isGroup()
    return self.flags:isGroup()
end


