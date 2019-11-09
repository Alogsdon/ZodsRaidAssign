


local ZodsRaidAssign = {

}
	

function ZodsRaidAssign.onUpdate()
	if ZodsRaidAssign.requestSent then
		if GetTime() - ZodsRaidAssign.requestSent.t > 3.0 then
			ZodsRaidAssign.requestTimeout()
		end
	end
end

function ZodsRaidAssign.requestTimeout()
	local request = ZodsRaidAssign.requestSent
	if request.item == 'rosterVersion' then
		ZodsRaidAssign.raidsRosterVersion = ZodsRaidAssign.rosterVersion()
		ZodsRaidAssign.raidsAssignsVersion = ZodsRaidAssign.raidAssignsVersion()
		ZodsRaidAssign.reGreet()
	elseif request.item == 'rosterPayload' then
		ZodsRaidAssign.otherUsers[request.askee] = nil
		ZodsRaidAssign.askForRosterPayload()
	elseif request.item == 'bossAssigns' then
		ZodsRaidAssign.otherUsers[request.askee] = nil
		ZodsRaidAssign.askForBossAssigns()
	end
	ZodsRaidAssign.requestSent = nil
	if #ZodsRaidAssign.request_queue > 0 then
		ZodsRaidAssign.sendRequestFromQueue()
	end
end

