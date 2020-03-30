
local addonName, ZRA = ...

function ZRA.onUpdate()

end

function ZRA.assignmentsModified(raid, boss, initiator)
	raid = raid or 'none'
	boss = boss or 0
	--just a function to hook into
	print('assignments modified by ' .. initiator .. " raid: " .. raid .. " boss: " .. boss)
end

function ZRA.rosterModified(initiator)
	print('roster modified by ' .. initiator)
	--hook into
end

function ZRA.onLoad()
	ZRA.CODES = {}
	ZRA.LETTER_MAP = {}
	ZRA.CLASS_MAP = {
		["WARLOCK"] = 1,
		["WARRIOR"] = 2,
		["PALADIN"] = 3,
		["PRIEST"] = 4,
		["DRUID"] = 5,
		["MAGE"] = 6,
		["ROGUE"] = 7,
		["HUNTER"] = 8,
		["SHAMAN"] = 9,
	}
	ZRA.CLASS_MAP_BACK = {}
	for k,v in pairs(ZRA.CLASS_MAP) do
		ZRA.CLASS_MAP_BACK[v] = k
	end
	ZRA.RAID_MAP = ZRA.mapRaids() 
	ZRA.RAID_MAP_BACK = {}
	for k,v in pairs(ZRA.RAID_MAP) do
		ZRA.RAID_MAP_BACK[v] = k
	end

	local str = 'abcdefghijklmnopqrstuvwxysABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	for i = 1, string.len(str) do
		table.insert(ZRA.CODES, string.sub(str, i, i))
		ZRA.LETTER_MAP[string.sub(str, i, i)] = i
	end
	if not ZRA_vars then
		ZRA.wipeVars()
	end

	ZRA.assignUpdateHistory = {}
	ZRA.checkSavedVars()
end


function ZRA.getBossData(raid, boss)
	local boss_data = nil
	if not(type(boss) == 'number') then
		boss = ZRA.getBossIndFromName(raid, boss)
	end
	if raid == "Roles" then
		boss_data = ZRA_vars.roles
	else
		boss_data = ZRA_vars.raids[raid][boss]
	end
	return boss_data
end

function ZRA.mapRaids()
	local m = {
		['Roles'] = '0',
	}
	local i = 1
	for k,_ in pairs(ZRA_vars.raids) do
		m[k] = tostring(i)
		i = i + 1
	end
	return m	
end

function ZRA.setRaidAssignment(raid, bossInd, group, column, members, initiator)
	initiator = initiator or 'other'
	local boss_data = ZRA.getBossData(raid, bossInd)
	local changed = ZRA.setGetDiff(boss_data[group].columns[column], 'members', members)
	if changed  then
		ZRA.assignmentsModified(raid, bossInd, initiator)
	end
end

function ZRA.dataChanged()
	ZRA.raidsAssignsVersion = ZRA.raidAssignsVersion()
	ZRA.refreshUI()
end

function ZRA.dropAsignee(playerCode, raid, bossInd, group, column, initiator)
	initiator = initiator or 'other'
	
	local boss_data = ZRA.getBossData(raid, bossInd)
	local mems_cpy = ZRA.shallowcopy(boss_data[group].columns[column].members)
	for i,v in ipairs(mems_cpy) do
		if v == playerCode then
			table.remove(mems_cpy, i)
		end
	end
	ZRA.setRaidAssignment(raid, bossInd, group, column, mems_cpy, initiator)
end


function ZRA.assignmentsAreBlank(raid, boss)
	if raid == "Log" then return false end
	if not(type(boss) == 'number') then
		boss = ZRA.getBossIndFromName(raid, boss)
	end
	local boss_data = nil
	if raid == "Roles" then
		boss_data = ZRA_vars.roles
	else
		boss_data = ZRA_vars.raids[raid][boss]
	end
	for _,group in ipairs(boss_data) do
		for _,col in ipairs(group.columns) do
			if #col.members > 0 then
				return false
			end
		end
		
	end
	return true
end

function ZRA.getBossIndFromName(raid, bossName)
	if raid == "Roles" then return "_" end
	for i,v in ipairs(ZRA_vars.raids[raid]) do
		if v.name == bossName then
			return i
		end
	end
end

function ZRA.onEvent(frame, event, arg1, arg2, arg3, arg4, ...)
	if (event == "ADDON_LOADED" and arg1 == "ZodsRaidAssign") then
		
		ZRA.onLoad()
		ZRA.onLoadUI()
		ZRA.onLoadComms()
		ZRA.cleanupEvents()
	elseif event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LEAVING_WORLD' then
		--unhandled onEvent
		local events = ZRA_vars.events or {}
		ZRA_vars.events = events
		local iname, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
		if #events==0 or (not (instanceType == events[#events].inst_type)) then
			table.insert(events, {event = event, time = GetTime(), instance = iname, inst_type = instanceType, id = instanceID})
		else
		end
	else
	end
