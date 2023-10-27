scope()
setModule('wow_helpers')


local healCasts = {
    'Flash Heal',
    'Flash of Light',
    'Holy Light',
}
local function IsHealCast(spellName)
    return util.indexOf(healCasts, spellName)
end


local currentCast = {}
dev.leakglobal('currentCast', currentCast)
function UnitGetIncomingHealsFixd(member, name)
    local inc_heals = UnitGetIncomingHeals(member) or 0
    if currentCast and currentCast.target and currentCast.unitName and currentCast.amount and currentCast.amount > 0 then
        if currentCast.unitName == name then
            inc_heals = inc_heals + currentCast.amount
        end
    end
    return inc_heals
end

function SetHealTarget(unitId)
    currentCast.nextTarget = unitId
end

wow_helpers.CombatEvent.Subscribe(function(event)
    if event.subevent == 'SPELL_CAST_START' then
        if event:Source():isMe() then
            local spellName = event:spellName()
            if IsHealCast(spellName) and currentCast.nextTarget then
                local target = currentCast.nextTarget
                currentCast.unitName = UnitName(target)
                currentCast.amount = UnitGetIncomingHeals(target, 'player')
                currentCast.target = target
                currentCast.nextTarget = nil
                C_Timer.After(0.2, function()
                    currentCast.amount = UnitGetIncomingHeals(target, 'player')
                end)
            end
        end
    end
    if event.subevent == 'SPELL_CAST_SUCCESS' then
        if event:Source():isMe() then
            local spellName = event:spellName()
            if IsHealCast(spellName) then
                C_Timer.After(0.4, function()
                    if currentCast.target then
                        currentCast.target = nil
                        currentCast.amount = 0
                    end
                end)
            end
        end
    end
end)