function ZodsRaidAssign.onLoad()
	C_ChatInfo.RegisterAddonMessagePrefix("ZRA")
	ZodsRaidAssign.otherUsers = {}
	ZodsRaidAssign.CODES = {}
	ZodsRaidAssign.request_queue = {}
	ZodsRaidAssign.LETTER_MAP = {}
	ZodsRaidAssign.CLASS_MAP = {
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
	ZodsRaidAssign.CLASS_MAP_BACK = {}
	for k,v in pairs(ZodsRaidAssign.CLASS_MAP) do
		ZodsRaidAssign.CLASS_MAP_BACK[v] = k
	end
	ZodsRaidAssign.RAID_MAP = {
		['Roles'] = '0',
		['Onyxias Lair'] = '1',
		['Molten Core'] = '2',
	}
	ZodsRaidAssign.RAID_MAP_BACK = {}
	for k,v in pairs(ZodsRaidAssign.RAID_MAP) do
		ZodsRaidAssign.RAID_MAP_BACK[v] = k
	end

	local str = 'abcdefghijklmnopqrstuvwxysABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	for i = 1, string.len(str) do
		table.insert(ZodsRaidAssign.CODES, string.sub(str, i, i))
		ZodsRaidAssign.LETTER_MAP[string.sub(str, i, i)] = i
	end
	ZodsRaidAssignPublic.assignUpdateHistory = {}
	ZodsRaidAssign.checkSavedVars()
	ZodsRaidAssign.Greet()
end

function ZodsRaidAssignPublic.setRaidAssignment(raid, boss, group, column, members, initiator)
	if not(type(boss) == 'number') then
		boss = ZodsRaidAssign.getBossIndFromName(raid, boss)
	end
	local boss_data = nil
	if raid == "Roles" then
		boss_data = ZRA_vars.roles
	else
		boss_data = ZRA_vars.raids[raid][boss]
	end
	local changed = setGetDiff(boss_data[group].columns[column], 'members', members)
	if changed and initiator ~= 'self' then
		ZodsRaidAssignPublic.dataChanged()
	end
end

function ZodsRaidAssignPublic.dataChanged()
	ZodsRaidAssign.raidsAssignsVersion = ZodsRaidAssign.raidAssignsVersion()
	ZodsRaidAssignPublic.updateUI()
end

function ZodsRaidAssignPublic.dropMissingAssignments(raid, boss, group, column, members)

	
end

function ZodsRaidAssign.getBossIndFromName(raid, bossName)
	for i,v in ipairs(ZRA_vars.raids[raid]) do
		if v.name == BossName then
			return i
		end
	end
end

function ZodsRaidAssign.onEvent(frame, event, arg1, arg2, arg3, arg4, ...)
	if (event == "ADDON_LOADED" and arg1 == "ZodsRaidAssign") then
		
		ZodsRaidAssign.onLoad()
		ZodsRaidAssign.cleanupEvents()
		
		
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" then
			local sender = string.gmatch(arg4,'(%w+)-')() or arg4
			if sender == UnitName("player") then
				if ZodsRaidAssignPublic.debugging then
					print('said ' .. arg2)
				end
			else
				ZodsRaidAssign.HandleRemoteData(arg2, arg3, sender)
			end
		end
	elseif event == "GROUP_JOINED" then
		ZodsRaidAssign.Greet()
	elseif event == "GROUP_ROSTER_UPDATE" then
		ZodsRaidAssign.reGreet()
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



function ZodsRaidAssign.Greet()
	ZodsRaidAssign.otherUsers = {}
	ZodsRaidAssign.requestSent = {t = GetTime(), item = 'rosterVersion'}
	ZodsRaidAssign.raidsRosterVersion = nil
	ZodsRaidAssign.raidsAssignsVersion = nil
	C_ChatInfo.SendAddonMessage("ZRA", "hello", 'RAID')
end

function ZodsRaidAssign.reGreet()
	ZodsRaidAssign.otherUsers = {}
	if ZodsRaidAssign.raidsRosterVersion and ZodsRaidAssign.raidsAssignsVersion then
		C_ChatInfo.SendAddonMessage("ZRA", "hi"..ZodsRaidAssign.raidsRosterVersion..ZodsRaidAssign.raidsAssignsVersion, 'RAID')
	end
end

function ZodsRaidAssign.rosterVersion()
	local version = 0
	local m = ZodsRaidAssign.LETTER_MAP
	for k,v in pairs(ZRA_vars.roster) do
		if m[string.sub(v.name, 1, 1)] then
			version = version + m[string.sub(k, 1, 1)] * m[string.sub(v.name, 1, 1)]
		else
			version = version + 1
		end
	end
	return string.format("%04d", modulo(version, 9547))
end

function ZodsRaidAssign.raidAssignsVersion()
	local version = 0
	local m = ZodsRaidAssign.LETTER_MAP
	for raidkey,raid in pairs(ZRA_vars.raids) do
		local raidNum = ZodsRaidAssign.RAID_MAP[raidkey]
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
	return string.format("%04d", modulo(version, 9547))
end


function ZodsRaidAssign.HandleRemoteData(arg2, arg3, arg4)
	local sender = arg4
	local task = string.sub(arg2,0,2)
	if ZodsRaidAssignPublic.debugging then print('heard ' .. arg2) end
	if task == 'he' then
		ZodsRaidAssign.reGreet()
		ZodsRaidAssign.otherUsers[sender] = true
	elseif task == 'hi' then
		ZodsRaidAssign.raidsRosterVersion = string.sub(arg2,3,6)
		ZodsRaidAssign.raidsAssignsVersion = string.sub(arg2,7,10)
		ZodsRaidAssign.otherUsers[sender] = true
		if ZodsRaidAssign.requestSent and ZodsRaidAssign.requestSent.item == 'rosterVersion' then
			ZodsRaidAssign.requestSent = nil
		end
		if ZodsRaidAssign.rosterVersion() ~= ZodsRaidAssign.raidsRosterVersion then
			ZRA_vars.roster = {}
			ZRA_vars.raids = deepcopy(ZodsRaidAssignPublic.raidschema)
			ZRA_vars.roles = deepcopy(ZodsRaidAssignPublic.roleschema)
			ZodsRaidAssign.myRosterChanged()
			table.insert(ZodsRaidAssignPublic.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'clear your roster, its out of date'})
			ZodsRaidAssign.askForRosterPayload()
		elseif ZodsRaidAssign.raidAssignsVersion() ~= ZodsRaidAssign.raidsAssignsVersion then
			ZodsRaidAssign.askForBossAssigns()
		end
	elseif task == 'rr' then
		ZodsRaidAssign.sendRosterData(sender)
	elseif task == 'sr' then
		if ZodsRaidAssign.rosterVersion() ~= ZodsRaidAssign.raidsRosterVersion then
			ZodsRaidAssign.requestSent = nil
			table.insert(ZodsRaidAssignPublic.assignUpdateHistory, {update_type = 'roster', sender = sender, mess = 'updated per roster payload partial'})
			ZodsRaidAssign.setRosterFromMess(string.sub(arg2,3))
		end
	elseif task == 'bu' then
		ZodsRaidAssign.hearBossAssigns(string.sub(arg2,3), sender)
	elseif task == 'ra' then
		ZodsRaidAssign.sendAllBossAssigns(sender)
	end
