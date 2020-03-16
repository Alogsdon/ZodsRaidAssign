
local addonName, ZRA = ...

	
function ZRA.onUpdate()
	if ZRA.requestSent then
		if GetTime() - ZRA.requestSent.t > 3.0 then
			ZRA.requestTimeout()
		end
	end
end

function ZRA.requestTimeout()
	local request = ZRA.requestSent
	if request.item == 'rosterVersion' then
		ZRA.raidsRosterVersion = ZRA.rosterVersion()
		ZRA.raidsAssignsVersion = ZRA.raidAssignsVersion()
		ZRA.reGreet()
	elseif request.item == 'rosterPayload' then
		ZRA.otherUsers[request.askee] = nil
		ZRA.askForRosterPayload()
	elseif request.item == 'bossAssigns' then
		ZRA.otherUsers[request.askee] = nil
		ZRA.askForBossAssigns()
	end
	ZRA.requestSent = nil
	if #ZRA.request_queue > 0 then
		ZRA.sendRequestFromQueue()
	end
end

function ZRA.onLoad()
	C_ChatInfo.RegisterAddonMessagePrefix("ZRA")
	ZRA.otherUsers = {}
	ZRA.CODES = {}
	ZRA.request_queue = {}
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
	ZRA.RAID_MAP = {
		['Roles'] = '0',
		['Onyxias Lair'] = '1',
		['Molten Core'] = '2',
	}
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
	if (not ZRA_vars.schema_version) or ZRA_vars.schema_version < ZRA.schema_version then
		ZRA.wipeVars()
		ZRA_vars.schema_version = ZRA.schema_version
	end
	ZRA.assignUpdateHistory = {}
	ZRA.checkSavedVars()
	ZRA.Greet()
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

function ZRA.setRaidAssignment(raid, bossInd, group, column, members, initiator)
	initiator = initiator or 'other'
	local boss_data = ZRA.getBossData(raid, bossInd)
	local changed = ZRA.setGetDiff(boss_data[group].columns[column], 'members', members)
	if changed and initiator ~= 'self' then
		ZRA.dataChanged()
	end
end

function ZRA.dataChanged()
	ZRA.raidsAssignsVersion = ZRA.raidAssignsVersion()
	ZRA.updateUI()
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

function ZRA.dropMissingAssignments(raid, boss, group, column, members)

	
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
		ZRA.cleanupEvents()
		
		
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" then
			local sender = string.gmatch(arg4,'(%w+)-')() or arg4
			if sender == UnitName("player") then
			else
				ZRA.HandleRemoteData(arg2, arg3, sender)
			end
		end
	elseif event == "GROUP_JOINED" then
		ZRA.loadMembers()
		ZRA.Greet()
	elseif event == "GROUP_ROSTER_UPDATE" then
		ZRA.loadMembers()
		ZRA.reGreet()
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



function ZRA.Greet()
	ZRA.otherUsers = {}
	ZRA.requestSent = {t = GetTime(), item = 'rosterVersion'}
	ZRA.raidsRosterVersion = nil
	ZRA.raidsAssignsVersion = nil
	C_ChatInfo.SendAddonMessage("ZRA", "hello", 'RAID')
end

hooksecurefunc(C_ChatInfo,"SendAddonMessage",function(arg1,arg2,arg3,arg4,...)
	if arg1 == "ZRA" and ZRA.debugging then
		print("ME->" .. arg3 .. (arg4 or '') ..": " .. arg2)
	end
end)


function ZRA.reGreet()
	ZRA.otherUsers = {}
	if ZRA.raidsRosterVersion and ZRA.raidsAssignsVersion then
		C_ChatInfo.SendAddonMessage("ZRA", "hi"..ZRA.raidsRosterVersion..ZRA.raidsAssignsVersion, 'RAID')
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


