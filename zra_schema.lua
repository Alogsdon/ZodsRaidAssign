
local addonName, ZRA = ...


--ZRA_vars.roles 
ZRA.roleschema = {
    {
        title = "Tanks",
        columns = {
            {
                header = '',
                members = {}
            },
        }
    },
    {

        title = "Healers",
        columns = {
            {
                header = 'Priest',
                members = {}
            },
            {
                header = 'Pally',
                members = {}
            },
            {
                header = 'Druid',
                members = {}
            }
        }

    },
}

ZRA.raidschema = {
    ['Onyxias Lair'] = {
        {
            name = 'Onyxia',
            { --[1]
                title = "Boss",
                columns = {
                    {
                        header = 'MT / Heals',
                        members = {}
                    },
                    {
                        header = 'OT / Heals',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        }
    },
    ['Molten Core'] = {
        {
            name = 'Trash',
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Diamond',
                columns = {
                    {
                        header = 'Banish',
                        members = {}
                    }
                }
            },
            {
                title = 'Star',
                columns = {
                    {
                        header = 'Banish',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            },
        },
        {
            name = 'Lucifron',
            {
                title = 'Boss',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    },
                }
            },
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            },
            {
                title = 'Dispels',
                columns = {
                    {
                        header = 'Magic',
                        members = {}
                    },
                    {
                        header = 'Curse',
                        members = {}
                    }
                }
            },
        },
        {
            name = 'Magmadar',
            {
            title = 'Boss',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                },
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Gehennas',
            {
            title = 'Boss',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            },
            {
                title = 'Dispels',
                columns = {
                    {
                        header = 'Curse',
                        members = {}
                    }
                }
            },
        },
        {
            name = 'Garr',
            {
            title = 'Boss',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Square',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
            {
                title = 'Moon',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
            {
                title = 'Triangle',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
            {
                title = 'Circle',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
            {
                title = 'Diamond',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
            {
                title = 'Star',
                columns = {
                    {
                        header = '',
                        members = {}
                    },
                }
            },
        },
        {
            name = 'Shazzrah',
            {
            title = 'Boss',
                columns = {
                    {
                        header = 'MT',
                        members = {}
                    },
                    {
                        header = 'MT Heals',
                        members = {}
                    },
                    {
                        header = 'OTs',
                        members = {}
                    }
                }
            },
        },
        {
            name = 'Baron',
            {
            title = 'Boss',
                columns = {
                    {
                        header = 'MT',
                        members = {}
                    },
                    {
                        header = 'MT Heals',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            },
            {
                title = 'Dispel',
                columns = {
                    {
                        header = 'Magic',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Golemagg',
            {
                title = 'Boss',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    },

                }
            },
            {
                title = 'Square',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Moon',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Sulfuron',
            {
                title = 'Boss',
                columns = {
                    {
                        header = 'Tank',
                        members = {}
                    },
                    {
                        header = 'Healers',
                        members = {}
                    },
                }
            },
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                    {
                        header = 'Kicks',
                        members = {}
                    }
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                    {
                        header = 'Kicks',
                        members = {}
                    }
                }
            },
            {
                title = 'Square',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                    {
                        header = 'Kicks',
                        members = {}
                    }
                }
            },
            {
                title = 'Moon',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                    {
                        header = 'Kicks',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Majordomo',
            {
                title = 'Domo',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Skull',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'X',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Square',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Circle',
                columns = {
                    {
                        header = 'Tank / Heal',
                        members = {}
                    },
                }
            },
            {
                title = 'Triangle',
                columns = {
                    {
                        header = 'Sheep',
                        members = {}
                    }
                }
            },
            {
                title = 'Diamond',
                columns = {
                    {
                        header = 'Sheep',
                        members = {}
                    }
                }
            },
            {
                title = 'Moon',
                columns = {
                    {
                        header = 'Sheep',
                        members = {}
                    }
                }
            },
            {
                title = 'Star',
                columns = {
                    {
                        header = 'Sheep',
                        members = {}
                    }
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Ragnaros',
            {
                title = 'Boss',
                columns = {
                    {
                        header = 'MT / Trans. Heal',
                        members = {}
                    },
                    {
                        header = 'OT / Trans. Heal',
                        members = {}
                    },
                    {
                        header = 'Aggro Heals',
                        members = {}
                    },
                }
            },
            {
                title = 'Backup',
                columns = {
                    {
                        header = 'Tanks',
                        members = {}
                    }
                }
            }
        },
        {
            name = 'Dog_Pack',
            {
                title = 'Skull',
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
            {
                title = 'X',
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
            },{
                title = 'Square',
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
            },{
                title = 'Moon',
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
            },{
                title = 'Triangle',
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
        },
    }
}


--functionsz

ZRA.funcs = {
    ['Molten Core'] = {
        Trash = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            local locks = {}
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "WARLOCK" then
                    table.insert(locks, k)
                end
            end
            for i = 1, 2 do
                ZRA_vars.raids['Molten Core'][1][i].columns[1].members = {ti()}
                ZRA_vars.raids['Molten Core'][1][i].columns[2].members = {hi()}
            end
            for i = 3, 4 do
                if #locks > 0 then
                    ZRA_vars.raids['Molten Core'][1][7 - i].columns[1].members = {table.remove(locks,#locks)}
                end
            end
            ZRA_vars.raids['Molten Core'][1][5].columns[1].members = {ti(), ti()}
        end,
        Dog_Pack = function()
            local ti = ZRA.tank_iter()
            local hi = ZRA.tank_heal_iter()
            for i = 1, 5 do
                ZRA_vars.raids['Molten Core'][12][i].columns[1].members = {ti()}
                ZRA_vars.raids['Molten Core'][12][i].columns[2].members = {hi()}
            end
        end,
        Lucifron = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            local assigned_heals = {}
            for i = 1, 3 do
                ZRA_vars.raids['Molten Core'][2][i].columns[1].members = {ti()}
                local heal = hi()
                if heal then
                    assigned_heals[heal] = true
                    ZRA_vars.raids['Molten Core'][2][i].columns[2].members = {heal}
                end
            end
            --backup tanks
            ZRA_vars.raids['Molten Core'][2][4].columns[1].members = {ti()}
            --dispels
            local magic = {}
            local curse = {}
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "PALADIN" or v.class == "PRIEST" then
                    if not assigned_heals[k] then
                        if #magic < 3 then
                            table.insert(magic, k)
                        end
                    end
                elseif v.class == "MAGE" then
                    if #curse < 4 then
                        table.insert(curse, k)
                    end
                end
            end
            ZRA_vars.raids['Molten Core'][2][5].columns[1].members = magic
            ZRA_vars.raids['Molten Core'][2][5].columns[2].members = curse
        end,
        Magmadar = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()

            ZRA_vars.raids['Molten Core'][3][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][3][1].columns[2].members = {hi(), hi(), hi()}

            ZRA_vars.raids['Molten Core'][3][2].columns[1].members = {ti(), ti()}
        end,
        Gehennas = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            local curse = {}
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "MAGE" then
                    if #curse < 4 then
                        table.insert(curse, k)
                    end
                end
            end
            ZRA_vars.raids['Molten Core'][4][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][4][1].columns[2].members = {hi(), hi()}
            for i = 2, 3 do
                ZRA_vars.raids['Molten Core'][4][i].columns[1].members = {ti()}
                ZRA_vars.raids['Molten Core'][4][i].columns[2].members = {hi()}
            end
            --backup tanks
            ZRA_vars.raids['Molten Core'][4][4].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][4][5].columns[1].members = curse
        end,
        Garr = function() 
            local locks = {}
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "WARLOCK" then
                    table.insert(locks, k)
                end
            end
            local num_banishes = min(6, #locks)
            for i = 1, num_banishes do 
                ZRA_vars.raids['Molten Core'][5][9 - num_banishes + i].columns[1].members = {locks[i]}
            end
            for i = 1, (9-num_banishes) do
                ZRA_vars.raids['Molten Core'][5][i].columns[1].members = {ti(), hi()}
            end
        end,
        Shazzrah = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            ZRA_vars.raids['Molten Core'][6][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][6][1].columns[2].members = {hi(), hi(), hi()}
            ZRA_vars.raids['Molten Core'][6][1].columns[3].members = {}
            for ot in ti do
                table.insert(ZRA_vars.raids['Molten Core'][6][1].columns[3].members, ot)
            end
        end,
        Baron = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            ZRA_vars.raids['Molten Core'][7][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][7][1].columns[2].members = {}
            local assigned_heals = {}
            for i = 1, 3 do
                local heal = hi()
                if heal then
                    assigned_heals[heal] = true
                    table.insert(ZRA_vars.raids['Molten Core'][7][1].columns[2].members, heal)
                end
            end
            --backup tanks
            ZRA_vars.raids['Molten Core'][7][2].columns[1].members = {ti(), ti()}
            --dispels
            local magic = {}
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "PALADIN" or v.class == "PRIEST" then
                    if not assigned_heals[k] then
                        if #magic < 4 then
                            table.insert(magic, k)
                        end
                    end
                end
            end
            ZRA_vars.raids['Molten Core'][7][3].columns[1].members = magic
        end,
        Golemagg = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            ZRA_vars.raids['Molten Core'][8][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][8][1].columns[2].members = {hi(), hi()}
            for i = 2, 3 do
                ZRA_vars.raids['Molten Core'][8][i].columns[1].members = {ti()}
                ZRA_vars.raids['Molten Core'][8][i].columns[2].members = {hi()}
            end
            --backup tanks
            ZRA_vars.raids['Molten Core'][8][4].columns[1].members = {ti()}
        end,
        Sulfuron = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            local ti2 = ZRA.tank_iter()
            local assigned_wars = {}
            local mages = {}
            local meleekicks = {}
            for ot in ti2 do
                assigned_wars[ot] = true
            end
            
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "MAGE" then
                    table.insert(mages, k)
                elseif v.class == "ROGUE" then
                    table.insert(meleekicks, k)
                elseif v.class == "WARRIOR" and (not assigned_wars[k]) then
                    table.insert(meleekicks, k)
                end
            end
            ZRA_vars.raids['Molten Core'][9][1].columns[1].members = {ti()}
            ZRA_vars.raids['Molten Core'][9][1].columns[2].members = {hi(), hi()}
            for i = 2, 5 do
                ZRA_vars.raids['Molten Core'][9][i].columns[1].members = {ti(), hi()}
                ZRA_vars.raids['Molten Core'][9][i].columns[2].members = {}
            end
            --backup tanks
            for i,v in ipairs(meleekicks) do
                table.insert(ZRA_vars.raids['Molten Core'][9][2 + ZRA.modulo(-i ,4)].columns[2].members, v)
            end
            for i,v in ipairs(mages) do
                table.insert(ZRA_vars.raids['Molten Core'][9][2 + ZRA.modulo(i - 1,4)].columns[2].members, v)
            end

            ZRA_vars.raids['Molten Core'][9][6].columns[1].members = ZRA.remaining(ti)
        end,
        Majordomo = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            local mages = {}
            for k,v in pairs(ZRA_vars.roster) do
                if v.class == "MAGE" then
                    table.insert(mages, k)
                end
            end
            for i = 1, 5 do
                local i_adjust = 1 + ZRA.modulo(i + 2, 5)
                ZRA_vars.raids['Molten Core'][10][i_adjust].columns[1].members = {ti(), hi()}
            end
            for i = 6, 9 do
                if #mages > 0 then
                    ZRA_vars.raids['Molten Core'][10][i].columns[1].members = {table.remove(mages,1)}
                end
            end
            --backup tanks
            ZRA_vars.raids['Molten Core'][10][10].columns[1].members = ZRA.remaining(ti)
        end,
        Ragnaros = function()
            local hi = ZRA.tank_heal_iter()
            local ti = ZRA.tank_iter()
            ZRA_vars.raids['Molten Core'][11][1].columns[3].members = {hi(), hi()}
            ZRA_vars.raids['Molten Core'][11][1].columns[1].members = {ti(), hi()}
            ZRA_vars.raids['Molten Core'][11][1].columns[2].members = {ti(), hi()}

        end,
    },
    Roles = function()
        ZRA_vars.roles[1].columns[1].members = {} --tanks
        ZRA_vars.roles[2].columns[1].members = {} -- priest
        ZRA_vars.roles[2].columns[2].members = {} -- pally
        ZRA_vars.roles[2].columns[3].members = {} -- druid
        for k,v in pairs(ZRA_vars.roster) do
            if v.class == "PALADIN" then
                table.insert(ZRA_vars.roles[2].columns[2].members, k)
            elseif v.class == "PRIEST" then
                table.insert(ZRA_vars.roles[2].columns[1].members, k)
            elseif v.class == "DRUID" then
                table.insert(ZRA_vars.roles[2].columns[3].members, k)
            elseif v.class == "WARRIOR" then
                table.insert(ZRA_vars.roles[1].columns[1].members, k)
            end
        end
    end,
    ['Onyxias Lair'] = {
        Onyxia = function() end
    }
}

ZRA.announcements = {
    ['Molten Core'] = {
        Trash = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 2 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 0 then
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                end
                local healnames = {}
                for _, vv in ipairs(v.columns[2].members) do
                    table.insert(healnames, ZRA_vars.roster[vv].name)
                end
                phrase = phrase .. ' healed by ' .. table.concat(healnames, ", ")
                table.insert(lines, phrase)
            end
            table.insert(lines, 'Backup tanks are ' .. table.concat(ZRA.codesToValsArr(rdata[5].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            table.insert(lines, "BANISHES")
            local banishes = {}
            for i = 3, 4 do
                local v = rdata[i]
                if #v.columns[1].members > 0 then
                    table.insert(banishes,  ZRA_vars.roster[v.columns[1].members[1]].name .. ' banish ' .. ZRA.shape(rdata[i].title))
                end
            end
            table.insert(lines, table.concat(banishes, ", "))
            return lines
        end,
        Dog_Pack = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 5 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 0 then
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                end
                local healnames = {}
                for _, vv in ipairs(v.columns[2].members) do
                    table.insert(healnames, ZRA_vars.roster[vv].name)
                end
                phrase = phrase .. ' healed by ' .. table.concat(healnames, ", ")
                table.insert(lines, phrase)
            end
            return lines
        end,
        Lucifron = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 3 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 0 then 
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                end
                phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", ")
                table.insert(lines, phrase)
            end
            table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[4].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            table.insert(lines, 'Magic cleansers ' .. table.concat(ZRA.codesToValsArr(rdata[5].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            table.insert(lines, 'Curse removers ' .. table.concat(ZRA.codesToValsArr(rdata[5].columns[2].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Magmadar = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local v = rdata[1]
            local phrase = ""
            if #v.columns[1].members > 0 then
                phrase = ZRA.shape(rdata[1].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
            end
            phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(rdata[1].columns[2].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines, phrase)
            table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[2].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Gehennas = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 3 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 0 then 
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                end
                phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", ")
                table.insert(lines, phrase)
            end
            table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[4].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            table.insert(lines, 'Curse removers ' .. table.concat(ZRA.codesToValsArr(rdata[5].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Garr = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local banishes = {}
            for i,v in ipairs(rdata) do
                local first_person = ZRA_vars.roster[v.columns[1].members[1]]
                if first_person and first_person.class == "WARLOCK" then
                    local phrase = first_person.name .. " banish " .. ZRA.shape(v.title)
                    table.insert(banishes, phrase)
                elseif first_person then
                    local temp = ZRA.shallowcopy(v.columns[1].members)
                    local temp2 = {}
                    local phrase = ZRA_vars.roster[table.remove(temp, 1)].name .. ' tanking ' .. ZRA.shape(v.title)
                    for _ ,vv in ipairs(temp) do
                        table.insert(temp2, ZRA_vars.roster[vv].name)
                    end
                    if #temp2 > 0 then
                        phrase = phrase .. ", healed by " .. table.concat(temp2, ", ")
                    else
                        phrase = phrase .. ", healed by *anyone*"
                    end
                    table.insert(lines, phrase)
                end
            end
            table.insert(lines,"BANISHES")
            for i,v in ipairs(ZRA.splitmess(banishes, ', ', 65)) do
                table.insert(lines, v)
            end
            return lines
        end,
        Shazzrah = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local v = rdata[1]
            local phrase = ""
            if #v.columns[1].members > 0 then 
                phrase = ZRA.shape(v.title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
            end
            phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(v.columns[2].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines, phrase)
            table.insert(lines, 'Backup tanks ' .. table.concat(ZRA.codesToValsArr(v.columns[3].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Baron = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local v = rdata[1]
            local phrase = ""
            if #v.columns[1].members > 0 then 
                phrase = ZRA.shape(v.title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
            end
            phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(v.columns[2].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines, phrase)
            if #rdata[2].columns[1].members > 0 then
                table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[2].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            end
            table.insert(lines, 'Magic cleansers ' .. table.concat(ZRA.codesToValsArr(rdata[3].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Golemagg = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 3 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 0 then 
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                end
                phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", ")
                table.insert(lines, phrase)
            end
            table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[4].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            return lines
        end,
        Sulfuron = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local v = rdata[1]
            local phrase = ""
            if #v.columns[1].members > 0 then 
                phrase = ZRA.shape(v.title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
            end
            phrase = phrase .. ' healed by ' .. table.concat(ZRA.codesToValsArr(v.columns[2].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines, phrase)
            for i = 2, 5 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 1 then 
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                    phrase = phrase .. ' healed by ' .. ZRA_vars.roster[v.columns[1].members[2]].name
                end
                table.insert(lines, phrase)
                phrase = ZRA.shape(rdata[i].title) .. ' interupts: ' .. table.concat(ZRA.codesToValsArr(rdata[i].columns[2].members, ZRA_vars.roster, 'name'), ", ")
                table.insert(lines, phrase)
            end
            if #rdata[6].columns[1].members > 0 then
                table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[6].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            end
            return lines
        end,
        Majordomo = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            for i = 1, 5 do
                local v = rdata[i]
                local phrase = ""
                if #v.columns[1].members > 1 then 
                    phrase = ZRA.shape(rdata[i].title) .. ' tanked by ' .. ZRA_vars.roster[v.columns[1].members[1]].name
                    phrase = phrase .. ' healed by ' .. ZRA_vars.roster[v.columns[1].members[2]].name
                    if v.columns[1].members[3] then phrase = phrase .. ', ' .. ZRA_vars.roster[v.columns[1].members[3]].name end
                end
                table.insert(lines, phrase)
            end
            local sheeps = {}
            for i = 6, 9 do
                local v = rdata[i]
                if #v.columns[1].members > 0 then 
                    table.insert(sheeps, ZRA_vars.roster[v.columns[1].members[1]].name .. ' sheeping ' .. ZRA.shape(rdata[i].title))
                end
            end
            table.insert(lines, "SHEEPS")
            for i ,v in ipairs(ZRA.splitmess(sheeps, ', ', 65)) do
                table.insert(lines, v)
            end
            if #rdata[10].columns[1].members > 0 then
                table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[10].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            end
            return lines
        end,
        Ragnaros = function(rdata)
            local lines = {}
            table.insert(lines, string.upper(rdata.name) .. " assignments")
            local v = rdata[1]
            local phrase = ""
            if #v.columns[1].members > 0 then 
                phrase = 'Main tank: ' .. ZRA_vars.roster[v.columns[1].members[1]].name
            end
            if #v.columns[1].members > 1 then 
                phrase = phrase .. '. MT transition healer: ' .. ZRA_vars.roster[v.columns[1].members[2]].name
            end
            table.insert(lines, phrase)

            phrase = ""
            if #v.columns[2].members > 0 then 
                phrase = 'Off tank: ' .. ZRA_vars.roster[v.columns[2].members[1]].name
            end
            if #v.columns[2].members > 1 then 
                phrase = phrase .. '. OT transition healer: ' .. ZRA_vars.roster[v.columns[2].members[2]].name
            end
            table.insert(lines, phrase)

            phrase = 'Heal the tank with aggro: ' .. table.concat(ZRA.codesToValsArr(v.columns[3].members, ZRA_vars.roster, 'name'), ", ")
            table.insert(lines, phrase)
            if #rdata[2].columns[1].members > 0 then
                table.insert(lines, 'Backup tank(s) ' .. table.concat(ZRA.codesToValsArr(rdata[2].columns[1].members, ZRA_vars.roster, 'name'), ", "))
            end
            return lines
        end,
    }
}


ZRA.testroster1 = {
    ["a"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Scottyflip",
        ["raidNum"] = 0,
    },
    ["c"] = {
        ["class"] = "DRUID",
        ["name"] = "Sprb",
        ["raidNum"] = 0,
    },
    ["b"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Kalleia",
        ["raidNum"] = 0,
    },
    ["e"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Dkd",
        ["raidNum"] = 0,
    },
    ["d"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Door",
        ["raidNum"] = 0,
    },
    ["g"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Stuot",
        ["raidNum"] = 0,
    },
    ["f"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Zodicus",
        ["raidNum"] = 0,
    },
    ["i"] = {
        ["class"] = "ROGUE",
        ["name"] = "Indomitable",
        ["raidNum"] = 0,
    },
    ["h"] = {
        ["class"] = "ROGUE",
        ["name"] = "Appolyin",
        ["raidNum"] = 0,
    },
    ["k"] = {
        ["class"] = "ROGUE",
        ["name"] = "Irishdrunk",
        ["raidNum"] = 0,
    },
    ["j"] = {
        ["class"] = "ROGUE",
        ["name"] = "Marvelous",
        ["raidNum"] = 0,
    },
    ["m"] = {
        ["class"] = "ROGUE",
        ["name"] = "Noldori",
        ["raidNum"] = 0,
    },
    ["l"] = {
        ["class"] = "ROGUE",
        ["name"] = "Duncanldaho",
        ["raidNum"] = 0,
    },
    ["o"] = {
        ["class"] = "HUNTER",
        ["name"] = "Khanitus",
        ["raidNum"] = 0,
    },
    ["n"] = {
        ["class"] = "ROGUE",
        ["name"] = "Nottoxic",
        ["raidNum"] = 0,
    },
    ["q"] = {
        ["class"] = "HUNTER",
        ["name"] = "Garmden",
        ["raidNum"] = 0,
    },
    ["p"] = {
        ["class"] = "HUNTER",
        ["name"] = "Sylrendas",
        ["raidNum"] = 0,
    },
    ["s"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Thordi",
        ["raidNum"] = 0,
    },
    ["r"] = {
        ["class"] = "HUNTER",
        ["name"] = "Plebos",
        ["raidNum"] = 0,
    },
    ["u"] = {
        ["class"] = "WARLOCK",
        ["name"] = "ßæns",
        ["raidNum"] = 0,
    },
    ["t"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Imadottin",
        ["raidNum"] = 0,
    },
    ["w"] = {
        ["class"] = "MAGE",
        ["name"] = "Mista",
        ["raidNum"] = 0,
    },
    ["v"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Jeshuah",
        ["raidNum"] = 0,
    },
    ["y"] = {
        ["class"] = "MAGE",
        ["name"] = "Digger",
        ["raidNum"] = 0,
    },
    ["x"] = {
        ["class"] = "MAGE",
        ["name"] = "Ssxtricky",
        ["raidNum"] = 0,
    },
    ["A"] = {
        ["class"] = "MAGE",
        ["name"] = "Phifey",
        ["raidNum"] = 0,
    },
    ["C"] = {
        ["class"] = "MAGE",
        ["name"] = "Keen",
        ["raidNum"] = 0,
    },
    ["B"] = {
        ["class"] = "MAGE",
        ["name"] = "Zookvicious",
        ["raidNum"] = 0,
    },
    ["E"] = {
        ["class"] = "PALADIN",
        ["name"] = "Aegis",
        ["raidNum"] = 0,
    },
    ["D"] = {
        ["class"] = "MAGE",
        ["name"] = "Kilyra",
        ["raidNum"] = 0,
    },
    ["G"] = {
        ["class"] = "PALADIN",
        ["name"] = "Ganklin",
        ["raidNum"] = 0,
    },
    ["F"] = {
        ["class"] = "PALADIN",
        ["name"] = "Horizons",
        ["raidNum"] = 0,
    },
    ["I"] = {
        ["class"] = "DRUID",
        ["name"] = "Sizequeens",
        ["raidNum"] = 0,
    },
    ["H"] = {
        ["class"] = "DRUID",
        ["name"] = "Twomanydabs",
        ["raidNum"] = 0,
    },
    ["K"] = {
        ["class"] = "DRUID",
        ["name"] = "Sprb",
        ["raidNum"] = 0,
    },
    ["J"] = {
        ["class"] = "DRUID",
        ["name"] = "Edoor",
        ["raidNum"] = 0,
    },
    ["M"] = {
        ["class"] = "PRIEST",
        ["name"] = "Uyscuti",
        ["raidNum"] = 0,
    },
    ["L"] = {
        ["class"] = "PRIEST",
        ["name"] = "Brendaniel",
        ["raidNum"] = 0,
    },
    ["N"] = {
        ["class"] = "PRIEST",
        ["name"] = "Sloanz",
        ["raidNum"] = 0,
    },
}

ZRA.testroster2 = {
    ["a"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Scottyflip",
        ["raidNum"] = 0,
    },
    ["c"] = {
        ["class"] = "DRUID",
        ["name"] = "Sprb",
        ["raidNum"] = 0,
    },
    ["b"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Kalleia",
        ["raidNum"] = 0,
    },
    ["e"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Dkd",
        ["raidNum"] = 0,
    },
    ["d"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Door",
        ["raidNum"] = 0,
    },
    ["g"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Zodicus",
        ["raidNum"] = 0,
    },
    ["f"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Badtank",
        ["raidNum"] = 0,
    },
    ["i"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Stuot",
        ["raidNum"] = 0,
    },
    ["h"] = {
        ["class"] = "WARRIOR",
        ["name"] = "Bde",
        ["raidNum"] = 0,
    },
    ["k"] = {
        ["class"] = "ROGUE",
        ["name"] = "Indomitable",
        ["raidNum"] = 0,
    },
    ["j"] = {
        ["class"] = "ROGUE",
        ["name"] = "Appolyin",
        ["raidNum"] = 0,
    },
    ["m"] = {
        ["class"] = "ROGUE",
        ["name"] = "Irishdrunk",
        ["raidNum"] = 0,
    },
    ["l"] = {
        ["class"] = "ROGUE",
        ["name"] = "Marvelous",
        ["raidNum"] = 0,
    },
    ["o"] = {
        ["class"] = "ROGUE",
        ["name"] = "Noldori",
        ["raidNum"] = 0,
    },
    ["n"] = {
        ["class"] = "ROGUE",
        ["name"] = "Duncanldaho",
        ["raidNum"] = 0,
    },
    ["q"] = {
        ["class"] = "HUNTER",
        ["name"] = "Khanitus",
        ["raidNum"] = 0,
    },
    ["p"] = {
        ["class"] = "ROGUE",
        ["name"] = "Nottoxic",
        ["raidNum"] = 0,
    },
    ["s"] = {
        ["class"] = "HUNTER",
        ["name"] = "Garmden",
        ["raidNum"] = 0,
    },
    ["r"] = {
        ["class"] = "HUNTER",
        ["name"] = "Sylrendas",
        ["raidNum"] = 0,
    },
    ["u"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Thordi",
        ["raidNum"] = 0,
    },
    ["t"] = {
        ["class"] = "HUNTER",
        ["name"] = "Plebos",
        ["raidNum"] = 0,
    },
    ["w"] = {
        ["class"] = "WARLOCK",
        ["name"] = "ßæns",
        ["raidNum"] = 0,
    },
    ["v"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Imadottin",
        ["raidNum"] = 0,
    },
    ["y"] = {
        ["class"] = "MAGE",
        ["name"] = "Mista",
        ["raidNum"] = 0,
    },
    ["x"] = {
        ["class"] = "WARLOCK",
        ["name"] = "Jeshuah",
        ["raidNum"] = 0,
    },
    ["A"] = {
        ["class"] = "MAGE",
        ["name"] = "Ssxtricky",
        ["raidNum"] = 0,
    },
    ["C"] = {
        ["class"] = "MAGE",
        ["name"] = "Phifey",
        ["raidNum"] = 0,
    },
    ["B"] = {
        ["class"] = "MAGE",
        ["name"] = "Digger",
        ["raidNum"] = 0,
    },
    ["E"] = {
        ["class"] = "MAGE",
        ["name"] = "Keen",
        ["raidNum"] = 0,
    },
    ["D"] = {
        ["class"] = "MAGE",
        ["name"] = "Zookvicious",
        ["raidNum"] = 0,
    },
    ["G"] = {
        ["class"] = "MAGE",
        ["name"] = "Dwonder",
        ["raidNum"] = 0,
    },
    ["F"] = {
        ["class"] = "MAGE",
        ["name"] = "Kilyra",
        ["raidNum"] = 0,
    },
    ["I"] = {
        ["class"] = "PALADIN",
        ["name"] = "Horizons",
        ["raidNum"] = 0,
    },
    ["H"] = {
        ["class"] = "PALADIN",
        ["name"] = "Aegis",
        ["raidNum"] = 0,
    },
    ["K"] = {
        ["class"] = "PALADIN",
        ["name"] = "Brecon",
        ["raidNum"] = 0,
    },
    ["J"] = {
        ["class"] = "PALADIN",
        ["name"] = "Ganklin",
        ["raidNum"] = 0,
    },
    ["M"] = {
        ["class"] = "PALADIN",
        ["name"] = "Astraea",
        ["raidNum"] = 0,
    },
    ["L"] = {
        ["class"] = "PALADIN",
        ["name"] = "Xeniko",
        ["raidNum"] = 0,
    },
    ["O"] = {
        ["class"] = "DRUID",
        ["name"] = "Edoor",
        ["raidNum"] = 0,
    },
    ["N"] = {
        ["class"] = "DRUID",
        ["name"] = "Twomanydabs",
        ["raidNum"] = 0,
    },
    ["Q"] = {
        ["class"] = "PRIEST",
        ["name"] = "Brendaniel",
        ["raidNum"] = 0,
    },
    ["P"] = {
        ["class"] = "DRUID",
        ["name"] = "Sizequeens",
        ["raidNum"] = 0,
    },
    ["S"] = {
        ["class"] = "PRIEST",
        ["name"] = "Sloanz",
        ["raidNum"] = 0,
    },
    ["R"] = {
        ["class"] = "PRIEST",
        ["name"] = "Hp",
        ["raidNum"] = 0,
    },
}