end

function ZodsRaidAssign.sendRosterData(dest)
	ZodsRaidAssignPublic.updateRaidNums()
	local mess_arr = {}
	for k,v in pairs(ZRA_vars.roster) do
		if v.raidNum > 0 then
			table.insert(mess_arr,k .. v.raidNum)
		else
			table.insert(mess_arr,k .. v.name..ZodsRaidAssign.CLASS_MAP[v.class])
		end
	end
	local lines = splitmess(mess_arr, ',', 220)
	for i,v in ipairs(lines) do
		C_ChatInfo.SendAddonMessage("ZRA", "sr" .. v, 'WHISPER', dest)
	end

	ZodsRaidAssignPublic.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZodsRaidAssignPublic.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
	
end

function ZodsRaidAssign.sendAllBossAssigns(dest)
	ZodsRaidAssignPublic.sendBossAssigns("Roles", nil, dest)
	for raidName, raidData in pairs(ZRA_vars.raids) do
		for bossIndex,bossAssigns in ipairs(raidData) do
			ZodsRaidAssignPublic.sendBossAssigns(raidName, bossIndex, dest)
		end
	end
end

function ZodsRaidAssign.hearBossAssigns(mess, sender)
	local raidKey = ZodsRaidAssign.RAID_MAP_BACK[string.sub(mess,1,1)]
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
	local groups = mysplit(assignsMess, '.')
	for groupInd, colmnsMess in ipairs(groups) do
		local columns = mysplit(colmnsMess, ',')
		local groupTitle = BossData[groupInd].title
		for colInd,membersMess in ipairs(columns) do
			local members = dicestring(membersMess)
			local header = BossData[groupInd].columns[colInd].header
			local thisDiff = setGetDiff(BossData[groupInd].columns[colInd], 'members', members)
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
		table.insert(ZodsRaidAssignPublic.assignUpdateHistory, {update_type = 'boss', sender = sender, raid = raidKey, boss = bossName or "_", diff = diff})
		ZodsRaidAssignPublic.dataChanged()
	end
end

function setGetDiff(oldVar, key, newAssign)
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

function ZodsRaidAssignPublic.sendBossAssigns(raidName, bossIndex, dest)
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

	local p = 'bu' .. ZodsRaidAssign.RAID_MAP[raidName] .. string.format("%02d", bossIndex)
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

function ZodsRaidAssign.askForRosterPayload()
	local guy_to_ask = tablefirstkey(ZodsRaidAssign.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'rosterPayload', askee = guy_to_ask}
	if ZodsRaidAssign.requestSent then
		table.insert(ZodsRaidAssign.request_queue, request)
	else
		ZodsRaidAssign.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "rr", 'WHISPER', guy_to_ask)
	end
end

function ZodsRaidAssign.askForBossAssigns()
	local guy_to_ask = tablefirstkey(ZodsRaidAssign.otherUsers)
	if not guy_to_ask then return end
	local request = {t = GetTime(), item = 'bossAssigns', askee = guy_to_ask}
	if ZodsRaidAssign.requestSent then
		table.insert(ZodsRaidAssign.request_queue, request)
	else
		ZodsRaidAssign.requestSent = request
		C_ChatInfo.SendAddonMessage("ZRA", "ra", 'WHISPER', guy_to_ask)
	end