end


function ZRA.rosterVersion()
	local version = 0
	local m = ZRA.LETTER_MAP
	for k,v in pairs(ZRA_vars.roster) do
		if m[string.sub(v.name, 1, 1)] then
			version = version + m[string.sub(k, 1, 1)] * m[string.sub(v.name, 1, 1)]
		else
			version = version + 1
		end
	end
	return string.format("%04d", ZRA.modulo(version, 9547))
end

function ZRA.raidAssignsVersion()
	local version = 0
	local m = ZRA.LETTER_MAP
	for raidkey,raid in pairs(ZRA_vars.raids) do
		local raidNum = ZRA.RAID_MAP[raidkey]
		for bossNum, boss in ipairs(raid) do
			for groupi,group in ipairs(boss) do
				for coli,col in ipairs(group.columns) do
					for memi,mem in ipairs(col.members) do
						version = version + m[mem] * (raidNum + bossNum + groupi + coli + memi)
					end
				end
			end
		end
	end
	for groupi,group in ipairs(ZRA_vars.roles) do
		for coli,col in ipairs(group.columns) do
			for memi,mem in ipairs(col.members) do
				version = version + m[mem] * (1 + groupi + coli + memi)
			end
		end
	end
	return string.format("%04d", ZRA.modulo(version, 9547))
end


function ZRA.wipeVars()
	if not ZRA_vars then
		ZRA_vars = {}
	end
	ZRA_vars.roster = {}
	ZRA_vars.raids = ZRA.deepcopy(ZRA.raidschema)
	ZRA_vars.roles = ZRA.deepcopy(ZRA.roleschema)
	ZRA.rosterModified('self')
end


