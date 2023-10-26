scope()
setModule('wow_helpers')


local function getPartyNum(unitId)
    if UnitIsUnit(unitId, 'player') then
        return 1
    else
        local partyn = string.match(unitId, "party(%d+)")
        if partyn then
            return tonumber(partyn) + 1
        end
    end
    return 1
end

local function getRaidGroupNum(member)
    local raidNum = string.match(member, "raid(%d+)")
    if raidNum then
        local n = tonumber(raidNum)
        local grp = math.ceil(n / 5)
        if grp == 0 then grp = 5 end
        local grpi = n % 5
        if grpi == 0 then grpi = 5 end
        return grp, grpi
    end
end

local function setRaidTargetArgs(args)
    local unitId = args.unitId
    if not unitId then return end

    local gpn, sgn = getRaidGroupNum(unitId)
    if gpn then
        args.isRaid = true
        args.groupNum = gpn
        args.subGroupNum = sgn
    else
        args.isRaid = false
        args.partyNum = getPartyNum(unitId)
    end
    return args
end

local function groupTypeSelect(args)
    local isRaid = args.isRaid
    if isRaid then
        return { 2 }
    else
        return { 1 }
    end
end

local function groupNumSelect(args)
    local groupNum = args.groupNum
    return { groupNum }
end

local function subGroupNumSelect(args)
    local subGroupNum = args.subGroupNum
    return { subGroupNum }
end

local function partySelect(args)
    local partyNum = args.partyNum
    return { partyNum }
end

function MakeRaidSpellMacro(key, spellName)
    local macroConfig = {
        [key] = {
            lines = {
                "/click " .. key .. "_PARTY_MB",
                "/click " .. key .. "_RAID_MB",
            },
            select = groupTypeSelect,
            args = setRaidTargetArgs
        },
        [key..'_RAID'] = {
            lines = {
                "/click " .. key .. "_RAID_1_MB",
                "/click " .. key .. "_RAID_2_MB",
                "/click " .. key .. "_RAID_3_MB",
                "/click " .. key .. "_RAID_4_MB",
                "/click " .. key .. "_RAID_5_MB",
            },
            select = groupNumSelect
        },
        [key.. '_PARTY'] = {
            lines = {
                "/cast [target=player] ".. spellName,
                "/cast [target=party1] ".. spellName,
                "/cast [target=party2] ".. spellName,
                "/cast [target=party3] ".. spellName,
                "/cast [target=party4] ".. spellName,
            },
            select = partySelect
        },
    }
    for i = 1,5 do
        macroConfig[key .. '_RAID_' .. tostring(i)] = {
            lines = {
                "/cast [target=raid" .. tostring((i-1)*5 + 1) .. "] " .. spellName,
                "/cast [target=raid" .. tostring((i-1)*5 + 2) .. "] " .. spellName,
                "/cast [target=raid" .. tostring((i-1)*5 + 3) .. "] " .. spellName,
                "/cast [target=raid" .. tostring((i-1)*5 + 4) .. "] " .. spellName,
                "/cast [target=raid" .. tostring((i-1)*5 + 5) .. "] " .. spellName,
            },
            select = subGroupNumSelect
        }
    end

    for k, config in pairs(macroConfig) do
        local sbtn = wow_helpers.SelectMacroButton.create(k .. '_MB')
        sbtn:SetLines(config.lines)
        sbtn:SetSelections(config.select)
        if config.args then
            sbtn:SetArgs(config.args)
        end
    end
    return key .. '_MB'
end
