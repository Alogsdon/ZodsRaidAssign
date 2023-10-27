scope()
setModule('wow_helpers')

local spells = {
    [17] =   "44",
    [592] =   "88",
    [600] =  "158",
    [3747] =  "234",
    [6065] =  "301",
    [6066] =  "381",
    [10898] =  "484",
    [10899] =  "605",
    [10900] =  "763",
    [10901] =  "942",
    [25217] = "1125",
    [25218] = "1265",
    [48065] = "1920",
    [48066] = "2230"
}


function MaxPowerWordShieldAmount(spellId)
    -- (Base+(SP*(coeff+BT))) * (1+TD) * (1+FP) * (1+IPWS)
    local base = spells[spellId]
    local spellPower = GetSpellBonusHealing(2)
    local coeff = 0.8068
    local BT = 0.08 * select(5, GetTalentInfo(1,14))
    local TD = 0.01 * select(5, GetTalentInfo(1,25))
    local FP = 0.02 * select(5, GetTalentInfo(1,16))
    local IPWS = 0.05 * select(5, GetTalentInfo(1,5))

    return (base + (spellPower * (coeff + BT))) * (1 + TD) * (1 + FP) * (1 + IPWS)
end

function CurrentShieldAmount(unitId)
    local data = GetMemberData(unitId)
    return data.shieldAmount or 0
end


wow_helpers.CombatEvent.Subscribe(function(event)
    if event.subevent == 'SPELL_CAST_SUCCESS' and event:Source():isMe() and event:spellName() == 'Power Word: Shield' then
        local shieldAmount = MaxPowerWordShieldAmount(event:spellId())
        local data = GetGuidData(event:destGUID())
        data.shieldAmount = shieldAmount
    end
    if event.subevent == 'SPELL_ABSORBED' then
        local data = GetGuidData(event:destGUID())
        if data.shieldAmount then
            data.shieldAmount = data.shieldAmount - event:AbsorbAmount()
        end
    end
end)