function ZRA.HandleRemoteData(arg2, arg3, arg4)
	local sender = arg4
	local task = string.sub(arg2,0,2)
	if ZRA.debugging then print('heard '.. arg4 .. '-'.. arg2 ) end
	if task == 'he' then
		ZRA.reGreet()
		ZRA.otherUsers[sender] = true
	elseif task == 'hi' then
		ZRA.raidsRosterVersion = string.sub(arg2,3,6)
		ZRA.raidsAssignsVersion = string.sub(arg2,7,10)
		ZRA.otherUsers[sender] = true
		if ZRA.requestSent and ZRA.requestSent.item == 'rosterVersion' then
			ZRA.requestSent = nil
		end
		if ZRA.rosterVersion() ~= ZRA.raidsRosterVersion then
			ZRA.wipeVars()
			table.insert(ZRA.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'clear your roster, its out of date'})
			ZRA.askForRosterPayload()
		elseif ZRA.raidAssignsVersion() ~= ZRA.raidsAssignsVersion then
			ZRA.askForBossAssigns()
		end
	elseif task == 'rr' then
		ZRA.sendRosterData(sender)
	elseif task == 'sr' then
		if ZRA.rosterVersion() ~= ZRA.raidsRosterVersion then
			ZRA.requestSent = nil
			table.insert(ZRA.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'updated per roster payload partial'})
			ZRA.setRosterFromMess(string.sub(arg2,3))
		end
	elseif task == 'bu' then
		ZRA.hearBossAssigns(string.sub(arg2,3), sender)
	elseif task == 'ra' then
		ZRA.sendAllBossAssigns(sender)
	end
end

function ZRA.wipeVars()
	if not ZRA_vars then
		ZRA_vars = {}
	end
	ZRA_vars.roster = {}
	ZRA_vars.raids = ZRA.deepcopy(ZRA.raidschema)
	ZRA_vars.roles = ZRA.deepcopy(ZRA.roleschema)
	ZRA.myRosterChanged()
end

function ZRA.sendRosterData(dest)
	ZRA.updateRaidNums()
	local mess_arr = {}
	for k,v in pairs(ZRA_vars.roster) do
		if v.raidNum > 0 then
			table.insert(mess_arr,k .. v.raidNum)
		else
			table.insert(mess_arr,k .. v.name..ZRA.CLASS_MAP[v.class])
		end
	end
	local lines = ZRA.splitmess(mess_arr, ',', 220)
	for i,v in ipairs(lines) do
		C_ChatInfo.SendAddonMessage("ZRA", "sr" .. v, 'WHISPER', dest)
	end

	ZRA.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZRA.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
	
end

function ZRA.sendAllBossAssigns(dest)
	ZRA.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZRA.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
end

function ZRA.hearBossAssigns(mess, sender)
	local raidKey = ZRA.RAID_MAP_BACK[string.sub(mess,1,1)]
	local bosskey = tonumber(string.sub(mess,2,3))
	local bossName = nil
	local BossData = nil
	if raidKey == "Roles" then
		BossData = ZRA_vars.roles
	else
		bossName = ZRA_vars.raids[raidKey][bosskey].name
		BossData = ZRA_vars.raids[raidKey][bosskey]
	end
	
	local assignsMess = string.sub(mess,4)
	local diff = nil
	local groups = ZRA.mysplit(assignsMess, '.')
	for groupInd, colmnsMess in ipairs(groups) do
		local columns = ZRA.mysplit(colmnsMess, ',')
		local groupTitle = BossData[groupInd].title
		for colInd,membersMess in ipairs(columns) do
			local members = ZRA.dicestring(membersMess)
			local header = BossData[groupInd].columns[colInd].header
			local thisDiff = ZRA.setGetDiff(BossData[groupInd].columns[colInd], 'members', members)
			if thisDiff then
				if diff then
					diff = 'multiple changes'
				else
					diff = ' g:' .. groupTitle .. ' c:' .. header .. " -"..thisDiff
				end
			end
		end
	end
	if diff then
		table.insert(ZRA.assignUpdateHistory, {update_type = 'boss', sender = sender, raid = raidKey, boss = bossName or "_", diff = diff})
		ZRA.dataChanged()
	end
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

