scope()
setModule('wow_helpers')

local classes

local function getPrio(member_data)
    local prio = 0
    if member_data.ratio < 0.98 then
        prio = prio + 100 + (1 - member_data.ratio) * 50
    end
    if member_data.ratio < 0.2 then
        prio = prio + 100 + (1 - member_data.ratio) * 50
    end
    if member_data.ratio < 0.5 then
        prio = prio + 100 + (1 - member_data.ratio) * 50
    end
    if member_data.ratio < 0.8 then
        prio = prio + 100 + (1 - member_data.ratio) * 50
    end
    if member_data.role == 'TANK' or member_data.id == 'player' then
        prio = prio * 2
    end
    if not member_data.in_range then prio = -1 end

    return prio
end

local function GetRaidDifficulty()
    local name, groupType, isHeroic = GetDifficultyInfo(GetRaidDifficultyID()) -- '25 Player' , 'raid', false
    return name, groupType, isHeroic
end

local function getRaidHealPrios()
    local myclass = UnitClass('player')

    local maxShield
    if myclass == 'Priest' then
        --maxShield = MaxPowerWordShieldAmount(10901) -- update with max when you level
        maxShield = MaxPowerWordShieldAmount(48066)
    end

    local rangeChecker = classes[myclass].rangeChecker
    local members = {}
    local dungeonDamage = 3000
    if GetNumGroupMembers() > 5 then
        local difficulty = GetRaidDifficulty()
        dungeonDamage = dungeonDamage + (({
            ['10 Player'] = 5000,
            ['10 Player (Heroic)'] = 10000,
            ['25 Player'] = 10000,
            ['25 Player (Heroic)'] = 20000,
        })[difficulty] or 0)
    end

    for member in GroupMembers() do
        local name = UnitName(member)
        local id = member
        if name == UnitName('player') then
            id = 'player'
        end
        local role = UnitGroupRolesAssigned(member) --=> 'DAMAGER' 'HEALER' 'TANK'
        local inc_damage = IncomingDamage(member)
        if role == 'TANK' then
            local enemyId = member..'target'
            if (UnitReaction(enemyId, 'player') or 5) < 3 then
                if (UnitThreatSituation(member, enemyId) or 0) > 1 then
                    inc_damage = inc_damage + dungeonDamage
                end
            end
        end

        local inc_heals = UnitGetIncomingHealsFixd(member, name)
        local in_range = IsSpellInRange(rangeChecker, member)
        in_range = (in_range and in_range > 0) and true or false
        local max_hp = UnitHealthMax(member) or 100
        local current_hp = UnitHealth(member) or 0
        local next_hp = math.min(current_hp + math.min(inc_heals, max_hp * 0.1), max_hp)
        local deficit = max_hp - next_hp + inc_damage
        local ratio = next_hp / max_hp
        local member_data = { role = role, deficit = deficit, name = name, ratio = ratio, id = member, in_range = in_range }
        member_data.prio = getPrio(member_data)
        if myclass == 'Priest' then
            local weakend =  AuraUtil.FindAuraByName('Weakened Soul', member, 'HARMFUL')
            if not weakend then
                member_data.shieldable = true
            else
                member_data.shieldable = false
            end
            member_data.shield = CurrentShieldAmount(member)
            member_data.shieldRatio = member_data.shield / maxShield
        end
        if member_data.prio >= 0 and current_hp > 1 and (UnitReaction(member, 'player') or 0) > 3 then
            table.insert(members, member_data)
        end
    end
    table.sort(members, function(a, b) return a.prio > b.prio end)
    return members
end


local function getPriestHealAction()
    local members = getRaidHealPrios()
    local member = members[1]
    if member and member.deficit > 200 then
        local amount = member.deficit
        if amount > 1500 then
            if (GetSpellCooldown('Penance') or -1) == 0 then
                return { unitId = member.id, spell = 'PENANCE' }
            end
        end
        return { unitId = member.id, spell = 'FLASH_HEAL' }
    end
end

local function getPriestShieldAction()
    local members = getRaidHealPrios()
    for _, member in ipairs(members) do
        if member.shieldable and member.shieldRatio < 0.2 then
            return { unitId = member.id, spell = 'POWER_WORD_SHIELD' }
        end
    end
