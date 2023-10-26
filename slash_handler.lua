
local AddonName = ...
scope()

_G["SLASH_" .. AddonName .. "1"] = '/zu'

SlashCmdList[AddonName] = function(msg)
    if msg == 'q' then
        debug.CheckQuests()
    else
        debug.tinspect(ZodsRaidAssign)
    end
end

_G["SLASH_RELOADS1"] = '/rl'

SlashCmdList['RELOADS'] = function(msg)
    ReloadUI();
end