end

function ZodsRaidAssign.sendRequestFromQueue()
	local request = table.remove(ZodsRaidAssign.request_queue, 1)
	if request.item == 'rosterPayload' then
		ZodsRaidAssign.askForRosterPayload()
	end
end

function ZodsRaidAssign.setRosterFromMess(mess)
	for entry in string.gmatch(mess, '([^,]+)') do
		if string.len(entry) == 2 then
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
			local class = ZodsRaidAssign.CLASS_MAP_BACK[tonumber(string.sub(entry,-1))]
			local dude = {
				class = class,
				name = name,
				raidNum = rnum,
			}
			ZRA_vars.roster[string.sub(entry,1,1)] = dude
		end
	end
	ZodsRaidAssign.myRosterChanged()
end

function ZodsRaidAssign.cleanupEvents()
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

function ZodsRaidAssign.checkSavedVars()
	if not ZRA_vars then ZRA_vars = {} end
	if not ZRA_vars.saved_raids then ZRA_vars.saved_raids = {} end
	if not ZRA_vars.roster then ZRA_vars.roster = {} end
	--if not ZRA_vars.raids then ZRA_vars.raids = {
	if not ZRA_vars.raids then 
		ZRA_vars.raids = deepcopy(ZodsRaidAssignPublic.raidschema)
		ZRA_vars.roles = deepcopy(ZodsRaidAssignPublic.roleschema)
	end
end

-- Save copied tables in `copies`, indexed by original table.
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--codes for player UID, to make pickling easier
function ZodsRaidAssign.getUnusedCode()
	for i,v in ipairs(ZodsRaidAssign.CODES) do
		if ZRA_vars.roster[v] == nil then
			return v
		end
	end
end



function ZodsRaidAssign.ParseEvents()
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
				print(cnt .. '. Exited ' .. iname.. ' ' .. string.format("%.1f", (GetTime() - event.time)/60) ..' mins ago')
			end
		end
	end
end

function notFreshInstance()
	local last_exit = false
	local events = ZRA_vars.events or {}
	local inside = false
	for i,event in ipairs(events) do
		if event.inst_type == "party" then
			inside = true
			iname = event.instance
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

function ZodsRaidAssign.MakeMacros()
	ZodsRaidAssign.BuffMacro()
end




function ZodsRaidAssign.GroupDistribute(numGroups,numBuffers)
	sets = {}
	avg = numGroups / numBuffers
	quota = 0
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


function ZodsRaidAssign.GetMakeMacro(name)
	mi = GetMacroIndexByName(name)
	if mi == 0 then 
		CreateMacro(name, 'INV_Misc_QuestionMark', "")
		mi = GetMacroIndexByName(name)
	end
	return mi
end

function ZodsRaidAssign.MacroSetBody(i, body)
	local name,	texture = GetMacroInfo(i)
	EditMacro(i, name, texture, body)
end


ZodsRaidAssign.SHAPES = {
	skull = true,
	x = true,
	square = true,
	moon = true,
	triangle = true,
	diamond = true,
	circle = true,
	star = true,
}

function ZodsRaidAssignPublic.shape(s)
	if ZodsRaidAssign.SHAPES[string.lower(s)] then
		return '{' .. s .. '}'
	else
		return s
	end
end



function ZodsRaidAssign.BuffMacro()
	local numgroups = 8
	local mi = ZodsRaidAssign.mage_iter()
	local di = ZodsRaidAssign.druid_iter()
	local pi = ZodsRaidAssign.priest_iter()
	s = ''
	mages_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetMages())
	s = s .. '/rw MAGE BUFFS\n'
	for i, groups in pairs(mages_groups) do
		mage = mi()
		s = s .. '/rw ' .. mage.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZMageBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	priest_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetPriests())
	s = s .. '/rw PRIEST BUFFS\n'
	for i, groups in pairs(priest_groups) do
		priest = pi()
		s = s .. '/rw ' .. priest.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZPriestBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	druids_groups = ZodsRaidAssign.GroupDistribute(numgroups, #ZodsRaidAssign.GetDruids())
	s = s .. '/rw DRUID BUFFS\n'
	for i, groups in pairs(druids_groups) do
		druid = di()
		s = s .. '/rw ' .. druid.name .. ' groups '
		for j, group in pairs(groups) do
			s = s .. group .. ', '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZDruidBuffs")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.GetTanks()
	return shallowcopy(ZRA_vars.roles[1].columns[1].members)
end

function ZodsRaidAssign.GetHeals()
	return {
		priests=shallowcopy(ZRA_vars.roles[2].columns[1].members),
		pallies=shallowcopy(ZRA_vars.roles[2].columns[2].members),
		druids=shallowcopy(ZRA_vars.roles[2].columns[3].members)
	}
end

function ZodsRaidAssignPublic.tank_heal_iter()
	local unass_healers = ZodsRaidAssign.GetHeals()
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

function ZodsRaidAssignPublic.tank_iter()
	local unass_tanks = ZodsRaidAssign.GetTanks()
	return 
		function ()
			if #unass_tanks > 0 then
				return table.remove(unass_tanks, 1)
			end
		end
end


function ZodsRaidAssignPublic.raid_iter()
	local key = nil
	return function()
		key = next(ZRA_vars.roster, key)
		if key then
			return ZRA_vars.roster[key]
		end
	end
	--	for r in ZodsRaidAssignPublic.raid_iter() do
	--	print(dump(r))
	--end
end

function ZodsRaidAssignPublic.loadMembers()
	local reverse_ind = {}
	for k,v in pairs(ZRA_vars.roster) do
		reverse_ind[v.name] = k
	end
	if IsInGroup() then
		for i=1,GetNumGroupMembers() do
			local name, _, _, _, _, class = GetRaidRosterInfo(i)
			if not reverse_ind[name] then
				ZRA_vars.roster[ZodsRaidAssign.getUnusedCode()] = {
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
			ZRA_vars.roster[ZodsRaidAssign.getUnusedCode()] = {
			class = class,
			name = name,
			raidNum = 1,
			}
		end
	end
	ZodsRaidAssign.pushNewRoster()
end

function ZodsRaidAssign.pushNewRoster()
	ZodsRaidAssign.raidsRosterVersion = ZodsRaidAssign.rosterVersion()
	ZodsRaidAssign.reGreet()
end

function ZodsRaidAssign.myRosterChanged()
	if ZRALayoutFrame:IsShown() then 
		ZodsRaidAssignPublic.OpenMenu()
	end
end

function ZodsRaidAssignPublic.updateRaidNums()
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

function ZodsRaidAssignPublic.dropMembers()
	ZRA_vars.roster = {}
	ZRA_vars.raids = deepcopy(ZodsRaidAssignPublic.raidschema)
	ZRA_vars.roles = deepcopy(ZodsRaidAssignPublic.roleschema)
	ZodsRaidAssignPublic.loadMembers()
end

function ZodsRaidAssignPublic.getCodeFromName(n)
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
		ZodsRaidAssignPublic.OpenMenu()
	elseif (command == 'clear') then
		ZRA_vars.raids = deepcopy(ZodsRaidAssignPublic.raidschema)
		ZRA_vars.roles = deepcopy(ZodsRaidAssignPublic.roleschema)
		ZRA_vars.roster = {}
		ZodsRaidAssign.myRosterChanged()
		ZodsRaidAssign.pushNewRoster()
		print('cleared')
	elseif (command == 'debug') then
		ZodsRaidAssignPublic.debugging = true
		print('debugging')
	elseif (command == 'dontgray') then
		ZodsRaidAssignPublic.dontgray = true
		print('gray off')
	elseif (command == 'i') then
		print('Recent instances')
		ZodsRaidAssign.ParseEvents()
	elseif (command == 'wipe') then
		notFreshInstance()
		print('wipe')
	elseif (command == 'test1') then
		ZRA_vars.roster = ZodsRaidAssignPublic.testroster1
		ZodsRaidAssign.myRosterChanged()
		ZodsRaidAssign.pushNewRoster()
		print('using test roster 1')
	elseif (command == 'test2') then
		ZRA_vars.roster = ZodsRaidAssignPublic.testroster2
		ZodsRaidAssign.myRosterChanged()
		ZodsRaidAssign.pushNewRoster()
		print('using test roster 2')
	elseif (command == 'save') then
		if arg1 then 
			print('saving ' .. arg1)
			ZRA_vars.saved_raids[arg1] = {}
			ZRA_vars.saved_raids[arg1].roster = deepcopy(ZRA_vars.roster)
			ZRA_vars.saved_raids[arg1].roles = deepcopy(ZRA_vars.roles)
			ZRA_vars.saved_raids[arg1].raids = deepcopy(ZRA_vars.raids)
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
				table.insert(ZodsRaidAssignPublic.assignUpdateHistory, {update_type = 'roster', sender = "ME", mess = 'loaded a stored raid, ' .. arg1})
				ZodsRaidAssign.myRosterChanged()
				ZodsRaidAssign.pushNewRoster()
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
		ZodsRaidAssign.PrintHelp()
	end
end

function ZodsRaidAssign.PrintHelp()
	print('load/save/delete {name}')
	print('\'i\' shows instances, \'wipe\' removes last zone out, test{1,2} for test raid, clear, dontgray, debug')
end

function dump(o)
	if type(o) == 'table' then
		 local s = '{ '
		 for k,v in pairs(o) do
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. dump(v) .. ','
		 end
		 return s .. '} '
	else
		 return tostring(o)
	end
end

function shallowcopy(orig)
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

function modulo(a,b)
	return a - math.floor(a/b)*b
end

function tablelen(t)
	local numItems = 0
	for k,v in pairs(t) do
		numItems = numItems + 1
	end
	return numItems
end

function tablefirstkey(t)
	for k,v in pairs(t) do
		return(k)
	end
end

function splitmess(mess_arr, sep, lencap)
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

function remaining(it)
	local temp = {}
	for item in it do
		table.insert(temp,item)
	end
	return temp
end

function mysplit (inputstr, sep)
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

function dicestring(str)
	local t = {}
	for i = 1, string.len(str) do
		table.insert(t, string.sub(str, i, i))
	end
	return t
end

function codesToValsArr(codes, hash, key)
	local vals = {}
	for _,v in ipairs(codes) do
		table.insert(vals, hash[v][key])
	end
	return vals
end

ZodsRaidAssign.scriptframe = CreateFrame("Frame", 'ZRAFrame')
ZodsRaidAssign.scriptframe:RegisterEvent("ADDON_LOADED")
ZodsRaidAssign.scriptframe:RegisterEvent("CHAT_MSG_ADDON")
ZodsRaidAssign.scriptframe:RegisterEvent("GROUP_JOINED")
ZodsRaidAssign.scriptframe:RegisterEvent("GROUP_ROSTER_UPDATE")
ZodsRaidAssign.scriptframe:SetScript("OnEvent", ZodsRaidAssign.onEvent)
ZodsRaidAssign.scriptframe:SetScript("OnUpdate", ZodsRaidAssign.onUpdate)

some_events = {
	'PLAYER_QUITING',
	'PLAYER_LOGOUT',
	'PLAYER_LOGIN',
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEAVING_WORLD",
}
for k, v in pairs(some_events) do
	ZodsRaidAssign.scriptframe:RegisterEvent(v)
end