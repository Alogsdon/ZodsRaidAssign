
local addonName, ZRA = ...


local BWL = 'Blackwing Lair'

ZRA.raidschema[BWL] = {
    {
        name = 'Razorgore',
        { --[1]
            title = "North",
            columns = {
                {
                    header = 'Tank(s)',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[2]
            title = "East",
            columns = {
                {
                    header = 'Tank(s)',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[3]
            title = "South",
            columns = {
                {
                    header = 'Tank(s)',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[4]
            title = "West",
            columns = {
                {
                    header = 'Tank(s)',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
    },
    {
        name = 'Vaelastrasz',
        { --[1]
            title = "Tanks",
            columns = {
                {
                    header = '',
                    members = {}
                },
            }
        },
        { --[2]
            title = "Healing",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'Melee',
                    members = {}
                },
                {
                    header = 'Raid',
                    members = {}
                },
            }
        },
    },
    {
        name = 'Broodlord',
        { --[1]
            title = "Tanks",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'OTs',
                    members = {}
                }
            }
        },
        { --[1]
            title = "Healing",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'Raid',
                    members = {}
                },
                {
                    header = 'bubble duty',
                    members = {}
                }
            }
        },
    },
    {
        name = 'Firemaw',
        { --[1]
            title = "Tanks",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'OTs',
                    members = {}
                }
            }
        },
        { --[2]
            title = "Healing",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'Melee/OTs',
                    members = {}
                },
                {
                    header = 'Raid',
                    members = {}
                }
            }
        },
    },
    {
        name = 'Flamegor',
        { --[1]
            title = "Tank 1",
            columns = {
                {
                    header = 'Tank',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[2]
            title = "Tank 2",
            columns = {
                {
                    header = 'Tank',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[3]
            title = "Tank 3",
            columns = {
                {
                    header = 'Tank',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[4]
            title = "Raid Heals",
            columns = {
                {
                    header = '',
                    members = {}
                },
            }
        },
    },
    {
        name = 'Chromaggus',
        { --[1]
            title = "Tanks",
            columns = {
                {
                    header = '',
                    members = {}
                },
            }
        },
        { --[2]
            title = "Healing",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'Melee',
                    members = {}
                },
                {
                    header = 'Raid',
                    members = {}
                },
            }
        },
    },
    {
        name = 'Nefarian',
        { --[1]
            title = "Boss",
            columns = {
                {
                    header = 'MT',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[2]
            title = "North Side",
            columns = {
                {
                    header = 'Tanks',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        },
        { --[3]
            title = "South Side",
            columns = {
                {
                    header = 'Tanks',
                    members = {}
                },
                {
                    header = 'Heals',
                    members = {}
                }
            }
        }
    },
}

ZRA.funcs[BWL] = {
    Razorgore = function()
    end,
    Vaelastrasz = function()
    end,
    Broodlord = function()
    end,
    Firemaw = function()
    end,
    Flamegor = function()
    end,
    Chromaggus = function()
    end,
    Nefarian = function()
    end,
}

ZRA.announcements[BWL] = {
    Razorgore = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        for i = 1, 4 do
            table.insert(lines, string.upper(rdata[i].title))
            table.insert(lines, 'Tank(s)' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            table.insert(lines, 'Heals' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", "))
        end
        return lines
    end,
    Vaelastrasz = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        table.insert(lines, "TANKS")
        local tanks = ZRA.shallowcopy(rdata[1].columns[1].members)
        table.insert(lines,   "MT is " .. ZRA_vars.roster[tanks[1]].name)
        table.remove(tanks, 1)
        table.insert(lines,   "Backup tanks are " .. table.concat(ZRA.codesToValsArr(tanks, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines, "HEALING")
        for i = 1, 3 do
            table.insert(lines,  rdata[2].columns[i].header .. " heals: " .. table.concat(ZRA.codesToValsArr(rdata[2].columns[i].members, ZRA_vars.roster, 'name'), ", "))
        end
        return lines
    end,
    Broodlord = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        table.insert(lines, "TANKS")
        table.insert(lines,   "MT is " .. table.concat(ZRA.codesToValsArr(rdata[1].columns[1].members, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines,   "Backup tanks are " .. table.concat(ZRA.codesToValsArr(rdata[1].columns[2].members, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines, "HEALING")
        for i = 1, 2 do
            table.insert(lines,  rdata[2].columns[i].header .. " heals: " .. table.concat(ZRA.codesToValsArr(rdata[2].columns[i].members, ZRA_vars.roster, 'name'), ", "))
        end
        table.insert(lines,  "Bubble duty: " .. table.concat(ZRA.codesToValsArr(rdata[2].columns[3].members, ZRA_vars.roster, 'name'), ", "))
        return lines
    end,
    Firemaw = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        table.insert(lines, "TANKS")
        table.insert(lines,   "MT is " .. table.concat(ZRA.codesToValsArr(rdata[1].columns[1].members, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines,   "Off-tanks are " .. table.concat(ZRA.codesToValsArr(rdata[1].columns[2].members, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines, "HEALING")
        for i = 1, 3 do
            table.insert(lines,  rdata[2].columns[i].header .. " heals: " .. table.concat(ZRA.codesToValsArr(rdata[2].columns[i].members, ZRA_vars.roster, 'name'), ", "))
        end
        return lines
    end,
    Flamegor = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        for i = 1, 3 do
            local ln = ''
            ln = ln .. "Tank " .. tostring(i) ..": "..  table.concat(ZRA.codesToValsArr(rdata[i].columns[1].members, ZRA_vars.roster, 'name'), ", ")
            ln = ln .. " <- healed by " .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines,  ln)
        end
        table.insert(lines,  "Raid heals: " .. table.concat(ZRA.codesToValsArr(rdata[4].columns[1].members, ZRA_vars.roster, 'name'), ", "))
        return lines
    end,
    Chromaggus = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        table.insert(lines, "TANKS")
        local tanks = ZRA.shallowcopy(rdata[1].columns[1].members)
        table.insert(lines,   "MT is " .. ZRA_vars.roster[tanks[1]].name)
        table.remove(tanks, 1)
        table.insert(lines,   "Backup tanks are " .. table.concat(ZRA.codesToValsArr(tanks, ZRA_vars.roster, 'name'), ", "))
        table.insert(lines, "HEALING")
        for i = 1, 3 do
            table.insert(lines,  rdata[2].columns[i].header .. " heals/dispels: " .. table.concat(ZRA.codesToValsArr(rdata[2].columns[i].members, ZRA_vars.roster, 'name'), ", "))
        end
        return lines
    end,
    Nefarian = function(rdata)
        local lines = {}
        table.insert(lines, string.upper(rdata.name) .. " assignments")
        local tanks = ZRA.shallowcopy(rdata[1].columns[1].members)
        table.insert(lines,   "MT is " .. ZRA_vars.roster[tanks[1]].name)
        table.insert(lines,   "Dedicated MT heals: " ..  table.concat(ZRA.codesToValsArr(rdata[1].columns[2].members, ZRA_vars.roster, 'name'), ", "))
        for i = 2, 3 do
            table.insert(lines, string.upper(rdata[i].title))
            for j = 1, 2 do
                table.insert(lines,  rdata[i].columns[j].header .. ": " .. table.concat(ZRA.codesToValsArr(rdata[i].columns[j].members, ZRA_vars.roster, 'name'), ", "))
            end
        end
        return lines
    end,
}