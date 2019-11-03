


local ZodsRaidAssign = {

}
	

function ZodsRaidAssign.onUpdate()

end

function ZodsRaidAssign.onLoad()
	ZodsRaidAssign.CODES = {}
	local str = 'abcdefghijklmnopqrstuvwxysABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	for i = 1, string.len(str) do
		table.insert(ZodsRaidAssign.CODES, string.sub(str, i, i))
	end
	ZodsRaidAssign.checkSavedVars()
end


function ZodsRaidAssign.onEvent(frame, event, arg1, arg2, arg3, ...)
	if (event == "ADDON_LOADED" and arg1 == "ZodsRaidAssign") then
		
		ZodsRaidAssign.onLoad()
		ZodsRaidAssign.cleanupEvents()
		
		
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "ZRA" and (arg3 == "PARTY" or arg3 == "WHISPER" or arg3 == "RAID")  then -- and arg4 ~= UnitName("player")
      	ZodsRaidAssign:HandleRemoteData(arg2, arg4)
		end
	elseif event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LEAVING_WORLD' then
		--unhandled onEvent
		local events = ZRA_vars.events or {}
		ZRA_vars.events = events
		local iname, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
		if #events==0 or (not (instanceType == events[#events].inst_type)) then
			table.insert(events, {event = event, time = GetTime(), instance = iname, inst_type = instanceType, id = instanceID})
		else
			print(instanceType .. events[#events].inst_type)
		end
	else
	end
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
	--if not ZRA_vars.raids then ZRA_vars.raids = {
	if true then 
		ZRA_vars.raids = ZodsRaidAssignPublic.raidschema
		ZRA_vars.roles = ZodsRaidAssignPublic.roleschema
	end
	--dummy roster
	if true then 
		ZRA_vars.roster = {}
		local i = 1
		for r in ZodsRaidAssign.raid_iter() do
			ZRA_vars.roster[ZodsRaidAssign.getUnusedCode()] = {
				class = r.class,
				name = r.name,
				raidNum = i,
			}
			i = i + 1
		end
	end
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
	ZodsRaidAssign.TankMacro()
	ZodsRaidAssign.CCMacro()
	ZodsRaidAssign.BuffMacro()
	ZodsRaidAssign.TrashHealMacro()
	ZodsRaidAssign.LuciMacro()
	ZodsRaidAssign.MagMacro()
	ZodsRaidAssign.GehMacro()
	ZodsRaidAssign.GarrMacro()
	ZodsRaidAssign.DomoMacro()
	ZodsRaidAssign.SulfMacro()
	ZodsRaidAssign.RagMacro()
	ZodsRaidAssign.GoleMaggMacro()
end

function ZodsRaidAssignPublic.parseRaidPost(post)
	local tanks, ti = {}, ZodsRaidAssign.tank_iter()
	local heals, hi = {}, ZodsRaidAssign.tank_heal_iter()
	local locks, li = {}, ZodsRaidAssign.lock_iter()
	local melee, mi = {}, ZodsRaidAssign.melee_iter()
	for i = 1,10 do
		table.insert(tanks, ti())
		table.insert(heals, hi())
		table.insert(locks, li())
		table.insert(melee, mi())
	end
	local temp = string.gsub(post, "%%%a+%d", function(str)
		local pre = string.sub(str, 2, -2)
		local ind = tonumber(string.sub(str,-1))
		if pre == "tank" then 
			return tanks[ind].name
		elseif pre == "heal" then 
			return heals[ind].name
		elseif pre == "lock" then 
			return locks[ind].name
		elseif pre == "melee" then 
			return melee[ind].name
		else
			return str
		end
	end)
	return temp
end


function ZodsRaidAssign.BaronMacro()
end

function ZodsRaidAssign.ShazzMacro()

end

function ZodsRaidAssign.GoleMaggMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	s = '/rw GOLEMAG\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'

	i = ZodsRaidAssign.GetMakeMacro("ZGolemag")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.RagMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	s = '/rw RAG\n'
	s = s .. '/rw  Heal the bosses target ' .. hi().name .. ', ' .. hi().name .. ' and ' .. hi().name ..'\n'
	s = s .. '/rw  Healing ' .. ti().name .. ' full time is ' .. hi().name .. '\n'
	s = s .. '/rw  Healing ' .. ti().name .. ' full time is ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ZodsRaidAssign.RemainingHeals(hi) .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZRagnaros")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.SulfMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()
	local mi = ZodsRaidAssign.melee_iter()
	local s = '/rw SULF\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZSulf1")
	ZodsRaidAssign.MacroSetBody(i, s)

	s = ''
	s = s .. '/rw ' .. ti().name .. ' is on {Moon}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. mi().name .. ' kick {X}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Skull}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Square}\n'
	s = s .. '/rw ' .. mi().name .. ' kick {Moon}\n'
	i = ZodsRaidAssign.GetMakeMacro("ZSulf2")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.DomoMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()
	local t1 = ti()
	local t2 = ti()
	local t3 = ti()
	local t4 = ti()
	local t5 = ti()

	local s = '/rw DOMO\n'
	s = s .. '/rw ' .. t3.name .. ' is on DOMO, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t4.name .. ' is on {X}->{Moon}->{Diamond}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t5.name .. ' is on {Skull}->{Star}->{Circle}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. t1.name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZDomo1")
	ZodsRaidAssign.MacroSetBody(i, s)

	local mi = ZodsRaidAssign.mage_iter()
	s = ''
	
	s = s .. '/rw ' .. t2.name .. ' is on {Triangle}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Moon}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Star}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Diamond}\n'
	s = s .. '/rw ' .. mi().name .. ' is sheeping {Circle}\n'
	i = ZodsRaidAssign.GetMakeMacro("ZDomo2")
	ZodsRaidAssign.MacroSetBody(i, s)

end

function ZodsRaidAssign.GarrMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()
	local s = '/rw GARR\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Square}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Moon}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on {Triangle}, HEALED BY ' .. hi().name .. '\n'
	i = ZodsRaidAssign.GetMakeMacro("ZGarr")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.GehMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	s = '/rw GEHENAS\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'

	i = ZodsRaidAssign.GetMakeMacro("ZGehns")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.LuciMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	s = '/rw LUCI\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ' and ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on Skull{Skull}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is on X{X}, HEALED BY ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'
	s = s .. '/rw DISPEL MAGIC/CURSE\n'

	i = ZodsRaidAssign.GetMakeMacro("ZLuci")
	ZodsRaidAssign.MacroSetBody(i, s)
end


function ZodsRaidAssign.MagMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	local s = '/rw MAG\n'
	s = s .. '/rw ' .. ti().name .. ' is on BOSS, HEALED BY ' .. hi().name .. ', ' .. hi().name .. ', ' .. hi().name .. '\n'
	s = s .. '/rw ' .. ti().name .. ' is BACKUP tank\n'
	s = s .. '/rw ' .. ZodsRaidAssign.RemainingHeals(hi) .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZMag")
	ZodsRaidAssign.MacroSetBody(i, s)
end

function ZodsRaidAssign.RemainingHeals(hi)
	local s = ''
	n = hi()
	repeat
		s = s .. n.name .. ', '
		n = hi()
	until( n.name == 'missing healer' )
	s = string.sub(s, 0, #s - 2)
	return s
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

function ZodsRaidAssign.TrashHealMacro()
	local ti = ZodsRaidAssign.tank_iter()
	local hi = ZodsRaidAssign.tank_heal_iter()

	s = '/rw TRASH HEAL ASSIGNMENTS\n'
	for i = 1, 3 do
		tank = ti()

		s = s .. '/rw '  .. tank.name .. ' is being healed by '
		for i = 1, 2 do
			healer = hi()
			s = s .. healer.name .. ' , '
		end
		s = string.sub(s, 0, #s - 2)
		s = s .. '\n'
	end
	
	s = s .. '/rw '
	n = hi()
	repeat
		s = s .. n.name .. ', '
		n = hi()
	until( n.name == 'missing healer' )
	s = string.sub(s, 0, #s - 2)
	s = s .. ' on raid heals'

	i = ZodsRaidAssign.GetMakeMacro("ZTrashHeals")
	ZodsRaidAssign.MacroSetBody(i, s)
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

function ZodsRaidAssign.TankMacro()
	local ti = ZodsRaidAssign.tank_iter()
	shapes = {
		'X {X}',
		'skull {Skull}',
		'Square {Square}',
		'Moon {Moon}',
		'Triangle {Triangle}',
	}
	s = '/rw TANK ASSIGNMENTS \n'
	for _, shape in pairs(shapes) do
		tank = ti()
		s = s .. '/rw '  .. tank.name .. ' tanking ' .. shape .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZTankShapes")
	ZodsRaidAssign.MacroSetBody(i, s)
end

ZodsRaidAssignPublic.SHAPES = {
	'{Skull}',
	'{X}',
	'{Square}',
	'{Moon}',
	'{Triangle}',
	'{Diamond}',
	'{Circle}',
	'{Star}',
}

function ZodsRaidAssign.CCMacro()
	local li = ZodsRaidAssign.lock_iter()
	shapes = {
		'Diamond {Diamond}',
		'Circle {Circle}',
		'Star {Star}',
	}
	s = '/rw LOCK BANISH ASSIGNMENTS\n'
	for _, shape in pairs(shapes) do
		lock = li()
		s = s .. '/rw '  .. lock.name .. ' banishing ' .. shape .. '\n'
	end
	i = ZodsRaidAssign.GetMakeMacro("ZLockShapes")
	ZodsRaidAssign.MacroSetBody(i, s)
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
	local temp = {}
	for i,v in ipairs(ZRA_vars.roles[1].columns[1].members) do
		table.insert(temp,ZRA_vars.roster[v])
	end
	
	return temp
end

function ZodsRaidAssign.GetHeals()
	return {
		pallies=shallowcopy(ZRA_vars.raid.healers.pallies),
		priests=shallowcopy(ZRA_vars.raid.healers.priests),
		druids=shallowcopy(ZRA_vars.raid.healers.druids)
	}
end

function ZodsRaidAssign.tank_heal_iter()
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
					return {name='missing healer'}
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
					return {name='missing healer'}
				end
			end
		end
end

function ZodsRaidAssign.tank_iter()
	unass_tanks = ZodsRaidAssign.GetTanks()
	return 
		function ()
			if #unass_tanks > 0 then
				return table.remove(unass_tanks, 1)
			else
				return {name='missing tank'}
			end
		end
end

function ZodsRaidAssign.GetLocks()
	return shallowcopy(ZRA_vars.raid.locks)
end

function ZodsRaidAssign.lock_iter()
	local unass_locks = ZodsRaidAssign.GetLocks()
	return 
		function ()
			if #unass_locks > 0 then
				return table.remove(unass_locks, 1)
			else
				return {name='missing warlock'}
			end
		end
end

function ZodsRaidAssign.GetMelee()
	return shallowcopy(ZRA_vars.raid.melee)
end

function ZodsRaidAssign.melee_iter()
	local unass = ZodsRaidAssign.GetMelee()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing melee'}
			end
		end
end

function ZodsRaidAssign.GetMages()
	return shallowcopy(ZRA_vars.raid.mages)
end

function ZodsRaidAssign.mage_iter()
	local unass = ZodsRaidAssign.GetMages()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing mage'}
			end
		end
end

function ZodsRaidAssign.GetDruids()
	return shallowcopy(ZRA_vars.raid.healers.druids)
end

function ZodsRaidAssign.druid_iter()
	local unass = ZodsRaidAssign.GetDruids()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing druid'}
			end
		end
end

function ZodsRaidAssign.GetPriests()
	return shallowcopy(ZRA_vars.raid.healers.priests)
end

function ZodsRaidAssign.priest_iter()
	unass = ZodsRaidAssign.GetPriests()
	return 
		function ()
			if #unass > 0 then
				return table.remove(unass, 1)
			else
				return {name='missing priest'}
			end
		end
end

function ZodsRaidAssign.PurgeRaid()
	local raid_mems = {}
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		raid_mems[name] = true
	end
	for n in ZodsRaidAssign.raid_iter() do
		if raid_mems[n.name] == nil then
			ZodsRaidAssign.DeleteRaider(n)
		end
	end
end

function ZodsRaidAssign.DeleteRaider(n, raid)
	if not raid then raid = ZRA_vars.raid end
	for i,v in pairs(raid) do
		if v.name then
			if v.name == n then
				raid[i] = nil
			end
		elseif type(v) == 'table' then
			ZodsRaidAssign.DeleteRaider(n, v)
		end
	end
	return false
end

function ZodsRaidAssign.SnapShotRaid()
	local raid = ZRA_vars.raid or {tanks = {}, healers = {pallies = {}, priests = {}, druids = {}}, mages = {}, locks = {}, hunters = {}, melee = {}}
	for i=1,GetNumGroupMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		 ZodsRaidAssign.AssumeRole(raid, {name=name, class=class})
	end
	return raid
end

function ZodsRaidAssign.AssumeRole(raid, member)
	if ZodsRaidAssign.MemberIsInRaidAlready(member, raid) then return end
	if member.class == 'WARRIOR' then
		table.insert(raid.tanks, member)
	elseif member.class == 'PALADIN' then
		table.insert(raid.healers.pallies, member)
	elseif member.class == 'PRIEST' then
		table.insert(raid.healers.priests, member)
	elseif member.class == 'DRUID' then
		table.insert(raid.healers.druids, member)
	elseif member.class == 'WARLOCK' then
		table.insert(raid.locks, member)
	elseif member.class == 'MAGE' then
		table.insert(raid.mages, member)
	elseif member.class == 'HUNTER' then
		table.insert(raid.hunters, member)
	elseif member.class == 'ROGUE' then
		table.insert(raid.melee, member)
	else 
		print('wtf is ' .. member.class .. ' class')
	end
end

function ZodsRaidAssign.raid_iter()
	local index = nil
	local subindex = nil
	local groups = {
		ZRA_vars.raid.tanks,
		ZRA_vars.raid.melee,
		ZRA_vars.raid.hunters,
		ZRA_vars.raid.locks,
		ZRA_vars.raid.mages,
		ZRA_vars.raid.healers.pallies,
		ZRA_vars.raid.healers.druids,
		ZRA_vars.raid.healers.priests,
	}
	index = next(groups, nil)
	
	return function()
		subindex = next(groups[index], subindex)
		if subindex then
			return groups[index][subindex]
		else
			repeat
			index = next(groups, index)
			until (not index) or #groups[index] >0
			if index then
				subindex = next(groups[index], subindex)
				if subindex then
					return groups[index][subindex]
				end
			end
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

function ZodsRaidAssignPublic.getCodeFromName(n)
	for k,v in pairs(ZRA_vars.roster) do
		if v.name ==n then
			return k
		end
	end
end



function ZodsRaidAssign.MemberIsInRaidAlready(member, raid)
	for i,v in pairs(raid) do
		if v.name then
			if v.name == member.name then
				return true 
			end
		else
			if ZodsRaidAssign.MemberIsInRaidAlready(member, v) then
				return true
			end
		end
	end
	return false
end

--- slash handler
SLASH_ZRAIDASSIGN1 = "/zra"
SlashCmdList["ZRAIDASSIGN"] = function(msg)
	local command, arg1, arg2, arg3 = strsplit(" ",msg)
	if command == '' then
		ZodsRaidAssign.PrintHelp()
	end
	if (command == "re") then
		local s = ZodsRaidAssign.GroupDistribute(8,4)
		print(dump(s))
	elseif (command == "load") then
		ZRA_vars.raid = ZodsRaidAssign.SnapShotRaid()
		print('loaded')
	elseif (command == "purge") then
		ZodsRaidAssign.PurgeRaid()
		print('purged')
	elseif (command == "rf") then
		ZRA_vars.raid = ZodsRaidAssign.SnapShotRaid()
		ZodsRaidAssign.PurgeRaid()
		print('refreshed')
	elseif (command == 'clear') then
		ZRA_vars.raid = {tanks = {}, healers = {pallies = {}, priests = {}, druids = {}}, mages = {}, locks = {}, hunters = {}, melee = {}}
		print('cleared')
	elseif (command == 'print') then
		for n in ZodsRaidAssign.raid_iter() do
			print(n.name)
		end
	elseif (command == 'macros') then
		ZodsRaidAssign.MakeMacros()
		print('macros made')
	elseif (command == 'i') then
		ZodsRaidAssign.ParseEvents()
	elseif (command == 'wipe') then
		notFreshInstance()
		print('wipe')
	elseif (command == 'menu') then
		ZodsRaidAssignPublic.OpenMenu()
	elseif (command == 'test') then
		
	else 
	end
end

function ZodsRaidAssign.PrintHelp()
	print('load, clear, purge, rf, macros, i, wipe, print, menu')
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

ZodsRaidAssign.scriptframe = CreateFrame("Frame", 'ZRAFrame')
ZodsRaidAssign.scriptframe:RegisterEvent("ADDON_LOADED")
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