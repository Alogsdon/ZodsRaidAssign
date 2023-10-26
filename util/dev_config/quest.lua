scope()
setModule('debug')

local quests = {}

Quest = function(k, fn)
    quests[k] = fn
end

CheckQuests = function()
    local passing = true
    for k, q in pairs(quests) do
        local status = q()
        if status ~= 'pass' then
            passing = false
            print('failing quest: ' .. k .. ' with status = ' .. tostring(status))
        end
    end
    if passing then print('all quests are passing') end
end

dev.leakglobal('quest_result_object', {})

