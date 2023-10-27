scope()
setModule('wow_helpers')



function GroupMembers()
    if IsInRaid() then
        local i, len = 0, GetNumGroupMembers()
        return function()
           i = i + 1
           if i <= len then
              return "raid"..i
           end
        end
    else
        local i, len = 0, GetNumSubgroupMembers()
        return function()
           i = i + 1
           if i <= len then
              return "party"..i
           end
           if i == len + 1 then
            return 'player'
           end
        end
    end
end

local membersByGuid = {}

function GetGuidData(guid)
    local memberData = membersByGuid[guid]
    if not memberData then
        memberData = {}
    end
    return memberData
end

function GetMemberData(unitId)
    local guid = UnitGUID(unitId)

    return GetGuidData(guid)
end