function ZRA.setGetDiff(oldVar, key, newAssign)
	local diff = nil
	if #(oldVar[key]) > #newAssign then
		for i,v in ipairs(newAssign) do
			if v ~= oldVar[key][i] then
				diff = ZRA_vars.roster[oldVar[key][i]].name .. ' removed from pos ' .. i
				break
			end
		end
		if not diff then diff = ZRA_vars.roster[oldVar[key][#oldVar[key]]].name .. ' removed from end' end
	elseif #(oldVar[key]) < #newAssign then
		for i,v in ipairs(oldVar[key]) do
			if v ~= newAssign[i] then
				diff = ZRA_vars.roster[newAssign[i]].name .. ' inserted at pos ' .. i
				break
			end
		end
		if not diff then diff = ZRA_vars.roster[newAssign[#newAssign]].name .. ' inserted at end' end
	else
	end
	oldVar[key] = newAssign
	return diff
end


function ZRA.cleanupEvents()
	local events = ZRA_vars.events or {}
	local removing = {}
	local t = GetTime()
	for i,v in ipairs(events) do
		if t - v.time > 60 * 60 * 2 then
			table.insert(removing, i)
		end
	end
	for i = #removing, 1, -1 do
		table.remove(events, removing[i])
	end
end

function ZRA.checkSavedVars()
	if not ZRA_vars then ZRA_vars = {} end
	if not ZRA_vars.saved_raids then ZRA_vars.saved_raids = {} end
	if not ZRA_vars.roster then ZRA_vars.roster = {} end
	--if not ZRA_vars.raids then ZRA_vars.raids = {
	if not ZRA_vars.raids then 
		ZRA_vars.raids = ZRA.deepcopy(ZRA.raidschema)
		ZRA_vars.roles = ZRA.deepcopy(ZRA.roleschema)
	end
end

-- Save copied tables in `copies`, indexed by original table.


ZRA.ROSTER_SOFT_CAP = 46
--codes for player UID, to make pickling easier
function ZRA.getUnusedCode()
	for i,v in ipairs(ZRA.CODES) do
		if ZRA_vars.roster[v] == nil then
			return v
		end
	end
	if ZRA.tablelen(ZRA_vars.roster) > ZRA.ROSTER_SOFT_CAP then
		ZRA.updateRaidNums()
		ZRA.tryDropExternals()
	end
	error("out of player codes")
end

function ZRA.tryDropExternals()
	for k,v in pairs(ZRA_vars.roster) do
		if v.raidNum == 0 then
			if ZRA.countPlayerAssigns(k) == 0 then
				ZRA_vars.roster[k] = nil
			end
		end
	end
end

function ZRA.countPlayerAssigns(k)
	local cnt = 0
	for _, raid in pairs(ZRA_vars.raids) do
		for _, boss in pairs(raid) do
			for _, assignGroup in ipairs(boss) do
				for _, column in ipairs(assignGroup.columns) do
					for index, value in ipairs(column.members) do
						if value == k then
							cnt = cnt + 1
						end
					end
				end
			end
		end
	end
	for _, assignGroup in ipairs(ZRA_vars.roles) do
		for _, column in ipairs(assignGroup.columns) do
			for index, value in ipairs(column.members) do
				if value == k then
					cnt = cnt + 1
				end
			end
		end
	end
	return cnt
end




function ZRA.GetTanks()
	return ZRA.shallowcopy(ZRA_vars.roles[1].columns[1].members)
end

function ZRA.GetHeals()
	return {
		priests=ZRA.shallowcopy(ZRA_vars.roles[2].columns[1].members),
		pallies=ZRA.shallowcopy(ZRA_vars.roles[2].columns[2].members),
		druids=ZRA.shallowcopy(ZRA_vars.roles[2].columns[3].members)
	}
end

function ZRA.tank_heal_iter()
	local unass_healers = ZRA.GetHeals()
	local lf = 'pally'
	return 
		function ()
			if lf == 'pally' then 
				if #unass_healers.pallies > 0 then
					lf = 'priest'
					return table.remove(unass_healers.pallies, 1)
				elseif #unass_healers.priests > 0 then
					lf = 'pally'
					return table.remove(unass_healers.priests, 1)
				elseif #unass_healers.druids > 0 then
					lf = 'pally'
					return table.remove(unass_healers.druids, 1)
				else
					--nil
				end
			elseif lf == 'priest' then
				if #unass_healers.priests > 0 then
					lf = 'pally'
					return table.remove(unass_healers.priests, 1)
				elseif #unass_healers.pallies > 0 then
					lf = 'priest'
					return table.remove(unass_healers.pallies, 1)
				elseif #unass_healers.druids > 0 then
					lf = 'pally'
					return table.remove(unass_healers.druids, 1)
				else
					--nil
				end
			end
		end
end

function ZRA.tank_iter()
	local unass_tanks = ZRA.GetTanks()
	return 
		function ()
			if #unass_tanks > 0 then
				return table.remove(unass_tanks, 1)
			end
		end
end


function ZRA.raid_iter()
	local key = nil
	return function()
		key = next(ZRA_vars.roster, key)
		if key then
			return ZRA_vars.roster[key]
		end
	end
	--	for r in ZRA.raid_iter() do
	--	print(dump(r))
	--end
end

function ZRA.loadMembers()
	--adds current group members to roster
	local num_before = ZRA.tablelen(ZRA_vars.roster)
	local reverse_ind = {}
	for k,v in pairs(ZRA_vars.roster) do
		reverse_ind[v.name] = k
	end
	if IsInGroup() then
		for i=1,GetNumGroupMembers() do
			local name, _, _, _, _, class = GetRaidRosterInfo(i)
			if not reverse_ind[name] then
				ZRA_vars.roster[ZRA.getUnusedCode()] = {
				class = class,
				name = name,
				raidNum = i,
				}
			end
		end
	else
		local name = UnitName("player")
		local class = string.upper(UnitClass('player'))
		if not reverse_ind[name] then
			ZRA_vars.roster[ZRA.getUnusedCode()] = {
			class = class,
			name = name,
			raidNum = 1,
			}
		end
	end
	local num_after = ZRA.tablelen(ZRA_vars.roster)
	if num_after > num_before then
		ZRA.rosterModified('self')
	end
end




function ZRA.updateRaidNums()
	local reverse_ind = {}
	for k,v in pairs(ZRA_vars.roster) do
		reverse_ind[v.name] = k
	end
	for k,v in pairs(ZRA_vars.roster) do
		v.raidNum = 0
	end
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		if reverse_ind[name] then
			ZRA_vars.roster[reverse_ind[name]].raidNum = i
		end
	end
end

function ZRA.dropExternalMembers()
	ZRA.tryDropExternals()
	ZRA.loadMembers()
end

function ZRA.getCodeFromName(n)
	for k,v in pairs(ZRA_vars.roster) do
		if v.name ==n then
			return k
		end
	end
end

function ZRA.reset()
	ZRA_vars.raids = ZRA.deepcopy(ZRA.raidschema)
	ZRA_vars.roles = ZRA.deepcopy(ZRA.roleschema)
	ZRA_vars.roster = {}
	ZRA.rosterModified('self')

end

--- slash handler
SLASH_ZRAIDASSIGN1 = "/zra"
SlashCmdList["ZRAIDASSIGN"] = function(msg)
	local command, arg1, arg2, arg3 = strsplit(" ",msg)
	if command == 'menu' or command == '' or (not command) then
		ZRA.OpenMenu()
	elseif (command == 'clear') then
		ZRA.reset()
		print('cleared')
	elseif (command == 'debug') then
		ZRA.debugging = true
		print('debugging')
	elseif (command == 'dontgray') then
		ZRA.dontgray = true
		print('gray off')
	elseif (command == 'i') then
		print('Recent instances')
		ZRA.ParseEvents()
	elseif (command == 'wipe') then
		ZRA.notFreshInstance()
		print('wipe')
	elseif (command == 'test1') then
		ZRA_vars.roster = ZRA.testroster1
		ZRA.rosterModified('self')
		print('using test roster 1')
	elseif (command == 'test2') then
		ZRA_vars.roster = ZRA.testroster2
		ZRA.rosterModified('self')
		print('using test roster 2')
	elseif (command == 'state') then
		print(ZRA.state)
	elseif (command == 'save') then
		if arg1 then 
			print('saving ' .. arg1)
			ZRA_vars.saved_raids[arg1] = {}
			ZRA_vars.saved_raids[arg1].roster = ZRA.deepcopy(ZRA_vars.roster)
			ZRA_vars.saved_raids[arg1].roles = ZRA.deepcopy(ZRA_vars.roles)
			ZRA_vars.saved_raids[arg1].raids = ZRA.deepcopy(ZRA_vars.raids)
		else
			print('need a name to save by')
		end
	elseif (command == 'load') then
		if arg1 then 
			if ZRA_vars.saved_raids and ZRA_vars.saved_raids[arg1] then
				print('loading ' .. arg1)
				ZRA_vars.roster = ZRA_vars.saved_raids[arg1].roster
				ZRA_vars.roles = ZRA_vars.saved_raids[arg1].roles
				ZRA_vars.raids = ZRA_vars.saved_raids[arg1].raids
				table.insert(ZRA.assignUpdateHistory, {update_type = 'roster', sender = "ME", mess = 'loaded a stored raid, ' .. arg1})
				ZRA.rosterModified('self')
			else
				print('coudlnt load raid named ' .. arg1 '. check the name')
				print("saved raids available to load")
				for k,_ in pairs(ZRA_vars.saved_raids or {}) do
					print(k)
				end
			end
		else
			print("saved raids available to load")
			for k,_ in pairs(ZRA_vars.saved_raids or {}) do
				print(k)
			end
		end
	elseif (command == 'delete') then
		if arg1 then 
			print('deleting ' .. arg1)
			ZRA_vars.saved_raids[arg1] = nil
		else
			print("saved raids available to delete")
			for k,_ in pairs(ZRA_vars.saved_raids or {}) do
				print(k)
			end
		end
	else
		ZRA.PrintHelp()
	end
end

function ZRA.PrintHelp()
	print('load/save/delete {name}')
	print('\'i\' shows instances, \'wipe\' removes last zone out, test{1,2} for test raid, clear, dontgray, debug')
end



function ZRA.splitmess(mess_arr, sep, lencap)
	local lines = {}
	local current_line = ""
	for i,v in ipairs(mess_arr) do
		if string.len(current_line) + string.len(sep) + string.len(v) >= lencap then
			table.insert(lines, current_line)
			current_line = ""
		elseif string.len(current_line) > 0 then
			current_line = current_line .. sep
		end
		current_line = current_line .. v
	end
	if string.len(current_line) > 0 then
		table.insert(lines, current_line)
	end
	return lines
end

ZRA.scriptframe = CreateFrame("Frame", 'ZRAFrame')
ZRA.scriptframe:RegisterEvent("ADDON_LOADED")
ZRA.scriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZRA.scriptframe:RegisterEvent("GROUP_JOINED")
ZRA.scriptframe:RegisterEvent("GROUP_ROSTER_UPDATE")
ZRA.scriptframe:SetScript("OnEvent", ZRA.onEvent)
ZRA.scriptframe:SetScript("OnUpdate", ZRA.onUpdate)

local some_events = {
	'PLAYER_QUITING',
	'PLAYER_LOGOUT',
	'PLAYER_LOGIN',
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEAVING_WORLD",
}

for k, v in pairs(some_events) do
	ZRA.scriptframe:RegisterEvent(v)
end


