local CreateFrame = CreateFrame
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
--local CombatLogGetCurrentEventInfo = function()
--   return 1617986113.264, "SPELL_DAMAGE", false, "Player-1096-06DF65C1", "Xiaohuli", 1297, 0, "Creature-0-4253-0-160-94-000070569B", "Cutpurse", 68168, 0, 585, "Smite", 2, 47, 19, 2, nil, nil, nil, false, false, false, false
--end

local pairs = pairs

scope()
setModule('wow_helpers')

CombatEvent = util.CreateClass({})
local CombatEvent = CombatEvent

-- ############  STATIC API METHODS  ############

function CombatEvent.Subscribe(callback)
    local sub = {
        callback = callback
    }
    CombatEvent._register()
    CombatEvent.subscribers[sub] = true
    local unsub = function()
        CombatEvent.subscribers[sub] = nil
    end
    return unsub
end

-- ############  CombatEvent CLASS METHODS  ############

function CombatEvent:asMap()
    local collector = {}
    for k in self.argmap:keyIter() do
        collector[k] = self:readArg(k)
    end
    return collector
end

function CombatEvent:isCastSuccess()
    return self.subevent == 'SPELL_CAST_SUCCESS'
end

function CombatEvent:isCastStart()
    return self.subevent == 'SPELL_CAST_START'
end

function CombatEvent:isAuraTouch()
    return self.subevent == 'SPELL_AURA_REFRESH' or self.subevent == 'SPELL_AURA_APPLIED'
end

function CombatEvent:spellName()
    return self:readArg('spellName')
end

function CombatEvent:spellId()
    return self:readArg('spellId')
end

function CombatEvent:destGUID()
    return self:readArg('destGUID')
end

function CombatEvent:destName()
    return self:readArg('destName')
end

function CombatEvent:readArg(key)
    local ind = self.argmap:getInd(key)
    if ind then
        return self.args[ind]
    end
end

function CombatEvent:Source()
    if self.source then return self.source end

    self.source = wow_helpers.CombatEventUnit.create(self:SourceArgs())
    return self.source
end

function CombatEvent:SourceArgs()
    return self.args[4], self.args[5], self.args[6]
end

function CombatEvent:Dest()
    if self.dest then return self.dest end

    self.dest = wow_helpers.CombatEventUnit.create(self:DestArgs())
    return self.dest
end

function CombatEvent:AbsorbAmount()
    -- good job blizzard. 20+ positional arguments. AND YOU MAKE THREE IN THE MIDDLE OPTIONAL!?!?? dumb as hell
    if self.subevent == 'SPELL_ABSORBED' then
        return self.args[22] or self.args[19]
    else
        return 0
    end
end

function CombatEvent:DamageAmount()
    return self.args[15] or self.args[12]
end

function CombatEvent:DestArgs()
    return self.args[8], self.args[9], self.args[10]
end

-- ############  STATIC VARIABLES  ############

CombatEvent.subscribers = {}
CombatEvent.scriptFrame = nil

-- ############  CLEU ARGS LOGIC (almost enough logic to make its own class)  ############


-- ############  PRIVATE METHODS  ############

function CombatEvent.create()
    local ce = CombatEvent:new()
    ce.args = CombatEvent.getCurrentArgs()
    ce.subevent = ce.args[2]
    ce.argmap = wow_helpers.CombatEventArgsMap.create(ce.subevent)
    return ce
end

-- I made this method mostly because stubbing CombatLogGetCurrentEventInfo wasnt working
function CombatEvent.getCurrentArgs()
    return { CombatLogGetCurrentEventInfo() }
end

function CombatEvent.CLEU()
    local ce = CombatEvent.create()
    for sub in pairs(CombatEvent.subscribers) do
        if sub.callback then
            sub.callback(ce)
        end
    end
end

function CombatEvent._register()
    if CombatEvent.scriptFrame then return end

    local f = CreateFrame("Frame")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:SetScript("OnEvent", CombatEvent.CLEU)
    CombatEvent.scriptFrame = f
end

local function argStub()
    return { 1617986113.264, "SPELL_DAMAGE", false, "Player-1096-06DF65C1", "Xiaohuli", 1297, 0,
        "Creature-0-4253-0-160-94-000070569B", "Cutpurse", 68168, 0, 585, "Smite", 2, 47, 19, 2, nil, nil, nil, false,
        false, false, false }
end

function spec.Tests:CombatEventTest()
    spec.Replace(CombatEvent, 'getCurrentArgs', argStub)
    local ce = CombatEvent.create()
    spec.AreEqual(ce:isCastSuccess(), false)
    spec.AreEqual(ce:spellName(), 'Smite')
    spec.AreEqual(ce:Source():isMe(), true)
    spec.AreEqual(ce:Source():isPlayer(), true)
    spec.AreEqual(ce:Dest():Reaction(), 'hostile')
end

function spec.Tests:CombatEventSubscriberTest()
    spec.Replace(CombatEvent, 'getCurrentArgs', argStub)
    local ce
    wow_helpers.CombatEvent.Subscribe(function(event)
        ce = event
    end)
    CombatEvent.CLEU()
    spec.AreEqual(ce:isCastSuccess(), false)
    spec.AreEqual(ce:spellName(), 'Smite')
    spec.AreEqual(ce:Source():isMe(), true)
    spec.AreEqual(ce:Source():isPlayer(), true)
end