function ZRA.sendBossAssigns(raidName, bossIndex, dest)
	if not bossIndex then bossIndex = 0 end
	local bossAssigns
	if bossIndex == -1 then
		raidName = "Roles"
	end
	if raidName == "Roles" then
		bossAssigns = ZRA_vars.roles
	else
		bossAssigns = ZRA_vars.raids[raidName][bossIndex]
	end

	local p = 'bu' .. ZRA.RAID_MAP[raidName] .. string.format("%02d", bossIndex)
	for groupInd, group in ipairs(bossAssigns) do
		for columnInd, column in ipairs(group.columns) do
			for _, playerCode in ipairs(column.members) do
				p = p .. playerCode
			end
			p = p .. ","
		end
		p = p .. "."
	end
	if dest then
		C_ChatInfo.SendAddonMessage("ZRA", p, 'WHISPER', dest)
	else
		C_ChatInfo.SendAddonMessage("ZRA", p, 'RAID')
	end
end

function ZRA.askForRosterPayload()
	local guy_to_ask = ZRA.tablefirstkey(ZRA.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'rosterPayload', askee = guy_to_ask}
	if ZRA.requestSent then
		table.insert(ZRA.request_queue, request)
	else
		ZRA.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "rr", 'WHISPER', guy_to_ask)
	end
end

function ZRA.askForBossAssigns()
	local guy_to_ask = ZRA.tablefirstkey(ZRA.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'bossAssigns', askee = guy_to_ask}
	if ZRA.requestSent then
		table.insert(ZRA.request_queue, request)
	else
		ZRA.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "ra", 'WHISPER', guy_to_ask)
	end
end

function ZRA.sendRequestFromQueue()
	local request = table.remove(ZRA.request_queue, 1)
	if request.item == 'rosterPayload' then
		ZRA.askForRosterPayload()
	end
end

function ZRA.setRosterFromMess(mess)
	for entry in string.gmatch(mess, '([^,]+)') do
		if string.len(entry) <= 3 then
			local rnum = tonumber(string.sub(entry,2))
			local name, _, _, _, _, class = GetRaidRosterInfo(rnum)
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		else
			local rnum = 0
			local name = string.sub(entry,2,-2)
			local class = ZRA.CLASS_MAP_BACK[tonumber(string.sub(entry,-1))]
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		end
	end
	ZRA.myRosterChanged()
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
function ZRA.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, ZRA.deepcopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[ZRA.deepcopy(orig_key, copies)] = ZRA.deepcopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

ZRA.ROSTER_SOFT_CAP = 46
--codes for player UID, to make pickling easier
function ZRA.getUnusedCode()
	for i,v in ipairs(ZRA.CODES) do
		if ZRA_vars.roster[v] == nil then
			return v
		end
	end
	if #ZRA_vars.roster > ZRA.ROSTER_SOFT_CAP then
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

function ZRA.ParseEvents()
	local events = ZRA_vars.events or {}
	local inside = false
	local iname = ''
	local cnt = 0
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
			iname = event.instance
		else
			if inside == true then
				--exited
				inside = false
				local t = GetTime()
				cnt = cnt + 1
				print(cnt .. '. Exited ' .. iname.. ' ' .. string.format("%.1f", (t - event.time)/60) ..' mins ago')
			end
		end
	end
end

function ZRA.notFreshInstance()
	local last_exit = false
	local events = ZRA_vars.events or {}
	local inside = false
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
		else
			if inside == true then
				last_exit = i
			end
		end
	end
	if last_exit then
		table.remove(events, last_exit)
	end
end

function ZRA.MakeMacros()
	ZRA.BuffMacro()
end




