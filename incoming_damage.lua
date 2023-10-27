scope()
setModule('wow_helpers')

local timeDiff = 5

local function addDamage(guid, amount)
    local data = GetGuidData(guid)
    data.damages = data.damages or {}
    local t = GetTime()
    data.damages[t] = (data.damages[t] or 0) + amount
end

function IncomingDamage(unitId)
    local data = GetMemberData(unitId)
    local damages = data.damages
    if not damages then return 0 end

    local staletimes = {}
    local sum = 0
    local t = GetTime()
    for k, v in pairs(damages) do
        if tonumber(k) > t - timeDiff then
            sum = sum + v
        else
            table.insert(staletimes, k)
        end
    end
    for _, v in ipairs(staletimes) do
        damages[v] = nil
    end
    return sum
end

wow_helpers.CombatEvent.Subscribe(function(event)
    if event.subevent == 'SPELL_ABSORBED' then
        addDamage(event:destGUID(), event:AbsorbAmount())
    end
    if event.subevent == 'SPELL_PERIODIC_DAMAGE' or event.subevent == 'SPELL_DAMAGE' or event.subevent == 'SWING_DAMAGE' or event.subevent == 'RANGE_DAMAGE' then
        local data = GetGuidData(event:destGUID())
        addDamage(event:destGUID(), event:DamageAmount())
    end
end)