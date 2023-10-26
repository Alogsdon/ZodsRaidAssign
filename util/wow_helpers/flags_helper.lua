local bitband = bit.band

scope()
setModule('wow_helpers')

Flags = util.CreateClass({})
local Flags = Flags

function Flags.create(flags)
    if not tonumber(flags) then error('nope') end
    local flag = Flags:new()
    flag.flags = flags
    return flag
end

-- GROUP
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 1
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY or 2
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 8

function Flags:Group()
    if self:isMe() then
        return 'me'
    elseif self:isParty() then
        return 'party'
    elseif self:isGroup() then
        return 'group'
    else
        return 'outsider'
    end
end

function Flags:isMe()
    return bitband(self.flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end
function Flags:isParty()
    return bitband(self.flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0
end
function Flags:isGroup()
    return bitband(self.flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0
end
function Flags:isOutsider()
    return bitband(self.flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0
end

-- REACT
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY or 16
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE or 64

function Flags:Reaction()
    if self:isFriendly() then
        return 'friendly'
    elseif self:isHostile() then
        return 'hostile'
    else
        return 'neutral'
    end
end

function Flags:isHostile()
    return bitband(self.flags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0;
end
function Flags:isFriendly()
    return bitband(self.flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0;
end

-- OBJECT TYPE (control)
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER or 1024 -- player
local COMBATLOG_OBJECT_TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC or 2048 -- npc
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET or 4096 -- controlled, pet or MC
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN or 8192 -- not controlled, but auto attack
local COMBATLOG_OBJECT_TYPE_OBJECT = COMBATLOG_OBJECT_TYPE_OBJECT or 16384 -- this could be totems/traps

function Flags:Control()
    if self:isPlayer() then
        return 'player'
    elseif self:isNPC() then
        return 'npc'
    elseif self:isPet() then
        return 'pet'
    elseif self:isGuardian() then
        return 'guardian'
    else
        return 'object'
    end
end

function Flags:isPlayer()
    return bitband(self.flags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0;
end
function Flags:isNPC()
    return bitband(self.flags, COMBATLOG_OBJECT_TYPE_NPC) ~= 0;
end
function Flags:isPet()
    return bitband(self.flags, COMBATLOG_OBJECT_TYPE_PET) ~= 0;
end
function Flags:isGuardian()
    return bitband(self.flags, COMBATLOG_OBJECT_TYPE_GUARDIAN) ~= 0;
end
function Flags:isObject()
    return bitband(self.flags, COMBATLOG_OBJECT_TYPE_OBJECT) ~= 0;
end