function ZRA.GroupDistribute(numGroups,numBuffers)
	local sets = {}
	local avg = numGroups / numBuffers
	local quota = 0
	for i = 1, numGroups do
		if quota > 0 then
			table.insert(sets[#sets], i)
			quota = quota - 1
		else
			table.insert(sets, {})
			table.insert(sets[#sets], i)
			quota = quota + avg - 1
		end
	end
	return sets
end


function ZRA.GetMakeMacro(name)
	local mi = GetMacroIndexByName(name)
	if mi == 0 then 
		CreateMacro(name, 'INV_Misc_QuestionMark', "")
		mi = GetMacroIndexByName(name)
	end
	return mi
end

function ZRA.MacroSetBody(i, body)
	local name,	texture = GetMacroInfo(i)
	EditMacro(i, name, texture, body)
end


ZRA.SHAPES = {
	skull = true,
	x = true,
	square = true,
	moon = true,
	triangle = true,
	diamond = true,
	circle = true,
	star = true,
}

function ZRA.shape(s)
	if ZRA.SHAPES[string.lower(s)] then
		return '{' .. s .. '}'
	else
		return s
	end
end



function ZRA.BuffMacro()
	local numgroups = 8
	local mi = ZRA.mage_iter()
	local di = ZRA.druid_iter()
	local pi = ZRA.priest_iter()
	local s,i = ''
	local mages_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetMages())
	s = s .. '/rw MAGE BUFFS\n'
	for i, groups in pairs(mages_groups) do
		local mage = mi()
		s = s .. '/rw ' .. mage.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZMageBuffs")
	ZRA.MacroSetBody(i, s)

	s = ''
	local priest_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetPriests())
	s = s .. '/rw PRIEST BUFFS\n'
	for i, groups in pairs(priest_groups) do
		local priest = pi()
		s = s .. '/rw ' .. priest.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZPriestBuffs")
	ZRA.MacroSetBody(i, s)

	s = ''
	local druids_groups = ZRA.GroupDistribute(numgroups, #ZRA.GetDruids())
	s = s .. '/rw DRUID BUFFS\n'
	for i, groups in pairs(druids_groups) do
		local druid = di()
		s = s .. '/rw ' .. druid.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZRA.GetMakeMacro("ZDruidBuffs")
	ZRA.MacroSetBody(i, s)
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
	ZRA.pushNewRoster()
	ZRA.updateRoster()
	ZRA.updateUI()
end

function ZRA.pushNewRoster()
	ZRA.raidsRosterVersion = ZRA.rosterVersion()
	ZRA.reGreet()
end

function ZRA.myRosterChanged()
	if ZRALayoutFrame and ZRALayoutFrame:IsShown() then 
		ZRA.OpenMenu()
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


--- slash handler
SLASH_ZRAIDASSIGN1 = "/zra"
SlashCmdList["ZRAIDASSIGN"] = function(msg)
	local command, arg1, arg2, arg3 = strsplit(" ",msg)
	if command == 'menu' or command == '' or (not command) then
		ZRA.OpenMenu()
	elseif (command == 'clear') then
		ZRA_vars.raids = ZRA.deepcopy(ZRA.raidschema)
		ZRA_vars.roles = ZRA.deepcopy(ZRA.roleschema)
		ZRA_vars.roster = {}
		ZRA.myRosterChanged()
		ZRA.pushNewRoster()
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
		ZRA.myRosterChanged()
		ZRA.pushNewRoster()
		print('using test roster 1')
	elseif (command == 'test2') then
		ZRA_vars.roster = ZRA.testroster2
		ZRA.myRosterChanged()
		ZRA.pushNewRoster()
		print('using test roster 2')
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
				ZRA.myRosterChanged()
				ZRA.pushNewRoster()
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

function ZRA.dump(o)
	if type(o) == 'table' then
		 local s = '{ '
		 for k,v in pairs(o) do
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. ZRA.dump(v) .. ','
		 end
		 return s .. '} '
	else
		 return tostring(o)
	end
end

function ZRA.shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
					copy[orig_key] = orig_value
			end
	else -- number, string, boolean, etc
			copy = orig
	end
	return copy
end

function ZRA.modulo(a,b)
	return a - math.floor(a/b)*b
end

function ZRA.tablelen(t)
	local numItems = 0
	for k,v in pairs(t) do
		numItems = numItems + 1
	end
	return numItems
end

function ZRA.tablefirstkey(t)
	for k,v in pairs(t) do
		return(k)
	end
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

function ZRA.remaining(it)
	local temp = {}
	for item in it do
		table.insert(temp,item)
	end
	return temp
end

function ZRA.mysplit (inputstr, sep)
	local t={}
	local p = ''
	for i = 1, string.len(inputstr) do
		local letter = string.sub(inputstr, i, i)
		if letter == sep then
			table.insert(t, p)
			p = ''
		else
			p = p .. letter
		end
	end
	return t
end

function ZRA.dicestring(str)
	local t = {}
	for i = 1, string.len(str) do
		table.insert(t, string.sub(str, i, i))
	end
	return t
end

function ZRA.codesToValsArr(codes, hash, key)
	local vals = {}
	for _,v in ipairs(codes) do
		table.insert(vals, hash[v][key])
	end
	return vals
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