end


local function getPaladinHealAction(amount)
    if amount > 7000 then
        return 'HOLY_LIGHT'
    end
    if amount > 4000 then
        local hs_cd = GetSpellCooldown('Holy Shock')
        if hs_cd == 0 then
            return 'HOLY_SHOCK'
        end
    end

    if amount > 200 then
        return 'FLASH_OF_LIGHT'
    end
end

local function paladinHeal()
    local members = getRaidHealPrios()
    if members[1] then
        local action =  getPaladinHealAction(members[1].deficit)
        if not action then return end

        local beacon = AuraUtil.FindAuraByName(GetSpellInfo(53563), members[1].id, 'PLAYER')
        if beacon then
            if members[2] then
                if action == 'FLASH_OF_LIGHT' and members[2].deficit < 2000 then
                    return { unitId = members[1].id, spell = action }
                end
                return { unitId = members[2].id, spell = action }
            end
        end
        return { unitId = members[1].id, spell = action }
    end
end


classes = {
    Priest = {
        rangeChecker = 'Flash Heal',
        buttons = {
            SHIELD = getPriestShieldAction,
            HEAL = getPriestHealAction
        },
        spells = {
            POWER_WORD_SHIELD = 'Power Word: Shield',
            PENANCE = 'Penance',
            FLASH_HEAL = 'Flash Heal',
        },
        watchedAuras = {
            'Power Word: Shield',
            'Weakened Soul'
        }
    },
    Paladin = {
        rangeChecker = 'Flash of Light',
        buttons = {
            HEAL = paladinHeal
        },
        spells = {
            HOLY_LIGHT = 'Holy Light',
            HOLY_SHOCK = 'Holy Shock',
            FLASH_OF_LIGHT = 'Flash of Light',
        },
        watchedAuras = {
            'Beacon of Light',
        }
    }
}

local module = classes[UnitClass('player')]
if module then
    local macros = {}
    local macroLines = {}
    for key, spellName in pairs(module.spells) do
        local btnName = wow_helpers.MakeRaidSpellMacro(key, spellName)
        table.insert(macroLines, '/click ' .. btnName)
        macros[key] = #macroLines
    end

    for key, func in pairs(module.buttons) do
        local btn
        btn = wow_helpers.SelectMacroButton.create(key .. '_BTN')
        btn:SetLines(macroLines)
        btn:SetSelections(function(args)
            if UnitChannelInfo('player') or UnitCastingInfo('player') then return {} end
            SetHealTarget(args.spell)
            return { macros[args.spell] }
        end)
        btn:SetArgs(func)
    end


end

local cached = {}
local expodite = 0
local valid = true
local function GetSuggestAction(key)
    local func = module.buttons[key]
    if not func then return end

    expodite = 0
    local result = func()
    cached[key] = { updatedAt = GetTime() }
    cached[key].result = result
    return result
end

local function CheckSuggestAction(key)
    if not valid then
        return GetSuggestAction(key)
    end
    local t = GetTime()
    local lastUpdate = cached[key] and cached[key].updatedAt or 0
    if lastUpdate < t - 1 + expodite then
        return GetSuggestAction(key)
    else
        return cached[key].result
    end
end

exports.GetSuggestAction = GetSuggestAction
exports.CheckSuggestAction = CheckSuggestAction

local watchedAuras = module and module.watchedAuras or {}
wow_helpers.CombatEvent.Subscribe(function(event)
    if event.subevent == 'SPELL_AURA_REMOVED' or event.subevent == 'SPELL_AURA_APPLIED' then
        local spellName = event:spellName()
        if util.indexOf(watchedAuras, spellName) then
            valid = false
        end
    end
    if event.subevent == 'SPELL_ABSORBED' or event.subevent == 'SPELL_DAMAGE' or event.subevent == 'SWING_DAMAGE' then
        local amount
        if event.subevent == 'SPELL_ABSORBED' then
            amount = event:AbsorbAmount()
        else
            amount = event:DamageAmount()
        end
        local maxHp = UnitHealthMax(event:destName()) or 10000
        local ratio = amount / maxHp
        if ratio > 0.1 then
            valid = false
        elseif ratio > 0.02 then
            expodite = expodite + 0.25
        end
    end
end)
