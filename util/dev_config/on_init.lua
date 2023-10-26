scope()
setModule('dev')

local addonName = AddonName
local LibStub = LibStub
local type = type
local After = C_Timer.After

local _hookAttaches = {}
function hookInit(func, delay)
    table.insert(_hookAttaches, function()
        local Addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
        -- idk. sometimes self (Addon) is referenced in these. After doesn't let me pass args
        local closureAddon = function()
            func(Addon)
        end
        local withDelay
        -- wrap in delay
        if delay then
            withDelay = function()
                After(delay, closureAddon)
            end
        else
            withDelay = closureAddon
        end
        -- hook after old
        local init
        local oldInit = Addon.OnInitialize
        if oldInit and type(oldInit) == "function" then
            init = function(Addon)
                oldInit(Addon)
                withDelay()
            end
        else
            init = withDelay
        end
        Addon.OnInitialize = init
    end)

end

function attachHooks()
    for _, value in ipairs(_hookAttaches) do
        value()
    end
end

